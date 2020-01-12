.text

.globl square226_2asm
.type square226_2asm, @function
square226_2asm:
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
    mv      s1, a1      # A pointer

    lw      a0, 0(a1)   # load A0
    mv      a1, a0
    jal     securemul226 # mul A0*B0

    sw      a0, 0(s0)   # res[0]=A0*B0_l
    add     s3, a0, a1  # res[1]=A0*B0_l + A0*B0_h
    lw      a0, 4(s1)   # load A1
    mv      s4, a1      # res[2]=A0*B0_h

    mv      a1, a0      # square so B1=A1
    jal     securemul226 # mul A1*B1

    add     s3, s3, a0  # res[1]+= A1*B1_l
    lw      t0, 0(s1)   # load A0 preloading to prevent load-use interlock
    lw      t1, 4(s1)   # load A1
    add     s4, s4, a0  # res[2]+= A1*B1_l
    add     s4, s4, a1  # res[2]+= A1*B1_h
    mv      s6, a1      # res[3]=A1*B1_h temporarily store it in t6 (not used by securemul226)

    
    sub     t0, t0, t1  # A0-A1
    srai    s5, t0, 31  # get the sign of the subtraction
    add     t0, t0, s5  # make absolute value of A0-A1
    xor     a0, t0, s5  #
    mv      a1, a0      # B0-B1=A0-A1
    jal     securemul226 # |A0-A1|*|B0-B1|

    sub     s3, s3, a0  # res[1]-=(A0-A1)*(B0-B1)_l
    sub     s4, s4, a1  # res[2]-=(A0-A1)*(B0-B1)_l

    li      t1, 0x3ffffff # 2^26-1
    sltz    t0, s3      # handle underflow
    sub     s4, s4, t0  #
    addi    t2, t1, 1   # 2^26
    neg     t0, t0      # mask
    and     t0, t2, t0  # mask 2^26
    add     s3, s3, t0  #
    
    sltz    t0, s4      # handle underflow
    sub     s6, s6, t0  #
    neg     t0, t0      # mask
    and     t0, t2, t0  # mask 2^26
    add     s4, s4, t0

    srli    t0, s3, 26  # handle overflow
    add     s4, s4, t0  #
    and     s3, s3, t1  #
    srli    t0, s4, 26  #
    add     s6, s6, t0  #
    and     s4, s4, t1  #
    sw      s3, 4(s0)   # store res[1]
    sw      s4, 8(s0)   # store res[2]
    sw      s6, 12(s0)  # store res[3]

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




