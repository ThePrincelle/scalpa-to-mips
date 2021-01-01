	.text
#	mainOnly
main:


	li $t1 0

	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall