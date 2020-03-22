.text

.globl karatsuba226_255_5
.type karatsuba226_255_5, @function
karatsuba226_255_5:

    addi  sp, sp, -112
    sw    s0, 108(sp)
    sw    s1, 104(sp)
    sw    s2, 100(sp)
    sw    s3, 96(sp)
    sw    s4, 92(sp)
    sw    ra, 88(sp)

    mv    s0, a0        # result pointer
    mv    s1, a1        # A pointer
    mv    s2, a2        # B pointer
    li    s4, 0x3ffffff # 2^26-1

    addi  a0, sp, 48    # y_result
    addi  a1, a1, 12    # address A3
    addi  a2, a2, 12    # address B3
    call karatsuba226_255_2 # A3A4*B3B4=y

    addi  a0, sp, 24    # x_result
    mv    a1, s1        # A0
    mv    a2, s2        # B0
    call karatsuba226_255_3 # A0A1A2*B0B1B2=x


    lw    t0, 0(s1)     # A0
    lw    t1, 4(s1)     # A1
    lw    t2, 8(s1)     # A2
    lw    t3, 12(s1)    # A3
    lw    t4, 16(s1)    # A4
    li    a0, 0x4000000 # 2^26
    sub   t0, t0, t3    # A0-A3
    srai  a1, t0, 31    # sign of A0-A3
    and   a2, a0, a1    # mask 2^26 with the sign
    add   t0, t0, a2    # apply borrow
    andi  a1, a1, 1     # possible borrow from A1
    sub   t1, t1, a1    #
    sub   t1, t1, t4    # A1-A4
    srai  a1, t1, 31    # sign of A1-A4
    and   a2, a0, a1    # mask 2^26 with the sign
    add   t1, t1, a2    # apply possible borrow
    andi  a1, a1, 1     # possible borrow from A2
    sub   t2, t2, a1    # 
    srai  s3, t2, 31    # sign of A2
    and   t3, s3, s4    # cut mask to 26 bits
    xor   t0, t0, t3    # absolute value of A0A1A2-A3A4
    xor   t1, t1, t3    #
    xor   t2, t2, s3    #
    neg   t3, s3        #
    add   t0, t0, t3    # handle carry
    srli  t3, t0, 26    #
    add   t1, t1, t3    #
    and   t0, t0, s4    #
    srli  t3, t1, 26    #
    add   t2, t2, t3    #
    and   t1, t1, s4    #
    sw    t0, 64(sp)    # store |A0A1A2-A3A4|
    sw    t1, 68(sp)    #
    sw    t2, 72(sp)    #

    lw    t0, 0(s2)     # B0
    lw    t1, 4(s2)     # B1
    lw    t2, 8(s2)     # B2
    lw    t3, 12(s2)    # B3
    lw    t4, 16(s2)    # B4
    sub   t0, t0, t3    # B0-B3
    srai  a1, t0, 31    # sign of B0-B3
    and   a2, a0, a1    # mask 2^26 with the sign
    add   t0, t0, a2    # apply borrow
    andi  a1, a1, 1     # possible borrow from B1
    sub   t1, t1, a1    #
    sub   t1, t1, t4    # B1-B4
    srai  a1, t1, 31    # sign of B1-B4
    and   a2, a0, a1    # mask 2626 with the sign
    add   t1, t1, a2    # apply possible borrow
    andi  a1, a1, 1     # possible borrow from B2
    sub   t2, t2, a1    # 
    srai  a0, t2, 31    # sign of B2
    and   t3, a0, s4    # cut mask to 26 bits
    xor   t0, t0, t3    # absolute value of A0A1A2-A3A4
    xor   t1, t1, t3    #
    xor   t2, t2, a0    #
    neg   t3, a0        #
    add   t0, t0, t3    # handle carry
    srli  t3, t0, 26    #
    add   t1, t1, t3    #
    and   t0, t0, s4    #
    srli  t3, t1, 26    #
    add   t2, t2, t3    #
    and   t1, t1, s4    #
    sw    t0, 76(sp)    # store |B0B1B2-B3B4|
    sw    t1, 80(sp)    #
    sw    t2, 84(sp)    #
    xor   s8, s3, a0    # sign of (A0A1A2-A3A4)*(B0B1B2-B3B4)

    addi  a0, sp, 0     # result address
    addi  a1, sp, 64    # address |A0A1A2-A3A4|
    addi  a2, sp, 76    # address |B0B1B2-B3B4|
    call   karatsuba226_255_3 # (A0A1A2-A3A4)*(B0B1B2-B3B4)=m
    
    lw    t4, 24(sp)    # x_0
    lw    t5, 28(sp)    # x_1
    lw    t6, 32(sp)    # x_2
    lw    a0, 36(sp)    # x_3
    lw    a1, 40(sp)    # x_4
    lw    a2, 44(sp)    # x_5

    lw    a3, 48(sp)    # y_0
    lw    a4, 52(sp)    # y_1
    lw    a5, 56(sp)    # y_2
    lw    a6, 60(sp)    # y_3

    add   a3, a3, a0    # res[6] = x_3+y_0
    add   a4, a4, a1    # res[7] = x_4+y_1
    add   a5, a5, a2    # res[8] = x_5+y_2

    add   a0, t4, a3    # res[3] = x_3+y_0+x_0
    add   a1, t5, a4    # res[4] = x_4+y_1+x_1
    add   a2, t6, a5    # res[5] = x_5+y_2+x_2

    add   a3, a3, a6    # res[6] = x_3+y_0+y_3

    sw    t4, 0(s0)     # store res[0]
    sw    t5, 4(s0)     # store res[1]
    sw    t6, 8(s0)     # store res[2]

    lw    t0, 0(sp)     # m_0
    lw    t1, 4(sp)     # m_1
    lw    t2, 8(sp)     # m_2
    lw    t3, 12(sp)    # m_3
    lw    t4, 16(sp)    # m_4
    lw    t5, 20(sp)    # m_5 

    add   t0, t0, s3     # for each m make it negative if multiplication flag is 0xffffff
    xor   t0, t0, s3     # otherwise leave it
    add   t1, t1, s3     # m_1
    xor   t1, t1, s3     #
    add   t2, t2, s3     # m_2
    xor   t2, t2, s3     #
    add   t3, t3, s3     # m_3
    xor   t3, t3, s3     #
    add   t4, t4, s3     # m_4
    xor   t4, t4, s3     #
    add   t5, t5, s3     # m_5
    xor   t5, t5, s3     #

    sub   a0, a0, t0     # res[3] -= m_0
    sub   a1, a1, t1     # res[4] -= m_1
    sub   a2, a2, t2     # res[5] -= m_2
    sub   a3, a3, t3     # res[6] -= m_3
    sub   a4, a4, t4     # res[7] -= m_4
    sub   a5, a5, t5     # res[8] -= m_5

    sltz  t0, a0         # underflow in result[3]
    sub   a1, a1, t0     # borrow from result[4]
    addi  t3, s4, 1      # 2^26
    neg   t0, t0         # create mask
    and   t0, t3, t0     #
    add   a0, t0, a0     #

    sltz  t0, a1         # underflow in result[4]
    sub   a2, a2, t0     # borrow from result[5]
    neg   t0, t0         # create mask
    and   t0, t3, t0     #
    add   a1, a1, t0     #

    sltz  t0, a2         # underflow result[5]
    sub   a3, a3, t0     # borrow from result[6]
    neg   t0, t0         # create mask
    and   t0, t3, t0     #
    add   a2, a2, t0     #

    sltz  t0, a3         # underflow in result[6]
    sub   a4, a4, t0     # borrow from result[7]
    neg   t0, t0         # create mask
    and   t0, t3, t0     #
    add   a3, a3, t0     #

    sltz  t0, a4         # underflow in result[7]
    sub   a5, a5, t0     # borrow from result[8]
    neg   t0, t0         # create mask
    and   t0, t3, t0     #
    add   a4, a4, t0     #

    srli  t0, a0, 26     # handle overflow
    add   a1, a1, t0     #
    and   a0, a0, s4     #
    srli  t0, a1, 26     # 
    add   a2, a2, t0     #
    and   a1, a1, s4     #
    srli  t0, a2, 26     #
    add   a3, a3, t0     #
    and   a2, a2, s4     #
    srli  t0, a3, 26     #
    add   a4, a4, t0     #
    and   a3, a3, s4     #
    srli  t0, a4, 26     #
    add   a5, a5, t0     #
    and   a4, a4, s4     #
    srli  t0, a5, 26     #
    add   a6, a6, t0     #
    and   a5, a5, s4     #

    sw    a0, 12(s0)     # store results
    sw    a1, 16(s0)     #
    sw    a2, 20(s0)     #
    sw    a3, 24(s0)     #
    sw    a4, 28(s0)     #
    sw    a5, 32(s0)     #
    sw    a6, 36(s0)     #

    lw    s0, 108(sp)   # restore variables
    lw    s1, 104(sp)   #
    lw    s2, 100(sp)   #
    lw    s3, 96(sp)    #
    lw    s4, 92(sp)    #
    lw    ra, 88(sp)    #

    addi  sp, sp, 112   #
    ret
