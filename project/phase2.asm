.data
KEY: .word 0x126b, 0x5f44, 0x6907, 0xee06, 0x2301, 0x2e17, 0x7c78, 0xbddb
IV: .word 0x7055, 0xa603, 0xa9d5, 0x7518
R: .word 0,0,0,0,0,0,0,0
ABCD: .word 0xcccc, 0xdddd, 0xeeee, 0x3333
s0: .word 0xF, 0x4, 0x5, 0x8, 0x9, 0x7, 0x2, 0x1, 0xA, 0x3, 0x0, 0xE, 0x6, 0xC, 0xD, 0xB
s1: .word 0x4, 0xA, 0x1, 0x6, 0x8, 0xF, 0x7, 0xC, 0x3, 0x0, 0xE, 0xD, 0x5, 0x9, 0xB, 0x2
s2: .word 0x2, 0xF, 0xC, 0x1, 0x5, 0x6, 0xA, 0xD, 0xE, 0x8, 0x3, 0x4, 0x0, 0xB, 0x9, 0x7
s3: .word 0x7, 0xC, 0xE, 0x9, 0x2, 0x1, 0x5 ,0xF, 0xB, 0x6, 0xD, 0x0, 0x4, 0x8, 0xA, 0x3
nl: .asciiz "\n"
.text

# Actual main
la	$a0, R
la	$a1, IV
la	$a2, KEY
la	$a3, ABCD
jal	Initialize

la	$t0, R
la	$t1, nl

add	$t2, $zero, $zero
printloop:
beq	$t2, 8, exit
lw 	$a0, 0($t0)
li	$v0,34
syscall
move	$a0, $t1
li	$v0,4
syscall
addi	$t0, $t0, 4
addi	$t2, $t2, 1
j	printloop

exit:
li $v0, 10 
syscall

######## NEW FUNCTIONS #############
Initialize:
addi	$sp, $sp, -32
sw	$ra, 0($sp)
sw	$a0, 4($sp) #save original R address
sw	$a2, 8($sp) #save original KEY address
sw	$a3, 12($sp) #save original ABCD address
sw	$s0, 16($sp) #s0 for loop index i
sw	$s1, 20($sp) #s1 for t0 in algorithm
sw	$s2, 24($sp) #s2 for t1 in algorithm
sw	$s3, 28($sp) #s3 for t2 in algorithm

####################################
##### IV initialization works ######
####################################
# R0, R4 <- IV0
lw	$t0, 0($a1) #IV0
sw	$t0, 0($a0)
sw	$t0, 16($a0)

# R1, R5 <- IV1
lw	$t0, 4($a1) #IV1
sw	$t0, 4($a0)
sw	$t0, 20($a0)

# R2, R6 <- IV2
lw	$t0, 8($a1) #IV2
sw	$t0, 8($a0)
sw	$t0, 24($a0)

# R3, R7 <- IV3
lw	$t0, 12($a1) #IV3
sw	$t0, 12($a0)
sw	$t0, 28($a0)

add	$s0, $zero, $zero
InitializeLoop:
beq	$s0, 4, continue

####################################
######## Function W works ##########
####### Key selection works ########
####################################
# get KEY 0,1,2,3 and set them to ABCD
lw	$t0, 0($a2)
lw	$t1, 4($a2)
lw	$t2, 8($a2)
lw	$t3, 12($a2)
sw	$t0, 0($a3)
sw	$t1, 4($a3)
sw	$t2, 8($a3)
sw	$t3, 12($a3)
# get R0 value and add i
lw	$a0, 0($a0)
add	$a0, $a0, $s0 #R0 + i
andi	$a0, 0xffff
move	$a1, $a3 # set base address of ABCD to $a1, as an input to FunctionW
jal	FunctionW
move	$s1, $v0 #s1 is t0

# retrieve the original addresses of a registers as they might change
# during a function call. Even if I could ensure that it does not change
# it is not guaranteed that enduser makes sure that it does not change.
# Therefore, I just wanted to follow the common conventions and make the
# functions as error-proof as possible
lw	$a0, 4($sp)
lw	$a2, 8($sp)
lw	$a3, 12($sp)

# get KEY 4,5,6,7 and set them to ABCD
lw	$t0, 16($a2)
lw	$t1, 20($a2)
lw	$t2, 24($a2)
lw	$t3, 28($a2)
sw	$t0, 0($a3)
sw	$t1, 4($a3)
sw	$t2, 8($a3)
sw	$t3, 12($a3)

lw	$a0, 4($a0)
add	$a0, $a0, $s1 #R1 + t0
andi	$a0, 0xffff
move	$a1, $a3  #set a3
jal	FunctionW
move	$s2, $v0 #s2 is t1

lw	$a0, 4($sp)
lw	$a2, 8($sp)
lw	$a3, 12($sp) 

# get KEY 0,2,4,6 and set them to ABCD
lw	$t0, 0($a2)
lw	$t1, 8($a2)
lw	$t2, 16($a2)
lw	$t3, 24($a2)
sw	$t0, 0($a3)
sw	$t1, 4($a3)
sw	$t2, 8($a3)
sw	$t3, 12($a3)

lw	$a0, 8($a0)
add	$a0, $a0, $s2 #R2 + t1
andi	$a0, 0xffff
move	$a1, $a3
jal	FunctionW
move	$s3, $v0 #s3 is t2

lw	$a0, 4($sp)
lw	$a2, 8($sp)
lw	$a3, 12($sp) 

addi	$s0, $s0, 1

