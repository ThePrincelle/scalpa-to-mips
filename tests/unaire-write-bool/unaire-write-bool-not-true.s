.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"
	.text
#	mainOnly
main:

	li $t0 1
	seq $t0 $t0 $zero
	move $a0 $t6
	move $a0 $t0
	li $v0 1
	syscall
end:
	li $v0 10
	syscall

error:
	la $a0 errorMessage
	li $v0 4
	syscall
	li $v0 10
	syscall