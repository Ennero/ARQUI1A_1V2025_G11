import time
from pcf8591 import PCF8591

class MQ135:
    def __init__(self, adc, channel=0, vref=5.0, load_resistance=10.0, r0=10.0):
        self.adc = adc
        self.channel = channel
        self.vref = vref
        self.load_resistance = load_resistance
        self.r0 = r0

    def calculate_rs(self, vout):
        if vout == 0:
            return float("inf")
        return (self.vref - vout) * self.load_resistance / vout

    @property
    def ppm(self):
        vout = self.adc.read_voltage(self.channel, self.vref)
        rs = self.calculate_rs(vout)
        ratio = rs / self.r0
        
        try:
            return 116.6020682 * (ratio ** -2.769034857)
        except Exception as e:
            print(f"Error al calcular PPM: {e}")
            return None

    def calibrate_r0(self, samples=50, delay=0.5):
        print(f"[Calibración] Iniciando calibración de R0 para MQ135...")
        rs_sum = 0
        for _ in range(samples):
            vout = self.adc.read_voltage(self.channel, self.vref)
            rs = self.calculate_rs(vout)
            rs_sum += rs
            time.sleep(delay)
        self.r0 = rs_sum / samples
        print(f"[Calibración] Nuevo R0 estimado: {self.r0:.2f}")