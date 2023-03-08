.data

prompt1: .asciiz  "\Enter an integer to partition (n): "
prompt2: .asciiz  "\Enter an integer for size of the partition (m): "
result: .asciiz "\nThe result is: "

.text

main:
      la $a0,  prompt1          
      li $v0,4
      syscall              

      li $v0, 5
      syscall		
      move $t0, $v0	# $t0 = n
      
      la $a0,  prompt2          
      li $v0,4
      syscall              

      li $v0, 5
      syscall		
      move $t1, $v0	# $t1 = m
      
      add $a0, $t0, $zero #$a0 = n
      add $a1, $t1, $zero #$a1 = m
     
      jal count_partitions

	move $t0, $v0
	la $a0, result
	li $v0, 4
	syscall
	
      move $a0,$t0        
      li $v0, 1
      syscall

      li $v0, 10
      syscall
	
count_partitions:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	beqz	$a0, return1 #if n is zero return1
	blt	$a0, 0, return0  #else if n is lt zero return0
	beqz	$a1, return0 #else if m is zero return0
	
	# else proceed to recursion
branch1:
	subi	$a1, $a1, 1 # call with m-1
	jal	count_partitions
	addi	$a1, $a1, 1 # revert m
	
	addi	$sp, $sp, -4
	sw	$v0, 0($sp) # save the return value of Branch1

branch2:
	sub	$a0, $a0, $a1 # call with n-m
	jal	count_partitions
	add	$a0, $a0, $a1 # revert n
	
	lw	$t0, 0($sp) # take the return value of branch1 
	add	$v0, $t0, $v0 # combine the return value of branch2 with the return value of branch1
	lw	$ra, 4($sp) # retrieve the return adress
	addi	$sp, $sp, 8
	
	jr 	$ra
	
return1:
	li 	$v0, 1
	addi	$sp, $sp, 4
	jr 	$ra
	
return0:
	li 	$v0, 0
	addi	$sp, $sp, 4
	jr 	$ra

      		
