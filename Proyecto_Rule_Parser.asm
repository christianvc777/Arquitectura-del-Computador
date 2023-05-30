# Proyecto #3 - Rule Parser
# Grupo: Sergio Cuellar, Renato Negrete y Cristian Vargas
# Programa en MARS - Assembler 32 bits

.data
    report_filename: .asciiz "C:/Usuarios/Asus/documentos/ProgAssembly/Report.log"
    filename_data: .asciiz "C:/Usuarios/Asus/documentos/ProgAssembly/data.231020221943"
    filename_rules: .asciiz "C:/Usuarios/Asus/documentos/ProgAssembly/Parsing_Rules.config"
    buffer: .space 200
    logs_table: .space 2400  # Tabla de logs (IP, Username, Date)
    alerts_table: .space 1600  # Tabla de alertas (IP, Username)
    sorted_logs_table: .space 2400  # Tabla de logs ordenada por fecha
    alerts_triggered: .space 2400  # Tabla de alarmas generadas

.text
.globl main

main:
    # Abrir el archivo data
    li $v0, 13   # Cargar el número de llamada al sistema para abrir archivo
    la $a0, filename_data  # Cargar la dirección del nombre del archivo
    li $a1, 0    # Modo de apertura (solo lectura)
    syscall

    # Guardar el descriptor de archivo en $t0
    move $t0, $v0

    # Leer el contenido del archivo data en la tabla de logs
    li $v0, 14   # Cargar el número de llamada al sistema para leer archivo
    move $a0, $t0  # Cargar el descriptor de archivo
    la $a1, logs_table  # Cargar la dirección de la tabla de logs
    li $a2, 200   # Tamaño a leer (200 registros)
    syscall

    # Cerrar el archivo data
    li $v0, 16   # Cargar el número de llamada al sistema para cerrar archivo
    move $a0, $t0  # Cargar el descriptor de archivo
    syscall

    # Abrir el archivo Parsing_Rules.config
    li $v0, 13   # Cargar el número de llamada al sistema para abrir archivo
    la $a0, filename_rules  # Cargar la dirección del nombre del archivo
    li $a1, 0    # Modo de apertura (solo lectura)
    syscall

    # Guardar el descriptor de archivo en $t0
    move $t0, $v0

    # Leer el contenido del archivo Parsing_Rules.config en la tabla de alertas
    li $v0, 14   # Cargar el número de llamada al sistema para leer archivo
    move $a0, $t0  # Cargar el descriptor de archivo
    la $a1, alerts_table  # Cargar la dirección de la tabla de alertas
    li $a2, 200   # Tamaño a leer (200 registros)
    syscall

    # Cerrar el archivo Parsing_Rules.config
    li $v0, 16   # Cargar el número de llamada al sistema para cerrar archivo
    move $a0, $t0  # Cargar el descriptor de archivo
    syscall

    # Ordenar la tabla de logs por fecha en formato epoch
    la $a0, logs_table  # Cargar la dirección de la tabla de logs
    la $a1, sorted_logs_table  # Cargar la dirección de la tabla de logs ordenada
    li $a2, 200   # Tamaño de la tabla de logs
    jal sort_logs

    # Función para eliminar duplicados en un arreglo
    remove_duplicates:
    	# Guardar los registros necesarios
    	addi $sp, $sp, -16
    	sw $ra, 0($sp)   # Guardar la dirección de retorno
    	sw $s0, 4($sp)   # Guardar el valor de $s0
    	sw $s1, 8($sp)   # Guardar el valor de $s1
    	sw $s2, 12($sp)  # Guardar el valor de $s2

    	move $s0, $a0    # Guardar la dirección del arreglo en $s0
    	move $s1, $a1    # Guardar la dirección del arreglo sin duplicados en $s1
    	move $s2, $a2    # Guardar el tamaño del arreglo en $s2

    	li $t0, 0        # Inicializar el contador de elementos únicos en 0

    	Loop:
        	li $t1, 0        # Inicializar el índice de comparación en 0

        	Inner_loop:
            	mul $t2, $t1, 4       # Multiplicar el índice por 4 para obtener el desplazamiento en bytes
            	mul $t3, $t1, 4       # Multiplicar el índice por 4 para obtener el desplazamiento en bytes
            	add $t2, $s0, $t2    # Calcular la dirección del elemento actual en el arreglo
            	add $t3, $s0, $t3    # Calcular la dirección del elemento siguiente en el arreglo
            	lw $t4, 0($t2)       # Cargar el elemento actual en $t4
            	lw $t5, 0($t3)       # Cargar el elemento siguiente en $t5

            	beq $t4, $t5, skip   # Saltar si el elemento actual es igual al siguiente

            	# Copiar el elemento actual al arreglo sin duplicados
            	mul $t6, $t0, 4       # Multiplicar el contador de elementos únicos por 4 para obtener el desplazamiento en bytes
            	add $t6, $s1, $t6    # Calcular la dirección donde se debe copiar el elemento
            	sw $t4, 0($t6)       # Copiar el elemento al arreglo sin duplicados

            	addi $t0, $t0, 1     # Incrementar el contador de elementos únicos

        skip:
            	addi $t1, $t1, 1     # Incrementar el índice de comparación
            	blt $t1, $s2, Inner_loop   # Repetir el bucle interno si no se han comparado todos los elementos

        	addi $t0, $t0, 1     # Incrementar el contador de elementos únicos
        	blt $t0, $s2, Loop   # Repetir el bucle externo si no se han procesado todos los elementos

    	move $v0, $t0    # Cargar el contador de elementos únicos en $v0

   	# Restaurar los registros
   	lw $ra, 0($sp)
   	lw $s0, 4($sp)
   	lw $s1, 8($sp)
   	lw $s2, 12($sp)
   	addi $sp, $sp, 16    # Liberar el espacio del stack
   
   	jr $ra    # Retornar a la dirección de retorno


 # Eliminar archivos duplicados en la tabla de alertas
    la $a0, alerts_table  # Cargar la dirección de la tabla de alertas
    la $a1, alerts_table  # Cargar la dirección de la tabla de alertas
    li $a2, 200   # Tamaño de la tabla de alertas
    jal remove_duplicates

