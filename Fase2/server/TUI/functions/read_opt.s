.global read_opt

.text
read_opt: // Retorna el entero leído en x0
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // Leer la entrada del usuario
    mov x0, #0              // file descriptor stdin 
    ldr x1, =input_buffer   // buffer input
    mov x2, #12             // tamaño del buffer
    mov x8, #63             // syscall para leer
    svc #0

    // Convertir el string leído a un entero
    mov x0, #-1             // x0 = acumulador del entero
    ldr x1, =input_buffer   // Puntero para recorrer el string
    mov x10, #10            // Constante para multiplicar

convert_loop:

    ldrb w3, [x1], #1 // Leer un byte del buffer y avanzar el puntero

    cmp w3, #'0'      // Verificar si es un dígito
    b.lt end_convert  // Si es menor que '0', terminar la conversión

    cmp w3, #'9'      // Verificar si es mayor que '9'
    b.gt end_convert  // Si es mayor que '9', terminar la conversión

    cmp x0, #-1
    b.ne process_digit // Si x0 no es -1, procesar el dígito
    mov x0, #0         // Si es -1, inicializar el acumulador


process_digit:
    sub w3, w3, #'0'  // Convertir el carácter ASCII a número
    mul x0, x0, x10   // Multiplicar el acumulador por 10
    add x0, x0, x3    // Sumar el dígito actual
    
    b convert_loop

end_convert:
    ldp fp, lr, [sp], #16
    ret


.bss
input_buffer: .space 12 // Un buffer dedicado para esta función
