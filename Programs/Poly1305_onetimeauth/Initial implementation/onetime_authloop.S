.text

.globl onetime_authloop
.type onetime_authloop, @function

onetime_authloop:
    addi   sp, sp, -32   # create space on stack to store variables
    sw     s2, 28(sp)    #
    sw     s3, 24(sp)    #
    sw     s4, 20(sp)    #
    sw     s5, 16(sp)    #
    sw     s6, 12(sp)    #
    sw     ra,  8(sp)    #
    mv     s2, a0        # in
    mv     s3, a1        # inlen
    mv     s4, a2        # h
    mv     s5, a3        # r
    mv     s6, a4        # c
outer_loop:
    sw     zero, 0(s6)    #
    sw     zero, 4(s6)    #
    sw     zero, 8(s6)    #
    sw     zero, 12(s6)   #
    sw     zero, 16(s6)   #
    sw     zero, 20(s6)   #
    sw     zero, 24(s6)   #
    sw     zero, 28(s6)   #
    sw     zero, 32(s6)   #
    sw     zero, 36(s6)   #
    sw     zero, 40(s6)   #
    sw     zero, 44(s6)   #
    sw     zero, 48(s6)   #
    sw     zero, 52(s6)   #
    sw     zero, 56(s6)   #
    sw     zero, 60(s6)   #
    sw     zero, 64(s6)   #

    sltiu  t1, s3, 16    # t1 = inlen < 16
    sub    t2, zero, t1  # create the mask for inlen
    and    t2, t2, s3    # apply mask to inlen
    addi   t1, t1, -1    # create mask for 16
    li     t3, 16
    and    t1, t3, t1    # mask the 16
    add    t1, t1, t2    # t1 is the min value of inlen, 16
    sub    s3, s3, t1    # already update the inlen
    slli   t1, t1, 2     # 4*min(inlen,16)
    add    t1, s6, t1    # stopping condition of the copy loop
    mv     t3, s6
copy_loop:
    lbu    t2, 0(s2)     # load in[j]
    sw     t2, 0(t3)     # store c[j]
    addi   t3, t3, 4     # update c address
    addi   s2, s2, 1     # update in address
    blt    t3, t1, copy_loop 
    
    li     t2, 1         # load 1 into a  reg
    sw     t2, 0(t3)     # c[j]=1
    mv     a0, s4        # prepare add call
    mv     a1, s6        #
    jal    addasm
    mv     a0, s4        # prepare mulmodasm call
    mv     a1, s5        #
    jal    mulmodasm    
    mv a0, s4
    li a1, 17
    jal printintarray
    bgtz   s3, outer_loop

    
    lw     s2, 28(sp)    # restore the values from sp
    lw     s3, 24(sp)    #
    lw     s4, 20(sp)    #
    lw     s5, 16(sp)    #
    lw     s6, 12(sp)    #
    lw     ra,  8(sp)    #
    addi   sp, sp, 32    # restore space on stack to store variables
    ret
