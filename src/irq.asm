; =================================================================
; irq.asm — MIDI player IRQ Handler
; Fires on every 6840 PTM tick
;
; Responsibilities:
;   - Distinguish PTM IRQs from all other IRQ sources
;   - Acknowledge the timer interrupt
;   - Dispatch MIDI events from the event table into CIRCBUF
;   - Set HALTED when the EOF sentinel is reached
;   - Return directly for owned IRQs, chain only for non-owned IRQs
; =================================================================

!zone irq

IRQ_HANDLER:
    ; Is this our interrupt?
    LDA TIMERSTAT
    AND #$01
    BEQ .pass_through

    ; Acknowledge timer
    LDA TIMERACK

    ; If already halted, nothing more to do
    LDA HALTED
    BNE .irq_done

    ; Delta countdown 
    LDA DELTA
    BEQ .dispatch
    DEC DELTA
    BNE .irq_done

    ; Event dispatch loop
    ; Entered when DELTA reaches zero
    ; May iterate for simultaneous events (DELTA == $00).
.dispatch:
    LDY #1
    LDA (EVTPTRLO),Y      ; read byte 1
    CMP #$FF
    BEQ .eof_record

    LDX BUFHEAD           ; prepare write pointer
    CMP #$00
    BEQ .two_byte_event

.three_byte_event:
    STA CIRCBUF,X         ; write byte 1
    INX

.two_byte_event:
    INY
    LDA (EVTPTRLO),Y      ; read byte 2
    STA CIRCBUF,X
    INX
    INY
    LDA (EVTPTRLO),Y      ; read byte 3
    STA CIRCBUF,X
    INX
    STX BUFHEAD           ; save updated write pointer
    JMP .advance_pointer

.eof_record:
    LDA #$01
    STA HALTED
    JMP .irq_done

.advance_pointer:
    ; Advance event pointer by 4 bytes
    LDA EVTPTRLO
    CLC
    ADC #4
    STA EVTPTRLO
    BCC .load_delta
    INC EVTPTRHI

.load_delta:
    LDY #0
    LDA (EVTPTRLO),Y      ; peek at next record's DELTA
    BEQ .dispatch         ; DELTA == $00 means next event happens in this tick, loop immediately
    STA DELTA

.irq_done:
    JMP KERNALIRQ

.pass_through:
    JMP (OLDVECLO)

