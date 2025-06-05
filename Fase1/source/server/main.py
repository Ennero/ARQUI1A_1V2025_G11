import time
from threading import Thread
from config.server import FlaskServer
from mqtt.client import SiepaMqttClient

def run_flask():
    server = FlaskServer()
    server.run()

def run_mqtt():
    mqtt_client = SiepaMqttClient()
    mqtt_client.connect()
    mqtt_client.run()

def sensors_monitoring():
    pass

if __name__ == "__main__":
    # Create and start threads
    # Set threads as daemon so they exit when main program exits
    flask_thread = Thread(target=run_flask, daemon=True)
    mqtt_thread = Thread(target=run_mqtt, daemon=True)
    sensors_thread = Thread(target=sensors_monitoring, daemon=True)
    
    # Start threads
    flask_thread.start()
    mqtt_thread.start()
    sensors_thread.start()
    
    # Keep main thread alive
    try:
        while True:
            # Interval (for waiting?) must come from env variables
            # time.sleep(self.intervals["principal"]) 
            pass
    except KeyboardInterrupt:
        # Handle program interruption (Ctrl+C)
        print("Shutting down...")
