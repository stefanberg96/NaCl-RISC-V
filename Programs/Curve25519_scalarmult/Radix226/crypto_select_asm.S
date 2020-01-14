.text

# A0 p, A1 q, A2 r, A3 s, A4 b
.globl crypto_select_asm
.type crypto_select_asm, @function
crypto_select_asm:
    lw    t0, 0(a2)     # r[0]
    lw    t1, 0(a3)     # s[0]
    li    t6, 1         #
    sub   a4, a4, t6    # mask of @^32-1 if b==0 if b==1 0 mask
    xor   t2, t0, t1    # r[0]^s[0]
    and   t2, a4, t2    # mask & (r[0]^s[0])
    lw    t3, 4(a2)     # r[1]
    lw    t4, 4(a3)     # s[1]
    xor   t0, t0, t2    # r[0] if mask==0 otherwise s[0]
    xor   t1, t1, t2    # s[0] if mask==0 otherwise r[0]
    sw    t0, 0(a0)     # store res in p[0]
    sw    t1, 0(a1)     # store res in q[0]

    xor   t2, t3, t4    # r[1]^s[1]
    and   t2, t2, a4    #
    lw    t0, 8(a2)     # r[2]
    lw    t1, 8(a3)     # s[2]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 4(a1)     #
    sw    t4, 4(a2)     #

    xor   t2, t0, t1    # r[2]^s[2]
    and   t2, t2, a4    #
    lw    t3, 12(a2)    # r[3]
    lw    t4, 12(a3)    # s[3]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 8(a1)     #
    sw    t1, 8(a2)     #

    xor   t2, t3, t4    # r[3]^s[3]
    and   t2, t2, a4    #
    lw    t0, 16(a2)    # r[4]
    lw    t1, 16(a3)    # s[4]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 12(a1)    #
    sw    t4, 12(a2)    #

    xor   t2, t0, t1    # r[4]^s[4]
    and   t2, t2, a4    #
    lw    t3, 20(a2)    # r[5]
    lw    t4, 20(a3)    # s[5]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 16(a1)    #
    sw    t1, 16(a2)    #

    xor   t2, t3, t4    # r[5]^s[5]
    and   t2, t2, a4    #
    lw    t0, 24(a2)    # r[6]
    lw    t1, 24(a3)    # s[6]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 20(a1)    #
    sw    t4, 20(a2)    #

    xor   t2, t0, t1    # r[6]^s[6]
    and   t2, t2, a4    #
    lw    t3, 28(a2)    # r[7]
    lw    t4, 28(a3)    # s[7]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 24(a1)    #
    sw    t1, 24(a2)    #

    xor   t2, t3, t4    # r[7]^s[7]
    and   t2, t2, a4    #
    lw    t0, 32(a2)    # r[8]
    lw    t1, 32(a3)    # s[8]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 28(a1)    #
    sw    t4, 28(a2)    #

    xor   t2, t0, t1    # r[8]^s[8]
    and   t2, t2, a4    #
    lw    t3, 36(a2)    # r[9]
    lw    t4, 36(a3)    # s[9]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 32(a1)    #
    sw    t1, 32(a2)    #

    xor   t2, t3, t4    # r[9]^s[9]
    and   t2, t2, a4    #
    lw    t0, 40(a2)    # r[10]
    lw    t1, 40(a3)    # s[10]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 36(a1)    #
    sw    t4, 36(a2)    #

    xor   t2, t0, t1    # r[10]^s[10]
    and   t2, t2, a4    #
    lw    t3, 44(a2)    # r[11]
    lw    t4, 44(a3)    # s[11]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 40(a1)    #
    sw    t1, 40(a2)    #

    xor   t2, t3, t4    # r[11]^s[11]
    and   t2, t2, a4    #
    lw    t0, 48(a2)    # r[12]
    lw    t1, 48(a3)    # s[12]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 44(a1)    #
    sw    t4, 44(a2)    #

    xor   t2, t0, t1    # r[12]^s[12]
    and   t2, t2, a4    #
    lw    t3, 52(a2)    # r[13]
    lw    t4, 52(a3)    # s[13]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 48(a1)    #
    sw    t1, 48(a2)    #

    xor   t2, t3, t4    # r[13]^s[13]
    and   t2, t2, a4    #
    lw    t0, 56(a2)    # r[14]
    lw    t1, 56(a3)    # s[14]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 52(a1)    #
    sw    t4, 52(a2)    #

    xor   t2, t0, t1    # r[14]^s[14]
    and   t2, t2, a4    #
    lw    t3, 60(a2)    # r[15]
    lw    t4, 60(a3)    # s[15]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 56(a1)    #
    sw    t1, 56(a2)    #

    xor   t2, t3, t4    # r[15]^s[15]
    and   t2, t2, a4    #
    lw    t0, 64(a2)    # r[16]
    lw    t1, 64(a3)    # s[16]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 60(a1)    #
    sw    t4, 60(a2)    #

    xor   t2, t0, t1    # r[16]^s[16]
    and   t2, t2, a4    #
    lw    t3, 68(a2)    # r[17]
    lw    t4, 68(a3)    # s[17]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 64(a1)    #
    sw    t1, 64(a2)    #

    xor   t2, t3, t4    # r[17]^s[17]
    and   t2, t2, a4    #
    lw    t0, 72(a2)    # r[18]
    lw    t1, 72(a3)    # s[18]
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 68(a1)    #
    sw    t4, 68(a2)    #

    xor   t2, t0, t1    # r[18]^s[18]
    and   t2, t2, a4    #
    lw    t3, 76(a2)    # r[19]
    lw    t4, 76(a3)    # s[19]
    xor   t0, t0, t2    #
    xor   t1, t1, t2    #
    sw    t0, 72(a1)    #
    sw    t1, 72(a2)    #

    xor   t2, t3, t4    # r[19]^s[19]
    and   t2, t2, a4    #
    xor   t3, t3, t2    #
    xor   t4, t4, t2    #
    sw    t3, 76(a1)    #
    sw    t4, 76(a2)    #
    
    ret
