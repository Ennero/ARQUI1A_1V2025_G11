class MeasuresCalculator:
    def __init__(self):
        self.lastRequest = {
            "measure": None,
            "date": None,
            "mean": None,
            "median": None,
            "mode": None,
            "minimum": None,
            "maximum": None,
            "standard_deviation": None,
            "variance": None,
            "moving_average": None,
            "exponential_smoothing": None
        }
    
    