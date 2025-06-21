# utils/device_manager.py

from utils.generic_device import GenericOutputDevice
from utils.display import DisplayLCD

class DeviceManager:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DeviceManager, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        # LEDs
        self.red_led = GenericOutputDevice(16)
        self.green_led = GenericOutputDevice(19)
        self.yellow_led = GenericOutputDevice(20)
        self.blue_led = GenericOutputDevice(21)

        # Actuadores
        self.buzzer_device = GenericOutputDevice(26)
        self.fan_device = GenericOutputDevice(1)
        self.lighting_device = GenericOutputDevice(13)

        # Display
        self.display_lcd = DisplayLCD()
