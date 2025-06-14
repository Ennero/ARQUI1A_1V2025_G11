from sensors.dht import DHT
from sensors.mq135 import MQ135
from sensors.pcf8591 import PCF8591
from sensors.bmp280 import BMP280
from sensors.bh1750 import BH1750
from sensors.ultrasonic import Ultrasonic
from config.db import SiepaDB
from config.server import FlaskServer
from mqtt.client import SiepaMqttClient
from utils.generic_device import GenericOutputDevice
from utils.display import DisplayLCD
from models.app_settings_model import AppSettings
from models.device_manager import DeviceManager
from threading import Thread, Event
import board
import RPi.GPIO as GPIO
import time
import json
import queue
# from dotenv import load_dotenv
# import os


class SiepaG11App(object):

    # Singleton pattern
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(SiepaG11App, cls).__new__(cls)
        return cls.instance

    def __init__(self):
        # GPIO.setmode(GPIO.BCM)
        # Load environment variables
        # load_dotenv()

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

        self.humidity_helper = False
        self.temperature_helper = False
        self.pressure_helper = False
        self.air_quality_helper = False

        # Define output devices
        self.display_lcd = DisplayLCD()
        
        self.red_led = self.device_manager.red_led
        self.green_led = self.device_manager.green_led
        self.yellow_led = self.device_manager.yellow_led
        self.blue_led = self.device_manager.blue_led

        self.buzzer_device = self.device_manager.buzzer_device
        self.fan_device = self.device_manager.fan_device
        self.lighting_device = self.device_manager.lighting_device

        self.fan_device.turn_off_device()

        # Define storage
        self.storage = [] # We will implement MongoDB later
        self.display_queue = queue.Queue()
        self.alert_queue = queue.Queue()

        self.last_display_message = None
        self.last_alert_message = None
        
        # Define Flask server and MQTT client
        self.server = FlaskServer()
        self.mqtt_client = SiepaMqttClient()

        # Threads
        self.flask_thread = None
        self.mqtt_thread = None
        self.sensor_thread = None
        self.display_thread = None

        self.pause_display_event = Event()

        # App settings
        self.config = AppSettings(
            "SiepaG11App",
            "1.0.0",
            True,
            "automatic"  # Default mode
        )

    def run_flask(self):
        """Run Flask server in a separate thread"""
        self.server.run()

    def run_mqtt(self):
        """Run MQTT client in a separate thread"""
        self.mqtt_client.connect()
        self.mqtt_client.run()
    
    def turning_off_with_delay(self, led, device=None):
        time.sleep(5)
        led.turn_off_device()
        if(device is None): return
        device.turn_off_device()

    def run_sensor_tasks(self):
        """Run sensor reading loop in a separate thread"""
        while not self.stop_event.is_set():
            try:
                # Create a siepaDB instance
                siepa_data = SiepaDB(
                    temperature=self.dht_sensor.temperature,
                    humidity=self.dht_sensor.humidity,
                    pressure=self.bmp_sensor.pressure,
                    air_quality=self.mq_sensor.ppm,
                    luminosity=self.bh_sensor.luminosity,
                    proximity=self.ultrasonic_sensor.proximity
                )

                # Store data
                self.storage.append(siepa_data)

                # Publish to MQTT messages
                self.mqtt_client.publish('temperature', json.dumps({'temperature': siepa_data.temperature}))
                self.mqtt_client.publish('humidity', json.dumps({'humidity': siepa_data.humidity}))
                self.mqtt_client.publish('pressure', json.dumps({'pressure': siepa_data.pressure}))
                self.mqtt_client.publish('air_quality', json.dumps({'air_quality': siepa_data.air_quality}))
                self.mqtt_client.publish('luminosity', json.dumps({'luminosity': siepa_data.luminosity}))

                if not self.presence_helper and siepa_data.proximity > 0:
                    self.mqtt_client.publish('proximity', json.dumps({'proximity': siepa_data.proximity}))
                    self.presence_helper = True
                elif self.presence_helper and  siepa_data.proximity <= 0:
                    self.presence_helper = False

                # Check if we should stop
                if self.stop_event.is_set():
                    break

                # ACTUATORS: Perform some actions based on sensor data

                # Red LED (temperature >= 28)
                if siepa_data.temperature >= 28 and not self.red_led.mode and self.fan_device.control == 'automatic':
                    self.red_led.turn_on_device()
                    self.mqtt_client.publish('temperature/danger', json.dumps({
                        'message': 'High temperature detected! Turning on red LED.'
                    }))
                    # Turn on the fan devices
                    self.fan_device.turn_on_device()
                    self.show_priority_message("Alerta temp", 5)
                    self.temperature_helper = True
                    #print("The fans are on.")
                elif siepa_data.temperature < 28 and self.red_led.mode and self.fan_device.control == 'automatic':
                    self.temperature_helper = False
                    Thread(target=self.turning_off_with_delay, args=(self.red_led, self.fan_device)).start()
                    # Turning off the fans in 5 seconds...
                
                # Yellow LED (humidity >= 70)
                if siepa_data.humidity >= 70 and not self.yellow_led.mode and self.lighting_device.control == 'automatic':
                    self.humidity_helper = True
                    self.yellow_led.turn_on_device()

                    self.mqtt_client.publish('humidity/danger', json.dumps({
                        'message': 'High humidity detected! Turning on yellow LED.'
                    }))
                    self.show_priority_message("Alerta humedad", 5)
                elif siepa_data.humidity < 70 and self.yellow_led.mode and self.lighting_device.control == 'automatic':
                    # self.yellow_led.turn_off_device()
                    self.humidity_helper = False
                    Thread(target=self.turning_off_with_delay, args=(self.yellow_led, None)).start()
                
                # Green LED (luminosity <= 200)
                if siepa_data.luminosity <= 200 and not self.green_led.mode and self.lighting_device.control == 'automatic':
                    self.luminosity_helper = True
                    self.green_led.turn_on_device()
                    self.mqtt_client.publish('luminosity/danger', json.dumps({
                        'message': 'Low luminosity detected! Turning on green LED.'
                    }))
                    self.lighting_device.turn_on_device()
                    self.show_priority_message("Alerta luz", 5)
                elif siepa_data.luminosity > 200 and self.green_led.mode and self.lighting_device.control == 'automatic':
                    # self.green_led.turn_off_device()
                    self.luminosity_helper = False
                    Thread(target=self.turning_off_with_delay, args=(self.green_led, self.lighting_device)).start()
                
                # Blue LED (air quality >= 1000)
                if siepa_data.air_quality >= 700 and not self.blue_led.mode and self.blue_led.control == 'automatic':
                    self.air_quality_helper = True
                    self.blue_led.turn_on_device()
                    self.mqtt_client.publish('air_quality/danger', json.dumps({
                        'message': 'Low air_quality detected! Turning on blue LED.'
                    }))
                    self.buzzer_device.turn_on_device()
                    self.show_priority_message("Alerta aire", 5)
                elif siepa_data.air_quality < 700 and self.blue_led.mode and self.blue_led.control == 'automatic':
                    #self.blue_led.turn_off_device()
                    self.air_quality_helper = False
                    Thread(target=self.turning_off_with_delay, args=(self.blue_led, self.buzzer_device)).start()

                for alert in siepa_data.alert_messages():
                    self.safe_put(self.alert_queue, alert, 'last_alert_message')

                for line in siepa_data.to_display_lines():
                    self.safe_put(self.display_queue, line, 'last_display_message')

                time.sleep(2)

            except Exception as e:
                #print(f"Error in sensor tasks: {e}")
                time.sleep(1)  # Prevent tight loop on error

    # def run_display(self):
    #     previous_line = ""
    #     current_line = ""
        
    #     while not self.stop_event.is_set():
    #         try:
    #             if not self.alert_queue.empty():
    #                 new_line = self.alert_queue.get(timeout=1)
    #                 previous_line = current_line
    #                 current_line = new_line

    #                 self.display_lcd.clear()
    #                 self.display_lcd.write_centered(current_line, 1)
    #                 time.sleep(5)
    #                 continue
                
    #             new_line = self.display_queue.get(timeout=1)
    #             previous_line = current_line
    #             current_line = new_line

    #             self.display_lcd.clear()
    #             self.display_lcd.write_centered(previous_line, 1)
    #             self.display_lcd.write_centered(current_line, 2)
    #             time.sleep(2)

    #         except queue.Empty:
    #             continue
    def run_display(self):
        previous_line = ""
        current_line = ""

        while not self.stop_event.is_set():
            if self.pause_display_event.is_set():
                time.sleep(0.1)  # Esperar a que termine el mensaje prioritario
                continue
            try:
                if not self.alert_queue.empty():
                    new_line = self.alert_queue.get(timeout=1)
                    previous_line = current_line
                    current_line = new_line

                    self.display_lcd.clear()
                    self.display_lcd.write_centered(current_line, 1)
                    time.sleep(5)
                    continue

                new_line = self.display_queue.get(timeout=1)
                previous_line = current_line
                current_line = new_line

                self.display_lcd.clear()
                self.display_lcd.write_centered(previous_line, 1)
                self.display_lcd.write_centered(current_line, 2)
                time.sleep(2)

            except queue.Empty:
                continue

    def show_priority_message(self, msg: str, duration: int = 5):
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
            #print("Application is already running")
            return

        self.running = True
        self.stop_event.clear()

        # Start Flask server thread
        self.flask_thread = Thread(target=self.run_flask, daemon=True)
        self.flask_thread.start()

        # Start MQTT client thread
        self.mqtt_thread = Thread(target=self.run_mqtt, daemon=True)
        self.mqtt_thread.start()

        # Start sensor tasks thread
        self.sensor_thread = Thread(target=self.run_sensor_tasks, daemon=True)
        self.sensor_thread.start()

        # # Start display thread
        self.display_thread = Thread(target=self.run_display, daemon=True)
        self.display_thread.start()

        #print("All threads started")

    def stop(self):
        """Stop all threads gracefully"""
        if not self.running:
            #print("Application is not running")
            return

        self.running = False
        self.stop_event.set()

        # Stop Flask server
        if hasattr(self.server, 'stop'):
            self.server.stop()

        # Stop MQTT client
        if hasattr(self.mqtt_client, 'disconnect'):
            self.mqtt_client.disconnect()

        # Wait for threads to finish
        if self.sensor_thread and self.sensor_thread.is_alive():
            self.sensor_thread.join(timeout=5)
        
        if self.mqtt_thread and self.mqtt_thread.is_alive():
            self.mqtt_thread.join(timeout=5)
            
        if self.flask_thread and self.flask_thread.is_alive():
            self.flask_thread.join(timeout=5)

        if self.display_thread and self.display_thread.is_alive():
            self.display_thread.join(timeout=5)

        # Cleanup GPIO pins
        GPIO.cleanup()

        #print("All threads stopped")

    def safe_put(self, q, msg, last_msg_attr):
        last_msg = getattr(self, last_msg_attr, None)
        if msg != last_msg:
            q.put(msg)
            setattr(self, last_msg_attr, msg)
    
    def perform(self):
        """Main application entry point"""
        self.display_lcd.write_centered("Bienvenido a", 1)
        self.display_lcd.write_centered("SIEPA - Grupo 11", 2)
        #print("Starting SiepaG11App...")
        time.sleep(4)  # Wait for 2 seconds before starting
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