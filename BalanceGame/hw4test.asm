    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   HW4TEST                                  ;
;                            Homework #4 Test Code                           ;
;                                  EE/CS 10b                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the test code for Homework #4.  The function makes a
; number of calls to the PlayNote and GetAccel* functions to test them.
; The public functions included are:
;    IMUSoundTest - test the homework sound and IMU functions
;
; The local functions included are:
;    Delay16      - delay loop (assumes no interrupts which is invalid)
;    DisplayAccel - display the acceleromter output
;
; Revision History:
;    5/31/24  Glen George               initial revision
;    6/2/2024 Zachary Pestrikov         Added start of tests, includes




; chip definitions
.include  "m64def.inc"

; local include files
.include    "SoundIMUconsts.inc"
.include    "timerDef.inc"
.include    "displayDef.inc"


; local definitions
	.EQU	ACCEL_BITS = 9		;9 bits of accuracy for values
	.EQU	ACCELX_POS = 10		;X-axis accelerometer centered at LED 10
	.EQU	ACCELY_POS = 30		;X-axis accelerometer centered at LED 30
	.EQU	ACCELZ_POS = 50		;X-axis accelerometer centered at LED 50




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


        CALL    InitTimer0              ; initialize display multiplexing
        CALL	InitDisplay             
        CALL    InitSoundIMU



        RCALL   IMUTests              ;do the sound tests
        RJMP    Start                   ;shouldn't return, but if it does, restart






; IMUSoundTest
;
; Description:       This procedure tests the sound and IMU functions.  It
;                    first loops calling the PlayNote function.  Following
;                    this it loops making calls to GetAccelX, GetAccelY, and
;                    GetAccelZ.  The results from these calls are displayed
;                    on the game play LEDs.  The function never returns.
;
; Operation:         The arguments to call each function with are stored in
;                    tables.  The function loops through the tables making the
;                    appropriate function calls.  Delays are done after calls
;                    to PlayNote so the sound can be heard.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   R20         - test counter.
;                    Z (ZH | ZL) - test table pointer.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             The IMU is read via GetAccelX, GetAccelY, and GetAccelZ.
; Output:            Sound is output via PlayNote and the LEDs are output with
;                    the accelerometer data via DisplayGameLED.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R16, R17, R18, R19, R20, X (XH | XL), Y (YH | YL),
;                    Z (ZH | ZL) (at least)
; Stack Depth:       unknown (at least 5 bytes)
;
; Author:            Glen George
; Last Modified:     May 31, 2024

IMUSoundTest:


PlayNoteTests:                          ;do some tests of PlayNote only
        LDI     ZL, LOW(2 * TestPNTab)  ;start at the beginning of the
        LDI     ZH, HIGH(2 * TestPNTab) ;   PlayNote test table
        LDI     R20, TestPNTab_TEST_CNT ;get the number of tests

PlayNoteTestLoop:
        LPM     R16, Z+                 ;get the PlayNote argument from the
        LPM     R17, Z+                 ;   table

        PUSH    ZL                      ;save registers around PlayNote call
        PUSH    ZH
        PUSH    R20
        RCALL   PlayNote                ;call the function
        POP     R20                     ;restore the registers
        POP     ZH
        POP     ZL

        LDI     R16, 200                ;delay for 2 seconds
        RCALL   Delay16                 ;and do the delay

        DEC     R20                     ;update loop counter
        BRNE    PlayNoteTestLoop        ;and keep looping if not done
        ;BREQ   IMUTests                ;otherwise test the IMU functions


IMUTests:				;test the IMU functions
	RCALL	ClearDisplay		;first need to clear the display

	RCALL	GetAccelX		;get X-axis accelerometer
	LDI	R18, ACCELX_POS		;get 0-level LED
	RCALL	DisplayAccel		;and display the accelerometer value

	RCALL	GetAccelY		;get Y-axis accelerometer
	LDI	R18, ACCELY_POS		;get 0-level LED
	RCALL	DisplayAccel		;and display the accelerometer value

	RCALL	GetAccelZ		;get Z-axis accelerometer
	LDI	R18, ACCELZ_POS		;get 0-level LED
	RCALL	DisplayAccel		;and display the accelerometer value

        LDI     R16, 50                 ;delay for 50 ms
        RCALL   Delay16
	RJMP	IMUTests		;and keep testing

        RET                             ;should never get here




