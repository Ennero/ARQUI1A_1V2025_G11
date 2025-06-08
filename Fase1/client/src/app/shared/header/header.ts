import { Component } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';


@Component({
  selector: 'app-header',
  imports: [MatToolbarModule, MatIconModule, RouterModule],
  templateUrl: './header.html',
  styleUrls: ['./header.css']
})
export class Header {
}
