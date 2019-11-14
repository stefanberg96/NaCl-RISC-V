.text

.globl mulmod216asm
.type mulmod216asm, @function
mulmod216asm:
   addi  sp, sp, -96 # space for the hr array and to temporarily store s2, s3, s4
   sw    s2, 96(sp)
   sw    s3, 92(sp)
   sw    s4, 88(sp)
   sw    s5, 84(sp) 
   sw    s6, 80(sp)
   sw    s7, 76(sp)
   sw    ra, 72(sp)   # store the return address
   mv    s4, a0       # store h base address into s4 
   mv    s5, a1       # store r base address into s5
   li    s2, 0        # set i to 0
   li    s6, 0        # u low
   li    s7, 0        # u high
   li    s3, 81920    # multiplication constant
   li    t3, 0xffff   # get lowest 16 bits constant
outer_loop_216:
   slli  t1, s2, 2    # stopping condition of inner loop 1
   add   t6, t1, s4   # add the stopping condition to the base address of h
   add   t5, s5, t1   # store address of ith element of r
   mv    t4, s4       # start from the base address of h
inner_loop1_216:
   lw    a0, 0(t4)    # load value of h[i] into a0
   lw    a1, 0(t5)    # load value of r[i-j] into a1 
   mul   a0, a0, a1   
   add   s6, s6, a0   # u+= h[i]*r[i-j] 
   sltu  t2, s6, a0   # t2 = s6<a0
   add   s7, s7, t2
   addi  t4, t4, 4    # increment counter j
   addi  t5, t5, -4   # 
   ble   t4, t6, inner_loop1_216

   addi  t6, s4, 32   # update stopping condition to inner loop 2
   bgt   t4, t6, postloop # incase innerloop 1 reached the went to 9 it shoudl skip loop2
   addi  t5, t5, 36   # update address from r[i-j] to r[i-j+9] 
inner_loop2_216:   
   lw    a0, 0(t4)    # load h[i]
   lw    a1, 0(t5)    # load r[i-j+9]
   mul   a0, a0, a1   # h[i]*r[i-j+9] 
   mulhu a1, a0, s3   # high part of (h[u]*r[i-j+9])*81920 
   add   s7, s7, a1   #
   mul   a1, a0, s3   # low part of the multiplication
   add   s6, s6, a1   # add low part to u low
   sltu  a1, s6, a1   # handle carry
   add   s7, s7, a1   #
   addi  t4, t4, 4    # increment counter j
   addi  t5, t5, -4   #
   ble   t4, t6, inner_loop2_216

postloop:
   slli  t4, s2, 2    # calculate i*4
   sub   t4, sp, t4   # address of hr[i]-68
   and   t5, s6, t3   #
   sw    t5, 68(t4)   # hr[i]=u low & 0xFFFF
   srli  s6, s6, 16   # ulow = ulow >> 16
   slli  t5, s7, 16   # (u_high &0xFFFF << 16)
   or    s6, s6, t5   #
   srli  s7, s7, 16   #  u high = uhigh >> 16 
   addi  s2, s2, 1    # increment i
   li    t1, 8        # stop value of outer_loop
   ble   s2, t1, outer_loop_216
   
   lw    t5, 68(t4)
   slli  s6, s6, 16
   add   t5, t5, s6
   sw    t5, 68(t4)
   #copy hr into h
   addi  t1, sp, 68   # address of hr[0]
   addi  t6, s4, 32   # stopping condition of copy_loop
copy_loop_216: 
   lw    t2, 0(t1)    # load hr[i]
   sw    t2, 0(s4)    # h[i]=hr[i]   
   addi  t1, t1, -4   # increment counters
   addi  s4, s4, 4    #
   ble   s4, t6, copy_loop_216
 
   addi  a0, t6, -32  # base address of h
   jal   squeeze216asm

   lw    s2, 96(sp)   # restore saved variables
   lw    s3, 92(sp)
   lw    s4, 88(sp)
   lw    s5, 84(sp)
   lw    s6, 80(sp)
   lw    s7, 76(sp)
   lw    ra, 72(sp)
   addi  sp, sp, 96 
   ret
