import time
import random
from paho.mqtt import client as mqtt_client

class SiepaMqttClient(object):

    # Singleton pattern
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(SiepaMqttClient, cls).__new__(cls)
        return cls.instance


    def __init__(self):
        self._broker = "broker.emqx.io"
        self._port = 1883
        self._client_id = f'grupo11-mqtt-{int(time.time())}-{random.randint(0, 1000)}'
        self._client = None
        self._connected = False
        self._topic = "fiusac/arqui1/g11/#"
        # self._topic = "GRUPO11/sensores/rasp01/#"

        self._allowed_topics = [
            'temperature', 
            'humidity', 
            'pressure', 
            'air_quality',
            'proximity',
            'luminosity',
            'motion_detected'
        ]

    def connect(self):
        def on_connect(client, user_data, flags, rc):
            if rc == 0:
                print("Successfully connected to MQTT Broker!")
                self._connected = True
                # Subscribe to all topics with QoS 1
                result = client.subscribe(self._topic, qos=1)
                if result[0] == mqtt_client.MQTT_ERR_SUCCESS:
                    print(f"Successfully subscribed to topics: {self._topic}")
                else:
                    print(f"Subscribe failed with result code: {result}")
            else:
                print(f"Failed to connect, return code {rc}\n")

        def on_message(client, user_data, msg):
            print(f"\nReceived message on [{msg.topic}]")
            print(f"QoS: {msg.qos}")
            print(f"Retained: {msg.retain}")
            print(f"Payload: {msg.payload.decode()}")

        def on_subscribe(client, user_data, mid, granted_qos):
            print(f"Subscription acknowledged for MID: {mid}")
            print(f"Granted QoS levels: {granted_qos}")

        self._client = mqtt_client.Client(client_id=self._client_id)
        self._client.on_connect = on_connect
        self._client.on_message = on_message
        # self._client.on_subscribe = on_subscribe
        
        # Enable additional logging
        self._client.enable_logger()
        
        # Set last will and testament (optional)
        self._client.will_set("clients/disconnect", payload="Client disconnected abruptly", qos=1)
        
        try:
            self._client.connect(self._broker, self._port, keepalive=60)
        except Exception as e:
            print(f"Connection error: {str(e)}")


    def publish(self, topic: str, message: str, qos: int = 1):
        if not self._connected:
            print("MQTT client is not connected. Cannot publish.")
            return

        if topic not in self._allowed_topics:
            print(f"Topic '{topic}' is not allowed. Allowed topics are: {self._allowed_topics}")
            return

        full_topic = f"fiusac/arqui1/g11/{topic}"

        result = self._client.publish(full_topic, payload=message, qos=qos)

        if result.rc == mqtt_client.MQTT_ERR_SUCCESS:
            print(f"Published to {full_topic}: {message}")
        else:
            print(f"Failed to publish to {full_topic}. Error code: {result.rc}")

    def disconnect(self):
        if self._client:
            print("Disconnecting MQTT client...")
            self._client.disconnect()
            self._connected = False
        else:
            print("MQTT client is not initialized.")

    def run(self):
        if not self._client:
            print("Client not initialized!")
            return
        
        print("Starting MQTT loop...")
        try:
            self._client.loop_forever(retry_first_connection=True)
        except KeyboardInterrupt:
            print("Disconnecting...")
            self._client.disconnect()
            
