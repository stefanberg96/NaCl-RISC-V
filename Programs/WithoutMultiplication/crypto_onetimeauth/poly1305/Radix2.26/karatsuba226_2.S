.text

.globl karatsuba226_130_2
.type karatsuba226_130_2, @function
karatsuba226_130_2:
    addi    sp, sp, -48
    sw      s7, 32(sp)
    sw      s6, 28(sp)
    sw      s5, 24(sp)
    sw      s4, 20(sp)
    sw      s3, 16(sp)
    sw      s2, 12(sp)
    sw      s1, 8(sp)
    sw      s0, 4(sp)
    sw      ra, 0(sp)

    mv      s0, a0      # Result pointer
    mv      s1, a1      # A pointer
    mv      s2, a2      # B pointer

    lw      a0, 0(a1)   # load A0
    lw      a1, 0(a2)   # load B0
    call    securemul226 # mul A0*B0

    mv      s3, a0      # res[0] = A0*B0_l
    add     s4, a0, a1  # res[1]=A0*B0_l + A0*B0_h
    lw      a0, 4(s1)   # load A1
    mv      s5, a1      # res[2]=A0*B0_h

    lw      a1, 4(s2)   # load B1
    call    securemul226 # mul A1*B1

    add     s4, s4, a0  # res[1]+= A1*B1_l
    lw      t0, 0(s1)   # load A0 preloading to prevent load-use interlock
    lw      t1, 4(s1)   # load A1
    lw      t2, 0(s2)   # load B0
    lw      t3, 4(s2)   # load B1
    add     s5, s5, a0  # res[2]+= A1*B1_l
    add     s5, s5, a1  # res[2]+= A1*B1_h
    mv      s6, a1      # res[3]=A1*B1_h 
    
    sub     t0, t0, t1  # A0-A1
    srai    s7, t0, 31  # get the sign of the subtraction
    sub     t2, t2, t3  # B0-B1
    srai    t3, t2, 31  # get the sign of the subtraction
    add     t0, t0, s7  # make absolute value of A0-A1
    xor     a0, t0, s7  #
    add     t2, t2, t3  # absolute value of B0-B1
    xor     a1, t2, t3  #
    xor     s7, s7, t3  # sign of the multiplication
    call    securemul226 # |A0-A1|*|B0-B1|

    add     a0, a0, s7  # if sign is negative make the value negative
    xor     a0, a0, s7  # otherwise keep it the same
    sub     s4, s4, a0  # res[1]-=(A0-A1)*(B0-B1)_l
    add     a1, a1, s7  # if sign is negative make the value negative
    xor     a1, a1, s7  # otherwise keep it the same
    sub     s5, s5, a1  # res[2]-=(A0-A1)*(B0-B1)_l

    li      t1, 0x3ffffff # 2^26-1
    sltz    t0, s4      # handle underflow
    sub     s5, s5, t0  #
    addi    t2, t1, 1   # 2^26
    neg     t0, t0      # mask
    and     t0, t2, t0  # mask 2^26
    add     s4, s4, t0  #
    
    sltz    t0, s5      # handle underflow
    sub     s6, s6, t0  #
    neg     t0, t0      # mask
    and     t0, t2, t0  # mask 2^26
    add     s5, s5, t0  #

    srli    t0, s4, 26  # handle overflow
    add     s5, s5, t0  #
    and     s4, s4, t1  #
    srli    t0, s5, 26  #
    add     s6, s6, t0  #
    and     s5, s5, t1  #
    sw      s3, 0(s0)   # store res[0]
    sw      s4, 4(s0)   # store res[1]
    sw      s5, 8(s0)   # store res[2]
    sw      s6, 12(s0)  # store res[3]

    lw      s7, 32(sp)  # restore variables and stack
    lw      s6, 28(sp)  #
    lw      s5, 24(sp)  #
    lw      s4, 20(sp)  #
    lw      s3, 16(sp)  #
    lw      s2, 12(sp)  #
    lw      s1, 8(sp)   #
    lw      s0, 4(sp)   #
    lw      ra, 0(sp)   #
    addi    sp, sp, 48
    ret
