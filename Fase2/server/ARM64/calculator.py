import subprocess as sbp

class Calculator:
    def __init__(self):
        self.last_stats = {
            "mean": None,
            "median": None,
            "mode": None,
            "minimum": None,
            "maximum": None,
            "variance": None,
            "standard_deviation": None
        }

        self.last_predictions = {
            "moving_average": None,
            "exponential_smoothing": None
        }    
    

    def calculate_stats(self, data):
        data = self.stringify_data(data)

        self.last_stats = {
            "mean": self.get_mean(data),
            "median": self.get_median(data),
            "mode": self.get_mode(data),
            "minimum": self.get_minimum(data),
            "maximum": self.get_maximum(data),
            "variance": self.get_variance(data),
            "standard_deviation": self.get_stdev(data)
        }

        return self.last_stats

    def calculate_predictions(self, data):
        data = self.stringify_data(data)

        self.last_predictions = {
            "moving_average": self.get_movil_mean(data),
            "exponential_smoothing": self.get_exponential_smoothing(data)
        }

        return self.last_predictions
    
    def get_mean(self, data):
        mean_result = sbp.Popen(
            ['./ARM64/main', '0'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Mean: " + stdout, end='')
        return int(stdout.strip())

    def get_variance(self, data):
        mean_result = sbp.Popen(
            ['./ARM64/main', '1'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Variance: " + stdout, end='')
        return int(stdout.strip())

    def get_stdev(self, data):
        mean_result = sbp.Popen(
            ['./ARM64/main', '2'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Standard deviation: " + stdout, end='')
        return int(stdout.strip())

    def get_mode(self, data):
        median_result = sbp.Popen(
            ['./ARM64/main', '3'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = median_result.communicate(input=data)
        print("Mode: " + stdout, end='')
        return int(stdout.strip())

    def get_median(self, data):
        median_result = sbp.Popen(
            ['./ARM64/main', '4'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = median_result.communicate(input=data)
        print("Median: " + stdout, end='')
        return int(stdout.strip())

    def get_maximum(self, data):
        maximum_result = sbp.Popen(
            ['./ARM64/main', '5'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = maximum_result.communicate(input=data)
        print("Maximum: " + stdout, end='')
        return int(stdout.strip())

    def get_minimum(self, data):
        minimum_result = sbp.Popen(
            ['./ARM64/main', '6'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = minimum_result.communicate(input=data)
        print("Minimum: " + stdout, end='')
        return int(stdout.strip())
    
    def get_movil_mean(self, data):
        mean_result = sbp.Popen(
            ['./ARM64/main', '0'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = mean_result.communicate(input=data)
        print("Movil mean: " + stdout, end='')
        return int(stdout.strip())

    def get_exponential_smoothing(self, data):
        smoothing_result = sbp.Popen(
            # ['qemu-aarch64','./main', '7'],
            ['./ARM64/main', '7'],
            stdin=sbp.PIPE,
            stdout=sbp.PIPE,
            stderr=sbp.PIPE,
            text=True
        )

        stdout, stderr = smoothing_result.communicate(input=data)
        print("Exponential smoothing:\n" + stdout, end='')
        result_lines = stdout.strip().split('\n')
        result_numbers = [int(line) for line in result_lines if line.strip().isdigit()]
        return result_numbers

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
    calc = Calculator()
    data = [1, 7, 3, 4, 5, 6, 7, 8, 9, 10]
    
    print("Calculating statistics...")
    stats = calc.calculate_stats(data)
    print(stats)

    print("Calculating predictions...")
    predictions = calc.calculate_predictions(data)
    print(predictions)

