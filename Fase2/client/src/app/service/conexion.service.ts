import { Injectable } from '@angular/core';
import mqtt from 'mqtt';
import { Subject } from 'rxjs';

// Acá hacemos que el servicio sea inyectable en toda la aplicación
// Esto permite que el servicio pueda ser utilizado en cualquier componente o servicio de la aplicación
// Y podemos crear varias instancias del servicio si es necesario, y todas compartirán los mismos datos
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

  // Array para almacenar los datos de la base de datos
  public dataLecturas: { id: number, date: string, time: string, _value: number }[] = [];
  public dataEstadisticas: { no: number, fecha: string, hora: string, type_data: string, valor: number }[] = [];
  public dataPredicciones: { no: number, fecha: string, hora: string, type_data: string, valor: number }[] = [];
  public dataAlertas: { id: number, date: string, time: string, _value: string }[] = [];
  
  // Variable para almacenar el nombre de la última tabla consultada
  public lastTable: string = '';
  // Variable para almacenar el nombre del sensor seleccionado y el tipo de tabla
  public selectedSensor: string = '';
  public selectedTable: string = '';

  // VARIABLES PARA ALMACENAR LOS DATOS DE LOS CALCULOS REALIZADOS
  // Variables para los resultados de los cálculos estadísticos
  averageValue = 0;
  medianValue = 0;
  modeValue = 0;
  minValue = 0;
  maxValue = 0;
  standardDeviationValue = 0;
  varianceValue = 0;

  // Variables para resultados de los modelos de predicción
  movingAverageValue = 0;
  exponentialSmoothingValue = 0;
  exponentialSmoothingList: {no: number, suavizado: number}[] = [];

  constructor() {
    this.connectClient();
  }

  // Cargar el historial de datos cuando se inicializa el servici

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
            console.log('La carga de datos es:', data);
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
                this.dataProximidad.push({ no: this.dataProximidad.length + 1, proximidad: `${valueFormatFixed} cm` });
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
              case 'luminosity':
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
              case 'average':
                this.averageValue = Number(valueFormatFixed);
                break;
              case 'median':
                this.medianValue = Number(valueFormatFixed);
                break;
              case 'mode':
                this.modeValue = Number(valueFormatFixed);
                break;
              case 'min':
                this.minValue = Number(valueFormatFixed);
                break;
              case 'max':
                this.maxValue = Number(valueFormatFixed);
                break;
              case 'standard_deviation':
                this.standardDeviationValue = Number(valueFormatFixed);
                break;
              case 'variance':
                this.varianceValue = Number(valueFormatFixed);
                break;
              case 'moving_average':
                this.movingAverageValue = Number(valueFormatFixed);
                break;
              case 'exponential_smoothing':
                this.exponentialSmoothingValue = Number(valueFormatFixed);
                break;
              case 'result':
                console.log('Datos recibidos del servidor:', data);
                const resultData = data;

                this.averageValue = this.averageValue = Number(resultData.average ?? 0);
                this.medianValue = this.medianValue = Number(resultData.median ?? 0);
                this.modeValue = this.modeValue = Number(resultData.mode ?? 0);
                this.minValue = this.minValue = Number(resultData.min_max ?? 0);
                this.standardDeviationValue = this.standardDeviationValue = Number(resultData.standard_deviation ?? 0);
                this.varianceValue = this.varianceValue = Number(resultData.variance ?? 0);
                this.movingAverageValue = this.movingAverageValue = Number(resultData.moving_average ?? 0);
                
                
                this.movingAverageValue =  Number(resultData.moving_average ?? 0);
          
                // Guardamos el valor de suavizado exponencial la lista
                const expList = Array.isArray(resultData.exponential_smoothing) ? resultData.exponential_smoothing : [];
                const expListobjetos = expList.map((valor: any, idx: number) => ({ no: idx + 1, suavizado: valor }));
                this.exponentialSmoothingList = expListobjetos;
                this.exponentialSmoothingValue = expList.length > 0 ? expList[expList.length - 1] : 0;
                // EMITIR EL MENSAJE PARA EL COMPONENTE
                this.messageSubject.next({ topic, value: JSON.stringify(data) });
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