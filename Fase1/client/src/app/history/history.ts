import { AfterViewInit, Component, OnInit, OnDestroy  } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MqttService } from '../service/conexion.service';
import { Subscription } from 'rxjs';
import Chart from 'chart.js/auto';
import {
  dataHumedad,
  dataTemperatura,
  dataDistancia,
  dataAirQuality,
  dataIluminacion,
  dataActual
} from '../data/datos';


@Component({
  selector: 'app-history',
  standalone: true,
  imports: [Header, MatCardModule, MatIconModule, CommonModule, MatTableModule],
  templateUrl: './history.html',
  styleUrls: ['./history.css']
})


export class History implements AfterViewInit, OnInit, OnDestroy{
  displayedColumnsHumedad: string[] = ['no', 'humidity'];
  dataSourceHumedad = dataHumedad;

  constructor(private mqttService: MqttService) {}
    currentHumedad: string = '-';
    currentTemperatura: string = '-';
    currentDistancia: string = '-';
    currentair_quality: string = '-';
    currentIluminacion: string = '-';
    currentActual: string = '-';
  
    private mqttSub!: Subscription;
    // Objetivo de tipo Chart, un diccionario con el nombre como clave y el valor es un Chart
    private charts: { [key: string]: Chart } = {};

  ngOnInit(): void {
    // Conectamos el broker
    this.mqttService.connectClient();

    // Suscribirse a los mensajes
    this.mqttSub = this.mqttService.message$.subscribe(({ topic, value }) => {
      // Extraer el tipo de sensor del topic
      const sensor = topic.split('/').pop();
      console.log("Agregando valor del sensor:", sensor, "con valor:", value);
      switch (sensor) {
        case 'humidity':
          // Imprimimos los valores de la lista
          console.log("Valor de la lista de humedad:", dataHumedad);
          dataHumedad.push({ no: dataHumedad.length + 1, humidity: `${value} %` });
          if (dataHumedad.length > 20) dataHumedad.shift();
          dataHumedad.forEach((item, idx) => item.no = idx + 1);
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
        case 'air_quality':
          this.addValueToArray(this.dataSourceair_quality, parseFloat(value), 'air_quality', 'ppm');
          this.updateChart('air_qualityChart', this.dataSourceair_quality, 'air_quality');
          this.currentair_quality = `${value} ppm`;
          break;
        case 'iluminacion':
          this.addValueToArray(this.dataSourceIluminacion, parseFloat(value), 'iluminacion', 'lux');
          this.updateChart('iluminacionChart', this.dataSourceIluminacion, 'iluminacion');
          this.currentIluminacion = `${value} lux`;
          break;
        case 'actual':
          this.addValueToArray(this.dataSourceActual, parseFloat(value), 'actual', '');
          this.updateChart('actualChart', this.dataSourceActual, 'actual');
          this.currentActual = `${value}`;
          break;
      }
    })


  } 

    ngAfterViewInit() {
    this.charts['distancia'] = this.createChart('distanciaChart', 'Distancia (m)', this.dataSourceDistancia, 'distancia', '#8d6748');
    this.charts['air_quality'] = this.createChart('air_qualityChart', 'CO2 (ppm)', this.dataSourceair_quality, 'air_quality', '#a8e6a3');
    this.charts['iluminacion'] = this.createChart('iluminacionChart', 'Iluminación (lux)', this.dataSourceIluminacion, 'iluminacion', '#22543d');
    this.charts['humedad'] = this.createChart('humedadChart', 'Humedad (%)', this.dataSourceHumedad, 'humedad', '#f5f3e7');
    this.charts['temperatura'] = this.createChart('temperaturaChart', 'Temperatura (°C)', this.dataSourceTemperatura, 'temperatura', '#8d6748', 'line');
    this.charts['actual'] = this.createChart('actualChart', 'Actual', this.dataSourceActual, 'actual', '#a8e6a3');
  }

  // Agregar un nuevo valor al array y mantener solo los últimos 20 VALORES
  addValueToArray(array: any[], value: number, key: string, unit: string): void {
    // Si ya hay 20 elementos, elimina el primero (el más antiguo)
    if (array.length >= 20) {
      array.shift();
    }

    // Agrega el nuevo valor al final
    array.push({ no: array.length + 1, [key]: unit ? `${value} ${unit}` : `${value}` });

    // Reasigna los números para que siempre sea del 1 al array.length
    array.forEach((item, index) => item.no = index+1);

    // Reasignar el array para forzar la detección de cambios
    if (key === 'humidity') this.dataSourceHumedad = [...array];
    if (key === 'temperatura') this.dataSourceTemperatura = [...array];
    if (key === 'distancia') this.dataSourceDistancia = [...array];
    if (key === 'air_quality') this.dataSourceair_quality = [...array];
    if (key === 'iluminacion') this.dataSourceIluminacion = [...array];
    if (key === 'actual') this.dataSourceActual = [...array];
  }

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
  dataSourceDistancia: { no: number, distancia: string }[] = [];

  displayedColumnsair_quality: string[] = ['no', 'air_quality'];
  dataSourceair_quality: { no: number, air_quality: string }[] = [];

  displayedColumnsIluminacion: string[] = ['no', 'iluminacion'];
  dataSourceIluminacion: { no: number, iluminacion: string }[] = [];

  
  displayedColumnsTemperatura: string[] = ['no', 'temperatura'];
  dataSourceTemperatura: { no: number, temperatura: string }[] = [];

  displayedColumnsActual: string[] = ['no', 'actual'];
  dataSourceActual: { no: number, actual: string }[] = [];

}
