.text

.globl mainloop226_asm
.type mainloop226_asm, @function
mainloop226_asm:
    addi  sp, sp, -1072 # create stack space
    sw    s0, 1068(sp)  # store variables
    sw    s1, 1064(sp)  # a1
    sw    s2, 1060(sp)  # i
    sw    s3, 1056(sp)  # j
    sw    s4, 1052(sp)  # b
    sw    s5, 1048(sp)  # 
    sw    ra, 1044(sp)  # 

    lw    t0, 0(a0)     # preload work[0]
    lw    t1, 4(a0)     # preload work[1]

    mv    s0, a0        # store work pointer
    mv    s1, a1        # store e pointer

    lw    t2, 8(a0)     # work[2]
    lw    t3, 12(a0)    # work[3]
    sw    t0, 0(sp)     # xzm1[0]=work[0]
    sw    t1, 4(sp)     # xzm1[1]
    lw    t0, 16(a0)    # work[4]
    lw    t1, 20(a0)    # work[5]
    sw    t2, 8(sp)     # xzm1[2]
    sw    t3, 12(sp)    # xzm1[3]
    lw    t2, 24(sp)    # work[6]
    lw    t3, 28(sp)    # work[7]
    sw    t0, 16(sp)    # xzm1[4]
    sw    t1, 20(sp)    # xzm1[5]
    lw    t0, 32(sp)    # work[8]
    lw    t1, 36(sp)    # work[9]
    sw    t2, 24(sp)    # xzm1[6]
    sw    t3, 28(sp)    # xzm1[7]
    sw    t0, 32(sp)    # xzm1[8]
    sw    t1, 36(sp)    # xzm1[9]
    li    t0, 1         #
    sw    t0, 40(sp)    # xzm1[10]=1
    sw    t0, 80(sp)    # xzm[0]=1
    sw    zero, 44(sp)  # xzm1[11]=0
    sw    zero, 48(sp)  # xzm1[12]=0
    sw    zero, 52(sp)  # xzm1[13]=0
    sw    zero, 56(sp)  # xzm1[14]=0
    sw    zero, 60(sp)  # xzm1[15]=0
    sw    zero, 64(sp)  # xzm1[16]=0
    sw    zero, 68(sp)  # xzm1[17]=0
    sw    zero, 72(sp)  # xzm1[18]=0
    sw    zero, 76(sp)  # xzm1[19]=0

    sw    zero, 84(sp)  # xzm[1..19]=0
    sw    zero, 92(sp)  #
    sw    zero, 96(sp)  #
    sw    zero, 100(sp) #
    sw    zero, 104(sp) #
    sw    zero, 108(sp) #
    sw    zero, 112(sp) #
    sw    zero, 116(sp) #
    sw    zero, 120(sp) #
    sw    zero, 124(sp) #
    sw    zero, 128(sp) #
    sw    zero, 132(sp) #
    sw    zero, 136(sp) #
    sw    zero, 140(sp) #
    sw    zero, 144(sp) #
    sw    zero, 148(sp) #
    sw    zero, 152(sp) #
    sw    zero, 156(sp) #
    sw    zero, 160(sp) #

    lw    s5, 36(s1)    # e[9]
    li    s3, 20        # loop variable

