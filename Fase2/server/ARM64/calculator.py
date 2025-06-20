import subprocess as sbp

class Calculator:
    def __init__(self):
        self.last_request = {
            "measure": None,
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
    

    def calculate(self, data):
        return
    
    
    def get_mean(self, data):
        mean_result = sbp.Popen(
            ['qemu-aarch64', './stats/main', '1'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=self.stringify_data(data))

        print("Mean: " + str(stdout))

    def stringify_data(self, data):
        data_size = len(data)
        styled_string = ""
        for n in range(data_size):
            styled_string += str(data[n])
            styled_string += "\n"

        styled_string += "$"
        return styled_string

    
if __name__ == "__main__":
    numbers = [1, 2, 47, 15, 5]
    calculator = Calculator()
    calculator.get_mean(numbers)