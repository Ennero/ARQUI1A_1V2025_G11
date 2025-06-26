import time
import random
import json
from models.device_manager import DeviceManager
from paho.mqtt import client as mqtt_client
from datetime import datetime
from config.mongodb import mongodb_connection
from ARM64.calculator import Calculator
from pymongo import DESCENDING

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
            'motion_detected',
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
            topic = msg.topic
            payload_str = msg.payload.decode()
            print(f"Received message on [{topic}]")
            print(f"Payload: {payload_str}")

            # Intentar parsear JSON
            try:
                payload = json.loads(payload_str)
            except json.JSONDecodeError:
                print("Invalid JSON format")
                return

            # Enrutar por tópico
            if topic == "fiusac/arqui1/g11/config":
                device_name = payload.get("device_name", "unknown")
                control = payload.get("control", "unknown")
                display_mode = payload.get("show_mode", None)

                # Topic: fiusac/arqui1/g11/config
                # For LEDs and Actuators, payload should be like:
                # {"device_name": "red_led", "control": "manual"}
                # For display, payload should be like:
                # {"device_name": "display", "show_mode": "readings"}

                if device_name == 'lighting':
                    DeviceManager().lighting_device.control = control
                    DeviceManager().lighting_device.turn_off_device()  
                elif device_name == 'fan':
                    DeviceManager().fan_device.control = control
                    DeviceManager().fan_device.turn_off_device()  
                elif device_name == 'buzzer':
                    DeviceManager().buzzer_device.control = control
                    DeviceManager().buzzer_device.turn_off_device()
                elif device_name == 'red_led':
                    DeviceManager().red_led.control = control
                    DeviceManager().red_led.turn_off_device()
                elif device_name == 'green_led':
                    DeviceManager().green_led.control = control
                    DeviceManager().green_led.turn_off_device()
                elif device_name == 'blue_led':
                    DeviceManager().blue_led.turn_off_device()
                elif device_name == 'yellow_led':
                    DeviceManager().yellow_led.control = control
                    DeviceManager().yellow_led.turn_off_device()
                elif device_name == 'display':
                    if display_mode is not None and display_mode in ['readings', 'statistics', 'predictions']:
                        DeviceManager().display_lcd.show = display_mode
                    else:
                        print("Invalid display mode provided.")

            elif topic == "fiusac/arqui1/g11/device_mode":
                device_name = payload.get("device_name", "unknown")
                status = bool(payload.get("status", "unknown"))

                # Topic: fiusac/arqui1/g11/device_mode
                # For Leds and actuators, payload should be like:
                # {"device_name": "red_led", "status": true}

                if device_name == 'lighting':
                    if status:
                        DeviceManager().lighting_device.turn_on_device()
                    else:
                        DeviceManager().lighting_device.turn_off_device()
                elif device_name == 'fan':
                    if status:
                        DeviceManager().fan_device.turn_on_device()
                    else:
                        DeviceManager().fan_device.turn_off_device()
                elif device_name == 'buzzer':
                    if status:
                        DeviceManager().buzzer_device.turn_on_device()
                    else:
                        DeviceManager().buzzer_device.turn_off_device()
                elif device_name == 'red_led':
                    if status:
                        DeviceManager().red_led.turn_on_device()
                    else:
                        DeviceManager().red_led.turn_off_device()
                elif device_name == 'green_led':
                    if status:
                        DeviceManager().green_led.turn_on_device()
                    else:
                        DeviceManager().green_led.turn_off_device()
                elif device_name == 'blue_led':
                    if status:
                        DeviceManager().blue_led.turn_on_device()
                    else:
                        DeviceManager().blue_led.turn_off_device()
                elif device_name == 'yellow_led':
                    if status:
                        DeviceManager().yellow_led.turn_on_device()
                    else:
                        DeviceManager().yellow_led.turn_off_device()
                else:
                    print(f"Invalid device name provided: {device_name}")

            elif topic == "fiusac/arqui1/g11/calculate":
                # Topic: fiusac/arqui1/g11/calculate
                # Payload should be like:
                # {"measurement": "temperature", calculate: "stats/predictions/all" }
                measurement = payload.get("measurement", "unknown")
                calculate = payload.get("calculate", "stats/predictions/all")

                # Validations
                if measurement not in self._allowed_topics:
                    print(f"Measurement '{measurement}' is not allowed. Allowed measurements are: {self._allowed_topics}")
                    return
                
                if calculate not in ['stats', 'predictions', 'all']:
                    print(f"Calculation type '{calculate}' is not recognized. Allowed types are: 'stats', 'predictions', 'all'")
                    return

                db = mongodb_connection.get_database('arqui1_siepa_g11_db')
                collection = db['sensor_readings']
                last_30_docs = list(collection.find(
                        { measurement: { "$exists": True, "$ne": None } },  # ensures value is not null
                        { '_id': 1, measurement: 1 }
                ).sort(
                    '_id', DESCENDING
                ).limit(30))

                print("--------------------------")
                print(last_30_docs)
                print("--------------------------")
            
                last_30_docs.reverse()

                # Through a list comprehension, we format the last 30 readings to only numbers
                # We truncate and ensure the're not None values
                arr_last_30_readings = [
                    int(doc[measurement]) for doc in last_30_docs
                    if measurement in doc and isinstance(doc[measurement], (int, float)) and doc[measurement] is not None
                ]
                
                # Perform algorithm
                if calculate == 'stats':
                    print("Calculating statistics...")
                    dict_result = Calculator().calculate_stats(arr_last_30_readings)
                    dict_result['timestamp'] = datetime.now()
                    dict_result['measurement'] = measurement
                    db['statistics'].insert_one(dict_result) # Now, we are ready to save the calculations in mongodb
                    print(f"Calculation result: {dict_result}")
                elif calculate == 'predictions':
                    print("Calculating predictions...")
                    dict_result = Calculator().calculate_predictions(arr_last_30_readings)
                    dict_result['timestamp'] = datetime.now()
                    dict_result['measurement'] = measurement
                    db['predictions'].insert_one(dict_result) # Now, we are ready to save the calculations in mongodb
                    print(f"Calculation result: {dict_result}")
                elif calculate == 'all':
                    print("Calculating both statistics and predictions...")
                    dict_stats_result = Calculator().calculate_stats(arr_last_30_readings)
                    dict_stats_result['timestamp'] = datetime.now()
                    dict_stats_result['measurement'] = measurement
                    dict_predictions_result = Calculator().calculate_predictions(arr_last_30_readings)
                    dict_predictions_result['timestamp'] = datetime.now()
                    dict_predictions_result['measurement'] = measurement
                    db['statistics'].insert_one(dict_stats_result) # Now, we are ready to save the calculations in mongodb
                    db['predictions'].insert_one(dict_predictions_result) # Now, we are ready to save the calculations in mongodb
                    
                    # Combine to have a single result
                    dict_result = {
                        "statistics": dict_stats_result,
                        "predictions": dict_predictions_result,
                    }

                    print(f"Calculation result: {dict_result}")
                
                # After the calculation, we show the result in the display, if it is configured to show predictions or statistics
                if DeviceManager().display_lcd.show in ['predictions', 'statistics']:
                    DeviceManager().new_message_helper = True

                # Respond to the MQTT topic with the result
                mqtt_client.publish("fiusac/arqui1/g11/calculate/result", json.dumps(dict_result))


            else:
                print("No handler for this topic.")

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
            
