
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

.globl add216asm
.type add216asm , @function
add216asm:
    li    t3, 0      # u = 0
    li    t4, 0xFFFF # load constant
    add   t5, a0, 32 # stopping condition h[8]
loop216:
    lw    t1, 0(a0)  # load h[0]
    lw    t2, 0(a1)  # load c[0]
    add   t1, t1, t2 # t1= h[0]+c[0]
    add   t3, t3, t1 # u+= h[0]+c[0]
    and   t2, t3, t4 # u & 0xFFFF
    sw    t2, 0(a0)  # store u & 0xFFFF = h[0]
    srli  t3, t3, 16 # u >>= 16
    addi  a0, a0, 4  # update to h[i+1]
    addi  a1, a1, 4  # update to c[i+1]
    ble   a0, t5, loop216
    ret
