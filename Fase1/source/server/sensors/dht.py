import adafruit_dht
import board

class DHT:
    def __init__(self, pin: board.pin, model: str = "DHT11"):
        self.temperature_c = None
        self.temperature_f = None
        self.humidity = None

        model = model.upper()

        if model == "DHT11":
            self.sensor = adafruit_dht.DHT11(pin)
        elif model == "DHT22":
            self.sensor = adafruit_dht.DHT22(pin)
        else:
            raise ValueError(f"Modelo de sensor no soportado: {model}")
        
    def read(self):
        try:
            temp = self.sensor.temperature
            hum = self.sensor.humidity
            if temp is not None:
                self.temperature_c = float(temp)
                self.temperature_f = self.temperature_c * (9 / 5) + 32
            if hum is not None:
                self.humidity = float(hum)
        except Exception as e:
            print(f"[DHT] Error al leer el sensor: {e}")

    def print_data(self):
        if self.temperature_c is not None:
            print(f"Temperatura en Celsius: {self.temperature_c:.1f} °C")
            print(f"Temperatura en Fahrenheit: {self.temperature_f:.1f} °F")
        else:
            print("Temperatura en Celsius: no disponible")
            print("Temperatura en Fahrenheit: no disponible")

        if self.humidity is not None:
            print(f"Humedad: {self.humidity:.1f} %")
        else:
            print("Humedad: no disponible")