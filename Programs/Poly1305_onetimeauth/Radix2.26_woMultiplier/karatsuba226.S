.text

.globl karatsuba226asm_inplace
.type karatsuba226asm_inplace, @function
karatsuba226asm_inplace:
    addi  sp, sp, -32
    sw    s0, 28(sp)
    sw    ra, 24(sp)

    mv    s0, a0        # a address
   
    mv    a2, a1        # calculate result
    mv    a1, a0        #
    addi  a0, sp, 4     #
    call karatsuba226asm #

    lw    a0, 4(sp)     # load result
    lw    a1, 8(sp)     #
    lw    a2, 12(sp)    #
    lw    a3, 16(sp)    #
    lw    a4, 20(sp)    #
    
    sw    a0, 0(s0)     # store result in a
    sw    a1, 4(s0)     #
    sw    a2, 8(s0)     #
    sw    a3, 12(s0)    #
    sw    a4, 16(s0)    #

    lw    s0, 28(sp)
    lw    ra, 24(sp)
    addi  sp, sp, 32
    ret

.globl karatsuba226asm
.type karatsuba226asm, @function
karatsuba226asm:
    addi  sp, sp, -96
    sw    s0, 92(sp)
    sw    s1, 88(sp)
    sw    s2, 84(sp)
    sw    s3, 80(sp)
    sw    s4, 76(sp)
    sw    s5, 72(sp)
    sw    s6, 68(sp)
    sw    s7, 64(sp)
    sw    s8, 60(sp)
    sw    s9, 56(sp)
    sw    s10, 52(sp)
    sw    ra,  48(sp)

    mv    s0, a0        # result pointer
    mv    s1, a1        # A pointer
    mv    s2, a2        # B pointer
    li    s10, 0x3ffffff # 2^26-1

    mv    a0, sp        # y_result
    addi  a1, a1, 12    # address A3
    addi  a2, a2, 12    # address B3
    jal   karatsuba226_2asm # A3A4*B3B4=y

    #lw    a0, 0(sp)     #
    #jal printbyte
    #lw    a0, 4(sp)     #
    #jal printbyte
    #lw    a0, 8(sp)     #
    #jal printbyte
    #lw    a0, 12(sp)    #
    #jal printbyte
    
    lw    s6, 0(sp)     # y_0
    lw    s5, 4(sp)     # y_1=res[2]
    lw    s3, 8(sp)     # y_2=res[0]
    lw    s4, 12(sp)    # y_3
    slli  t0, s4, 2     # y_3 * 4
    add   s7, s4, t0    # res[4] = y_3 * 5
    add   s4, s4, s6    # res[1] = y_0 + y_3
    slli  t0, s3, 2     # y_2 * 4
    add   t0, s3, t0    # y_2 * 5
    add   s6, s6, t0    # res[3]=y_0+y_2*5
    add   s7, s7, s5    # res[4] += y_1

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
    srai  s8, t2, 31    # sign of A2
    and   t3, s8, s10   # cut mask to 26 bits
    xor   t0, t0, t3    # absolute value of A0A1A2-A3A4
    xor   t1, t1, t3    #
    xor   t2, t2, s8    #
    neg   t3, s8        #
    add   t0, t0, t3    # handle carry
    srli  t3, t0, 26    #
    add   t1, t1, t3    #
    and   t0, t0, s10   #
    srli  t3, t1, 26    #
    add   t2, t2, t3    #
    and   t1, t1, s10   #
    sw    t0, 20(sp)    # store |A0A1A2-A3A4|
    sw    t1, 24(sp)    #
    sw    t2, 28(sp)    #

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
    and   t3, a0, s10   # cut mask to 26 bits
    xor   t0, t0, t3    # absolute value of A0A1A2-A3A4
    xor   t1, t1, t3    #
    xor   t2, t2, a0    #
    neg   t3, a0        #
    add   t0, t0, t3    # handle carry
    srli  t3, t0, 26    #
    add   t1, t1, t3    #
    and   t0, t0, s10   #
    srli  t3, t1, 26    #
    add   t2, t2, t3    #
    and   t1, t1, s10   #
    sw    t0, 32(sp)    # store |B0B1B2-B3B4|
    sw    t1, 36(sp)    #
    sw    t2, 40(sp)    #
    xor   s8, s8, a0    # sign of (A0A1A2-A3A4)*(B0B1B2-B3B4)

    addi  a0, sp, 0     # result address
    addi  a1, sp, 20    # address |A0A1A2-A3A4|
    addi  a2, sp, 32    # address |B0B1B2-B3B4|
    jal   karatsuba226_3asm # (A0A1A2-A3A4)*(B0B1B2-B3B4)=m

    addi  a0, sp, 20    # result address
    addi  a1, s1, 0     # address A0A1A2
    addi  a2, s2, 0     # address B0B1B2
    jal   karatsuba226_3asm # A0A1A2*B0B1B2 = x

    #lw   a0, 20(sp)
    #jal printbyte
    #lw   a0, 24(sp)
    #jal printbyte
    #lw   a0, 28(sp)
    #jal printbyte
    #lw   a0, 32(sp)
    #jal printbyte
    #lw  a0,  36(sp)
    #jal printbyte

    lw    t0, 20(sp)    # x_0
    lw    t1, 24(sp)    # x_1
    lw    t2, 28(sp)    # x_2
    lw    t3, 32(sp)    # x_3
    lw    t4, 36(sp)    # x_4

    add   s6, s6, t0    # res[3] += x_0
    add   s7, s7, t1    # res[4] += x_1
    add   s6, s6, t3    # res[3] += x_3
    add   s7, s7, t4    # res[4] += x_4

    add   s3, s3, t2    # res[0] += x_2
    add   s4, s4, t3    # res[1] += x_3
    add   s5, s5, t4    # res[2] += x_4

    lw   a0, 0(sp)      # m_0
    lw   a1, 4(sp)      # m_1
    lw   a2, 8(sp)      # m_2
    lw   a3, 12(sp)     # m_3
    lw   a4, 16(sp)     # m_4
    add  a0, a0, s8     # for each m make it negative if multiplication flag is 0xffffff
    xor  a0, a0, s8     # otherwise leave it
    add  a1, a1, s8     # m_1
    xor  a1, a1, s8     #
    add  a2, a2, s8     # m_2
    xor  a2, a2, s8     #
    add  a3, a3, s8     # m_3
    xor  a3, a3, s8     #
    add  a4, a4, s8     # m_4
    xor  a4, a4, s8     #

    sub  s6, s6, a0     # res[3] -= m_0
    sub  s7, s7, a1     # res[4] -= m_1
    sub  s3, s3, a2     # res[0] -= m_2
    sub  s4, s4, a3     # res[1] -= m_3
    sub  s5, s5, a4     # res[2] -= m_4

    sltz t1, s3         # underflow in result[0]
    sub  s4, s4, t1     # borrow from result[1]
    addi a0, s10, 1     # 2^26
    neg  t1, t1         # generate mask
    and  t1, a0, t1     # 
    add  s3, t1, s3     #

    sltz t1, s4         # underflow in result[1]
    sub  s5, s5, t1     # borrow from result[2]
    neg  t1, t1         # generate mask
    and  t1, a0, t1     # 
    add  s4, s4, t1     #

    sltz t1, s5         # underflow in result[2]
    neg  t1, t1         # generate mask
    andi t2, t1, 5
    sub  s6, s6, t2     # borrow from result[3]
    and  t1, a0, t1     # 
    add  s5, t1, s5     #

    lw    t0, 20(sp)    # x_0
    lw    t1, 24(sp)    # x_1
    lw    t2, 28(sp)    # x_2

    slli a0, s3, 2      # res[0] * 4
    add  s3, s3, a0     # res[0] *= 5
    add  s3, s3, t0     # res[0] += x_0
    slli a0, s4, 2      # res[1] * 4
    add  s4, s4, a0     # res[1] *= 5
    add  s4, s4, t1     # res[1] += x_1
    slli a0, s5, 2      # res[2] * 4
    add  s5, s5, a0     # res[2] *= 5
    add  s5, s5, t2     # res[2] += x_2

    addi a0, s10, 1     # 2^26
    sltz t0, s6         # underflow in result[3]
    sub  s7, s7, t0     # borrow from result[4]
    neg  t0, t0         # generate mask
    and  t0, a0, t0     # 
    add  a3, t0, s6     #

    sltz t0, s7         # underflow in result[4]
    li   t1, 5          #
    neg  t0, t0         # generate mask
    and  t1, t0, t1     # 
    sub  s3, s3, t1     # borrow 5 from result[0]
    and  t0, a0, t0     #
    add  a4, t0, s7     #

    mv   a0, s3         #
    mv   a1, s4         #
    mv   a2, s5         #
    jal squeeze226param 

    sw    a0, 0(s0)     # store result
    sw    a1, 4(s0)     #
    sw    a2, 8(s0)     #
    sw    a3, 12(s0)    #
    sw    a4, 16(s0)    #
    
    lw    s0, 92(sp)
    lw    s1, 88(sp)
    lw    s2, 84(sp)
    lw    s3, 80(sp)
    lw    s4, 76(sp)
    lw    s5, 72(sp)
    lw    s6, 68(sp)
    lw    s7, 64(sp)
    lw    s8, 60(sp)
    lw    s9, 56(sp)
    lw    s10, 52(sp)
    lw    ra,  48(sp)
    addi  sp, sp, 96
    ret