firstloop:
    srl   s4, s5, s3    # e[9] >> loop variable
    andi  s4, s4, 1     # bit 234+j

    addi  a0, sp, 160   # xzmb
    addi  a1, sp, 240   # xzm1b
    addi  a2, sp, 80    # xzm
    addi  a3, sp, 0     # xzm1
    mv    a4, s4        # b
    call  crypto_select_asm

    addi  a0, sp, 480   # a0
    addi  a1, sp, 160   # xzmb
    addi  a2, sp, 200   # xzmb[10]
    call  add226

    addi  a0, sp, 520   # a0[10]
    addi  a1, sp, 160   # xzmb
    addi  a2, sp, 200   # xzmb[10]
    call sub226

    addi  a0, sp, 560   # a1
    addi  a1, sp, 240   # xzm1b
    addi  a2, sp, 280   # xzm1b[10]
    call add226

    addi  a0, sp, 600   # a1[10]
    addi  a1, sp, 240   # xzm1b
    addi  a2, sp, 280   # xzm1b[10]
    call sub226

    addi  a0, sp, 640   # b0
    addi  a1, sp, 480   # a0
    call square226

    addi  a0, sp, 680   # b0[10]
    addi  a1, sp, 520   # a0[10]
    call square226

    addi  a0, sp, 720   # b1
    addi  a1, sp, 560   # a1
    addi  a2, sp, 520   # a0[10]
    call karatsuba226

    addi  a0, sp, 760   # b1[10]
    addi  a1, sp, 600   # a1[10]
    addi  a2, sp, 480   # a0
    call karatsuba226

    addi  a0, sp, 800   # c1
    addi  a1, sp, 720   # b1
    addi  a2, sp, 760   # b1[10]
    call add226

    addi  a0, sp, 840   # c1[10]
    addi  a1, sp, 720   # b1
    addi  a2, sp, 760   # b1[10]
    call sub226

    addi  a0, sp, 880   # r
    addi  a1, sp, 840   # c1[10]
    call square226

    addi  a0, sp, 920   # s
    addi  a1, sp, 640   # b0
    addi  a2, sp, 680   # b0[10]
    call sub226

    addi  a0, sp, 960   # t
    addi  a1, sp, 920   # s
    call mul121665asm

    addi  a0, sp, 1000  # u
    addi  a1, sp, 960   # t
    addi  a2, sp, 640   # b0
    call add226

    addi  a0, sp, 320   # xznb
    addi  a1, sp, 640   # b0
    addi  a2, sp, 680   # b0[10]
    call karatsuba226

    addi  a0, sp, 360   # xznb[10]
    addi  a1, sp, 920   # s
    addi  a2, sp, 1000  # u
    call karatsuba226

    addi  a0, sp, 400   # xzn1b
    addi  a1, sp, 800   # c1
    call square226

    addi  a0, sp, 440   # xzn1b[10]
    addi  a1, sp, 880   # r
    addi  a2, s0, 0     # work
    call karatsuba226

    addi  a0, sp, 80    # xzm
    addi  a1, sp, 0     # xzm1
    addi  a2, sp, 320   # xznb
    addi  a3, sp, 400   # xzn1b
    addi  a4, s4, 0     # b
    call crypto_select_asm

    addi  s3, s3, -1    # update j loop variable
    bgez  s3, firstloop

    addi  s2, s1, 32    # outerloop variable

outerloop:
    lw    s5, 0(s2)     # e[i]
    li    s3, 25        # innerloop variable

