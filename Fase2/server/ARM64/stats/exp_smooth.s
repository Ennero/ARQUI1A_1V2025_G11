.global exp_smooth
.extern itoa
.extern print

.text
exp_smooth: // x0 = array de numeros, x1 = tamaño del array
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x0      // array de números
    mov x3, x1      // tamaño del array
    mov x5, #0      // índice i
    mov x7, #0      // At-1
    mov x8, #0      // Ft-1
    mov x10, #300   // a = 0.3 (escalado 1000)
    mov x11, #1000  // escala

loop:
    cmp x5, x3
    bge exit

    ldr w6, [x2, w5, uxtw #2]   // At
    cmp x5, #0
    bne calc_smooth

    // Primera iteración: Ft = At
    mov x9, x6
    b print_smooth

calc_smooth:
    sub w9, w7, w8      // At-1 - Ft-1
    mul w9, w9, w10     // * a (escalado)
    sdiv w9, w9, w11    // / 1000
    add w9, w8, w9      // Ft = Ft-1 + a (At-1 - Ft-1)

print_smooth:
    mov x19, x2
    mov x20, x3
    mov x21, x5
    mov x22, x6
    mov x23, x7
    mov x24, x8
    mov x25, x9

    mov x0, x9
    bl itoa      // x0 = ptr, x1 = len
    bl print     // imprimir string

    mov x2, x19
    mov x3, x20
    mov x5, x21
    mov x6, x22
    mov x7, x23
    mov x8, x24
    mov x9, x25

    mov x7, x6    // At-1 = At
    mov x8, x9    // Ft-1 = Ft
    add x5, x5, #1
    b loop

exit:
    ldp fp, lr, [sp], #16
    ret
