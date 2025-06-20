# Setup


### Init virtual env
```shell
    python3 -m venv env
    source ./env/bin/activate
    deactivate # deactivate env
    pip3 freeze > requirements.txt # Generate requirements.txt
    pip3 install -r requirements.txt # Install packages from the requirements.txt
```

### Run the app manually
```bash
    python3 ./main.py
```

### Troubleshooting

```shell
    pip3 install -r requirements.txt --break-system-packages # Install packages from the requirements.txt
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

### Credentials

#### Connect to MongoDB Atlas

In order to get access to your cluster, your `.env` file must have the following structure:
```env
MONGODB_URI=mongodb+srv://<username>:<password>@arqui1g11siepacluster.r2uoqj2.mongodb.net/?retryWrites=true&w=majority&appName=Arqui1G11SiepaCluster
```


### Siepa Deamon On Raspberry PI

The service file is located at

```
/etc/systemd/system/siepa.service
```

#### Check Siepa services status

```bash
    sudo systemctl status siepa.service
```

#### Stop the service

```bash
    sudo systemctl stop siepa.service
```

#### Enable/Disable the service

```bash
    sudo systemctl disable siepa.service
    sudo systemctl enable siepa.service
```

#### Start the service

```bash
    sudo systemctl start siepa.service
```

#### Restart the service

```bash
    sudo systemctl restart siepa.service
```

#### Track logs on live

```bash
    journalctl -u siepa.service -f
```

### Turn the Raspberry PI off

```bash
    sudo shutdown now
```