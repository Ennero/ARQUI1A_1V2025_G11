import { AfterViewInit, Component, OnInit, OnDestroy } from '@angular/core';
import { MqttService } from '../service/conexion.service';
import { Subscription } from 'rxjs';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import Chart from 'chart.js/auto';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [Header, MatCardModule, MatIconModule],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css'
})

export class Dashboard implements AfterViewInit, OnInit, OnDestroy {
  constructor(private mqttService: MqttService) {}

  // Definimos las columnas que se mostrarán en las tablas
  displayedColumnHumedad: string[] = ['no', 'humidity'];
  displayedColumnTemperatura: string[] = ['no', 'temperatura'];
  displayedColumnDistancia: string[] = ['no', 'distancia'];
  displayedColumnAirQuality: string[] = ['no', 'air_quality'];
  displayedColumnIluminacion: string[] = ['no', 'iluminacion'];
  displayedColumnActual: string[] = ['no', 'actual'];

  // Acceder a los datos de los sensores a través del servicio MQTT
  // Estos getters permiten acceder a los datos de los sensores desde la plantilla
  get dataSourceHumedad() { return this.mqttService.dataHumedad; }
  get dataSourceTemperatura() { return this.mqttService.dataTemperatura; }
  get dataSourceDistancia() { return this.mqttService.dataDistancia; }
  get dataSourceAirQuality() { return this.mqttService.dataAirQuality; }
  get dataSourceIluminacion() { return this.mqttService.dataIluminacion; }
  get dataSourceActual() { return this.mqttService.dataActual; }

  // Estos getters permiten acceder a los valores actuales de los sensores desde la plantilla
  // Accediendo al último elemento de cada array
  get currentHumedad(): string {
    const listaHumdedad = this.dataSourceHumedad;
    if (listaHumdedad.length > 0) {
      return listaHumdedad[listaHumdedad.length - 1].humidity;
    } else {
      return '-';
    }
  }

  get currentTemperatura(): string {
    const listaTemperatura = this.dataSourceTemperatura;
    if (listaTemperatura.length > 0) {
      return listaTemperatura[listaTemperatura.length - 1].temperatura;
    } else {
      return '-';
    }
  }

  get currentDistancia(): string {
    const listaDistancia = this.dataSourceDistancia;
    if (listaDistancia.length > 0) {
      return listaDistancia[listaDistancia.length - 1].distancia;
    } else {
      return '-';
    }
  }

  get currentAirQuality(): string {
    const listaAirQuality = this.dataSourceAirQuality;
    if (listaAirQuality.length > 0) {
      return listaAirQuality[listaAirQuality.length - 1].air_quality;
    } else {
      return '-';
    }
  }

  get currentIluminacion(): string {
    const listaIluminacion = this.dataSourceIluminacion;
    if (listaIluminacion.length > 0) {
      return listaIluminacion[listaIluminacion.length - 1].iluminacion;
    } else {
      return '-';
    }
  }

  get currentActual(): string {
    const listaActual = this.dataSourceActual;
    if (listaActual.length > 0) {
      return listaActual[listaActual.length - 1].actual;
    } else {
      return '-';
    }
  }

  private mqttSub!: Subscription;
  // Objetivo de tipo Chart, un diccionario con el nombre como clave y el valor e sun Chart
  private charts: { [key: string]: Chart } = {};

  // Inicializar los arrays para los datos de los sensores
  ngOnInit() {
      // Suscribirse a los mensajes
      this.mqttSub = this.mqttService.message$.subscribe(({ topic, value }) => {
        // Extraer el tipo de sensor del topic
        const sensor = topic.split('/').pop();
        switch (sensor) {
          case 'humidity':
            this.updateChart('humedadChart', this.dataSourceHumedad, 'humidity');
            break;
          case 'temperatura':
            this.updateChart('temperaturaChart', this.dataSourceTemperatura, 'temperatura');
            break;
          case 'distancia':
            this.updateChart('distanciaChart', this.dataSourceDistancia, 'distancia');
            break;
            break;
          case 'air_quality':
            this.updateChart('air_qualityChart', this.dataSourceAirQuality, 'air_quality');
            break;
          case 'iluminacion':
            this.updateChart('iluminacionChart', this.dataSourceIluminacion, 'iluminacion');
            break;
          case 'actual':
            this.updateChart('actualChart', this.dataSourceActual, 'actual');
            break;
        }
      });
  }
  // Actualizar el gráfico con los nuevos datos
  updateChart(chartId: string, dataSource: any[], key: string) {
    const chart = Chart.getChart(chartId);
    if (chart) {
      chart.data.labels = dataSource.map(d => d.no);
      chart.data.datasets[0].data = dataSource.map(d => parseFloat(d[key]));
      chart.update();
    }
  }

  // Desconectar del broker al destruir el componente
  ngOnDestroy(): void {
    if (this.mqttSub) this.mqttSub.unsubscribe();
  }

  // Inicializar los gráficos después de que la vista se haya inicializado
  ngAfterViewInit() {
    this.charts['distancia'] = this.createChart('distanciaChart', 'Distancia (m)', this.dataSourceDistancia, 'distancia', '#8d6748');
    this.updateChart('distanciaChart', this.dataSourceDistancia, 'distancia');
    this.charts['air_quality'] = this.createChart('air_qualityChart', 'CO2 (ppm)', this.dataSourceAirQuality, 'air_quality', '#a8e6a3');
    this.updateChart('air_qualityChart', this.dataSourceAirQuality, 'air_quality');
    this.charts['iluminacion'] = this.createChart('iluminacionChart', 'Iluminación (lux)', this.dataSourceIluminacion, 'iluminacion', '#22543d');
    this.updateChart('iluminacionChart', this.dataSourceIluminacion, 'iluminacion');
    this.charts['humedad'] = this.createChart('humedadChart', 'Humedad (%)', this.dataSourceHumedad, 'humidity', '#f5f3e7');
    this.updateChart('humedadChart', this.dataSourceHumedad, 'humidity');
    this.charts['temperatura'] = this.createChart('temperaturaChart', 'Temperatura (°C)', this.dataSourceTemperatura, 'temperatura', '#8d6748');
    this.updateChart('temperaturaChart', this.dataSourceTemperatura, 'temperatura');
    this.charts['actual'] = this.createChart('actualChart', 'Actual', this.dataSourceActual, 'actual', '#a8e6a3');
    this.updateChart('actualChart', this.dataSourceActual, 'actual');
  }

  // Método para crear un gráfico
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
