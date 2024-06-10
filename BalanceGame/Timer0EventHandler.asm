; 'Timer0EventHandler.asm'
; This file manages all interrupt features

; Procedures Included:
;   Timer0EventHandler

; Registers Changed:
;   R16

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
    CALL MultiplexDisplay
    CALL ButtonEventHandler

    LDS  R16,   TimerCounter
    INC  R16
    STS TimerCounter,   R16
    CPI R16,    TIME_INTERRUPT    ; need to dec time every ms
    BRNE    ExitEventHandler ; if ms hasn't passed skip time stuff
    CLR R16 ; if ms passed, reset timer counter
    STS TimerCounter,   R16

HandleTime: ; handle counting down the game clock
    LDS R16,    TimeLeftMS
    CPI R16, 0           ; check if a whole CENTIsecond has passed by
    BRNE    DecrementTimeLeftMS


    LDS R17,    TimeLeftCS   ; if whole centisecond has passed, then wrap
    CPI R17,    0   ;check if a whole second has passed by
    BRNE    DecrementCS

    ; if whole second has passed by then handle that:
    LDS R19, TimeLeftSeconds

    CPI R19, 0  ; ensure that game is not over
    BREQ    DecrementTimeLeftMS ; if game over, then hold at 0
    DEC R19 ; if game not over, then subtract a second because 1000ms passed
    STS TimeLeftSeconds,    R16
DecrementCS:
    DEC R17
    STS TimeLeftCS, R17
DecrementTimeLeftMS:
    DEC R16
    STS TimeLeftMS, R16
PlaySound:  ; handle playing tunes

ExitEventHandler:
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
TimeLeftMS: .BYTE   1 ; milliseconds between each centisecond of timeleft
TimeLeftCS: .BYTE   1  ; centiseconds between each second of timeleft
