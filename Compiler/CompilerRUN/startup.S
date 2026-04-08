.section .text.start
.global _start

_start:
    /* Load stack pointer */
    lui  sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)

    /* Zero out BSS section */
    la   a0, __bss_start
    la   a1, __bss_end
bss_loop:
    bge  a0, a1, bss_done
    sw   zero, 0(a0)
    addi a0, a0, 4
    j    bss_loop
bss_done:

    /* Call main */
    call main

    /* Halt if main returns */
halt:
    j halt