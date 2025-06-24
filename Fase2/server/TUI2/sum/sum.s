.global sum

.text
sum: // parametros x18 = buffer ; retornos x19 = suma total, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x18      // apuntador al buffer
    mov x19, #0      // suma total
    mov x1, #0      // contador de números
    mov x3, #0      // x3 = acumulador del número actual
    mov x4, #10     // base decimal

loop:
    ldrb w5, [x2]   // cargar el primer byte del buffer
    cmp w5, #36     // es '$'?
    beq end_loop    // si es '$', terminar
    cmp w5, #10     // es '\n'?
    beq skip_loop

    sub w5, w5, #48 // convertir de ASCII a número
    uxtb x5, w5     // extender
    mul x3, x3, x4  // x3 = x3 * 10
    add x3, x3, x5  // x3 += dígito actual
    add x2, x2, #1  // avanzar al siguiente digito
    b loop

skip_loop:
    add x1, x1, #1  // incrementar contador
    add x2, x2, #1  // avanzar a la siguiente línea
    add x19, x19, x3  // sumar el número actual a la suma total
    mov x3, #0      // reiniciar el acumulador para el siguiente número
    b loop

end_loop:
    ldp fp, lr, [sp], #16
    ret
