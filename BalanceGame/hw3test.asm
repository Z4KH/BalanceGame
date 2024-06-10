;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   HW3TEST                                  ;
;                            Homework #3 Test Code                           ;
;                                  EE/CS 10b                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the test code for Homework #3.  The function makes a
; number of calls to the display functions to test them.  The functions
; included are:
;    DisplayTest - test the homework display functions
;
; Revision History:
;    4/29/19  Glen George               initial revision
;    5/18/23  Glen George               updated for Hexer game
;    5/18/24  Glen George               updated for Balance game
;	 5/18/24  Zachary Pestrikov			Added Stack, start, and vector table




;get the definitions for the device
.include  "m64def.inc"




.cseg

;setup the vector area

.org    $0000

        JMP     Start                   ;reset vector
        JMP     PC                     ;external interrupt 0
        JMP     PC                      ;external interrupt 1
        JMP     PC                      ;external interrupt 2
        JMP     PC                      ;external interrupt 3
        JMP     PC                      ;external interrupt 4
        JMP     PC                      ;external interrupt 5
        JMP     PC                      ;external interrupt 6
        JMP     PC                      ;external interrupt 7
        JMP     PC                      ;timer 2 compare match
        JMP     PC                      ;timer 2 overflow
        JMP     PC                      ;timer 1 capture
        JMP     PC                      ;timer 1 compare match A
        JMP     PC                      ;timer 1 compare match B
        JMP     PC                      ;timer 1 overflow
        JMP     PC                     ;timer 0 compare match
        JMP     MultiplexDisplay        ;timer 0 overflow
        JMP     PC                      ;SPI transfer complete
        JMP     PC                      ;UART 0 Rx complete
        JMP     PC                      ;UART 0 Tx empty
        JMP     PC                      ;UART 0 Tx complete
        JMP     PC                      ;ADC conversion complete
        JMP     PC                      ;EEPROM ready
        JMP     PC                      ;analog comparator
        JMP     PC                      ;timer 1 compare match C
        JMP     PC                      ;timer 3 capture
        JMP     PC                      ;timer 3 compare match A
        JMP     PC                      ;timer 3 compare match B
        JMP     PC                      ;timer 3 compare match C
        JMP     PC                      ;timer 3 overflow
        JMP     PC                      ;UART 1 Rx complete
        JMP     PC                      ;UART 1 Tx empty
        JMP     PC                      ;UART 1 Tx complete
        JMP     PC                      ;Two-wire serial interface
        JMP     PC                      ;store program memory ready




; start of the actual program

Start:                                  ;start the CPU after a reset
        LDI     R16, LOW(TopOfStack)    ;initialize the stack pointer
        OUT     SPL, R16
        LDI     R16, HIGH(TopOfStack)
        OUT     SPH, R16


        CALL    InitTimer0              ; initialize the switches and variables
		CALL	InitDisplay


        RCALL   DisplayTest              ;do the display tests
        RJMP    Start                   ;shouldn't return, but if it does, restart




; DisplayTest
;
; Description:       This procedure tests the display functions.  It first
;                    turns on some LEDs and segments and then clears the
;                    display by calling ClearDisplay.  Next it loops
;                    displaying patterns on the game LEDs using the
;                    DisplayGameLED function.  Following this it loops sending
;                    values to the DisplayHex function.  To validate the code
;                    the display must be checked for the appropriate patterns
;                    being displayed.  The function never returns, when the
;                    aforementioned patterns have finished, it repeats them.
;
; Operation:         The arguments to call each function with are stored in
;                    tables.  The function loops through the tables making the
;                    appropriate display code calls.  Delays are done after
;                    most calls so the display can be examined.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   R20         - test counter.
;                    Z (ZH | ZL) - test table pointer.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R16, R17, R18, R19, R20, R21, Y (YH | YL),
;                    Z (ZH | ZL)
; Stack Depth:       unknown (at least 4 bytes)
;
; Author:            Glen George
; Last Modified:     May 18, 2024

DisplayTest:

	LDI	R16, 1			;first turn on some LEDs
	LDI	R17, 0xFF
	RCALL	DisplayGameLED
	LDI	R16, 2
	LDI	R17, 0xFF
	RCALL	DisplayGameLED
	LDI	R16, 35
	LDI	R17, 0xFF
	RCALL	DisplayGameLED
	LDI	R16, 69
	LDI	R17, 0xFF
	RCALL	DisplayGameLED
	LDI	R16, 70
	LDI	R17, 0xFF
	RCALL	DisplayGameLED
	LDI	R16, 0x88		;now turn on all segments
	LDI	R17, 0x88
	RCALL	DisplayHex
         LDI     R16, 100                ;and delay a bit
        RCALL   Delay16
        RCALL   ClearDisplay            ;now clear the display
        LDI     R16, 100                ;and delay a bit
        RCALL   Delay16


