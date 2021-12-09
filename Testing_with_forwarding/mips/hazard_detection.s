.data
data: .word 10
.text
main:
    la $s0, data
    ori $s1, $zero, 0
    ori $s2, $zero, 4
begin_loop:
    slt $t0, $s1, $s2
    bne $t0, $zero, do_thing
    j exit
do_thing:
    bne $s0, $zero, do_thing_after
do_thing_first:
    j exit_loop
do_thing_after:
    jal some_task
    j exit_loop
some_task:
    lw $t0, 0($s0)
    add $t0, $t0, $t0
    jr $ra
exit_loop:
    addi $s1, $s1, 1
    j begin_loop
exit:
    halt
