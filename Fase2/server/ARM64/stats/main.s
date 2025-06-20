.global _start
.extern mean
.extern print_num
.extern sum

.bss
buffer: .skip 4096

.text
_start:
    mov x0, #0
    ldr x1, =buffer
    mov x2, #1024
    mov x8, #63
    svc #0

    mov x5, sp
    ldr x2, [x5, #16]
    ldrb w3, [x2]
    cmp w3, #49
    beq do_mean

    b exit

do_mean:
    ldr x2, =buffer
    bl mean
    bl print_num
    b exit

exit:
    mov x0, #0
    mov x8, #93
    svc #0
