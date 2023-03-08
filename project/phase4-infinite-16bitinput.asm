.data
KEY: .word 0x2301, 0x6745, 0xAB89, 0xEFCD, 0xDCFE, 0x98BA, 0x5476, 0x1032
IV: .word 0x3412, 0x7856, 0xBC9A, 0xF0DE
R: .word 0,0,0,0,0,0,0,0
R2: .word 0,0,0,0,0,0,0,0
ABCD: .word 0xcccc, 0xdddd, 0xeeee, 0x3333
s0: .word 0xF, 0x4, 0x5, 0x8, 0x9, 0x7, 0x2, 0x1, 0xA, 0x3, 0x0, 0xE, 0x6, 0xC, 0xD, 0xB
s1: .word 0x4, 0xA, 0x1, 0x6, 0x8, 0xF, 0x7, 0xC, 0x3, 0x0, 0xE, 0xD, 0x5, 0x9, 0xB, 0x2
s2: .word 0x2, 0xF, 0xC, 0x1, 0x5, 0x6, 0xA, 0xD, 0xE, 0x8, 0x3, 0x4, 0x0, 0xB, 0x9, 0x7
s3: .word 0x7, 0xC, 0xE, 0x9, 0x2, 0x1, 0x5 ,0xF, 0xB, 0x6, 0xD, 0x0, 0x4, 0x8, 0xA, 0x3
is0: .word 0xA, 0x7, 0x6, 0x9, 0x1, 0x2, 0xC, 0x5, 0x3, 0x4, 0x8, 0xF, 0xD, 0xE, 0xB, 0x0
is1: .word 0x9, 0x2, 0xF, 0x8, 0x0, 0xC, 0x3, 0x6, 0x4, 0xD, 0x1, 0xE, 0x7, 0xB, 0xA, 0x5
is2: .word 0xC, 0x3, 0x0, 0xA, 0xB, 0x4, 0x5, 0xF, 0x9, 0xE, 0x6, 0xD, 0x2, 0x7, 0x8, 0x1
is3: .word 0xB, 0x5, 0x4, 0xF, 0xC, 0x6, 0x9 ,0x0, 0xD, 0x3, 0xE, 0x8, 0x1, 0xA, 0x2, 0x7
nl: .asciiz "\n"
prompt1: .asciiz  "\Enter a plain text input, (enter -1 to exit):  "
prompt2: .asciiz  "\Resulting encrypted text is: "
prompt3: .asciiz  "\Resulting decrypted text is: "
.text

la	$a0, R
jal	Initialize

la	$a0, R2
jal	Initialize

Ploop:
la $a0,  prompt1          
li $v0,4
syscall      
      
li	$v0, 5
syscall		
move	$a0, $v0
beq	$a0, -1, exit

jal	Encryption
move	$s0, $v0

la $a0,  prompt2          
li $v0,4
syscall  

move 	$a0, $s0
li	$v0,34
syscall

la $a0,  nl          
li $v0,4
syscall 

move 	$a0, $s0
jal	Decryption
move	$s0, $v0

la $a0,  prompt3          
li $v0, 4
syscall  

move 	$a0, $s0
li	$v0,1
syscall

la $a0,  nl          
li $v0,4
syscall   

j	Ploop

exit:
li $v0, 10 
syscall

####################################
Decryption:
addi	$sp, $sp, -28
sw	$ra, 0($sp)
sw	$s0, 4($sp) #for t0
sw	$s1, 8($sp) #for t1
sw	$s2, 12($sp) #for t2
sw	$s3, 16($sp) #for KEY
sw	$s4, 20($sp) #for R
sw	$s5, 24($sp) #for ABCD

la	$s3, KEY
la 	$s4, R
la	$s5, ABCD

########## calculate t2 ##########
lw	$t0, 16($s3) # Key
lw	$t1, 20($s3)
lw	$t2, 24($s3)
lw	$t3, 28($s3)

lw	$t4, 0($s4) # R
lw	$t5, 4($s4)
lw	$t6, 8($s4)
lw	$t7, 12($s4)

sub	$a0, $a0, $t4 # C - R0
andi	$a0, 0xFFFF

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

jal	InvFunctionW
lw	$t0, 12($s4) #R3
sub	$v0, $v0, $t0
andi	$v0, $v0, 0xFFFF
move	$s2, $v0 #t2
########## calculate t1 ##########
lw	$t0, 0($s3) # Key
lw	$t1, 4($s3)
lw	$t2, 8($s3)
lw	$t3, 12($s3)

