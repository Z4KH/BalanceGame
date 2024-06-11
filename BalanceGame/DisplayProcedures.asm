; 'DisplayProcedures.asm'
; This file contains all procedures for updating the display
;
; Registers Changed:
; 	- R0 -
;	- R16 -
;	- R17 -
;	- R20 - 
; 	- R21 -
;	- R22 -
;   -  Y  -
;	-  Z  -
;
;
; Revision History
;	05/18/2024	Zachary Pestrikov   Wrote Clear, DisplayHex, and GameLED procedures
;   06/9/2024   Zachary Pestrikov   Added DisplayDecimal


.cseg
;
;Procedure: ClearDisplay()
;Description:    This Procedure turns off all LEDs on the gameboard.
;Operational Description:    The procedure sends 0's to all LEDs. The display is immediately cleared.
;Arguments:      None
;Return Values:  None
;Shared Variables: displayBuffer - contains the state to write to each group of LEDs, set to all 0's
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
;Local Variables: Group - the group that is currently being set to 0
;Input:          None
;Output:         All LED's on the board are turned off
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Storing 0's in buffer
;Constants: NUM_LED_GROUPS - the number of LED groups to turn off
;Registers Changed:
;	- R20 - used to count down bytes during loop
;	- R21 - used to set LED's
;	-  Y  - Points to the buffer

ClearDisplay:
	LDI R20, NUM_LED_GROUPS	; used as offset in loop
	LDI R21, 0	; setting all led's to 0
	LDI YL, LOW(displayBuffer)
	LDI	YH, HIGH(displayBuffer)
	CLI
ClearBufferLoop:
	TST R20
	BREQ ExitClearDisplay
	ST	Y+, R21
	DEC R20
	JMP ClearBufferLoop
ExitClearDisplay:
	SEI
	RET





;Procedure: DisplayHex(n)
;Description:    Displays the input (n) in hexademical to the 4-digit 7-segment display
;Operational Description:   This Procedure stores (n) in memory, which is cycled through in 
;                            the interrupts. If n is less than 4 digits, then only the low(nonzero) digits 
;								will be output.
;Arguments:      n - 4 digit hexademical number in R17|R16
;Return Values:  None
;Shared Variables:  displayBuffer - contains the state to write to each group of LEDs, set to all 0's
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
						;Digit2 		Select Lines: A=0,D=32
						;Digit3			(leftmost digit) 	Select Lines: A=0,D=64
;Local Variables: Nibble - R22 - the nibble currently being loaded into the buffer
;				  First_Digit - R19 - signifies whether the first nonzero digit has been found yet.
;Input:          None
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Storing (n) 
;Constants: UPPER_NIBBLE - UPPER nibble set to all ones
			;NUM_DIGITS - number of digits on 7-segment display
			;DIGITS_OFFSET - offset from buffer where digits are stored
			;DigitSegTable - table that holds segments for hex digits in the 7seg display
			;NIBBLES_PER_BYTE - 2
			;NIBBLES_PER_WORD - 4
;Registers Changed:
;	- R0 - Carry Propogation
;	- R17|R16	- n
;	- R19	- first digit
;	- R20 - Used to Store n
;	- R21 - hold bits of n
;	- R22 - count nibbles stored
;   - R23  - count nibbles passed
;	- Z - Table pointer
;

DisplayHex:
    PUSH    R19 ; save registers
    PUSH    R0
    PUSH    R20
    PUSH    R21
    PUSH    R22
    PUSH    ZL
    PUSH    ZH
	; get buffer digit pointer into Y
	LDI R22, 0	;nibbles parsed = 0
	LDI YL, LOW(displayBuffer)
	LDI YH, HIGH(displayBuffer)
	ADIW Y, DIGITS_OFFSET
	LDI R19, 0 ; first digit not found yet
    LDI R23,    NIBBLES_PER_WORD
    INC R23
	; get lower nibble of n
GetNibble:

    DEC     R23 ; ensure not going past total nibbles
    BREQ    ExitDisplayHex

	LDI 	R21, UPPER_NIBBLE
	AND		R21, R17	
	SWAP	R21; digit now in r21
; check if the first digit bit is set
	CPI 	R19, 1
	BREQ	ProceedStore	; if its set display as normal
	; if it is not set, check if 0
	CPI		R21, 0
	BRNE    FoundFirstDigit; if 0, then dont store 0, else, set r19
    ST     -Y, R19   ;   do not display this  DIGIT
	JMP		GetNextNibble
FoundFirstDigit:
	LDI 	R19, 1
ProceedStore:	
	LDI     ZL, LOW(2 * DigitSegTable)   ;get the start of the table
    LDI     ZH, HIGH(2 * DigitSegTable)
    EOR     R0, R0                      ;zero R0 for carry propagation
    ADD     ZL, R21                     ;add in the table offset
    ADC     ZH, R0
    LPM     R21, Z                       ;and get the segments into R21
StoreNibble:
	CLI
	ST -Y, R21
GetNextNibble:
	INC R22
	CPI R22, NIBBLES_PER_BYTE	; if stored 2 nibbles then move to next byte
	BREQ NextByte
	CPI R22, NIBBLES_PER_WORD  ; check if finished with n
	BREQ ExitDisplayHex 
	SWAP R17
	JMP  GetNibble
