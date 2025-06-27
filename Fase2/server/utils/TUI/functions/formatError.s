.global formatError

.section .data
    msg: .asciz "\n\n***** FORMATO DE ARCHIVO INCORRECTO *****\n"
    msgEnd: // end of fileError
    .equ msgLen, msgEnd - msg // length

.section .text
formatError:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x0 // Buffer
    mov x3, #0 // bandera de $

error_loop:
    ldrb w3, [x2], #1

    cmp w3, #36 // Check for '$'
    beq exit

    cmp w3, #48
    b.lt error_exit
    cmp w3, #57
    b.gt error_exit
    
number_loop:
    ldrb w3, [x2], #1

    cmp w3, #10
    beq error_loop

    cmp w3, #48
    b.lt error_exit
    cmp w3, #57
    b.gt error_exit

    b number_loop

error_exit:
    mov x0, #1          // file descriptor stdout
    ldr x1, =msg  // direccion mensaje error
    mov x2, msgLen // longitud mensaje error
    mov x8, #64         // syscall_num write
    svc 0               // llamada al sistema

    mov x0, #-1

exit:
    ldp fp, lr, [sp], #16
    ret
