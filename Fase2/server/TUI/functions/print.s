.global print

.text
print: // parámetros x0 = cadena a imprimir; x1 = longitud de la cadena; // retorno: x0 = 0 (éxito)
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x1  // longitud de la cadena
    mov x1, x0  // puntero a la cadena
    mov x0, #1  // stdout
    mov x8, #64 // syscall write
    svc #0      // llamada al sistema para escribir

    mov x0, #0  // retorno: éxito (0)

    ldp fp, lr, [sp], #16   // Epílogo
    ret
