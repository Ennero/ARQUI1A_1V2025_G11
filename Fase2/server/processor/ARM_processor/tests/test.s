.global _start

.section .bss
buffer: .skip 1024
numSalida: .space 5

.section .data
noDataMsg: .asciz "There is no data in stdin\n"

.section .text
_start:
    mov x0, 0              // fd 0 = stdin
    ldr x1, =buffer        // buffer destino
    mov x2, 1024           // bytes a leer
    mov x8, 63             // syscall number for read (Linux AArch64)
    svc #0                 // syscall
    mov x24, 0

//     // Declarar variables para analisis de numeros
//     mov x20, x0             // cantidad de bytes
//     mov x21, 0              // contador bytes usados
//     mov x22, 0              // contador palabras
//     mov x23, 0              // contador digitos
//     mov x24, 1              // multiplicador de dígito
//     mov x25, 0              // suma de numeros

// obtenerCantDigitos:
    
//     bl


    mov x0, 1
    ldr x1, =buffer
    mov x2, 1024
    mov x8, 64
    svc 0

    mov x8, #93
    svc 0