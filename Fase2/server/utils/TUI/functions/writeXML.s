.global writeXML
.extern minimum
.extern itoa
.extern maximum
.extern mean
.extern sum
.extern bubble_sort
.extern median
.extern mode
.extern variance
.extern sub_var
.extern stdev
.extern writeXML
.extern exp_smoothXML
.extern convert
.extern printNum

.section .bss
fileName: .space 30
//writeBuffer: .space 16384 // 16KB buffer for writing XML content
writeBuffer: .space 163840 // 16KB buffer for writing XML content
prueba2: .space 2

.section .data
welcomeMsg: .asciz "\n\n======= BIENVENIDO A LA SECCION ESCRIBIR XML =======\n" // length = 55
intructionMsg: .asciz "\nInstrucciones: \n1. Sigue la sintaxis: nombre.xml\n2. Nombres con longitud menores a 25 caracteres\n"
fileNameMsg: .asciz "\nNombre del archivo: " // length = 21
pruebaMsg: .asciz "\n\npn" // lenght = 4

.section .text
writeXML:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    // Write the welcome msg
    mov x0, #1
    ldr x1, =welcomeMsg
    mov x2, #55
    mov x8, #64
    svc #0

    // Write the instruction Msg 

    mov x0, #1
    ldr x1, =intructionMsg
    mov x2, #98
    mov x8, #64
    svc #0

    // Write the fileName msg
    mov x0, #1
    ldr x1, =fileNameMsg
    mov x2, #21
    mov x8, #64
    svc #0

    // request a text entry
    mov x0, #0
    ldr x1, =fileName
    mov x2, #30
    mov x8, #63
    svc #0

    mov x4, #0              // x4 = counter and file name length
    ldr x9, =fileName

// ------------------------REMOVE BREAK LINE IN FILE NAME-----------------------------------------

removeBreakLine:
    ldrb w7, [x9, x4]
    cmp w7, #10
    b.eq setPositionToNull
    add x4, x4, 1
    b removeBreakLine

setPositionToNull:
    mov w7, #0
    strb w7, [x9, x4]
    
    // set initial conditions
    mov x27, #0              // x27 = position counter
    ldr x26, =writeBuffer   // x26 = dir(writeBuffer)

openEstadisticasTag:
    mov w7, #60             // <
    strb w7, [x26, x27]
    add x27, x27, 1
    
    mov w7, #101            // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115            // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #116            // 't'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97             // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100            // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105            // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115            // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #116            // 't'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105            // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #99             // 'c'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97             // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115            // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62             // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openMeanTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to median
    bl mean
    bl itoa
    mov x5, #0          // counter

meanValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeMeanTag
    add x5, x5, 1
    b meanValue

closeMeanTag:
     mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openMedianTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to median
    bl median
    bl itoa
    mov x5, #0          // counter

medianValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeMedianTag
    add x5, x5, 1
    b medianValue

closeMedianTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openModeTag: 
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to mode
    bl mode
    bl itoa
    mov x5, #0          // counter
    ldr x4, =prueba2

modeValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeModeTag
    add x5, x5, 1
    b modeValue

closeModeTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openMinTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to Minimum
    bl minimum
    bl itoa
    mov x5, #0          // counter

minValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeMinTag
    add x5, x5, 1
    b minValue

closeMinTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openMaxTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #120        // 'x'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to maximum
    bl maximum
    bl itoa
    mov x5, #0          // counter

maxValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeMaxTag
    add x5, x5, 1
    b maxValue

closeMaxTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #120        // 'x'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openDeviationTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #99         // 'c'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to deviation
    bl stdev
    bl itoa
    mov x5, #0          // counter

deviationValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeDeviationTag
    add x5, x5, 1
    b deviationValue

closeDeviationTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #99         // 'c'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openVarianceTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #114        // 'r'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #122        // 'z'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to variance
    bl variance
    bl itoa
    mov x5, #0          // counter

varianceValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeVarianceTag
    add x5, x5, 1
    b varianceValue

closeVarianceTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #114        // 'r'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #110        // 'n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #122        // 'z'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openMovilMeanTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #108        // 'l'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    // set values to movil mean
    bl mean
    bl itoa
    mov x5, #0          // counter

movilMeanValue:
    ldrb w7, [x0, x5]
    strb w7, [x26, x27]
    add x27, x27, 1
    sub x1, x1, 1
    cmp x1, 0
    b.eq closeMovilMeanTag
    add x5, x5, 1
    b movilMeanValue

closeMovilMeanTag:
    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #109        // 'm'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #108        // 'l'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

openExponentialSoftenerTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #117        // 'u'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #122        // 'z'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

    bl exp_smoothXML

closeExponentialSoftenerTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #9         // '\t'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #117        // 'u'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #118        // 'v'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #122        // 'z'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #111        // 'o'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

closeStatisticsTag:
    mov w7, #10         // '\n'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #60         // '<'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #47         // '/'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #101        // 'e'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #116        // 't'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #100        // 'd'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #116        // 't'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #105        // 'i'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #99         // 'c'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #97         // 'a'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #115        // 's'
    strb w7, [x26, x27]
    add x27, x27, #1

    mov w7, #62         // '>'
    strb w7, [x26, x27]
    add x27, x27, #1

// ----------------------------------------------- WRITE XML FILE -------------------------

writeXmlFile:
    mov x12, x27
    // open file
    mov x0, -100        // open
    ldr x1, =fileName   // filename address
    mov x2, 101         // O_WRONLY | O_CREATE
    mov x3, 0777        // permissions
    mov x8, 56          // openat
    svc #0              // syscall
    mov x9, x0          // store file descriptor
    
    // write file
    mov x0, x9          // file descriptor
    ldr x1, =writeBuffer     // buffer address
    mov x2, x12          // size address
    mov x8, 64          // write
    svc 0               // syscall

    // close file
    mov x0, x9          // file descriptor
    mov x8, 57          // close
    svc 0               // syscall

    ldp fp, lr, [sp], #16
    ret

testPrint:
    stp fp, lr, [sp, #-16]!
    mov fp, sp
    mov x0, 1
    ldr x1, =pruebaMsg
    mov x2, 4
    mov x8, 64
    svc 0

    ldp fp, lr, [sp], #16
    ret

testPrint2:
    stp fp, lr, [sp, #-16]!
    mov fp, sp
    mov x0, 1
    ldr x1, =prueba2
    mov x2, 2
    mov x8, 64
    svc 0

    ldp fp, lr, [sp], #16
    ret
