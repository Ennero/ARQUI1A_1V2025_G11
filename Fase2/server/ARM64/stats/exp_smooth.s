.global exp_smooth
.extern itoa

.bss
smooth: .skip 8192

.text
exp_smooth: // x0 = array de numeros, x1 = tamaño del array ; x0 = buffer del suavizado, x1 = tamaño del buffer
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x0      // apuntador al array de números
    mov x3, x1      // tamaño del array
    mov x4, #0      // longitud de smooth
    mov x5, #0      // indice i del array de números
    mov x6, #0      // At (valor actual)
    mov x7, #0      // At-1 (valor previo)
    mov x8, #0      // Ft-1 (valor suavizado previo)
    mov x9, #0      // Ft (valor suavizado actual)
    ldr x11, =smooth // apuntador al buffer de suavizado
    mov x10, #300   // a = 0.3 (factor de suavizado)
    mov x12, #1000 // factor de escala para evitar decimales

loop:
    cmp x5, x3      // comparar i con el tamaño del array
    bge exit        // si i >= tamaño del array, salir

    // mientras i < tamaño del array hacer

    ldr w6, [x2, w5, uxtw #2] // w9 = At
    cmp w5, #0 // si i es 0, no hay suavizado previo
    bne calc_smooth // si i es 0, saltar a copy

    mov x9, x6
    b copy

calc_smooth:
    sub w9, w7, w8 // w9 = At-1 - Ft-1
    mul w9, w9, w10 // w9 = a (At-1 - Ft-1) * 1000
    sdiv w9, w9, w12 // w9 = a (At-1 - Ft-1)
    add w9, w8, w9 // w9 = Ft = Ft-1 + a (At-1 - Ft-1)

copy:
    mov x19, x2
    mov x20, x3
    mov x21, x4
    mov x22, x5
    mov x23, x6
    mov x24, x7
    mov x25, x8
    mov x26, x9
    mov x0, x9
    bl itoa // x0 = puntero al string de salida, x1 = longitud del string
    mov x2, x19
    mov x3, x20
    mov x4, x21
    mov x5, x22
    mov x6, x23
    mov x7, x24
    mov x8, x25
    mov x9, x26
    add x4, x4, x1 // longitud del string de salida

copy_loop:
    cbz x1, done_copy // si x1 es 0, salir del bucle
    ldrb w7, [x0], 1
    strb w7, [x11], 1 // copiar el byte al buffer de suavizado
    sub x1, x1, #1 // decrementar el tamaño del array
    b copy_loop

done_copy:
    mov w8, w9 // Ft-1 = Ft
    mov w7, w6 // At-1 = At
    add w5, w5, #1 // incrementar el índice i
    b loop

exit:
    ldr x0, =smooth // apuntar x0 al buffer de suavizado
    mov x1, x4      // tamaño del buffer de suavizado
    ldp fp, lr, [sp], #16
    ret