lw	$t4, 16($s4) # R
lw	$t5, 20($s4)
lw	$t6, 24($s4)
lw	$t7, 28($s4)

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

move	$a0, $s2
jal	InvFunctionW
lw	$t0, 8($s4) #R2
sub	$v0, $v0, $t0
andi	$v0, $v0, 0xFFFF
move	$s1, $v0 #t1
########## calculate t0 ##########
lw	$t0, 16($s3) # Key
lw	$t1, 20($s3)
lw	$t2, 24($s3)
lw	$t3, 28($s3)

lw	$t4, 16($s4) # R
lw	$t5, 20($s4)
lw	$t6, 24($s4)
lw	$t7, 28($s4)

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

move	$a0, $s1
jal	InvFunctionW
lw	$t0, 4($s4) #R1
sub	$v0, $v0, $t0
andi	$v0, $v0, 0xFFFF
move	$s0, $v0 #t0
########## calculate P ###########
lw	$t0, 0($s3) # Key
lw	$t1, 4($s3)
lw	$t2, 8($s3)
lw	$t3, 12($s3)

lw	$t4, 0($s4) # R
lw	$t5, 4($s4)
lw	$t6, 8($s4)
lw	$t7, 12($s4)

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

move	$a0, $s0
jal	InvFunctionW
lw	$t0, 0($s4) #R0
sub	$v0, $v0, $t0
andi	$v0, $v0, 0xFFFF #P
########## adjust Rs #############
lw	$t0, 0($s4) 
lw	$t1, 4($s4) 
lw	$t2, 8($s4) 
lw	$t3, 12($s4)
lw	$t4, 16($s4) 
lw	$t5, 20($s4) 
lw	$t6, 24($s4)
lw	$t7, 28($s4)

# I will need values of T0, T1, T2 soon so I use a registers to save them
# as there is no function call here, the value won't be lost 
add	$a0, $t0, $s2 # R0 + t2 (T0)
andi	$a0, 0xFFFF
sw	$a0, 0($s4)
add	$a1, $t1, $s0 # R1 + t0 (T1)
andi	$a1, 0xFFFF
sw	$a1, 4($s4)
add	$a2, $t2, $s1 # R2 + t1 (T2)
andi	$a2, 0xFFFF
sw	$a2, 8($s4)
add	$t8, $t3, $s0 # R3 + t0
add	$t8, $t8, $a0 # +T0
andi	$t8, 0xFFFF
sw	$t8, 12($s4)
xor	$t8, $t8, $t4 # T3 xor R4
sw	$t8, 16($s4)
xor	$t8, $t5, $a1 # R5 xor T1
sw	$t8, 20($s4)
xor	$t8, $t6, $a2 # R6 xor T2
sw	$t8, 24($s4)
xor	$t8, $t7, $a0 # R7 xor T0
sw	$t8, 28($s4)

lw	$ra, 0($sp)
lw	$s0, 4($sp) #for t0
lw	$s1, 8($sp) #for t1
lw	$s2, 12($sp) #for t2
lw	$s3, 16($sp) #for KEY
lw	$s4, 20($sp) #for R
lw	$s5, 24($sp) #for ABCD
addi	$sp, $sp, 28
jr	$ra
####################################
Encryption:
addi	$sp, $sp, -28
sw	$ra, 0($sp)
sw	$s0, 4($sp) #for t0
sw	$s1, 8($sp) #for t1
sw	$s2, 12($sp) #for t2
sw	$s3, 16($sp) #for KEY
sw	$s4, 20($sp) #for R
sw	$s5, 24($sp) #for ABCD

la	$s3, KEY
la 	$s4, R2
la	$s5, ABCD

########## calculate t0 ##########
lw	$t0, 0($s3) # Key
lw	$t1, 4($s3)
lw	$t2, 8($s3)
lw	$t3, 12($s3)

lw	$t4, 0($s4) # R
lw	$t5, 4($s4)
lw	$t6, 8($s4)
lw	$t7, 12($s4)

add	$a0, $a0, $t4 # P + R0
andi	$a0, 0xFFFF

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

jal	FunctionW
move	$s0, $v0 #t0
########## calculate t1 ##########
lw	$t0, 16($s3) # Key
lw	$t1, 20($s3)
lw	$t2, 24($s3)
lw	$t3, 28($s3)

lw	$t4, 16($s4) # R
lw	$t5, 20($s4)
lw	$t6, 24($s4)
lw	$t7, 28($s4)

