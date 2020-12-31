	.text
#	mainOnly
main:

	li $t1 10
	mul $t1 $t1 -1
	move $a0 $t6
	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall