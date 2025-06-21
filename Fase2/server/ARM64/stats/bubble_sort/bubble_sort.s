.global bubble_sort

.text
bubble_sort: // parametros x0 = array de números, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov w3, w1          // tamaño del array
    mov w4, #0          // índice externo (i)
    mov w5, #0          // índice interno (j)
    mov w6, #0          // bandera de intercambio

    cmp w3, #1          // si el tamaño es 1 o menos, no hay nada que ordenar
    b.le end_loop       // si es 1 o menos, saltar al final

    sub w7, w3, #1      // ajustar el tamaño para el bucle
    mov w11, w7         // guardar tamaño para inner loop

loop:
    cmp w4, w11      // comparar índice externo con el tamaño ajustado
    b.ge end_loop   // si i >= tamaño - 1, salir del bucle

    mov w6, #0      // reiniciar la bandera de intercambio
    mov w5, #0      // reiniciar el índice interno (j)
    mov w10, #0

    loop_inner:
        mov w5, w10
        cmp w5, w7                  // comparar índice interno con el tamaño del array
        b.ge next_outer             // si j >= tamaño - 1, ir al siguiente índice externo

        ldr w8, [x0, w5, uxtw #2]   // cargar el elemento actual (j)
        add w10, w5, #1             // es j+1
        ldr w9, [x0, w10, uxtw #2]  // cargar el siguiente elemento (j + 1)

        cmp w8, w9                  // comparar los dos elementos
        b.le loop_inner             // si el elemento actual es menor o igual al siguiente, no hacer swap

        // si el elemento actual es mayor que el siguiente, hacer swap
        str w9, [x0, w5, uxtw #2]   // almacenar el siguiente elemento en la posición actual
        str w8, [x0, w10, uxtw #2]  // almacenar el elemento actual en la siguiente posición
        mov w6, #1                  // establecer la bandera de intercambio

        b loop_inner                // volver al inicio del bucle interno

    next_outer:
        cmp w6, #0                  // verificar si se hizo algún intercambio
        b.eq end_loop               // si no se hizo ningún intercambio, salir del bucle externo
        add w4, w4, #1              // incrementar el índice externo (i)
        sub w7, w7, #1              // reducir el tamaño del bucle interno
        b loop                      // volver al inicio del bucle externo
    
end_loop:

    ldp fp, lr, [sp], #16
    ret
