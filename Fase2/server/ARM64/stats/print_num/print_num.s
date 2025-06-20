.global print_num

.bss
output: .skip 12

.text
print_num:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    ldr x1, =output     // puntero de salida
    mov x2, x0          // copia del número a imprimir
    mov x3, #10         // base decimal
    mov x4, #0          // longitud del número
    mov x6, x0          // respaldo original del número para conversión

get_length:
    udiv x2, x2, x3     // x2 = x2 / 10
    add x4, x4, #1      // incrementar longitud
    cmp x2, #0
    bne get_length

    add x1, x1, x4      // apuntar al final del número
    mov w7, #10         // salto de línea '\n'
    strb w7, [x1]       // escribirlo
    sub x1, x1, #1      // retroceder al último dígito
    add x4, x4, #1      // incluir \n en la longitud

    mov x2, x6          // restaurar el número original

get_digit:
    udiv x7, x2, x3             // x7 = x2 / 10
    msub x8, x7, x3, x2         // x8 = x2 - x7 * 10 (dígito)
    add x8, x8, #48             // convertir a ASCII
    strb w8, [x1]               // guardar el carácter
    sub x1, x1, #1
    mov x2, x7
    cmp x2, #0
    bne get_digit

    add x1, x1, #1              // volver al primer dígito

print:
    mov x0, #1                  // stdout
    ldr x1, =output             // puntero al inicio del output
    mov x2, x4                  // longitud total
    mov x8, #64                 // syscall write
    svc #0

    ldp fp, lr, [sp], #16     // Epílogo
    ret
