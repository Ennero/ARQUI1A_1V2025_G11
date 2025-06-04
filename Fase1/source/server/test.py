import time
import random

from paho.mqtt import client as mqtt_client

broker = 'broker.emqx.io'
port = 1883
topic = "python/mqtt/Arqui1Grupo11"

# Generate a unique client ID
client_id = f'python-mqtt-{random.randint(0, 1000)}'
# username = 'emqx'
# password = 'public'

def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print(f"Failed to connect, return code {rc}\n")
    def on_message(client, userdata, msg):
        print(f"Received: {msg.payload.decode()}°C")
    
    client = mqtt_client.Client(client_id=client_id)
    # client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(broker, port)
    return client

def run():
    client = connect_mqtt()
    # client.loop_start()  # Start the loop to process network traffic and callbacks
    client.loop_forever()
    # publish(client)
    # client.loop_stop()  # Stop the loop when done

if __name__ == '__main__':
    run()
    print("Finished publishing messages.")