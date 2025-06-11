from utils.display import DisplayLCD
from threading import Thread, Event
import queue
import time

class TestDisplay:
    def __init__(self):
        self.display_lcd = DisplayLCD()
        self.display_queue = queue.Queue()
        self.stop_event = Event()
        self.display_thread = Thread(target=self.run_display, daemon=True)

    def run_display(self):
        previous_line = ""
        current_line = ""
        while not self.stop_event.is_set():
            try:
                new_line = self.display_queue.get(timeout=1)
                previous_line = current_line
                current_line = new_line
                self.display_lcd.clear()
                self.display_lcd.write_centered(previous_line, 1)
                self.display_lcd.write_centered(current_line, 2)
                time.sleep(2)
            except queue.Empty:
                continue

    def start(self):
        self.display_thread.start()
        messages = [
            "Sensor iniciado",
            "Temp: 25°C",
            "Humedad: 60%",
            "Calidad aire OK",
            "Proximidad: 12cm"
        ]
        for msg in messages:
            self.display_queue.put(msg)

    def stop(self):
        self.stop_event.set()
        self.display_thread.join()
        self.display_lcd.clear()

if __name__ == "__main__":
    tester = TestDisplay()
    try:
        tester.start()
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Detenido.")
    finally:
        tester.stop()