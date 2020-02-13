.text

.globl securemul226
.type securemul226, @function
securemul226:
   mulh    t1, a0, a1    #
   mul     a0, a0, a1    #

   srli    t0, a0, 26    # handle overflow
   slli    a1, t1, 6     #
   or      a1, a1, t0
   li      t0, 0x3ffffff # 2^26-1
   and     a0, a0, t0    #

   ret


.globl mul121665asm
.type mul121665asm, @function
mul121665asm:

   addi    sp, sp, -32  # store variables
   sw      s0, 28(sp)   #
   sw      s1, 24(sp)   #
   sw      s2, 20(sp)   #
   sw      s3, 16(sp)   #
   sw      s4, 12(sp)   #

   lw      t0, 0(a1)    # A_0
   mv      s0, a0       # store out address
   mv      s1, a1       # store A address
  
   li      a7, 0x3ffffff# 2^26-1
   slli    t1, t0, 6    # A_0*64
   and     t1, t1, a7   # A_0*64_l
   add     t1, t1, t0   # A_0*65_l
   slli    t2, t0, 1    # A_0*2
   add     s3, t0, t2   # A_0*3
   slli    t3, t0, 16   # A_0*65536
   and     t3, t3, a7   # A_0*66536_l
   add     t3, t3, t1   # A_0*65601_l
   slli    t2, s3, 8    # A_0*768
   and     t2, t2, a7   # A_0*768_l
   add     t3, t3, t2   # A_0*66369_l
   slli    t2, t2, 3    # A_0*6144
   and     t2, t2, a7   # A_0*6144_l
   add     t3, t3, t2   # A_0*72513_l
   slli    t2, t2, 3    # A_0*49152
   and     t2, t2, a7   # A_0*49152_l
   add     t4, t3, t2   # A_0*121665_l

   srli    s2, t0, 20   # A_0*65_h, since A_0_h=0 A_0*65_h=A_0_h+A_0*64
   srli    t0, t0, 10   # A_0*65536_h
   add     s2, s2, t0   # A_0*65601_h
   lw      t0, 4(s1)    # A_2
   srli    s3, s3, 12   # A_0*49152_h
   add     s2, s2, s3   # A_0*114753_h
   srli    s3, s3, 3    # A_0*6144_h
   add     s2, s2, s3   # A_0*120897_h
   srli    s3, s3, 3    # A_0*768_h
   add     t5, s2, s3   # A_0*121665_h
   srli    s2, t4, 26   # overflow
   add     t5, t5, s2   #
   and     t4, t4, a7   #

   slli    t1, t0, 6    # A_1*64
   and     t1, t1, a7   # A_1*64_l
   add     t1, t1, t0   # A_1*65_l
   slli    t2, t0, 1    # A_1*2
   add     s3, t0, t2   # A_1*3
   slli    t3, t0, 16   # A_1*65536
   and     t3, t3, a7   # A_1*66536_l
   add     t3, t3, t1   # A_1*65601_l
   slli    t2, s3, 8    # A_1*768
   and     t2, t2, a7   # A_1*768_l
   add     t3, t3, t2   # A_1*66369_l
   slli    t2, t2, 3    # A_1*6144
   and     t2, t2, a7   # A_1*6144_l
   add     t3, t3, t2   # A_1*72513_l
   slli    t2, t2, 3    # A_1*49152
   and     t2, t2, a7   # A_1*49152_l
   add     t2, t3, t2   # A_1*121665_l
   add     t5, t5, t2   # A_1*121665_l+A_0*121665_h

   srli    s2, t0, 20   # A_1*65_h
   srli    t0, t0, 10   # A_1*65536_h
   add     s2, s2, t0   # A_1*65601_h
   lw      t0, 8(s1)    # A_2
   srli    s3, s3, 12   # A_1*49152_h
   add     s2, s2, s3   # A_1*114753_h
   srli    s3, s3, 3    # A_1*6144_h
   add     s2, s2, s3   # A_1*120897_h
   srli    s3, s3, 3    # A_1*768_h
   add     t6, s2, s3   # A_1*121665_h
   srli    s2, t5, 26   # overflow
   add     t6, t6, s2   #
   and     t5, t5, a7   #

   slli    t1, t0, 6    # A_2*64
   and     t1, t1, a7   # A_2*64_l                   
   add     t1, t1, t0   # A_2*65_l                   
   slli    t2, t0, 1    # A_2*2                      
   add     s3, t0, t2   # A_2*3                      
   slli    t3, t0, 16   # A_2*65536                  
   and     t3, t3, a7   # A_2*66536_l                
   add     t3, t3, t1   # A_2*65601_l                
   slli    t2, s3, 8    # A_2*768                    
   and     t2, t2, a7   # A_2*768_l                  
   add     t3, t3, t2   # A_2*66369_l                
   slli    t2, t2, 3    # A_2*6144                   
   and     t2, t2, a7   # A_2*6144_l                 
   add     t3, t3, t2   # A_2*72513_l                
   slli    t2, t2, 3    # A_2*49152                  
   and     t2, t2, a7   # A_2*49152_l                
   add     t2, t3, t2   # A_2*121665_l               
   add     t6, t6, t2   # A_2*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_2*65_h
   srli    t0, t0, 10   # A_2*65536_h                 
   add     s2, s2, t0   # A_2*65601_h
   lw      t0, 12(s1)   # A_3
   srli    s3, s3, 12   # A_2*49152_h
   add     s2, s2, s3   # A_2*114753_h
   srli    s3, s3, 3    # A_2*6144_h
   add     s2, s2, s3   # A_2*120897_h
   srli    s3, s3, 3    # A_2*768_h
   add     a0, s2, s3   # A_2*121665_h
   srli    s2, t6, 26   # overflow
   add     a0, a0, s2   #
   and     t6, t6, a7   #

   slli    t1, t0, 6    # A_3*64
   and     t1, t1, a7   # A_3*64_l                   
   add     t1, t1, t0   # A_3*65_l                   
   slli    t2, t0, 1    # A_3*2                      
   add     s3, t0, t2   # A_3*3                      
   slli    t3, t0, 16   # A_3*65536                  
   and     t3, t3, a7   # A_3*66536_l                
   add     t3, t3, t1   # A_3*65601_l                
   slli    t2, s3, 8    # A_3*768                    
   and     t2, t2, a7   # A_3*768_l                  
   add     t3, t3, t2   # A_3*66369_l                
   slli    t2, t2, 3    # A_3*6144                   
   and     t2, t2, a7   # A_3*6144_l                 
   add     t3, t3, t2   # A_3*72513_l                
   slli    t2, t2, 3    # A_3*49152                  
   and     t2, t2, a7   # A_3*49152_l                
   add     t2, t3, t2   # A_3*121665_l               
   add     a0, a0, t2   # A_3*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_3*65_h
   srli    t0, t0, 10   # A_3*65536_h                 
   add     s2, s2, t0   # A_3*65601_h
   lw      t0, 16(s1)   # A_4
   srli    s3, s3, 12   # A_3*49152_h
   add     s2, s2, s3   # A_3*114753_h
   srli    s3, s3, 3    # A_3*6144_h
   add     s2, s2, s3   # A_3*120897_h
   srli    s3, s3, 3    # A_3*768_h
   add     a1, s2, s3   # A_3*121665_h
   srli    s2, a0, 26   # overflow
   add     a1, a1, s2   #
   and     a0, a0, a7   #

   slli    t1, t0, 6    # A_4*64
   and     t1, t1, a7   # A_4*64_l                   
   add     t1, t1, t0   # A_4*65_l                   
   slli    t2, t0, 1    # A_4*2                      
   add     s3, t0, t2   # A_4*3                      
   slli    t3, t0, 16   # A_4*65536                  
   and     t3, t3, a7   # A_4*66536_l                
   add     t3, t3, t1   # A_4*65601_l                
   slli    t2, s3, 8    # A_4*768                    
   and     t2, t2, a7   # A_4*768_l                  
   add     t3, t3, t2   # A_4*66369_l                
   slli    t2, t2, 3    # A_4*6144                   
   and     t2, t2, a7   # A_4*6144_l                 
   add     t3, t3, t2   # A_4*72513_l                
   slli    t2, t2, 3    # A_4*49152                  
   and     t2, t2, a7   # A_4*49152_l                
   add     t2, t3, t2   # A_4*121665_l               
   add     a1, a1, t2   # A_4*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_4*65_h
   srli    t0, t0, 10   # A_4*65536_h                 
   add     s2, s2, t0   # A_4*65601_h
   lw      t0, 20(s1)   # A_5
   srli    s3, s3, 12   # A_4*49152_h
   add     s2, s2, s3   # A_4*114753_h
   srli    s3, s3, 3    # A_4*6144_h
   add     s2, s2, s3   # A_4*120897_h
   srli    s3, s3, 3    # A_4*768_h
   add     a2, s2, s3   # A_4*121665_h
   srli    s2, a1, 26   # overflow
   add     a2, a2, s2   #
   and     a1, a1, a7   #

   slli    t1, t0, 6    # A_5*64
   and     t1, t1, a7   # A_5*64_l                   
   add     t1, t1, t0   # A_5*65_l                   
   slli    t2, t0, 1    # A_5*2                      
   add     s3, t0, t2   # A_5*3                      
   slli    t3, t0, 16   # A_5*65536                  
   and     t3, t3, a7   # A_5*66536_l                
   add     t3, t3, t1   # A_5*65601_l                
   slli    t2, s3, 8    # A_5*768                    
   and     t2, t2, a7   # A_5*768_l                  
   add     t3, t3, t2   # A_5*66369_l                
   slli    t2, t2, 3    # A_5*6144                   
   and     t2, t2, a7   # A_5*6144_l                 
   add     t3, t3, t2   # A_5*72513_l                
   slli    t2, t2, 3    # A_5*49152                  
   and     t2, t2, a7   # A_5*49152_l                
   add     t2, t3, t2   # A_5*121665_l               
   add     a2, a2, t2   # A_5*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_5*65_h
   srli    t0, t0, 10   # A_5*65536_h                 
   add     s2, s2, t0   # A_5*65601_h
   lw      t0, 24(s1)   # A_6
   srli    s3, s3, 12   # A_5*49152_h
   add     s2, s2, s3   # A_5*114753_h
   srli    s3, s3, 3    # A_5*6144_h
   add     s2, s2, s3   # A_5*120897_h
   srli    s3, s3, 3    # A_5*768_h
   add     a3, s2, s3   # A_5*121665_h
   srli    s2, a2, 26   # overflow
   add     a3, a3, s2   #
   and     a2, a2, a7   #

   slli    t1, t0, 6    # A_6*64
   and     t1, t1, a7   # A_6*64_l                   
   add     t1, t1, t0   # A_6*65_l                   
   slli    t2, t0, 1    # A_6*2                      
   add     s3, t0, t2   # A_6*3                      
   slli    t3, t0, 16   # A_6*65536                  
   and     t3, t3, a7   # A_6*66536_l                
   add     t3, t3, t1   # A_6*65601_l                
   slli    t2, s3, 8    # A_6*768                    
   and     t2, t2, a7   # A_6*768_l                  
   add     t3, t3, t2   # A_6*66369_l                
   slli    t2, t2, 3    # A_6*6144                   
   and     t2, t2, a7   # A_6*6144_l                 
   add     t3, t3, t2   # A_6*72513_l                
   slli    t2, t2, 3    # A_6*49152                  
   and     t2, t2, a7   # A_6*49152_l                
   add     t2, t3, t2   # A_6*121665_l               
   add     a3, a3, t2   # A_6*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_6*65_h
   srli    t0, t0, 10   # A_6*65536_h                 
   add     s2, s2, t0   # A_6*65601_h
   lw      t0, 28(s1)   # A_7
   srli    s3, s3, 12   # A_6*49152_h
   add     s2, s2, s3   # A_6*114753_h
   srli    s3, s3, 3    # A_6*6144_h
   add     s2, s2, s3   # A_6*120897_h
   srli    s3, s3, 3    # A_6*768_h
   add     a4, s2, s3   # A_6*121665_h
   srli    s2, a3, 26   # overflow
   add     a4, a4, s2   #
   and     a3, a3, a7   #

   slli    t1, t0, 6    # A_7*64
   and     t1, t1, a7   # A_7*64_l                   
   add     t1, t1, t0   # A_7*65_l                   
   slli    t2, t0, 1    # A_7*2                      
   add     s3, t0, t2   # A_7*3                      
   slli    t3, t0, 16   # A_7*65536                  
   and     t3, t3, a7   # A_7*66536_l                
   add     t3, t3, t1   # A_7*65601_l                
   slli    t2, s3, 8    # A_7*768                    
   and     t2, t2, a7   # A_7*768_l                  
   add     t3, t3, t2   # A_7*66369_l                
   slli    t2, t2, 3    # A_7*6144                   
   and     t2, t2, a7   # A_7*6144_l                 
   add     t3, t3, t2   # A_7*72513_l                
   slli    t2, t2, 3    # A_7*49152                  
   and     t2, t2, a7   # A_7*49152_l                
   add     t2, t3, t2   # A_7*121665_l               
   add     a4, a4, t2   # A_7*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_7*65_h
   srli    t0, t0, 10   # A_7*65536_h                 
   add     s2, s2, t0   # A_7*65601_h
   lw      t0, 32(s1)   # A_8
   srli    s3, s3, 12   # A_7*49152_h
   add     s2, s2, s3   # A_7*114753_h
   srli    s3, s3, 3    # A_7*6144_h
   add     s2, s2, s3   # A_7*120897_h
   srli    s3, s3, 3    # A_7*768_h
   add     a5, s2, s3   # A_7*121665_h
   srli    s2, a4, 26   # overflow
   add     a5, a5, s2   #
   and     a4, a4, a7   #

   slli    t1, t0, 6    # A_8*64
   and     t1, t1, a7   # A_8*64_l                   
   add     t1, t1, t0   # A_8*65_l                   
   slli    t2, t0, 1    # A_8*2                      
   add     s3, t0, t2   # A_8*3                      
   slli    t3, t0, 16   # A_8*65536                  
   and     t3, t3, a7   # A_8*66536_l                
   add     t3, t3, t1   # A_8*65601_l                
   slli    t2, s3, 8    # A_8*768                    
   and     t2, t2, a7   # A_8*768_l                  
   add     t3, t3, t2   # A_8*66369_l                
   slli    t2, t2, 3    # A_8*6144                   
   and     t2, t2, a7   # A_8*6144_l                 
   add     t3, t3, t2   # A_8*72513_l                
   slli    t2, t2, 3    # A_8*49152                  
   and     t2, t2, a7   # A_8*49152_l                
   add     t2, t3, t2   # A_8*121665_l               
   add     a5, a5, t2   # A_8*121665_l+A_2*121665_h  

   srli    s2, t0, 20   # A_8*65_h
   srli    t0, t0, 10   # A_8*65536_h                 
   add     s2, s2, t0   # A_8*65601_h
   lw      t0, 36(s1)   # A_9
   srli    s3, s3, 12   # A_8*49152_h
   add     s2, s2, s3   # A_8*114753_h
   srli    s3, s3, 3    # A_8*6144_h
   add     s2, s2, s3   # A_8*120897_h
   srli    s3, s3, 3    # A_8*768_h
   add     a6, s2, s3   # A_8*121665_h
   srli    s2, a5, 26   # overflow
   add     a6, a6, s2   #
   and     a5, a5, a7   #

   li      s2, 0x1fffff # 2^21-1
   slli    t1, t0, 6    # A_9*64
   and     t1, t1, s2   # A_9*64_l                   
   add     t1, t1, t0   # A_9*65_l                   
   slli    t2, t0, 1    # A_9*2                      
   add     s3, t0, t2   # A_9*3                      
   slli    t3, t0, 16   # A_9*65536                  
   and     t3, t3, s2   # A_9*66536_l                
   add     t3, t3, t1   # A_9*65601_l                
   slli    t2, s3, 8    # A_9*768                    
   and     t2, t2, s2   # A_9*768_l                  
   add     t3, t3, t2   # A_9*66369_l                
   slli    t2, t2, 3    # A_9*6144                   
   and     t2, t2, s2   # A_9*6144_l                 
   add     t3, t3, t2   # A_9*72513_l                
   slli    t2, t2, 3    # A_9*49152                  
   and     t2, t2, s2   # A_9*49152_l                
   add     t2, t3, t2   # A_9*121665_l               
   add     a6, a6, t2   # A_9*121665_l+A_2*121665_h  
   srli    t1, a6, 21   # overflow
   and     a6, a6, s2   #

   srli    s2, t0, 15   # A_9*65_h
   srli    t0, t0, 5    # A_9*65536_h                 
   add     s2, s2, t0   # A_9*65601_h
   srli    s3, s3, 7    # A_9*49152_h
   add     s2, s2, s3   # A_9*114753_h
   srli    s3, s3, 3    # A_9*6144_h
   add     s2, s2, s3   # A_9*120897_h
   srli    s3, s3, 3    # A_9*768_h
   add     s2, s2, s3   # A_9*121665_h  
   add     s2, s2, t1   # handle overflow

   slli    t0, s2, 4    # overflow*16
   slli    t1, s2, 1    # overflow*2
   add     t0, s2, t0   # overflow*17
   add     t0, t0, t1   # overflow*19
   add     t4, t4, t0   # res[0]+= overflow*19

   srli    t1, t4, 26   # handle carries
   and     t4, t4, a7   #
   add     t5, t5, t1   #
   srli    t1, t5, 26   # res[1]
   and     t5, t5, a7   #
   add     t6, t6, t1   #
   srli    t1, t6, 26   # res[2]
   and     t6, t6, a7   #
   add     a0, a0, t1   #
   srli    t1, a0, 26   # res[3]
   and     a0, a0, a7   #
   add     a1, a1, t1   #
   srli    t1, a1, 26   # res[4]
   and     a1, a1, a7   # 
   add     a2, a2, t1   #
   srli    t1, a2, 26   # res[5]
   and     a2, a2, a7   #
   add     a3, a3, t1   #
   srli    t1, a3, 26   # res[6]
   and     a3, a3, a7   #
   add     a4, a4, t1   #
   srli    t1, a4, 26   # res[7]
   and     a4, a4, a7   #
   add     a5, a5, t1   #
   srli    t1, a5, 26   # res[8]
   and     a5, a5, a7   #
   add     a6, a6, t1   #
   
   sw      t4, 0(s0)    #
   sw      t5, 4(s0)    #
   sw      t6, 8(s0)    #
   sw      a0, 12(s0)   #
   sw      a1, 16(s0)   #
   sw      a2, 20(s0)   #
   sw      a3, 24(s0)   #
   sw      a4, 28(s0)   #
   sw      a5, 32(s0)   #
   sw      a6, 36(s0)   #


   lw      s0, 28(sp)   # restore variables
   lw      s1, 24(sp)   #
   lw      s2, 20(sp)   #
   lw      s3, 16(sp)   #
   lw      s4, 12(sp)   #
   addi    sp, sp, 32   #
   ret 

