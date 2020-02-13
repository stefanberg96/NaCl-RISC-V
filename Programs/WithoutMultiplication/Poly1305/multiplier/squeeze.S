.text

.globl squeezeasm
.align 2
.type squeezeasm,@function
squeezeasm:
    mv    t3, a0
    lw    a1, 0(a0)   # load h[0] into a1
    andi  t0, a1, 255 # u = a1 & 255
    sw    t0, 0(a0)   # store h[0] 
    srli  a1, a1, 8   # u = h[0] >> 8 
    addi  t1, a0, 60  # stop condition for all loops h + 60 bytes
fittingloop:
    lw    t0, 4(a0)   # h[1] into t0
    add   a1, a1, t0  # u += h[1]
    andi  t0, a1, 255 # 
    sw    t0, 4(a0)   # store h[1]
    srli  a1, a1, 8   # u >>=8
    addi  a0, a0, 4   # increase pointer by 4 bytes
    bne   a0, t1, fittingloop

    lw    t0, 4(a0)   # h[16] into t0
    add   a1, a1, t0  # u += h[16]
    andi  t0, a1, 3   # h[16]= u & 3
    sw    t0, 4(a0)   #
    srli  a1, a1, 2   # u>>2
    mv    t2, a1      # u>>2
    slli  t2, t2, 2   # (u>>2)*4
    add   a1, a1, t2  # (u>>2)*5   
    addi  a0, t1, -64 # store h[-1] into a0
moduloloop:
    lw    t0, 4(a0)   # load h[j]
    add   a1, a1, t0  # u += h[j]
    andi  t0, a1, 255 # h[j]= u & 255
    sw    t0, 4(a0)   # 
    srli  a1, a1, 8   # u >>= 8
    addi  a0, a0, 4   # increment by 4 bytes
    bne   a0, t1, moduloloop  #up to and not including h[16]

    lw    t0, 4(a0)   # load h[16]
    add   a1, a1, t0  # u += h[16]
    sw    a1, 4(a0)   # h[1]6 = u
    ret 
