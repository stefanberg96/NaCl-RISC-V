.text
.globl securemul
.type securemul, @function
securemul:
    mv    t0, a0
    mv    t1, a1
    mv    a0, zero
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1    
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1 
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3  
    srli  t0, t0, 1
    slli  t1, t1, 1
    andi  t2, t0, 1
    sub   t2, zero, t2
    and   t3, t1, t2
    add   a0, a0, t3
    ret 

# Multiply the value in a0 with 320
# Registers used:
# a0, a1
.globl mul320
.align 2
mul320:
    mv   a1, a0
    slli a0, a0, 0x6
    slli a1, a1, 0x8
    add  a0, a0, a1
    ret 
