.text

.globl karatsuba226_2asm
.type karatsuba226_2asm, @function

# a0 a1 A
# a2 a3 B
# a4..a7 R
# t6 2^26-1
karatsuba226_2asm:
    addi    sp, sp, -16
    sw      s0, 12(sp)
    sw      s1, 8(sp)

    mv      s0, a0
    mv      s1, a1
    lw      a0, 0(a2)
    lw      a1, 4(a2)
    lw      a2, 0(s1)
    lw      a3, 4(s1)

    li      t6, 0x3ffffff# 2^26-1

    mul     a4, a0, a2  # A0*B0_l
    mulh    a5, a0, a2  # A0*B0_h
    mul     t5, a1, a3  # A1*B1_l
    mulh    a7, a1, a3  # A1*B1_h

    
    sub     t0, a0, a1  # A0-A1
    srai    t4, t0, 31  # get the sign of the subtraction
    sub     t1, a2, a3  # B0-B1
    srai    t3, t1, 31  # get the sign of the subtraction
    add     t0, t0, t4  # make absolute value of A0-A1
    xor     t0, t0, t4  #
    add     t1, t1, t3  # absolute value of B0-B1
    xor     t1, t1, t3  #
    xor     t4, t4, t3  # sign of the multiplication

    mul     t2, t1, t0  #
    mulh    t3, t1, t0  #

    srli    t0, a4, 26  # base change to 2^26
    slli    a5, a5, 6   #
    or      a5, a5, t0  #
    and     a0, a4, t6  #

    srli    t0, t5, 26  #
    slli    a7, a7, 6   #
    or      a7, t0, a7  #
    and     t5, t5, t6  #

    add     a5, a5, t5  # A0*B0_h + A1*B1_l
    add     a6, a7, a5  # A0*B0_h + A1*B1
    add     a5, a5, a0  # A0*B0 + A1*B1


    srli   t0, t2, 26   # base change to 2^26
    slli   t3, t3, 6    #
    or     t3, t3, t0   #
    and    t2, t2, t6   #
    

    add     t2, t2, t4  # if sign is negative make the value negative
    xor     t2, t2, t4  # otherwise keep it the same
    sub     a5, a5, t2  # res[1]-=(A0-A1)*(B0-B1)_l
    add     t3, t3, t4  # if sign is negative make the value negative
    xor     t3, t3, t4  # otherwise keep it the same
    sub     a6, a6, t3  # res[2]-=(A0-A1)*(B0-B1)_l

    sltz    t0, a5      # handle underflow
    sub     a6, a6, t0  #
    addi    t2, t6, 1   # 2^26
    neg     t0, t0      # mask
    and     t0, t2, t0  # mask 2^26
    add     a5, a5, t0  #
    
    sltz    t0, a6      # handle underflow
    sub     a7, a7, t0  #
    neg     t0, t0      # mask
    and     t0, t2, t0  # mask 2^26
    add     a6, a6, t0

    srli    t0, a5, 26  # handle overflow
    add     a6, a6, t0  #
    and     a1, a5, t6  #
    srli    t0, a6, 26  #
    add     a3, a7, t0  #
    and     a2, a6, t6  #
    
    sw      a0, 0(s0)   # store res[0]
    sw      a1, 4(s0)   # store res[1]
    sw      a2, 8(s0)   # store res[2]
    sw      a3, 12(s0)  # store res[3]

    lw      s0, 12(sp)  # restore variables and stack
    lw      s1, 8(sp)   #
    addi    sp, sp, 16

    ret