NextByte:
	MOV R17, R16
	JMP GetNibble
ExitDisplayHex:
 	SEI
    POP ZH  ; restore registers
    POP ZL
    POP R22
    POP R21
    POP R20
    POP R0
    POP R19
	RET
	


;    
;
;
;
;Procedure: DisplayGameLED(l, s)
;Description:    This Procedure changes the lth LED to the state s(0 is off, 1 is on).
;Operational Description:  Updates the appropriate bit in the shared LEDs variable to (s), which will
;                            then update the appropriate LED in an upcoming interrupt.
;Arguments:      l - 8-bit LED number to change(1-72)(R16), 71 is the Mode Switch, 72 is the Start Switch
;                s - 8-bit LED state(on is anything other than 0, off = 0)(R17)
;Return Values:  None
;Shared Variables: displayBuffer - contains the state to write to each group of LEDs, set to all 0's
					; Buffer Structure: (bottom to top)
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
						;Digit2 		Select Lines: A=0,D=32
						;Digit3			(leftmost digit) 	Select Lines: A=0,D=64
;Local Variables:  - L(R16) - the led to change 
;					- LEDgroup(R20) - the group that the led is stored in
;Input:          None
;Output:        None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. Only changing one byte of shared variable
;Constants: LEDS_PER_GROUP - number of leds in a group
;			- LIM_LEDS - the upper limit of the input L
;Registers Changed:
;	- R16 - LED bit L
;	- R20 - LED group
; 	- R21 - Zero Register
;	-  Y  - buffer pointer
;
;    

DisplayGameLED:
	; only allow L < LIM_LEDS
	CPI R16, LIM_LEDS
	BRGE ExitDisplayGameLED
	DEC R16	; need 0 index
	; leds are grouped into 8 bit sections => need L = L % 8, Group = L / 8
	LDI R20, 0
GetGroup:
	CPI R16, LEDS_PER_GROUP
	BRLO GotGroup
	SUBI R16, LEDS_PER_GROUP
	INC R20
	JMP GETGROUP
GotGroup:	; the led in the group is now in r16, and the group number is in r20
	; deal with swapped last two ledBars (8th and 9th)
	CPI R20, 7
	BRGE Group7
	JMP StoreLED
Group7:
	BRNE Group8
	INC R20
	JMP StoreLED
Group8:
	DEC R20
StoreLED:
	; get buffer pointer
	LDI R21, 0
	LDI YL, LOW(displayBuffer)
	LDI YH, HIGH(displayBuffer)
	ADD YL, R20	;Y now points to group
	ADC YH, R21
	LD R20, Y
	; want to set bit L(R16)th bit of R20
	; get bit
	LDI ZL, LOW(2 * LEDBitDecodingTable)
	LDI ZH, HIGH(2 * LEDBitDecodingTable)
	ADD ZL, R16
	ADC ZH, R21
	LPM R16, Z	;now have appropriate led bit
	; need to set based on state
	CPI R17, 0	;0xFF => LED should be on
	BRNE StateOn
	COM R16
	AND R16, R20
	ST Y, R16
	JMP ExitDisplayGameLED
StateOn:
	OR R16, R20
	ST Y, R16
ExitDisplayGameLED:
	RET

;___________________________________________________________________________________

; misc passed in r16

DisplayMisc:
    ; save REGISTERS
    PUSH    R21
    PUSH    R20
    PUSH    YL
    PUSH    YH

    CLR R21
    LDI R20,    MISC_GROUP_OFFSET
    LDI YL, LOW(displayBuffer)
	LDI YH, HIGH(displayBuffer)
	ADD YL, R20	;Y now points to misc group
	ADC YH, R21
    ST  Y,  R16

    ;restore registers
    POP YH
    POP YL
    POP R20
    POP R21
    RET

;__________________________________________________________________________________

;R16 - the character's segments
;R17 - the digit to display it on [3,2,1,0]
DisplayChar:
    PUSH R20
    PUSH    YL
    PUSH    YH
    LDI YL, LOW(displayBuffer)
	LDI YH, HIGH(displayBuffer)
	ADIW Y, DIGITS_OFFSET
    ADD YL, R17     ; get appropriate digit(sb)
    BRCS    ExitDisplayChar

    CLR R20
    DEC YH     ; account for actual subtraction above
ExitDisplayChar:
    ST  Y, R16
    POP YH
    POP YL
    POP R20
    RET

;__________________________________________________________________________________

;assumes that buffer is already loaded
; delay passed into R16
; rounds passed into R17

BlinkDisplay:
    PUSH    R19
    MOV     R20,    R16
BlinkOff:
    CLR R19
    CLI
    OUT PORTC,  R19 ; turn off the display
    CALL    Delay16 ; and wait

    MOV     R16,    R20
    SEI             ; display turns on with interrupts
    CALL    Delay16 ; wait
    MOV     R16,    R20

    CPI R17,    0   ; check if done
    BREQ    ExitBlinkDisplay
    DEC R17
    JMP BlinkOff

ExitBlinkDisplay:
    POP R19
    RET
	
	
