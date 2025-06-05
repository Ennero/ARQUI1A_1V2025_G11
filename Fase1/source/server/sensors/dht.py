import adafruit_dht
import board

class DHT:
    def __init__(self, pin: board.pin, model: str = "DHT11"):
        self._temperature = None
        self._humidity = None

        model = model.upper()

        if model == "DHT11":
            self._sensor = adafruit_dht.DHT11(pin)
        elif model == "DHT22":
            self._sensor = adafruit_dht.DHT22(pin)
        else:
            raise ValueError(f"Modelo de sensor no soportado: {model}")
        
    @property
    def sensor(self):
        return self._sensor
    
    @sensor.setter
    def sensor(self, value):
        if isinstance(value, (adafruit_dht.DHT11, adafruit_dht.DHT22)):
            self._sensor = value
        else:
            raise TypeError("El sensor debe ser una instancia de DHT11 o DHT22")
        
    @property
    def temperature(self):
        temp = self.sensor.temperature
        return float(temp) if temp else None
    
    @temperature.setter
    def temperature(self, value):
        if isinstance(value, (int, float)):
            self._temperature = value
        else:
            raise TypeError("La temperatura debe ser un número")
        
    @property
    def humidity(self):
        hum = self.sensor.humidity
        return float(hum) if hum else None
    
    @humidity.setter
    def humidity(self, value):
        if isinstance(value, (int, float)):
            self._humidity = value
        else:
            raise TypeError("La humedad debe ser un número")
    
    def __str__(self):
        return f"Temperatura: {self.temperature:.1f} °C\nHumedad: {self.humidity:.1f} %"

    # def read(self):
    #     try:
    #         temp = self._sensor.temperature
    #         hum = self._sensor.humidity
    #         if temp is not None:
    #             self._temperature = float(temp)
    #             self._temperature_f = self._temperature * (9 / 5) + 32
    #         if hum is not None:
    #             self._humidity = float(hum)
    #     except Exception as e:
    #         print(f"[DHT] Error al leer el sensor: {e}")

    # def print_data(self):
    #     if self._temperature is not None:
    #         print(f"Temperatura en Celsius: {self._temperature:.1f} °C")
    #         print(f"Temperatura en Fahrenheit: {self._temperature_f:.1f} °F")
    #     else:
    #         print("Temperatura en Celsius: no disponible")
    #         print("Temperatura en Fahrenheit: no disponible")

    #     if self._humidity is not None:
    #         print(f"Humedad: {self._humidity:.1f} %")
    #     else:
    #         print("Humedad: no disponible")