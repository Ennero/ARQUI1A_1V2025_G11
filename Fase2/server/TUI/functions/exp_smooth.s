.global exp_smooth
.extern itoa
// .extern print
.extern convert
.extern printNum

.text
exp_smooth: // x0 = array de numeros, x1 = tamaño del array
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x14//x1      // array de números
    mov x3, x13//x1      // tamaño del array
    mov x5, #0           // índice i
    mov x7, #0      // At-1
    mov x8, #0      // Ft-1
    mov x10, #300   // a = 0.3 (escalado 1000)
    mov x11, #1000  // escala

loop:
    cmp x5, x3
    b.ge exit



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
    // Guardar registros en el stack (x2–x9)
    sub sp, sp, #64         // Reservar espacio para 8 registros (8 x 8 bytes)
    stp x2, x3, [sp, #0]
    stp x4, x5, [sp, #16]
    stp x6, x7, [sp, #32]
    stp x8, x9, [sp, #48]

    // Llamar a itoa y print
    mov x19, x9              // Ft
    bl itoa
    bl printNum


    // Restaurar registros desde el stack
    ldp x2, x3, [sp, #0]
    ldp x4, x5, [sp, #16]
    ldp x6, x7, [sp, #32]
    ldp x8, x9, [sp, #48]
    add sp, sp, #64         // Liberar espacio del stack

    // Continuar con el cálculo
    mov x7, x6              // At-1 = At
    mov x8, x9              // Ft-1 = Ft
    add x5, x5, #1
    b loop

exit:
    ldp fp, lr, [sp], #16
    ret
    