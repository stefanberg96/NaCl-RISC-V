.text

.globl karatsuba226_2asm
.type karatsuba226_2asm, @function
karatsuba226_2asm:
    addi    sp, sp, -32
    sw      s0, 28(sp)
    sw      s1, 24(sp)
    sw      s2, 20(sp)
    sw      s3, 16(sp)
    sw      s4, 12(sp)
    sw      s5, 8(sp)
    sw      s6, 4(sp)
    sw      ra, 0(sp)

    mv      s0, a0      # Result pointer
    lw      a0, 0(a1)   # load A0
    mv      s1, a1      # A pointer
    lw      a1, 0(a2)   # load B0
    mv      s2, a2      # B pointer

    jal     securemul226 # mul A0*B0
    sw      a0, 0(s0)   # res[0]=A0*B0_l
    add     s3, a0, a1  # res[1]=A0*B0_l + A0*B0_h
    lw      a0, 4(s1)   # load A1
    mv      s4, a1      # res[2]=A0*B0_h

    lw      a1, 4(s2)   # load B1
    jal     securemul226 # mul A1*B1
    add     s3, s3, a0  # res[1]+= A1*B1_l
    lw      t0, 0(s1)   # load A0 preloading to prevent load-use interlock
    lw      t1, 4(s1)   # load A1
    lw      t2, 0(s2)   # load B0
    lw      t3, 4(s2)   # load B1
    add     s4, s4, a0  # res[2]+= A1*B1_l
    add     s4, s4, a1  # res[2]+= A1*B1_h
    sw      a1, 12(s0)  # res[3]=A1*B1_h
    
    sub     t0, t0, t1  # A0-A1
    srai    s5, t0, 31  # get the sign of the subtraction
    sub     t2, t2, t3  # B0-B1
    srai    s6, t2, 31  # get the sign of the subtraction
    add     t0, t0, s5  # make absolute value of A0-A1
    xor     a0, t0, s5  #
    add     t2, t2, s6  # absolute value of B0-B1
    xor     a1, t2, s6  #

    jal     securemul226 # |A0-A1|*|B0-B1|

    xor     s5, s5, s6  # sign of the multiplication
    add     a0, a0, s5  # if sign is negative make the value negative
    xor     a0, a0, s5  # otherwise keep it the same
    sub     s3, s3, a0  # res[1]-=(A0-A1)*(B0-B1)_l
    add     a1, a1, s5  # if sign is negative make the value negative
    xor     a1, a1, s5  # otherwise keep it the same
    sub     s4, s4, a1  # res[2]-=(A0-A1)*(B0-B1)_l
    sw      s3, 4(s0)   # store res[1]
    sw      s4, 8(s0)   # store res[2]

    lw      s0, 28(sp)  # restore variables and stack
    lw      s1, 24(sp)
    lw      s2, 20(sp)
    lw      s3, 16(sp)
    lw      s4, 12(sp)
    lw      s5, 8(sp)
    lw      s6, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 32

    ret




