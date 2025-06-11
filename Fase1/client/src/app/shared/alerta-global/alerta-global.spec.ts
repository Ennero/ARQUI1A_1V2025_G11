import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AlertaGlobal } from './alerta-global';

describe('AlertaGlobal', () => {
  let component: AlertaGlobal;
  let fixture: ComponentFixture<AlertaGlobal>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AlertaGlobal]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AlertaGlobal);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
