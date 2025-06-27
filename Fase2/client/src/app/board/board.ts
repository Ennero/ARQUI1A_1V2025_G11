import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { FormsModule } from '@angular/forms';
import { TitleCasePipe } from '@angular/common';
import { NgForOf } from '@angular/common';
import { NgIf } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import Swal from 'sweetalert2';
import { MqttService } from '../service/conexion.service';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { Modal } from '../modal/modal';

@Component({
  selector: 'app-board',
  imports: [Header, MatCardModule, MatSelectModule, MatButtonModule, MatTableModule, FormsModule, HttpClientModule, NgForOf, TitleCasePipe, NgIf, MatDialogModule],
  templateUrl: './board.html',
  styleUrl: './board.css'
})
export class Board {

  constructor(private http: HttpClient, private mqttService: MqttService, private dialog: MatDialog) {}

  displayedColumns: string[] = ['no', 'fecha', 'hora', 'valor'];
  dataSource: any[] = [];

  // Mapeo de encabezados de columnas
  columnLabels: { [key: string]: string } = {
    id: 'No',
    date: 'Fecha',
    time: 'Hora',
    _value: 'Valor',
    mean: 'Media',
    median: 'Mediana',
    mode: 'Moda',
    minimum: 'Minimo',
    maximum: 'Máximo',
    standard_deviation: 'Desviación',
    variance: 'Varianza',
    moving_average: 'Media Móvil',
    exponential_smoothing: 'Suavizado Exponencial',
    alert: 'Valor de Alerta',
    proximity: 'Proximidad',
    air_quality: 'Calidad del Aire',
    luminosity: 'Luminosidad',
    humidity: 'Humedad',
    temperature: 'Temperatura',
    pressure: 'Presión',
    type: "Tipo de Sensor",
    type_data: "Tipo de medición",
  };

  sensorTypes = [
    { value: 'proximity', viewValue: 'Proximidad' },
    { value: 'air_quality', viewValue: 'Aire' },
    { value: 'luminosity', viewValue: 'Iluminación' },
    { value: 'humidity', viewValue: 'Humedad' },
    { value: 'temperature', viewValue: 'Temperatura' },
    { value: 'pressure', viewValue: 'Presión' },
    { value: 'all', viewValue: 'Todos los sensores' },
  ];

  
  tableTypes = [
    { value: 'sensor_readings', viewValue: 'Lecturas de los sensores' },
    { value: 'statistics', viewValue: 'Resultados estadisticos' },
    { value: 'predictions', viewValue: 'Resultados predicciones' },
    { value: 'alerts', viewValue: 'Alertas' },
  ]

  selectedSensor = '';
  selectedTable = '';

  // Método para abrir el modal:
  openPredictionModal(lista: number[]) {
    this.dialog.open(Modal, {
      data: lista,
      width: '800px'
    });
  }

  actualizarTabla() {
    switch (this.selectedTable) {
      case 'sensor_readings':
        if (this.selectedSensor === 'all') {
          this.displayedColumns = ['id', 'date', 'time', 'proximity', 'air_quality', 'luminosity', 'humidity', 'temperature', 'pressure'];
          this.dataSource = this.mqttService.dataLecturas;
        } else {
          this.displayedColumns = ['id', 'date', 'time', '_value'];
          this.dataSource = this.mqttService.dataLecturas;
        }
        this.mqttService.lastTable = 'sensor_readings'; // Guardar la última tabla consultada
        break;
      case 'statistics':
        this.displayedColumns = ['id', 'date', 'time' ,'mean', 'median', 'mode', 'minimum', 'maximum', 'variance', 'standard_deviation'];
        this.dataSource = this.mqttService.dataEstadisticas;
        this.mqttService.lastTable = 'statistics';
        break;
      case 'predictions':
        this.displayedColumns = ['id', 'date', 'time', 'moving_average', 'exponential_smoothing', 'detalles'];
        this.dataSource = this.mqttService.dataPredicciones;
        this.mqttService.lastTable = 'predictions'; // Guardar la última tabla consultada
        break;
      case 'alerts':
        if (this.selectedSensor === 'all') {
          this.displayedColumns = ['id', 'date', 'time', 'type', '_value'];
          this.dataSource = this.mqttService.dataAlertas;   
        } else {
          this.displayedColumns = ['id', 'date', 'time', '_value'];
          this.dataSource = this.mqttService.dataAlertas;
        }
        this.mqttService.lastTable = 'alertas'; // Guardar la última tabla consultada
        break;
      default:
        this.displayedColumns = [];
        this.dataSource = [];
    }
  }
  onSend(){
    // Borramos los datos de las listas de datos
    this.mqttService.dataLecturas = [];
    this.mqttService.dataEstadisticas = [];
    this.mqttService.dataPredicciones = [];
    this.mqttService.dataAlertas = [];
    let url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=${this.selectedSensor}&limit=${20}`; // Backend
    const sensor = this.selectedSensor;
    const table = this.selectedTable;
    this.mqttService.selectedSensor = sensor; // Guardar el sensor seleccionado
    this.mqttService.selectedTable = table; // Guardar la tabla seleccionada

    if (this.selectedTable === 'sensor_readings') {
      if (this.selectedSensor === 'all') {
        url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=all&limit=${20}`; // Backend
      } else {
        url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=${this.selectedSensor}&limit=${20}`; // Backend
      }
    } else if (this.selectedTable === 'alerts') {
      if (this.selectedSensor === 'all') {
        url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=all&limit=${2000}`; // Backend
      } else {
        url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=${this.selectedSensor}&limit=${20}`; // Backend
      }
    } else if (this.selectedTable === 'statistics') {
      url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=all&measurement=${this.selectedSensor}&limit=${20}`; // Backend
      this.dataSource = this.mqttService.dataEstadisticas;
      if (this.selectedSensor === 'all') {
        Swal.fire('Error', 'No se pueden consultar estadísticos de todos los sensores.Selecciona uno específico.', 'error');
        return;
      }
    } else if (this.selectedTable === 'predictions') {
      url = `http://localhost:3001/siepa/collections/${this.selectedTable}?attr=all&measurement=${this.selectedSensor}&limit=${20}`; // Backend
      this.dataSource = this.mqttService.dataPredicciones;
      if (this.selectedSensor === 'all') {
        Swal.fire('Error', 'No se pueden consultar predicciones de todos los sensores.Selecciona uno específico.', 'error');
        return;
      }
    }

