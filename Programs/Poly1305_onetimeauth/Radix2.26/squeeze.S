.text

.globl squeeze216asm
.align 2
.type squeeze216asm,@function
squeeze216asm:
    mv    t3, a0
    li    t4, 0xFFFF     # load the and value into t4
    lw    a1, 0(a0)      # load h[0] into a1
    and   t0, a1, t4     # u = a1 & 0xFFFF
    sw    t0, 0(a0)      # store h[0] 
    srli  a1, a1, 16     # u = h[0] >> 16 
    addi  t1, a0, 28     # stop condition for all loops h + 28 bytes
fittingloop:
    lw    t0, 4(a0)      # h[1] into t0
    add   a1, a1, t0     # u += h[1]
    and   t0, a1, t4     # 
    sw    t0, 4(a0)      # store h[1]
    srli  a1, a1, 16     # u >>= 16
    addi  a0, a0, 4      # increase pointer by 4 bytes
    bne   a0, t1, fittingloop

    lw    t0, 4(a0)      # h[8] into t0
    add   a1, a1, t0     # u += h[8]
    andi  t0, a1, 3      # h[8]= u & 3
    sw    t0, 4(a0)      #
    srli  a1, a1, 2      # u>>2
    mv    t2, a1         # u>>2
    slli  t2, t2, 2      # (u>>2)*4
    add   a1, a1, t2     # (u>>2)*5   
    addi  a0, t1, -32    # store h[-1] into a0
moduloloop:
    lw    t0, 4(a0)      # load h[j]
    add   a1, a1, t0     # u += h[j]
    and   t0, a1, t4     # h[j]= u & 0xFFFF
    sw    t0, 4(a0)      # 
    srli  a1, a1, 16     # u >>= 16
    addi  a0, a0, 4      # increment by 4 bytes
    bne   a0, t1, moduloloop  #up to and not including h[8]

    lw    t0, 4(a0)      # load h[8]
    add   a1, a1, t0     # u += h[8]
    sw    a1, 4(a0)      # h[1]6 = u
    ret 
