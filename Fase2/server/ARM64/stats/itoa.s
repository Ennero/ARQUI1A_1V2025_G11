.global itoa

.bss
output: .skip 8

.text
itoa: // parametros x0 = número a convertir; retornos x0 = puntero al string de salida, x1 = longitud del string
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x0          // copia del número a convertir
    ldr x0, =output     // puntero de salida
    mov x3, #10         // base decimal
    mov x1, #0          // longitud del string
    mov x4, x2          // respaldo original del número para conversión

get_length:
    udiv x2, x2, x3     // x2 = x2 / 10
    add x1, x1, #1      // incrementar longitud
    cmp x2, #0
    bne get_length

    add x0, x0, x1      // apuntar al final del número
    mov w5, #10         // salto de línea '\n'
    strb w5, [x0]       // escribirlo
    sub x0, x0, #1      // retroceder al último dígito
    add x1, x1, #1      // incluir \n en la longitud

    mov x2, x4          // restaurar el número original

get_digit:
    udiv x5, x2, x3         // x5 = x2 / 10
    msub x6, x5, x3, x2     // x6 = x2 - x5 * 10 (dígito)
    add x6, x6, #48         // convertir a ASCII
    strb w6, [x0]           // guardar el carácter
    sub x0, x0, #1          // retroceder al puntero
    mov x2, x5              // actualizar x2 con el dígito
    cmp x2, #0              // verificar si quedan dígitos
    bne get_digit

exit:
    add x0, x0, #1          // ajustar el puntero al inicio del string
    ldp fp, lr, [sp], #16   // Epílogo
    ret
