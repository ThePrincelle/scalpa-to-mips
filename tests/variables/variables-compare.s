.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:


	addi $sp, $sp, -8

	li $t1 8
	sw $t1 4($sp)

	li $t1 2
	sw $t1 0($sp)

	lw $t1 0($sp)
	move $a0 $t1
	li $v0 1
	syscall

	lw $t1 4($sp)
	move $a0 $t1
	li $v0 1
	syscall

	lw $t1 0($sp)
	lw $t2 4($sp)
	sge $t1 $t1 $t2
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