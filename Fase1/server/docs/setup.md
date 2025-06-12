# Setup


## Backend (API)
```shell
    python3 -m venv env
    source ./env/bin/activate
    deactivate # deactivate env
    pip3 freeze > requirements.txt # Generate requirements.txt
    pip3 install -r requirements.txt # Install packages from the requirements.txt
```

```bash
    python3 ./main.py
```

## Mqtt Client Installation and Configuration on MacOS

```shell
    brew install mosquitto

    # mosquitto has been installed with a default configuration file.
    # You can make changes to the configuration by editing:
    #     /opt/homebrew/etc/mosquitto/mosquitto.conf
    # 
    # To start mosquitto now and restart at login:
    #   brew services start mosquitto
    # Or, if you don't want/need a background service you can just run:
    #   /opt/homebrew/opt/mosquitto/sbin/mosquitto -c /opt/homebrew/etc/mosquitto/mosquitto.conf
```

### Troubleshooting

```shell
   pip3 freeze > requirements.txt --break-system-packages
```

```shell
    ssh fichaje@123.local
    # password: fichaje
```

```bash
    sudo pigpiod
    python3 ./main.py
```

#### Credentials


```env
MODE=automatic
DHT_PIN=
BMP_PIN=
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=
```