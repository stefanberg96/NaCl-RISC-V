.text

.globl securemul226
.type securemul226, @function
securemul226:
   li      a2, 0         # x_h
   li      a3, 0         # r_l
   andi    t1, a1, 1     # create mask 
   sub     t1, zero, t1  #
   and     t1, a0, t1    # apply mask
   add     a3, a3, t1    # increase result
   slli    a0, a0, 1     # shift 1
   srli    a1, a1, 1     #
   andi    t1, a1, 1     # create mask 
   sub     t1, zero, t1  #
   and     t1, a0, t1    # apply mask
   add     a3, a3, t1    # increase result
   slli    a0, a0, 1     # shift 2
   srli    a1, a1, 1     #
   andi    t1, a1, 1     # create mask 
   sub     t1, zero, t1  #
   and     t1, a0, t1    # apply mask
   add     a3, a3, t1    # increase result
   slli    a0, a0, 1     # shift 3
   srli    a1, a1, 1     #
   andi    t1, a1, 1     # create mask      
   sub     t1, zero, t1  #
   and     t1, a0, t1    # apply mask
   add     a3, a3, t1    # increase result
   slli    a0, a0, 1     # shift 4
   srli    a1, a1, 1     #
   andi    t1, a1, 1     # create mask      
   sub     t1, zero, t1  #
   and     t1, a0, t1    # apply mask
   add     a3, a3, t1    # increase result
   slli    a0, a0, 1     # shift 5
   srli    a1, a1, 1     #
   andi    t1, a1, 1     # create mask      
   sub     t1, zero, t1  #
   and     t1, a0, t1    # apply mask
   add     a3, a3, t1    # increase result
   sltu    t1, a3, t1
   mv      a4, t1

   srli    a1, a1, 1     # shift 6
   srli    t1, a0, 31    #
   mv      a2, t1        # x_h
   slli    a0, a0, 1     #
   andi    t1, a1, 1     # create mask
   sub     t1, zero, t1  #
   and     t2, a2, t1    # apply mask
   and     t1, a0, t1    #
   add     a3, t1, a3    # increase result
   sltu    t1, a3, t1    # handle carry
   add     a4, a4, t1    # r_h
   add     a4, a4, t2    #

   li      a5, 19
loop:
   srli    a1, a1, 1     # shift 
   slli    a2, a2, 1     #
   srli    t1, a0, 31    #
   add     a2, a2, t1    # x_h
   slli    a0, a0, 1     #
   andi    t1, a1, 1     # create mask
   sub     t1, zero, t1  #
   and     t2, a2, t1    # apply mask
   and     t1, a0, t1    #
   add     a3, t1, a3    # increase result
   sltu    t1, a3, t1    # handle carry
   add     a4, a4, t1    # 
   add     a4, a4, t2    #
   addi    a5, a5, -1    # update loop variables
   bnez    a5, loop

   mv      a0, a3        # return result
   mv      a1, a4        #
   ret

