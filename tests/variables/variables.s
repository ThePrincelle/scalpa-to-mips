	.text
#	mainOnly
main:


	addi $sp, $sp, -12

	li $t1 2
	sw $t1 0($sp)

	lw $t1 0($sp)

	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall
