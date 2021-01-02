.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:




	addi $sp, $sp, -812

	li $t1 -3
	li $t2 1
	li $t3 10
	move $t4 $t1
	move $t1 $t3
	move $t3 $t4
	li $t4 -3
	bgt $t3 $t4 error
	li $t4 -4
	blt $t3 $t4 error
	sub $t3 $t3 $t4
	mul $t5 $t3 100


	li $t4 100
	bgt $t2 $t4 error
	li $t4 1
	blt $t2 $t4 error
	sub $t4 $t2 $t4
	mul $t4 $t4 1
	add $t5 $t4 $t5

	li $t2 4
	add $t2 $t2 $t5
	add $t2, $sp, $t2
	sw $t1 0($t2)

	li $t1 -3
	li $t2 1
	li $t3 -3
	bgt $t1 $t3 error
	li $t3 -4
	blt $t1 $t3 error
	sub $t3 $t1 $t3
	mul $t4 $t2 100


	li $t3 100
	bgt $t2 $t3 error
	li $t3 1
	blt $t2 $t3 error
	sub $t3 $t2 $t3
	mul $t3 $t3 1
	add $t4 $t3 $t4

	li $t1 4
	add $t2 $t1 $t4
	add $t2, $sp, $t2
	lw $t1 0($t2)
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