innerloop:
    srl   s4, s5, s3    # e[9] >> loop variable
    andi  s4, s4, 1     # bit 234+j

    addi  a0, sp, 160   # xzmb
    addi  a1, sp, 240   # xzm1b
    addi  a2, sp, 80    # xzm
    addi  a3, sp, 0     # xzm1
    mv    a4, s4        # b
    call  crypto_select_asm

    addi  a0, sp, 480   # a0
    addi  a1, sp, 160   # xzmb
    addi  a2, sp, 200   # xzmb[10]
    call  add226

    addi  a0, sp, 520   # a0[10]
    addi  a1, sp, 160   # xzmb
    addi  a2, sp, 200   # xzmb[10]
    call sub226

    addi  a0, sp, 560   # a1
    addi  a1, sp, 240   # xzm1b
    addi  a2, sp, 280   # xzm1b[10]
    call add226

    addi  a0, sp, 600   # a1[10]
    addi  a1, sp, 240   # xzm1b
    addi  a2, sp, 280   # xzm1b[10]
    call sub226

    addi  a0, sp, 640   # b0
    addi  a1, sp, 480   # a0
    call square226

    addi  a0, sp, 680   # b0[10]
    addi  a1, sp, 520   # a0[10]
    call square226

    addi  a0, sp, 720   # b1
    addi  a1, sp, 560   # a1
    addi  a2, sp, 520   # a0[10]
    call karatsuba226

    addi  a0, sp, 760   # b1[10]
    addi  a1, sp, 600   # a1[10]
    addi  a2, sp, 480   # a0
    call karatsuba226

    addi  a0, sp, 800   # c1
    addi  a1, sp, 720   # b1
    addi  a2, sp, 760   # b1[10]
    call add226

    addi  a0, sp, 840   # c1[10]
    addi  a1, sp, 720   # b1
    addi  a2, sp, 760   # b1[10]
    call sub226

    addi  a0, sp, 880   # r
    addi  a1, sp, 840   # c1[10]
    call square226

    addi  a0, sp, 920   # s
    addi  a1, sp, 640   # b0
    addi  a2, sp, 680   # b0[10]
    call sub226

    addi  a0, sp, 960   # t
    addi  a1, sp, 920   # s
    call mul121665asm

    addi  a0, sp, 1000  # u
    addi  a1, sp, 960   # t
    addi  a2, sp, 640   # b0
    call add226

    addi  a0, sp, 320   # xznb
    addi  a1, sp, 640   # b0
    addi  a2, sp, 680   # b0[10]
    call karatsuba226

    addi  a0, sp, 360   # xznb[10]
    addi  a1, sp, 920   # s
    addi  a2, sp, 1000  # u
    call karatsuba226

    addi  a0, sp, 400   # xzn1b
    addi  a1, sp, 800   # c1
    call square226

    addi  a0, sp, 440   # xzn1b[10]
    addi  a1, sp, 880   # r
    addi  a2, s0, 0     # work
    call karatsuba226

    addi  a0, sp, 80    # xzm
    addi  a1, sp, 0     # xzm1
    addi  a2, sp, 320   # xznb
    addi  a3, sp, 400   # xzn1b
    addi  a4, s4, 0     # b
    call crypto_select_asm

    addi  s3, s3, -1    # update j loop variable
    bgez  s3, innerloop

    addi  s2, s2, -4    # update i loop variable
    ble   s1, s2, outerloop

    lw    t0, 80(sp)    # xzm[0]
    lw    t1, 84(sp)    # xzm[1]
    lw    t2, 88(sp)    # xzm[2]
    lw    t3, 92(sp)    # xzm[3]
    lw    t4, 96(sp)    # xzm[4]
    lw    t5, 100(sp)   # xzm[5]
    lw    t6, 104(sp)   # xzm[6]
    lw    a0, 108(sp)   # xzm[7]
    lw    a1, 112(sp)   # xzm[8]
    lw    a2, 116(sp)   # xzm[9]
    sw    t0, 0(s0)     # work[0]
    sw    t1, 4(s0)     # work[1]
    sw    t2, 8(s0)     # work[2]
    sw    t3, 12(s0)    # work[3]
    sw    t4, 16(s0)    # work[4]
    sw    t5, 20(s0)    # work[5]
    sw    t6, 24(s0)    # work[6]
    sw    a0, 28(s0)    # work[7]
    sw    a1, 32(s0)    # work[8]
    sw    a2, 36(s0)    # work[9]

    lw    t0, 120(sp)   # xzm[10]
    lw    t1, 124(sp)   # xzm[11]
    lw    t2, 128(sp)   # xzm[12]
    lw    t3, 132(sp)   # xzm[13]
    lw    t4, 136(sp)   # xzm[14]
    lw    t5, 140(sp)   # xzm[15]
    lw    t6, 144(sp)   # xzm[16]
    lw    a0, 148(sp)   # xzm[17]
    lw    a1, 152(sp)   # xzm[18]
    lw    a2, 156(sp)   # xzm[19]
    sw    t0, 40(s0)    # work[10]
    sw    t1, 44(s0)    # work[11]
    sw    t2, 48(s0)    # work[12]
    sw    t3, 52(s0)    # work[13]
    sw    t4, 56(s0)    # work[14]
    sw    t5, 60(s0)    # work[15]
    sw    t6, 64(s0)    # work[16]
    sw    a0, 68(s0)    # work[17]
    sw    a1, 72(s0)    # work[18]
    sw    a2, 76(s0)    # work[19]

    lw    s0, 1068(sp)  # restore variables
    lw    s1, 1064(sp)  # 
    lw    s2, 1060(sp)  # 
    lw    s3, 1056(sp)  # 
    lw    s4, 1052(sp)  # 
    lw    s5, 1048(sp)  # 
    lw    ra, 1044(sp)  # 
    addi  sp, sp, 1072  # 
    ret

