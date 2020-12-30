
	.text
#	mainOnly
main:
	li $a0 10
	mul $t6 $a0 -1
	la $a0, ($t6)
	li $v0 1
	syscall