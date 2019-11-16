.text

.globl mulmod226asm
.type mulmod226asm, @function
mulmod226asm:
    addi   sp, sp, -64   # space for hr array and pushes
    sw     s1, 60(sp)    #
    sw     s2, 56(sp)    #
    sw     s3, 52(sp)    #
    sw     s4, 48(sp)    #
    sw     s5, 44(sp)    #
    sw     s6, 40(sp)    #
    sw     s7, 36(sp)    #
    sw     ra, 32(sp)    #
    mv     s1, a0        # store address of h
    mv     s2, a1        # store address of r
    li     s3, 0         # i = 0
    li     s4, 0         # u_low
    li     s5, 0         # u_high
    li     s6, 5         # multiplication constant
    li     s7, 0x3FFFFFF # get lowest 26 bits
outer_loop:
    slli   t1, s3, 2     # stopping condition
    add    t6, t1, s1    # h[i]
    add    t5, s2, t1    # r[i]
    mv     t4, s1
inner_loop:
    lw     a0, 0(t4)     # h[i]
    lw     a1, 0(t5)     # r[i-j]
    jal    securemul226  
    add    s5, s5, a1    # u+= r[i-j] *h[j]
    add    s4, s4, a0    #
    sltu   a0, s4, a0    # handle carry
    add    s5, s5, a0    #
    addi   t4, t4, 4     # update loop variables
    addi   t5, t5, -4    #
    ble    t4, t6, inner_loop

    addi   t6, s1, 16    # stopping condition
    bgt    t4, t6, postloop

    addi   t5, t5, 20    # r[i-j+5]
inner_loop2:
    lw     a0, 0(t4)     # h[i]
    lw     a1, 0(t5)     # r[i-j+5]
    jal    securemul226  
    slli   t1, a1, 2     #
    add    a1, a1, t1    # high *5
    srli   t1, a0, 30    # low *5
    add    a1, a1, t1    # 
    slli   t1, a0, 2     #
    add    a0, a0, t1    #
    sltu   t1, a0, t1    # handle carry
    add    a1, a1, t1    # 
    add    s5, s5, a1    # u+=high * 5
    add    s4, s4, a0    # u+=low * 5
    sltu   a0, s4, a0    # handle carry
    add    s5, s5, a0    #

    addi   t4, t4, 4     # update loop variables
    addi   t5, t5, -4    #
    ble    t4, t6, inner_loop2

postloop:
    slli  t5, s3, 2      # i*4
    sub   t5, sp, t5     # hr[i]-28
    and   t4, s4, s7     # u_low & 0x3FFFFFF
    sw    t4, 28(t5)     # hr[i] = u_low & 0x3FFFFFF
    srli  s4, s4, 26     # u >>26
    slli  t5, s5, 6      # 
    or    s4, s4, t5     #
    srli  s5, s5, 26     #
    addi  s3, s3, 1      #
    blt   s3, s6, outer_loop

    sw    s4, 20(s1)     # h[5]=u
    lw    a0, 28(sp)     #
    sw    a0, 0(s1)      # h[i]=hr[i]
    lw    a0, 24(sp)     #              
    sw    a0, 4(s1)      # h[i]=hr[i]
    lw    a0, 20(sp)     #
    sw    a0, 8(s1)      # h[i]=hr[i]
    lw    a0, 16(sp)     #              
    sw    a0, 12(s1)     # h[i]=hr[i]
    lw    a0, 12(sp)     #
    sw    a0, 16(s1)     # h[i]=hr[i]
    mv    a0, s1
    jal   squeeze226asm

    lw    s1, 60(sp)     # restore pushed values
    lw    s2, 56(sp)     #
    lw    s3, 52(sp)     #
    lw    s4, 48(sp)     #
    lw    s5, 44(sp)     #
    lw    s6, 40(sp)     #
    lw    s7, 36(sp)     #
    lw    ra, 32(sp)     #
    addi  sp, sp, 64     #
    ret
