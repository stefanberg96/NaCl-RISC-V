.text

.globl disable_interrupts
.type disable_interrupts, @function
disable_interrupts:
   csrrsi   zero, mstatus, 0
   ret
