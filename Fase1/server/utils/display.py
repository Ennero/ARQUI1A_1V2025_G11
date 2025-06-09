# from rpi_lcd import LCD
# import time

# class DisplayLCD:
#     def __init__(self):
#         self.lcd = LCD(0x27, 1, 16, 2, True)
#         self.lcd.clear()
#         self.lcd.backlight(self.enable)

#     def show_message(self, message: str, line: int):
#         self.lcd.clear()
#         self.lcd.text(message, line)

from rpi_lcd import LCD
import time
import threading

class DisplayLCD:
    def __init__(self):
        self.lcd = LCD()
        self.lcd.clear()
        self.messages = []  # Lista compartida de mensajes
        self.lock = threading.Lock()
        self.running = True

        # Iniciar el hilo que rota mensajes
        self.thread = threading.Thread(target=self._rotate_messages)
        self.thread.start()

    def show_message(self, message: str, line: int):
        self.lcd.clear()
        self.lcd.text(message[:16], line)

    # def _rotate_messages(self, delay: float = 3.0):
    #     index = 0
    #     while self.running:
    #         with self.lock:
    #             if self.messages:
    #                 msg = self.messages[index % len(self.messages)]
    #                 self.show_message(msg, 1)
    #                 index += 1
    #         time.sleep(delay)
    def _rotate_messages(self, delay: float = 3.0):
        shown = set()
        while self.running:
            with self.lock:
                pending = [msg for msg in self.messages if msg not in shown]

                if not pending:
                    # Todos los mensajes ya fueron mostrados
                    self.running = False
                    break

                msg = pending[0]
                shown.add(msg)
                self.show_message(msg, 1)

            time.sleep(delay)


    def add_message(self, message: str):
        with self.lock:
            self.messages.append(message)

    def stop(self):
        self.running = False
        self.thread.join()
        self.lcd.clear()
