.text
main:
    addi    $s0,    $zero,  2   # 2 in s0 (Simple addition no forwarding)
    bne     $s0,    $zero   exit1
    addi	$s0,    $s0,    1   # This should not be called
exit1:
    bne     $s0,    $zero   exit
    addi	$s0,    $s0,    3   # This also shouldn't be called
exit:
    j actual_exit
actual_exit:
    halt
    