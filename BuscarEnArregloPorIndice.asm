.data
arr: .word 10, 20, 30, 40, 50  # arreglo de n�meros
prompt: .asciiz "Ingrese el valor a buscar: "
found_msg: .asciiz "El valor se encuentra en el �ndice: "
not_found_msg: .asciiz "El valor no se encuentra en el arreglo"

.text
.globl main

main:
    # Imprimir prompt
    la $a0, prompt
    li $v0, 4
    syscall
    
    # Leer valor a buscar
    li $v0, 5
    syscall
    move $t0, $v0
    
    # Inicializar �ndice y bandera de encontrado
    li $t1, 0
    li $t2, 0
    
    # Recorrer el arreglo
    la $t3, arr  # cargar direcci�n base del arreglo
    la $t4, arr + 20  # cargar direcci�n final del arreglo
    loop:
        beq $t3, $t4, not_found  # si se llega al final del arreglo sin encontrar el valor, imprimir mensaje de no encontrado
        
        lw $t5, ($t3)  # cargar valor actual del arreglo
        beq $t0, $t5, found  # si se encuentra el valor, guardar �ndice y salir del ciclo
        
        addi $t3, $t3, 4  # incrementar direcci�n del arreglo
        addi $t1, $t1, 1  # incrementar �ndice
        j loop  # continuar ciclo
        
    # Imprimir mensaje de valor encontrado
    found:
        la $a0, found_msg
        li $v0, 4
        syscall
        
        move $a0, $t1
        li $v0, 1
        syscall
        
        j exit
        
    # Imprimir mensaje de valor no encontrado
    not_found:
        la $a0, not_found_msg
        li $v0, 4
        syscall
        
    # Salir
    exit:
        li $v0, 10
        syscall
