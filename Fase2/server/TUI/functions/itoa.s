.global itoa

.section .bss
asciiValue: .space 30

.section .text
itoa:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // Set setting to reset the asciiValue value
    mov x4, x19             // x4 = x19 = number value returned fron another function
    ldr x20, =asciiValue    // x20 = dir(asciiValue)
    mov x6, #0              // x6 = offset
    mov w7, #0              // constant in reset function
    mov x8, #10             // x8 = 10 (constant)

resetValue:
    cmp x6, #30
    b.ge asciiConverter
    strb w7, [x20, x6]
    add x6, x6, 1
    b resetValue

asciiConverter:
    // set initial values
    mov x9, x4              // copy of the number returned
    mov x6, #0              // set character counter
    mov x21, #0             // x21 = quantity of digits
    b digitsCounter

digitsCounter:
    sdiv x9, x9, x8
    add x21, x21, 1
    cmp x9, #0
    b.eq conditionsSetter
    b digitsCounter

conditionsSetter:
    mov x6, x21             // copy of the quantity of digits

convertionProcess:
    mov x9, x4
    sdiv x9, x9, x8         // 1234/10 = 123
    msub x7, x9, x8, x4    // x7 = 1234 - (123*10) = 1234 - 1230 = 4 (remove last value)
    add x7, x7, #48         // int to ascii
    sub x6, x6, 1
    strb w7, [x20, x6]

    sdiv x4, x4, x8
    cmp x4, #0
    b.eq returnValues
    b convertionProcess

returnValues:
    // x20 = dir(asciiValue)
    // x21 = #digits
    ldp fp, lr, [sp], #16
    ret
