import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AlertGlobal } from './alert-global';

describe('AlertGlobal', () => {
  let component: AlertGlobal;
  let fixture: ComponentFixture<AlertGlobal>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AlertGlobal]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AlertGlobal);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
