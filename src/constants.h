; =====================================================
; constants.h — Hardware addresses and system equates
; Pure symbol definitions — no code or data emitted
; =====================================================

; --- Zero Page --- 
EVTPTRLO      = $FB          ; low  byte of event-table pointer (indirect addr)
EVTPTRHI      = $FC          ; high byte of event-table pointer

; --- KERNAL Vectors ---
IRQVECLO      = $0314        ; C64 IRQ vector low  byte
IRQVECHI      = $0315        ; C64 IRQ vector high byte

; --- KERNAL Routines ---
KERNALIRQ     = $EA81        ; normal KERNAL IRQ exit
GETIN         = $FFE4        ; keyboard scan — returns char in A, 0 if none

; --- Motorola 6840 PTM ---
TIMERCTRL     = $DE00        ; PTM control register
TIMERSTAT     = $DE01        ; PTM status register  (bit 0 = our IRQ pending)
TIMERACK      = $DE02        ; read to acknowledge timer interrupt

; --- Motorola 6850 ACIA ---
ACIACTRL      = $DE08        ; write: control  register
ACIASTAT      = $DE08        ; read:  status   register (bit 1 = TDRE ready)
ACIADATA      = $DE09        ; read/write: MIDI data register

; --- Event Table (page-aligned, filled by separately loaded .prg) ---
; Records are 4 bytes each: [DELTA, BYTE1, BYTE2, BYTE3]
; BYTE1 = 0x80-0xFE:        3-byte message (BYTE1, BYTE2, BYTE3 transmitted)
; BYTE1 = 0x00:             2-byte message (BYTE2, BYTE3 transmitted)
; BYTE1 = 0xFF:             EOF marker
EVTTABLE      = $0C00
