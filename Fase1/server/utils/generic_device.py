import RPi.GPIO as GPIO

# Set GPIO mode once in the main program
GPIO.setmode(GPIO.BCM)
import time

class GenericOutputDevice:
    """
    Generic class to control output devices like LEDs using Raspberry Pi GPIO.

    Attributes:
        pin (int): GPIO pin used.
        mode (bool): Device state. True = ON, False = OFF.
    """

    def __init__(self, pin, control="automatic"):
        self._pin = pin
        self._mode = False
        self._control = control
        GPIO.setup(self._pin, GPIO.OUT)

    def turn_on_device(self):
        GPIO.output(self._pin, GPIO.HIGH)
        self._mode = True
        print("The device is on")

    def turn_off_device(self):
        GPIO.output(self._pin, GPIO.LOW)
        self._mode = False
        print("The device is off")

    def toggle_device(self):
        if self._mode:
            self.turn_off_device()
        else:
            self.turn_on_device()

    def cleanup(self):
        GPIO.cleanup(self._pin)

    @property
    def mode(self):
        return self._mode

    @property
    def pin(self):
        return self._pin
    
    @property
    def control(self):
        return self._control

    @control.setter
    def control(self, value):
        if value in ["automatic", "manual"]:
            self._control = value
        else:
            print('Control must be "automatic" or "manual"')
