from sensors.dht import DHT
from sensors.mq135 import MQ135
from sensors.pcf8591 import PCF8591
from sensors.bmp280 import BMP280
from sensors.bh1750 import BH1750
from sensors.ultrasonic import Ultrasonic
from config.db import SiepaDB
from mqtt.client import SiepaMqttClient
from utils.generic_device import GenericOutputDevice
from utils.display import DisplayLCD
from models.app_settings_model import AppSettings
from models.device_manager import DeviceManager
from config.mongodb import mongodb_connection
from pymongo import DESCENDING
from threading import Thread, Event
from datetime import datetime
import board
import RPi.GPIO as GPIO
import time
import json
import queue

class SiepaG11App(object):

    # Singleton pattern
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(SiepaG11App, cls).__new__(cls)
        return cls.instance

    def __init__(self):
        # GPIO.setmode(GPIO.BCM)

        self.device_manager = DeviceManager()

        self.running = False
        self.stop_event = Event()  # For graceful thread termination

        # Define sensors
        self.dht_sensor = DHT(board.D17, "DHT11")
        self.bmp_sensor = BMP280()
        self.mq_sensor = MQ135(PCF8591(), channel=0, vref=5.0, load_resistance=10.0, r0=20.5)
        self.bh_sensor = BH1750(bus=1)
        # self.ultrasonic_sensor = Ultrasonic(trigger_pin=27, echo_pin=22, detection_range_cm=50.0)
        self.ultrasonic_sensor = Ultrasonic(trigger_pin=27, echo_pin=22, detection_range_cm=15.0)
        self.presence_helper = False

        # Define output devices
        self.display_lcd = self.device_manager.display_lcd
        
        self.red_led = self.device_manager.red_led
        self.green_led = self.device_manager.green_led
        self.yellow_led = self.device_manager.yellow_led
        self.blue_led = self.device_manager.blue_led

        self.buzzer_device = self.device_manager.buzzer_device
        self.fan_device = self.device_manager.fan_device
        self.lighting_device = self.device_manager.lighting_device

        self.display_queue = queue.Queue()
        self.alert_queue = queue.Queue()

        self.last_display_message = None
        self.last_alert_message = None
        
        # Define MQTT client
        self.mqtt_client = SiepaMqttClient()

        # Threads
        self.mqtt_thread = None
        self.sensor_thread = None
        self.display_thread = None

        self.pause_display_event = Event()

        # Create MongoDB database and collections
        self.database = mongodb_connection.get_database('arqui1_siepa_g11_db')
        self.sensor_readings_collection = self.database['sensor_readings']
        self.alerts_collection = self.database['alerts']
        self.predictions_collection = self.database['predictions']
        self.stadistics_collection = self.database['statistics']

        self.current_reading = None  # To store the latest sensor reading

        # App settings
        self.config = AppSettings(
            "SiepaG11App",
            "1.0.0",
            True,
            "automatic"  # Default mode
        )

    def run_mqtt(self):
        """Run MQTT client in a separate thread"""
        self.mqtt_client.connect()
        self.mqtt_client.run()
    
    def turning_off_with_delay(self, led, device=None):
        time.sleep(5)
        led.turn_off_device()
        if(device is None): return
        device.turn_off_device()

    def save_sensor_readings_to_mongodb(self):
        if not self.current_reading:
            return  # No data to save
        
        try:
            
            # Insert into MongoDB
            result = self.sensor_readings_collection.insert_one({
                "timestamp": self.current_reading.timestamp,
                "temperature": self.current_reading.temperature,
                "humidity": self.current_reading.humidity,
                "pressure": self.current_reading.pressure,
                "air_quality": self.current_reading.air_quality,
                "luminosity": self.current_reading.luminosity,
                "proximity": self.current_reading.proximity,
            })
            
            print(f"Saved SENSOR DATA to MongoDB with id: {result.inserted_id}")
            
        except Exception as e:
            print(f"Failed to save sensor data to MongoDB: {e}")
    
    def save_alert_to_mongodb(self, measurement, value):
        if not self.current_reading:
            return  # No data to save
        
        try:
            
            # Insert into MongoDB
            result = self.alerts_collection.insert_one({
                "timestamp": self.current_reading.timestamp,
                "measurement": measurement,
                "value": value
            })
            
            print(f"Saved ALERT to MongoDB with id: {result.inserted_id}")
            
        except Exception as e:
            print(f"Failed to save sensor data to MongoDB: {e}")

    def run_sensor_tasks(self):
        """Run sensor reading loop in a separate thread"""

        last_save_time = time.time() # Initialize last save time

        while not self.stop_event.is_set():
            try:
                current_time = time.time()

                # Create a siepaDB instance
                self.current_reading = SiepaDB(
                    temperature=self.dht_sensor.temperature,
                    humidity=self.dht_sensor.humidity,
                    pressure=self.bmp_sensor.pressure,
                    air_quality=self.mq_sensor.ppm,
                    luminosity=self.bh_sensor.luminosity,
                    proximity=self.ultrasonic_sensor.proximity
                )

                self.current_reading.ensure_none_null_values()

                if current_time - last_save_time >= 30:
                    try:
                        # self.save_sensor_data_to_mongodb()
                        Thread(target=self.save_sensor_readings_to_mongodb, daemon=True).start()
                        last_save_time = current_time  # Update last save time
                    except Exception as e:
                        print(f"Error saving to MongoDB: {e}")
                
                # Store data
                #self.storage.append(self.current_reading) # No longer used, we make use of MongoDB

                # Publish to MQTT messages
                self.mqtt_client.publish('temperature', json.dumps({'temperature': self.current_reading.temperature}))
                self.mqtt_client.publish('humidity', json.dumps({'humidity': self.current_reading.humidity}))
                self.mqtt_client.publish('pressure', json.dumps({'pressure': self.current_reading.pressure}))
                self.mqtt_client.publish('air_quality', json.dumps({'air_quality': self.current_reading.air_quality}))
                self.mqtt_client.publish('luminosity', json.dumps({'luminosity': self.current_reading.luminosity}))

                if not self.presence_helper and self.current_reading.proximity > 0:
                    self.mqtt_client.publish('proximity', json.dumps({'proximity': self.current_reading.proximity}))
                    self.presence_helper = True
                elif self.presence_helper and  self.current_reading.proximity <= 0:
                    self.presence_helper = False

                # Check if we should stop
                if self.stop_event.is_set():
                    break

                # ACTUATORS: Perform some actions based on sensor data

                # Red LED (temperature >= 28)
                if self.current_reading.temperature >= 28 and not self.red_led.mode and self.fan_device.control == 'automatic':
                    self.red_led.turn_on_device()
                    self.mqtt_client.publish('temperature/danger', json.dumps({
                        'message': 'High temperature detected! Turning on red LED.'
                    }))
                    self.fan_device.turn_on_device()
                    self.show_priority_message("Alerta temp", 5)
                elif self.current_reading.temperature < 28 and self.red_led.mode and self.fan_device.control == 'automatic':
                    Thread(target=self.turning_off_with_delay, args=(self.red_led, self.fan_device)).start()
                    # Turning off the fans in 5 seconds...
                
                # Yellow LED (humidity >= 70)
                if self.current_reading.humidity >= 70 and not self.yellow_led.mode and self.lighting_device.control == 'automatic':
                    self.yellow_led.turn_on_device()

                    self.mqtt_client.publish('humidity/danger', json.dumps({
                        'message': 'High humidity detected! Turning on yellow LED.'
                    }))
                    self.show_priority_message("Alerta humedad", 5)
                elif self.current_reading.humidity < 70 and self.yellow_led.mode and self.lighting_device.control == 'automatic':
                    Thread(target=self.turning_off_with_delay, args=(self.yellow_led, None)).start()
                
                # Green LED (luminosity <= 200)
                if self.current_reading.luminosity <= 45 and not self.green_led.mode and self.lighting_device.control == 'automatic' and self.green_led.control == 'automatic':
                    self.luminosity_helper = True
                    self.green_led.turn_on_device()
                    self.mqtt_client.publish('luminosity/danger', json.dumps({
                        'message': 'Low luminosity detected! Turning on green LED.'
                    }))
                    self.lighting_device.turn_on_device()
                    self.show_priority_message("Alerta luz", 5)
                elif self.current_reading.luminosity > 45 and self.green_led.mode and self.lighting_device.control == 'automatic' and self.green_led.control == 'automatic':
                    # self.green_led.turn_off_device()
                    self.luminosity_helper = False
                    Thread(target=self.turning_off_with_delay, args=(self.green_led, self.lighting_device)).start()
                
                # Blue LED (air quality >= 1000)
                if self.current_reading.air_quality >= 700 and not self.blue_led.mode and self.blue_led.control == 'automatic':
                    self.blue_led.turn_on_device()
                    self.mqtt_client.publish('air_quality/danger', json.dumps({
                        'message': 'Low air_quality detected! Turning on blue LED.'
                    }))
                    self.buzzer_device.turn_on_device()
                    self.show_priority_message("Alerta aire", 5)
                elif self.current_reading.air_quality < 700 and self.blue_led.mode and self.blue_led.control == 'automatic':
                    Thread(target=self.turning_off_with_delay, args=(self.blue_led, self.buzzer_device)).start()

                for alert in self.current_reading.alert_messages():
                    self.safe_put(self.alert_queue, alert, 'last_alert_message')

                for line in self.current_reading.to_display_lines():
                    self.safe_put(self.display_queue, line, 'last_display_message')


                if self.current_reading.temperature >= 28:
                    Thread(target=self.save_alert_to_mongodb, daemon=True, args=("temperature", self.current_reading.temperature)).start()
                if self.current_reading.humidity >= 70:
                    Thread(target=self.save_alert_to_mongodb, daemon=True, args=("humidity", self.current_reading.humidity)).start()
                if self.current_reading.air_quality >= 700:
                    Thread(target=self.save_alert_to_mongodb, daemon=True, args=("air_quality", self.current_reading.air_quality)).start()
                if self.current_reading.luminosity <= 45:
                    Thread(target=self.save_alert_to_mongodb, daemon=True, args=("luminosity", self.current_reading.luminosity)).start()   
                if self.current_reading.pressure < 600: # Not that sure about this value yet
                    Thread(target=self.save_alert_to_mongodb, daemon=True, args=("pressure", self.current_reading.pressure)).start()
                
                time.sleep(2)

            except Exception as e:
                #print(f"Error in sensor tasks: {e}")
                time.sleep(1)  # Prevent tight loop on error

    def run_display(self):
        previous_line = ""
        current_line = ""
        current_mode = self.display_lcd.show

        while not self.stop_event.is_set():
            if self.pause_display_event.is_set():
                time.sleep(0.1)
                continue

            try:
                if current_mode != self.display_lcd.show:
                    print(f"Display mode has changed: {current_mode} -> {self.display_lcd.show}")
                    current_mode = self.display_lcd.show

                    with self.display_queue.mutex:
                        self.display_queue.queue.clear()
                    with self.alert_queue.mutex:
                        self.alert_queue.queue.clear()
                    self.last_display_message = None
                    self.last_alert_message = None
                    self.display_lcd.clear()

                if not self.alert_queue.empty():
                    new_line = self.alert_queue.get(timeout=1)
                    previous_line = current_line
                    current_line = new_line

                    self.display_lcd.clear()
                    self.display_lcd.write_centered(current_line, 1)
                    time.sleep(5)
                    continue

                if current_mode == 'readings':
                    new_line = self.display_queue.get(timeout=1)
                    previous_line = current_line
                    current_line = new_line

                    self.display_lcd.clear()
                    self.display_lcd.write_centered(previous_line, 1)
                    self.display_lcd.write_centered(current_line, 2)
                    time.sleep(2)

                elif current_mode in ['statistics', 'predictions']:
                    print("================================================================================================================")
                    print("if not DeviceManager().new_message_helper: return")
                    print("================================================================================================================")
                    if not DeviceManager().new_message_helper: return
                    print("================================================================================================================")
                    print("if not DeviceManager().new_message_helper: return DESPUESSSSS")
                    print("================================================================================================================")

                    self.display_lcd.clear()
                    
                    if current_mode == 'statistics':
                        data_dict = self.get_last_calculation_dict('statistics')
                    else:
                        data_dict = self.get_last_calculation_dict('predictions')
                    print("================================================================================================================")
                    print("data_dict")
                    print(data_dict)
                    print("================================================================================================================")

                    for key, value in data_dict.items():
                        if self.pause_display_event.is_set() or current_mode != self.display_lcd.show:
                            break
                        self.display_lcd.clear()
                        self.display_lcd.write_centered(key, 1)
                        self.display_lcd.write_centered(str(value), 2)
                        time.sleep(2)

                    self.display_lcd.clear()
                    DeviceManager().new_message_helper = False
                    print("================================================================================================================")
                    print(f"Display cleared after showing {current_mode} data.")
                    print("================================================================================================================")

            except queue.Empty:
                continue

    def get_last_calculation_dict(self, collection):
        # Get the last document
        if not collection:
            return {}
        
        if collection == 'statistics':
            last_dict = self.stadistics_collection.find_one(sort=[('_id', DESCENDING)])
        elif collection == 'predictions':
            last_dict = self.predictions_collection.find_one(sort=[('_id', DESCENDING)])
        else:
            return {}

        if not last_dict:
            return {}

        # Extract timestamp
        timestamp = last_dict.get('timestamp')
        if isinstance(timestamp, datetime):
            last_dict['date'] = timestamp.strftime('%Y-%m-%d')
            last_dict['time'] = timestamp.strftime('%H:%M:%S')

        # Clean up unnecessary fields
        last_dict.pop('timestamp', None)
        last_dict.pop('_id', None)

        return last_dict
        

    def show_priority_message(self, msg: str, duration: int = 5):
        if self.display_lcd.show != 'readings': return
        
        """Pausa el display, muestra un mensaje por unos segundos, limpia las colas y reanuda."""
        def task():
            self.pause_display_event.set()  # Pausar display
            self.display_lcd.clear()
            self.display_lcd.write_centered(msg, 1)
            time.sleep(duration)

            # Limpiar colas
            with self.display_queue.mutex:
                self.display_queue.queue.clear()
            with self.alert_queue.mutex:
                self.alert_queue.queue.clear()

            self.last_display_message = None
            self.last_alert_message = None

            self.display_lcd.clear()
            self.pause_display_event.clear()  # Reanudar display
            # self.display_queue.clear()  # Clear display queue

        Thread(target=task, daemon=True).start()


    def start(self):
        """Start all threads"""
        if self.running:
            return

        self.running = True
        self.stop_event.clear()

        # Start MQTT client thread
        self.mqtt_thread = Thread(target=self.run_mqtt, daemon=True)
        self.mqtt_thread.start()

        # Start sensor tasks thread
        self.sensor_thread = Thread(target=self.run_sensor_tasks, daemon=True)
        self.sensor_thread.start()

        # # Start display thread
        self.display_thread = Thread(target=self.run_display, daemon=True)
        self.display_thread.start()

    def stop(self):
        if not self.running:
            return

        self.running = False
        self.stop_event.set()

        # Stop MQTT client
        if hasattr(self.mqtt_client, 'disconnect'):
            self.mqtt_client.disconnect()

        # Wait for threads to finish
        if self.sensor_thread and self.sensor_thread.is_alive():
            self.sensor_thread.join(timeout=5)
        
        if self.mqtt_thread and self.mqtt_thread.is_alive():
            self.mqtt_thread.join(timeout=5)
            
        if self.display_thread and self.display_thread.is_alive():
            self.display_thread.join(timeout=5)

        # Cleanup GPIO pins
        GPIO.cleanup()

    def safe_put(self, q, msg, last_msg_attr):
        last_msg = getattr(self, last_msg_attr, None)
        if msg != last_msg:
            q.put(msg)
            setattr(self, last_msg_attr, msg)
    
    def perform(self):
        """Main application entry point"""
        self.display_lcd.write_centered("Bienvenido a", 1)
        self.display_lcd.write_centered("SIEPA - Grupo 11", 2)
        time.sleep(5)  # Wait for 5 seconds before starting
        self.display_lcd.clear()

        try:
            self.start()
            
            # Main thread can do other work here or just wait
            while self.running:
                time.sleep(4)
                
        except KeyboardInterrupt:
            pass
            #print("\nReceived keyboard interrupt, stopping...")
        finally:
            self.stop()

    def __del__(self):
        """Destructor to ensure clean shutdown"""
        self.stop()