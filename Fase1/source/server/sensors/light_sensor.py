class LightSensor:
    def __init__(self, adc, channel=0, vref=5.0, r_fixed=10000):
        self.adc = adc
        self.channel = channel
        self.vref = vref
        self.r_fixed = r_fixed

    def calculate_rldr(self, voltage):
        if voltage == 0:
            return float('inf')
        rldr = self.r_fixed * (self.vref - voltage) / voltage
        return rldr

    def calculate_lux(self, rldr):
        A = 500
        B = -1.4
        lux = A * (rldr ** B)
        return lux