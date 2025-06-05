import adafruit_bmp280
import board

class BMP:
    def __init__(self, address: int = 0x76):
        self._sensor = adafruit_bmp280.Adafruit_BMP280_I2C(board.I2C(), address=address)
        self._temperature = 0
        self._pressure = 0

    @property
    def sensor(self):
        return self._sensor
    
    @sensor.setter
    def sensor(self, value):
        if isinstance(value, adafruit_bmp280.Adafruit_BMP280_I2C):
            self._sensor = value
        else:
            raise TypeError("El sensor debe ser una instancia de Adafruit_BMP280_I2C")
        
    @property
    def temperature(self):
        temp = self.sensor.temperature
        return float(temp.temperature) if temp else None
    
    @temperature.setter
    def temperature(self, value):
        if isinstance(value, (int, float)):
            self._temperature = value
        else:
            raise TypeError("La temperatura debe ser un número")
    
    @property
    def pressure(self):
        pres = self.sensor.pressure
        return float(pres.pressure) if pres else None
    
    @pressure.setter
    def pressure(self, value):
        if isinstance(value, (int, float)):
            self._pressure = value
        else:
            raise TypeError("La presión debe ser un número")
        
    def __str__(self):
        return f"Temperatura: {self.temperature:.1f} °C\nPresión: {self.pressure:.1f} hPa"

    # def read(self):
    #     try:
    #         temp = self._sensor.temperature
    #         pres = self._sensor.pressure
    #         if temp is not None:
    #             self._temperature = float(temp)
    #         if pres is not None:
    #             self._pressure = float(pres)
    #     except Exception as e:
    #         print(f"[BMP280] Error al leer el sensor: {e}")

    # def print_data(self):
    #     if self._temperature is not None:
    #         print(f"Temperatura: {self._temperature:.1f} °C")
    #     else:
    #         print("Temperatura: no disponible")

    #     if self._pressure is not None:
    #         print(f"Presión: {self._pressure:.1f} hPa")
    #     else:
    #         print("Presión: no disponible")