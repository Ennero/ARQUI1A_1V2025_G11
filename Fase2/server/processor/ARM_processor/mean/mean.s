.global _start

.section .bss
buffer:     .skip 1024

.section .text
_start:
    mov x0, 0              // fd 0 = stdin
    ldr x1, =buffer        // buffer destino
    mov x2, 1024           // bytes a leer
    mov x8, 63             // syscall number for read (Linux AArch64)
    svc #0                 // syscall

    // valor de retorno: x0 = bytes leídos
    mov x2, x0             // guardar cantidad en x1

    // escribir en stdout
    mov x0, 1              // fd 1 = stdout
    ldr x1, =buffer        // contenido
    mov x2, x2             // cantidad de bytes
    mov x8, 64             // syscall number for write (Linux AArch64)
    svc #0

    // exit(0)
    mov x0, 0
    mov x8, 93             // syscall number for exit
    svc #0