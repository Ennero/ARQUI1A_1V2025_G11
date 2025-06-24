import subprocess
from datetime import datetime  # Date = dt.now.strftime("%x") Time: dt.now.strftime("%X")
import os


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

    def calculate(self):
        return  
    
    
    def get_mean(self, data):
        input_data = self.stringify_data(data)
        mean_result = subprocess.run(
            ['qemu-aarch64-static', './ARM_processor/main', '2'],
            input=input_data,
            text=True,
            capture_output=True,
            check=True
        )

        print("Media: " + str(mean_result.stdout))
        if(len(str(mean_result.stderr).strip())<1):
            print("\nErrores: ningún error en la ejecución")
        else:
            print("\nErrores: " + str(mean_result.stderr))
    

    def stringify_data(self, data):
        data_size = len(data)
        styled_string = ""
        for n in range(data_size):
            styled_string += str(data[n])
            styled_string += "\n"
        styled_string += "$"
        return styled_string