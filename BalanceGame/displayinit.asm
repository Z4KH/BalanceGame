; 'displayinit.asm'
; This file initializes the ouptut ports for the display.
; Registers Changed
;	- R16 - Used to output data to ports
; Revision History
;	- 05/18/2024	Zachary Pestrikov	Wrote File



;Procedure: InitDisplay
;Description:    This Procedure initializes the I/O ports for the display, and any shared variables.
;Operational Description:    The procedure sets ports A, C, and D to output ports
;Arguments:      None
;Return Values:  None
;Shared Variables: currGroup - initialized to 0
;Local Variables: R16
;Input:          None
;Output:         None
;Error Handling: Interrupts are dissabled
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None - Interrupt is not called until after function runs
;Registers Changed: R16 - used to output to ports

.cseg

InitDisplay:       
		CALL ClearDisplay          
InitPorts:
        LDI    R16, OUTDATA             
        OUT     DDRA, R16		; Port A Selects between the first 7 game LED bars
		OUT		DDRC, R16		; Port C outputs the data sent to the displays
		OUT 	DDRD, R16		; Port D selects digits on the 4-digit display and selects the last two game LED bars
InitData:
		LDI		R16, 0
		STS		currGroup, R16	; first group is 0th group of LEDs 
ExitInitDisplay:
        CLZ
        RET
