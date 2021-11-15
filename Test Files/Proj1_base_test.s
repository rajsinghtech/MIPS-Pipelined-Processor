.globl main
main:
    # immediates - signed
    addi $s0, $zero, 1  # s0 = 1
    ori  $s1, $zero, 3  # s1 = 3
    slti $s2, $zero, 1  # s2 = 1
    andi $s3, $s0, 3    # s3 = 1
    
    # immediates - unsigned
    addiu $s4, $s1, 1   # s4 = (3 + 1) = 4
    sltiu $s5, $s2, 2   # s5 = (1 < 2) = 1

    # shifts
    sll $s0, $s3, 1     # s0 = (1 << 1) = b10 = 2
    srl $s1, $s4, 2     # s1 = (b100 >> 2) = b1 = 1
    sra $s2, $s5, 1     # s2 = (b1 >> 1) = b0 = 0

    # register operations - signed
    add $s3, $s0, $s0   # s3 = 2 + 2 = 4
    and $s4, $s1, $s1   # s4 = 1 & 1 = 1
    nor $s5, $s2, $s2   # s5 = 0 ~| 0 = 0xFFFFFFFF
    slt $s0, $s3, $s3   # s0 = 4 < 4 = 0
    sub $s1, $s4, $s4   # s1 = 1 - 1 = 0

    # register operations - unsigned
    addu $s2, $s5, $s5  # s2 = 0xFFFFFFFF + 0xFFFFFFFF = FFFFFFFE (overflow)
    subu $s3, $s0, $s0  # s3 = 0 - 0 = 0

    # repl fun
    REPL.QB $s4, 2      # s4 = 0x020202

    # halting
    halt
