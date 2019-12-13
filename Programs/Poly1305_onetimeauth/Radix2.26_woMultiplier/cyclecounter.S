.text

.globl getcycles
.align 2
getcycles:
#    csrr a1, mcycleh
    csrr a0, mhpmcounter3
    csrr a1, mcycle
#    csrr a2, mcycleh
#    bne a1, a2, getcycles
    ret

.globl icachemisses
.type icachemisses, @function
icachemisses:
    li t0, 0x6001
    csrw mhpmevent3, t0 #instruction cache misses
    ret

.globl getsp
.align 2
getsp:
    mv a0, sp
    ret
