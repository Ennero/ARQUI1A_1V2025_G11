from gpiozero import DistanceSensor

class Ultrasonic:

    def __init__(self, trigger_pin: int, echo_pin: int, detection_range_cm: float = 100.0):
        self.sensor = DistanceSensor(echo=echo_pin, trigger=trigger_pin, max_distance=2.0)
        self.detection_range = detection_range_cm / 100.0
        self.motion_detected = False
    
    def read(self):
        try:
            distance = self.sensor.distance
            self.motion_detected = distance <= self.detection_range
        except Exception as e:
            print(f"[Ultrasonic] Error al leer: {e}")
            self.motion_detected = False

    def print_data(self):
        if self.motion_detected:
            print("Movimiento detectado dentro del rango.")
        else:
            print("Sin movimiento dentro del rango.")
