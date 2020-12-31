
	.text
#	mainOnly
main:
	li $t2 4
	li $t2 4
	li $a3 $t1
	li $a4 $t2
	jal pow
	li $v0 1
	syscall
	
	
pow:
	mul $a3 $a3 $a3
	add $t9 $t9 1 
	beq $t9 $a4 pow
	jr $ra
	