import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { FormsModule } from '@angular/forms';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { NgClass, NgIf } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MqttService } from '../service/conexion.service';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-exit',
  standalone: true,
  imports: [Header, MatCardModule, NgClass, NgIf, MatIconModule, FormsModule, MatSlideToggleModule],
  templateUrl: './exit.html',
  styleUrls: ['./exit.css'],
})
export class Exit {
  constructor(private mqttService: MqttService) {}

  // false = automático, true = manual
  modoManual = false;

  temperaturaCritica = false;
  humedadCritica = false;
  iluminacionCritica = false;
  aireCritico = false;

  get dataSourceHumedad() : number {
    const listaHumedad = this.mqttService.dataHumedad;
    if (listaHumedad.length > 0) {
      return parseFloat(listaHumedad[listaHumedad.length - 1].humidity);
    } else {
      return 0.0;
    }
  }

  get dataSourceTemperatura() : number {
    const listaTemperatura = this.mqttService.dataTemperatura;
    if (listaTemperatura.length > 0) {
      return parseFloat(listaTemperatura[listaTemperatura.length - 1].temperatura);
    } else {
      return 0.0;
    }
  }

  get dataSourceIluminacion() : number {
    const listaIluminacion = this.mqttService.dataIluminacion;
    if (listaIluminacion.length > 0) {
      return parseFloat(listaIluminacion[listaIluminacion.length - 1].iluminacion);
    } else {
      return 0.0;
    }
  }

  get dataSourceAire() : number {
    const listaAire = this.mqttService.dataAirQuality;
    if (listaAire.length > 0) {
      return parseFloat(listaAire[listaAire.length - 1].air_quality);
    } else {
      return 0.0;
    }
  }

  // Simulación para encender las leds
  ngOnInit() {

    // Suscribirse a los mensajes WebSocket
    this.mqttService.message$.subscribe(({ topic, value}) => {
      // Extraer el tipo de sensor del topic
      const sensor = topic.split('/').pop();
      // Actualizar los valores de las fuentes de datos
      switch (sensor) {
        case 'humidity':
          this.dataSourceHumedad;
          break;
        case 'temperatura':
          this.dataSourceTemperatura;
          break;
        case 'iluminacion':
          this.dataSourceIluminacion;
          break;
        case 'air_quality':
          this.dataSourceAire;
          break;
      }

      const temperaturaMaxima = 29; // Simulación de temperatura
      this.temperaturaCritica = this.dataSourceTemperatura > temperaturaMaxima;

      const humedadMaxima = 80; // Simulación de humedad
      this.humedadCritica = this.dataSourceHumedad > humedadMaxima;

      const iluminacionMaxima = 1000; // Simulación de iluminación
      this.iluminacionCritica = this.dataSourceIluminacion < iluminacionMaxima;

      console.log('Temperatura:', this.dataSourceTemperatura);

      const aireMaximo = 1500; // Simulación de aire
      this.aireCritico = this.dataSourceAire > aireMaximo;
    });
  }

  ngAfterViewInit() {
    const temperaturaMaxima = 29; // Simulación de temperatura
    this.temperaturaCritica = this.dataSourceTemperatura > temperaturaMaxima;

    const humedadMaxima = 80; // Simulación de humedad
    this.humedadCritica = this.dataSourceHumedad > humedadMaxima;

    const iluminacionMinima = 1000; // Simulación de iluminación
    this.iluminacionCritica = this.dataSourceIluminacion < iluminacionMinima;

    const aireMaximo = 1500; // Simulación de aire
    this.aireCritico = this.dataSourceAire > aireMaximo;
  }

  mostrarAlertaPeligro(titulo: string) {
  Swal.fire({
    icon: 'warning',
    title: '¡Peligro!',
    text: `La ${titulo} ha superado el límite seguro. Por favor, revise los actuadores del sistema.`,
    confirmButtonText: 'Entendido',
    confirmButtonColor: '#e53935'
  });
}
}
