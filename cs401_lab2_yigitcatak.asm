.data

array1: .word 1, 1, 2, 2, 3, 3, 4, 4, 5, 5 
array2: .word 2, 2, 3, 3, 4, 4, 5, 5, 6, 6 

tempArray1: .space 40 #for storing different elements in array1
tempArray2: .space 40 #for storing different elements in array2


message: .asciiz "The sum of the same elements is "

.text


main:
	la $a0, array1 
	la $a1, tempArray1 
      	jal DiffElement  
      	move $s0, $v0 
      	
      	la $a0, array2 
	la $a1, tempArray2 
      	jal DiffElement  
     	move $s1, $v0

     	la $a0, tempArray1
     	move $a1, $s0
     	la $a2, tempArray2
     	move $a3, $s1
     	
     	jal SumofElements
     	
     	move $t0, $v0
     	
     	la $a0, message
     	li $v0, 4
     	syscall	
     	
      	move $a0, $t0  
      	li $v0,1
      	syscall
      	
      	li $v0, 10
      	syscall
     
	
DiffElement:
	#initialization
	lw	$t0, 0($a0)
	sw	$t0, 0($a1)
	addi	$v0, $zero, 1 #a2 for unique count
	addi	$t0, $zero, 4 #t0 for array index
	
outterloop:
	beq	$t0, 40, DiffelementEnd # while i < 40
		add	$t1, $a0, $t0
		lw	$t2, 0($t1) # array[i]
		add	$t3, $zero, $zero # j = 0
innerloop:
		add	$t6, $v0, $v0
		add	$t6, $t6, $t6
		beq	$t3, $t6, quitinnerloop # while j < length(temparray)
			add	$t4, $a1, $t3
			lw	$t5, 0($t4) # temparray[j]
			beq	$t5, $t2 abortinnerloop # same element exists, abort 
			addi	$t3, $t3, 4 # j++
			j	innerloop
quitinnerloop:
		# no matching item found in the temparray, insert to end ($t3 is already at the end)
		add	$t3, $a1, $t3
		sw	$t2, 0($t3) # temparray[j]
		addi	$v0, $v0, 1 # length(temparray)++
abortinnerloop:
		addi	$t0, $t0, 4 # i++
		j	outterloop
		
DiffelementEnd:
	jr	$ra

SumofElements:
	#initialization
	add	$a1, $a1, $a1
	add	$a1, $a1, $a1 # length(temparray1)
	
	add	$a3, $a3, $a3
	add	$a3, $a3, $a3 # length(temparray2)
	
	add	$t0, $zero, $zero # i = 0
	add	$v0, $zero, $zero # sum = 0
outterloop2:
	beq	$t0, $a1, SumofElementsEnd # while i < length(temparray1)
		add	$t2, $a0, $t0
		lw	$t3, 0($t2) # temparray[i]
		add	$t1, $zero, $zero # j = 0
innerloop2:
		beq	$t1, $a3 quitinnerloop2 # while j < length(temparray1)
			add	$t4, $a2, $t1
			lw	$t5, 0($t4) # temparray[j]
			beq	$t3, $t5, foundequal
			addi	$t1, $t1, 4 # j++
			j 	innerloop2
foundequal:
			add	$v0, $v0, $t3
quitinnerloop2:
		addi	$t0, $t0, 4 # i++
		j	outterloop2
SumofElementsEnd:
	jr	$ra
