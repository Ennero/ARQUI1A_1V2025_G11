import adafruit_bmp280
import board

class BMP:
    def __init__(self, address: int = 0x76):
        i2c = board.I2C()
        self.sensor = adafruit_bmp280.Adafruit_BMP280_I2C(i2c, address=address)
        self.temperature = None
        self.pressure = None

    def read(self):
        try:
            temp = self.sensor.temperature
            pres = self.sensor.pressure
            if temp is not None:
                self.temperature = float(temp)
            if pres is not None:
                self.pressure = float(pres)
        except Exception as e:
            print(f"[BMP280] Error al leer el sensor: {e}")

    def print_data(self):
        if self.temperature is not None:
            print(f"Temperatura: {self.temperature:.1f} °C")
        else:
            print("Temperatura: no disponible")

        if self.pressure is not None:
            print(f"Presión: {self.pressure:.1f} hPa")
        else:
            print("Presión: no disponible")