lw	$t8, 4($s4)
add	$a0, $t8, $s0 # R1 + t0
andi	$a0, 0xFFFF

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

jal	FunctionW
move	$s1, $v0 #t1
########## calculate t2 ##########
lw	$t0, 0($s3) # Key
lw	$t1, 4($s3)
lw	$t2, 8($s3)
lw	$t3, 12($s3)

lw	$t4, 16($s4) # R
lw	$t5, 20($s4)
lw	$t6, 24($s4)
lw	$t7, 28($s4)

lw	$t8, 8($s4)
add	$a0, $t8, $s1 # R2 + t1
andi	$a0, 0xFFFF

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

jal	FunctionW
move	$s2, $v0 #t2
########## calculate C ###########
lw	$t0, 16($s3) # Key
lw	$t1, 20($s3)
lw	$t2, 24($s3)
lw	$t3, 28($s3)

lw	$t4, 0($s4) # R
lw	$t5, 4($s4)
lw	$t6, 8($s4)
lw	$t7, 12($s4)

lw	$t8, 12($s4)
add	$a0, $t8, $s2 # R3 + t2
andi	$a0, 0xFFFF

xor	$t8, $t0, $t4 # A
sw	$t8, 0($s5)
xor	$t8, $t1, $t5 # B
sw	$t8, 4($s5)
xor	$t8, $t2, $t6 # C
sw	$t8, 8($s5)
xor	$t8, $t3, $t7 # D
sw	$t8, 12($s5)

jal	FunctionW
lw	$t0, 0($s4) #R0
add	$v0, $v0, $t0
andi	$v0, 0xFFFF

########## adjust Rs #############
lw	$t1, 4($s4) 
lw	$t2, 8($s4) 
lw	$t3, 12($s4)
lw	$t4, 16($s4) 
lw	$t5, 20($s4) 
lw	$t6, 24($s4)
lw	$t7, 28($s4)

# I will need values of T0, T1, T2 soon so I use a registers to save them
# as there is no function call here, the value won't be lost 
add	$a0, $t0, $s2 # R0 + t2 (T0)
andi	$a0, 0xFFFF
sw	$a0, 0($s4)
add	$a1, $t1, $s0 # R1 + t0 (T1)
andi	$a1, 0xFFFF
sw	$a1, 4($s4)
add	$a2, $t2, $s1 # R2 + t1 (T2)
andi	$a2, 0xFFFF
sw	$a2, 8($s4)
add	$t8, $t3, $s0 # R3 + t0
add	$t8, $t8, $a0 # +T0
andi	$t8, 0xFFFF
sw	$t8, 12($s4)
xor	$t8, $t8, $t4 # T3 xor R4
sw	$t8, 16($s4)
xor	$t8, $t5, $a1 # R5 xor T1
sw	$t8, 20($s4)
xor	$t8, $t6, $a2 # R6 xor T2
sw	$t8, 24($s4)
xor	$t8, $t7, $a0 # R7 xor T0
sw	$t8, 28($s4)

lw	$ra, 0($sp)
lw	$s0, 4($sp) #for t0
lw	$s1, 8($sp) #for t1
lw	$s2, 12($sp) #for t2
lw	$s3, 16($sp) #for KEY
lw	$s4, 20($sp) #for R
lw	$s5, 24($sp) #for ABCD
addi	$sp, $sp, 28
jr	$ra
#########################
Initialize:
addi	$sp, $sp, -36
sw	$ra, 0($sp)
sw	$s7, 4($sp) 
sw	$s5, 8($sp) 
sw	$s6, 12($sp)
sw	$s0, 16($sp) #s0 for loop index i
sw	$s1, 20($sp) #s1 for t0 in algorithm
sw	$s2, 24($sp) #s2 for t1 in algorithm
sw	$s3, 28($sp) #s3 for t2 in algorithm
sw	$s4, 32($sp) #s4 for t3 in algorithm

la	$s6, IV
move	$s5, $a0

# R0, R4 <- IV0
lw	$t0, 0($s6) #IV0
sw	$t0, 0($s5)
sw	$t0, 16($s5)

# R1, R5 <- IV1
lw	$t0, 4($s6) #IV1
sw	$t0, 4($s5)
sw	$t0, 20($s5)

# R2, R6 <- IV2
lw	$t0, 8($s6) #IV2
sw	$t0, 8($s5)
sw	$t0, 24($s5)