TestGameLEDs:                           ;do the DisplayGameLED tests
        LDI     ZL, LOW(2 * TestGTab)   ;start at the beginning of the
        LDI     ZH, HIGH(2 * TestGTab)  ;   DisplayGameLED test table

TestGameLEDsLoop:

        LPM     R16, Z+                 ;get the DisplayGameLEDs arguments
        LPM     R17, Z+                 ;   from the table

        PUSH    ZL                      ;save registers around function call
        PUSH    ZH
        RCALL   DisplayGameLED          ;call the function
        POP     ZH                      ;restore the registers
        POP     ZL

        LDI     R16, 20                 ;delay 200 ms between calls
        RCALL   Delay16                 ;and do the delay

        LDI     R20, HIGH(2 * EndTestGTab)      ;setup for end check
        CPI     ZL, LOW(2 * EndTestGTab)        ;check if at end of table
        CPC     ZH, R20
        BRNE    TestGameLEDsLoop        ;and keep looping if not done
        ;BREQ   TestDisplayHex          ;otherwise test DisplayHex function


TestDisplayHex:                         ;do the DisplayHex tests
        LDI     ZL, LOW(2 * TestHexTab) ;start at the beginning of the
        LDI     ZH, HIGH(2 * TestHexTab);   DisplayHex test table

TestDisplayHexLoop:

        LPM     R16, Z+                 ;get DisplayHex argument from the table
        LPM     R17, Z+

        PUSH    ZL                      ;save registers around DisplayHex call
        PUSH    ZH
        RCALL   DisplayHex              ;call the function
        POP     ZH
        POP     ZL

        LPM     R16, Z                  ;get the time delay from the table
        RCALL   Delay16                 ;and do the delay
        LPM     R16, Z+                 ;do twice the delay
        RCALL   Delay16

        ADIW    Z, 1                    ;skip the padding byte

        LDI     R20, HIGH(2 * EndTestHexTab)    ;setup for end check
        CPI     ZL, LOW(2 * EndTestHexTab)      ;check if at end of table
        CPC     ZH, R20
        BRNE    TestDisplayHexLoop      ;and keep looping if not done
        ;BREQ   DoneDisplayTests        ;otherwise done with display tests


DoneDisplayTests:                       ;have done all the tests
        RJMP    DisplayTest             ;start over and loop forever


        RET                             ;should never get here




; Delay16
;
; Description:       This procedure delays the number of clocks passed in R16
;                    times 80000.  Thus with a 8 MHz clock the passed delay is
;                    in 10 millisecond units.
;
; Operation:         The function just loops decrementing Y until it is 0.
;
; Arguments:         R16 - 1/80000 the number of CPU clocks to delay.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R16, Y (YH | YL)
; Stack Depth:       0 bytes
;
; Author:            Glen George
; Last Modified:     May 6, 2018

Delay16:

Delay16Loop:                            ;outer loop runs R16 times
        LDI     YL, LOW(20000)          ;inner loop is 4 clocks
        LDI     YH, HIGH(20000)         ;so loop 20000 times to get 80000 clocks
Delay16InnerLoop:                       ;do the delay
        SBIW    Y, 1
        BRNE    Delay16InnerLoop

        DEC     R16                     ;count outer loop iterations
        BRNE    Delay16Loop


DoneDelay16:                            ;done with the delay loop - return
        RET




; Test Tables


; TestGTab
;
; Description:      This table contains the values of the arguments for
;                   testing the DisplayGameLED function.  Each entry consists
;                   of the LED number to change and the new value for the LED
;                   (TRUE/FALSE) pattern displayed.
;
; Author:           Glen George
; Last Modified:    May 8, 2024

