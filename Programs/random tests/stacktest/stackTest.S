.text

.globl stackTest
.type stackTest, @function
stackTest:
    mv   t1, a0   # store h temporarily
    addi sp, sp, -96  #make space on the stack
    sw   s2, 96(sp)
    sw   s3, 92(sp)
    sw   s4, 88(sp)
    sw   s5, 84(sp) 
    sw   ra, 80(sp)


    #copy the array to the stack
    addi t2, a0, 68   # stop condition
    addi t3, sp, 76   # begin of the stack space
    li   t5, 15
loop:
    lw   t4, 0(a0)    # load h[i]
    addi t4, t4, 1
    sw   t4, 0(t3)    
    addi t5, t5, 1
    addi t3, t3, -4   
    addi a0, a0, 4
    ble  a0, t2, loop

    mv   a0, t1
    addi t3, sp ,76 
loop2:
    lw   t4, 0(t3)
    sw   t4, 0(a0)
    addi t3, t3, -4
    addi a0, a0, 4
    ble  a0, t2, loop2

    mv a0, sp
    jal print32bytes
    lw   s2, 96(sp)
    lw   s3, 92(sp)
    lw   s4, 88(sp)
    lw   s5, 84(sp)
    lw   ra, 80(sp)
    addi sp, sp, 96
    ret
