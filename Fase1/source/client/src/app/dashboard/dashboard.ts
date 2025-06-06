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
  currentHumedad: string = '-';
  currentTemperatura: string = '-';
  currentDistancia: string = '-';
  currentGas: string = '-';
  currentIluminacion: string = '-';
  currentActual: string = '-';

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
            this.currentHumedad = `${value} %`;
            break;
          case 'temperatura':
            this.addValueToArray(this.dataSourceTemperatura, parseFloat(value), 'temperatura', '°C');
            this.updateChart('temperaturaChart', this.dataSourceTemperatura, 'temperatura');
            this.currentTemperatura = `${value} °C`;
            break;
          case 'distancia':
            this.addValueToArray(this.dataSourceDistancia, parseFloat(value), 'distancia', 'm');
            this.updateChart('distanciaChart', this.dataSourceDistancia, 'distancia');
            this.currentDistancia = `${value} m`;
            break;
          case 'gas':
            this.addValueToArray(this.dataSourceGas, parseFloat(value), 'gas', 'ppm');
            this.updateChart('gasChart', this.dataSourceGas, 'gas');
            this.currentGas = `${value} ppm`;
            break;
          case 'iluminacion':
            this.addValueToArray(this.dataSourceIluminacion, parseFloat(value), 'iluminacion', 'lux');
            this.updateChart('iluminacionChart', this.dataSourceIluminacion, 'iluminacion');
            this.currentIluminacion = `${value} lux`;
            break;
          case 'actual':
            this.addValueToArray(this.dataSourceActual, parseFloat(value), 'actual', '');
            this.updateChart('actualChart', this.dataSourceActual, 'actual');
            break;
        }
      });
  }

  // Agregar un nuevo valor al array y mantener solo los últimos 20 valores
  addValueToArray(array: any[], value: number, key: string, unit: string) {
    // Si ya hay 20 elementos, elimina el primero (el más antiguo)
    if (array.length >= 20){
      array.shift();
    } 
    // Agrega el nuevo valor al final
    array.push({ no: array.length + 1, [key]: unit ? `${value} ${unit}` : `${value}` });

    // Reasigna los números para que siempre sea den 1 al array.length
    array.forEach((item, index) => item.no = index + 1);
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
    this.charts['gas'] = this.createChart('gasChart', 'Gas (ppm)', this.dataSourceGas, 'gas', '#a8e6a3');
    this.charts['iluminacion'] = this.createChart('iluminacionChart', 'Iluminación (lux)', this.dataSourceIluminacion, 'iluminacion', '#22543d');
    this.charts['humedad'] = this.createChart('humedadChart', 'Humedad (%)', this.dataSourceHumedad, 'humedad', '#f5f3e7');
    this.charts['temperatura'] = this.createChart('temperaturaChart', 'Temperatura (°C)', this.dataSourceTemperatura, 'temperatura', '#8d6748', 'line');
    this.charts['actual'] = this.createChart('actualChart', 'Actual', this.dataSourceActual, 'actual', '#a8e6a3');
  }

  // Método para crear un gráfico
  createChart(canvasId: string, label: string, dataSource: any[], key: string, color: string, type: 'bar' | 'line' = 'bar'): Chart {
    return new Chart(canvasId, {
      type,
      data: {
        labels: dataSource.map(d => d.no),
        datasets: [{
          label,
          data: dataSource.map(d => parseFloat(d[key])),
          backgroundColor: color
        }]
      },
      options: { responsive: true }
    });
  }
  
  displayedColumnsDistancia: string[] = ['no', 'distancia'];
  dataSourceDistancia = [];

  displayedColumnsGas: string[] = ['no', 'gas'];
  dataSourceGas = [];

  displayedColumnsIluminacion: string[] = ['no', 'iluminacion'];
  dataSourceIluminacion = [];

  displayedColumnsHumedad: string[] = ['no', 'humidity'];
  dataSourceHumedad = [];
  
  displayedColumnsTemperatura: string[] = ['no', 'temperatura'];
  dataSourceTemperatura = [];

  displayedColumnsActual: string[] = ['no', 'actual'];
  dataSourceActual = [];
}
