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
    mov x5, x0          // respaldo original del número para conversión

get_length:
    udiv x2, x2, x3     // x2 = x2 / 10
    add x4, x4, #1      // incrementar longitud
    cmp x2, #0
    bne get_length

    add x1, x1, x4      // apuntar al final del número
    mov w6, #10         // salto de línea '\n'
    strb w6, [x1]       // escribirlo
    sub x1, x1, #1      // retroceder al último dígito
    add x4, x4, #1      // incluir \n en la longitud

    mov x2, x5          // restaurar el número original

get_digit:
    udiv x6, x2, x3             // x6 = x2 / 10
    msub x7, x6, x3, x2         // x7 = x2 - x6 * 10 (dígito)
    add x7, x7, #48             // convertir a ASCII
    strb w7, [x1]               // guardar el carácter
    sub x1, x1, #1
    mov x2, x6
    cmp x2, #0
    bne get_digit

print:
    mov x0, #1                  // stdout
    ldr x1, =output             // puntero al inicio del output
    mov x2, x4                  // longitud total
    mov x8, #64                 // syscall write
    svc #0

    ldp fp, lr, [sp], #16     // Epílogo
    ret
