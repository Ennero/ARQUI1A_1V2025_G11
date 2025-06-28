.global printNum

.section .text
// Values as arguments:
//      x20 -> x0 = space of memory that saves the result
//      x21 -> x1 = #digits
printNum:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // print action
    mov w7, #10
    strb w7, [x0, x1]
    add x1, x1, 1
    mov x3, x1
    mov x4, x0
    
    mov x0, 1
    mov x1, x4
    mov x2, x3
    mov x8, #64
    svc 0

    ldp fp, lr, [sp], #16
    ret
