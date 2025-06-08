import { Component } from '@angular/core';
import { Header } from '../shared/header/header';
import { MatCardModule } from '@angular/material/card';
import { NgClass, NgIf } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-exit',
  standalone: true,
  imports: [Header, MatCardModule, NgClass, NgIf, MatIconModule],
  templateUrl: './exit.html',
  styleUrls: ['./exit.css']
})
export class Exit {

  temperaturaCritica = false;
  humedadCritica = false;
  iluminacionCritica = false;
  aireCritico = false;

  // Simulación para encender las leds
  ngOnInit() {

    const temperatura = 29; // Simulación de temperatura
    this.temperaturaCritica = temperatura > 29;
    
    const humedad = 80; // Simulación de humedad
    this.humedadCritica = humedad > 70;

    const iluminacion = 1000; // Simulación de iluminación
    this.iluminacionCritica = iluminacion < 500;

    const aire = 1500; // Simulación de aire
    this.aireCritico = aire > 1000;
  }

}
