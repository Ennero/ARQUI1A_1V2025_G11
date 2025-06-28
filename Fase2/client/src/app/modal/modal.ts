import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { NgIf, NgForOf } from '@angular/common';
import { MatDialogContent } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-modal',
  imports: [MatDialogContent, NgIf, NgForOf, MatButtonModule],
  templateUrl: './modal.html',
  styleUrl: './modal.css'
})
export class Modal {
  constructor(@Inject(MAT_DIALOG_DATA) public data: any) {}
}
