.global stdev
.extern variance

.text
stdev: // parametros x0 -> x18 = buffer ; retornos x0 -> x19 = desviación estándar, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    bl variance  // x0 -> x19 = varianza, x1 = contador de números
    scvtf d0, x19//x0 // convertir varianza a float en d0
    fsqrt d0, d0 // calcular la raíz cuadrada de la varianza
    fcvtzs x19, d0 // convertir el resultado de la raíz cuadrada a entero en x0 -> x19

    ldp fp, lr, [sp], #16
    ret
