.text
main:
    addi    $s0,    $zero,  1   # 1 in s0 (Simple addition no forwarding)
    bne     $s0,    $zero   exit
    addi	$s0,    $s0,    1   # This should not be called
exit:
    addi    $s0,    $s0,    0   # this will be called
    halt