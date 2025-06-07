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

  // Definimos las columnas que se mostrarán en las tablas
  displayedColumnsHumedad: string[] = ['no', 'humidity'];
  displayedColumnsAirQuality: string[] = ['no', 'air_quality'];
  displayedColumnsDistancia: string[] = ['no', 'distancia'];
  displayedColumnsIluminacion: string[] = ['no', 'iluminacion'];
  displayedColumnsTemperatura: string[] = ['no', 'temperatura'];
  displayedColumnsActual: string[] = ['no', 'actual'];

  // Copiamos los datos para que se muestren en las tablas
  dataSourceHumedad = dataHumedad;
  dataSourceAirQuality = dataAirQuality;
  dataSourceDistancia = dataDistancia;
  dataSourceIluminacion = dataIluminacion;
  dataSourceTemperatura = dataTemperatura;
  dataSourceActual = dataActual;

  constructor(private mqttService: MqttService) {}
  
  private mqttSub!: Subscription;
  // Objetivo de tipo Chart, un diccionario con el nombre como clave y el valor es un Chart
  private charts: { [key: string]: Chart } = {};

  ngOnInit(): void {

    // Suscribirse a los mensajes
    this.mqttSub = this.mqttService.message$.subscribe(({ topic, value }) => {
      // Extraer el tipo de sensor del topic
      const sensor = topic.split('/').pop();
      console.log("Agregando valor del sensor:", sensor, "con valor:", value);
      switch (sensor) {
        case 'humidity':
          this.addValueToArrayToData(parseFloat(value), 'humidity', '%');
          this.updateChart('humedadChart', dataHumedad, 'humidity');
          break;
        case 'temperatura':
          this.addValueToArrayToData(parseFloat(value), 'temperatura', '°C');
          this.updateChart('temperaturaChart', dataTemperatura, 'temperatura');
          break;
        case 'distancia':
          this.addValueToArrayToData(parseFloat(value), 'distancia', 'm');
          this.updateChart('distanciaChart', dataDistancia, 'distancia');
          break;
        case 'air_quality':
          this.addValueToArrayToData(parseFloat(value), 'air_quality', 'ppm');
          this.updateChart('air_qualityChart', dataAirQuality, 'air_quality');
          break;
        case 'iluminacion':
          this.addValueToArrayToData(parseFloat(value), 'iluminacion', 'lux');
          this.updateChart('iluminacionChart', dataIluminacion, 'iluminacion');
          break;
        case 'actual':
          this.addValueToArrayToData(parseFloat(value), 'actual', '');
          this.updateChart('actualChart', dataActual, 'actual');
          break;
      }
    })
  } 

  ngAfterViewInit() {
    this.charts['distancia'] = this.createChart('distanciaChart', 'Distancia (m)', dataDistancia, 'distancia', '#8d6748');
    this.charts['air_quality'] = this.createChart('air_qualityChart', 'CO2 (ppm)', dataAirQuality, 'air_quality', '#a8e6a3');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('air_qualityChart', dataAirQuality, 'air_quality');
    this.charts['iluminacion'] = this.createChart('iluminacionChart', 'Iluminación (lux)', dataIluminacion, 'iluminacion', '#22543d');
    this.charts['humedad'] = this.createChart('humedadChart', 'Humedad (%)', dataHumedad, 'humedad', '#f5f3e7');
    // Actualizar los datos de los gráficos con los datos iniciales
    this.updateChart('humedadChart', dataHumedad, 'humidity');
    this.charts['temperatura'] = this.createChart('temperaturaChart', 'Temperatura (°C)', dataTemperatura, 'temperatura', '#8d6748', 'line');
    this.charts['actual'] = this.createChart('actualChart', 'Actual', dataActual, 'actual', '#a8e6a3');
  }

  // Método para agregar un valor al array de datos y actualizar la tabla correspondiente
  addValueToArrayToData(value: number, key: string, unit: string): void {      
    // Reasignar el array para forzar la detección de cambios
    if (key === 'humidity') {
      dataHumedad.push({ no: dataHumedad.length + 1, humidity: `${value} ${unit}` });
      if (dataHumedad.length > 20) dataHumedad.shift();
      dataHumedad.forEach((item, idx) => item.no = idx + 1);
      this.dataSourceHumedad = [...dataHumedad];
    }

    if (key === 'air_quality') {
      dataAirQuality.push({ no: dataAirQuality.length + 1, air_quality: `${value} ${unit}` });
      if (dataAirQuality.length > 20) dataAirQuality.shift();
      dataAirQuality.forEach((item, idx) => item.no = idx + 1);
      this.dataSourceAirQuality = [...dataAirQuality];
    }

    if (key === 'temperatura') {
      dataTemperatura.push({ no: dataTemperatura.length + 1, temperatura: `${value} ${unit}` });
      if (dataTemperatura.length > 20) dataTemperatura.shift();
      dataTemperatura.forEach((item, idx) => item.no = idx + 1);
      this.dataSourceTemperatura = [...dataTemperatura];
    } 

    if (key === 'distancia') {
      dataDistancia.push({ no: dataDistancia.length + 1, distancia: `${value} ${unit}` });
      if (dataDistancia.length > 20) dataDistancia.shift();
      dataDistancia.forEach((item, idx) => item.no = idx + 1);
      this.dataSourceDistancia = [...dataDistancia];
    }

    if (key === 'actual') {
      dataActual.push({ no: dataActual.length + 1, actual: `${value} ${unit}` });
      if (dataActual.length > 20) dataActual.shift();
      dataActual.forEach((item, idx) => item.no = idx + 1);
      this.dataSourceActual = [...dataActual];
    }

    if (key === 'iluminacion') {
      dataIluminacion.push({ no: dataIluminacion.length + 1, iluminacion: `${value} ${unit}` });
      if (dataIluminacion.length > 20) dataIluminacion.shift();
      dataIluminacion.forEach((item, idx) => item.no = idx + 1);
      this.dataSourceIluminacion = [...dataIluminacion];
    }
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
}