import { AfterViewInit, Component, OnInit, OnDestroy  } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MqttService } from '../service/conexion.service';
import { Subscription } from 'rxjs';
import Chart from 'chart.js/auto';

@Component({
  selector: 'app-history',
  standalone: true,
  imports: [Header, MatCardModule, MatIconModule, CommonModule, MatTableModule],
  templateUrl: './history.html',
  styleUrls: ['./history.css']
})

export class History implements AfterViewInit, OnInit, OnDestroy{

  // Definimos las columnas que se mostrarán en las tablas
  displayedColumnsHumedad: string[] = ['no', 'humidity'];
  displayedColumnsAirQuality: string[] = ['no', 'air_quality'];
  displayedColumnsDistancia: string[] = ['no', 'distancia'];
  displayedColumnsIluminacion: string[] = ['no', 'iluminacion'];
  displayedColumnsTemperatura: string[] = ['no', 'temperatura'];
  displayedColumnsPresion: string[] = ['no', 'presion'];

  constructor(private mqttService: MqttService) {}

  // Acceder a los datos de los sensores a través del servicio MQTT
  // Estos getters permiten acceder a los datos de los sensores desde la plantilla
  get dataSourceHumedad() { return this.mqttService.dataHumedad; }
  get dataSourceAirQuality() { return this.mqttService.dataAirQuality; }
  get dataSourceDistancia() { return this.mqttService.dataDistancia; }
  get dataSourceIluminacion() { return this.mqttService.dataIluminacion; }
  get dataSourceTemperatura() { return this.mqttService.dataTemperatura; }
  get dataSourcePresion() { return this.mqttService.dataPresion; }

  private mqttSub!: Subscription;
  // Objetivo de tipo Chart, un diccionario con el nombre como clave y el valor es un Chart
  private charts: { [key: string]: Chart } = {};

  ngOnInit(): void {

    // En el componente, al suscribirte:
    // this.mqttService.message$
    //   .pipe(throttleTime(1000)) // máximo una actualización por segundo
    //   .subscribe(({ topic, value }) => {
    //     // tu lógica...
    //   });
    // Suscribirse a los mensajes WebSocket
    this.mqttSub = this.mqttService.message$.subscribe(({ topic, value }) => {
      
      // Extraer el tipo de sensor del topic
      const sensor = topic.split('/').pop();
      // Inicializar los valores de las fuentes de datos
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
        case 'air_quality':
          this.updateChart('air_qualityChart', this.dataSourceAirQuality, 'air_quality');
          break;
        case 'iluminacion':
          this.updateChart('iluminacionChart', this.dataSourceIluminacion, 'iluminacion');
          break;
        case 'presion':
          this.updateChart('presionChart', this.dataSourcePresion, 'presion');
          break;
      }
    })
  } 

  ngAfterViewInit() {
    this.charts['distancia'] = this.createChart('distanciaChart', 'Distancia (m)', this.dataSourceDistancia, 'distancia', '#8d6748');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('distanciaChart', this.dataSourceDistancia, 'distancia');
    this.charts['air_quality'] = this.createChart('air_qualityChart', 'CO2 (ppm)', this.dataSourceAirQuality, 'air_quality', '#a8e6a3');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('air_qualityChart', this.dataSourceAirQuality, 'air_quality');
    this.charts['iluminacion'] = this.createChart('iluminacionChart', 'Iluminación (lux)', this.dataSourceIluminacion, 'iluminacion', '#22543d');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('iluminacionChart', this.dataSourceIluminacion, 'iluminacion');
    this.charts['humidity'] = this.createChart('humedadChart', 'Humedad (%)', this.dataSourceHumedad, 'humidity', '#f5f3e7');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('humedadChart', this.dataSourceHumedad, 'humidity');
    this.charts['temperatura'] = this.createChart('temperaturaChart', 'Temperatura (°C)', this.dataSourceTemperatura, 'temperatura', '#8d6748');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('temperaturaChart', this.dataSourceTemperatura, 'temperatura');
    this.charts['presion'] = this.createChart('presionChart', 'Presion (hPa)', this.dataSourcePresion, 'presion', '#a8e6a3');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('presionChart', this.dataSourcePresion, 'presion');
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