import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { FormsModule } from '@angular/forms';
import { NgForOf } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { MqttService } from '../service/conexion.service';
import Swal from 'sweetalert2';
import Chart from 'chart.js/auto';
import { Subscription } from 'rxjs';


@Component({
  selector: 'app-calc',
  standalone: true,
  imports: [Header, MatCardModule, MatSelectModule, MatButtonModule, FormsModule, NgForOf, HttpClientModule],
  templateUrl: './calc.html',
  styleUrls: ['./calc.css']
})
export class Calc {

  private charts: { [key: string]: Chart } = {};

  constructor(private http: HttpClient, private mqttService: MqttService) {}
  sensorTypes = [
    { value: 'proximity', viewValue: 'Proximidad' },
    { value: 'air_quality', viewValue: 'Aire' },
    { value: 'luminosity', viewValue: 'Iluminación' },
    { value: 'humidity', viewValue: 'Humedad' },
    { value: 'temperature', viewValue: 'Temperatura' },
    { value: 'pressure', viewValue: 'Presión' },
  ];

  // Variables para los resultados de los cálculos estatísticos
  averageValue = 0;
  medianValue = 0;
  modeValue = 0;
  minimum = 0;
  maximum = 0;
  standardDeviationValue = 0;
  varianceValue = 0;

  // Variables para resultados de los modelos de predicción
  movingAverageValue = 0;
  exponentialSmoothingValue = 0;
  exponentialSmoothingList: {no: number, suavizado: number}[] = [];

  selectedSensor = '';
  private mqttSub!: Subscription;

  ngOnInit() {
    // Suscribirse a los cambios del sensor seleccionado en el servicio MQTT
    this.mqttSub = this.mqttService.message$.subscribe(({topic, value}) => {
      console.log('Mensaje recibido desde calc:', topic, value);
      // Extraer el tipo de valor del topic
      const medida = topic.split('/').pop();
      console.log('Medida:', medida, 'Valor:', value);
      switch (medida) {
        case 'mean':
          this.averageValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.averageValue = this.averageValue;
          break;
        case 'median':
          this.medianValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.medianValue = this.medianValue;
          break;
        case 'mode':
          this.modeValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.modeValue = this.modeValue;
          break;
        case 'min':
          this.minimum = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.minimum = this.minimum;
          break;
        case 'max':
          this.maximum = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.maximum = this.maximum;
          break;
        case 'standard_deviation':
          this.standardDeviationValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.standardDeviationValue = this.standardDeviationValue;
          break;
        case 'variance':
          this.varianceValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.varianceValue = this.varianceValue;
          break;
        case 'moving_average':
          this.movingAverageValue = Number(Number(value).toFixed(2)) ?? 0
          this.mqttService.movingAverageValue = this.movingAverageValue;
          break;
        case 'exponential_smoothing':
          this.exponentialSmoothingValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.exponentialSmoothingValue = this.exponentialSmoothingValue;
          break;
        case 'result':
          const resultData = JSON.parse(value);
          console.log('Datos recibidos desde calc:', resultData);

          this.averageValue = this.mqttService.averageValue = Number(resultData.statistics.mean ?? 0);
          this.medianValue = this.mqttService.medianValue = Number(resultData.statistics.median ?? 0);
          this.modeValue = this.mqttService.modeValue = Number(resultData.statistics.mode ?? 0);
          this.minimum = this.mqttService.minimum = Number(resultData.statistics.minimum ?? 0);
          this.maximum = this.mqttService.maximum = Number(resultData.statistics.maximum ?? 0);
          this.standardDeviationValue = this.mqttService.standardDeviationValue = Number(resultData.statistics.standard_deviation ?? 0);
          this.varianceValue = this.mqttService.varianceValue = Number(resultData.statistics.variance ?? 0);
          this.movingAverageValue = this.mqttService.movingAverageValue = Number(resultData.predictions.moving_average ?? 0);

          // Guardamos el valor de suavizado exponencial la lista
          const expList = Array.isArray(resultData.predictions.exponential_smoothing) ? resultData.predictions.exponential_smoothing : [];
          const expListobjetos = expList.map((valor: any, idx: number) => ({ no: idx + 1, suavizado: valor }));
          this.exponentialSmoothingList = this.mqttService.exponentialSmoothingList = expListobjetos;
          this.exponentialSmoothingValue = this.mqttService.exponentialSmoothingValue = expList.length > 0 ? expList[expList.length - 1] : 0;

          // Actualizar el gráfico de suavizado exponencial
          this.updateChart('suavizadoChart', this.exponentialSmoothingList, 'suavizado');
          break;
      }
    });

    // Cargar los datos del sensor seleccionado al iniciar el componente
    this.selectedSensor = this.mqttService.selectedSensor ;
    this.averageValue = this.mqttService.averageValue;
    this.medianValue = this.mqttService.medianValue;
    this.modeValue = this.mqttService.modeValue;
    this.minimum = this.mqttService.minimum;
    this.maximum = this.mqttService.maximum;
    this.standardDeviationValue = this.mqttService.standardDeviationValue;
    this.varianceValue = this.mqttService.varianceValue;
    this.movingAverageValue = this.mqttService.movingAverageValue;
    this.exponentialSmoothingValue = this.mqttService.exponentialSmoothingValue;
  }

