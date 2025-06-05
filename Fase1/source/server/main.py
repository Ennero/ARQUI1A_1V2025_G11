import time
from threading import Thread
from config.server import FlaskServer
from mqtt.client import SiepaMqttClient

from sensors.bmp import BMP
from sensors.dht import DHT
from sensors.ultrasonic import Ultrasonic
import RPi.GPIO as GPIO
import board

dht_sensor = None
mqtt_client = None

def run_flask():
    server = FlaskServer()
    server.run()

def run_mqtt():
    mqtt_client = SiepaMqttClient()
    mqtt_client.connect()
    mqtt_client.run()

# def sensors_monitoring():
#     # pass
#     dht_sensor = DHT(board.D17, "DHT11")
#     dht_sensor.read()
#     dht_sensor.print_data()

def run_sensor_tarsks():
    pass

if __name__ == "__main__":
    # Create and start threads
    # Set threads as daemon so they exit when main program exits
    flask_thread = Thread(target=run_flask, daemon=True)
    mqtt_thread = Thread(target=run_mqtt, daemon=True)
    sensors_thread = Thread(target=run_sensor_tarsks, daemon=True)
    
    # Start threads
    flask_thread.start()
    mqtt_thread.start()
    sensors_thread.start()
    

    dht_sensor = DHT(board.D17, "DHT11")

    # Keep main thread alive
    try:
        while True:
            # Interval (for waiting?) must come from env variables
            # time.sleep(self.intervals["principal"]) 
            dht_sensor.read()
            dht_sensor.print_data()
            mqtt_client.publish('temperature', f"{dht_sensor.temperature_c}-jaja")
            time.sleep(1)

    except KeyboardInterrupt:
        # Handle program interruption (Ctrl+C)
        print("Shutting down...")
