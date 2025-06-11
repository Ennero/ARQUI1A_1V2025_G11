
from rpi_lcd import LCD
import time

class DisplayLCD:
    def __init__(self):
        self.lcd = LCD()
        self.lcd.clear()
        self.lcd.backlight(True)

    def write_centered(self, message: str, line: int):
        message = message.strip()
        if len(message) > 16:
            message = message[:16]
        centered_message = message.center(16)
        self.lcd.text(centered_message, line)

    def clear(self):
        self.lcd.clear()