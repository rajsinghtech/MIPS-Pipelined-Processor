.data
newline: .asciiz  "\n"
.text
.globl main
main:
    # s1 => 1
    addiu $s1, $zero, 1
    # s2 => 2
    # addiu $s2, $zero, 2
    
    # expect 1 + 2 = 3
    add $a0, $s1, $s2
    # jal print
    
    # expect 3 + -1 = 2
    addi $a0, $a0, -1
    # jal print
    
    # expect an overflow
    addiu $a0, $zero, 0x7FFFFFFF
    addiu $a0, $a0, 1
    # jal print
    
    # expect 2
    addu $a0, $s1, $s1
    # jal print
    
    # expect 0
    and $a0, $s1, $s2
    # jal print
    
   # expect 2
    andi $a0, $s2, 3
    # jal print
    
    # expect $a0 = 1 nor 2 = 0xFFFFFFFC
    nor $a0, $s1, $s2
    # jal print
    
    
    # expect 1
    slt $a0, $s1, $s2
    # jal print
    
    #expect 0
    slti $a0, $s1, 0
    # jal print
    
    # expect 0
    sltiu $a0, $s2, 2
    # jal print
    
    # shifting
    # expect 2
    sll $a0, $s1, 1
    # jal print
    
    #expect 0
    srl $a0, $s2, 2
    # jal print
    
    #expect 1 - 2 = -1
    sub $a0, $s1, $s2
    # jal print
    
    # expect 1 - 1 = 0
    subu $a0, $s1, $s1
    # jal print
    
    # expect 02020202
    REPL.QB $a0, 2

    # Exit program
    j exit
    
print:
    # Print number
    ori   $v0, $zero, 1
    syscall
    # save the argument to $a0
    or $t0, $a0, $zero
    # print new line
    li $v0, 4
    la $a0, newline
    syscall
    # restore argument
    or $a0, $t0, $zero
    jr $ra
exit:
    halt
