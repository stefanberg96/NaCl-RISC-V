.text

.globl test
.type test, @function
test:
    addi a0, a0, -1
    bnez a0, test
    ret
