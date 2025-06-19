import subprocess as sbp
from datetime import datetime  # Date = dt.now.strftime("%x") Time: dt.now.strftime("%X")
from operations import stringify_data as str_data


class MeasuresCalculator:
    def __init__(self):
        self.last_request = {
            "measure": None,
            "date": None,
            "time": None,
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
    
    

    def calculate(self, measure=None):
        return  
    
    def get_mean(self, data):
        mean_result = sbp.Popen(
            ['qemu-aarch64-static', './ARM_processor/tests/test'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=str_data(data))

        print("Media: ")
        print(stdout)

        print("Error: ")
        print(stderr)



    