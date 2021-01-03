.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"
	.text
#	mainOnly
main:


	addi $sp, $sp, -28

	li $t0 2
	li $t1 2
	la $a0 readMessage
	li $v0 4
	syscall
	li $v0 5
	syscall
	move $t2 $v0
	li $t3 3
	bgt $t0 $t3 error
	li $t3 1
	blt $t0 $t3 error
	sub $t3 $t0 $t3
	mul $t4 $t3 2


	li $t3 2
	bgt $t1 $t3 error
	li $t3 1
	blt $t1 $t3 error
	sub $t3 $t1 $t3
	mul $t3 $t3 1
	add $t4 $t3 $t4

	li $t0 0
	add $t0 $t0 $t4
	mul $t0 $t0   4
	add $t0, $sp, $t0
	sw $t2 0($t0)

	li $t0 2
	li $t1 2
	li $t2 3
	bgt $t0 $t2 error
	li $t2 1
	blt $t0 $t2 error
	sub $t2 $t0 $t2
	mul $t3 $t2 2


	li $t2 2
	bgt $t1 $t2 error
	li $t2 1
	blt $t1 $t2 error
	sub $t2 $t1 $t2
	mul $t2 $t2 1
	add $t3 $t2 $t3

	li $t0 0
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