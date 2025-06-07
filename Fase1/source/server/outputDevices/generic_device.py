import RPi.GPIO as GPIO
import time

# Atributes:
# 1. pin -> stablish the pin of the LED in the raspberry
# 2. mode -> determines if a led is on or off (true = on, false = off)

class GenericOutputDevice:
  
  def __init__(self, noPin):
    self._pin = noPin
    self._mode = False
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(self.pin, GPIO.OUT)
    
  def turn_on_device(self):
    GPIO.output(self.pin, GPIO.HIGH)
    self.mode = True
    print("The device is on")
  
  def turn_off_device(self):
    GPIO.output(self.pin, GPIO.LOW)
    self.mode = False
    print("The device is off")
  
  #Getter of mode
  @property
  def mode(self):
    return self._mode
  
  #Getter or pin
  @property
  def pin(self):
    return self._pin