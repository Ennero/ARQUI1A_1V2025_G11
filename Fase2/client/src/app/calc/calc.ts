import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { FormsModule } from '@angular/forms';
import { NgForOf } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import Swal from 'sweetalert2';


@Component({
  selector: 'app-calc',
  standalone: true,
  imports: [Header, MatCardModule, MatSelectModule, MatButtonModule, FormsModule, NgForOf, HttpClientModule],
  templateUrl: './calc.html',
  styleUrls: ['./calc.css']
})
export class Calc {
  constructor(private http: HttpClient) {}
  sensorTypes = [
    { value: 'proximity', viewValue: 'Proximidad' },
    { value: 'air_quality', viewValue: 'Aire' },
    { value: 'luminosity', viewValue: 'Iluminación' },
    { value: 'humidity', viewValue: 'Humedad' },
    { value: 'temperature', viewValue: 'Temperatura' },
    { value: 'pressure', viewValue: 'Presión' },
  ];

  selectedSensor = '';

  onSend(){
    console.log('Enviando datos para el sensor:', this.selectedSensor);
    // Url del servidor al que se enviará el comando
    const url = `http://172.20.10.2:5000/siepa/devices/${this.selectedSensor}`; // Backend
    const sensor = this.selectedSensor;

    this.http.put(url, { sensor: sensor }).subscribe({
          next: (response) => {
            console.log('Comando enviado exitosamente:', response);
            Swal.fire('Éxito', `El comando para sensor ${sensor} se ha enviado correctamente.`, 'success');
          },
          error: (error) => {
            console.error('Error al enviar el comando:', error);
            Swal.fire('Error', 'No se pudo enviar el comando. Inténtelo de nuevo más tarde.', 'error');
          }
        });
  }
}
