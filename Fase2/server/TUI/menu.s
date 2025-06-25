.global _start
.extern readfile
.extern numbers_array
.extern read_opt
.extern print
.extern create_range_buffer
.extern minimum
.extern itoa
.extern printNum
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
.extern exp_smooth


// Menu de opciones
// que se ejecuta en un bucle hasta que se elige salir
// Opciones:
// 1. Leer Archivo de Datos
// 1.1. Escoger rango de lineas (si no se escoge se tomará todo el archivo)
// 1.2. Limpiar filtrado
// 1.3. Seleccionar funciones estadisticas y de prediccion [ Tendria las opciones de las funciones ]
// 1.4. Exportar a XML
// 1.5. Regresar al menu principal

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
        // 0. Salir
        mov x0, #1          // file descriptor para stdout
        ldr x1, =msg        // direccion mensaje
        mov x2, len_msg     // longitud mensaje
        mov x8, #64         // syscall_num write
        svc #0              // llamada al sistema

        // Leer la opción del usuario
        bl read_opt         // x0 = opción leída
        mov w6, w0          // Guardar la opción leída en w6

        cmp w6, #1          // comparar 1 (Leer Archivo de Datos)
        b.eq read_file 

        cmp w6, #0         // comparar 2 (Salir)
        b.eq exit           

        // Si opción no es válida
        mov x0, #1          // file descriptor stdout
        ldr x1, =msg2       // direccion mensaje error
        mov x2, len_msg2    // longitud mensaje error
        mov x8, #64         // syscall_num write
        svc #0              // llamada al sistema

        b do                // Volver al inicio del bucle

        read_file:
            mov x15, #0         // Limite inferior del rango (inicializado a 0)
            mov x16, #0         // Limite superior del rango (inicializado a 0)

            bl readfile         // x0 | x18 = direccion del archivo leido , x1= numero bytes leidos
            cmp x0, #0          // Verificar si el archivo se ha abierto correctamente
            b.lt do

            mov x24, x1         // Guardar el número de bytes leídos en x24
            mov x23, x0         // Guardar la dirección del buffer leido en x23
            mov x18, x23        // Guardar la dirección del buffer leido en x18 para usarlo más tarde
            mov x0, x23         // x0 = dirección del buffer leido

            bl numbers_array    // x0 = array de numeros, x1 = contador de números
            mov x17, x1         // Guardar el contador de números en x17
            mov x22, x0         // Guardar la dirección del array de números en x22 
            mov x25, x22        // x25 = Puntero al array de números
            mov x28, x17        // x28 = Contador de números (para usar en las funciones estadísticas)

            mov x0, #1                      // file descriptor stdout
            ldr x1, =msg_file_uploaded      // direccion mensaje exito
            mov x2, len_msg_file_uploaded   // longitud mensaje
            mov x8, #64                     // syscall_num write
            svc #0                          // llamada al sistema

                do2:
                    // Imprimir el mensaje del submenu
                    // 1. Escoger rango de lineas
                    // 2. Limpiar filtrado
                    // 3. Seleccionar funciones estadisticas y de prediccion
                    // 4. Exportar a XML
                    // 0. Regresar al menu principal
                    mov x0, #1          // file descriptor stdout
                    ldr x1, =msg3       // direccion mensaje
                    mov x2, len_msg3    // longitud mensaje
                    mov x8, #64         // syscall_num write
                    svc #0              // llamada al sistema

                    // Leer la opción del usuario
                    bl read_opt         // x0 = opción leída
                    mov w6, w0          // Guardar la opción leída en w6

                    cmp w6, #1          // comparar 1 (Escoger rango de lineas)
                    b.eq choose_range 

                    cmp w6, #2          // comparar 2 (limpiar filtrado)
                    b.eq clean_filter  

                    cmp w6, #3          // comparar 3 (Seleccionar funciones estadisticas y de prediccion)
                    b.eq select_stats 

                    cmp w6, #4          // comparar 4 (exportar a XML)
                    b.eq export_xml             

                    cmp w6, #0          // comparar 5 (Regresar al menu principal)
                    b.eq do            

                    // Si la opción no es válida, volver al inicio del bucle
                    mov x0, #1          // file descriptor stdout
                    ldr x1, =msg2       // direccion mensaje error
                    mov x2, len_msg2    // longitud mensaje error
                    mov x8, #64         // syscall_num para write
                    svc #0              // llamada al sistema

                    b do2

                chose_lower_limit_error:
                    // Imprimir mensaje de error del límite inferior
                    mov x0, #1                                  // file descriptor stdout
                    ldr x1, =msg_limit_lower_out_of_range       // direccion mensaje error
                    mov x2, len_msg_limit_lower_out_of_range    // longitud mensaje error
                    mov x8, #64                                 // syscall_num write
                    svc #0                                      // llamada al sistema

                    b do2 // Volver al submenu

                chose_upper_limit_error:
                    // Imprimir mensaje de error del límite superior
                    mov x0, #1                                  // file descriptor stdout
                    ldr x1, =msg_choose_range_upper_error       // direccion mensaje error
                    mov x2, len_msg_choose_range_upper_error    // longitud mensaje error
                    mov x8, #64                                 // syscall_num write
                    svc #0                                      // llamada al sistema

                    b do2 // Volver al submenu

                choose_range:
                    // Imprimir mensaje de bienvenida
                    mov x0, #1
                    ldr x1, =msg_select_ranges
                    mov x2, len_msg_select_ranges
                    mov x8, #64
                    svc 0

                    // Imprimir mensaje para escoger rango inferior
                    mov x0, #1                              // file descriptor stdout
                    ldr x1, =msg_choose_lower_limit         // direccion mensaje
                    mov x2, len_msg_choose_lower_limit      // longitud mensaje
                    mov x8, #64                             // syscall_num write
                    svc #0                                  // llamada al sistema

                    // Leer la opción del usuario
                    bl read_opt         // x0 = opción leída
                    mov w6, w0          // Guardar la opción leída en w6  

                    sub w6, w6, #1      // Ajustar para que sea 0-indexado

                    // Comparo el límite inferior con el número de líneas
                    cmp w6, w17                     // comparar con el número de líneas
                    b.ge chose_lower_limit_error    // Si el límite inferior es mayor o igual al número de líneas

                    cmp w6, #0                      // comparar con 0
                    b.lt chose_lower_limit_error    // Si el límite inferior es menor que 0, error

                    // Si todo está bien, guardar el rango escogido
                    mov w15, w6                     // Guardar el límite inferior en x16

                    // Imprimir mensaje para escoger limite superior
                    mov x0, #1                          // file descriptor stdout
                    ldr x1, =msg_choose_upper_limit     // direccion mensaje
                    mov x2, len_msg_choose_upper_limit  // longitud mensaje
                    mov x8, #64                         // syscall_num write
                    svc #0                              // llamada al sistema

                    // Leer la opción del usuario
                    bl read_opt         // x0 = opción leída
                    mov w6, w0          // Guardar la opción leída en w6

                    sub w6, w6, #1      // Ajustar para que sea 0-indexado

                    // Comparo el límite superior con el número total de lineas
                    cmp w6, w17                     // comparar con el número de líneas
                    b.gt chose_upper_limit_error    // Si el límite superior es mayor o igual al número de

                    // Comparo el límite superior con el límite inferior
                    cmp w6, w15                     // comparar con el límite inferior
                    b.le chose_upper_limit_error    // Si el límite superior es menor o igual al límite inferior

                    // Si todo está bien, guardar el rango escogido
                    mov w16, w6                     // Guardar el límite superior en x16
                    
                    // Crea un buffer con el rango escogido
                    mov x0, x23             // x0 = dirección del buffer leido
                    mov x1, x24             // x1 = total bytes en el buffer leido
                    mov x2, x15             // x2 = límite inferior en el rango 
                    mov x3, x16             // x3 = límite superior en el rango
                    bl create_range_buffer  // x0 = buffer con el rango escogido
                    mov x18, x0             // Guardar el buffer con el rango escogido en x18

                    // Creo otro array de números con el rango escogido
                    mov x0, x18             // x0 = dirección del buffer con el rango escogido
                    mov x1, x24             // total bytes en el buffer leido
                    bl numbers_array        // x0 = array de numeros, x1 = contador de números
                    mov x25, x0             // Guardar  la dirección del array de números en x25
                    mov x28, x1             // Guardar el contador de números en x28

                    // Rango escogido exitosamente
                    mov x0, #1                          // file descriptor stdout
                    ldr x1, =msg_choosing_range_success // direccion mensaje
                    mov x2, len_choosing_range_success  // longitud mensaje
                    mov x8, #64                         // syscall_num write
                    svc #0                              // llamada al sistema

                    b do2 // Volver al submenu


                clean_filter:
                    // Resetear los límites del rango
                    mov w15, #0         // Limite inferior del rango (inicializado a 0)
                    mov w16, #0         // Limite superior del rango (inicializado a 0)

                    mov x18, x23        // Resetear el buffer con el archivo leido

                    bl numbers_array    // x0 = array de numeros, x1 = contador de números
                    mov x25, x0         // Guardar la dirección del array de números en x25
                    mov x28, x1         // Guardar el contador de números en x28

                    // Imprimir mensaje de éxito de limpieza de filtro
                    mov x0, #1                          // file descriptor stdout
                    ldr x1, =msg_clean_filter_success   // direccion mensaje
                    mov x2, len_msg_clean_filter        // longitud mensaje
                    mov x8, #64                         // syscall_num write
                    svc #0                              // llamada al sistema

                    b do2 // Volver al submenu

                select_stats:
                    // Imprimir el mensaje del submenu de opciones estadisticas
                    // 1. Valor Minimo
                    // 2. Valor Maximo
                    // 3. Media
                    // 4. Mediana
                    // 5. Moda
                    // 6. Desviación Estándar
                    // 7. Varianza
                    // 8. Media Movil
                    // 9. Suavizado Exponencial
                    // 10 Imprimir todo
                    // 0. Regresar
                    // Seleccione una opcion
                    mov x0, #1                          // file descriptor stdout
                    ldr x1, =msg_menu_stats             // direccion mensaje
                    mov x2, len_msg_menu_stats          // longitud mensaje
                    mov x8, #64                         // syscall_num write
                    svc #0                              // llamada al sistema
                    mov x27, #0                          // eliminar el filtro para todos

                    // Leer la opción del usuario
                    bl read_opt         // x0 = opción leída
                    mov w6, w0          // Guardar la opción leída en w6

                    cmp w6, #1          // comparar 1 (Valor Minimo)
                    b.eq min_value

                    cmp w6, #2          // comparar 2 (Valor Maximo)
                    b.eq max_value

                    cmp w6, #3          // comparar 3 (Media)
                    b.eq mean_value

                    cmp w6, #4          // comparar 4 (Mediana)
                    b.eq median_value

                    cmp w6, #5          // comparar 5 (Moda)
                    b.eq mode_value

                    cmp w6, #6          // comparar 6 (Desviación Estándar)
                    b.eq std_dev_value

                    cmp w6, #7          // comparar 7 (Varianza)
                    b.eq variance_value

                    cmp w6, #8          // comparar 8 (Media Movil)
                    b.eq moving_average

                    cmp w6, #9          // comparar 9 (Suavizado Exponencial)
                    b.eq exponential_smoothing

                    cmp w6, #10         // comparar 10 (Imprimir todo)
                    b.eq print_all

                    cmp w6, #0         // comparar 0 (Regresar)
                    b.eq do2

                    // Si la opción no es válida, volver al inicio del bucle
                    mov x0, #1          // file descriptor stdout
                    ldr x1, =msg2       // direccion mensaje error
                    mov x2, len_msg2    // longitud mensaje error
                    mov x8, #64         // syscall_num write
                    svc #0              // llamada al sistema

                    b select_stats // Volver al submenu de estadisticas


                    min_value:
                        bl add_double_break_line

                        mov x0, #1                          // file descriptor stdout
                        ldr x1, =msg_min_value              // direccion mensaje
                        mov x2, len_msg_min_value           // longitud mensaje
                        mov x8, #64                         // syscall_num write
                        svc #0                              // llamada al sistema

                        // Aquí iría la lógica para calcular el valor mínimo

                        bl minimum
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq max_value
                        
                        bl add_break_line                        
                        b select_stats // Volver al submenu
                                    
                    max_value:
                        mov x0, #1                          // file descriptor stdout
                        ldr x1, =msg_max_value              // direccion mensaje
                        mov x2, len_msg_max_value           // longitud mensaje
                        mov x8, #64                         // syscall_num write
                        svc #0                              // llamada al sistema

                        // Aquí iría la lógica para calcular el valor máximo

                        bl maximum
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq mean_value
                        bl add_break_line
                        b select_stats // Volver al submenu

                    mean_value:
                        mov x0, #1                          // file descriptor stdout
                        ldr x1, =msg_mean_value             // direccion mensaje
                        mov x2, len_msg_mean_value          // longitud mensaje
                        mov x8, #64                         // syscall_num write
                        svc #0                              // llamada al sistema

                        // Aquí iría la lógica para calcular la media

                        bl mean
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq median_value

                        bl add_break_line
                        b select_stats // Volver al submenu

                    median_value:
                        mov x0, #1                              // file descriptor stdout
                        ldr x1, =msg_median_value               // direccion mensaje
                        mov x2, len_msg_median_value            // longitud mensaje
                        mov x8, #64                             // syscall_num write
                        svc #0                                  // llamada al sistema

                        // Aquí iría la lógica para calcular la mediana

                        bl median
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq mode_value

                        bl add_break_line
                        b select_stats // Volver al submenu

                    mode_value:
                        mov x0, #1                              // file descriptor stdout
                        ldr x1, =msg_mode_value                 // direccion mensaje
                        mov x2, len_msg_mode_value              // longitud mensaje
                        mov x8, #64                             // syscall_num write
                        svc #0                                  // llamada al sistema

                        // Aquí iría la lógica para calcular la moda

                        bl mode
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq std_dev_value

                        bl add_break_line
                        b select_stats // Volver al submenu

                    std_dev_value:
                        mov x0, #1                              // file descriptor stdout
                        ldr x1, =msg_std_dev_value              // direccion mensaje
                        mov x2, len_msg_std_dev_value           // longitud mensaje
                        mov x8, #64                             // syscall_num write
                        svc #0                                  // llamada al sistema

                        // Aquí iría la lógica para calcular la desviación estándar

                        bl stdev
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq variance_value
                        
                        bl add_break_line
                        b select_stats // Volver al submenu

                    variance_value:
                        mov x0, #1                              // file descriptor stdout
                        ldr x1, =msg_variance_value             // direccion mensaje
                        mov x2, len_msg_variance_value          // longitud mensaje
                        mov x8, #64                             // syscall_num write
                        svc #0                                  // llamada al sistema

                        // Aquí iría la lógica para calcular la varianza
                        
                        bl variance
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq moving_average

                        bl add_break_line
                        b select_stats // Volver al submenu

                    moving_average:
                        mov x0, #1                              // file descriptor stdout
                        ldr x1, =msg_moving_average             // direccion mensaje
                        mov x2, len_msg_moving_average          // longitud mensaje
                        mov x8, #64                             // syscall_num write
                        svc #0                                  // llamada al sistema

                        // Aquí iría la lógica para calcular la media móvil

                        bl mean
                        bl itoa
                        bl printNum

                        cmp x27, #1111
                        b.eq exponential_smoothing

                        bl add_break_line
                        b select_stats // Volver al submenu

                    exponential_smoothing:
                        mov x0, #1                              // file descriptor stdout
                        ldr x1, =msg_exponential_smoothing      // direccion mensaje
                        mov x2, len_msg_exponential_smoothing   // longitud mensaje
                        mov x8, #64                             // syscall_num write
                        svc #0                                  // llamada al sistema

                        // Aquí iría la lógica para calcular el suavizado exponencial

                        bl exp_smooth

                        cmp x27, #1111
                        b.eq return_to_principal_menu_desition
                        b select_stats // Volver al submenu
                    
                    print_all:
                        // Imprimir todos los valores calculados
                        mov x27, #1111
                        b min_value


                export_xml:
                    // Aquí iría la lógica para exportar a XML
                    // Pero de momento solo saltará mensaje de exito

                    bl writeXML

                    mov x0, #1                          // file descriptor stdout
                    ldr x1, =msg_export_xml_success     // direccion mensaje
                    mov x2, len_msg_export_xml_success   // longitud mensaje
                    mov x8, #64                         // syscall_num write
                    svc #0                              // llamada al sistema

                    b do2 // Volver al submenu

    
    exit:
        // Imprimir mensaje de salida
        mov x0, #1          // file descriptor stdout
        ldr x1, =msg_exit   // direccion mensaje
        mov x2, len_exit    // longitud mensaje
        mov x8, #64         // syscall_num write
        svc #0              // llamada al sistema

        // Terminar el programa
        mov x8, #93         // syscall_num msg_exit
        mov x0, #0          // código de salida 0
        svc #0              // llamada al sistema

