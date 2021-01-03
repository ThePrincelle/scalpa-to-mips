.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"
	.text
#	mainOnly
main:


	addi $sp, $sp, -4

	la $a0 readMessage
	li $v0 4
	syscall
	li $v0 5
	syscall
	move $t0 $v0
	sw $t0 0($sp)

	lw $t0 0($sp)
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