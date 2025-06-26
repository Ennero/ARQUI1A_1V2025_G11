.global numbers_array

.bss
numbers: .skip 4096

.text
numbers_array: // parametros x0 = buffer ; retornos x0 = array de numeros, x1 = tamaño del array
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x2, x0          // apuntador al buffer
    ldr x0, =numbers    // apuntador al array de números
    mov x1, #0          // tamaño del array
    mov w3, #0          // x3 = acumulador del número actual
    mov w4, #10         // base decimal
    mov w5, #0          // índice del array

loop:
    ldrb w6, [x2]   // cargar el primer byte del buffer
    cmp w6, #36     // es '$'?
    beq end_loop    // si es '$', terminar
    cmp w6, #10     // es '\n'?
    beq store_number

    sub w6, w6, #48 // convertir de ASCII a número
    mul w3, w3, w4  // w3 = w3 * 10
    add w3, w3, w6  // w3 += dígito actual
    add x2, x2, #1  // avanzar al siguiente dígito
    b loop

store_number:
    add x7, x0, w5, uxtw #2 // calcular la dirección del número en el array
    str w3, [x7]            // almacenar el número actual en el array
    add w5, w5, #1          // incrementar el índice del array
    add x1, x1, #1          // incrementar contador
    add x2, x2, #1          // avanzar a la siguiente línea
    mov w3, #0              // reiniciar el acumulador
    b loop

end_loop:
    ldp fp, lr, [sp], #16
    ret
