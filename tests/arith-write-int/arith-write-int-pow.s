.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"
	.text
#	mainOnly
main:

	li $t0 2
	li $t1 4
	move $a2 $t0
	move $a3 $t1
	move $t8 $a2
	jal pow
	move $t0 $t8
	move $a0 $t0
	li $v0 1
	syscall
end:
	li $v0 10
	syscall
pow:
	mul $t8 $t8 $a2
	add $t9 $t9 1
	bne $t9 $a3 pow
	jr $ra
	

error:
	la $a0 errorMessage
	li $v0 4
	syscall
	li $v0 10
	syscall