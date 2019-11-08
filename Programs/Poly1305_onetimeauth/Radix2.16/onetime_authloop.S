.text

.globl onetime_authloopasm
.type onetime_authloopasm, @function

onetime_authloopasm:
    addi   sp, sp, -32    # create space on stack to store variables
    sw     s2, 28(sp)     #
    sw     s3, 24(sp)     #
    sw     s4, 20(sp)     #
    sw     s5, 16(sp)     #
    sw     s6, 12(sp)     #
    sw     ra,  8(sp)     #
    mv     s2, a0         # in
    mv     s3, a1         # inlen
    mv     s4, a2         # h
    mv     s5, a3         # r
    mv     s6, a4         # c

outer_loop:
    sw     zero, 0(s6)    #
    sw     zero, 4(s6)    #
    sw     zero, 8(s6)    #
    sw     zero, 12(s6)   #
    sw     zero, 16(s6)   #
    sw     zero, 20(s6)   #
    sw     zero, 24(s6)   #
    sw     zero, 28(s6)   #
    sw     zero, 32(s6)   #

    addi   t1, s6, 32     # stopping condition of the copy loop
    mv     t3, s6         # changable addres of c
    li     t4, 1          # for the branching in copy loop
copy_loop:
    ble    s3, t4, append # if inlen < 2 goto append the 1 byte 
    lbu    t2, 0(s2)      # load in[j]
    lbu    t5, 1(s2)      # load in[j+1] << 8
    slli   t5, t5, 8      #
    or     t2, t2, t5     # in[j] + in[j+1] << 8
    sw     t2, 0(t3)      # store c[j]
    addi   t3, t3, 4      # update c address
    addi   s2, s2, 2      # update in address
    addi   s3, s3, -2     # update the inlen
    blt    t3, t1, copy_loop 
    j      eveninlen      # set last byte to 1
    
append:
    beqz   s3, eveninlen# if inlen==0 only append a 1
uneveninlen:
    lbu    t2, 0(s2)      # load in[j]
    addi   t2, t2, 0x100  # append the 1 byte 
    sw     t2, 0(t3)      # c[j] = in[2*j]+1<<8
    addi   s3, s3, -1     # decrease the inlen to be 0
    j      rest
eveninlen:
    sw     t4, 0(t3)      # append the 1 byte c[j]

rest:
    mv     a0, s4         # prepare add call
    mv     a1, s6         #
    jal    add216asm
    mv     a0, s4         # prepare mulmodasm call
    mv     a1, s5         #
    jal    mulmod216asm    
    bgtz   s3, outer_loop
    lw     s2, 28(sp)     # restore the values from sp
    lw     s3, 24(sp)     #
    lw     s4, 20(sp)     #
    lw     s5, 16(sp)     #
    lw     s6, 12(sp)     #
    lw     ra,  8(sp)     #
    addi   sp, sp, 32     # restore space on stack to store variables
    ret
