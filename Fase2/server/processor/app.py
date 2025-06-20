from calculator import MeasuresCalculator as ms
from operations import stringify_data, stringify_data_document
import subprocess

datos = [
    19, 20, 30, 25, 19, 20, 30, 25, 19, 20, 30, 25, 42, 44, 57
]
calc = ms()
calc.get_mean(datos)

# print(stringify_data_document())


# test_input = "19\n20\n30\n25\n19\n20\n30\n25\n19\n20\n30\n25\n42\n44\n57\n$"
# result = subprocess.run(['qemu-aarch64-static', './ARM_processor/main'], 
#                        input=test_input, 
#                        text=True, 
#                        capture_output=True)
# print(result.stdout)