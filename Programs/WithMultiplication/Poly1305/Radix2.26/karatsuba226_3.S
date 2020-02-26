.text

.globl karatsuba226_3asm
.type karatsuba226_3asm, @function

karatsuba226_3asm:
    addi sp, sp, -80    #
    sw   s0, 76(sp)     #
    sw   s1, 72(sp)     #
    sw   s2, 68(sp)     #
    sw   s3, 64(sp)     # result[0]
    sw   s4, 60(sp)     # result[1]
    sw   s5, 56(sp)     # result[2]
    sw   s6, 52(sp)     # result[3]
    sw   s7, 48(sp)     # result[4]
    sw   s8, 44(sp)     # negative flag
    sw   s9, 40(sp)     # 
    sw   s10, 36(sp)    # 2^26-1
    sw   ra, 32(sp)     #

    li   s10, 0x3ffffff # 2^26-1
    mv   s0, a0         # store result pointer
    mv   s1, a1         # store A pointer 
    mv   s2, a2         # store B pointer

    lw   a0, 8(s1)      # A2
    lw   a1, 8(s2)      # B2
    call securemul226    # A2*B2 = y 

    mv   s5, a0         # result[2] += y_0
    mv   s7, a0         # result[4] += y_0
    mv   s6, a1         # result[3] += y_1
    mv   s3, a1         # result[0] += y_1
    
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
    srai s8, t1, 31     # sign of A1
    and  t2, s8, s10    # cut mask to 26 bits length
    xor  t1, t1, s8     # absolute value of A0A1-A2
    xor  t0, t0, t2     # 
    neg  t3, s8         #
    add  t0, t0, t3     #    
    srli t3, t0, 26     # handle carry
    add  t1, t1, t3     #
    and  t0, t0, s10    #
    sw   t0, 0(sp)      # store |A0A1-A2| on the stack
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
    and  a0, t3, s10    # cut mask to 26 bits
    xor  t1, t1, t3     # absolute value of B0B1-B2
    xor  t0, t0, a0     #
    neg  t4, t3         #
    add  t0, t0, t4     #
    srli t4, t0, 26     # handle carry
    add  t1, t1, t4     #
    and  t0, t0, s10    #
    sw   t0, 8(sp)      # store B0B1-B2 on the stack
    sw   t1, 12(sp)     #
    xor  s8, s8, t3     # sign of (A0A1-A2)*(B0B1-B2)

    addi a0, sp, 16     # space for result on stack
    addi a1, sp, 0      # A0A1-A2 stack location
    addi a2, sp, 8      # B0B1-B2 stack location
    call  karatsuba226_2asm # Calculate (A0A1-A2)*(B0B1-B2) =m

    addi a0, sp, 0      # result for x
    mv   a1, s1         # A0A1
    mv   a2, s2         # B0B1
    call  karatsuba226_2asm # Calculate A0A1*B0B1 = x

    lw   t6, 0(sp)      # x_0
    lw   a1, 4(sp)      # x_1
    lw   a2, 8(sp)      # x_2
    lw   a3, 12(sp)     # x_3
    
    add  s3, s3, a3     # res[0] += x_3
    mv   s4, a1         # res[1] = x_1
    add  s5, s5, a2     # res[2] += x_2
    add  s5, s5, t6     # res[2] += x_0
    add  s6, s6, a3     # res[3] += x_3
    add  s6, s6, a1     # res[3] += x_1
    add  s7, s7, a2     # res[4] += x_2

    lw   a0, 16(sp)     # m_0
    lw   a1, 20(sp)     # m_1
    lw   a2, 24(sp)     # m_2
    lw   a3, 28(sp)     # m_3
    add  a0, a0, s8     # for each m make it negative if multiplication flag is 0xffffff
    xor  a0, a0, s8     # otherwise leave it
    add  a1, a1, s8     # m_1
    xor  a1, a1, s8     #
    add  a2, a2, s8     # m_2
    xor  a2, a2, s8     #
    add  a3, a3, s8     # m_3
    xor  a3, a3, s8     #

    sub  s5, s5, a0     # result[2] -= m_0
    sub  s6, s6, a1     # result[3] -= m_1
    sub  s7, s7, a2     # result[4] -= m_2
    sub  s3, s3, a3     # result[0] -= m_3

    sltz a0, s3         # underflow in result[0]
    sub  s4, s4, a0     # borrow from result[1]
    addi a1, s10, 1     # 2^26
    neg  a0, a0         # generate mask
    and  a0, a1, a0     # 
    add  s3, a0, s3     #

    slli t0, s3, 2      # result[0] * 4
    add  s3, s3, t0     # result[0] *= 5
    add  s3, s3, t6     # result[0] += x_0
    
    sltz t0, s4         # underflow in result[1]
    sub  s5, s5, t0     # borrow from result[2]
    neg  t0, t0         # generate mask
    and  t0, a1, t0     # 
    add  s4, t0, s4     #

    sltz t0, s5         # underflow in result[2]
    sub  s6, s6, t0     # borrow from result[3]
    neg  t0, t0         # generate mask
    and  t0, a1, t0     # 
    add  a2, t0, s5     #

    sltz t0, s6         # underflow in result[3]
    sub  s7, s7, t0     # borrow from result[4]
    neg  t0, t0         # generate mask
    and  t0, a1, t0     # 
    add  a3, t0, s6     #

    sltz t0, s7         # underflow in result[4]
    neg  t0, t0         # generate mask
    andi t1, t0, 5      # 
    sub  s3, s3, t1     # borrow 5 from result[0]
    and  t0, a1, t0     #
    add  a4, t0, s7     #

    mv   a0, s3         #
    mv   a1, s4         #

    call squeeze226param

    sw   a0, 0(s0)      # store results
    sw   a1, 4(s0)      #
    sw   a2, 8(s0)      #
    sw   a3, 12(s0)     #
    sw   a4, 16(s0)     #

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
    lw   ra, 32(sp)     #
    addi sp, sp, 80     #
    ret

