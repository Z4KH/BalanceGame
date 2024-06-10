; 'timerdef.asm'
; This file contains the hardware definitions for the timer.
;
; Revision History:
;     5/18/24  Zachary Pestrikov    added file to project




; setup values for Timer 0
.EQU    TIMERCLK8    = 0b00000010	;timer runs at CLK/8
.EQU    TIME_INTERRUPT    =   3   ; want to interrupt dec timeleft every ms