    this.http.get<any>(url).subscribe({
          next: (response) => {
            // Validar si la respuesta contiene datos
            if (!response || !response.data || response.data.length === 0) {
              Swal.fire('Precaución', 'No se encontraron datos para la consulta.', 'warning');
              return;
            }
            if (table === 'sensor_readings') {
              this.mqttService.dataLecturas = response.data;
              this.dataSource = this.mqttService.dataLecturas;
            } else if (table === 'alerts') {
              this.mqttService.dataAlertas = response.data;
              this.dataSource = this.mqttService.dataAlertas;
            } else if (table === 'statistics') {
              this.mqttService.dataEstadisticas = response.data;
              this.dataSource = this.mqttService.dataEstadisticas;
            } else if (table === 'predictions') {
              this.mqttService.dataPredicciones = response.data.map((prediccion: any, index: number) => ({
                id: index + 1,
                date: prediccion.date,
                time: prediccion.time,
                moving_average: prediccion.moving_average,
                exponential_smoothing: Array.isArray(prediccion.exponential_smoothing)
                  ? prediccion.exponential_smoothing[prediccion.exponential_smoothing.length - 1]
                  : null,
                exponential_smoothing_list: prediccion.exponential_smoothing // Guardamos la lista completa
              }));
            }
            this.displayedColumns = ['id', 'date', 'time', 'moving_average', 'exponential_smoothing', 'detalles'];
            this.dataSource = this.mqttService.dataPredicciones;
            this.actualizarTabla(); // Actualizar la tabla mostrada
            Swal.fire('Éxito', `El comando para sensor ${sensor} y tabla ${table} se ha enviado correctamente.`, 'success');
            console.log('Datos de predicciones:', this.mqttService.dataPredicciones);
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
      if (this.mqttService.lastTable === 'sensor_readings') {
        if (this.selectedSensor === 'all') {
          this.displayedColumns = ['id', 'date', 'time', 'proximity', 'air_quality', 'luminosity', 'humidity', 'temperature', 'pressure'];
          this.dataSource = this.mqttService.dataLecturas;
        } else {
          this.displayedColumns = ['id', 'date', 'time', '_value'];
          this.dataSource = this.mqttService.dataLecturas;
        }
      } else if (this.mqttService.lastTable === 'statistics') {
        this.displayedColumns = ['id', 'date', 'time', 'mean', 'median', 'mode', 'minimum', 'maximum', 'variance', 'standard_deviation'];
        this.dataSource = this.mqttService.dataEstadisticas;
      } else if (this.mqttService.lastTable === 'predictions') {
        this.displayedColumns = ['id', 'date', 'time', 'moving_average', 'exponential_smoothing', 'detalles'];
        this.dataSource = this.mqttService.dataPredicciones;
      } else if (this.mqttService.lastTable === 'alerts') {
        if (this.selectedSensor === 'all') {
          this.displayedColumns = ['id', 'date', 'time', 'type', '_value'];
          this.dataSource = this.mqttService.dataAlertas;   
        } else {
          this.displayedColumns = ['id', 'date', 'time', '_value'];
          this.dataSource = this.mqttService.dataAlertas;
        }
      }
    }
  }
  
  isAllSensorDisabled(): boolean {
    return this.selectedTable === 'statistics' || this.selectedTable === 'predictions';
  }

}
