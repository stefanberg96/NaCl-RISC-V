.text

.globl getcycles
.align 2
getcycles:
    csrr a0, mcycle
    ret
