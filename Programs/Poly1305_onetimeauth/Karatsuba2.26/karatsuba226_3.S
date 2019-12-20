.text

.globl karatsuba226_3asm
.type karatsuba226_3asm, @function

karatsuba226_3asm:
    addi sp, sp, -96    #
    sw   s0, 92(sp)     #
    sw   s1, 88(sp)     #
    sw   s2, 84(sp)     #
    sw   s3, 80(sp)     # result[0]
    sw   s4, 76(sp)     # result[2]
    sw   s5, 72(sp)     # result[3]
    sw   s6, 68(sp)     # result[4]
    sw   s7, 64(sp)     # negative flag
    sw   s8, 60(sp)     # x_0
    sw   s9, 56(sp)     # result[1]
    sw   s10, 52(sp)    # 
    sw   ra, 52(sp)     #
    li   s10, 0x3ffffff # 2^26-1
    mv   s0, a0         # store result pointer
    mv   s1, a1         # store A pointer 
    mv   s2, a2         # store B pointer

    mv   a0, sp         # place to store A0A1*B0B1
    jal  karatsuba226_2asm # calulate A0A1*B0B1=x
    lw   s8, 0(sp)      # x_0
    lw   s9, 4(sp)      # x_1=result[1]
    lw   s4, 8(sp)      # x_2
    lw   s5, 12(sp)     # x_3
    mv   s3, s5         # result[0] = x_3
    mv   s6, s4         # result[4] = x_2
    add  s4, s4, s8     # result[2] = x_2 + x_0
    add  s5, s5, s9     # result[3] = x_3 + x_1
 
    lw   a0, 8(s1)      # A2
    lw   a1, 8(s2)      # B2
    jal securemul226    # A2*B2 = y 

    add  s4, s4, a0     # result[2] += y_0
    add  s6, s6, a0     # result[4] += y_0
    add  s5, s5, a1     # result[3] += y_1
    add  s3, s3, a1     # result[0] += y_1
    
    lw   t0, 0(s1)      # load A0
    lw   t1, 4(s1)      # load A1
    lw   t2, 8(s1)      # load A2
    sub  t0, t0, t2     # A0-A2
    srai t3, t0, 31     # sign of A0-A2  
    addi a0, s10, 1     # 2^26
    and  a0, t3, a0     # mask 2^26 with the sign
    add  t0, t0, a0     # apply borrow from A1
    andi t2, t3, 1      # possible borrow from A1
    sub  t1, t1, t2     # 
    srai s7, t1, 31     # sign of A1
    add  t1, t1, s7     # absolute value of A1
    xor  t1, t1, s7     #
    sw   t0, 0(sp)      # store A0A1-A2 on the stack
    sw   t1, 4(sp)      #

    lw   t0, 0(s2)      # load B0
    lw   t1, 4(s2)      # load B1
    lw   t2, 8(s2)      # load B2
    sub  t0, t0, t2     # B0-B2
    srai t3, t0, 31     # sign of B0-B2
    addi a0, s10, 1     # 2^26
    and  a0, t3, a0     # mask 2^26 with the sign
    add  t0, t0, a0     # apply borrow from B1
    andi t2, t3, 1      # possible borrow from B1
    sub  t1, t1, t2     # 
    srai t3, t1, 31     # sign of B1
    add  t1, t1, t3     # absolute value of B1
    xor  t1, t1, t3     #
    sw   t0, 8(sp)      # store B0B1-B2 on the stack
    sw   t1, 12(sp)     #
    xor  s7, s7, t3     # sign of (A0A1-A2)*(B0B1-B2)

    addi a0, sp, 20     # space for result on stack
    addi a1, sp, 0      # A0A1-A2 stack location
    addi a2, sp, 8      # B0B1-B2 stack location
    jal  karatsuba226_2asm # Calculate (A0A1-A2)*(B0B1-B2) =m

    lw   a0, 20(sp)     # m_0
    lw   a1, 24(sp)     # m_1
    lw   a2, 28(sp)     # m_2
    lw   a3, 32(sp)     # m_3
    add  a0, a0, s7     # for each m make it negative if multiplication flag is 0xffffff
    xor  a0, a0, s7     # otherwise leave it
    add  a1, a1, s7     # m_1
    xor  a1, a1, s7     #
    add  a2, a2, s7     # m_2
    xor  a2, a2, s7     #
    add  a3, a3, s7     # m_3
    xor  a3, a3, s7     #

    sub  s4, s4, a0     # result[2] -= m_0
    sub  s5, s5, a1     # result[3] -= m_1
    sub  s6, s6, a2     # result[4] -= m_2
    sub  s3, s3, a3     # result[0] -= m_3

    slli t0, s3, 2      # result[0] * 4
    add  s3, s3, t0     # result[0] *= 5
    add  s3, s3, s8     # result[0] += x_0

    srli t0, s3, 26     # handle overflow
    add  s9, s9, t0     #
    and  s3, s3, s10    #
    sw   s3, 0(s0)      # store result[0]
    srli t0, s9, 26     #
    add  s4, s4, t0     #
    and  s9, s9, s10    #
    sw   s9, 4(s0)      # store result[1]
    srli t0, s4, 26     #
    add  s5, s5, t0     #
    and  s4, s4, s10    #
    sw   s4, 8(s0)      # store result[2]
    srli t0, s5, 26     #
    add  s6, s6, t0     #
    and  s5, s5, s10    #
    sw   s5, 12(s0)     # store result[3]
    sw   s6, 16(s0)     # store result[4]

    lw   s0, 92(sp)     # restore variables
    lw   s1, 88(sp)     #
    lw   s2, 84(sp)     #
    lw   s3, 80(sp)     #
    lw   s4, 76(sp)     #
    lw   s5, 72(sp)     #
    lw   s6, 68(sp)     #
    lw   s7, 64(sp)     #
    lw   s8, 60(sp)     #
    lw   s9, 56(sp)     #
    lw   ra, 52(sp)     #
    addi sp, sp, 96     #
    ret

