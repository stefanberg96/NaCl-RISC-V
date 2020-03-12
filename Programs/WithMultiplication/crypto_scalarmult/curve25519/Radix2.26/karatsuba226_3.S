.text

.globl karatsuba226_255_3asm
.type karatsuba226_255_3asm, @function

# a0..a2 A
# a3..a5 B
# s0..s5 R
# s6..s9 m arguments

karatsuba226_255_3asm:
    addi sp, sp, -80    #
    sw   s0, 76(sp)     #
    sw   s1, 72(sp)     #
    sw   s2, 68(sp)     #
    sw   s3, 64(sp)     #
    sw   s4, 60(sp)     #
    sw   s5, 56(sp)     #
    sw   s6, 52(sp)     #
    sw   s7, 48(sp)     #
    sw   s8, 44(sp)     #
    sw   s9, 40(sp)     #
    sw   s10, 36(sp)    #
    sw   s11, 32(sp)    #
    sw   ra, 28(sp)     #

    mul  s2, a2, a5     # A2*B2_l
    mulh s3, a2, a5     # A2*B2_h
    li   t6, 0x4000000  # 2^26

    sub  s6, a0, a2     # A0-A2
    srai t0, s6, 31     # sign of A0-A2
    andi t1, t0, 1      # possible borrow
    sub  s7, a1, t1     #
    and  t0, t0, t6     # mask 2^26 with the sign
    add  s6, s6, t0     #

    sub  s8, a3, a5     # B0-B2
    srai t0, s8, 31     # sign of A0-A2
    andi t1, t0, 1      # possible borrow
    sub  s9, a4, t1     #
    and  t0, t0, t6     # mask 2^26 with the sign
    add  s8, s8, t0     #

    mv   a2, a3         # calculate x
    mv   a3, a4         #
    call karatsuba226_255_2asm

    li   t6, 0x3ffffff  # 2^26-1

    srli t0, s2, 26     # base change to 2^26
    slli s3, s3, 6      #
    or   s3, s3, t0     #
    and  s2, s2, t6     #

    mv   s0, a0         # x0
    mv   s1, a1         # x1
    add  s4, s2, a2     # A2*B2_l + x2
    add  s5, s3, a3     # A2*B2_h + x3
    add  s2, s4, s0     # A2*B2_l + x2 + x0
    add  s3, s5, s1     # A2*B2_h + x3 + x1

    srai t0, s7, 31     # sign of A1
    and  t1, t0, t6     # cut mask to 26 bits
    xor  s6, s6, t1     # |A0A1-A2|
    xor  s7, s7, t0     #
    neg  t1, t0         #
    add  s6, s6, t1     #
    srli t1, s6, 26     # handle carry
    add  a1, s7, t1     #
    and  a0, s6, t6     #

    srai t2, s9, 31     # sign of B1
    and  t1, t2, t6     # cut mask to 26 bits
    xor  s8, s8, t1     # |B0B1-B2|
    neg  t1, t2         #
    add  s8, s8, t1     # 
    srli t1, s8, 26     # handle carry
    add  a3, s9, t1     #
    and  a2, s8, t6     #

    xor  s6, t0, t2     # sign of (A0A1-A2)*(B0B1-B2) s6 is not used to store arguments of m anymore

    call karatsuba226_255_2asm

    add  a0, a0, s6     # for each m make it negative if multiplication flag is 0xffffff
    xor  a0, a0, s6     # otherwise leave it
    add  a1, a1, s6     # m_1
    xor  a1, a1, s6     #
    add  a2, a2, s6     # m_2
    xor  a2, a2, s6     #
    add  a3, a3, s6     # m_3
    xor  a3, a3, s6     #

    sub  s2, s2, a0     # result[2] -= m_0
    sub  s3, s3, a1     # result[3] -= m_1
    sub  s4, s4, a2     # result[4] -= m_2
    sub  s5, s5, a3     # result[5] -= m_3

    li   t6, 0x3ffffff  # 2^26-1
   
    sltz t0, s2         # underflow in result[2]
    sub  s3, s3, t0     # borrow from result[3]
    addi t2, t6, 1      # 2^26
    neg  t0, t0         # generate mask
    and  t0, t2, t0     # 
    add  s2, t0, s2     #

    sltz t0, s3         # underflow in result[3]
    sub  s4, s4, t0     # borrow from result[4]
    neg  t0, t0         # generate mask
    and  t0, t2, t0     # 
    add  s3, t0, s3     #

    sltz t0, s4         # underflow in result[4]
    sub  s5, s5, t0     # borrow from result[5]
    neg  t0, t0         # generate mask
    and  t0, t2, t0     # 
    add  s4, t0, s4     #

    srli t0, s2, 26     # overflow in result[2]
    add  s3, s3, t0     #
    and  a2, s2, t6     #

    srli t0, s3, 26     # overflow in result[3]
    add  s4, s4, t0     #
    and  a3, s3, t6     #

    srli t0, s4, 26     # overflow in result[4]
    add  a5, s5, t0     #
    and  a4, s4, t6     #

    mv   a0, s0         #
    mv   a1, s1         #

    lw   s0, 76(sp)     #
    lw   s1, 72(sp)     #
    lw   s2, 68(sp)     #
    lw   s3, 64(sp)     #
    lw   s4, 60(sp)     #
    lw   s5, 56(sp)     #
    lw   s6, 52(sp)     #
    lw   s7, 48(sp)     #
    lw   s8, 44(sp)     #
    lw   s9, 40(sp)     #
    lw   s10, 36(sp)    #
    lw   s11, 32(sp)    #
    lw   ra, 28(sp)     #
    addi sp, sp, 80     #
    ret

