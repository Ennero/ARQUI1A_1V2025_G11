import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { AlertGlobal } from './shared/alert-global/alert-global';
import { NgFor } from '@angular/common';
import { MqttService } from './service/conexion.service';

type Alerta = { id: number, mensaje: string, tipo: 'danger' | 'warning' | 'warning_1' | 'warning_2' | 'warning_3' | 'warning_4' | 'info' | 'success', visible?: boolean };
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, AlertGlobal, NgFor],
  templateUrl: './app.html',
  styleUrls: ['./app.css']
})

export class App {
  alertas: Alerta[] = [];
  private alertaId = 0;

  constructor(private mqttService: MqttService) {}

  ngOnInit() {
    this.mqttService.message$.subscribe(({ topic, value }) => {
      let mensaje = '';
      let tipo: 'danger' | 'warning' | 'warning_1' | 'warning_2' | 'warning_3' | 'warning_4' | 'info' | 'success' | undefined = undefined;
      if (topic.endsWith('temperatura/danger')) {
        mensaje = '¡Peligro! Temperatura crítica detectada.';
        tipo = 'danger';
      } else if (topic.endsWith('iluminacion/danger')) {
        mensaje = '¡Peligro! Iluminación baja detectada.';
        tipo = 'warning_1';
      } else if (topic.endsWith('humedad/danger')) {
        mensaje = '¡Peligro! Humedad crítica detectada.';
        tipo = 'warning_2';
      } else if (topic.endsWith('air_quality/danger')) {
        mensaje = '¡Peligro! Calidad del aire crítica detectada.';
        tipo = 'warning_3';
      } else if (topic.endsWith('proximidad')) {
        mensaje = 'Hay movimiento detectado.';
        tipo = 'warning_4';
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