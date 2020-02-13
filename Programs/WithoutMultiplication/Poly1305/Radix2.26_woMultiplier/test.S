.text

.globl test
.type test, @function
test:
    mv a3, a0
loop:
    lw a1, 0(a3)
    addi  a0, a0, -1
    bnez  a0, loop
    addi  a0, a0, 5
    ret