write_alerts_to_file:
    # Guardar los registros necesarios
    addi $sp, $sp, -12
    sw $ra, 0($sp)    # Guardar la dirección de retorno
    sw $s0, 4($sp)    # Guardar el valor de $s0
    sw $s1, 8($sp)    # Guardar el valor de $s1

    move $s0, $a0     # Guardar la dirección de la tabla de alertas en $s0

    li $v0, 13   # Cargar el número de llamada al sistema para abrir archivo
    la $a0, report_filename   # Cargar la dirección del nombre del archivo
    li $a1, 1    # Modo de apertura (escritura)
    syscall

    # Guardar el descriptor de archivo en $t0
    move $t0, $v0

    # Escribir las alertas en el archivo
    li $t1, 0         # Inicializar el índice en 0

    Loop2:
        mul $t2, $t1, 8   # Multiplicar el índice por 8 para obtener el desplazamiento en bytes
        add $t2, $s0, $t2   # Calcular la dirección del elemento actual en la tabla de alertas
        lw $t3, 0($t2)    # Cargar la IP del elemento actual en $t3

        # Escribir la IP en el archivo
        move $a0, $t0     # Cargar el descriptor de archivo en $a0
        move $a1, $t3     # Cargar la IP en $a1
        jal write_ip_to_file

        addi $t1, $t1, 1   # Incrementar el índice
        blt $t1, $a2, Loop   # Repetir el bucle si no se han procesado todas las alertas

    # Cerrar el archivo
    li $v0, 16   # Cargar el número de llamada al sistema para cerrar archivo
    move $a0, $t0     # Cargar el descriptor de archivo en $a0
    syscall

    # Restaurar los registros guardados
    lw $ra, 0($sp)    # Cargar la dirección de retorno
    lw $s0, 4($sp)    # Cargar el valor de $s0
    lw $s1, 8($sp)    # Cargar el valor de $s1
    addi $sp, $sp, 12  # Restaurar el puntero de pila

    # Salir de la función y volver a la dirección de retorno
    jr $ra