add_break_line:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x0, 1
    ldr x1, =break_line
    mov x2, 1
    mov x8, 64
    svc 0

    ldp fp, lr, [sp], #16
    ret

add_double_break_line:
    stp fp, lr, [sp, #-16]!
    mov fp, sp

    mov x0, 1
    ldr x1, =double_break_line
    mov x2, 2
    mov x8, 64
    svc 0

    ldp fp, lr, [sp], #16
    ret

return_to_principal_menu_desition:
    mov x27, 0
    mov x0, 1
    ldr x1, =return_statistics_section_msg
    mov x2, len_return_statistics_section_msg
    mov x8, #64
    svc 0

    bl read_opt         // x0 = opción leída
    mov w6, w0          // Guardar la opción leída en w6

    cmp w6, #1
    b.eq select_stats

    b return_to_principal_menu_desition



.data
return_statistics_section_msg: .asciz "\n---> Presiona 1 para retornar al menu de estadisticas..."
end_return_statistics_section_msg:
.equ len_return_statistics_section_msg, end_return_statistics_section_msg - return_statistics_section_msg  // longitud mensaje

//Mensaje de bienvenida
welcome_msg: .asciz "\n====== Bienvenido a TUI (Text User Interface) ======"
end_welcome_msg: // apuntar final mensaje
.equ len_welcome_msg, end_welcome_msg - welcome_msg  // longitud mensaje

// Mensajes del menu
msg: .asciz "\n\n================== MENU DE INICIO ==================\n\n1. Leer Archivo de Datos\n0. Salir\nSeleccione una opcion: "
end_msg: // apuntar final mensaje
.equ len_msg, end_msg - msg  // longitud mensaje

// Mensaje de error para opción no válida
msg2: .asciz "\n\n***Opcion no valida, intente de nuevo***\n"
end_msg2: // apuntar final mensaje error
.equ len_msg2, end_msg2 - msg2  // longitud  mensaje error

//Mensaje submenu 
msg3: .asciz "\n\n================== MENU PRINCIPAL ==================\n\n1. Escoger rango de lineas\n2. Limpiar filtrado\n3. Seleccionar funciones estadisticas y de prediccion\n4. Exportar a XML\n0. Regresar al menu principal\nSeleccione una opcion: "
end_msg3: // apuntar final mensaje menu 2
.equ len_msg3, end_msg3 - msg3  // longitud mensaje menu

//Mensaje opciones de los stats
msg_menu_stats: .asciz "\n\n======= SELECCIONE LA ESTADÍSTICA A CALCULAR =======\n\n1. Valor Minimo\n2. Valor Maximo\n3. Media\n4. Mediana\n5. Moda\n6. Desviación Estándar\n7. Varianza\n8. Media Movil\n9. Suavizado Exponencial\n10. Ejecutar todas las operaciones\n0. Regresar\n\nSeleccione una opcion: "
end_msg_menu_stats: // apuntar final mensaje menu xml
.equ len_msg_menu_stats, end_msg_menu_stats - msg_menu_stats  // longitud mensaje

// Mensaje de archivo cargado
msg_file_uploaded: .asciz "\n\n¡¡¡Archivo cargado exitosamente!!!\n"
end_msg_file_uploaded: // apuntar final mensaje
.equ len_msg_file_uploaded, end_msg_file_uploaded - msg_file_uploaded  // longitud mensaje

// Mensaje sección de elegir rangos
msg_select_ranges: .asciz "\n\n==== BIENVENIDO A LA SECCION ELECCION DE RANGOS ====\n"
end_msg_select_ranges: // apuntar final mensaje
.equ len_msg_select_ranges, end_msg_select_ranges - msg_select_ranges  // longitud mensaje

// Mensaje para escoger limite inferior
msg_choose_lower_limit: .asciz "\nIngrese el limite inferior del rango (empieza en 1): "
msg_choose_lower_limit_end: // apuntar final mensaje
.equ len_msg_choose_lower_limit, msg_choose_lower_limit_end - msg_choose_lower_limit

// Mensaje para escoger limite superior
msg_choose_upper_limit: .asciz "\n\nIngrese el limite superior del rango: "
msg_choose_upper_limit_end: // apuntar final mensaje
.equ len_msg_choose_upper_limit, msg_choose_upper_limit_end - msg_choose_upper_limit

// Mensaje limite inferio fuera de rango
msg_limit_lower_out_of_range: .asciz "\n\n***** El limite inferior esta fuera del rango de lineas *****\n"
end_msg_limit_lower_out_of_range: // apuntar final mensaje
.equ len_msg_limit_lower_out_of_range, end_msg_limit_lower_out_of_range - msg_limit_lower_out_of_range

// Mensahe limite superior fuera de rango
msg_choose_range_upper_error: .asciz "\n\n***** El limite superior esta fuera del rango de lineas *****\n"
end_msg_choose_range_upper_error: // apuntar final mensaje
.equ len_msg_choose_range_upper_error, end_msg_choose_range_upper_error - msg_choose_range_upper_error

// Mensaje de rango seleccionado exitosamente
msg_choosing_range_success: .asciz "\n\n¡¡¡Rango de lineas seleccionado exitosamente!!!\n"
end_msg_choosing_range_success: // apuntar final mensaje
.equ len_choosing_range_success, end_msg_choosing_range_success - msg_choosing_range_success  // longitud mensaje

msg_clean_filter_success: .asciz "\n\n¡¡¡Filtrado limpiado exitosamente!!!\n"
end_msg_clean_filter: // apuntar final mensaje
.equ len_msg_clean_filter, end_msg_clean_filter - msg_clean_filter_success  // longitud mensaje 

msg_min_value: .asciz "\n\nValor mínimo calculado: "
end_msg_min_value: // apuntar final mensaje
.equ len_msg_min_value, end_msg_min_value - msg_min_value  // longitud mensaje

msg_max_value: .asciz "\n\nValor máximo calculado: "
end_msg_max_value: // apuntar final mensaje
.equ len_msg_max_value, end_msg_max_value - msg_max_value  // longitud mensaje

msg_mean_value: .asciz "\n\nMedia calculada: "
end_msg_mean_value: // apuntar final mensaje
.equ len_msg_mean_value, end_msg_mean_value - msg_mean_value  // longitud mensaje

msg_median_value: .asciz "\n\nMediana calculada: "
end_msg_median_value: // apuntar final mensaje
.equ len_msg_median_value, end_msg_median_value - msg_median_value

msg_mode_value: .asciz "\n\nModa calculada: "
end_msg_mode_value: // apuntar final mensaje
.equ len_msg_mode_value, end_msg_mode_value - msg_mode_value  // longitud mensaje

msg_std_dev_value: .asciz "\n\nDesviación Estándar calculada: "
end_msg_std_dev_value: // apuntar final mensaje
.equ len_msg_std_dev_value, end_msg_std_dev_value - msg_std_dev_value

msg_variance_value: .asciz "\n\nVarianza calculada: "
end_msg_variance_value: // apuntar final mensaje
.equ len_msg_variance_value, end_msg_variance_value - msg_variance_value

msg_moving_average: .asciz "\n\nMedia Móvil calculada: "
end_msg_moving_average: // apuntar final mensaje
.equ len_msg_moving_average, end_msg_moving_average - msg_moving_average

msg_exponential_smoothing: .asciz "\n\nSuavizado Exponencial calculado:\n"
end_msg_exponential_smoothing: // apuntar final mensaje
.equ len_msg_exponential_smoothing, end_msg_exponential_smoothing - msg_exponential_smoothing

msg_export_xml_success: .asciz "\n\n¡¡¡Exportado a XML exitosamente!!!\n"
end_msg_export_xml_success: // apuntar final mensaje
.equ len_msg_export_xml_success, end_msg_export_xml_success - msg_export_xml_success  // longitud mensaje

msg_exit: .asciz "\n\nTen un buen dia!, saliendo sel programa...\n"
end_exit: // apuntar final mensaje
.equ len_exit, end_exit - msg_exit  // longitud mensaje

break_line: .asciz "\n"

double_break_line: .asciz "\n"

.bss
input: .space 10        // buffer para la entrada del usuario
