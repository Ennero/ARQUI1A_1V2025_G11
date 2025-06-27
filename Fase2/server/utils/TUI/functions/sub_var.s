.global sub_var

.text
sub_var: // parametros x0 --> x18 = buffer, x1 = promedio ; retornos x0 -> x19 = sumatoria total
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x18 //x0      // apuntador al buffer
    mov x19, #0      // sumtoria total
    mov x3, #0      // x3 = acumulador del número actual
    mov x4, #10     // base decimal

loop:
    ldrb w5, [x2]   // cargar el primer byte del buffer
    cmp w5, #36     // es '$'?
    beq end_loop    // si es '$', terminar
    cmp w5, #10     // es '\n'?
    beq skip_loop

    sub w5, w5, #48 // convertir de ASCII a número
    mul x3, x3, x4  // x3 = x3 * 10
    add x3, x3, x5  // x3 += dígito actual
    add x2, x2, #1  // avanzar al siguiente digito
    b loop

skip_loop:
    add x2, x2, #1  // avanzar a la siguiente línea
    sub x6, x3, x1  // x6 = x_i - promedio
    mul x6, x6, x6  // x6 = (x_i - promedio)^2
    add x19, x19, x6  // sumamos al total
    mov x3, #0      // reiniciar el acumulador para el siguiente número
    b loop

end_loop:
    ldp fp, lr, [sp], #16
    ret
