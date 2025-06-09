from rpi_lcd import LCD
import time

class DisplayLCD:
    def __init__(self):
        self.lcd = LCD(0x27, 1, 16, 2, True)
        self.lcd.clear()
        self.lcd.backlight(self.enable)

    def show_message(self, message: str, line: int):
        self.lcd.clear()
        self.lcd.text(message, line)