TestGTab:
               ;Arguments (LED number and LED on/off)
	.DB	 1, 0xFF,  2, 0x80,  3, 0x01,  4, 0xFF	;turn on LEDs
	.DB	 5, 0xFF,  6, 0x08,  7, 0x10,  8, 0xFF	;   in sequence
	.DB	 9, 0xFF, 10, 0x08, 11, 0x10, 12, 0xFF
	.DB	13, 0xFF, 14, 0xFF, 15, 0xFF, 16, 0xFF
	.DB	17, 0xFF, 18, 0xFF, 19, 0xFF, 20, 0xFF
	.DB	21, 0xFF, 22, 0xFF, 23, 0xFF, 24, 0xFF
	.DB	25, 0xFF, 26, 0xFF, 27, 0xFF, 28, 0xFF
	.DB	29, 0xFF, 30, 0xFF, 31, 0xFF, 32, 0xFF
	.DB	33, 0xFF, 34, 0xFF, 35, 0xFF, 36, 0xFF
	.DB	37, 0xFF, 38, 0xFF, 39, 0xFF, 40, 0xFF
	.DB	41, 0x01, 42, 0x01, 43, 0x01, 44, 0x01
	.DB	45, 0x01, 46, 0x01, 47, 0x01, 48, 0x01
	.DB	49, 0x01, 50, 0x01, 51, 0x01, 52, 0x01
	.DB	53, 0x01, 54, 0x01, 55, 0x01, 56, 0x01
	.DB	57, 0x01, 58, 0x01, 59, 0x01, 60, 0x01
	.DB	61, 0x01, 62, 0x01, 63, 0x01, 64, 0x01
	.DB	65, 0x01, 66, 0x01, 67, 0x01, 68, 0x01
	.DB	69, 0x01, 70, 0x01

	.DB     35, 0x00, 34, 0x00, 36, 0x00, 33, 0x00	;turn off LEDs
	.DB	37, 0x00, 32, 0x00, 38, 0x00, 31, 0x00	;   from center
	.DB	39, 0x00, 30, 0x00, 40, 0x00, 29, 0x00
	.DB	41, 0x00, 28, 0x00, 42, 0x00, 27, 0x00
	.DB	43, 0x00, 26, 0x00, 44, 0x00, 25, 0x00
	.DB	45, 0x00, 24, 0x00, 46, 0x00, 23, 0x00
	.DB	47, 0x00, 22, 0x00, 48, 0x00, 21, 0x00
	.DB	49, 0x00, 20, 0x00, 50, 0x00, 19, 0x00
	.DB	51, 0x00, 18, 0x00, 52, 0x00, 17, 0x00
	.DB	53, 0x00, 16, 0x00, 54, 0x00, 15, 0x00
	.DB	55, 0x00, 14, 0x00, 56, 0x00, 13, 0x00
	.DB	57, 0x00, 12, 0x00, 58, 0x00, 11, 0x00
	.DB	59, 0x00, 10, 0x00, 60, 0x00,  9, 0x00
	.DB	61, 0x00,  8, 0x00, 62, 0x00,  7, 0x00
	.DB	63, 0x00,  6, 0x00, 64, 0x00,  5, 0x00
	.DB	65, 0x00,  4, 0x00, 66, 0x00,  3, 0x00
	.DB	67, 0x00,  2, 0x00, 68, 0x00,  1, 0x00
	.DB	69, 0x00, 70, 0x00

	.DB	82, 0xFF, 93, 0xFF, 200, 0xFF		;some bad arguments

	.DB      1, 0xFF,  9, 0xFF,  1, 0x00, 17, 0xFF	;move a single LED
	.DB	 9, 0x00, 25, 0xFF, 17, 0x00, 33, 0xFF	;   around
	.DB	25, 0x00, 41, 0xFF, 33, 0x00, 49, 0xFF
	.DB	41, 0x00, 57, 0xFF, 49, 0x00, 65, 0xFF
	.DB	57, 0x00, 70, 0xFF, 65, 0x00, 64, 0xFF
	.DB	70, 0x00, 56, 0xFF, 64, 0x00, 48, 0xFF
	.DB	56, 0x00, 40, 0xFF, 48, 0x00, 32, 0xFF
	.DB	40, 0x00, 24, 0xFF, 32, 0x00, 16, 0xFF
	.DB	24, 0x00,  8, 0xFF, 16, 0x00,  8, 0x00

EndTestGTab:




; TestHexTab
;
; Description:      This table contains the argument values for testing the
;                   DisplayHex function.  Each entry consists of the value to
;                   display, and the time delay to leave the pattern
;                   displayed.  Since this accessed as a 8-bit value, the high
;                   byte of the delay must be skipped in the code.
;
; Author:           Glen George
; Last Modified:    April 29, 2019

TestHexTab:
               ;Argument    Delay (10 ms)
        .DW     0x8888,     150                 ;all segments on
        .DW     0x0000,     150
        .DW     0x1234,     150
        .DW     0x5678,     150
        .DW     0x9ABC,     150
        .DW     0xDEF0,     150
        .DW     0xFFFF,     150
        .DW     0x7734,     150
        .DW     0xDEAD,     150
        .DW     0xBEEF,     150

EndTestHexTab:


.dseg

; the stack - 128 bytes
                .BYTE   127
TopOfStack:     .BYTE   1               ;top of the stack



; local include files
.include "segtable.asm"
.include "displayDef.inc"
.include "displayinit.asm"
.include "displayMultiplex.asm"
.include "DisplayProcedures.asm"
.include "timerDef.inc"
.include "timerinit.asm"