generate_alerts_file:
    # Guardar los registros necesarios
    addi $sp, $sp, -12
    sw $ra, 0($sp)    # Guardar la dirección de retorno
    sw $s0, 4($sp)    # Guardar el valor de $s0
    sw $s1, 8($sp)    # Guardar el valor de $s1

    move $s0, $a0     # Guardar la dirección de la tabla de logs ordenada en $s0
    move $s1, $a1     # Guardar la dirección de la tabla de alertas en $s1

    li $t0, 0         # Inicializar el contador de alarmas generadas en 0

    Loop1:
        li $t1, 0        # Inicializar el índice de comparación en 0

        Inner_loop1:
            mul $t2, $t1, 8       # Multiplicar el índice por 8 para obtener el desplazamiento en bytes
            mul $t3, $t1, 8       # Multiplicar el índice por 8 para obtener el desplazamiento en bytes
            add $t2, $s1, $t2    # Calcular la dirección del elemento actual en la tabla de alertas
            add $t3, $s1, $t3    # Calcular la dirección del elemento siguiente en la tabla de alertas
            lw $t4, 0($t2)       # Cargar la IP del elemento actual en $t4
            lw $t5, 0($t3)       # Cargar la IP del elemento siguiente en $t5

            beq $t4, $t5, skip   # Saltar si la IP actual es igual a la IP siguiente

            # Copiar la IP actual al archivo de alarmas generadas
            li $v0, 13   # Cargar el número de llamada al sistema para abrir archivo
            la $a0, alerts_triggered_filename   # Cargar la dirección del nombre del archivo
            li $a1, 1    # Modo de apertura (escritura)
            syscall

            # Guardar el descriptor de archivo en $t6
            move $t6, $v0

            # Escribir la IP actual en el archivo de alarmas generadas
            move $a0, $t6     # Cargar el descriptor de archivo en $a0
            move $a1, $t4     # Cargar la IP actual en $a1
            jal write_ip_to_file

            # Cerrar el archivo de alarmas generadas
            li $v0, 16   # Cargar el número de llamada al sistema para cerrar archivo
            move $a0, $t6     # Cargar el descriptor de archivo en $a0
            syscall

            addi $t0, $t0, 1   # Incrementar el contador de alarmas generadas

                skip:
            addi $t1, $t1, 1   # Incrementar el índice de comparación
            blt $t1, $a2, Inner_loop1   # Repetir el bucle interno si no se han comparado todos los elementos

        addi $t0, $t0, 1   # Incrementar el contador de alarmas generadas

    # Restaurar los registros guardados
    lw $ra, 0($sp)    # Cargar la dirección de retorno
    lw $s0, 4($sp)    # Cargar el valor de $s0
    lw $s1, 8($sp)    # Cargar el valor de $s1
    addi $sp, $sp, 12  # Restaurar el puntero de pila

    # Salir de la función y volver a la dirección de retorno
    jr $ra

    # Generar archivo de alarmas generadas (Alerts_Triggered.log)
    la $a0, sorted_logs_table  # Cargar la dirección de la tabla de logs ordenada
    la $a1, alerts_table  # Cargar la dirección de la tabla de alertas
    li $a2, 200   # Tamaño de la tabla de logs/alertas
    la $a3, alerts_triggered  # Cargar la dirección de la tabla de alarmas generadas
    jal generate_alerts_file

    # Realizar búsqueda y generar reporte (Report.log)
    la $a0, logs_table  # Cargar la dirección de la tabla de logs
    li $a1, 200   # Tamaño de la tabla de logs
    li $v0, 5   # Cargar el número de llamada al sistema para leer una entrada del usuario
    syscall
    move $t0, $v0   # Guardar la entrada del usuario en $t0
    jal search_and_generate_report

    # Salir del programa
    li $v0, 10   # Cargar el número de llamada al sistema para salir del programa
    syscall

# Función para ordenar la tabla de logs por fecha en formato epoch
sort_logs:
    # Guardar los registros necesarios
    addi $sp, $sp, -12
    sw $ra, 0($sp)    # Guardar la dirección de retorno
    sw $s0, 4($sp)    # Guardar el valor de $s0
    sw $s1, 8($sp)    # Guardar el valor de $s1

    move $s0, $a0     # Guardar la dirección de la tabla de logs en $s0
    move $s1, $a1     # Guardar la dirección de la tabla de logs ordenada en $s1

    li $t0, 0         # Inicializar el contador de iteraciones en 0

outer_loop:
    li $t1, 0         # Inicializar el índice de comparación en 0

inner_loop:
    mul $t2, $t1, 12  # Multiplicar el índice por 12 para obtener el desplazamiento en bytes
    mul $t3, $t1, 12  # Multiplicar el índice por 12 para obtener el desplazamiento en bytes
    add $t2, $s0, $t2 # Calcular la dirección del elemento actual en la tabla de logs
    add $t3, $s0, $t3 # Calcular la dirección del elemento siguiente en la tabla de logs
    lw $t4, 0($t2)    # Cargar la fecha del elemento actual en $t4
    lw $t5, 0($t3)    # Cargar la fecha del elemento siguiente en $t5

       ble $t4, $t5, no_swap   # Saltar si la fecha actual es menor o igual a la fecha siguiente

    # Intercambiar los elementos en la tabla de logs
    sw $t5, 0($t2)    # Guardar la fecha siguiente en la posición actual
    sw $t4, 0($t3)    # Guardar la fecha actual en la posición siguiente

    no_swap:
    addi $t1, $t1, 1  # Incrementar el índice de comparación
    blt $t1, $a2, inner_loop   # Repetir el bucle interno si no se han comparado todos los elementos

    addi $t0, $t0, 1  # Incrementar el contador de iteraciones
    blt $t0, $a2, outer_loop   # Repetir el bucle externo si no se han realizado todas las iteraciones

    # Copiar la tabla de logs ordenada a la tabla de logs original
    move $t0, $s0     # Cargar la dirección de la tabla de logs en $t0
    move $t1, $s1     # Cargar la dirección de la tabla de logs ordenada en $t1
    li $t2, 0         # Inicializar el índice en 0

