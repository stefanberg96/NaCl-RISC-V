.text

.globl karatsuba226_5asm
.type karatsuba226_5asm, @function
karatsuba226_5asm:
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

    sw    a0, 24(sp)    # result pointer
    mv    s10, a1       # A pointer
    mv    s11, a2       # B pointer

    lw    a0, 12(s10)    # Load A3A4
    lw    a1, 16(s10)    #

    lw    a2, 12(s11)    # Load B3B4
    lw    a3, 16(s11)    #

    call  karatsuba226_2asm 

    mv    s0, a0        # store y in S0..S3
    mv    s1, a1        #
    mv    s2, a2        #
    mv    s3, a3        #

    lw    a0, 0(s10)    # Load A0A1A2
    lw    a1, 4(s10)    #
    lw    a2, 8(s10)    #

    lw    a3, 0(s11)    # Load B0B1B2
    lw    a4, 4(s11)    #
    lw    a5, 8(s11)    #

    lw    a6, 12(s10)   # Load A3A4
    lw    a7, 16(s10)   #

    lw    t5, 12(s11)   # Load B3B4
    lw    t6, 16(s11)   #

    li    t4, 0x4000000 # 2^26
    sub   s4, a0, a6    # A0-A3
    srai  t0, s4, 31    # sign of A0-A3
    and   t1, t0, t4    # mask 2^26 with the sign
    add   s4, s4, t1    # apply borrow
    andi  t0, t0, 1     # possible borrow from A1
    sub   s5, a1, t0    #
    sub   s5, s5, a7    # A1-A4
    srai  t0, s5, 31    # sign of A1-A4
    and   t1, t0, t4    # mask 2^26 with the sign
    add   s5, s5, t1    # apply possible borrow
    andi  t0, t0, 1     # possible borrow from A2
    sub   s6, a2, t0    # 

    sub   s7, a3, t5    # B0-B3
    srai  t0, s7, 31    # sign of B0-B3
    and   t1, t0, t4    # mask 2^26 with the sign
    add   s7, s7, t1    # apply borrow
    andi  t0, t0, 1     # possible borrow from B1
    sub   s8, a4, t0    #
    sub   s8, s8, t6    # B1-B4
    srai  t0, s8, 31    # sign of B1-B4
    and   t1, t0, t4    # mask 2^26 with the sign
    add   s8, s8, t1    # apply possible borrow
    andi  t0, t0, 1     # possible borrow from B2
    sub   s9, a5, t0    # 

    call karatsuba226_3asm # calculate A0A1A2*B0B1B2=x

    add   s0, s0, a3    # y0+x3
    add   s1, s1, a4    # y1+x4
    add   s2, s2, a5    # y2+x5

    li    t6, 0x3ffffff #

    srai  t3, s9, 31    # sign of A2
    and   t1, t6, t3    # cut mask to 26 bits
    xor   a3, s7, t1    # absolute value of A0A1A2-A3A4
    xor   a4, s8, t1    #
    xor   a5, s9, t3    #
    neg   t0, t3        #
    add   a3, a3, t0    # handle carry
    srli  t0, a3, 26    #
    add   a4, a4, t0    #
    and   a3, a3, t6    #
    srli  t0, a4, 26    #
    add   a5, a5, t0    #
    and   a4, a4, t6    #

    mv    s7, a0        # store x
    mv    s8, a1        #
    mv    s9, a2        #
 
    srai  t2, s6, 31    # sign of A2
    and   t1, t6, t2    # cut mask to 26 bits
    xor   a0, s4, t1    # absolute value of A0A1A2-A3A4
    xor   a1, s5, t1    #
    xor   a2, s6, t2    #
    neg   t0, t2        #
    add   a0, a0, t0    # handle carry
    srli  t0, a0, 26    #
    add   a1, a1, t0    #
    and   a0, a0, t6    #
    srli  t0, a1, 26    #
    add   a2, a2, t0    #
    and   a1, a1, t6    #
   
    xor   s4, t2, t3    # sign of (A0A1A2-A3A4)*(B0B1B2-B3B4) 
    call   karatsuba226_3asm # (A0A1A2-A3A4)*(B0B1B2-B3B4)=m

    li    t6, 0x3ffffff # 2^26-1
    lw    t5, 24(sp)    # load result pointer
    sw    s7, 0(t5)     # res[0]
    sw    s8, 4(t5)     # res[1]
    sw    s9, 8(t5)     # res[2]

    add   s7, s7, s0    # x_0+y_0+x_3
    add   s8, s8, s1    # x_1+y_1+x_4
    add   s9, s9, s2    # x_2+y_2+x_5
    add   s0, s0, s3    # x_3+y_0+y_3

    add   a0, a0, s4    # for each m make it negative if multiplication flag is 0xffffff
    xor   a0, a0, s4    # otherwise leave it
    add   a1, a1, s4    # m_1
    xor   a1, a1, s4    #
    add   a2, a2, s4    # m_2
    xor   a2, a2, s4    #
    add   a3, a3, s4    # m_3
    xor   a3, a3, s4    #
    add   a4, a4, s4    # m_4
    xor   a4, a4, s4    #
    add   a5, a5, s4    # m_5
    xor   a5, a5, s4    #

    sub   s7, s7, a0    # res[3] -= m_0
    sub   s8, s8, a1    # res[4] -= m_1
    sub   s9, s9, a2    # res[5] -= m_2
    sub   s0, s0, a3    # res[6] -= m_3
    sub   s1, s1, a4    # res[7] -= m_4
    sub   s2, s2, a5    # res[8] -= m_5

    sltz  t0, s7        # underflow in result[3]
    sub   s8, s8, t0    # borrow from result[4]
    addi  t3, t6, 1     # 2^26
    neg   t0, t0        # create mask
    and   t0, t3, t0    #
    add   s7, s7, t0    #

    sltz  t0, s8        # underflow in result[4]
    sub   s9, s9, t0    # borrow from result[5]
    neg   t0, t0        # create mask
    and   t0, t3, t0    #
    add   s8, s8, t0    #

    sltz  t0, s9        # underflow result[5]
    sub   s0, s0, t0    # borrow from result[6]
    neg   t0, t0        # create mask
    and   t0, t3, t0    #
    add   s9, s9, t0    #

    sltz  t0, s0        # underflow in result[6]
    sub   s1, s1, t0    # borrow from result[7]
    neg   t0, t0        # create mask
    and   t0, t3, t0    #
    add   s0, s0, t0    #

    sltz  t0, s1        # underflow in result[7]
    sub   s2, s2, t0    # borrow from result[8]
    neg   t0, t0        # create mask
    and   t0, t3, t0    #
    add   s1, s1, t0    #

    srli  t0, s7, 26    # handle overflow
    add   s8, s8, t0    #
    and   s7, s7, t6    #
    srli  t0, s8, 26    # 
    add   s9, s9, t0    #
    and   s8, s8, t6    #
    srli  t0, s9, 26    #
    add   s0, s0, t0    #
    and   s9, s9, t6    #
    srli  t0, s0, 26    #
    add   s1, s1, t0    #
    and   s0, s0, t6    #
    srli  t0, s1, 26    #
    add   s2, s2, t0    #
    and   s1, s1, t6    #
    srli  t0, s2, 26    #
    add   s3, s3, t0    #
    and   s2, s2, t6    #

    sw    s7, 12(t5)    # store results
    sw    s8, 16(t5)    #
    sw    s9, 20(t5)    #
    sw    s0, 24(t5)    #
    sw    s1, 28(t5)    #
    sw    s2, 32(t5)    #
    sw    s3, 36(t5)    #

    lw   s0, 76(sp)     # restore variables
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
