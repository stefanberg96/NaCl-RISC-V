.text

.globl squeeze226asm
.type squeeze226asm,@function
squeeze226asm:
    mv    t6, a0          # store address
    lw    a0, 0(t6)       #
    lw    a1, 4(t6)       # in[1]
    lw    a2, 8(t6)       # in[2]
    lw    a3, 12(t6)      # in[3]
    lw    a4, 16(t6)      # in[4]

    jal   squeeze226param
    
    sw    a0, 0(t6)       # store result
    sw    a1, 4(t6)       #
    sw    a2, 8(t6)       #
    sw    a3, 12(t6)      #
    sw    a4, 16(t6)      #

    ret


.globl squeeze226param
.type squeeze226param, @function
squeeze226param:
    li    t6, 0x3ffffff   # 2^26-1
    srli  t0, a4, 26      #
    slli  t1, t0, 2       # overflow result[4]*4
    add   t0, t0, t1      # overflow result[4]*5
    add   a0, a0, t0      #
    and   a4, a4, t6      #
    srli  t0, a0, 26      # overflow result[0]
    add   a1, a1, t0      #
    and   a0, a0, t6      #
    srli  t0, a1, 26      # overflow result[1]
    add   a2, a2, t0      #
    and   a1, a1, t6      #
    srli  t0, a2, 26      # overflow result[2]
    add   a3, a3, t0      #
    and   a2, a2, t6      #
    srli  t0, a3, 26      # overflow result[3]
    add   a4, a4, t0      #
    and   a3, a3, t6      #
    srli  t0, a4, 26      # overflow result[4]
    slli  t1, t0, 2       # 
    add   t0, t1, t0      #
    add   a0, a0, t0      #
    and   a4, a4, t6      #
    ret

