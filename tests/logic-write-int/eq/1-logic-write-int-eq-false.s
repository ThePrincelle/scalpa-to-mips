	.text
#	mainOnly
main:

	li $t1 2
	li $t2 1
	seq $t1 $t1 $t2
	move $a0 $t1
	li $v0 1
	syscall
	li $v0 10
	syscall