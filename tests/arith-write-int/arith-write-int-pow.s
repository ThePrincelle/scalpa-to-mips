	.text
#	mainOnly
main:

	addi $sp, $sp, 0
	li $t1 2
	li $t2 4
	move $a2 $t1
	move $a3 $t2
	move $t8 $a2
	jal pow
	move $t1 $t8
	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall
pow:
	mul $t8 $t8 $a2
	add $t9 $t9 1
	bne $t9 $a3 pow
	jr $ra
	