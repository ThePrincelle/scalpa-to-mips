.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"
	.text
#	mainOnly
main:




	addi $sp, $sp, -6412

	li $t0 -3
	li $t1 1
	li $t2 2
	li $t3 1
	li $t4 10
	move $t5 $t0
	move $t0 $t4
	move $t4 $t5
	li $t5 -3
	bgt $t4 $t5 error
	li $t5 -4
	blt $t4 $t5 error
	sub $t4 $t4 $t5
	mul $t6 $t4 800


	li $t5 100
	bgt $t1 $t5 error
	li $t5 1
	blt $t1 $t5 error
	sub $t5 $t1 $t5
	mul $t5 $t5 8
	add $t6 $t5 $t6

	li $t5 4
	bgt $t2 $t5 error
	li $t5 1
	blt $t2 $t5 error
	sub $t5 $t2 $t5
	mul $t5 $t5 2
	add $t6 $t5 $t6

	li $t5 2
	bgt $t3 $t5 error
	li $t5 1
	blt $t3 $t5 error
	sub $t5 $t3 $t5
	mul $t5 $t5 1
	add $t6 $t5 $t6

	li $t1 4
	add $t1 $t1 $t6
	mul $t1 $t1   4
	add $t1, $sp, $t1
	sw $t0 0($t1)

	li $t0 -3
	li $t1 1
	li $t2 2
	li $t3 1
	li $t4 -3
	bgt $t0 $t4 error
	li $t4 -4
	blt $t0 $t4 error
	sub $t4 $t0 $t4
	mul $t5 $t4 800


	li $t4 100
	bgt $t1 $t4 error
	li $t4 1
	blt $t1 $t4 error
	sub $t4 $t1 $t4
	mul $t4 $t4 8
	add $t5 $t4 $t5

	li $t4 4
	bgt $t2 $t4 error
	li $t4 1
	blt $t2 $t4 error
	sub $t4 $t2 $t4
	mul $t4 $t4 2
	add $t5 $t4 $t5

	li $t4 2
	bgt $t3 $t4 error
	li $t4 1
	blt $t3 $t4 error
	sub $t4 $t3 $t4
	mul $t4 $t4 1
	add $t5 $t4 $t5

	li $t0 4
	add $t0 $t0 $t5
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