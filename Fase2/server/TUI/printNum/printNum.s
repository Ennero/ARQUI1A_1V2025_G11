.global printNum

.section .text
// Values as arguments:
//      x20 = space of memory that saves the result
//      x21 = #digits
printNum:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // print action
    mov w7, #10
    strb w7, [x20, x21]
    add x21, x21, 1
    
    mov x0, 1
    mov x1, x20
    mov x2, x21
    mov x8, #64
    svc 0

    ldp fp, lr, [sp], #16
    ret
