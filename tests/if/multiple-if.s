.data
	errorMessage:	.asciiz	"Error Syntax run time"
	readMessage:	.asciiz	"Please write an int and 0 for false and 1 for true:\n"

	.text
#	mainOnly
main:
	li $t0 1
	li $t1 1
	seq $t0 $t0 $t1
	beq $t0 0 endIf0
	li $t0 1
	li $t1 1
	seq $t0 $t0 $t1
	beq $t0 0 endIf0
	li $t0 1
	li $t1 1
	seq $t0 $t0 $t1
	beq $t0 0 endIf0
	li $t0 1
	move $a0 $t0
	li $v0 1
	syscall
	j endIf0
endIf0:
	j endIf1
endIf1:
	j endIf2
endIf2:
	li $t0 1
	li $t1 1
	seq $t0 $t0 $t1
	beq $t0 0 endIf3
	li $t0 1
	move $a0 $t0
	li $v0 1
	syscall
	j endIf3
endIf3:
end:
	li $v0 10
	syscall

error:
	la $a0 errorMessage
	li $v0 4
	syscall
	li $v0 10
	syscall