import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { FormsModule } from '@angular/forms';
import { TitleCasePipe } from '@angular/common';
import { NgForOf } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import Swal from 'sweetalert2';
import { MqttService } from '../service/conexion.service';

@Component({
  selector: 'app-board',
  imports: [Header, MatCardModule, MatSelectModule, MatButtonModule, MatTableModule, FormsModule, HttpClientModule, NgForOf, TitleCasePipe],
  templateUrl: './board.html',
  styleUrl: './board.css'
})
export class Board {

  constructor(private http: HttpClient, private mqttService: MqttService) {}

  displayedColumns: string[] = ['no', 'fecha', 'hora', 'valor'];
  dataSource: any[] = [];

  // Mapeo de encabezados de columnas
  columnLabels: { [key: string]: string } = {
    no: 'No',
    fecha: 'Fecha',
    hora: 'Hora',
    lectura: 'Lectura',
    media: 'Media',
    mediana: 'Mediana',
    moda: 'Moda',
    min_max: 'Min/Max',
    desviacion: 'Desviación',
    varianza: 'Varianza',
    mediaMovil: 'Media Móvil',
    suavizadoExponencial: 'Suavizado Exponencial',
    alerta: 'Valor de Alerta',
  };

  sensorTypes = [
    { value: 'proximity', viewValue: 'Proximidad' },
    { value: 'air_quality', viewValue: 'Aire' },
    { value: 'luminosity', viewValue: 'Iluminación' },
    { value: 'humidity', viewValue: 'Humedad' },
    { value: 'temperature', viewValue: 'Temperatura' },
    { value: 'pressure', viewValue: 'Presión' },
  ];

  tableTypes = [
    { value: 'sensores', viewValue: 'Lecturas de los sensores' },
    { value: 'estadisticas', viewValue: 'Resultados estadisticos' },
    { value: 'predicciones', viewValue: 'Resultados predicciones' },
    { value: 'alertas', viewValue: 'Alertas' },
  ]

  selectedSensor = '';
  selectedTable = '';

  simularDatos(){
    this.mqttService.selectedSensor = this.selectedSensor;
    this.mqttService.selectedTable = this.selectedTable;
    this.actualizarTabla();
    // Simulación de datos
    switch (this.selectedTable) {
      case 'sensores':
        this.simularDatosLecturas();
        break;
      case 'estadisticas':
        this.simularDatosEstadistica();
        break;
      case 'predicciones':
        this.simularDatosPredicciones();
        break;
      case 'alertas':
        this.simularDatosAlertas();
        break;
      default:
        console.error('Tabla no válida seleccionada');
    }
  }

  simularDatosLecturas(){
    // Simulación de datos
    const simulatedData = [];
    for (let i = 0; i < 10; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      simulatedData.push({
        no: i + 1,
        fecha: date.toLocaleDateString(),
        hora: date.toLocaleTimeString(),
        lectura: Math.floor(Math.random() * 100) // Valor aleatorio entre 0 y 99
      });
    }
    this.dataSource = simulatedData;
    this.mqttService.dataLecturas = simulatedData;
  }

  simularDatosEstadistica(){
    // Simulación de datos
    const simulatedData = [];
    for (let i = 0; i < 1; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      simulatedData.push({
        no: i + 1,
        fecha: date.toLocaleDateString(),
        hora: date.toLocaleTimeString(),
        media: Math.floor(Math.random() * 100), // Valor aleatorio entre 0 y 99
        mediana: Math.floor(Math.random() * 100),
        moda: Math.floor(Math.random() * 100),
        min_max: Math.floor(Math.random() * 100),
        desviacion: Math.floor(Math.random() * 100),
        varianza: Math.floor(Math.random() * 100)
      });
    }
    this.dataSource = simulatedData;
    this.mqttService.dataEstadisticas = simulatedData;
  }

  simularDatosPredicciones(){
    // Simulación de datos
    const simulatedData = [];
      const date = new Date();
      date.setDate(date.getDate() - 1);
      simulatedData.push({
        no: 1,
        fecha: date.toLocaleDateString(),
        hora: date.toLocaleTimeString(),
        tipo: this.selectedSensor,
        mediaMovil: Math.floor(Math.random() * 100), // Valor aleatorio entre 0 y 99
        suavizadoExponencial: Math.floor(Math.random() * 100)
      });
    this.dataSource = simulatedData;
    this.mqttService.dataPredicciones = simulatedData;
  }


