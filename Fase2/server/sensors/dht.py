import adafruit_dht
import board

class DHT:
    def __init__(self, pin: board.pin, model: str = "DHT11"):
        model = model.upper()

        if model == "DHT11":
            self._sensor = adafruit_dht.DHT11(pin)
        elif model == "DHT22":
            self._sensor = adafruit_dht.DHT22(pin)
        else:
            raise ValueError(f"Modelo de sensor no soportado: {model}")
        
    @property
    def temperature(self):
        try:
            temp = self._sensor.temperature
            return float(temp) if temp else None
        except Exception as e:
            print(f"[DHT] Error al leer temperatura: {e}")
            return None
        
    @property
    def humidity(self):
        try:
            hum = self._sensor.humidity
            return float(hum) if hum else None
        except Exception as e:
            print(f"[DHT] Error al leer humedad: {e}")
            return None