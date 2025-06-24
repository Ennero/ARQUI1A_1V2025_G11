.global mode
.extern numbers_array

.text
mode: // parametros x22 = array de números, x1 = tamaño de array ; retornos x19 = moda , x1 = frecuencia
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x22 // array de números
    mov x19, #0 // moda
    mov w3, #0 // indice i
    mov w4, w17 // tamaño del array
    mov x1, #0 // frecuencia máxima
    
outer_loop:
    cmp w3, w4
    b.ge exit // si i >= tamaño del array, salimos
    // mientras i < tamaño del array hacer el outer_loop

    ldr w5, [x2, w3, uxtw #2]   // cargar el numero actual en la posición i
    mov x6, #0 // indice j
    mov x7, #0 // frecuencia actual

inner_loop:
    cmp w6, w4
    b.ge check_mode // si j >= tamaño del array, salimos del bucle interno
    // mientras j < tamaño del array hacer el inner_loop

    ldr w8, [x2, w6, uxtw #2]   // cargar el numero actual en la posición j
    cmp w5, w8 // comparar el número en la posicion i con el número en la posición j
    bne skip_inc // si son diferentes, saltamos

    add w7, w7, #1 // si son iguales, incrementamos la frecuencia actual

skip_inc:
    add w6, w6, #1 // incrementar el índice j
    b inner_loop // volver al inicio del bucle interno

check_mode:
    cmp w7, w1 // comparar la frecuencia actual con la frecuencia máxima
    csel w1, w7, w1, gt // si la frecuencia actual es mayor, actualizar la frecuencia máxima
    csel w19, w5, w19, gt // si la frecuencia actual es mayor, actualizar la moda
    add w3, w3, #1 // incrementar el índice i
    b outer_loop // volver al inicio del bucle externo

exit:
    ldp fp, lr, [sp], #16
    ret
