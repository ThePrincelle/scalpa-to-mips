	.text
#	mainOnly
main:

	addi $sp, $sp, 0
	li $t1 0
	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall