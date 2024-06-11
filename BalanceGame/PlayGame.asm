; 'PlayGame.asm'
; This file handles all gameplay for the Balance Game

; Procedures Included:
;   PlayGame()
;   GameLoop()

; Registers Changed:

; Revision History
;   6/10/2024   Zachary Pestrikov   Drafted File

;______________________________________________________________________________
;
;Procedure: PlayGame()
;Description: This Procedure is run to begin the game. 
;Operational Description: This procedure plays the music and 
;                sets the ball's location in the middle of the board. It also 
;                clears the display.
;Arguments:      None
;Return Values:  None
;Shared Variables: SoundToPlay - the tune for the speaker to play - set to the
;                        game play music if music is turned on.
;                    disapearanceRate - the rate at which the ball disappears
;                        from the screen, 0 => no disappearing - unchanged
;                    music - whether the user wants music to play during the game
;                    ballLocation - the center of the ball - initialized to the
;                        middle of the board
;                    ballLeft - the leftmost LED of the ball - initialized based
;                        on the size of the ball
;                    ballRight - the rightmost LED of the ball - initialized based
;                        on the size of the ball
;                    winState - the user's progress in winning the game - 
;                        initialized to 0
;                    timeLeft - the time the user has left in the game before
;                        they lose - initialized
;                    disappearance - the time until the next time the ball 
;                        disappears - initialized to the disapearanceRate
;                    size - the size of the ball chosen by the user - unchanged
;Local Variables: None
;Input:          None
;Output:         7-segment display
;                70 unit LED bar
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None
;Constants:      GAMEPLAYSOUND - the sound to play during the game
;                BOARD_MIDDLE - the middle LED on the game board
;                GAMETIME - the maximum time the user has to play the game before
;                    they lose.
;               PLAY_GAME_DELAY - the delay called when the game begins
;Registers Changed: TBD
;    
;PlayGame():
;    Delay(0.5s)
;    if (music):
;        SoundToPlay = GAMEPLAYSOUND
;    else:
;        SoundToPlay = NO_SOUND
;    ballLocation = BOARD_MIDDLE + (settings[size] - 1) / 2
;    ballLeft = ballLocation - (settings[size] - 1) / 2
;    ballRight = ballLocation + (settings[size] - 1) / 2
;    winState = 0
;    ClearDisplay()
;    timeLeft = GAMETIME
;    disappearance = disappearanceRate
;    while (!StartPress() and TimeLeft):
;        GameLoop()
;    if (timeLeft == 0):
;        GameLose()
;    return

PlayGame:
;TODO: MUSIC
    
    ; compute initial ball location
    LDI R19,    BOARD_MIDDLE
    STS BallLocation,   R19

    LDS R16,    Size;    ballLeft = ballLocation - (settings[size] - 1) / 2
    DEC R16
    ASR R16 ; divide by 2, offset now in r16
    MOV R17,    R19
    SUB R17,    R16
    STS BallLeft,   R17

    ADD R19,    R16 ;    ballRight = ballLocation + (settings[size] - 1) / 2
    STS BallRight,  R19

    LDS R19,    DisappearanceRate   ; init first disappearance
    STS Disappearance,  R19

    LDI R16,    PLAY_GAME_DELAY ; delay to display the start 
    CALL    Delay16
    CALL    ClearDisplay

    CLR R16
    LDI R19,    GAMETIME
    STS WinState,   R16 ; initialize winstate

    STS TimeLeftDS, R16 ; initialize time
    STS TimeLeftCS, R16
    STS TimeLeftSeconds,    R19
    STS MoveBall, R16 ; prepare for counter
    STS DeltaRemainder, R16

    CALL    GameLoop
    RET
;        
;______________________________________________________________________________  


