.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:

	li $t1 0
	move $a0 $t1
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