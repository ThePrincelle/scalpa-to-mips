.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"
	.text
#	mainOnly
main:


	addi $sp, $sp, -8

	li $t0 8
	sw $t0 4($sp)

	li $t0 2
	sw $t0 0($sp)

	lw $t0 0($sp)
	move $a0 $t0
	li $v0 1
	syscall

	lw $t0 4($sp)
	move $a0 $t0
	li $v0 1
	syscall

	lw $t0 0($sp)
	lw $t1 4($sp)
	sge $t0 $t0 $t1
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