;Procedure: GameLoop()
;Description: This Procedure is the main loop for the game. 
;Operational Description: This procedure moves the ball across the board and 
;                            determines whether the user has won or lost.
;Arguments:      None
;Return Values:  None
;Shared Variables: 
;                    disapearanceRate - the rate at which the ball disappears
;                        from the screen, 0 => no disappearing - unchanged
;                    ballLocation - the center of the ball - initialized to the
;                        middle of the board
;                    ballLeft - the leftmost LED of the ball - initialized based
;                        on the size of the ball
;                    ballRight - the rightmost LED of the ball - initialized based
;                        on the size of the ball
;                    winState - the user's progress in winning the game - 
;                        initialized to 0
;                    timeLeftSeconds - the time the user has left in the game 
;                        in seconds
;                    randomMode - the setting to choose whether to play the game
;                        in random mode
;                    disappearance - the time left until the next disappearance
;                    prevBall - the previous location of the ball
;                    
;Local Variables: yAccel - the acceleration in the y direction of the board
;                zAccel - the acceleration in the z direction of the board
;                deltaBall - the change in the ball's position
;Input:          IMU
;Output:         7-segment display
;                70 unit LED bar
;Error Handling: If the ball rolls of the edge of the board or the user flips the 
;                board upside down, then the user loses. 
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Changing the ball's position
;Constants:      MAXZ_ACCEL - the maximum z acceleration that denotes that the 
;                    board has flipped upside down
;                sizeRangeHigh - the maximum size of the ball
;                gravityRangeHigh - the maximum strength of gravity
;                LEDsMIDDLE - the middle led of the game board
;                LEDsLEFT - the leftmost led of the game board
;                LEDsRIGHT - the rightmost led of the game board
;
;GameLoop():
;    yAccel = GetAccelY()
;    zAccel = GetAccelz()
;    if (zAccel < MAXZ_ACCEL):
;        GameLose()
;    else:
;        if (randomMode):
;            settings[size] = Random() % (sizeRangeHigh + 1)
;            settings[gravity] = Random() % (gravityRangeHigh + 1)
;        deltaBall = GetDeltaBall(yAccel)
;        prevBall = [ballLeft..ballRight]
;        ballLocation += deltaBall
;        ballLeft += deltaBall
;        ballRight += deltaBall
;        if (ballLocation > 70 or ballLocation < 0):
;            GameLose()
;        else:
;            DisplayBall(disappearance, prevBall)
;            if (winState == 0):
;                if (ballLeft == LEDsLEFT):
;                    winState++
;                    side = LEDsLEFT
;                    BlinkDisplay('1')
;                elif (ballRight == LEDsRIGHT):
;                    winState++
;                    side = LEDsRight
;                    BlinkDisplay('1')
;            elif (winState == 1):
;                if (ballLeft == side or ballRight == side):
;                    winState++
;                    BlinkDisplay('2')
;            else:
;                if (ballLocation == LEDsMIDDLE):
;                    GameWin()
;    displayHex(TimeLeftSeconds)
;    return
GameLoop:
    
    ;dont move ball every time
    LDS     R22,    MoveBall
    CPI     R22,    TRUE

    BREQ    NeedMoveBall
    JMP CheckRestartGame    

NeedMoveBall:
    LDI     R22,    FALSE
    STS     MoveBall,   R22 ; reset for next time

    ; first turn off the display of the ball
    LDI     R17,    FALSE  
    CLI
    CALL    DisplayBall


    ; get displacement 
    CALL    GetAccelY
    CALL    GetDeltaBall

    ; handle displacement (R19)(flipped sign)
    LDS     R20,    BallLeft
    SUB     R20,    R19
    STS     BallLeft,   R20

    LDS     R20,    BallLocation
    SUB     R20,    R19
    STS     BallLocation,   R20

    ; ensure it is still on the board
    LDI     R21,    BOARD_LEFT
    CP      R20,    R21
    BRGE    BallOnRight
    CALL    GameLose
    JMP     ExitGameLoop
BallOnRight:
    LDI     R21,    BOARD_RIGHT
    INC     R21
    CP      R20,    R21
    BRLT    BallOnBoard
    CALL    GameLose
    JMP     ExitGameLoop

