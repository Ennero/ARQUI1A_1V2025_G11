from sensors.dht import DHT
from sensors.mq135 import MQ135
from sensors.pcf8591 import PCF8591
from sensors.bmp import BMP
from sensors.ultrasonic import Ultrasonic
from config.db import SiepaDB
from config.server import FlaskServer
from mqtt.client import SiepaMqttClient
from utils.generic_device import GenericOutputDevice
from utils.display import DisplayLCD
from Fase1.server.models.app_settings_model import AppSettings
from threading import Thread, Event
import board
import RPi.GPIO as GPIO
import time
import json
# from dotenv import load_dotenv
# import os


class SiepaG11App(object):

    # Singleton pattern
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(SiepaG11App, cls).__new__(cls)
        return cls.instance

    def __init__(self):
        # Load environment variables
        # load_dotenv()

        self.running = False
        self.stop_event = Event()  # For graceful thread termination

        # Define sensors
        self.dht_sensor = DHT(board.D17, "DHT11")
        self.bmp_sensor = BMP(board.D4)
        self.mq_sensor = MQ135(PCF8591(), channel=0, vref=5.0, load_resistance=10.0, r0=10.0)
        self.ultrasonic_sensor = Ultrasonic(trigger_pin=board.D18, echo_pin=board.D27)

        # Define output devices
        self.display_lcd = DisplayLCD()
        self.red_led = GenericOutputDevice(22)
        self.green_led = GenericOutputDevice(23)
        self.yellow_led = GenericOutputDevice(25)
        self.blue_led = GenericOutputDevice(26)
        
        # Actuators
        self.fan = GenericOutputDevice(19)
        self.buzzer = GenericOutputDevice(24)
        self.lighting_device = GenericOutputDevice(21)

        # Define storage
        self.storage = [] # We will implement MongoDB later
        
        # Define Flask server and MQTT client
        self.server = FlaskServer()
        self.mqtt_client = SiepaMqttClient()

        # Threads
        self.flask_thread = None
        self.mqtt_thread = None
        self.sensor_thread = None

        # App settings
        self.config = AppSettings(
            app_name="SiepaG11App",
            version="1.0.0",
            debug=True,
            mode="automatic"  # Default mode
        )

    def run_flask(self):
        """Run Flask server in a separate thread"""
        self.server.run()

    def run_mqtt(self):
        """Run MQTT client in a separate thread"""
        self.mqtt_client.connect()
        self.mqtt_client.run()

    def run_sensor_tasks(self):
        """Run sensor reading loop in a separate thread"""
        while not self.stop_event.is_set():
            try:
                # Read sensors
                dht_data = self.dht_sensor.read()
                bmp_data = self.bmp_sensor.read()
                mq_data = self.mq_sensor.read()
                ultrasonic_data = self.ultrasonic_sensor.read()

                # Create a siepaDB instance
                siepa_data = SiepaDB(
                    temperature=dht_data['temperature'],
                    humidity=dht_data['humidity'],
                    pressure=bmp_data['pressure'],
                    air_quality=mq_data['air_quality'],
                    iluminity=None
                )

                # Store data
                self.storage.append(siepa_data)

                # Publish to MQTT messages
                self.mqtt_client.publish('temperature', json.dumps({'temperature': siepa_data.temperature}))
                self.mqtt_client.publish('humidity', json.dumps({'humidity': siepa_data.humidity}))
                self.mqtt_client.publish('pressure', json.dumps({'pressure': siepa_data.pressure}))
                self.mqtt_client.publish('air_quality', json.dumps({'air_quality': siepa_data.air_quality}))
                self.mqtt_client.publish('proximity', json.dumps({'distance': ultrasonic_data['distance']}))
                self.mqtt_client.publish('iluminity', json.dumps({'iluminity': mq_data['iluminity']}))

                # Check if we should stop
                if self.stop_event.is_set():
                    break

                # ACTUATORS: Perform some actions based on sensor data

                # Red LED (temperature >= 28)
                if siepa_data.temperature >= 28 and not self.red_led.mode:
                    self.red_led.turn_on_device()
                    self.mqtt_client.publish('humidity/temperature', json.dumps({
                        'message': 'High temperature detected! Turning on red LED.'
                    }))
                elif siepa_data.temperature < 28 and self.red_led.mode:
                    self.red_led.turn_off_device()
                
                # Yellow LED (humidity >= 70)
                if siepa_data.humidity >= 70 and not self.yellow_led.mode:
                    self.yellow_led.turn_on_device()

                    self.mqtt_client.publish('humidity/danger', json.dumps({
                        'message': 'High humidity detected! Turning on yellow LED.'
                    }))

                elif siepa_data.humidity < 70 and self.yellow_led.mode:
                    self.yellow_led.turn_off_device()
                
                # Green LED (pressure <= 1000)
                if siepa_data.iluminity <= 1000 and not self.green_led.mode:
                    self.green_led.turn_on_device()
                    self.mqtt_client.publish('iluminity/danger', json.dumps({
                        'message': 'Low iluminity detected! Turning on green LED.'
                    }))
                elif siepa_data.iluminity > 1000 and self.green_led.mode:
                    self.green_led.turn_off_device()
                
                # Blue LED (air quality <= 100)
                if siepa_data.air_quality <= 100 and not self.blue_led.mode:
                    self.blue_led.turn_on_device()
                    self.mqtt_client.publish('air_quality/danger', json.dumps({
                        'message': 'Low air_quality detected! Turning on blue LED.'
                    }))
                elif siepa_data.air_quality > 100 and self.blue_led.mode:
                    self.blue_led.turn_off_device()

                if self.config.mode == "automatic":
                    # Fan (temperature >= 28)
                    if siepa_data.temperature >= 28 and not self.fan.mode:
                        self.fan.turn_on_device()
                    elif siepa_data.temperature < 28 and self.fan.mode:
                        self.fan.turn_off_device()
                    # Buzzer (air quality <= 50)
                    if siepa_data.air_quality <= 50 and not self.buzzer.mode:
                        self.buzzer.turn_on_device()
                    elif siepa_data.air_quality > 50 and self.buzzer.mode:
                        self.buzzer.turn_off_device()
                    # Lighting device (iluminity <= 200)
                    if siepa_data.iluminity <= 200 and not self.lighting_device.mode:
                        self.lighting_device.turn_on_device()
                    elif siepa_data.iluminity > 200 and self.lighting_device.mode:
                        self.lighting_device.turn_off_device()

                # Sleep for a while before the next reading
                time.sleep(5)

            except Exception as e:
                print(f"Error in sensor tasks: {e}")
                time.sleep(1)  # Prevent tight loop on error

    def start(self):
        """Start all threads"""
        if self.running:
            print("Application is already running")
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

        print("All threads started")

    def stop(self):
        """Stop all threads gracefully"""
        if not self.running:
            print("Application is not running")
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

        print("All threads stopped")

    def perform(self):
        """Main application entry point"""
        try:
            self.start()
            
            # Main thread can do other work here or just wait
            while self.running:
                time.sleep(1)
                
        except KeyboardInterrupt:
            print("\nReceived keyboard interrupt, stopping...")
        finally:
            self.stop()

    def __del__(self):
        """Destructor to ensure clean shutdown"""
        self.stop()