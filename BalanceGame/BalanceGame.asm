; 'BalanceGame.asm'
; This file initializes all devices and runs the balance game.

; Procedures Included:
;   Start()
;   InitSettings()

; Registers Changed: 
;   R16

; Revision History
;   06/09/2024  Zachary Pestrikov   Wrote Initial Draft of File

;_______________________________________________________________________________

; include device definitions
.include "m64def.inc"

; include files
.include    "ButtonConsts.inc"
.include    "displayDef.inc"
.include    "SettingsConsts.inc"
.include    "SoundIMUconsts.inc"
.include    "timerDef.inc"
.include    "DelayConsts.inc"


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
        JMP     Timer0EventHandler        ;timer 0 overflow
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

;________________________________________________________________________________

;Procedure: Start()
;Description: This Procedure initializes the buttons, display, timers, sound,
;                and IMU for the balance game.
;Operational Description: This procedure calls all initialization functions for
;                            all inputs, outputs, and timers. It is also the 
;                            origin of the program and runs the main loop.
;Arguments:      None
;Return Values:  None
;Shared Variables: None
;Local Variables: None
;Input:          None
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      TBD
;Registers Changed: TBD
;
;Init():
;    InitButtons()
;    InitDisplay()
;    InitTimer0()
;    InitSoundIMU()
;    InitSettings()
;    while (true):
;        WaitStart()
;    

Start:
    LDI     R16, LOW(TopOfStack)    ;initialize the stack 
    OUT     SPL, R16
    LDI     R16, HIGH(TopOfStack)
    OUT     SPH, R16

    CALL InitButtons
    CALL InitDisplay
    CALL InitTimer0     ; initialize interrupts
    CALL InitSoundIMU
    CALL InitSettings
BalanceGame:
    CALL    WaitStart
    RJMP BalanceGame

;_______________________________________________________________________________

;Procedure: InitSettings()
;Description: This Procedure initializes the balance game settings, which include
;                the gravity, size, and disappearanceRate. It also initializes
;                randomMode to false and the game high score to zero.
;Operational Description: This procedure stores all the settings, highscore,
;                            and randomMode in shared variables. 
;Arguments:      None
;Return Values:  None
;Shared Variables: gravity - the gravity experienced by the ball - initialized
;                    size - the size of the ball - initialized
;                    disapearanceRate - the rate at which the ball disappears
;                        from the screen, 0 => no disappearing - initialized to 0
;                    highscore - the high score of the user based on the settings
;                        - initialized to 0
;                    randomMode - a special mode where all the settings are 
;                        chosen at random - initialized to off
;                    music - whether the user wants music to play during the game
;                    disapearanceTime - a random amount of time for the ball
;                            to disappear for
;Local Variables: None
;Input:          None
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      GRAVITY_INIT - the default gravity
;                SIZE_INIT   - the default size
;                FALSE - Value that represents false in the program
;                TRUE - Value that represents true in the program
;                MAX_DISAPPEARANCE_TIME - the maximum amount of time the ball can
;                        disappear for
;Registers Changed: R16 - buffer for settings
;                   R17 - upper byte for division 
;


InitSettings:
    LDI R16,    GRAVITY_INIT
    STS Gravity,    R16
    LDI R16,    SIZE_INIT
    STS Size,   R16
    LDI R16,    FALSE   ; default is no disappearance and no randomMode
    STS DisappearanceRate,  R16 
    STS RandomMode, R16
    LDI R16,    TRUE    ; default is music
    STS Music,  R16
    CALL    Random ; returns in R16
    CLR R17
    CLR R21
    LDI R20,    MAX_DISAPPEARANCE_TIME
    CALL    Div16 ; returns Low byte of remainder in r2
    STS DisappearanceTime,  R2
    CLR R20
    STS HighScore,  R20
    RET

;________________________________________________________________________________   

.dseg   ; store all settingss variables

Gravity:    .BYTE   1   ; the strength of gravity acting on the ball
Size:   .BYTE   1   ; the size of the ball in LEDs
DisappearanceRate:  .BYTE   1 ; the number of seconds between each disappearance
HighScore:  .BYTE   1    ; the user's high score based on the settings and time
Music:  .BYTE   1   ; boolean whether or not the user wants music to play
RandomMode: .BYTE   1   ; a mode where all the features are chosen at random
DisappearanceTime:  .BYTE   1 ; number of seconds until the ball reappears

; the stack - 128 bytes
                .BYTE   127
TopOfStack:     .BYTE   1               ;top of the stack

;________________________________________________________________________________

; asm include files
.include "ButtonEventHandler.asm"
.include "Delay.asm"
.include "displayinit.asm"
.include "DisplayMultiplex.asm"
.include "DisplayProcedures.asm"
.include "Div16.asm"
.include "GetAccel.asm"
.include "InitButtons.asm"
.include "InitSoundIMU.asm"
.include "PlayNote.asm"
.include "Recieve.asm"
.include "segtable.asm"
.include "SwitchStatusFuncs.asm"
.include "Timer0EventHandler.asm"
.include "timerinit.asm"
.include "Transmit.asm"
.include "WaitStart.asm"
.include "Random.asm"
.include "PlayGame.asm"
.include "EndGame.asm"
