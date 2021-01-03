.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"

	.text
#	mainOnly
main:
	addi $sp, $sp, -4
	li $t0 0
	sw $t0 0($sp)
bwhile0:
	lw $t0 0($sp)
	li $t1 5
	slt $t0 $t0 $t1
	beq $t0 0 ewhile0
	lw $t0 0($sp)
	li $t1 1
	add $t0 $t0 $t1
	sw $t0 0($sp)
	lw $t0 0($sp)
	move $a0 $t0
	li $v0 1
	syscall
	j bwhile0
ewhile0:
end:
	li $v0 10
	syscall

error:
	la $a0 errorMessage
	li $v0 4
	syscall
	li $v0 10
	syscall