; ============================================================
; variables.h — RAM variable allocation and buffer layout
;
; Emits actual bytes into the binary — no equates here.
; !src'd last in all.asm so all variables land after code.
; ============================================================

; --- RAM Variables ---
PPQN:         !fill 1       ; configurable PPQN (poked from BASIC at $C003)
HALTED:       !fill 1       ; $01 when EOF sentinel reached
DELTA:        !fill 1       ; tick countdown to next event
BUFHEAD:      !fill 1       ; circular buffer write index (IRQ-owned)
BUFTAIL:      !fill 1       ; circular buffer read index  (main-loop-owned)
TICKS:        !fill 1       ; counts down timer ticks per beat. Reloaded with PPQN
OLDVECLO:     !fill 1       ; saved IRQ vector low  byte
OLDVECHI:     !fill 1       ; saved IRQ vector high byte

; --- Circular Buffer (page-aligned, 256 bytes) ---
; BUFHEAD and BUFTAIL wrap naturally via 8-bit overflow.
; Buffer is empty when BUFHEAD == BUFTAIL.
!align 255, 0
CIRCBUF:      !fill 256