BallOnBoard:
    LDS     R20,    BallRight
    SUB     R20,    R19
    STS     BallRight,  R20

    

    ; display the ball 
; TODO  deal with disappearance
    LDI     R17,    TRUE
    CALL    DisplayBall
    SEI

    ; handle winstate
    LDS     R16,    WinState
    CPI     R16,    0   ; first win state - no edges touched
    BRNE    WinState1

    LDS     R17,    BallRight
    CPI     R17,    BOARD_RIGHT     ; ball right < board right => didn't touch right side
    BRLT    CheckLeftSide
    LDI     R17,    BOARD_LEFT
    STS     Side,   R17
    JMP     IncWinState

CheckLeftSide:
    LDS     R17,    BallLeft
    CPI     R17,    BOARD_LEFT  ; ball left <= board left => touched left side
    BRLO    LeftSideAchieved
    BRNE    CheckRestartGame

LeftSideAchieved:
    LDI     R17,    BOARD_RIGHT
    STS     Side,   R17
    JMP     IncWinState

WinState1:    
    CPI     R16,    2 ; second win state - one edge touched
    BRGE    FinalWinState
    
    PUSH    R16
    LDI     R16,    WS1_SIGNIFIER
    CALL    DisplayMisc
    POP     R16

    LDS     R16,    Side
    CPI     R16,    BOARD_LEFT
    BREQ    NeedLeftSide
    LDS     R17,    BallRight
    CPI      R17,   BOARD_RIGHT ; ball right is past side, inc
    BRGE    IncWinState
    JMP     CheckRestartGame

NeedLeftSide:
    LDS     R17,    BallLeft
    CP      R16,    R17 ; side is past ball left => inc
    BRGE    IncWinState
    JMP     CheckRestartGame

FinalWinState:  ; ball must get back to the center

    PUSH    R16
    LDI     R16,    WS2_SIGNIFIER
    CALL    DisplayMisc
    POP     R16

    LDS     R17,    BallLocation
    CPI     R17,    BOARD_MIDDLE
    BRNE    CheckRestartGame
    CALL    GameWin
    JMP     ExitGameLoop

IncWinState:
    INC     R16
    STS     WinState,   R16

;TODO  handle errors at the end
CheckRestartGame:
    ;display time left & ensure it hasnt run out
    LDS R16,    TimeLeftSeconds
    CPI R16,    0
    BRNE    CheckStartPressedDuringGame
    CALL    GameLose
    JMP     ExitGameLoop
CheckStartPressedDuringGame:
    CLR R17
    CALL    DisplayHex
    CALL    StartPress  ; check if user restarted game
    BREQ    ExitGameLoop
    JMP     GameLoop
ExitGameLoop:
    RET
;                
;______________________________________________________________________________   

;
;Procedure: GetDeltaBall(yAccel)
;Description: This Procedure determines the change in the position of the ball. 
;Operational Description: This procedure looks the yAccel up in a dictionary
;                            that maps yAccels to their corresponding deltas.
;Arguments:      yAccel(R17) - the high byte of the acceleration of the ball 
;                                   in the y direction
;Return Values:  delta(R19) - the change in leds of the position of the ball
;Shared Variables: gravity - the strength of gravity            
;Local Variables: i - used in for loops
;                    sign - the sign of yAccel
;Input:          None 
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None
;Constants:      DELTA_TABLE - the table that maps yAccel to deltas
;                DELTA_TABLE_LENGTH - the length of DELTA_TABLE
;Registers Changed:
;    R16, R17, R19, R20, R21
;
;GetDeltaBall(yAccel):
;    sign = yAccel[15]
;    for (int i = 0; i < DELTA_TABLE_LENGTH; i+=2):
;        if !(DELTA_TABLE[i] > yAccel[14..0]):
;            delta = DELTA_TABLE[i+1] * gravity
;    if (sign == 1):
;        delta *= -1
;    return delta

