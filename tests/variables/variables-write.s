.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:



	addi $sp, $sp, -16

	li $t0 10
	sw $t0 8($sp)

	li $t0 1
	sw $t0 12($sp)

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

	lw $t0 8($sp)
	move $a0 $t0
	li $v0 1
	syscall

	lw $t0 12($sp)
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