.globl mainloop226_compiled
mainloop226_compiled:
addi sp, sp, -1120
  sw ra, 1116(sp)
  sw s0, 1112(sp)
  sw s1, 1108(sp)
  sw s2, 1104(sp)
  sw s3, 1100(sp)
  sw s4, 1096(sp)
  sw s5, 1092(sp)
  sw s6, 1088(sp)
  sw s7, 1084(sp)
  sw s8, 1080(sp)
  sw s9, 1076(sp)
  sw s10, 1072(sp)
  sw s11, 1068(sp)
  add s0, zero, a1
  add a1, zero, a0
  addi a0, sp, 988
  addi a2, zero, 40
  sw a1, 20(sp)
  call memcpy
  addi s1, zero, 1
  sw s1, 1028(sp)
  addi a0, sp, 1032
  addi a2, zero, 36
  mv a1, zero
  call memset
  sw s1, 908(sp)
  addi a0, sp, 912
  addi a2, zero, 76
  mv a1, zero
  call memset
  addi s9, zero, 20
  addi s4, sp, 348
  sw s0, 12(sp)
.LBB0_1: # =>This Inner Loop Header: Depth=1
  lw a0, 36(s0)
  srl a0, a0, s9
  andi s8, a0, 1
  addi s1, sp, 828
  add a0, zero, s1
  addi s7, sp, 748
  add a1, zero, s7
  addi s6, sp, 908
  add a2, zero, s6
  addi s5, sp, 988
  add a3, zero, s5
  add a4, zero, s8
  call crypto_select_asm
  addi s10, sp, 508
  add a0, zero, s10
  add a1, zero, s1
  addi s2, sp, 868
  add a2, zero, s2
  call add226
  addi s3, sp, 548
  add a0, zero, s3
  add a1, zero, s1
  add a2, zero, s2
  call sub226
  addi s11, sp, 428
  add a0, zero, s11
  add a1, zero, s7
  addi s0, sp, 788
  add a2, zero, s0
  call add226
  addi s1, sp, 468
  add a0, zero, s1
  add a1, zero, s7
  add a2, zero, s0
  call sub226
  add a0, zero, s4
  add a1, zero, s10
  call square226
  addi s2, sp, 388
  add a0, zero, s2
  add a1, zero, s3
  call square226
  addi s7, sp, 268
  add a0, zero, s7
  add a1, zero, s11
  add a2, zero, s3
  call karatsuba226
  addi s0, sp, 308
  add a0, zero, s0
  add a1, zero, s1
  add a2, zero, s10
  call karatsuba226
  addi s3, sp, 188
  add a0, zero, s3
  add a1, zero, s7
  add a2, zero, s0
  call add226
  addi s1, sp, 228
  add a0, zero, s1
  add a1, zero, s7
  add a2, zero, s0
  call sub226
  addi s7, sp, 148
  add a0, zero, s7
  add a1, zero, s1
  call square226
  addi s1, sp, 108
  add a0, zero, s1
  add a1, zero, s4
  add a2, zero, s2
  call sub226
  addi s0, sp, 68
  add a0, zero, s0
  add a1, zero, s1
  call mul121665asm
  addi s10, sp, 28
  add a0, zero, s10
  add a1, zero, s0
  add a2, zero, s4
  call add226
  addi s0, sp, 668
  add a0, zero, s0
  add a1, zero, s4
  add a2, zero, s2
  call karatsuba226
  addi a0, sp, 708
  add a1, zero, s1
  add a2, zero, s10
  call karatsuba226
  addi s1, sp, 588
  add a0, zero, s1
  add a1, zero, s3
  call square226
  addi a0, sp, 628
  add a1, zero, s7
  lw a2, 20(sp)
  call karatsuba226
  add a0, zero, s6
  add a1, zero, s5
  add a2, zero, s0
  add a3, zero, s1
  add a4, zero, s8
  lw s0, 12(sp)
  call crypto_select_asm
  addi s9, s9, -1
  addi a0, zero, -1
  bne s9, a0, .LBB0_1
  lw a0, 20(sp)
  addi a0, zero, 8
  addi s2, sp, 828
  addi s3, sp, 748
  addi s10, sp, 908
  addi s6, sp, 988
  addi s5, sp, 348
