; 'DisplayMultiplex.asm'
;  This file handles multiplexing all LEDs on the game board

;  Registers Changed:
;		- R20 - Used to output to ports & handle local variables
;		- Y	- handles accessing shared vars
;		- R21 - handles data ouptut to display
;		- R22 - handles LED selection
;		- R23 - used in multiplication
;		- R0|R1 - used in multiplication

;  Revision History:
;		-	05/18/2024	Zachary Pestrikov	Wrote File



;Procedure: MultiplexLEDs()
;Description:    This Procedure is called every 3.9ms and updates the display by 
;                switching between LEDs and outputting to them at the rate of the interrupts(3.9ms).
;Operational Description:  Reads from the stored buffer variables and then outputs the to the LEDs
;                            a given portion of the buffer variables. Then goes to the next portion on the
;                            next interrupt.
;Arguments:      None
;                None
;Return Values:  None
;Shared Variables: displayBuffer - contains the state to write to each group of LEDs
					; Buffer Structure:
						;ledBar0		(leftmost bar of LEDs)	Select Lines: A=1,D=0
						;ledBar1		Select Lines: A=2,D=0
						;ledBar2		Select Lines: A=4,D=0
						;ledBar3		Select Lines: A=8,D=0
						;ledBar4		Select Lines: A=16,D=0
						;ledBar5		Select Lines: A=32,D=0
						;ledBar6		Select Lines: A=64,D=0
						;ledBar8		(rightmost bar of LEDs & Start/Stop)	Select Lines: A=0,D=1
						;ledBar7		Select Lines: A=0,D=2
						;7segMisc		(colons, decomals, etc.) Select Lines: A=0,D=4
						;Digit0			(rightmost digit) 	Select Lines: A=0,D=8
						;Digit1			Select Lines: A=0,D=16
						;Digit2			Select Lines: A=0,D=32
						;Digit3			(leftmost digit) 	Select Lines: A=0,D=64
;					currGroup - 0-indexed current group of LEDs the function will output to
;Local Variables:  data - the output data to be sent to the group of LEDs
;                  select - the select lines to be output to either port A or port C
;Input:          None
;Output:         4-digit 7-segment Display - based on the variable displayLEDout
;                Bar of LEDs - based on the variable gameLEDout
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. Only called during interrupt
;Constants:  NUM_LED_GROUPS - the number of different mutually exclusive groups of LEDs 
;				LED_GROUPS_PER_PORT	- the number of LED groups that are selected by each port
;            
;Registers Changed:
;			- R20 - handles moving around consts and vars
;			- Y	- handles accessing shared vars
;			- R21 - handles data ouptut to display
;			- R22 - handles LED selection
;			- R23 - used in multiplication
;			- R0|R1 - used in multiplication
;

.cseg

MultiplexDisplay:
;Push Changed Registers
	PUSH R20
	PUSH YL
	PUSH YH
	PUSH R21
	PUSH R22
	PUSH R23
	PUSH R0
	PUSH R1
	IN	R1, SREG
	PUSH R1
;ClearAllLEDs:			; don't want to see wrong values
	LDI R20, 0
	OUT	PORTA, R20		; A and D are select lines
	OUT PORTD, R20 
;Get currGroup (current group of LEDs to output
	LDS R20, currGroup
	INC R20	; currGroup = prevGroup++ % NUM_GROUPS
ModCurrGroup:	; to do mod, subtract NUM_GROUPS until less than NUM_GROUPS
	CPI R20, NUM_LED_GROUPS
	BRLO HaveCurrGroup	; currGroup < NUM_GROUPS  => output to that group (currGroup is 0 indexed)
	SUBI	R20, NUM_LED_GROUPS	; currGroup never goes past NUM_GROUPS(initialized to 0), so only need to check once
HaveCurrGroup:
	STS currGroup, R20	; put back for next interrupt
	; want to load addr(LEDBar0) + currgroup
	LDI YL, LOW(displayBuffer)		; use Y to access the buffer
	LDI YH, HIGH(displayBuffer)
	ADD YL, R20			;currGroup still in R20
	LDI R22, 0
	ADC YH, R22
	LD R21, Y			;R21 now holds the data => output it to port C(data port)
	OUT PORTC, R21
OutputDisplay:	; Get the select bits based on currGroup(R20), and output to ports A and D
; Select byte is just (2^{currGroup % Groups per port})
	MOV R21, R20	;R21 = curr group % group per port
	CPI R21, LED_GROUPS_PER_PORT ; begin curr Group % Groups per port
	BRLO RaiseTwo
	SUBI R21, LED_GROUPS_PER_PORT
RaiseTwo:	; raise 2^{R21}
	; 2^0 = 1, all other versions are 2^R21
	LDI R22, 1  ;R22 will be the output select byte
	LDI R23, 2  ;base is 2
Multiplication:	
; while(r21 != 0):
;	r22 *= 2
;	r21 -= 1	
	TST R21		
	BREQ DeterminePort	;if r21 == 0, then done
	MUL R22, R23		; R1|R0 <- r22 * 2
	MOV R22, R0		; only need low byte of R1|R0 because select <= 64
	DEC R21		;R21 -= 1
	JMP Multiplication
DeterminePort:
	LDI R21, 0
; if curr group >= groups per port, then choose port D
	CPI 	R20, LED_GROUPS_PER_PORT
	BRGE	OutputD
OutputA: 	; If port A is the select port for this group A<- select, D<- 0
	OUT	PORTA, R22
	OUT PORTD, R21
	JMP ExitMultiplexer	;done
OutputD:	; If port D is the select port for this group, D<-select A<-0 
	OUT PORTA, R21
	OUT PORTD, R22
ExitMultiplexer:
	; pop changed registers
	POP R1
	OUT SREG, R1
	POP R1
	POP R0
	POP R23
	POP R22
	POP R21
	POP YH
	POP YL
	POP R20
	RET


.dseg 

currGroup:	.BYTE 1	; the current group of LEDs to output to

; the buffer variable for storing the data to output to each display
displayBuffer: .BYTE	14
; Buffer Structure (bottom to top):
	;ledBar0		(leftmost bar of LEDs)	Select Lines: A=1,D=0
	;ledBar1		Select Lines: A=2,D=0
	;ledBar2		Select Lines: A=4,D=0
	;ledBar3		Select Lines: A=8,D=0
	;ledBar4		Select Lines: A=16,D=0
	;ledBar5		Select Lines: A=32,D=0
	;ledBar6		Select Lines: A=64,D=0
	;ledBar8		(rightmost bar of LEDs & Start/Stop)	Select Lines: A=0,D=1
	;ledBar7		Select Lines: A=0,D=2
	;7segMisc		(colons, decomals, etc.) Select Lines: A=0,D=4
	;Digit0			(rightmost digit) 	Select Lines: A=0,D=8
	;Digit1			Select Lines: A=0,D=16
	;Digit2			Select Lines: A=0,D=32
	;Digit3			(leftmost digit) 	Select Lines: A=0,D=64
