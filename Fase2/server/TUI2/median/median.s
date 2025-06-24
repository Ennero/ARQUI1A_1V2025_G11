.global median
.extern bubble_sort

.text
median: // parametros x22 = array de números ; retornos x0 = mediana, x17 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    bl bubble_sort // x22 = array de números, x17 = contador de números
    lsr x2, x17, #1 // x2 = contador de números / 2
    and x3, x17, #1 // x3 = contador de números % 2

    cmp x3, #0  // comparo
    b.eq even   // si es par, salta a la etiqueta 'even'
    b odd       // si es impar, salta a la etiqueta 'odd'

even:
    ldr w4, [x22, w2, uxtw #2]   // carga el elemento en la posición x2
    sub x2, x2, #1              // decrementa x2 para la siguiente posición
    ldr w5, [x22, w2, uxtw #2]   // carga el siguiente elemento
    add w4, w4, w5              // suma los dos elementos
    lsr w4, w4, #1              // divide la suma por 2 para obtener la mediana
    mov x19, x4                  // mueve el resultado a x0
    b exit

odd:
    ldr w4, [x22, w2, uxtw #2]   // carga el elemento en la posición x2
    mov x19, x4                  // mueve el resultado a x0
    b exit

exit:
    ldp fp, lr, [sp], #16
    ret
    