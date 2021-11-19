.data
.align 2
vals: .word 25 1 4 10 381 42 100 60 0 12 # address: 0x10010000
vals_length: .word 10                    # address: 0x10010028
.text
.globl main

# vars
# $s0 => *vals
# $s1 => vals_length
# $s2 => i
# $s3 => j
# $s4 => swapped
# $s5 => &arr[j]
# $s6 => &arr[j+1]
main:
    
    # s1 => vals_length
    lui $s1, 0x1001
    # s0 => vals
    lui $s0, 0x1001
    # i($s2) = 0
    addi $s2, $zero, 0
    nop
    ori $s1, $s1, 0x0028
    nop
    nop
    nop
    lw $s1, 0($s1)
    nop
    # outer loop
outer_loop_cond:
    nop
    nop
    addi $t0, $s1, -1
    # $t1 = i < n - 1
    nop
    nop
    nop
    slt $t1, $s2, $t0
    nop
    nop
    nop
    beq $t1, $zero, exit_outer_loop
    nop
    nop
outer_loop_body:
    add $s4, $zero, $zero
    # j($s3) = 0
    add $s3, $zero, $zero
inner_loop_cond:
    nop
    nop
    sub  $t0, $s1, $s2
    nop
    nop
    nop
    addi $t0, $t0, -1
    nop
    nop
    nop
    # $t0 = j < n - i - 1
    slt $t0, $s3, $t0
    nop
    nop
    nop
    beq $t0, $zero, exit_inner_loop
    nop
    nop
inner_loop_body:
    # get offset of j (j * 4)
    sll $t0, $s3, 2
    nop
    nop
    nop
    add $s5, $s0, $t0
    nop
    nop
    nop
    # offset for j+1 is just j + 4
    addi $s6, $s5, 4
    nop
    nop
    lw $t0, 0($s5)
    lw $t1, 0($s6)
    nop
    nop
    nop
    slt $t2, $t1, $t0
    nop
    nop
    nop
    beq $t2, $zero, inner_loop_footer
    nop
    nop
    #do swap
    sw $t0, 0($s6)
    sw $t1, 0($s5)
    addi $s4, $zero, 1
inner_loop_footer:
    nop
    nop
    addi $s3, $s3, 1
    j inner_loop_cond
exit_inner_loop:
    nop
    nop
    beq $s4, $zero, exit_outer_loop
    nop
    nop
outer_loop_footer:
    addi $s2, $s2, 1
    j outer_loop_cond
exit_outer_loop:
    nop
    nop
    halt