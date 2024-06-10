; "PlayNote.asm"
; This file controls the speaker, and includes the playnote procedure

; Procedures Included:
;	PlayNote

; Revision history:
;   06/01/2024  Zachary Pestrikov   Wrote file
;	06/02/2024	Zachary Pestrikov	Debugged File
;	06/05/2024	Zachary Pestrikov	Documented File

; Registers Changed: 
;   R17|R16
;   R20
;   R21

;___________________________________________________________________________________
.cseg

;Procedure: PlayNote(f)
;Description: This procedure plays a frequency f(hz) to the speaker.
;Operational Description: This procedure computes the appropriate value to put 
;							in the timer1 count register based on the given frequency, 
;							f. The frequency must be between greater than 0, and 
;							nowhere near the maximum frequency of 62,500hz. 
;							If it is not, then the speaker is turned off. The value
;							in the timer counter register is set to 
;							floor(CLOCK_FRQ_FACTOR / f).
;Arguments:      f - frequency to output to the speaker in hz. 16-bits passed in R17|R16
;Return Values:  None
;Shared Variables: None
;Local Variables: None
;Input:          None
;Output:         Speaker
;Error Handling: Turns speaker off if f = 0 or f close to or greater than 62,500
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Modifying the counter register 
;Constants:      CLOCK_FRQ_FACTOR = 8,000,000 / (2*64) - factor to divide the clock 
;                by when computing the frequency.
;					SpeakerBit 0 the bit in port B that drives the speaker
;Registers Changed: R17|R16 - f(hz)
;					R21|R20 - buffer

PlayNote:
    ; Restart the timer counter 
    CLR R20
    OUT TCNT1H, R20
    OUT TCNT1L, R20
    CPI R17, CLOCK_FRQ_FACTORhigh ; cannot be close to the maximum frequency 62,500hz
    BRSH    InvalidF
    CPI R17, 0          ; if frequency is 0, then turn speaker off
    BRNE    SpeakerOn
    CPI R16, 0          ; must be 0 in both reg's to be 0
    BRNE    SpeakerOn
InvalidF:
    CALL TurnSpeakerOff
    JMP ExitPlayNote
SpeakerOn: ; errors have been handled already
    ; compute CLOCK_FREQ_FACTOR / f
    LDI R21,    CLOCK_FRQ_FACTORhigh
    LDI R20,    CLOCK_FRQ_FACTORlow
    CALL Div16 		; result gets put in R21|R20
OutputSound: ; load the result into the speaker counter register
    CBI PORTB,  SpeakerBit   ; turn off speaker
    OUT OCR1AL, R20     ; output frequency
    OUT OCR1AH, R21
    SBI PORTB,  SpeakerBit  ; turn on speaker
ExitPlayNote:
    RET
;__________________________________________________________________________________
