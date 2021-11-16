.data
.text
    li $sp, 0x10011000
    li $fp, 0
.globl main
main:
    # put 12 in the a0 reg
    ori $a0, $zero, 12

    # Start program 
    addi $a1, $zero, 1 # F1 = 1
    addi $a2, $zero, 1 # F2 = 1
    jal fibn


    # Exit program
    j exit


fibn:
    # base case check -- leaf so no activation record
    # Note that we are actually calculating from lower Fn s to higher, but we are starting by calculating F3
    # N is simply a counter now and we decrement it down to _below_ 3 since we need N-2 depth of recursion
    slti $t0, $a0, 3
    beq  $t0, $zero, recurse
base:
    addu $v0, $a2, $zero
    jr   $ra
exit:
    halt

recurse:
    # using a simple ABI convention activation record
    # allocate stack space for outgoing $a0-3 and a double-word aligned $ra
    addi $sp, $sp, -24
    # save $ra
    sw   $ra, 16($sp)

    # n - 1 case
    addi $a0, $a0, -1     # N--
    addu $t0, $a1, $a2    # F(i-2) +  F(i-1)
    addu $a1, $a2, $zero  # F(i-2) update
    addu $a2, $t0, $zero  # F(i-1) update
    jal  fibn

    # restore registers from stack
    # load $ra
    lw   $ra, 16($sp)

    addi $sp, $sp, 24

    jr $ra 
