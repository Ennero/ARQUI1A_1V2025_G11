import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { AlertaGlobal } from './shared/alerta-global/alerta-global';
import { NgFor } from '@angular/common';
import { MqttService } from './service/conexion.service';

type Alerta = { id: number, mensaje: string, tipo: 'danger' | 'warning' | 'warning_1' | 'warning_2' | 'warning_3' | 'warning_4' | 'info' | 'success', visible?: boolean };
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, AlertaGlobal, NgFor],
  templateUrl: './app.html',
  styleUrls: ['./app.css']
})

export class App {
  alertas: Alerta[] = [];
  private alertaId = 0;

  constructor(private mqttService: MqttService) {}

  ngOnInit() {
    this.mqttService.message$.subscribe(({ topic, value }) => {
      console.log("El valor es de tipo: ", typeof value, " y el topic es: ", topic);
      let mensaje = '';
      let tipo: 'danger' | 'warning' | 'warning_1' | 'warning_2' | 'warning_3' | 'warning_4' | 'info' | 'success' | undefined = undefined;
      if (topic.endsWith('temperature/danger')) {
        mensaje = '¡Peligro! Temperatura crítica detectada.';
        tipo = 'danger';
      } else if (topic.endsWith('luminosity/danger')) {
        mensaje = '¡Peligro! Iluminación baja detectada.';
        tipo = 'warning_1';
      } else if (topic.endsWith('humidity/danger')) {
        mensaje = '¡Peligro! Humedad crítica detectada.';
        tipo = 'warning_2';
      } else if (topic.endsWith('air_quality/danger')) {
        mensaje = '¡Peligro! Calidad del aire crítica detectada.';
        tipo = 'warning_3';
      } else if (topic.endsWith('proximity') && value != '0') {
        mensaje = 'Hay movimiento detectado.';
        tipo = 'info';
      } else if (topic.endsWith('pressure/danger')) {
        mensaje = '¡Peligro! Presión crítica detectada.';
        tipo = 'success';
      }
      if (mensaje && tipo) {
        const id = ++this.alertaId;
        this.alertas.push({ id, mensaje, tipo, visible: true });
        setTimeout(() => {
          this.alertas = this.alertas.filter(a => a.id !== id);
        }, 5000);
      }
    });
  }

  cerrarAlerta(alerta: Alerta) {
    this.alertas = this.alertas.filter(a => a !== alerta);
  }
}