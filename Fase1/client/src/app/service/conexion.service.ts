import { Injectable } from '@angular/core';
import mqtt from 'mqtt';
import { Subject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class MqttService {
  private client!: mqtt.MqttClient;
  private readonly brokerUrl = 'wss://broker.emqx.io:8084/mqtt'; // EMQX WS URL
  private messageSubject = new Subject<{ topic: string, value: string }>();
  public message$ = this.messageSubject.asObservable();

  constructor() {
    this.connectClient();
  }

  connectClient() {
    this.client = mqtt.connect(this.brokerUrl, {
      clientId: 'angular_' + Math.random().toString(16).substr(2, 8),
      clean: true,
      reconnectPeriod: 1000,
      connectTimeout: 4000
    });

    this.client.on('connect', () => {
      console.log('✅ Conectado a EMQX broker');
      this.subscribe('fiusac/arqui1/g11/#');
    });

    this.client.on('message', (topic, payload) => {
        try {
            const data = JSON.parse(payload.toString());
            // Extrear el nombre del sensor del topic
            const sensor = topic.split('/').pop();
            // Obetener el valor usando la clave dinámica
            const value = data[sensor!];
            console.log("El sensor es:", sensor);
            console.log("El valor es:", value);
            if (typeof value === 'number' || typeof value === 'string') {
                this.messageSubject.next({ topic, value: value.toString() });
            }
        } catch (error) {
            console.error('❌ Error al procesar el mensaje:', error);
        }
    });

    this.client.on('error', (err) => {
      console.error('❌ Error:', err);
    });
  }
  subscribe(topic: string) {
    this.client.subscribe(topic, (err) => {
      if (err) console.error('❌ Error al suscribirse:', err);
      else console.log(`✅ Suscrito a: ${topic}`);
    });
  }

  publish(topic: string, message: string) {
    this.client.publish(topic, message);
  }
}