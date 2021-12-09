.text
main:
    addi    $s0,    $zero,  1   # 1 in s0 (Simple addition no forwarding)
    add     $s1,    $s0,    $s0 # 2 in s1 (Attempt to forward result of s0 into both rt and rs)
    sub     $s2,    $s0,    $s1 # -1 in s2 (Forward previous two values)
    addi    $s2,    $s2,    1   # Result of s2 is going int s2
exit:
    halt