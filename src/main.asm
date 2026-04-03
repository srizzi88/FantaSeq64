; ============================================================
; main.asm — Initializer, Main Drain Loop, and Teardown
; Installed after interrupt service in memory.  
; Called from BASIC via SYS 49152; which jumps to INIT
;
; Responsibilities:
;   - Save and replace the IRQ vector
;   - Initialize all variables and hardware (ACIA, EVT_PTR)
;   - Release the 6840 timer (BASIC has pre-loaded the latches)
;   - Drain CIRCBUF to 6850 ACIA in a tight poll loop
;   - Detect keypress
;   - Perform clean teardown and return to BASIC
; ============================================================

!zone main

INIT:
    ; Disable interrupts
    SEI

    ; Save existing IRQ vector
    LDA IRQVECLO
    STA OLDVECLO
    LDA IRQVECHI
    STA OLDVECHI

    ; Install our IRQ handler
    LDA #<IRQ_HANDLER
    STA IRQVECLO
    LDA #>IRQ_HANDLER
    STA IRQVECHI

    ; Init shared variables
    LDA #0
    STA HALTED
    STA BUFHEAD
    STA BUFTAIL

    LDA PPQN
    STA TICKS

    ; Configure 6850 ACIA: master reset, then 8-N-1 / div-16
    LDA #$03
    STA ACIACTRL
    LDA #$15
    STA ACIACTRL

    ; Point event pointer at the start of the event table
    LDA #<EVTTABLE
    STA EVTPTRLO
    LDA #>EVTTABLE
    STA EVTPTRHI

    ; Pre-load DELTA_COUNT from first record
    LDY #0
    LDA (EVTPTRLO),Y
    STA DELTA

    ; Enable interrupts
    CLI

    ; Release timer — BASIC has already written the latches
    LDA #$42
    STA TIMERCTRL

MAIN_LOOP:
    LDA BUFHEAD
    CMP BUFTAIL
    BEQ .idle                ; buffer empty, go to idle tasks

    ; Poll ACIA TDRE (bit 1 of status register)
    LDA ACIASTAT
    AND #$02
    BEQ MAIN_LOOP            ; not ready, spin

    ; Send one byte to ACIA
    LDX BUFTAIL
    LDA CIRCBUF,X
    STA ACIADATA
    INX
    STX BUFTAIL
    JMP MAIN_LOOP

.idle:
    ; Check for halt condition
    LDA HALTED
    BNE TEARDOWN

.check_key:
    JSR GETIN
    BEQ MAIN_LOOP            ; no key, keep looping
    ; if any key pressed, fall through to TEARDOWN

TEARDOWN:
    ; Disable interrupts
    SEI

    ; Stop the timer — no more IRQs
    LDA #$43
    STA TIMERCTRL

    ; Restore original IRQ vector
    LDA OLDVECLO
    STA IRQVECLO
    LDA OLDVECHI
    STA IRQVECHI

    ; Enable interrupts
    CLI

    ; return cleanly to BASIC
    RTS
