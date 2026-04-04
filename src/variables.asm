; ============================================================
; variables.asm — RAM variable allocation and buffer layout
;
; Emits actual bytes into the binary.
; ============================================================

; --- RAM Variables ---
HALTED:       !fill 1       ; $01 when EOF sentinel reached
DELTA:        !fill 1       ; tick countdown to next event
BUFHEAD:      !fill 1       ; circular buffer write index (IRQ-owned)
BUFTAIL:      !fill 1       ; circular buffer read index  (main-loop-owned)
OLDVECLO:     !fill 1       ; saved IRQ vector low  byte
OLDVECHI:     !fill 1       ; saved IRQ vector high byte

; --- Circular Buffer (page-aligned, 256 bytes) ---
; BUFHEAD and BUFTAIL wrap naturally via 8-bit overflow.
; Buffer is empty when BUFHEAD == BUFTAIL.
!align 255, 0
CIRCBUF:      !fill 256



