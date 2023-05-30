.data
array:  .word   5, 2, 4, 6, 1, 3   # arreglo de ejemplo
n:      .word   6                 # tama�o del arreglo

.text
.globl main

main:
    # Inicializaci�n de variables
    la $t0, array      # direcci�n base del arreglo
    lw $t1, n          # tama�o del arreglo
    addi $t1, $t1, -1  # �ndice m�ximo
    li $t2, 1          # flag de intercambio

    # Ciclo externo del ordenamiento de burbuja
    j sort_outer_loop
sort_outer_loop:
    move $t3, $zero    # �ndice actual

    # Ciclo interno del ordenamiento de burbuja
    j sort_inner_loop
sort_inner_loop:
    add $t4, $t0, $t3  # direcci�n actual del elemento
    lw $t5, 0($t4)     # carga el valor actual
    lw $t6, 4($t4)     # carga el valor siguiente

    # Compara y intercambia si es necesario
    ble $t5, $t6, sort_no_swap
    sw $t6, 0($t4)
    sw $t5, 4($t4)
    li $t2, 1          # indica que se hizo un intercambio
sort_no_swap:
    addi $t3, $t3, 4   # avanza al siguiente elemento

    # Verifica si lleg� al final del arreglo interno
    bne $t3, $t1, sort_inner_loop

    # Verifica si se hizo un intercambio en el ciclo interno
    beqz $t2, sort_done
    li $t2, 0          # resetea el flag de intercambio
    addi $t1, $t1, -4  # disminuye el �ndice m�ximo
    j sort_outer_loop

sort_done:
    # Salida
    li $v0, 10         # syscall para salir del programa
    syscall
