	.text
#	mainOnly
main:



	addi $sp, $sp, -8

	li $t1 1
	li $t2 3
	li $t3 10
	move $t4 $t1
	move $t1 $t3
	move $t3 $t4
	li $t4 4
	add $t3 $t3 $t4
	add $t2 $t2 $t3
	add $t2, $sp, $t2
	sw $t1 0($t2)

	li $t1 1
	li $t2 3
	li $t3 4
	add $t2 $t2 $t3
	add $t1 $t1 $t2
	add $t1, $sp, $t1
	lw $t1 0($t1)
	move $a0 $t1
	li $v0 1
	syscall

	li $v0 10
	syscall
