.global _start
.extern mean
.extern print_num
.extern sum
.extern variance
.extern sub_var
.extern stdev
.extern mode
.extern numbers_array

.bss
buffer: .skip 8192

.text
_start:
    mov x0, #0
    ldr x1, =buffer
    mov x2, #8192
    mov x8, #63
    svc #0

    mov x5, sp
    ldr x2, [x5, #16]
    ldrb w3, [x2]

    ldr x0, =buffer

    cmp w3, #49
    beq do_mean

    cmp w3, #50
    beq do_variance

    cmp w3, #51
    beq do_stdev

    cmp w3, #52
    beq do_mode

    b exit

do_mean:
    bl mean      // x0 = media, x1 = contador de números
    bl print_num // print(x0)
    b exit

do_variance:
    bl variance  // x0 = varianza, x1 = contador de números
    bl print_num // print(x0)
    b exit

do_stdev:
    bl stdev     // x0 = desviación estándar, x1 = contador de números
    bl print_num // print(x0)
    b exit

do_mode:
    bl numbers_array // x0 = array de números, x1 = contador de números
    bl mode      // x0 = moda, x1 = contador de números
    bl print_num // print(x0)
    b exit

exit:
    mov x0, #0
    mov x8, #93
    svc #0