copy_loop:
    mul $t3, $t2, 12  # Multiplicar el índice por 12 para obtener el desplazamiento en bytes
    add $t3, $t3, $t1 # Calcular la dirección del elemento en la tabla de logs ordenada
    lw $t4, 0($t3)    # Cargar el elemento de la tabla de logs ordenada en $t4
    add $t3, $t3, $t0 # Calcular la dirección del elemento en la tabla de logs
    sw $t4, 0($t3)    # Guardar el elemento en la tabla de logs original

    addi $t2, $t2, 1  # Incrementar el índice
    blt $t2, $a2, copy_loop   # Repetir el bucle de copia si no se han copiado todos los elementos

 # Restaurar los registros
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12

    # Abrir el archivo "Alerts_Triggered.log" para escritura
    li $v0, 13
    la $a0, alerts_triggered_filename
    li $a1, 1
    syscall

    # Guardar el descriptor de archivo en $v0
    move $t0, $v0

    # Escribir las alarmas generadas en el archivo "Alerts_Triggered.log"
    move $a0, $t0     # Cargar el descriptor de archivo en $a0
    la $a1, alerts_triggered_table   # Cargar la dirección de la tabla de alarmas generadas en $a1
    li $a2, 200   # Tamaño de la tabla de alarmas generadas
    jal write_alerts_to_file

    # Cerrar el archivo "Alerts_Triggered.log"
    li $v0, 16
    move $a0, $t0     # Cargar el descriptor de archivo en $a0
    syscall

    # Realizar búsqueda y generar reporte (Report.log)
    la $a0, logs_table  # Cargar la dirección de la tabla de logs
    li $a1, 200   # Tamaño de la tabla de logs
    li $v0, 5   # Cargar el número de llamada al sistema para leer una entrada del usuario
    syscall
    move $t0, $v0   # Guardar la entrada del usuario en $t0
    jal search_and_generate_report

search_and_generate_report:
    # Guardar los registros necesarios
    addi $sp, $sp, -12
    sw $ra, 0($sp)    # Guardar la dirección de retorno
    sw $s0, 4($sp)    # Guardar el valor de $s0
    sw $s1, 8($sp)    # Guardar el valor de $s1

    # Inicializar variables
    move $s0, $a0     # Guardar la dirección de la tabla de logs en $s0
    li $s1, 0         # Inicializar el contador de coincidencias en 0

    # Leer la opción del usuario (1 para búsqueda por IP, 2 para búsqueda por usuario)
    li $v0, 5
    syscall
    move $t0, $v0

    # Leer el valor de búsqueda del usuario
    li $v0, 8
    la $a0, buffer
    li $a1, 200
    syscall

    # Recorrer la tabla de logs y buscar coincidencias
    li $t1, 0         # Inicializar el índice de la tabla de logs en 0
    la $a0, buffer    # Cargar la dirección del valor de búsqueda
    move $a1, $t0     # Cargar la opción de búsqueda en $a1
    move $a2, $s0     # Cargar la dirección de la tabla de logs en $a2
    move $a3, $s1     # Cargar el contador de coincidencias en $a3
    jal search_logs

# Recorrer la tabla de logs y buscar coincidencias
li $t1, 0         # Inicializar el índice de la tabla de logs en 0
la $a0, buffer    # Cargar la dirección del valor de búsqueda
move $a1, $t0     # Cargar la opción de búsqueda en $a1
move $a2, $s0     # Cargar la dirección de la tabla de logs en $a2
move $a3, $s1     # Cargar el contador de coincidencias en $a3
jal search_logs

# Mostrar el número de coincidencias encontradas
move $a0, $s1     # Cargar el contador de coincidencias en $a0
li $v0, 1         # Cargar el número de llamada al sistema para imprimir un entero
syscall

# Abrir el archivo "Report.log" para escritura
li $v0, 13
la $a0, report_filename
li $a1, 1
syscall

# Guardar el descriptor de archivo en $v0
move $t0, $v0

