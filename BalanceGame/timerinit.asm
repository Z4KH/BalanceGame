; 'timerinit.asm'
; This file initializes timer0 to 3.9ms interrupts.
; Registers changed:
    ; R16 - Count Register for clock to generate interrupts
; Revision History:
    ; 5/18/2024 Zachary Pestrikov   Wrote file
    ; 6/9/2024  Zachary Pestrikov   Added InitTimerVars
;________________________________________________________________________________

;Procedure: InitTimer0
;Description:    This Procedure initializes the timer to 3.9ms interrupts. 
;Operational Description:    The procedure initializes timer0.
;Arguments:      None
;Return Values:  None
;Shared Variables: TimerCounter - splits the interrupts - initialized to 0
;Local Variables: R16 - Used to output to timer
;Input:          None
;Output:         None
;Error Handling: Interrupts are dissabled
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None - Interrupt is not called until after function runs
;Registers Changed: R16 - Count Register for clock to generate interrupts

.cseg

InitTimer0:
                                        ;setup timer 0
    	CLR	R16			;clear the count register
    	OUT	TCNT0, R16	
    					;use CLK/8 as timer source, gives
    	LDI	R16, TIMERCLK8		;   8 MHz / 8 / 256 interrupt
    	OUT	TCCR0, R16		;   rate = 3900 Hz

    	IN	R16, TIMSK		;get current timer interrupt masks
    	ORI	R16, 1 << TOV0		;turn on timer 0 interrupts
    	OUT	TIMSK, R16
InitTimerVars:  ; initialize the timer counter variables
        LDS R16,    TimerCounter
        CLR R16
        STS TimerCounter,   R16
ExitInitTimer0:
        CLZ
        SEI
        RET
;________________________________________________________________________________
