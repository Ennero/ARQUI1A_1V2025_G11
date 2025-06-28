import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Calc } from './calc';

describe('Calc', () => {
  let component: Calc;
  let fixture: ComponentFixture<Calc>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Calc]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Calc);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
