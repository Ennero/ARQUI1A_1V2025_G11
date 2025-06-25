.global readfile

.section .data
readfileSectionWelcome: .asciz "\n\n==== BIENVENIDO A LA FUNCIONALIDAD LEER ARCHIVO ====\n"
readfileSectionWelcomeEnd: // end of readfileSectionWelcome
.equ readfileSectionWelcomeLen, readfileSectionWelcomeEnd - readfileSectionWelcome  // length

fileNameRequest: .asciz "\nIngrese el nombre del archivo: " // msg
fileNameRequestEnd: // end of fileNameRequest
.equ fileNameRequestLen, fileNameRequestEnd - fileNameRequest // length

fileError: .asciz "***** NO SE ENCONTRÓ EL ARCHIVO *****\n"
fileErrorEnd: // end of fileError
.equ fileErrorLen, fileErrorEnd - fileError // length

.section .bss
fileName: .space 30
//buffer: .skip 8192
buffer: .skip 42000

.section .text
readfile:

    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // Print welcome msg
    mov x0, #1
    ldr x1, =readfileSectionWelcome
    mov x2, readfileSectionWelcomeLen
    mov x8, #64
    svc 0

    // Request file name text
    mov x0, #1
    ldr x1, =fileNameRequest
    mov x2, fileNameRequestLen
    mov x8, #64
    svc 0

    // file name request
    mov x0, #0
    ldr x1, =fileName
    mov x2, #30
    mov x8, #63
    svc 0

    mov x5, #0           // x5 = word counter
    ldr x6, =fileName   // x6 = dir(fileName)

findLineBreak:
    ldrb w7, [x6]
    cmp w7, #10
    b.eq deleteLineBreak
    add x6, x6, 1
    add x5, x5, 1
    b findLineBreak

deleteLineBreak:
    mov w9, #0
    ldr x4, =fileName
    strb w9, [x4, x5]

openFile:
    mov x0, -100
    ldr x1, =fileName
    mov x2, #0
    mov x8, #56
    svc #0
    mov x9, x0

    cmp x9, #0 // Check if file opened successfully
    b.lt error

    mov x0, x9
    ldr x1, =buffer
    //mov x2, 8192        // size address
    mov x2, 42000        // size address
    mov x8, 63          // read
    svc 0               // syscall

    mov x1, x0          // x1 = number of bytes read
    ldr x18, =buffer     // return dir(buffer)
    mov x0, x18         // x0 = dir(buffer)

    ldp fp, lr, [sp], #16
    ret

error:
    mov x0, #1          // file descriptor stdout
    ldr x1, =fileError  // direccion mensaje error
    mov x2, fileErrorLen // longitud mensaje error
    mov x8, #64         // syscall_num write
    svc 0               // llamada al sistema

    mov x0, #-1          // Return 0 on error
    ldp fp, lr, [sp], #16
    ret

