.text

.globl mul320
.align 2
mul320:
  mv   a1, a0
  slli a0, a0, 0x6
  slli a1, a1, 0x8
  add  a0, a0, a1
  ret 
