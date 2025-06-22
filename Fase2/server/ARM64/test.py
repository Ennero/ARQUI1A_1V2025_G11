from collections import Counter
import math

if __name__ == "__main__":
    with open("prueba.txt", "r") as file:
        data_string = file.read()

        # Eliminar el carácter $ y separar por saltos de línea
        lines = data_string.strip().strip("$").split("\n")

        # Convertir a enteros
        numbers = [int(num) for num in lines if num.strip().isdigit()]

        # Calcular estadísticas
        n = len(numbers)
        mean = sum(numbers) / n
        variance = sum((x - mean) ** 2 for x in numbers) / n
        std_dev = math.sqrt(variance)
        counts = Counter(numbers)
        mode, frequency = counts.most_common(1)[0]
        median = sorted(numbers)[n // 2] if n % 2 == 1 else (sorted(numbers)[n // 2 - 1] + sorted(numbers)[n // 2]) / 2
        maximum = max(numbers)
        minimum = min(numbers)

        # Mostrar resultados
        print(f"Media: {mean}")
        print(f"Varianza: {variance}")
        print(f"Desviación estándar: {std_dev}")
        print(f"Moda: {mode} (frecuencia: {frequency})")
        print(f"Mediana: {median}")
        print(f"Máximo: {maximum}")
        print(f"Mínimo: {minimum}")