; DisplayAccel
;
; Description:       This procedure displays the passed 16-bit signed value on
;                    the game play LEDs.  The value is displayed
;                    logarithmically with eight (8) bits of resolution and the
;                    zero level at the passed LED number.
;
; Operation:         The arguments to call each function with are stored in
;                    tables.  The function loops through the tables making the
;                    appropriate function calls.  Delays are done after calls
;                    to PlayNote so the sound can be heard.
;
; Arguments:         R17 | R16 - 16-bit signed value to display.
;                    R18       - LED to use for 0 level of passed value.
; Return Value:      None.
;
; Local Variables:   R20         - test counter.
;                    Z (ZH | ZL) - test table pointer.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            A game play LED is output to indicate the passed value via
;                    the DisplayGameLED function.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R16, R17, R18, R19, R20 (at least)
; Stack Depth:       unknown (at least 2 bytes)
;
; Author:            Glen George
; Last Modified:     May 31, 2024

DisplayAccel:


	MOV	R20, R18		;remember 0-level LED

	OR	R17, R17		;check the sign to get absolute value
	BRPL	AccelPos		;positive value
	;BRMI	AccelNeg		;negative value

AccelNeg:				;negative value
        COM	R17			;negate R17 | R16
	COM	R16
	SUBI	R16, -1
	LDI	R19, 0
	ADC	R17, R19
	LDI	R19, -1			;move LED to right for negative
	SUBI	R18, -ACCEL_BITS	;start at rightmost LED
	RJMP	AccelAmp		;and get amplitude

AccelPos:				;positive value
	LDI	R19, 1			;move LED to left for positive
	SUBI	R18, ACCEL_BITS		;start at leftmost LED
	;RJMP	AccelAmp		;and get amplitude

AccelAmp:				;compute LED for amplitude
        SBRC	R17, 6			;check if high bit (not sign) is clear
	RJMP	HaveAccelLED		;if not, have bit to display
	LSL	R16			;otherwise check next bit
	ROL	R17			;by shifting 16-bit value
	ADD	R18, R19		;move to next LED too
	CP	R20, R18		;see if back to 0-level LED
	BRNE	AccelAmp		;if not 0-level, keep looping
	;RJMP	HaveAccelLED		;otherwise have LED to output (0)

HaveAccelLED:				;turn on the LED for the passed value
	MOV	R16, R18
	LDI	R17, TRUE
	RCALL	DisplayGameLED
	;RJMP	EndDisplayAccel		;and all done


EndDisplayAccel:			;done displaying passed value
	RET




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


; TestPNTab
;
; Description:      This table contains the values of arguments for testing
;                   the PlayNote function.  Each entry is just a 16-bit
;                   frequency for the note to play.
;
; Author:           Glen George
; Last Modified:    May 31, 2024

TestPNTab:

        .DW     261                     ;middle C
        .DW     440                     ;middle A
        .DW     1000
        .DW     0                       ;turn off output for a bit
        .DW     2000
        .DW     50
        .DW     4000
        .DW     100
        .DW     0			;turn off when done

        ;size of the table (number of tests)
        .EQU    TestPNTab_TEST_CNT = PC - TestPNTab

.dseg

; the stack - 128 bytes
                .BYTE   127
TopOfStack:     .BYTE   1               ;top of the stack



; local assembly files
.include    "Div16.asm"
.include    "GetAccel.asm"
.include    "InitSoundIMU.asm"
.include    "PlayNote.asm"
.include    "DisplayProcedures.asm"
.include    "DisplayMultiplex.asm"
.include    "displayinit.asm"
.include    "segtable.asm"
.include    "timerinit.asm"
.include    "Recieve.asm"
.include    "Transmit.asm"
