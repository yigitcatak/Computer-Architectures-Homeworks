.data

s0: .word 0xF, 0x4, 0x5, 0x8, 0x9, 0x7, 0x2, 0x1, 0xA, 0x3, 0x0, 0xE, 0x6, 0xC, 0xD, 0xB
s1: .word 0x4, 0xA, 0x1, 0x6, 0x8, 0xF, 0x7, 0xC, 0x3, 0x0, 0xE, 0xD, 0x5, 0x9, 0xB, 0x2
s2: .word 0x2, 0xF, 0xC, 0x1, 0x5, 0x6, 0xA, 0xD, 0xE, 0x8, 0x3, 0x4, 0x0, 0xB, 0x9, 0x7
s3: .word 0x7, 0xC, 0xE, 0x9, 0x2, 0x1, 0x5 ,0xF, 0xB, 0x6, 0xD, 0x0, 0x4, 0x8, 0xA, 0x3
s:  .word 0xF, 0x4, 0x5, 0x8, 0x9, 0x7, 0x2, 0x1, 0xA, 0x3, 0x0, 0xE, 0x6, 0xC, 0xD, 0xB, 0x4, 0xA, 0x1, 0x6, 0x8, 0xF, 0x7, 0xC, 0x3, 0x0, 0xE, 0xD, 0x5, 0x9, 0xB, 0x2, 0x2, 0xF, 0xC, 0x1, 0x5, 0x6, 0xA, 0xD, 0xE, 0x8, 0x3, 0x4, 0x0, 0xB, 0x9, 0x7, 0x7, 0xC, 0xE, 0x9, 0x2, 0x1, 0x5 ,0xF, 0xB, 0x6, 0xD, 0x0, 0x4, 0x8, 0xA, 0x3
x:  .word 8709,7357,9587,9427,5665,5261,1492,7249,362,6834,9604,375,8896,2043,4965,9104,5561,8003,2504,8634,9125,3739,9356,2292,9004,8875,5520,1558,2124,6109,7686,4553,7436,7687,5263,5835,6786,71,2207,3438,5734,8430,3252,3025,1851,7600,4518,944,7359,7220,9254,5705,9601,7096,3526,137,9799,9875,7125,760,3260,2317,2884,827,3583,8843,755,502,6714,7306,8040,9519,1405,8883,7140,2823,844,8047,6246,9683,408,5986,1762,3055,3981,3058,8227,1127,7083,5057,6079,6958,842,8750,4449,8557,7851,9358,4044,3166
newline: .asciiz "\n"
.text

addi	$s1, $zero, 100
la 	$s0, x

# change 'SingleTable' to 'ManyTable' for many table implementation
loop:
beqz 	$s1, exit
lw      $a0, 0($s0)
jal	SingleTable
addi	$s0, $s0, 4
addi	$s1, $s1, -1

move	$a0, $v0
li	$v0,1
syscall

la 	$a0, newline
li 	$v0, 4
syscall

j	loop
exit:

li $v0, 10 
syscall
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
srl $t0, $a0, 4 # extract x2
andi $t0, $t0, 0xF 
la $t1, s2

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 4
or $v0, $v0, $t1

#x1
srl $t0, $a0, 8 # extract x2
andi $t0, $t0, 0xF 
la $t1, s1

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 8
or $v0, $v0, $t1

#x0
srl $t0, $a0, 12 # extract x2
andi $t0, $t0, 0xF 
la $t1, s0

sll $t0, $t0, 2
add $t1, $t1, $t0

lw $t1, 0($t1)
sll $t1, $t1, 12
or $v0, $v0, $t1

jr $ra
########################
SingleTable:
la $t1, s #load adress of s

andi $t0, $a0, 0xF #get x3

addi $t0, $t0, 48
sll $t0, $t0, 2

add $t0, $t1, $t0

lw $t0, 0($t0)
move $v0, $t0

#x2
srl $t0, $a0, 4
andi $t0, $t0, 0xF

addi $t0, $t0, 32
sll $t0, $t0, 2

add $t0, $t1, $t0

lw $t0, 0($t0)

sll $t0, $t0, 4
or $v0, $v0, $t0

#x1
srl $t0, $a0, 8
andi $t0, $t0, 0xF

addi $t0, $t0, 16
sll $t0, $t0, 2

add $t0, $t1, $t0

lw $t0, 0($t0)

sll $t0, $t0, 8
or $v0, $v0, $t0

#x0
srl $t0, $a0, 12
andi $t0, $t0, 0xF

sll $t0, $t0, 2

add $t0, $t1, $t0

lw $t0, 0($t0)

sll $t0, $t0, 12
or $v0, $v0, $t0

jr $ra
