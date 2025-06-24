.global minimum

.text
minimum: // parametros x18 = buffer ; retornos x19 = minimo, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // Declaración de variables iniciales
    mov x2, x18              // x2 = dir(buffer) --> esta es la que se irá modificando
    mov x19, #0              // x19 = numero más pequeño
    mov x3, #0              // x3 = numero en binario
    mov x4, #10             // x4 = constante 10
    mov x1, #0              // x1 = contador de números

parse_number:
    ldrb w5, [x2]          // leer byte del buffer
    cmp w5, #36            // es '$'?
    b.eq returnMinimumNumber// si es '$', returnMinimumNumber
    cmp w5, #10            // es '\n'?
    b.eq compareNumber

    sub w5, w5, #48       // convertir de ASCII a número
    mul x3, x3, x4          // x3 *= 10
    add x3, x3, x5         // x3 += dígito
    add x2, x2, 1           // apunta al siguiente dígito
    b parse_number

compareNumber:
    cmp x1, #0
    csel x19, x3, x19, eq // si es el primero, x19 = x3 (mínimo = primer número)

    cmp x3, x19
    csel x19, x3, x19, lt // si x3 < x19, x19 = x3 (actualizar mínimo)

    add x1, x1, 1           // #words = #words + 1
    add x2, x2, 1           // move to next number
    mov x3, #0              // x3 = 0 --> vuelve a su valor inicial
    b parse_number

returnMinimumNumber:
    ldp fp, lr, [sp], #16
    ret
