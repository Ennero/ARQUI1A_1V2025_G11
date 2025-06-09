import time
import json
from threading import Thread
from config.server import FlaskServer
from config.db import SiepaDB
from mqtt.client import SiepaMqttClient

from sensors.bmp import BMP
from sensors.dht import DHT
from sensors.mq135 import MQ135
from sensors.ultrasonic import Ultrasonic
from sensors.pcf8591 import PCF8591
import RPi.GPIO as GPIO
import board

dht_sensor = None
mqtt_client = None
storage = []

def run_flask():
    server = FlaskServer()
    server.run()

def run_mqtt():
    global mqtt_client
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
    # sensors_thread = Thread(target=run_sensor_tarsks, daemon=True)
    
    # Start threads
    flask_thread.start()
    mqtt_thread.start()
    # sensors_thread.start()
    

    # dht_sensor = DHT(board.D17, "DHT11")

    adc = PCF8591()
    mq = MQ135(adc, channel=0, vref=5.0, load_resistance=10.0, r0=10.0)
    
    mq.calibrate_r0(samples=100, delay=0.5)

    # Keep main thread alive

    try:
        while True:
            siepa_DB = SiepaDB(
                temperature=0,
                humidity=0,
                pressure=0,
                air_quality = mq.ppm
            )
            
            # mqtt_client.publisher('temperature', json.dumps({
            #     "temperature": siepa_DB.temperature
            # }))

            # mqtt_client.publisher('humidity', json.dumps({
            #     "humidity": siepa_DB.humidity
            # }))

            # mqtt_client.publisher('pressure', json.dumps({
            #     "pressure": siepa_DB.pressure
            # }))

            mqtt_client.publisher('air_quality', json.dumps({
                "air_quality": siepa_DB.air_quality
            }))

            print(siepa_DB)

            storage.append(siepa_DB)

            time.sleep(3)

    except KeyboardInterrupt:
        # Handle program interruption (Ctrl+C)
        print("Shutting down...")


# from app import SiepaG11App


# if __name__ == "__main__":
#     app = SiepaG11App()
#     app.perform()