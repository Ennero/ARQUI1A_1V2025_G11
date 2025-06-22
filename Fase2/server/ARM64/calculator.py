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
            ['qemu-aarch64', './main', '0'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Mean: " + str(stdout))

    def get_variance(self, data):
        mean_result = sbp.Popen(
            ['qemu-aarch64', './main', '1'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Variance: " + str(stdout))

    def get_stdev(self, data):
        mean_result = sbp.Popen(
            ['qemu-aarch64', './main', '2'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Standard deviation: " + str(stdout))

    def get_mode(self, data):
        median_result = sbp.Popen(
            ['qemu-aarch64', './main', '3'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = median_result.communicate(input=data)
        print("Mode: " + str(stdout))

    def get_median(self, data):
        median_result = sbp.Popen(
            ['qemu-aarch64', './main', '4'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = median_result.communicate(input=data)
        print("Median: " + str(stdout))

    def get_maximum(self, data):
        maximum_result = sbp.Popen(
            ['qemu-aarch64', './main', '5'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = maximum_result.communicate(input=data)
        print("Maximum: " + str(stdout))

    def get_minimum(self, data):
        minimum_result = sbp.Popen(
            ['qemu-aarch64', './main', '6'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = minimum_result.communicate(input=data)
        print("Minimum: " + str(stdout))
    
    def get_movil_mean(self, data):
        mean_result = sbp.Popen(
            ['qemu-aarch64', './main', '0'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Movil mean: " + str(stdout))

    # -------------------------------------------------------------------------------
    def stringify_data(self, data):
        data_size = len(data)
        styled_string = ""
        for n in range(data_size):
            styled_string += str(data[n])
            styled_string += "\n"

        styled_string += "$"
        return styled_string

    
if __name__ == "__main__":
    with open("prueba.txt", "r") as file:
        numbers = file.read()
        calculator = Calculator()
        calculator.get_mean(numbers)
        calculator.get_variance(numbers)
        calculator.get_stdev(numbers)
        calculator.get_mode(numbers)
        calculator.get_median(numbers)
        calculator.get_maximum(numbers)
        calculator.get_minimum(numbers)
        calculator.get_movil_mean(numbers)
        