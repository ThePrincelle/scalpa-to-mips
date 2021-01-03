.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"

	.text
#	mainOnly
main:
	addi $sp, $sp, -812
	li $t0 -3
	li $t1 1
	li $t2 10
	move $t3 $t0
	move $t0 $t2
	move $t2 $t3
	li $t3 -3
	bgt $t2 $t3 error
	li $t3 -4
	blt $t2 $t3 error
	sub $t2 $t2 $t3
	mul $t4 $t2 100


	li $t3 100
	bgt $t1 $t3 error
	li $t3 1
	blt $t1 $t3 error
	sub $t3 $t1 $t3
	mul $t3 $t3 1
	add $t4 $t3 $t4

	li $t1 4
	add $t1 $t1 $t4
	mul $t1 $t1   4
	add $t1, $sp, $t1
	sw $t0 0($t1)
	li $t0 -3
	li $t1 1
	li $t2 -3
	bgt $t0 $t2 error
	li $t2 -4
	blt $t0 $t2 error
	sub $t2 $t0 $t2
	mul $t3 $t2 100


	li $t2 100
	bgt $t1 $t2 error
	li $t2 1
	blt $t1 $t2 error
	sub $t2 $t1 $t2
	mul $t2 $t2 1
	add $t3 $t2 $t3

	li $t0 4
	add $t0 $t0 $t3
	mul $t0 $t0   4
	add $t0, $sp, $t0
	lw $t0 0($t0)
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