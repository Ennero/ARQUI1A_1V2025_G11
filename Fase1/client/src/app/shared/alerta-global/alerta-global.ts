import { Component,Input, Output, EventEmitter } from '@angular/core';
import { NgIf, NgClass } from '@angular/common';
import { MatIcon } from '@angular/material/icon';

@Component({
  selector: 'app-alerta-global',
  imports: [NgIf, NgClass, MatIcon],
  templateUrl: './alerta-global.html',
  styleUrls: ['./alerta-global.css']
})
export class AlertaGlobal {
  @Input() mensaje: string = '';
  @Input() tipo: 'danger' | 'warning' | 'warning_1' | 'warning_2' | 'warning_3' | 'warning_4' | 'info' | 'success' = 'danger';
  @Input() visible: boolean = false;
  @Output() cerrar = new EventEmitter<void>();
}
