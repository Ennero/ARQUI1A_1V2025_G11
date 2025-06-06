from bmp import BMP
from dht import DHT
from pcf8591 import PCF8591
from mq135 import MQ135
from ultrasonic import Ultrasonic
import RPi.GPIO as GPIO
import board
import time

def main():
    adc = PCF8591()

    while True:
        digital_value = adc.read(channel=0)
        voltage = adc.read_voltage(channel=0, vref=5.0)
        print(f"Valor digital: {digital_value}")
        print(f"Voltaje: {voltage:.2f} V")
        time.sleep(2)

    # mq = MQ135(adc, channel=0, vref=5.0, load_resistance=10.0, r0=10.0)
    # mq.calibrate_r0(samples=20, delay=0.2)
    
    # while True:
    #     ppm = mq.get_ppm()
    #     print(f"CO2 (estimado): {ppm:.2f} ppm")
    #     time.sleep(2)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Programa interrumpido por el usuario.")
    finally:
        GPIO.cleanup()
        