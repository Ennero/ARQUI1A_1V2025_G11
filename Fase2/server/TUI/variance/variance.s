.global variance
.extern sub_var

.text
variance: // parametros x0 = buffer ; retornos x0 = varianza, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // mov x19, x0     // apuntador al buffer
    bl mean         // x0 -> x19 = promedio, x1 = contador de números
    mov x20, x1     // guardar el contador de números en x20
    mov x1, x19// x0      // guardar el promedio en x1
    // mov x0, x19     // apuntador al buffer de nuevo
    bl sub_var      // x0 -> x19 = sumatoria total de varianza
    mov x1, x20     // restaurar el contador de números
    sdiv x19, x19, x1 // x0 -> x19 = varianza = sumatoria total / contador de números

    ldp fp, lr, [sp], #16
    ret
