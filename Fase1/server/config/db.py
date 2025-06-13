from datetime import datetime

class SiepaDB:

    def __init__(self, temperature=0, humidity=0, pressure=0, air_quality=0, luminosity=0, motion_detected=False):
        self._timestamp = datetime.now()
        self._temperature = temperature
        self._humidity = humidity
        self._pressure = pressure
        self._air_quality = air_quality
        self._luminosity = luminosity
        self._motion_detected = motion_detected

    @property
    def timestamp(self):
        return self._timestamp
    
    @timestamp.setter
    def timestamp(self, value):
        if isinstance(value, datetime):
            self._timestamp = value
        else:
            raise TypeError("El timestamp debe ser una instancia de datetime")
        
    @property
    def temperature(self):
        return self._temperature
    
    @temperature.setter
    def temperature(self, value):
        if isinstance(value, (int, float)):
            self._temperature = value
        else:
            raise TypeError("La temperatura debe ser un número")
        
    @property
    def humidity(self):
        return self._humidity
    
    @humidity.setter
    def humidity(self, value):
        if isinstance(value, (int, float)):
            self._humidity = value
        else:
            raise TypeError("La humedad debe ser un número")
    
    @property
    def pressure(self):
        return self._pressure
    
    @pressure.setter
    def pressure(self, value):
        if isinstance(value, (int, float)):
            self._pressure = value
        else:
            raise TypeError("La presión debe ser un número")

    @property
    def air_quality(self):
        return self._air_quality

    @air_quality.setter
    def air_quality(self, value):
        if isinstance(value, (int, float)):
            self._air_quality = value
        else:
            raise TypeError("La calidad del aire debe ser un número")

    @property
    def luminosity(self):
        return self._luminosity
    
    @luminosity.setter
    def luminosity(self, value):
        if isinstance(value, (int, float)):
            self._luminosity = value
        else:
            raise TypeError("La luminosidad debe ser un número")

    @property
    def motion_detected(self):
        return self._motion_detected
    
    @motion_detected.setter
    def motion_detected(self, value):
        if isinstance(value, bool):
            self._motion_detected = value
        else:
            raise TypeError("El estado de movimiento debe ser un booleano")

    def to_display_lines(self):
        timestamp_str = self._timestamp.strftime('%H:%M:%S') if self._timestamp else "N/A"
        lines = ["Nueva lectura"]
        
        lines.append(f"Hora: {timestamp_str}")
        lines.append(f"Temp: {self._temperature:.1f} °C")

        if self._temperature >= 28:
            lines.append("Temperatura alta")

        lines.append(f"Humedad: {self._humidity:.1f} %")

        if self._humidity >= 70:
            lines.append("Humedad alta")

        lines.append(f"Presion: {self._pressure:.1f} hPa")

        lines.append(f"CO2: {self._air_quality:.1f} ppm")

        if self._air_quality >= 1000:
            lines.append("Aire contaminado")

        lines.append(f"Lumin: {self._luminosity:.1f} lux")

        if self._luminosity <= 200:
            lines.append("Poca luz")

        return lines

    # def to_display_lines(self):
    #     return [
    #         f"T: {self.temperature:.1f}C",
    #         f"H: {self.humidity:.1f}%",
    #         f"P: {self.pressure:.1f}hPa",
    #         f"AQ: {self.air_quality:.1f}ppm",
    #         f"LUX: {self.luminosity:.1f}"
    #     ]


    # def to_display_lines(self):
    #     return [
    #         f"T: {self.temperature:.1f}C",
    #         f"H: {self.humidity:.1f}%",
    #         f"P: {self.pressure:.1f}hPa",
    #         f"AQ: {self.air_quality:.1f}ppm",
    #         f"LUX: {self.luminosity:.1f}"
    #     ]
    # def to_display_lines(self):
    #     return [
    #         f"Temp: {self.temperature:.1f}C Hum: {self.humidity:.1f}%",
    #         f"Pres: {self.pressure:.1f}hPa AQ: {self.air_quality:.1f}",
    #         f"Lux: {self.luminosity:.1f} Time: {self._timestamp.strftime('%H:%M')}"
    #     ]
