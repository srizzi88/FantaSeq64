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
KERNALSYS     = $EA31        ; pass-through for non-owned IRQs
GETIN         = $FFE4        ; keyboard scan — returns char in A, 0 if none

; --- Passport MH-02 / Motorola 6840 PTM ---
TIMERCTRL     = $DE00        ; PTM control register
TIMERSTAT     = $DE01        ; PTM status register  (bit 0 = our IRQ pending)
TIMERACK      = $DE02        ; read to acknowledge timer interrupt

; --- Motorola 6850 ACIA ---
ACIACTRL      = $DE08        ; write: control  register
ACIASTAT      = $DE08        ; read:  status   register (bit 1 = TDRE ready)
ACIADATA      = $DE09        ; read/write: MIDI data register

; --- Event Table (page-aligned, filled by separately loaded .prg) ---
; Records are 4 bytes each: [DELTA, STATUS, NOTE, VELOCITY]
EVTTABLE      = $0C00
