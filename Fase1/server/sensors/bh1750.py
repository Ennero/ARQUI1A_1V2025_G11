import smbus
import time

class BH1750:
    ADDRESS = 0x23
    POWER_ON = 0x01
    RESET = 0x07
    CONT_H_RES_MODE = 0x10

    def __init__(self, bus=1):
        self.bus = smbus.SMBus(bus)
        self.power_on()
        self.reset()
        time.sleep(0.2)

    def power_on(self):
        self.bus.write_byte(self.ADDRESS, self.POWER_ON)

    def reset(self):
        self.bus.write_byte(self.ADDRESS, self.RESET)

    @property
    def brightness(self):
        self.bus.write_byte(self.ADDRESS, self.CONT_H_RES_MODE)
        time.sleep(0.2)

        data = self.bus.read_i2c_block_data(self.ADDRESS, 0x00, 2)
        raw = (data[0] << 8) | data[1]  
        lux = raw / 1.2
        return lux