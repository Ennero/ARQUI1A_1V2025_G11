import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Exit } from './exit';

describe('Exit', () => {
  let component: Exit;
  let fixture: ComponentFixture<Exit>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Exit]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Exit);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
