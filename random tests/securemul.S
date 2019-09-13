.text

.globl securemul
.align 2
securemul:
    li    t0, 10
    li    t1, 50
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
    ret

.globl add
.align 2
add:
  add a0, a0, a1;
  add t0, t0 ,t1;
  ret
