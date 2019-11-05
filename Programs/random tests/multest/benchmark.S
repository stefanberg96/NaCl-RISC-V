.text

.globl bench
.type bench, @function
bench:
    addi   sp,sp,-32
    sw     ra,28(sp)
    sw     s0,24(sp)
    li  a1, 10
    jal getcycles
    mv  s0, a0
    li  a0, 5
    jal securemul
    jal getcycles
    sub a0, a0, s0
    lw    ra, 28(sp)
    lw    s0, 24(sp)
    addi sp,sp, 32
    ret

