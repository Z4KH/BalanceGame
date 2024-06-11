; 'Timer0EventHandler.asm'
; This file manages all interrupt features

; Procedures Included:
;   Timer0EventHandler

; Registers Changed:
;   R16, R17, R19, R20

; Revision History:
;   06/09/2024  Zachary Pestrikov   Drafted File

;________________________________________________________________________________

.cseg

Timer0EventHandler:
    PUSH    R16
    IN  R16,    SREG
    PUSH    R16
    PUSH    R17
    PUSH    R19
    PUSH    R20
    CALL MultiplexDisplay
    CALL ButtonEventHandler

    LDS  R16,   TimerCounter
    INC  R16
    STS TimerCounter,   R16
    CPI R16,    TIME_INTERRUPT    ; need to dec time every cs
    BRNE    ExitEventHandler ; if ms hasn't passed skip time stuff
    CLR R16 ; if ms passed, reset timer counter
    STS TimerCounter,   R16

HandleTime: ; handle counting down the game clock
    LDS R16,    TimeLeftCS
    CPI R16, 0           ; check if a whole DECIsecond has passed by
    BRNE    DecrementCS

    LDI R16,   CS_PER_DS    ; wrap 

    ; must move the ball
    LDI R20,    TRUE
    STS MoveBall,   R20


    LDS R17,    TimeLeftDS   
    CPI R17,    0   ;check if a whole second has passed by
    BRNE    DecrementDS

    ; if whole second has passed by then handle that:
    LDI R17,    DS_PER_SECOND   ; wrap 

    LDS R19, TimeLeftSeconds

    CPI R19, 0  ; ensure that game is not over
    BREQ    DecrementDS ; if game over, then hold at 0
    DEC R19 ; if game not over, then subtract a second because 1000ms passed
    STS TimeLeftSeconds,    R19
DecrementDS:
    DEC R17
    STS TimeLeftDS, R17
DecrementCS:
    DEC R16
    STS TimeLeftCS, R16
PlaySound:  ; handle playing tunes

ExitEventHandler:
    POP R20
    POP R19
    POP    R17
    POP R16
    OUT SREG,   R16
    POP R16
    RETI
    



;________________________________________________________________________________

.dseg

TimerCounter:	.BYTE 1; variable to split timer into 3900 kHz and .975 kHz
                            ; interrupts
TimeLeftSeconds:       .BYTE 1; time left in the game. in seconds, 
TimeLeftDS: .BYTE   1 ; deciseconds between each centisecond of timeleft
TimeLeftCS: .BYTE   1  ; centiseconds between each second of timeleft
