.global _start

.section .bss
buffer: .skip 1024
numSalida: .space 6

.section .data
noDataMsg: .asciz "There is no data in stdin\n"

.section .text
_start:
    mov x0, 0              // fd 0 = stdin
    ldr x1, =buffer        // buffer destino
    mov x2, 1024           // bytes a leer
    mov x8, 63             // syscall number for read (Linux AArch64)
    svc #0                 // syscall

    // Declarar variables para analisis de numeros
    //mov x20, x0             // cantidad de bytes
    //mov x21, 0              // contador bytes usados
    mov x22, 0              // contador palabras
    mov x23, 0              // contador digitos
    mov x24, 1              // multiplicador de dígito
    mov x25, 0              // suma de numeros
    ldr x1, =buffer
    mov x2, x1

obtenerCantDigitos:
    ldrb w7, [x2]
    cmp w7, 36
    b.eq calculateMean      // fin de la lectura de numeros, calcula la media
    cmp w7, 10
    b.eq strToInt           // salta a verificar el numero
    add x23, x23, 1         // contador = contador + 1
    add x2, x2, 1           // x2 = x2 + 1 (cambia al siguiente bit)
    b obtenerCantDigitos

strToInt:
    sub x23, x23, 1         // x23 = #digitos - 1
    ldrb w7, [x1, x23]      // x7 = mem(x1 + x23) -> memoria del primer dígito + (long - 1)
    sub w7, w7, 48          // ascii -> int
    mul x7, x7, x24        // x7 = x7*x24 -> toma el número y lo multiplica por una potencia de 10, para obtener decenas, centenas, etc.
    add x25, x25, x7        // lo suma al total
    mov x26, 10
    mul x24, x24, x26       // eleva el multiplicador 10 veces

    cmp x23, 0              // condición if(x23 == 0):
    b.eq processNextNumber  //      processNextNumber()
    b strToInt              // procesar el siguiente dígito

processNextNumber:
    // Va a leer el siguiente dígito
    add x2, x2, 1           // x2 = x2 + 1 (cambia al primer dígito del siguiente número)
    mov x1, x2              // cambia la dirección inicial al siguiente numero
    add x22, x22, 1         // cantPalabras++
    mov x24, 1              // volver a la condición inicial de multiplicador
    b obtenerCantDigitos

calculateMean:
    // calcula media
    sdiv x26, x25, x22      // obtiene la media = x26
    // declaración de variables nuevamente
    mov x20, 0              // longitud de numero
    mov x21, 10             // variable división
    ldr x1, =numSalida      // direccion memoria de numero de salida
    mov x27, x26            // x27 = resultado
    b cantDigitosRespuesta

cantDigitosRespuesta:
    sdiv x27, x27, x21       // eliminar el ultimo digito 1234 -> 123
    add x20, x20, 1         // contadorNumeros++
    cmp x27, 0
    b.eq configurarNumeroBits
    b cantDigitosRespuesta

configurarNumeroBits:
    mov x2, x20

saveResultInASCII:
    mov x27, x26            // x27 = media
    sdiv x27, x27, x21      // quita el último dígito
    msub x28, x27, x21, x26 // ej: x28 = 1234 - (123*10) = 1234 - 1230 = 4 (último número)
    add x28, x28, 48        // conversión a ascii
    sub x20, x20, 1         // x20 = long(media) - 1
    strb w28, [x1, x20]
    
    sdiv x26, x26, x21
    cmp x26, 0
    b.eq printResult
    b saveResultInASCII

printResult:
    mov x0, 1
    ldr x1, =numSalida
    mov x2, x2
    mov x8, #64
    svc 0

    b exit

exit:
    mov x0, #0
    mov x8, #93
    svc 0