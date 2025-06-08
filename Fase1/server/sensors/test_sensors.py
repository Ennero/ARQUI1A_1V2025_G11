from bmp import BMP
from dht import DHT
from ultrasonic import Ultrasonic
import RPi.GPIO as GPIO
import board
import time

def main():
    dht_sensor = DHT(board.D17, "DHT11")
    dht_sensor.read()
    dht_sensor.print_data()

    bmp_sensor = BMP(0x76)
    bmp_sensor.read()
    bmp_sensor.print_data()

    ultrasonic_sensor = Ultrasonic(23, 24, 50.0)
    while True:
        sensor.read()
        sensor.print_data()
        time.sleep(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Programa interrumpido por el usuario.")
    finally:
        GPIO.cleanup()
        