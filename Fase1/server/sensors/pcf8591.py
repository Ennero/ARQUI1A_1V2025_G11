import smbus

class PCF8591:
    def __init__(self, address=0x48, bus=1):
        self.address = address
        self.bus = smbus.SMBus(bus)

    def read(self, channel):
        if channel < 0 or channel > 3:
            raise ValueError("El canal debe estar entre 0 y 3")

        self.bus.write_byte(self.address, 0x40 | channel)
        self.bus.read_byte(self.address)
        value = self.bus.read_byte(self.address)
        return value

    def read_voltage(self, channel, vref):
        value = self.read(channel)
        voltage = (value / 255.0) * vref
        return voltage