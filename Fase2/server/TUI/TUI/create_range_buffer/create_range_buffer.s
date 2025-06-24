.global create_range_buffer

.bss
new_buffer: .skip 8192 // Buffer para guardar el resultado filtrado

.text
// x0: Puntero al buffer de texto original
// x1: Número total de bytes en el buffer original
// x2: Número de la línea de INICIO del rango (ej: 5)
// x3: Número de la línea de FIN del rango (ej: 10)

// x0: Puntero al new_buffer con el texto filtrado
// x1: Número de bytes en el new_buffer
create_range_buffer:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    ldr x4, =new_buffer     // x4 = Puntero de escritura para el nuevo buffer
    mov x5, #0              // x5 = Índice de lectura (para el buffer original)
    mov x6, #0              // x6 = Índice de escritura (para el nuevo buffer)
    mov x8, #0              // x8 = Contador de línea actual, empezamos en la línea 1

skip_loop:
    cmp x8, x2              // Comparar línea_actual con línea_inicio
    b.ge copy_loop          // Empezar a copiar

    cmp x5, x1              // Si se llegó a la longitud del buffer original
    b.ge add_terminator     // Coloco el valor de terminación
    
    ldrb w7, [x0, x5]       // Leer un carácter del buffer original

    cmp w7, #10             // si es salto de linea
    b.ne not_a_newline_skip

    add x8, x8, #1          // Incrementar el contador de línea actual


not_a_newline_skip:
    add x5, x5, #1       // Avanzar el índice de lectura
    b skip_loop          // Repetir hasta que se alcance la línea de inicio


copy_loop:
    cmp x8, x3           //  Comparar línea_actual con línea_fin
    b.gt add_terminator  // Terminado

    cmp x5, x1           // Si se llegó a la longitud del buffer original
    b.ge add_terminator  // Si es así, terminar.

    ldrb w7, [x0, x5]    // Leer un carácter del buffer original
    strb w7, [x4, x6]    // Escribir ese mismo carácter en el nuevo buffer

    cmp w7, #10          // Verificar si es un salto de línea
    b.ne not_a_newline_copy
    add x8, x8, #1       // Incrementar el contador de línea actual


not_a_newline_copy:
    add x5, x5, #1          // Mover puntero de lectura
    add x6, x6, #1          // Mover puntero de escritura
    b copy_loop


add_terminator:
    mov w7, #'$'            // Carácter de terminación '$'
    strb w7, [x4, x6]       // Escribirlo al final del nuevo buffer
    add x6, x6, #1          // Incrementar el tamaño para incluir el '$'


prepare_return:
    mov x0, x4              // Retorno 1 (x0): puntero al new_buffer
    mov x1, x6              // Retorno 2 (x1): número de bytes en el new_buffer





    ldp fp, lr, [sp], #16
    ret

    