GetDeltaBall:
        PUSH    R16; SAVE REGISTERS
        PUSH    R20
        PUSH    R21

        LDI     ZL, LOW(2 * DeltaTable)   ;start at the beginning of the
        LDI     ZH, HIGH(2 * DeltaTable)  ;   DisplayGameLED test table
        ; save the sign
        LDI     R16,    SIGN_BIT
        AND     R16,    R17
        PUSH    R16     ; sign saved in R16

CompareDelta:
        LPM     R16,    Z+      ; get the yaccel
        LPM     R19,    Z+      ; get the corresponding delta
        CP      R17,    R16
        BRLT    HaveDelta    ; go until less than the yaccel
        BREQ    HaveDelta
        JMP     CompareDelta

HaveDelta:  ; delta is in LEDs * 10, gravity is in G's * 10 => multiply
                                                ; and divide by 100
        LDS     R16,    Gravity
        MUL     R16,    R19 ; put in R1|R0
        ;r17|r16 / r21|r20
        MOV R21,    R1
        MOV R20,    R0
        CLR R17
        LDI R16,    DELTA_FACTOR
        CALL    Div16    ;r21|r20 / r17|r16 -> r20, r2
        ; result must only be in r20 because |delta|<=7
        LDS R16,    DeltaRemainder ; save remainder

        ; adjust for sign (if negative, must sub remainder)
        POP R17
        CPI R17,    0
        BREQ    AddDeltaRemainder
        SUB R16,    R2
        JMP StoreRemainder  ;   cant be an overflow because subtracting

AddDeltaRemainder:
        ADD R16,    R2
DetermineDeltaOverflow:
        CPI R16,    DELTA_FACTOR
        BRLT    StoreRemainder
        INC R20 ; add another led to delta because of remainder overflow
        SUBI    R16,    DELTA_FACTOR

StoreRemainder:
        STS DeltaRemainder, R16
        MOV R19,    R20
        
        CPI R17,    0
        BREQ    ExitGetDeltaBall   ; if sign positive
        NEG R19 ; if sign negative, must negate delta
ExitGetDeltaBall:
        POP R21
        POP R20
        POP R16
        RET    ; delta returned in r19 
;    
;______________________________________________________________________________ 
;        
;Procedure: DisplayBall(State)
;Description: This Procedure displays the ball on the LED bar. 
;Operational Description: This procedure displays all LEDs from ballLeft to
;                            ballRight. It turns the ball off or on based on
;                           the state argument
;Arguments:      State - whether to turn the ball off or on
;Return Values:  None
;Shared Variables: 
;                    ballLocation - the center of the ball - initialized to the
;                        middle of the board
;                    ballLeft - the leftmost LED of the ball - initialized based
;                        on the size of the ball
;                    ballRight - the rightmost LED of the ball - initialized based
;                        on the size of the ball
;                    disappearance - the time left until the next disappearance
;                    prevBall - the previous location of the ball
;                    disapearanceTime - a random amount of time for the ball
;                            to disappear for
;                    
;Local Variables: i - used in for loops
;Input:          None 
;Output:         7-segment display
;                70 unit LED bar
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None
;Constants:      MAX_DISAPPEARANCE_TIME - the maximum amount of time that the 
;                    ball can disappear for
;        
;DisplayBall(disappearance, state):
;	get the positions
;	turn to state
;    for i in prevBall:
;        DisplayGameLED(i, Off)
;    if (disappearance > 0 && disappearanceTime <= 0) or disappearanceRate == 0:
;        for (int i = ballLeft; i < ballRight + 1; i++):
;            DisplayGameLED(i, On)
;    else if (disappearance <= 0 and disappearanceTime <= 0):
;        disappearance = disappearanceRate
;        disappearanceTime = Random() % MAX_DISAPPEARANCE_TIME
;    return

DisplayBall:
    LDS R20,    BallLeft    ; get the limits
    LDS R21,    BallRight

    CPI R21,    BOARD_RIGHT; must be <= max LED (cant turn on start/mode)
    BRLO    HaveBallLEDs
    LDI R21,    BOARD_RIGHT

HaveBallLEDs:
    INC R21 ; using brge
