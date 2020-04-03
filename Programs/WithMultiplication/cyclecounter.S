.text

.globl getcycles
getcycles:
    csrr t0, mcycle
    csrr t1, mhpmcounter3
    csrr t2, mhpmcounter4
    nop
    sw   t0, 0(a0)
    sw   t1, 4(a0)
    sw   t2, 8(a0)
    ret

.globl getcycle
getcycle:
   csrr a0, mcycle
   ret

.globl icachemisses
.type icachemisses, @function
icachemisses:
    li t0, 0x6001
    csrw mhpmevent3, t0 #Branch direction mis
    li t0, 0x801
    csrw mhpmevent4, t0 #Branch target miss
    ret

.globl getsp
getsp:
    mv a0, sp
    ret

.globl getra
getra:
    lw a0, 1244(sp)
    ret
