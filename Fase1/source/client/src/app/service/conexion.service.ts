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

  // Arrays públicos para compartir entre componentes
  public dataHumedad: { no: number, humidity: string }[] = [];
  public dataTemperatura: { no: number, temperatura: string }[] = [];
  public dataProximidad: { no: number, proximidad: string }[] = [];
  public dataAirQuality: { no: number, air_quality: string }[] = [];
  public dataIluminacion: { no: number, iluminacion: string }[] = [];
  public dataPresion: { no: number, presion: string }[] = [];

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
            const valueFormat = Number(value);
            const valueFormatFixed = isNaN(valueFormat) ? value : valueFormat.toFixed(2);

            console.log(`📬 Mensaje recibido en el topic: ${topic} con valor: ${value}`);
            switch (sensor) {
              case 'humidity':
                // // Actualizar el array de humedad, manteniendo solo los últimos 20 valores, de lo contrario elimina el primero
                // if (this.dataHumedad.length >= 20) this.dataHumedad.shift();
                // Agregar el nuevo valor al array
                this.dataHumedad.push({ no: this.dataHumedad.length + 1, humidity: `${valueFormatFixed} %` });
                // Actualizar el índice 'no' de cada elemento, por si se borra algún elemento
                this.dataHumedad.forEach((item, idx) => item.no = idx + 1);
                // Reasignar el array para forzar la actualización de la vista, así Angular detecta el cambio
                this.dataHumedad = [...this.dataHumedad];
                break;
              case 'temperature':
                this.dataTemperatura.push({ no: this.dataTemperatura.length + 1, temperatura: `${valueFormatFixed} °C` });
                this.dataTemperatura.forEach((item, idx) => item.no = idx + 1);
                // Reasignar el array para forzar la actualización de la vista, así Angular detecta el cambio
                this.dataTemperatura = [...this.dataTemperatura];
                break;
              case 'proximity':
                this.dataProximidad.push({ no: this.dataProximidad.length + 1, proximidad: `${valueFormatFixed} m` });
                this.dataProximidad.forEach((item, idx) => item.no = idx + 1);
                // Reasignar el array para forzar la actualización de la vista, así Angular detecta el cambio
                this.dataProximidad = [...this.dataProximidad];
                break;
              case 'air_quality':
                this.dataAirQuality.push({ no: this.dataAirQuality.length + 1, air_quality: `${valueFormatFixed} ppm` });
                this.dataAirQuality.forEach((item, idx) => item.no = idx + 1);
                // Reasignar el array para forzar la actualización de la vista, así Angular detecta el cambio
                this.dataAirQuality = [...this.dataAirQuality];
                break;
              case 'iluminity':
                this.dataIluminacion.push({ no: this.dataIluminacion.length + 1, iluminacion: `${valueFormatFixed} lux` });
                this.dataIluminacion.forEach((item, idx) => item.no = idx + 1);
                // Reasignar el array para forzar la actualización de la vista, así Angular detecta el cambio
                this.dataIluminacion = [...this.dataIluminacion];
                break;
              case 'pressure':
                this.dataPresion.push({ no: this.dataPresion.length + 1, presion: `${valueFormatFixed} hPa` });
                this.dataPresion.forEach((item, idx) => item.no = idx + 1);
                // Reasignar el array para forzar la actualización de la vista, así Angular detecta el cambio
                this.dataPresion = [...this.dataPresion];
                break;
            }
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