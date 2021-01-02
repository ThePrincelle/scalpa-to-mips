.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:

	li $t1 10
end:
	li $v0 10
	syscall

error:
	la $a0 errorMessage
	li $v0 4
	syscall
	li $v0 10
	syscall