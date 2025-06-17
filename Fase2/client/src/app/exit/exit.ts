import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { FormsModule } from '@angular/forms';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { NgClass, NgIf } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MqttService } from '../service/conexion.service';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-exit',
  standalone: true,
  imports: [Header, MatCardModule, NgClass, NgIf, MatIconModule, FormsModule, MatSlideToggleModule, HttpClientModule],
  templateUrl: './exit.html',
  styleUrls: ['./exit.css'],
})
export class Exit {
  constructor(private mqttService: MqttService, private http: HttpClient) {}

  // false = automático, true = manual
  modoManualTemperatura = false;
  modoManualIluminacion = false;
  modoManualAire = false;

  // Variables para los estados de los sensores
  temperaturaCritica = false;
  humedadCritica = false;
  iluminacionCritica = false;
  aireCritico = false;

  statusDeviceBuzzer = false // Estado del actuador
  statusDeviceFan = false // Estado del actuador
  statusDeviceLighting = false // Estado del actuador

  // Estados de las led
  statusLedRoja = false;
  statusLedVerde = false;
  statusLedAzul = false;
  statusLedAmarilla = false;

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
    //this.cargarEstadosDesdeBackend();
    // Suscribirse a los mensajes WebSocket
    this.mqttService.message$.subscribe(({ topic, value}) => {
      // Extraer el tipo de sensor del topic
      const sensor = topic.split('/').pop();
      // Actualizar los valores de las fuentes de datos
      switch (sensor) {
        case 'humidity':
          this.dataSourceHumedad;
          break;
        case 'temperature':
          this.dataSourceTemperatura;
          break;
        case 'luminosity':
          this.dataSourceIluminacion;
          break;
        case 'air_quality':
          this.dataSourceAire;
          break;
      }

      const temperaturaMaxima = 28; // Simulación de temperatura
      this.temperaturaCritica = this.dataSourceTemperatura > temperaturaMaxima;

      const humedadMaxima = 70; // Simulación de humedad
      this.humedadCritica = this.dataSourceHumedad > humedadMaxima;

      const iluminacionMaxima = 200; // Simulación de iluminación
      this.iluminacionCritica = this.mqttService.dataIluminacion.length > 0 && this.dataSourceIluminacion < iluminacionMaxima;
      console.log('Iluminación:', this.dataSourceIluminacion);

      const aireMaximo = 700; // Simulación de aire
      this.aireCritico = this.dataSourceAire > aireMaximo;
    });
  }

  ngAfterViewInit() {
    const temperaturaMaxima = 28; // Simulación de temperatura
    this.temperaturaCritica = this.dataSourceTemperatura > temperaturaMaxima;

    const humedadMaxima = 70; // Simulación de humedad
    this.humedadCritica = this.dataSourceHumedad > humedadMaxima;

    const iluminacionMinima = 200; // Simulación de iluminación
    this.iluminacionCritica = this.dataSourceIluminacion < iluminacionMinima;

    const aireMaximo = 700; // Simulación de aire
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

  cambiarModoManual(actuador: string) {
    let modoManual = "manual";
    const url = `http://172.20.10.2:5000/siepa/devices/control/${actuador}`;

    if (actuador === 'fan') {
      this.modoManualTemperatura = !this.modoManualTemperatura; // Cambiar el estado del modo manual
      modoManual = this.modoManualTemperatura ? 'manual' : 'automatic';
    } else if (actuador === 'lighting') {
      this.modoManualIluminacion = !this.modoManualIluminacion; // Cambiar el estado del modo manual
      modoManual = this.modoManualIluminacion ? 'manual' : 'automatic';
    } else if (actuador === 'buzzer') {
      this.modoManualAire = !this.modoManualAire; // Cambiar el estado del modo manual
      modoManual = this.modoManualAire ? 'manual' : 'automatic';
    }

    this.http.put(url, { mode: modoManual }).subscribe({
      next: (response) => {
        console.log('Modo cambiado exitosamente:', response);
        Swal.fire('Éxito', `El modo del sistema se ha cambiado a ${modoManual ? 'manual' : 'automatic'}.`, 'success');
      },
      error: (error) => {
        console.error('Error al cambiar el modo:', error);
        Swal.fire('Error', 'No se pudo cambiar el modo del sistema. Inténtelo de nuevo más tarde.', 'error');
      }
    });
  }

  enviarComando(actuador: string) {
    // Url del servidor al que se enviará el comando
    const url = `http://172.20.10.2:5000/siepa/devices/${actuador}`; // Backend

    let status = null;

    if (actuador == 'buzzer') {
      this.statusDeviceBuzzer = status = !this.statusDeviceBuzzer; // Cambiar el estado del buzzer
    } else if (actuador == 'fan') {
      this.statusDeviceFan = status = !this.statusDeviceFan; // Cambiar el estado del ventilador
    } else if (actuador == 'lighting') {
      this.statusDeviceLighting = status = !this.statusDeviceLighting; // Cambiar el estado de la iluminación
    } else if (actuador == 'red_led'){
      this.statusLedRoja = status = !this.statusLedRoja; // Cambiar el estado del led rojo
    } else if (actuador == 'green_led'){
      this.statusLedVerde = status = !this.statusLedVerde; // Cambiar el estado del led verde
    } else if (actuador == 'blue_led'){
      this.statusLedAzul = status = !this.statusLedAzul; // Cambiar el estado del led azul
    } else if (actuador == 'yellow_led'){
      this.statusLedAmarilla = status = !this.statusLedAmarilla; // Cambiar el estado del led amarillo
    }

    this.http.put(url, { status: status }).subscribe({
      next: (response) => {
        console.log('Comando enviado exitosamente:', response);
        Swal.fire('Éxito', `El comando para el actuador ${actuador} se ha enviado correctamente.`, 'success');
      },
      error: (error) => {
        console.error('Error al enviar el comando:', error);
        Swal.fire('Error', 'No se pudo enviar el comando. Inténtelo de nuevo más tarde.', 'error');
      }
    });
  }

  puedeEncenderVentilador() {
  return this.modoManualTemperatura;
  }

  puedeEncenderBuzzer() {
  return this.modoManualAire;
  }
  puedeEncenderIluminacion() {
    return this.modoManualIluminacion;
  }

  cargarEstadosDesdeBackend() {
    const url = 'http://172.20.10.2:5000/siepa/devices/status'; // Cambia por tu endpoint real

    this.http.get<any>(url).subscribe({
      next: (data) => {
        // Leds
        this.statusLedRoja = data.temperature?.mode ?? false;
        this.modoManualTemperatura = data.temperature?.control === 'manual';

        this.statusLedAmarilla = data.humidity?.mode ?? false;

        this.statusLedVerde = data.luminosity?.mode ?? false;
        this.modoManualIluminacion = data.luminosity?.control === 'manual';

        this.statusLedAzul = data.air_quality?.mode ?? false;
        this.modoManualAire = data.air_quality?.control === 'manual';

        // Actuadores principales
        this.statusDeviceLighting = data.lighting_device?.mode ?? false;
        // Si tienes modo manual para iluminación principal:
        // this.modoManualIluminacion = data.lighting_device?.control === 'manual';

        this.statusDeviceFan = data.fan_device?.mode ?? false;
        // this.modoManualTemperatura = data.fan_device?.control === 'manual';

        this.statusDeviceBuzzer = data.buzzer_device?.mode ?? false;
        // this.modoManualAire = data.buzzer_device?.control === 'manual';
      },
      error: (err) => {
        console.error('Error al cargar estados:', err);
      }
    });
  }

}
