; 'timerdef.asm'
; This file contains the hardware definitions for the timer.
;
; Revision History:
;     5/18/24  Zachary Pestrikov    added file to project
;     6/10/24   Zachary Pestrikov   added game time consts




; setup values for Timer 0
.EQU    TIMERCLK8    = 0b00000010	;timer runs at CLK/8
.EQU    TIME_INTERRUPT    =   39   ; want to interrupt dec timeleft every 10 ms


; game time constants
.EQU    GAMETIME    =   61  ;60 seconds to win the game
.EQU    CS_PER_DS   =   10  ; 10 centiseconds per decisecond
.EQU    DS_PER_SECOND   =   10  ; 10 deciseconds per second