# Escribir el reporte en el archivo "Report.log"
move $a0, $t0     # Cargar el descriptor de archivo en $a0
la $a1, report_table   # Cargar la dirección de la tabla de reporte en $a1
li $a2, 200   # Tamaño de la tabla de reporte
jal write_report_to_file

# Cerrar el archivo "Report.log"
li $v0, 16
move $a0, $t0     # Cargar el descriptor de archivo en $a0
syscall

# Guardar los registros necesarios
addi $sp, $sp, -12
sw $ra, 0($sp)    # Guardar la dirección de retorno
sw $s0, 4($sp)    # Guardar el valor de $s0
sw $s1, 8($sp)    # Guardar el valor de $s1

# Ordenar la tabla de logs por fecha en formato epoch
la $a0, logs_table  # Cargar la dirección de la tabla de logs
la $a1, sorted_logs_table  # Cargar la dirección de la tabla de logs ordenada
li $a2, 200   # Tamaño de la tabla de logs
jal sort_logs

# Restaurar los registros
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addi $sp, $sp, 12

# Terminar la ejecución del programa
li $v0, 10
syscall

# Función para buscar coincidencias en la tabla de logs
# Entradas:
#   $a0: dirección del valor de búsqueda
#   $a1: opción de búsqueda (1 para búsqueda por IP, 2 para búsqueda por usuario)
#   $a2: dirección de la tabla de logs
#   $a3: contador de coincidencias

search_logs:
    # Guardar los registros necesarios
    addi $sp, $sp, -8
    sw $ra, 0($sp)    # Guardar la dirección de retorno
    sw $s1, 4($sp)    # Guardar el valor de $s1

    li $s1, 0         # Inicializar el contador de coincidencias en 0

    # Recorrer la tabla de logs y buscar coincidencias
    loop:
        mul $t2, $t1, 12  # Multiplicar el índice por 12 para obtener el desplazamiento en bytes
        mul $t3, $t1, 12  # Multiplicar el índice por 12 para obtener el desplazamiento en bytes
        add $t2, $s0, $t2 # Calcular la dirección del elemento actual en la tabla de logs
        add $t3, $s0, $t3 # Calcular la dirección del elemento siguiente en la tabla de logs
        lw $t4, 0($t2)    # Cargar la fecha del elemento actual en $t4
        lw $t5, 0($t3)    # Cargar la fecha del elemento siguiente en $t5

        # Comparar las fechas para determinar si hay coincidencia
        beq $t4, $t5, equal_dates    # Saltar a equal_dates si las fechas son iguales
        bne $t4, $t5, not_equal_dates    # Saltar a not_equal_dates si las fechas son diferentes

    equal_dates:
        # Las fechas son iguales, continuar comparando según la opción de búsqueda
        beq $a1, 1, compare_ip    # Saltar a compare_ip si la opción de búsqueda es 1 (búsqueda por IP)
        beq $a1, 2, compare_user    # Saltar a compare_user si la opción de búsqueda es 2 (búsqueda por usuario)

    compare_ip:
        # Comparar las direcciones IP
        lw $t6, 4($t2)    # Cargar la dirección IP del elemento actual en $t6
        lw $t7, 4($a0)    # Cargar la dirección IP de búsqueda en $t7
        beq $t6, $t7, found_match    # Saltar a found_match si hay coincidencia
        j continue_loop    # Saltar a continue_loop para continuar el bucle

    compare_user:
    # Comparar los usuarios
    lw $t6, 8($t2)    # Cargar el usuario del elemento actual en $t6
    lw $t7, 4($a0)    # Cargar el usuario de búsqueda en $t7
    beq $t6, $t7, found_match    # Saltar a found_match si hay coincidencia
    j continue_loop    # Saltar a continue_loop para continuar el bucle

not_equal_dates:
    # Las fechas son diferentes, continuar al siguiente elemento
    j continue_loop    # Saltar a continue_loop para continuar el bucle

found_match:
    # Se encontró una coincidencia, incrementar el contador
    addi $s1, $s1, 1

continue_loop:
    # Actualizar el índice y comprobar si se ha recorrido toda la tabla
    addi $t1, $t1, 1   # Incrementar el índice en 1
    li $t2, 200        # Cargar el tamaño de la tabla de logs en $t2
    blt $t1, $t2, loop   # Saltar a loop si el índice es menor que el tamaño de la tabla

    # Restaurar los registros
    lw $ra, 0($sp)    # Cargar la dirección de retorno
    lw $s1, 4($sp)    # Cargar el valor de $s1
    addi $sp, $sp, 8  # Restaurar el puntero de pila

    # Retornar al llamador
    jr $ra
    
 
    
    
