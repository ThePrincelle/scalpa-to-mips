.data
	errorMessage:	.asciiz	"Error Syntax run time"
	.text
#	mainOnly
main:




	addi $sp, $sp, -20

	li $t1 -3
	li $t2 10
	move $t3 $t1
	move $t1 $t2
	move $t2 $t3
	li $t3 -3
	bgt $t2 $t3 error
	li $t3 -4
	blt $t2 $t3 error
	sub $t2 $t2 $t3
	mul $t4 $t2 1


	li $t2 4
	add $t2 $t2 $t4
	mul $t2 $t2   4
	add $t2, $sp, $t2
	sw $t1 0($t2)

	li $t1 1
	li $t2 -3
	bgt $t1 $t2 error
	li $t2 -4
	blt $t1 $t2 error
	sub $t2 $t1 $t2
	mul $t3 $t1 1


	li $t1 4
	add $t2 $t1 $t3
	mul $t2 $t2   4
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