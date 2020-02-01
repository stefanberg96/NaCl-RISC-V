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
    lw     a3, 16(a0)     # load h[4]  
    srli   t1, a3, 26     #
    slli   t2, t1, 2      #
    add    t3, t1, t2     # h[4]*5
    sw     t3, 4(sp)      # c[0]=h[4]*5
    li     t3, 0x3ffffff  # ADDED
    and    t1, a3, t3     #
    sw     t1, 16(a0)
    addi   a1, sp, 4      # address of c[0] 
    jal    add226asm
    lw     t1, 16(s0)     # load h[4]
    srli   t3, t1, 26     # h[4]>>26
    slli   t2, t3, 2      #
    add    t3, t3, t2     # h[4]>>26 *5
    sw     t3, 4(sp)      # c[0] = (h[4]>>26)*5
    li     t3, 0x3ffffff  # ADDED
    and    t1, t1, t3     #
    sw     t1, 16(s0)     #
    mv     a0, s0         # start address of h
    addi   a1, sp, 4      # start address of c
    jal    add226asm
    lw     ra, 28(sp)     # restore return address
    lw     s0, 24(sp)     #
    addi   sp, sp, 32     # restore stack space
    ret

.globl squeeze226param
.type squeeze226param, @function
squeeze226param:
    li   t6, 0x3ffffff    # 2^26-1
    srli t0, a4, 26       #
    slli t1, t0, 2        # overflow result[4]*4
    add  t0, t0, t1       # overflow result[4]*5
    add  a0, a0, t0       #
    and  a4, a4, t6       #
    srli t0, a0, 26       # overflow result[0]
    add  a1, a1, t0       #
    and  a0, a0, t6       #
    srli t0, a1, 26       # overflow result[1]
    add  a2, a2, t0       #
    and  a1, a1, t6       #
    srli t0, a2, 26       # overflow result[2]
    add  a3, a3, t0       #
    and  a2, a2, t6       #
    srli t0, a3, 26       # overflow result[3]
    add  a4, a4, t0       #
    and  a3, a3, t6       #
    srli t0, a4, 26       # overflow result[4]
    slli t1, t0, 2        # 
    add  t0, t1, t0       #
    add  a0, a0, t0       #
    and  a4, a4, t6       #
    ret

