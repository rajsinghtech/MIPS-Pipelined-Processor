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
    # s1 => vals_length (pt 2)
    ori $s1, $s1, 0x0028
    nop
    nop
    nop
    # load the value of vals_length
    lw $s1, 0($s1)
    nop
    # outer loop
outer_loop_cond:
    nop
    nop
    # n - 1
    addi $t0, $s1, -1
    nop
    nop
    nop
    # $t1 = i < n - 1
    slt $t1, $s2, $t0
    nop
    nop
    nop
    # if !(i < n - 1) exit outer loop
    beq $t1, $zero, exit_outer_loop
    nop
    nop
outer_loop_body:
    # swapped = false
    add $s4, $zero, $zero
    # j($s3) = 0
    add $s3, $zero, $zero
inner_loop_cond:
    nop
    nop
    # n - i
    sub  $t0, $s1, $s2
    nop
    nop
    nop
    # n - i - 1
    addi $t0, $t0, -1
    nop
    nop
    nop
    # $t0 = j < n - i - 1
    slt $t0, $s3, $t0
    nop
    nop
    nop
    # if !(j < n - i - 1) exit inner loop
    beq $t0, $zero, exit_inner_loop
    nop
    nop
inner_loop_body:
    # get offset of j (j * 4)
    sll $t0, $s3, 2
    nop
    nop
    nop
    # set the address arr[j]
    add $s5, $s0, $t0
    nop
    nop
    nop
    # offset for j+1 is just j + 4
    # set address of arr[j + 1]
    addi $s6, $s5, 4
    nop
    nop
    # load values from array
    lw $t0, 0($s5)
    lw $t1, 0($s6)
    nop
    nop
    nop
    # $t2 = j + 1 < j
    slt $t2, $t1, $t0
    nop
    nop
    nop
    # if !(j + 1 < j) continue
    beq $t2, $zero, inner_loop_footer
    nop
    nop
    #do swap
    # arr[j+1] = arr[j] (stored in reg)
    sw $t0, 0($s6)
    # arr[j] = arr[j+1] (reg value)
    sw $t1, 0($s5)
    # swapped = true
    addi $s4, $zero, 1
inner_loop_footer:
    nop
    nop
    # increment j
    addi $s3, $s3, 1
    j inner_loop_cond
exit_inner_loop:
    nop
    nop
    # if we've not swapped a value this iteration then we're done sorting exit
    beq $s4, $zero, exit_outer_loop
    nop
    nop
outer_loop_footer:
    # increment i
    addi $s2, $s2, 1
    j outer_loop_cond
exit_outer_loop:
    nop
    nop
    halt