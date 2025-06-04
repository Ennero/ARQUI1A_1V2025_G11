# import paho.mqtt.client as mqtt
# import random

# class SiepaMqtt:
#     broker = 'broker.emqx.io'
#     port = 1883
#     topic = "python/mqtt/Arqui1Grupo11"

#     def __init__(self):
#         self.client_id = f'python-mqtt-{random.randint(0, 1000)}'

#     def run(self):
#         def on_connect(client, userdata, flags, reason_code, properties):
#             print(f"Connected with result code {reason_code}")
#             # Subscribing in on_connect() means that if we lose the connection and
#             # reconnect then subscriptions will be renewed.
#             self.client.subscribe("$SYS/#")

#         # The callback for when a PUBLISH message is received from the server.
#         def on_message(client, userdata, msg):
#             print(msg.topic+" "+str(msg.payload))

#         mqttc = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
#         mqttc.on_connect = on_connect
#         mqttc.on_message = on_message


# subscriber.py
import paho.mqtt.client as mqtt

broker = "broker.emqx.io"
topic = "python/mqtt/Arqui1Grupo11"

def on_connect(client, userdata, flags, rc):
    print("Connected!")
    client.subscribe(topic)

def on_message(client, userdata, msg):
    print(f"Received: {msg.payload.decode()}°C")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(broker, 1883, 60)
client.loop_forever()  # Keeps listening