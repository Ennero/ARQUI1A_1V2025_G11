.global create_range_buffer

.text
// parametros: x0 = dirección del buffer, x1 = limite inferior, x2 = límite superior
create_range_buffer: // Retorna el buffer con el rango de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // inicializo valores
    ldr x3, =new_buffer // Dirección del buffer
    sub x4, x2, x1      // Rango = límite superior - límite inferior
    mov x5, #0          // Contador de números


.data
new_buffer: .skip 8192