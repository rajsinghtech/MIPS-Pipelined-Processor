.text
main:
    addi    $s0,    $zero,  1 # 1 in s0
    add     $s1,    $s0,    $s0 # 2 in s1
    sub     
exit:
    halt