.LBB0_3: # =>This Loop Header: Depth=1
  sw a0, 8(sp)
  slli a0, a0, 2
  add a0, a0, s0
  sw a0, 16(sp)
  addi s0, zero, 25
.LBB0_4: # Parent Loop BB0_3 Depth=1
  lw a0, 16(sp)
  lw a0, 0(a0)
  srl a0, a0, s0
  andi a4, a0, 1
  sw a4, 24(sp)
  add a0, zero, s2
  add a1, zero, s3
  add a2, zero, s10
  add a3, zero, s6
  call crypto_select_asm
  addi s4, sp, 508
  add a0, zero, s4
  add a1, zero, s2
  addi s7, sp, 868
  add a2, zero, s7
  call add226
  addi s9, sp, 548
  add a0, zero, s9
  add a1, zero, s2
  add a2, zero, s7
  call sub226
  add s8, zero, s5
  addi s5, sp, 428
  add a0, zero, s5
  add a1, zero, s3
  addi s1, sp, 788
  add a2, zero, s1
  call add226
  addi s7, sp, 468
  add a0, zero, s7
  add a1, zero, s3
  add a2, zero, s1
  call sub226
  add a0, zero, s8
  add a1, zero, s4
  call square226
  addi a0, sp, 388
  add a1, zero, s9
  call square226
  addi s11, sp, 268
  add a0, zero, s11
  add a1, zero, s5
  add s5, zero, s8
  add a2, zero, s9
  call karatsuba226
  addi s1, sp, 308
  add a0, zero, s1
  add a1, zero, s7
  add a2, zero, s4
  call karatsuba226
  addi a0, sp, 188
  add a1, zero, s11
  add a2, zero, s1
  call add226
  addi s7, sp, 228
  add a0, zero, s7
  add a1, zero, s11
  add a2, zero, s1
  call sub226
  addi s8, sp, 148
  add a0, zero, s8
  add a1, zero, s7
  call square226
  addi s7, sp, 108
  add a0, zero, s7
  add a1, zero, s5
  addi s4, sp, 388
  add a2, zero, s4
  call sub226
  addi s1, sp, 68
  add a0, zero, s1
  add a1, zero, s7
  call mul121665asm
  addi s9, sp, 28
  add a0, zero, s9
  add a1, zero, s1
  add a2, zero, s5
  call add226
  addi s11, sp, 668
  add a0, zero, s11
  add a1, zero, s5
  add a2, zero, s4
  call karatsuba226
  addi a0, sp, 708
  add a1, zero, s7
  add a2, zero, s9
  call karatsuba226
  addi s1, sp, 588
  add a0, zero, s1
  addi a1, sp, 188
  call square226
  addi a0, sp, 628
  add a1, zero, s8
  lw a2, 20(sp)
  call karatsuba226
  add a0, zero, s10
  add a1, zero, s6
  add a2, zero, s11
  add a3, zero, s1
  lw a4, 24(sp)
  call crypto_select_asm
  addi a0, zero, -1
  addi s0, s0, -1
  bne s0, a0, .LBB0_4
  lw a1, 8(sp)
  addi a0, a1, -1
  lw s0, 12(sp)
  bnez a1, .LBB0_3
  addi a1, sp, 908
  addi a2, zero, 80
  lw a0, 20(sp)
  call memcpy
  lw s11, 1068(sp)
  lw s10, 1072(sp)
  lw s9, 1076(sp)
  lw s8, 1080(sp)
  lw s7, 1084(sp)
  lw s6, 1088(sp)
  lw s5, 1092(sp)
  lw s4, 1096(sp)
  lw s3, 1100(sp)
  lw s2, 1104(sp)
  lw s1, 1108(sp)
  lw s0, 1112(sp)
  lw ra, 1116(sp)
  addi sp, sp, 1120
  ret
