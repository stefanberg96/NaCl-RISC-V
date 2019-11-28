.text

.globl onetimeauth_loop
.type onetimeauth_loop, @function
onetimeauth_loop:
    addi   sp, sp, -32   # create space on stack
    sw     s0, 28(sp)    #
    sw     s1, 24(sp)    #
    sw     s2, 20(sp)    #
    sw     s3, 16(sp)    #
    sw     s4, 12(sp)    #
    sw     s5,  8(sp)    #
    sw     s6,  4(sp)    #
    sw     ra,  0(sp)    #
    li     t1, 0xfffffffc# make sure in is aligned correctly
    and    a0, a0, t1    #
    mv     s0, a0        # in 
    mv     s1, a1        # inlen
    mv     s2, a2        # h
    mv     s3, a3        # r
    mv     s4, a4        # c
    li     s5, 0x3FFFFFF #
    li     s6, 16        # loop value
    blt    s1, s6, end_loop
loop:
    lw     t2, 0(s0)     # load 32 bytes from in[0]
    and    t3, t2, s5    # get first 26 bits
    sw     t3, 0(s4)     # c[0] = in[0..3] & 0x3FFFFFF
    srli   t2, t2, 26    # in[3] >> 2
    lw     t3, 4(s0)     # in[4..7]
    slli   t4, t3, 6     # in[4..7] << 6
    or     t2, t2, t4    # in[3] >> 2 + in[4..7]<<6
    and    t2, t2, s5    # get first 26 bits
    sw     t2, 4(s4)     # store value
    srli   t2, t3, 20    # in[4..7]>>20
    lw     t3, 8(s0)     # in[8..11]
    slli   t4, t3, 12    # in[8..11]<<12
    or     t2, t2, t4    # in[4..7]>>20 + in[8..11]<<12
    and    t2, t2, s5    #
    sw     t2, 8(s4)     # 
    srli   t2, t3, 14    # in[8..11]>>14
    lw     t3, 12(s0)    # in[12..15]
    slli   t4, t3, 18    # in[12..15]<<8
    or     t2, t2, t4    # in[8..11]>>14 + in[12..15]<<8
    and    t2, t2, s5    #
    sw     t2, 12(s4)    #
    srli   t2, t3, 8     # in[13..15]
    li     t3, 0x1000000 # 1<<24
    or     t2, t2, t3    #
    sw     t2, 16(s4)    # 
 
    mv     a0, s2        #
    mv     a1, s4        #
    jal    add226asm     #
    mv     a0, s2        #
    mv     a1, s3        #
    jal    mulmod226asm
    addi   s1, s1, -16   # update loop variables
    addi   s0, s0, 16    #
    bgt    s1, s6, loop
    
end_loop:
    mv     a0, s1        # return inlen
    lw     s0, 28(sp)    # restore values
    lw     s1, 24(sp)    #
    lw     s2, 20(sp)    #
    lw     s3, 16(sp)    #
    lw     s4, 12(sp)    #
    lw     s5,  8(sp)    #
    lw     s6,  4(sp)    #
    lw     ra,  0(sp)    #
    addi   sp, sp, 32    
    ret