# R3, R7 <- IV3
lw	$t0, 12($s6) #IV3
sw	$t0, 12($s5)
sw	$t0, 28($s5)

la	$s7, ABCD
la	$s6, KEY
add	$s0, $zero, $zero
InitializeLoop:
beq	$s0, 4, continue

# get KEY 0,1,2,3 and set them to ABCD
lw	$t0, 0($s6)
lw	$t1, 4($s6)
lw	$t2, 8($s6)
lw	$t3, 12($s6)
sw	$t0, 0($s7)
sw	$t1, 4($s7)
sw	$t2, 8($s7)
sw	$t3, 12($s7)
# get R0 value and add i
lw	$a0, 0($s5)
add	$a0, $a0, $s0 #R0 + i
andi	$a0, 0xffff
jal	FunctionW
move	$s1, $v0 #s1 is t0

# get KEY 4,5,6,7 and set them to ABCD
lw	$t0, 16($s6)
lw	$t1, 20($s6)
lw	$t2, 24($s6)
lw	$t3, 28($s6)
sw	$t0, 0($s7)
sw	$t1, 4($s7)
sw	$t2, 8($s7)
sw	$t3, 12($s7)

lw	$a0, 4($s5)
add	$a0, $a0, $s1 #R1 + t0
andi	$a0, 0xffff
jal	FunctionW
move	$s2, $v0 #s2 is t1

# get KEY 0,2,4,6 and set them to ABCD
lw	$t0, 0($s6)
lw	$t1, 8($s6)
lw	$t2, 16($s6)
lw	$t3, 24($s6)
sw	$t0, 0($s7)
sw	$t1, 4($s7)
sw	$t2, 8($s7)
sw	$t3, 12($s7)

lw	$a0, 8($s5)
add	$a0, $a0, $s2 #R2 + t1
andi	$a0, 0xffff
jal	FunctionW
move	$s3, $v0 #s3 is t2

addi	$s0, $s0, 1

# get KEY 1,3,5,7 and set them to ABCD
lw	$t0, 4($s6)
lw	$t1, 12($s6)
lw	$t2, 20($s6)
lw	$t3, 28($s6)
sw	$t0, 0($s7)
sw	$t1, 4($s7)
sw	$t2, 8($s7)
sw	$t3, 12($s7)

lw	$a0, 12($s5)
add	$a0, $a0, $s3 #R3 + t2
andi	$a0, 0xffff
jal	FunctionW
move	$s4, $v0 #s4 is t3

# Calculate R(i+1)'s
# as there was no shift by variable amount I wrote these manually
# I could have just wrote SLL - SLR by 1 functions and call them variable 
# amout of time but did not want to do that

# R0 and R7
# as we have R0 ready, calculate R7 as well, doing it later
# would require us to load R0 back again
lw	$t0, 0($s5)
add	$t0, $t0, $s4 #R0 + t3
andi	$t0, 0xffff

srl	$t1, $t0, 13 #circulate left-most 3 bit to right
sll	$t0, $t0, 3 #left shift
or	$t0, $t0, $t1 #add circulated bits
andi	$t0, 0xffff #remove higher 16 bits
sw	$t0, 0($s5)

lw	$t1, 28($s5) 
xor	$t1, $t1, $t0
sw	$t1, 28($s5)

# R1 and R5
lw	$t0, 4($s5)
add	$t0, $t0, $s1 #R1 + t0
andi	$t0, 0xffff

sll	$t1, $t0, 11
srl	$t0, $t0, 5
or	$t0, $t0, $t1
andi	$t0, 0xffff
sw	$t0, 4($s5)

lw	$t1, 20($s5)
xor	$t1, $t1, $t0
sw	$t1, 20($s5)

# R2 and R6
lw	$t0, 8($s5)
add	$t0, $t0, $s2 #R2 + t1
andi	$t0, 0xffff

srl	$t1, $t0, 8
sll	$t0, $t0, 8
or	$t0, $t0, $t1
andi	$t0, 0xffff
sw	$t0, 8($s5)

lw	$t1, 24($s5)
xor	$t1, $t1, $t0
sw	$t1, 24($s5)

# R3 and R4
lw	$t0, 12($s5)
add	$t0, $t0, $s3 #R3 + t2
andi	$t0, 0xffff

srl	$t1, $t0, 10
sll	$t0, $t0, 6
or	$t0, $t0, $t1
andi	$t0, 0xffff
sw	$t0, 12($s5)

