; 'displayDef.inc'
; This file defines all constants used when managing the displays

; Revision History
;	- 05/18/2024	Zachary Pestrikov	Wrote File


; I/O Port Definitions

.EQU	OUTDATA    = 0b11111111		;data direction 1 is output


; Display Constants
.EQU	NUM_LED_GROUPS	=	14		; total number of mutually exclsive groups of LEDs 
.EQU	LED_GROUPS_PER_PORT	=	7;	9 total game led bars
.EQU	UPPER_NIBBLE	= 0b11110000	; used to get lower nibble
.EQU	NUM_DIGITS	= 4;number of digits on 7 segment display
.EQU	DIGITS_OFFSET = 14	; offset from display buffer to digit 0 + 1
.EQU	NIBBLES_PER_BYTE = 2
.EQU	NIBBLES_PER_WORD = 4
.EQU	LEDS_PER_GROUP = 8	;number of leds in a group of leds(except last group)
.EQU	LIM_LEDS	= 73	; all led numbers must be < this number
.EQU    TRUE    = 0xFF
.EQU    WAIT_START_DELAY    =   5  ; 50ms delay

; Button LED & misc group constants
.EQU    MODE_BUTTON = 71        ; LED # for mode button
.EQU    START_BUTTON    =   72 ; LED # FOR START button
.EQU MISC_GROUP_OFFSET   =   9   ; offset to display buffer for misc 7-seg display group
.EQU    COLON_DECIMAL =   0b10001000       ; turns on colon and decimal
.EQU    COLON   =   0b10000000  ; turns on only the colon

;Special Chars encoded for 7-seg display
.EQU    CHAR_G  =   0b01111101
.EQU    CHAR_H  =   0b11110110
.EQU    CHAR_F  =   0b11110001
.EQU    CHAR_R  =   0b10110000
.EQU    CHAR_T  =   0b11111000

;SegmentDigits [Digit3, Digit2, digit1, digit0] relative to end of buffer
.EQU    DIGIT0  =   -4
.EQU    DIGIT1  =   -3
.EQU    DIGIT2  =   -2 
.EQU    DIGIT3  =   -1

