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

    def __init__(self, pin):
        self._pin = pin
        self._mode = False
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


# if __name__ == "__main__":
    # blue_led = GenericOutputDevice(26)
    # blue_led.turn_on_device()
    # print(f"blue_led is {'on' if blue_led.mode else 'off'}")
    # time.sleep(2)  # Keep blue_led on for 2 seconds
    # blue_led.turn_off_device()
    # print(f"blue_led is {'on' if blue_led.mode else 'off'}")
    # blue_led.cleanup()

    # yellow_led = GenericOutputDevice(16)
    # yellow_led.turn_on_device()
    # print(f"yellow_led is {'on' if yellow_led.mode else 'off'}")
    # time.sleep(2)  # Keep yellow_led on for 2 seconds
    # yellow_led.turn_off_device()
    # print(f"yellow_led is {'on' if yellow_led.mode else 'off'}")
    # yellow_led.cleanup()

    # red_led = GenericOutputDevice(6)
    # red_led.turn_on_device()
    # print(f"red_led is {'on' if red_led.mode else 'off'}")
    # time.sleep(2)  # Keep red_led on for 2 seconds
    # red_led.turn_off_device()
    # print(f"red_led is {'on' if red_led.mode else 'off'}")
    # red_led.cleanup()

    # green_led = GenericOutputDevice(5)
    # green_led.turn_on_device()
    # print(f"green_led is {'on' if green_led.mode else 'off'}")
    # time.sleep(2)  # Keep green_led on for 2 seconds
    # green_led.turn_off_device()
    # print(f"green_led is {'on' if green_led.mode else 'off'}")
    # green_led.cleanup()

    # buzzer = GenericOutputDevice(21)
    # buzzer.turn_on_device()
    # print(f"buzzer is {'on' if buzzer.mode else 'off'}")
    # time.sleep(2)  # Keep buzzer on for 2 seconds   
    # buzzer.turn_off_device()
    # print(f"buzzer is {'on' if buzzer.mode else 'off'}")
    # buzzer.cleanup()