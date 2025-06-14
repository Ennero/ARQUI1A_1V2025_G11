from gpiozero import DistanceSensor
from gpiozero.pins.pigpio import PiGPIOFactory

class Ultrasonic:

    def __init__(self, trigger_pin: int, echo_pin: int, detection_range_cm: float = 100.0):
        factory = PiGPIOFactory()  # Usar pigpio como backend
        self.sensor = DistanceSensor(
            echo=echo_pin,
            trigger=trigger_pin,
            max_distance=2.0,
            pin_factory=factory
        )
        self.detection_range = detection_range_cm / 100.0

    @property
    def proximity(self):
        try:
            distance = self.sensor.distance
            if distance <= self.detection_range:
                return distance * 100
            else:
                return 0
        except Exception as e:
            print(f"[Ultrasonic] Error al obtener proximidad: {e}")
            return None

if __name__ == "__main__":
    ultrasonic = Ultrasonic(trigger_pin=27, echo_pin=22, detection_range_cm=50.0)

    try:
        while True:
            if ultrasonic.motion_detected:
                print("Movimiento detectado!")
            else:
                print("No se detecta movimiento.")
    except KeyboardInterrupt:
        print("Deteniendo sensor ultrasonido.")
