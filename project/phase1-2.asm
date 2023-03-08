.data
x: .word 0x45a8

.text
la	$a0, x
lw	$a0, 0($a0)
jal	FunctionL
move	$a0, $v0
li	$v0,34
syscall

li $v0, 10 
syscall
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
addi	$sp, $sp, 12
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
