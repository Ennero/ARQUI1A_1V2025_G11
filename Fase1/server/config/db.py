from datetime import datetime

class SiepaDB:

    def __init__(self, temperature=0, humidity=0, pressure=0, air_quality=0, iluminity=0):
        self._timestamp = datetime.now()
        self._temperature = temperature
        self._humidity = humidity
        self._pressure = pressure
        self._air_quality = air_quality
        self._iluminity = iluminity

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
    def iluminity(self):
        return self._iluminity
    
    @iluminity.setter
    def iluminity(self, value):
        if isinstance(value, (int, float)):
            self._iluminity = value
        else:
            raise TypeError("La iluminidad debe ser un número")

    def to_display_lines(self):
        timestamp_str = self._timestamp.strftime('%H:%M:%S') if self._timestamp else "N/A"
        lines = ["Nueva lectura"]
        
        lines.append(f"Hora: {timestamp_str}")
        lines.append(f"Temp: {self._temperature:.1f} °C")
        # 🚨 Agrega advertencias si los valores están fuera de rangos
        if self._temperature > 30:
            lines.append("Temperatura alta")
        elif self._temperature < 10:
            lines.append("Temperatura baja")

        lines.append(f"Humedad: {self._humidity:.1f} %")

        if self._humidity < 30:
            lines.append("Humedad baja")
        elif self._humidity > 70:
            lines.append("Humedad alta")

        lines.append(f"Presión: {self._pressure:.1f} hPa")
        lines.append(f"CO2: {self._air_quality:.1f} ppm")

        if self._air_quality > 1000:
            lines.append("Aire contaminado")

        lines.append(f"Lux: {self._iluminity:.1f} lux")

        if self._iluminity < 50:
            lines.append("Poca luz")

        return lines