# get KEY 1,3,5,7 and set them to ABCD
lw	$t0, 4($a2)
lw	$t1, 12($a2)
lw	$t2, 20($a2)
lw	$t3, 28($a2)
sw	$t0, 0($a3)
sw	$t1, 4($a3)
sw	$t2, 8($a3)
sw	$t3, 12($a3)

lw	$a0, 12($a0)
add	$a0, $a0, $s3 #R3 + t2
andi	$a0, 0xffff
move	$a1, $a3
jal	FunctionW
move	$s4, $v0 #s4 is t3

lw	$a0, 4($sp)
lw	$a2, 8($sp)
lw	$a3, 12($sp)


####################################
####### shift functions work #######
####################################
# Calculate R(i+1)'s
# as there was no shift by variable amount I wrote these manually
# I could have just wrote SLL - SLR by 1 functions and call them variable 
# amout of time but did not want to do that

# R0 and R7
# as we have R0 ready, calculate R7 as well, doing it later
# would require us to load R0 back again
lw	$t0, 0($a0)
add	$t0, $t0, $s4 #R0 + t3
andi	$t0, 0xffff

srl	$t1, $t0, 13 #circulate left-most 3 bit to right
sll	$t0, $t0, 3 #left shift
or	$t0, $t0, $t1 #add circulated bits
andi	$t0, 0xffff #remove higher 16 bits
sw	$t0, 0($a0)

lw	$t1, 28($a0) 
xor	$t1, $t1, $t0
sw	$t1, 28($a0)

# R1 and R5
lw	$t0, 4($a0)
add	$t0, $t0, $s1 #R1 + t0
andi	$t0, 0xffff

sll	$t1, $t0, 11
srl	$t0, $t0, 5
or	$t0, $t0, $t1
andi	$t0, 0xffff
sw	$t0, 4($a0)

lw	$t1, 20($a0)
xor	$t1, $t1, $t0
sw	$t1, 20($a0)

# R2 and R6
lw	$t0, 8($a0)
add	$t0, $t0, $s2 #R2 + t1
andi	$t0, 0xffff

srl	$t1, $t0, 8
sll	$t0, $t0, 8
or	$t0, $t0, $t1
andi	$t0, 0xffff
sw	$t0, 8($a0)

lw	$t1, 24($a0)
xor	$t1, $t1, $t0
sw	$t1, 24($a0)

# R3 and R4
lw	$t0, 12($a0)
add	$t0, $t0, $s3 #R3 + t2
andi	$t0, 0xffff

srl	$t1, $t0, 10
sll	$t0, $t0, 6
or	$t0, $t0, $t1
andi	$t0, 0xffff
sw	$t0, 12($a0)

lw	$t1, 16($a0)
xor	$t1, $t1, $t0
sw	$t1, 16($a0)
j	InitializeLoop

continue: # load back original values of registers except a type registers and retrieve ra
lw	$ra, 0($sp)
lw	$s0, 16($sp)
lw	$s1, 20($sp)
lw	$s2, 24($sp)
lw	$s3, 28($sp)
addi	$sp, $sp, 32
jr	$ra

####################################
####################################
FunctionW:
addi	$sp, $sp, -8
sw	$ra, 0($sp)
sw	$a1, 4($sp) #save original ABCD address

lw 	$t0, 0($a1) #get A
xor	$a0, $a0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL

lw	$t0, 4($sp) #get original address of ABCD 
lw	$t0, 4($t0) #get B
xor	$a0, $v0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL

lw	$t0, 4($sp) #get original address of ABCD 
lw	$t0, 8($t0) #get C
xor	$a0, $v0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL

lw	$t0, 4($sp) #get original address of ABCD 
lw	$t0, 12($t0) #get D
xor	$a0, $v0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL #v0 is already the result


lw	$ra, 0($sp) #get ra back, ignore address of ABCD, not necessary anymore
addi	$sp, $sp, 8
jr	$ra

####################################
####################################
####################################
######## PREVIOUS FUNCTIONS ######## 
####################################
####################################
####################################
ManyTable:

#x3
andi $t0, $a0, 0xF #get x3
la $t1, s3 #load adress of s3

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1 0($t1) # s3(x3)
move $v0, $t1 # write back s3(x3)

#x2
srl $t0, $a0, 4
andi $t0, $t0, 0xF 
la $t1, s2

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 4
or $v0, $v0, $t1

#x1
srl $t0, $a0, 8
andi $t0, $t0, 0xF 
la $t1, s1

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 8
or $v0, $v0, $t1

#x0
srl $t0, $a0, 12
andi $t0, $t0, 0xF 
la $t1, s0

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 12
or $v0, $v0, $t1

jr $ra
########################
FunctionL:
addi	$sp, $sp, -8
sw	$ra, 0($sp)
sw	$s0, 4($sp)

jal cls6
move $s0, $v0
jal crs6

xor $v0, $v0, $a0 #xor x>>>6 with x
xor $v0, $v0, $s0 #xor x<<<6 with result above

lw	$ra, 0($sp)
lw	$s0, 4($sp)
addi	$sp, $sp, 8
jr 	$ra
########################
cls6:
srl	$t0, $a0, 10 #circulate left-most 6 bit to right
sll	$v0, $a0, 6 #left shift
or	$v0, $v0, $t0 #add circulated bits
andi	$v0, 0xffff #remove higher 16 bits
jr	$ra
########################
crs6:
sll	$t0, $a0, 10
srl	$v0, $a0, 6
or	$v0, $v0, $t0
andi	$v0, 0xffff
jr	$ra
########################
