	.text
#	mainOnly
main:

	li $t1 0
	li $t2 0

	xor $t1 $t1 $t2
	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall