.global _start
.extern readfile
.extern numbers_array

// Menu de opciones
// que se ejecuta en un bucle hasta que se elige salir
// Opciones:
// 1. Leer Archivo de Datos
// 1.1. Escoger rango de lineas (si no se escoge se tomará todo el archivo)
// 1.2. Limpiar filtrado
// 1.3. Exportar a XML [ Tendria las opciones de las funciones ]
// 1.4. Regresar al menu principal

// 2. Salir

_start:
    // Imprimir mensaje de bienvenida
    mov x0, #1              // file descriptor stdout
    ldr x1, =welcome_msg    // direccion mensaje
    mov x2, len_welcome_msg // longitud mensaje
    mov x8, #64             // syscall_num write
    svc #0                  // llamada al sistema

    do:

    // Imprimir el mensaje del menu
    // 1. Leer Archivo de Datos
    // 2. Salir
    mov x0, #1          // file descriptor para stdout
    ldr x1, =msg        // direccion mensaje
    mov x2, len_msg     // longitud mensaje
    mov x8, #64         // syscall_num write
    svc #0              // llamada al sistema

    // Leer la opción del usuario
    mov x0, #0          // file descriptor stdin
    ldr x1, =input      // buffer de entrada
    mov x2, #2          // tamaño buffer
    mov x8, #63         // syscall_num read
    svc #0              // llamada al sistema

    // Procesar la entrada del usuario
    ldrb w6, [x1]       // cargar primer byte del buffer
    sub w6, w6, #'0'    // ASCII a entero

    cmp w6, #1          // comparar 1 (Leer Archivo de Datos)
    b.eq read_file 

    cmp w6, #2          // comparar 2 (Salir)
    b.eq exit           

    // Si opción no es válida
    mov x0, #1          // file descriptor stdout
    ldr x1, =msg2       // direccion mensaje error
    mov x2, len_msg2    // longitud mensaje error
    mov x8, #64         // syscall_num write
    svc #0              // llamada al sistema

    b do                // Volver al inicio del bucle

    file_error:


    read_file:
    mov x16, #0         // Limite inferior del rango (inicializado a 0)

    bl readfile         // x0|x18 = direccion del archivo leido , x1= numero bytes leidos
    cmp x0, #0          // Verificar si el archivo se ha abierto correctamente
    b.lt do

    mov x18, x0         // Guardar la dirección del buffer leido en x18

    bl numbers_array    // x0 = array de numeros, x1 = contador de números
    mov x19, x0         // Guardar la dirección del array de números en x19
    mov x17, x1         // Guardar el contador de números en x17

    mov x0, #1                      // file descriptor stdout
    ldr x1, =msg_file_uploaded      // direccion mensaje exito
    mov x2, len_msg_file_uploaded   // longitud mensaje
    mov x8, #64                     // syscall_num write
    svc #0                          // llamada al sistema

        do2:
        // Imprimir el mensaje del submenu
        // 1. Escoger rango de lineas
        // 2. Limpiar filtrado
        // 3. Exportar a XML
        // 4. Regresar al menu principal
        mov x0, #1          // file descriptor stdout
        ldr x1, =msg3       // direccion mensaje
        mov x2, len_msg3    // longitud mensaje
        mov x8, #64         // syscall_num write
        svc #0              // llamada al sistema

        // Leer la opción del usuario
        mov x0, #0          // file descriptor stdin
        ldr x1, =input      // buffer entrada
        mov x2, #2          // tamaño buffer
        mov x8, #63         // syscall_num read
        svc #0              // llamada al sistema

        // Procesar la entrada del usuario
        ldrb w6, [x1]       // cargar primer byte buffer
        sub w6, w6, #'0'    // ASCII a entero



        // ***************************************************


        cmp w6, #1          // comparar 1 (Escoger rango de lineas)
        b.eq choose_range 

        cmp w6, #2          // comparar 2 (limpiar filtrado)
        b.eq clean_filter  

        cmp w6, #3          // comparar 3 (exportar a XML)
        b.eq export_xml             

        cmp w6, #4          // comparar 4 (Regresar al menu principal)
        b.eq do            

        // Si la opción no es válida, volver al inicio del bucle
        mov x0, #1          // file descriptor stdout
        ldr x1, =msg2       // direccion mensaje error
        mov x2, len_msg2    // longitud mensaje error
        mov x8, #64         // syscall_num para write
        svc #0              // llamada al sistema

        b do2


        choose_range:
            // FUNCIÓN PARA CONTAR LINEAS



            //Rango escogido exitosamente
            mov x0, #1                          // file descriptor stdout
            ldr x1, =msg_choosing_range_success // direccion mensaje
            mov x2, len_choosing_range_success  // longitud mensaje
            mov x8, #64                         // syscall_num write
            svc #0                              // llamada al sistema

            b do2 // Volver al submenu


        clean_filter:
            // Aquí iría la lógica para limpiar el filtrado
            // Pero de momento solo saltará mensaje de exito

            mov x0, #1                          // file descriptor stdout
            ldr x1, =msg_clean_filter_success   // direccion mensaje
            mov x2, len_msg_clean_filter        // longitud mensaje
            mov x8, #64                         // syscall_num write
            svc #0                              // llamada al sistema

            b do2 // Volver al submenu


        

        export_xml:
            // Aquí iría la lógica para exportar a XML
            // Pero de momento solo saltará mensaje de exito

            do3:
            // Imprimir el mensaje del submenu de opciones XML
            // 1. Valor Minimo
            // 2. Valor Maximo
            // 3. Media
            // 4. Mediana
            // 5. Moda
            // 6. Desviación Estándar
            // 7. Varianza
            // 8. Media Movil
            // 9. Suavizado Exponencial
            // 10. Regresar
            // 11. Seleccione una opcion
            mov x0, #1                          // file descriptor stdout
            ldr x1, =msg_menu_xml                // direccion mensaje
            mov x2, len_msg_menu_xml             // longitud mensaje
            mov x8, #64                         // syscall_num write
            svc #0                              // llamada al sistema

            // Leer la opción del usuario
            mov x0, #0          // file descriptor stdin
            ldr x1, =input      // buffer entrada
            mov x2, #2          // tamaño buffer        
            mov x8, #63         // syscall_num read
            svc #0              // llamada al sistema

            // Procesar la entrada del usuario
            ldrb w6, [x1]       // cargar primer byte buffer
            sub w6, w6, #'0'    // ASCII a entero

            mov w0, w6 // Guardar la opción seleccionada en x0
            // Aquí iría la lógica para manejar las diferentes opciones del submenu XML **************************************************************
            
            mov x0, #1                          // file descriptor stdout
            ldr x1, =msg_export_xml_success     // direccion mensaje
            mov x2, len_msg_export_xml_success   // longitud mensaje
            mov x8, #64                         // syscall_num write
            svc #0                              // llamada al sistema

            b do2 // Volver al submenu

    exit:
    // Imprimir mensaje de salida
    mov x0, #1          // file descriptor stdout
    ldr x1, =msg_exit       // direccion mensaje
    mov x2, len_exit    // longitud mensaje
    mov x8, #64         // syscall_num write
    svc #0              // llamada al sistema

    // Terminar el programa
    mov x8, #93         // syscall_num msg_exit
    mov x0, #0          // código de salida 0
    svc #0              // llamada al sistema


.data
//Mensaje de bienvenida
welcome_msg: .asciz "====== Bienvenido a TUI (Text User Interface) ======\n"
end_welcome_msg: // apuntar final mensaje
.equ len_welcome_msg, end_welcome_msg - welcome_msg  // longitud mensaje

// Mensajes del menu
msg: .asciz "\nMENU:\n1. Leer Archivo de Datos\n2. Salir\nSeleccione una opcion: "
end_msg: // apuntar final mensaje
.equ len_msg, end_msg - msg  // longitud mensaje

// Mensaje de error para opción no válida
msg2: .asciz "Opcion no valida, intente de nuevo.\n"
end_msg2: // apuntar final mensaje error
.equ len_msg2, end_msg2 - msg2  // longitud  mensaje error

//Mensaje submenu 
msg3: .asciz "\nMENU:\n1. Escoger rango de lineas\n2. Limpiar filtrado\n3. Exportar a XML\n4. Regresar al menu principal\nSeleccione una opcion: "
end_msg3: // apuntar final mensaje menu 2
.equ len_msg3, end_msg3 - msg3  // longitud mensaje menu

//Mensaje opciones del XML
msg_menu_xml: .asciz "\nOPCIONES:\n1. Valor Minimo\n2. Valor Maximo\n3. Media\n4. Mediana\n5. Moda\n6. Desviación Estándar\n7. Varianza\n8. Media Movil\n9. Suavizado Exponencial\n10. Regresar\n11. Seleccione una opcion: "
end_msg_menu_xml: // apuntar final mensaje menu xml
.equ len_msg_menu_xml, end_msg_menu_xml - msg_menu_xml  // longitud mensaje

// Mensaje de archivo cargado
msg_file_uploaded: .asciz "¡¡¡Archivo cargado exitosamente!!!\n"
end_msg_file_uploaded: // apuntar final mensaje
.equ len_msg_file_uploaded, end_msg_file_uploaded - msg_file_uploaded  // longitud mensaje

// Mensaje de rango seleccionado exitosamente
msg_choosing_range_success: .asciz "¡¡¡Rango de lineas seleccionado exitosamente!!!\n"
end_msg_choosing_range_success: // apuntar final mensaje
.equ len_choosing_range_success, end_msg_choosing_range_success - msg_choosing_range_success  // longitud mensaje

msg_clean_filter_success: .asciz "¡¡¡Filtrado limpiado exitosamente!!!\n"
end_msg_clean_filter: // apuntar final mensaje
.equ len_msg_clean_filter, end_msg_clean_filter - msg_clean_filter_success  // longitud mensaje 

msg_export_xml_success: .asciz "¡¡¡Exportado a XML exitosamente!!!\n"
end_msg_export_xml_success: // apuntar final mensaje
.equ len_msg_export_xml_success, end_msg_export_xml_success - msg_export_xml_success  // longitud mensaje

msg_exit: .asciz "Saliendo del programa...\n"
end_exit: // apuntar final mensaje
.equ len_exit, end_exit - msg_exit  // longitud mensaje


.bss
input: .space 2        // buffer para la entrada del usuario
