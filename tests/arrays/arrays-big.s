.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:




	addi $sp, $sp, -6412

	li $t1 -3
	li $t2 1
	li $t3 2
	li $t4 1
	li $t5 10
	move $t6 $t1
	move $t1 $t5
	move $t5 $t6
	li $t6 -3
	bgt $t5 $t6 error
	li $t6 -4
	blt $t5 $t6 error
	sub $t5 $t5 $t6

	li $t6 100
	bgt $t2 $t6 error
	li $t6 1
	blt $t2 $t6 error
	sub $t6 $t2 $t6
	mul $t5 $t6 $t5

	li $t6 4
	bgt $t3 $t6 error
	li $t6 1
	blt $t3 $t6 error
	sub $t6 $t3 $t6
	mul $t5 $t6 $t5

	li $t6 2
	bgt $t4 $t6 error
	li $t6 1
	blt $t4 $t6 error
	sub $t6 $t4 $t6
	mul $t5 $t6 $t5


    move $a0 $t5
	li $v0 1
	syscall
	li $t2 4
	add $t2 $t2 $t5
	move $a0 $t2
	li $v0 1
	syscall
	add $t2, $sp, $t2
	sw $t1 0($t2)

	li $t1 -3
	li $t2 1
	li $t3 2
	li $t4 1
	li $t5 -3
	bgt $t1 $t5 error
	li $t5 -4
	blt $t1 $t5 error
	sub $t5 $t1 $t5

	li $t5 100
	bgt $t2 $t5 error
	li $t5 1
	blt $t2 $t5 error
	sub $t6 $t2 $t6
	mul $t5 $t6 $t5

	li $t5 4
	bgt $t3 $t5 error
	li $t5 1
	blt $t3 $t5 error
	sub $t6 $t3 $t6
	mul $t5 $t6 $t5

	li $t5 2
	bgt $t4 $t5 error
	li $t5 1
	blt $t4 $t5 error
	sub $t6 $t4 $t6
	mul $t5 $t6 $t5

	li $t1 4
	add $t2 $t1 $t5
	add $t2, $sp, $t2
	lw $t1 0($t2)

end:
	li $v0 10
	syscall


error:
	la $a0 errorMessage
	li $v0 4
	syscall
	li $v0 10
	syscall