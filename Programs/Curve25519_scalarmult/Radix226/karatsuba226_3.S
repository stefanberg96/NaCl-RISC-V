.text

.globl karatsuba226_3asm
.type karatsuba226_3asm, @function

karatsuba226_3asm:
    addi sp, sp, -80    #
    sw   s0, 76(sp)     #
    sw   s1, 72(sp)     #
    sw   s2, 68(sp)     #
    sw   s3, 64(sp)     #
    sw   s4, 60(sp)     #
    sw   ra, 56(sp)     #
    li   s4, 0x3ffffff # 2^26-1

    mv   s0, a0         # store result pointer
    mv   s1, a1         # store A pointer 
    mv   s2, a2         # store B pointer

    mv   a0, sp         # place to store A0A1*B0B1
    jal  karatsuba226_2asm # calulate A0A1*B0B1=x

    lw   t0, 0(s1)      # load A0
    lw   t1, 4(s1)      # load A1
    lw   t2, 8(s1)      # load A2
    sub  t0, t0, t2     # A0-A2
    srai t3, t0, 31     # sign of A0-A2  
    andi t2, t3, 1      # possible borrow from A1
    sub  t1, t1, t2     # 
    addi a0, s4, 1      # 2^26
    and  a0, t3, a0     # mask 2^26 with the sign
    add  t0, t0, a0     # apply borrow from A1
    srai s3, t1, 31     # sign of A1
    and  t2, s3, s4     # cut mask to 26 bits length
    xor  t1, t1, s3     # absolute value of A0A1-A2
    xor  t0, t0, t2     # 
    neg  t3, t2         #
    add  t0, t0, t3     #    
    srli t3, t0, 26     # handle carry
    add  t1, t1, t3     #
    and  t0, t0, s4     #
    sw   t0, 32(sp)     # store |A0A1-A2| on the stack
    sw   t1, 36(sp)     #

    lw   t0, 0(s2)      # load B0
    lw   t1, 4(s2)      # load B1
    lw   t2, 8(s2)      # load B2
    sub  t0, t0, t2     # B0-B2
    srai t3, t0, 31     # sign of B0-B2
    andi t2, t3, 1      # possible borrow from B1
    sub  t1, t1, t2     #
    addi a0, s4, 1      # 2^26
    and  a0, t3, a0     # mask 2^26 with the sign
    add  t0, t0, a0     # apply borrow from B1
    srai t3, t1, 31     # sign of B1
    and  a0, t3, s4     # cut mask to 26 bits
    xor  t1, t1, t3     # absolute value of B0B1-B2
    xor  t0, t0, a0     #
    neg  t4, a0         #
    add  t0, t0, t4     #
    srli t4, t0, 26     # handle carry
    add  t1, t1, t4     #
    and  t0, t0, s4     #
    sw   t0, 40(sp)     # store B0B1-B2 on the stack
    sw   t1, 44(sp)     #
    xor  s3, s3, t3     # sign of (A0A1-A2)*(B0B1-B2)

    addi a0, sp, 16     # space for result on stack
    addi a1, sp, 32     # A0A1-A2 stack location
    addi a2, sp, 40     # B0B1-B2 stack location
    jal  karatsuba226_2asm # Calculate (A0A1-A2)*(B0B1-B2) =m

#    lw a0, 0(sp)
#    jal printbyte
#    lw a0, 4(sp)
#    jal printbyte
#    lw a0, 8(sp)
#    jal printbyte
#    lw a0, 12(sp)
#    jal printbyte
#
#    lw  a0, 16(sp)
#    jal printbyte 
#    lw a0, 20(sp)
#    jal printbyte
#    lw a0, 24(sp)
#    jal printbyte
#    lw a0, 28(sp)
#    jal printbyte

    lw   a0, 8(s1)      # A2
    lw   a1, 8(s2)      # B2
    jal securemul226    # A2*B2 = y 
    lw   a4, 8(sp)      # x_2
    lw   a5, 12(sp)     # x_3
    lw   a2, 0(sp)      # x_0
    lw   a3, 4(sp)      # x_1

    add  a0, a0, a4     # result[4] = x_2+y_0
    add  a1, a1, a5     # result[5] = x_3+y_1
    add  a4, a0, a2     # result[2] = x_2+y_0+x_0
    add  a5, a1, a3     # result[3] = x_3+y_1+x_1

    lw   t0, 16(sp)     # m_0
    lw   t1, 20(sp)     # m_1
    lw   t2, 24(sp)     # m_2
    lw   t3, 28(sp)     # m_3
    add  t0, t0, s3     # for each m make it negative if multiplication flag is 0xffffff
    xor  t0, t0, s3     # otherwise leave it
    add  t1, t1, s3     # m_1
    xor  t1, t1, s3     #
    add  t2, t2, s3     # m_2
    xor  t2, t2, s3     #
    add  t3, t3, s3     # m_3
    xor  t3, t3, s3     #

    sub  a4, a4, t0     # result[2] -= m_0
    sub  a5, a5, t1     # result[3] -= m_1
    sub  a0, a0, t2     # result[4] -= m_2
    sub  a1, a1, t3     # result[5] -= m_3
   
    sltz t0, a4         # underflow in result[2]
    sub  a5, a5, t0     # borrow from result[3]
    addi t2, s4, 1      # 2^26
    neg  t0, t0         # generate mask
    and  t0, t2, t0     # 
    add  a4, t0, a4     #

    sltz t0, a5         # underflow in result[3]
    sub  a0, a0, t0     # borrow from result[4]
    neg  t0, t0         # generate mask
    and  t0, t2, t0     # 
    add  a5, t0, a5     #

    sltz t0, a0         # underflow in result[4]
    sub  a1, a1, t0     # borrow from result[5]
    neg  t0, t0         # generate mask
    and  t0, t2, t0     # 
    add  a0, t0, a0     #

    srli t0, a4, 26     # overflow in result[2]
    add  a5, a5, t0     #
    and  a4, a4, s4     #

    srli t0, a5, 26     # overflow in result[3]
    add  a0, a0, t0     #
    and  a5, a5, s4     #

    srli t0, a0, 26     # overflow in result[4]
    add  a1, a1, t0     #
    and  a0, a0, s4     #

    sw   a2, 0(s0)      # store results
    sw   a3, 4(s0)      #
    sw   a4, 8(s0)      #
    sw   a5, 12(s0)     #
    sw   a0, 16(s0)     #
    sw   a1, 20(s0)     #

    lw   s0, 76(sp)     # restore variables
    lw   s1, 72(sp)     #
    lw   s2, 68(sp)     #
    lw   s3, 64(sp)     #
    lw   s4, 60(sp)     #
    lw   ra, 56(sp)     #
    addi sp, sp, 80     #
    ret