DisplayBallLED:
    CP R20,    R21         ; exit after displaying last led
    BRGE    ExitDisplayBall

    MOV R16,    R20
    PUSH    R20             ; save registers
    PUSH    R21
    CALL    DisplayGameLED  ; r17 already has state
    POP     R21
    POP     R20
    INC R20                 ; move through LED's
    JMP DisplayBallLED


ExitDisplayBall:
    RET
;        
;______________________________________________________________________________

; table that converts IMU yAccel values in the form Q1.6 into changes in LEDs
; format is Q1.6 => denominator is just 2^6, numerator is lowest 6
; each LED is treated as 20 centimeters(even though it is just 0.2 centimeters)
; table is in LEDs/second

DeltaTable: ; negatives first
     .DB 0b10111111, 38
     .DB 0b11000001, 37     .DB 0b11000010, 36     .DB 0b11000100, 35     .DB 0b11000110, 34     .DB 0b11000111, 33
     .DB 0b11001001, 32     .DB 0b11001010, 31     .DB 0b11001100, 30     .DB 0b11001110, 29     .DB 0b11001111, 28
     .DB 0b11010001, 27     .DB 0b11010011, 26
     .DB 0b11010100, 25     .DB 0b11010110, 24     .DB 0b11011000, 23     .DB 0b11011001, 22     .DB 0b11011011, 21
     .DB 0b11011101, 20     .DB 0b11011110, 19     .DB 0b11100000, 18     .DB 0b11100010, 17     .DB 0b11100011, 16
     .DB 0b11100101, 15     .DB 0b11100111, 14
     .DB 0b11101000, 13     .DB 0b11101010, 12     .DB 0b11101100, 11     .DB 0b11101101, 10     .DB 0b11101111, 9
     .DB 0b11110001, 8     .DB 0b11110010, 7     .DB 0b11110100, 6     .DB 0b11110110, 5     .DB 0b11110111, 4
     .DB 0b11111001, 3     .DB 0b11111011, 2
     .DB 0b11111100, 1     .DB 0b11111110, 0

        ; then positives
     .DB 0b00000001, 0     .DB 0b00000010, 1     .DB 0b00000100, 2
     .DB 0b00000101, 3     .DB 0b00000111, 4     .DB 0b00001001, 5     .DB 0b00001010, 6     .DB 0b00001100, 7
     .DB 0b00001110, 8     .DB 0b00001111, 9     .DB 0b00010001, 10     .DB 0b00010011, 11     .DB 0b00010100, 12
     .DB 0b00010110, 13     .DB 0b00011000, 14
     .DB 0b00011001, 15     .DB 0b00011011, 16     .DB 0b00011101, 17     .DB 0b00011110, 18     .DB 0b00100000, 19
     .DB 0b00100010, 20     .DB 0b00100011, 21     .DB 0b00100101, 22     .DB 0b00100111, 23     .DB 0b00101000, 24
     .DB 0b00101010, 25     .DB 0b00101100, 26
     .DB 0b00101101, 27     .DB 0b00101111, 28     .DB 0b00110001, 29     .DB 0b00110010, 30     .DB 0b00110100, 31
     .DB 0b00110110, 32     .DB 0b00110111, 33     .DB 0b00111001, 34     .DB 0b00111010, 35     .DB 0b00111100, 36
     .DB 0b00111110, 37     .DB 0b00111111, 38      .DB 0b01111111, 39


;______________________________________________________________________________

.dseg

BallLocation:   .BYTE   1   ;the location of the center of the ball
BallLeft:       .BYTE   1   ; the location of the leftmost led of the ball
BallRight:      .BYTE   1   ; the location of the rightmost led of the ball

WinState:       .BYTE   1   ; the user's progress towards winning, 4 states

Disappearance:  .BYTE   1   ; the time until the next disappearance

DeltaRemainder: .BYTE   1   ; remainder after division

MoveBall: .BYTE   1; boolean whether to move the ball based on clock

Side:       .BYTE   1;  the next side of the board needed to win
