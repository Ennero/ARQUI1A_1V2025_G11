.global convert
.extern itoa
.extern printNum

.section .text
convert:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

openValueTag:
    // arguments: x26 = memory, x27 = word counter, x19 = result
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #108        // 'l'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #114        // 'r'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1


// -------------------------------- add value
    // mov x19, #12345
    bl itoa
    mov x5, #0          // counter

addValue:
    // x26 = dirección de memoria, x27 = contador de digitos, x5 = contador general, x19 = número a guardar
    ldrb w7, [x20, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x21, x21, 1
    cmp x21, 0
    b.eq closeValueTag
    add x5, x5, 1
    b addValue


// -------------------------------- add value
closeValueTag:

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #108        // 'l'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #114        // 'r'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    ldp fp, lr, [sp], #16
    ret

