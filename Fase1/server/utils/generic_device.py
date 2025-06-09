import RPi.GPIO as GPIO
import time

class GenericOutputDevice:
    """
    Generic class to control output devices like LEDs using Raspberry Pi GPIO.

    Attributes:
        pin (int): GPIO pin used.
        mode (bool): Device state. True = ON, False = OFF.
    """
  
    def __init__(self, noPin):
        self._pin = noPin
        self._mode = False
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self._pin, GPIO.OUT)
    
    def turn_on_device(self):
        GPIO.output(self._pin, GPIO.HIGH)
        self._mode = True
        print("The device is on")
  
    def turn_off_device(self):
        GPIO.output(self._pin, GPIO.LOW)
        self._mode = False
        print("The device is off")
    
    def cleanup(self):
        GPIO.cleanup()
  
    @property
    def mode(self):
        return self._mode
  
    @property
    def pin(self):
        return self._pin
