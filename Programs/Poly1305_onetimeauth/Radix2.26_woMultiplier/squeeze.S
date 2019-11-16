.text

.globl squeeze226asm
.align 2
.type squeeze226asm,@function
squeeze226asm:
    addi   sp, sp, -32    # create space on stack
    sw     ra, 28(sp)     # store return address
    sw     s0, 24(sp)     #
    mv     s0, a0         # store address of h
    sw     zero, 20(sp)   # c[1..4]=0
    sw     zero, 16(sp)   #
    sw     zero, 12(sp)   #
    sw     zero,  8(sp)   #
    lw     t1, 20(a0)     # load h[5]
    slli   t2, t1, 2      #
    add    t1, t1, t2     # h[5]*5
    sw     t1, 4(sp)      # c[0]=h[5]*5
    addi   a1, sp, 4      # address of c[0] 
    jal    add226asm
    lw     t1, 16(s0)     # load h[4]
    srli   t1, t1, 26     # h[4]>>26
    slli   t2, t1, 2      #
    add    t1, t1, t2     # h[4]>>26 *5
    sw     t1, 4(sp)      # c[0] = (h[4]>>26)*5
    mv     a0, s0         # start address of h
    addi   a1, sp, 4      # start address of c
    jal    add226asm
    lw     ra, 28(sp)     # restore return address
    lw     s0, 24(sp)     #
    addi   sp, sp, 32     # restore stack space
    ret
