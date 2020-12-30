
	.text
#	mainOnly
main:
	li $a0 0
	seq $t6 $a0 $zero
	la $a0, ($t6)
	li $v0 1
	syscall