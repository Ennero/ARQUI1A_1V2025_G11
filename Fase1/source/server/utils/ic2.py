from rpi_lcd import LCD
from time import sleep

lcd = LCD()

lcd.text('Hello World!', 1)
lcd.text('jajaja', 2)

sleep(5)
lcd.clear()