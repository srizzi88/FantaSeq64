; ==========================================================
; all.asm — This is the only file passed to the assembler
; ==========================================================

!cpu 6510

; Constant definitions
!src "constants.h"

; Entry point from Basic
; SYS 49152
* = $C000
jmp INIT

; Variables at fixed location for easy access from Basic
; Circular buffer page-aligned included here
!src "variables.asm"   

; Initialization, main loop, and teardown
!src "main.asm"

; Interrupt handler
!src "irq.asm"