  ngAfterViewInit() {
    this.charts['suavizado'] = this.createChart('suavizadoChart', 'Suavizado Exponencial', this.exponentialSmoothingList, 'suavizado', '#0bab64');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('suavizadoChart', this.mqttService.exponentialSmoothingList, 'suavizado');
  }

  updateChart(chartId: string, dataSource: any[], key: string) {
    const chart = Chart.getChart(chartId);
    if (chart) {
      chart.data.labels = dataSource.map(d => d.no);
      chart.data.datasets[0].data = dataSource.map(d => parseFloat(d[key]));
      chart.update();
    }
  }

  ngOnDestroy() {
    this.mqttSub?.unsubscribe(); // Desuscribirse de los mensajes MQTT al destruir el componente
  }

  onSend() {
    console.log('Enviando comando para el sensor:', this.selectedSensor);
    this.mqttService.selectedSensor = this.selectedSensor; // Guardar el sensor seleccionado en el servicio
    const topic = `fiusac/arqui1/g11/calculate`;
    const message = JSON.stringify({ measurement: `${this.selectedSensor}`, calculate: 'all' });

    this.mqttService.publish(topic, message);

    Swal.fire('Éxito', `Comando publicado para el sensor ${this.selectedSensor}.`, 'success');
  }

  // Método para devolver el valor para los cálculos estadísticos
  displayValue(value: number): string {
    return value === 0 ? '-' : value.toString();
  }

  createChart(canvasId: string, label: string, dataSource: any[], key: string, color: string, type: 'bar' | 'line' = 'line'): Chart {
    // Crear una nueva instancia de Chart.js
    return new Chart(canvasId, {
      type,
      data: {
        // Asignar las etiquetas de los datos, en este caso los números de los registros
        labels: dataSource.map(d => d.no),
        datasets: [{
          label, // La etiqueta del dataset
          data: dataSource.map(d => parseFloat(d[key])), // Los valores del dataset, convertidos a float
          borderColor: color,
          backgroundColor: (ctx: { chart: any; }) => {
            const chart = ctx.chart;
            const {ctx: canvas, chartArea} = chart;
            if (!chartArea) return color;
            // Degradado vertical
            const gradient = canvas.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
            gradient.addColorStop(0, color + 'BB'); // más opaco arriba
            gradient.addColorStop(1, color + '11'); // más transparente abajo
            return gradient;
          },
          pointBackgroundColor: color,
          pointBorderColor: '#fff',
          pointRadius: 5,
          pointHoverRadius: 7,
          fill: true,
          tension: 0.4, // curva suave
          borderWidth: 3,
        }]
      },
      options: {
        responsive: true, // Hacer el gráfico responsivo
        plugins: {
          legend: {
            display: true, // Mostrar la leyenda
            labels: {
              color: '#22543d',
              font: { weight: 'bold', size: 14 }
            }
          },
          tooltip: {
            backgroundColor: '#0bab64',
            titleColor: '#fff',
            bodyColor: '#fff',
            borderColor: '#22543d',
            borderWidth: 1,
            padding: 12
          }
        },
        scales: {
          x: {
            grid: { color: '#e3e8ee' },
            ticks: { color: '#22543d', font: { weight: 'bold' } }
          },
          y: {
            grid: { color: '#e3e8ee' },
            ticks: { color: '#22543d', font: { weight: 'bold' } }
          }
        },
        animation: {
          duration: 900,
          easing: 'easeOutQuart'
        }
      }
    });
  }
}
