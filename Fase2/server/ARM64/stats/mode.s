.global mode
.extern numbers_array

.text
mode: // parametros x0 = array de números, x1 = tamaño de array ; retornos x0 = moda , x1 = frecuencia
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    ldp fp, lr, [sp], #16
    ret
