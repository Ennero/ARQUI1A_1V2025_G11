from datetime import datetime

class SeipaDB:

    def __init__(self, temperature, humidity, pressure, air_quality, iluminity):
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

    # def __str__(self):
    #     return (f"Timestamp: {self._timestamp.strftime('%Y-%m-%d %H:%M:%S')}\n"
    #             f"Temperatura: {self._temperature:.1f} °C\n"
    #             f"Humedad: {self._humidity:.1f} %\n"
    #             f"Presión: {self._pressure:.1f} hPa")
    
    def __str__(self):
        timestamp_str = self._timestamp.strftime('%Y-%m-%d %H:%M:%S') if self._timestamp else "N/A"
        return (
                f"Temperatura: {self._temperature:.1f} °C\n"
                f"Humedad: {self._humidity:.1f} %\n"
                f"Presión: {self._pressure:.1f} hPa")
