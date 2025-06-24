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
import { Subscription } from 'rxjs';


@Component({
  selector: 'app-calc',
  standalone: true,
  imports: [Header, MatCardModule, MatSelectModule, MatButtonModule, FormsModule, NgForOf, HttpClientModule],
  templateUrl: './calc.html',
  styleUrls: ['./calc.css']
})
export class Calc {
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
  minMaxValue = 0;
  standardDeviationValue = 0;
  varianceValue = 0;

  // Variables para resultados de los modelos de predicción
  movingAverageValue = 0;
  exponentialSmoothingValue = 0;

  selectedSensor = '';
  private mqttSub!: Subscription;

  ngOnInit() {
    // Suscribirse a los cambios del sensor seleccionado en el servicio MQTT
    this.mqttSub = this.mqttService.message$.subscribe(({topic, value}) => {
      // Extraer el tipo de valor del topic
      const medida = topic.split('/').pop();
      switch (medida) {
        case 'average':
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
        case 'min_max':
          this.minMaxValue = Number(Number(value).toFixed(2)) ?? 0;
          this.mqttService.minMaxValue = this.minMaxValue;
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
      }
    });

    // Cargar los datos del sensor seleccionado al iniciar el componente
    this.selectedSensor = this.mqttService.selectedSensor ;
    this.averageValue = this.mqttService.averageValue;
    this.medianValue = this.mqttService.medianValue;
    this.modeValue = this.mqttService.modeValue;
    this.minMaxValue = this.mqttService.minMaxValue;
    this.standardDeviationValue = this.mqttService.standardDeviationValue;
    this.varianceValue = this.mqttService.varianceValue;
    this.movingAverageValue = this.mqttService.movingAverageValue;
    this.exponentialSmoothingValue = this.mqttService.exponentialSmoothingValue;
  }

  ngOnDestroy() {
    this.mqttSub?.unsubscribe(); // Desuscribirse de los mensajes MQTT al destruir el componente
  }


  onSendELiminar(){
    console.log('Enviando datos para el sensor:', this.selectedSensor);
    // Url del servidor al que se enviará el comando
    const url = `http://172.20.10.2:5000/siepa/devices/${this.selectedSensor}`; // Backend
    const sensor = this.selectedSensor;

    this.http.put<any>(url, { sensor: sensor }).subscribe({
          next: (response) => {
            // Actualizamos el valor de las variables con los datos recibidos
            this.mqttService.averageValue = this.averageValue = Number(Number(response.average).toFixed(2)) ?? 0;
            this.mqttService.medianValue = this.medianValue = Number(Number(response.median).toFixed(2)) ?? 0;
            this.mqttService.modeValue = this.modeValue = Number(Number(response.mode).toFixed(2)) ?? 0;
            this.mqttService.minMaxValue = this.minMaxValue = Number(Number(response.minMax).toFixed(2)) ?? 0;
            this.mqttService.standardDeviationValue = this.standardDeviationValue = Number(Number(response.standardDeviation).toFixed(2)) ?? 0;
            this.mqttService.varianceValue = this.varianceValue = Number(Number(response.variance).toFixed(2)) ?? 0;
            this.mqttService.movingAverageValue = this.movingAverageValue = Number(Number(response.movingAverage).toFixed(2)) ?? 0;
            this.mqttService.exponentialSmoothingValue = this.exponentialSmoothingValue = Number(Number(response.exponentialSmoothing).toFixed(2)) ?? 0;

            this.mqttService.selectedSensor = this.selectedSensor; // Guardar el sensor seleccionado en el servicio

            Swal.fire('Éxito', `El comando para sensor ${sensor} se ha enviado correctamente.`, 'success');
          },
          error: (error) => {
            console.error('Error al enviar el comando:', error);
            Swal.fire('Error', 'No se pudo enviar el comando. Inténtelo de nuevo más tarde.', 'error');
          }
        });
  }

  onSend() {
    console.log('Enviando comando para el sensor:', this.selectedSensor);
    this.mqttService.selectedSensor = this.selectedSensor; // Guardar el sensor seleccionado en el servicio
    const topic = `fiusac/arqui1/g11/data/${this.selectedSensor}`;
    const message = JSON.stringify({ comando: 'calcular' });

    this.mqttService.publish(topic, message);

    Swal.fire('Éxito', `Comando publicado para el sensor ${this.selectedSensor}.`, 'success');
  }

  // Método para devolver el valor para los cálculos estadísticos
  displayValue(value: number): string {
    return value === 0 ? '-' : value.toString();
  }
}
