from bmp280 import BMP280
from dht import DHT
from pcf8591 import PCF8591
from mq135 import MQ135
from bh1750 import BH1750
from ultrasonic import Ultrasonic
import RPi.GPIO as GPIO
import board
import time

def main():
    # adc = PCF8591()

    # digital_value = adc.read(channel=0)
    # voltage = adc.read_voltage(channel=0, vref=5.0)
    # print(f"Valor digital: {digital_value}")
    # print(f"Voltaje: {voltage:.2f} V")

    # mq = MQ135(adc, channel=0, vref=5.0, load_resistance=10.0, r0=10.0)
    # mq.calibrate_r0(samples=20, delay=0.2)
    
    # while True:
    #     ppm = mq.get_ppm()
    #     print(f"CO2 (estimado): {ppm:.2f} ppm")
    #     time.sleep(2)

    # ultra_sonic = Ultrasonic(trigger_pin=23, echo_pin=24, detection_range_cm=50.0)

    # while True:
    #     if ultra_sonic.motion_detected:
    #         print("✅ Objeto detectado dentro del rango")
    #     else:
    #         print("⛔ Nada detectado en el rango")
    #     time.sleep(1)

    # light_sensor = BH1750()
    # while True:
    #     print(f"Luminosidad: {light_sensor.luminosity:.2f} lux")
    #     time.sleep(1)

    # bmp_sensor = BMP280()
    # while True:
    #     print(f"Temp: {bmp_sensor.temperature:.1f}°C")
    #     print(f"Presión: {bmp_sensor.pressure:.1f}hPa")
    #     time.sleep(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Programa interrumpido por el usuario.")
    finally:
        GPIO.cleanup()
        