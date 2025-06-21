.global _start
.extern mean
.extern print_num
.extern sum
.extern variance
.extern sub_var
.extern stdev
.extern mode
.extern numbers_array
.extern median
.extern bubble_sort
.extern minimum
.extern maximum

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
    b.eq do_mean

    cmp w3, #50
    b.eq do_variance

    cmp w3, #51
    b.eq do_stdev

    cmp w3, #52
    b.eq do_mode

    cmp w3, #53
    b.eq do_median

    cmp w3, #54
    b.eq do_max

    cmp w3, #55
    b.eq do_min

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

do_median:
    bl numbers_array // x0 = array de números, x1 = contador de números
    bl median     // x0 = mediana, x1 = contador de números
    bl print_num  // print(x0)
    b exit

do_min:
    // bl numbers_array // x0 = array de números, x1 = contador de números
    // bl bubble_sort // ordenar el array | x0 = array de números, x1 = contador de números
    // ldr w0, [x0]  // cargar el primer elemento (minimo)
    // bl print_num  // print(x0)
    // b exit
    bl minimum
    b exit

do_max:
    // bl numbers_array // x0 = array de números, x1 = contador de números
    // bl bubble_sort // ordenar el array | x0 = array de números, x1 = contador de números
    // sub w1, w1, #1 // x1 = contador de números - 1
    // ldr w0, [x0, w1, uxtw  #2] // cargar el último elemento (maximo)
    // bl print_num  // print(x0)
    bl minimum
    b exit


exit:
    mov x0, #0
    mov x8, #93
    svc #0
