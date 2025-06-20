.global mean
.extern sum

.text
mean: // retornos x0 = media, x1 = contador de números
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    bl sum
    sdiv x0, x0, x1  // x0 = suma total / contador de números

    ldp fp, lr, [sp], #16     // Epílogo
    ret
