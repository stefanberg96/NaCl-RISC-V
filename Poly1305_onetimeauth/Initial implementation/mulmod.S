.text

.globl mulmodasm
.type mulmodasm, @function
mulmodasm:
   addi  sp, sp, -96 # space for the hr array and to temporarily store s2, s3, s4
   sw    s2, 96(sp)
   sw    s3, 92(sp)
   sw    s4, 88(sp)
   sw    s5, 84(sp) 
   sw    ra, 80(sp)   # store the return address
   mv    s4, a0       # store h base address into s4 
   mv    s5, a1       # store r base address into s5
   li    s2, 0        # set i to 0
outer_loop:
   li    s3, 0        # set u to 0
   slli  t1, s2, 2    # stopping condition of inner loop 1
   add   t6, t1, s4   # add the stopping condition to the base address of h
   add   t5, s5, t1   # store address of ith element of r
   mv    t4, s4       # start from the base address of h
inner_loop1:
   lw    a0, 0(t4)    # load value of h[i] into a0
   lw    a1, 0(t5)    # load value of r[i-j] into a1 
   jal   securemul    
   add   s3, s3, a0   # u+= h[i]*r[i-j] 
   addi  t4, t4, 4    # increment counter j
   addi  t5, t5, -4   # 
   ble   t4, t6, inner_loop1

   #mv    a0, s3
   #jal   print32bytes # debugging

   addi  t6, s4, 64   # update stopping condition to inner loop 2
   addi  t5, t5, 68   # update address from r[i-j] to r[i-j+17] 
inner_loop2:   
   lw    a0, 0(t4)    # load h[i]
   lw    a1, 0(t5)    # load r[i-j+17]
   jal   securemul
   jal   mul320
   add   s3, s3, a0   # u+= (h[i]*r[i-j+17])*320
   addi  t4, t4, 4    # increment counter j
   addi  t5, t5, -4   #
   ble   t4, t6, inner_loop2

   slli  t4, s2, 2    # calculate i*4
   sub   t4, sp, t4   # address of hr[i]+76
   sw    s3, 76(t4)   # hr[i]=u
   addi  s2, s2, 1    # increment i
   li    t1, 16       # stop value of outer_loop
   ble   s2, t1, outer_loop

   #copy hr into h
   addi  t1, sp, 76   # address of hr[0]
   addi  t6, s4, 64   # stopping condition of copy_loop
copy_loop: 
   lw    t2, 0(t1)    # load hr[i]
   sw    t2, 0(s4)    # h[i]=hr[i]   
   addi  t1, t1, -4   # increment counters
   addi  s4, s4, 4    #
   ble   s4, t6, copy_loop

   addi  a0, t6, -64  # base address of h
   jal   squeezeasm

   lw    s2, 96(sp)   # restore saved variables
   lw    s3, 92(sp)
   lw    s4, 88(sp)
   lw    s5, 84(sp)
   lw    ra, 80(sp)
   addi  sp, sp, 96 
   ret
