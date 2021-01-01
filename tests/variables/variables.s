	.text
#	mainOnly
main:


	addi $sp, $sp, -12

	li $t1 10
	sw $t1 8($sp)

	li $t1 8
	sw $t1 4($sp)

	li $t1 2
	sw $t1 0($sp)

	lw $t1 0($sp)
	move $a0 $t1
	li $v0 1
	syscall

	lw $t2 4($sp)
	move $a0 $t2
	li $v0 1
	syscall

	lw $t3 8($sp)
	move $a0 $t3
	li $v0 1
	syscall

	li $v0 10
	syscall
