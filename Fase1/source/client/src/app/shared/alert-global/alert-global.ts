import { Component, Input, Output, EventEmitter } from '@angular/core';
import { NgIf, NgClass } from '@angular/common';
import { MatIcon } from '@angular/material/icon';

@Component({
  selector: 'app-alert-global',
  standalone: true,
  imports: [NgIf, NgClass, MatIcon],
  templateUrl: './alert-global.html',
  styleUrls: ['./alert-global.css']
})
export class AlertGlobal {
  @Input() mensaje: string = '';
  @Input() tipo: 'danger' | 'warning' | 'warning_1' | 'warning_2' | 'warning_3' | 'warning_4' | 'info' | 'success' = 'danger';
  @Input() visible: boolean = false;
  @Output() cerrar = new EventEmitter<void>();
}