import board
import adafruit_bmp280
from time import sleep

i2c = board.I2C()
sensor = adafruit_bmp280.Adafruit_BMP280_I2C(i2c, address=0x76)

while True:
    sleep(1)
    print(f"Temp: {sensor.temperature:.1f}°C")
    print(f"Presión: {sensor.pressure:.1f}hPa")