  simularDatosAlertas(){
    // Simulación de datos
    const simulatedData = [];
    for (let i = 0; i < 10; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      simulatedData.push({
        no: i + 1,
        fecha: date.toLocaleDateString(),
        hora: date.toLocaleTimeString(),
        alerta: `Alerta de ${this.selectedSensor} #${i + 1}` // Simulación de alerta
      });
    }
    this.dataSource = simulatedData;
    this.mqttService.dataAlertas = simulatedData;
  }

  actualizarTabla() {
    switch (this.selectedTable) {
      case 'sensores':
        this.displayedColumns = ['no', 'fecha', 'hora', 'lectura'];
        this.dataSource = this.mqttService.dataLecturas;
        this.mqttService.lastTable = 'sensores'; // Guardar la última tabla consultada
        break;
      case 'estadisticas':
        this.displayedColumns = ['fecha', 'hora', 'media', 'mediana', 'moda', 'min_max', 'desviacion', 'varianza'];
        this.dataSource = this.mqttService.dataEstadisticas;
        this.mqttService.lastTable = 'estadisticas'; // Guardar la última tabla consultada
        break;
      case 'predicciones':
        this.displayedColumns = ['no', 'fecha', 'hora', 'mediaMovil', 'suavizadoExponencial'];
        this.dataSource = this.mqttService.dataPredicciones;
        this.mqttService.lastTable = 'predicciones'; // Guardar la última tabla consultada
        break;
      case 'alertas':
        this.displayedColumns = ['no', 'fecha', 'hora', 'alerta'];
        this.dataSource = this.mqttService.dataAlertas;
        this.mqttService.lastTable = 'alertas'; // Guardar la última tabla consultada
        break;
      default:
        this.displayedColumns = [];
        this.dataSource = [];
    }
  }
  onSend(){
    console.log('Enviando datos para el sensor:', this.selectedSensor);
    // Url del servidor al que se enviará el comando
    const url = `http://172.20.10.2:5000/siepa/devices/table`; // Backend
    const sensor = this.selectedSensor;
    const table = this.selectedTable;

    this.http.put<any>(url, { sensor: sensor, table: table }).subscribe({
          next: (response) => {
            if (table === 'sensores') {
              this.mqttService.dataLecturas = response.data;
            } else if (table === 'estadisticas') {
              this.mqttService.dataEstadisticas = response.data;
            } else if (table === 'predicciones') {
              this.mqttService.dataPredicciones = response.data;
            } else if (table === 'alertas') {
              this.mqttService.dataAlertas = response.data;
            }
            this.actualizarTabla(); // Actualizar la tabla mostrada
            Swal.fire('Éxito', `El comando para sensor ${sensor} y tabla ${table} se ha enviado correctamente.`, 'success');
          },
          error: (error) => {
            console.error('Error al enviar el comando:', error);
            Swal.fire('Error', 'No se pudo enviar el comando. Inténtelo de nuevo más tarde.', 'error');
          }
        });
  }
  ngOnInit() {
    // Cargarmos los datos de los sensores escogidos y la tabla seleccionada
    this.selectedSensor = this.mqttService.selectedSensor;
    this.selectedTable = this.mqttService.selectedTable;
    // Cargar los datos de los sensores al iniciar el componente
    if (this.mqttService.lastTable) {
      if (this.mqttService.lastTable === 'sensores') {
        this.displayedColumns = ['no', 'fecha', 'hora', 'lectura'];
        this.dataSource = this.mqttService.dataLecturas;
      } else if (this.mqttService.lastTable === 'estadisticas') {
        this.displayedColumns = ['fecha', 'hora', 'media', 'mediana', 'moda', 'min_max', 'desviacion', 'varianza'];
        this.dataSource = this.mqttService.dataEstadisticas;
      } else if (this.mqttService.lastTable === 'predicciones') {
        this.displayedColumns = ['no', 'fecha', 'hora', 'mediaMovil', 'suavizadoExponencial'];
        this.dataSource = this.mqttService.dataPredicciones;
      } else if (this.mqttService.lastTable === 'alertas') {
        this.displayedColumns = ['no', 'fecha', 'hora', 'alerta'];
        this.dataSource = this.mqttService.dataAlertas;
      }
    }
  }

}
