.global median
.extern bubble_sort

.text
median: // parametros x0 = array de números ; retornos x0 = mediana, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    bl bubble_sort // x0 = array de números, x1 = contador de números
    lsr x2, x1, #1 // x2 = contador de números / 2
    and x3, x1, #1 // x3 = contador de números % 2

    cmp x3, #0  // comparo
    b.eq even   // si es par, salta a la etiqueta 'even'
    b odd       // si es impar, salta a la etiqueta 'odd'

even:
    ldr w4, [x0, w2, uxtw #2]   // carga el elemento en la posición x2
    sub x2, x2, #1              // decrementa x2 para la siguiente posición
    ldr w5, [x0, w2, uxtw #2]   // carga el siguiente elemento
    add w4, w4, w5              // suma los dos elementos
    lsr w4, w4, #1              // divide la suma por 2 para obtener la mediana
    mov x0, x4                  // mueve el resultado a x0
    b exit

odd:
    ldr w4, [x0, w2, uxtw #2]   // carga el elemento en la posición x2
    mov x0, x4                  // mueve el resultado a x0
    b exit

exit:
    ldp fp, lr, [sp], #16
    ret
    