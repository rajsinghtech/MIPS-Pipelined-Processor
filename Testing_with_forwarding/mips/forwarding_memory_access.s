.data
data: .word 10
.text
main:
    la $s0, data
    lw $s0, 0($s0)  # Load the data from address stored in s0 causing the previous instructions to forward
    add $s0, $s0, $s0   # Do something with the data causing the memory to forward
    halt