lw	$t1, 16($s5)
xor	$t1, $t1, $t0
sw	$t1, 16($s5)
j	InitializeLoop

continue:

lw	$ra, 0($sp)
lw	$s7, 4($sp) 
lw	$s5, 8($sp) 
lw	$s6, 12($sp)
lw	$s0, 16($sp)
lw	$s1, 20($sp) 
lw	$s2, 24($sp) 
lw	$s3, 28($sp) 
sw	$s4, 32($sp)
addi	$sp, $sp, 36
jr	$ra
####################################
InvFunctionW:
addi	$sp, $sp, -8
sw	$ra, 0($sp)
sw	$s0, 4($sp)
la	$s0, ABCD

jal	InvFunctionL 
move	$a0, $v0
jal	InvManyTable
lw 	$t0, 12($s0) #get D
xor	$a0, $v0, $t0

jal	InvFunctionL 
move	$a0, $v0
jal	InvManyTable
lw	$t0, 8($s0) #get C
xor	$a0, $v0, $t0

jal	InvFunctionL 
move	$a0, $v0
jal	InvManyTable
lw	$t0, 4($s0) #get B
xor	$a0, $v0, $t0

jal	InvFunctionL 
move	$a0, $v0
jal	InvManyTable 
lw	$t0, 0($s0) #get A
xor	$v0, $v0, $t0

lw	$ra, 0($sp) #get ra back
lw	$s0, 4($sp)
addi	$sp, $sp, 8
jr	$ra
####################################
FunctionW:
addi	$sp, $sp, -8
sw	$ra, 0($sp)
sw	$s0, 4($sp)
la	$s0, ABCD

lw 	$t0, 0($s0) #get A
xor	$a0, $a0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL

lw	$t0, 4($s0) #get B
xor	$a0, $v0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL

lw	$t0, 8($s0) #get C
xor	$a0, $v0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL

lw	$t0, 12($s0) #get D
xor	$a0, $v0, $t0
jal	ManyTable 
move	$a0, $v0
jal	FunctionL #v0 is already the result

lw	$ra, 0($sp) #get ra back
lw	$s0, 4($sp)
addi	$sp, $sp, 8
jr	$ra
########################
InvManyTable:
#x3
andi $t0, $a0, 0xF #get x3
la $t1, is3 #load adress of s3

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1 0($t1) # s3(x3)
move $v0, $t1 # write back s3(x3)

#x2
srl $t0, $a0, 4
andi $t0, $t0, 0xF 
la $t1, is2

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 4
or $v0, $v0, $t1

#x1
srl $t0, $a0, 8
andi $t0, $t0, 0xF 
la $t1, is1

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 8
or $v0, $v0, $t1

#x0
srl $t0, $a0, 12
andi $t0, $t0, 0xF 
la $t1, is0

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 12
or $v0, $v0, $t1

jr $ra
########################
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
InvFunctionL:
# a0 is L(x)
#Inv Function L
#crs10
sll	$t0, $a0, 6
srl	$t1, $a0, 10
or	$t1, $t1, $t0
andi	$t1, 0xffff # L(x) >>> 10

#cls10
srl	$t0, $a0, 6
sll	$t2, $a0, 10
or	$t2, $t2, $t0
andi	$t2, 0xffff # L(x) <<< 10

xor	$a0, $a0, $t1 # xor L(x) with L(x) >>> 10
xor	$a0, $a0, $t2 # xor result with L(x) <<< 10

# a0 is Y
#crs4
sll	$t0, $a0, 12
srl	$t1, $a0, 4
or	$t1, $t1, $t0
andi	$t1, 0xffff # Y >>> 4

#cls4
srl	$t0, $a0, 12
sll	$t2, $a0, 4
or	$t2, $t2, $t0
andi	$t2, 0xffff # Y <<< 4

xor	$v0, $a0, $t1 # xor Y with Y >>> 4
xor	$v0, $v0, $t2 # xor result with Y <<< 4

jr 	$ra
########################
FunctionL:
#crs6
sll	$t0, $a0, 10
srl	$t1, $a0, 6
or	$t1, $t1, $t0
andi	$t1, 0xffff

#cls6
srl	$t0, $a0, 10
sll	$v0, $a0, 6
or	$v0, $v0, $t0
andi	$v0, 0xffff

xor $v0, $v0, $a0 #xor x>>>6 with x
xor $v0, $v0, $t1 #xor x<<<6 with result above

jr 	$ra