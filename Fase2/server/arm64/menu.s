.global _start

// Programa para tener un menu de opciones
// que se ejecuta en un bucle hasta que se elige salir
// Opciones:
// 1. Leer Archivo de Datos
// 2. Escoger rango de lineas
// 3. Limpiar filtrado
// 4. Exportar a XML
// 5. Salir

_start:

    // -------------------------------------------------------------------------------------------------------------------------
    do:

    // Imprimir el mensaje del menu
    mov x0, #1           // file descriptor para stdout
    ldr x1, =msg        // direccion del mensaje
    mov x2, len_msg    // longitud del mensaje
    mov x8, #64          // syscall_num para write
    svc #0               // llamada al sistema

    // Leer la opción del usuario
    mov x0, #0           // file descriptor para stdin
    ldr x1, =input      // buffer para la entrada
    mov x2, #2          // tamaño del buffer
    mov x8, #63          // syscall_num para read
    svc #0               // llamada al sistema

    // Procesar la entrada del usuario
    ldrb w6, [x1]    // cargar el primer byte del buffer
    sub w6, w6, #'0'    // convertir de ASCII a entero

    cmp w6, #1          // comparar con 1 (Leer Archivo de Datos)
    b.eq read_file        // si es 1, llamar a la función de leer archivo

    cmp w6, #2          // comparar con 2 (Escoger rango de lineas)
    b.eq choose_range     // si es 2, llamar a la función de escoger rango

    cmp w6, #3          // comparar con 3 (Limpiar filtrado)
    b.eq clear_filter     // si es 3, llamar a la función de limpiar filtr

    cmp w6, #4          // comparar con 4 (Exportar a XML)
    b.eq export_xml       // si es 4, llamar a la función de exportar

    cmp w6, #5          // comparar con 5 (opción de salir)
    b.eq exit            // si es 5, salir del bucle

    // Si la opción no es válida, volver al inicio del bucle
    mov x0, #1           // file descriptor para stdout
    ldr x1, =msg2       // direccion del mensaje de error
    mov x2, len_msg2   // longitud del mensaje de error
    mov x8, #64          // syscall_num para write
    svc #0               // llamada al sistema

    b do
    // -------------------------------------------------------------------------------------------------------------------------

    // Opción para leer un archivo de datos
    // -------------------------------------------------------------------------------------------------------------------------
    read_file:
    // Aquí iría la lógica para leer el archivo de datos
    // Pero de momento solo sale

    mov x0, #1           // valor de retorno
    mov x8, #93          // syscall_num para exit
    svc #0       
    // -------------------------------------------------------------------------------------------------------------------------

    // Opción para escoger un rango de lineas
    // -------------------------------------------------------------------------------------------------------------------------
    choose_range:
        // Aquí iría la lógica para escoger el rango de lineas
        // Pero de momento solo sale
        mov x0, #2           // valor de retorno
        mov x8, #93          // syscall_num para exit
        svc #0               // llamada al sistema
    // -------------------------------------------------------------------------------------------------------------------------

    // Opción para limpiar el filtrado
    // -------------------------------------------------------------------------------------------------------------------------
    clear_filter:
        // Aquí iría la lógica para limpiar el filtrado
        // Pero de momento solo sale
        mov x0, #3           // valor de retorno
        mov x8, #93          // syscall_num para exit
        svc #0               // llamada al sistema
    // -------------------------------------------------------------------------------------------------------------------------

    // Opción para exportar a XML
    // -------------------------------------------------------------------------------------------------------------------------
    export_xml:
        // Aquí iría la lógica para exportar a XML
        // Pero de momento solo sale
        mov x0, #4           // valor de retorno
        mov x8, #93          // syscall_num para exit
        svc #0               // llamada al sistema
    // -------------------------------------------------------------------------------------------------------------------------

    // Opción para salir del programa
    // -------------------------------------------------------------------------------------------------------------------------
    exit:
    // Salir del Programa
    mov x0, #5           // valor de retorno
    mov x8, #93          // syscall_num para exit
    svc #0               // llamada al sistema
    // -------------------------------------------------------------------------------------------------------------------------

.data

// Mensajes del menu
msg: .asciz "MENU:\n1. Leer Archivo de Datos\n2. Escoger rango de lineas\n3. Limpiar filtrado\n4. Exportar a XML\n5. Salir\nSeleccione una opcion: "
end_msg: // Para apuntar al final del mensaje
.equ len_msg, end_msg - msg  // longitud del mensaje

// Mensaje de error para opción no válida
msg2: .asciz "Opcion no valida, intente de nuevo.\n"
end_msg2: // Para apuntar al final del mensaje de error
.equ len_msg2, end_msg2 - msg2  // longitud del mensaje de error

.bss
input: .space 2        // buffer para la entrada del usuario