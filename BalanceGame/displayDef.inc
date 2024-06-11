; 'displayDef.inc'
; This file defines all constants used when managing the displays

; Revision History
;	- 05/18/2024	Zachary Pestrikov	Wrote File
;   - 06/9/2024     Zachary Pestrikov   added button LED & misc group
;   - 06/10/2024    Zachary Pestrikov   Added led bar consts


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

; Button LED & misc group constants
.EQU    MODE_BUTTON = 71        ; LED # for mode button
.EQU    START_BUTTON    =   72 ; LED # FOR START button
.EQU MISC_GROUP_OFFSET   =   9   ; offset to display buffer for misc 7-seg display group
.EQU    COLON_DECIMAL =   0b10001000       ; turns on colon and decimal
.EQU    COLON   =   0b10000000  ; turns on only the colon
.EQU    WS1_SIGNIFIER   =   0b00000001
.EQU    WS2_SIGNIFIER   =   0b00000101
.EQU    WIN_SIGNIFIER   =   0b00000111

;Special Chars encoded for 7-seg display
.EQU    CHAR_G  =   0b01111101
.EQU    CHAR_H  =   0b11110110
.EQU    CHAR_F  =   0b11110001
.EQU    CHAR_R  =   0b10110000
.EQU    CHAR_T  =   0b11111000
.EQU    CHAR_L  =   0b01111000
.EQU    CHAR_E  =   0b11111001


;SegmentDigits [Digit3, Digit2, digit1, digit0] relative to end of buffer
.EQU    DIGIT0  =   -4
.EQU    DIGIT1  =   -3
.EQU    DIGIT2  =   -2 
.EQU    DIGIT3  =   -1

;   LED bar constants for game
.EQU    BOARD_MIDDLE    =   36  ; middle led is the 36th one
.EQU    BOARD_LEFT      =   1   ; leftmost led
.EQU    BOARD_RIGHT     =   70  ; rightmost led

; Related Consts
.EQU    DELTA_FACTOR    =   100 ; convert gravity * delta -> number of leds
.EQU    SIGN_BIT        =   0b10000000

; EndGame Displays
.EQU    LOSE_HIGH       =   0x10 
.EQU    LOSE_LOW        =   0x50
.EQU    END_BLINK_DELAY =   50  ;   500ms blinking
.EQU    END_BLINK_RDS   =   5   ;   blink for 5 seconds
