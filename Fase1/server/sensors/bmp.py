import adafruit_bmp280
import board

class BMP:
    def __init__(self, address: int = 0x76):
        self._sensor = adafruit_bmp280.Adafruit_BMP280_I2C(board.I2C(), address=address)

    @property
    def temperature(self):
        try:
            temp = self._sensor.temperature
            return float(temp) if temp else None
        except Exception as e:
            print(f"[BMP] Error al leer temperatura: {e}")
            return None
    
    @property
    def pressure(self):
        try:
            pres = self._sensor.pressure
            return float(pres) if pres else None
        except Exception as e:
            print(f"[BMP] Error al leer presión: {e}")
            return None