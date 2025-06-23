from rpi_lcd import LCD

class DisplayLCD:
    def __init__(self):
        # self.lcd = LCD()
        # self.lcd.clear()
        # self.lcd.backlight(True)
        self.lcd = LCD(address=0x27)  # Common address for I2C LCDs
        self.lcd.clear()
        self.lcd.backlight(True)
        self._show = 'readings'

    def write_centered(self, message: str, line: int):
        message = message.strip()
        if len(message) > 16:
            message = message[:16]
        centered_message = message.center(16)
        self.lcd.text(centered_message, line)

    def clear(self):
        self.lcd.clear()

    @property
    def show(self):
        return self._show
    @show.setter
    def show(self, value):
        if value in ['readings', 'statistics', 'predictions']:
            self._show = value
        else:
            raise ValueError("Invalid display mode. Use 'readings', 'statistics' or 'predictions.")
