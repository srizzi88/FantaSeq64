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
;   - Detect keypress and send MIDI All Notes Off panic
;   - Perform clean teardown and return to BASIC
; ============================================================

!zone main

; Helper routines

STOP_TIMER:
    ; Disable interrupts and stop the PTM.
    SEI
    LDA #$43
    STA TIMERCTRL

    ; Clear any pending PTM interrupt before restoring vectors.
    LDA TIMERSTAT
    AND #$01
    BEQ .done
    LDA TIMERACK

.done:
    RTS

PANIC_ALL_NOTES_OFF:
    ; Send CC123 value 0 on all 16 MIDI channels.
    LDX #$0F
.panic_loop:
    TXA
    ORA #$B0
    JSR SEND_ACIA_BYTE
    LDA #$7B
    JSR SEND_ACIA_BYTE
    LDA #$00
    JSR SEND_ACIA_BYTE
    DEX
    BPL .panic_loop
    RTS

SEND_ACIA_BYTE:
    ; Byte to send is passed in A. Uses Y as a scratch register.
    TAY
.wait_tdre:
    LDA ACIASTAT
    AND #$02
    BEQ .wait_tdre
    TYA
    STA ACIADATA
    RTS


; Entry point from BASIC

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

    ; Manual stop: stop further PTM IRQ production, send MIDI panic,
    ; then continue through the shared teardown tail.
    JSR STOP_TIMER
    JSR PANIC_ALL_NOTES_OFF
    JMP .restore_exit

TEARDOWN:
    JSR STOP_TIMER

.restore_exit:
    ; Restore original IRQ vector
    LDA OLDVECLO
    STA IRQVECLO
    LDA OLDVECHI
    STA IRQVECHI

    ; Enable interrupts
    CLI

    ; return cleanly to BASIC
    RTS

