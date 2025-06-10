from rpi_lcd import LCD
import time

class Display_LCD:
    def __init__(self):
        self.lcd = LCD(0x27, 1, 16, 2, True)
        self.lcd.clear()
        self.lcd.backlight(True)

    def display_centered(self, message: str, line: int):
        message = message.strip()
        if len(message) > 16:
            message = message[:16]
        padding = (16 - len(message)) // 2
        centered_message = " " * padding + message
        self.lcd.text(centered_message, line)

    def scroll_data(self, seipa: 'SeipaDB', delay=2):
        lines = [
            f"--- Nueva lectura ---",
            f"Hora: {seipa.timestamp.strftime('%H:%M:%S')}",
            f"Temp: {seipa.temperature:.1f} °C",
            f"Humedad: {seipa.humidity:.1f} %",
            f"Presión: {seipa.pressure:.1f} hPa",
            f"CO2: {seipa.air_quality:.1f} ppm",
            f"Lux: {seipa.iluminity:.1f} lux"
        ]

        for i in range(len(lines) - 1):
            self.lcd.clear()
            self.display_centered(lines[i], 1)
            self.display_centered(lines[i + 1], 2)
            time.sleep(delay)