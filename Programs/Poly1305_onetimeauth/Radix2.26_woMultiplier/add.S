
.globl addasm
.type addasm , @function
addasm:
    li    t3, 0        # u = 0
    add   t5, a0, 64   # stopping condition h[16]
loop:
    lw    t1, 0(a0)    # load h[0]
    lw    t2, 0(a1)    # load c[0]
    add   t1, t1, t2   # t1= h[0]+c[0]
    add   t3, t3, t1   # u+= h[0]+c[0]
    andi   t2, t3, 255 # u & 255
    sw    t2, 0(a0)    # store u & 255 = h[0]
    srli  t3, t3, 8    # u >>= 8
    addi  a0, a0, 4    # update to h[i+1]
    addi  a1, a1, 4    # update to c[i+1]
    ble   a0, t5, loop
    ret

.globl add226asm
.type add226asm , @function
add226asm:
    li    t4, 0x3FFFFFF # load constant
    lw    t1, 0(a0)     # load h[0]
    lw    t2, 0(a1)     # load c[0]
    add   t3, t1, t2    # u= h[0]+c[0]
    and   t2, t3, t4    # u & 0x3FFFFFF
    sw    t2, 0(a0)     # store u & 0x3FFFFFF = h[0]
    srli  t3, t3, 26    # u >>= 26
    lw    t1, 4(a0)     # load h[1]
    lw    t2, 4(a1)     # load c[1]
    add   t1, t1, t2    # t1= h[1]+c[1]
    add   t3, t3, t1    # u+= h[1]+c[1]
    and   t2, t3, t4    # u & 0x3FFFFFF
    sw    t2, 4(a0)     # store u & 0x3FFFFFF = h[0]
    srli  t3, t3, 26    # u >>= 26
    lw    t1, 8(a0)     # load h[2]
    lw    t2, 8(a1)     # load c[0]
    add   t1, t1, t2    # t1= h[2]+c[2]
    add   t3, t3, t1    # u+= h[2]+c[2]
    and   t2, t3, t4    # u & 0x3FFFFFF
    sw    t2, 8(a0)     # store u & 0x3FFFFFF = h[2]
    srli  t3, t3, 26    # u >>= 26
    lw    t1, 12(a0)    # load h[3]
    lw    t2, 12(a1)    # load c[3]
    add   t1, t1, t2    # t1= h[3]+c[3]
    add   t3, t3, t1    # u+= h[3]+c[3]
    and   t2, t3, t4    # u & 0x3FFFFFF
    sw    t2, 12(a0)    # store u & 0x3FFFFFF = h[3]
    srli  t3, t3, 26    # u >>= 26
    lw    t1, 16(a0)    # load h[4]
    lw    t2, 16(a1)    # load c[4]
    add   t1, t1, t2    # t1= h[4]+c[4]
    add   t3, t3, t1    # u+= h[4]+c[4]
    sw    t3, 16(a0)    # store u & 0x3FFFFFF = h[4]
    ret
