.data
    x: .word 0
    y: .word 0
    sum: .word 0
    prompt_x: .asciiz "Ingrese el primer número en binario: "
    prompt_y: .asciiz "Ingrese el segundo número en binario: "
    prompt_sum: .asciiz "La suma de los números en binario es: "

.text
    .globl main
main:
    # Solicitar al usuario que ingrese x e y en binario
    li $v0, 4
    la $a0, prompt_x
    syscall

    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, x

    li $v0, 4
    la $a0, prompt_y
    syscall

    li $v0, 5
    syscall
    move $t1, $v0
    sw $t1, y

    # Inicializar las variables sum, carry, i
    li $t2, 0       # sum
    li $t3, 0       # carry
    li $t4, 0       # i

while_loop:
    # Obtener los bits menos significativos de x e y
    lw $t5, x
    andi $t6, $t5, 1
    lw $t5, y
    andi $t7, $t5, 1

    # Sumar los bits de x e y con el carry anterior
    add $t8, $t6, $t7
    add $t8, $t8, $t3

    # Calcular el bit actual de la suma y agregarlo a sum
    andi $t9, $t8, 1
    sll $t10, $t9, $t4
    add $t2, $t2, $t10

    # Actualizar carry y avanzar en la posición de los bits
    srl $t3, $t8, 1
    addi $t4, $t4, 1

    # Verificar si quedan bits en x o y para seguir sumando
    lw $t5, x
    lw $t6, y
    or $t5, $t5, $t6
    bne $t5, $0, while_loop

    # Si queda carry pendiente, agregarlo a sum
    bne $t3, $zero, add_carry
    j print_sum

add_carry:
    sll $t11, $t3, $t4
    add $t2, $t2, $t11

print_sum:
    # Mostrar el resultado de la suma en binario
    li $v0, 4
    la $a0, prompt_sum
    syscall

    lw $a0, sum
    li $v0, 1
    syscall

    # Salir del programa
    li $v0, 10
    syscall
