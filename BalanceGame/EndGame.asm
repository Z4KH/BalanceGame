;   'EndGame.asm'
;   This file handles everything at the end of the game(winning or losing)

; Procedures Included:
;   GameLose()
;   GameWin()
;   ComputeHS

; Registers Changed:

; Revision History:
;   6/11/2024   Zachary Pestrikov   Drafted File


;______________________________________________________________________________
;
;Procedure: GameLose()
;Description: This Procedure is called when the user loses, and it ends the game. 
;Operational Description: This procedure plays the LOSESOUND, and displays       
;                            'LOSE' on the display.
;Arguments:      None
;Return Values:  None
;Shared Variables: 
;                    SoundToPlay - the tune for the speaker to play - set to the
;                        losing sound
;                    TimeLeft - the time the user has left in the game - set to 0
;                        to end the game
;                    
;Local Variables: None
;Input:          None 
;Output:         Speaker, 7-seg Display, game LEDs
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None
;Constants:      LOSESOUND - the sound to play when the user loses   
;                NO_SOUND - tells the speaker to play no sound
;                BLINK_TIME - the amount of time to blink the display
;Registers Changed: R16, R17
;        
;
;GameLose():
;    ClearDisplay()
;    SoundToPlay = LOSESOUND
;    BlinkDisplay('LOSE', BLINKTIME)
;    TimeLeft = 0;
;    SoundToPlay = NO_SOUND
;    return


.cseg

GameLose:
    CALL    ClearDisplay
;TODO sound stuff
    
    LDI R17,    LOSE_HIGH
    LDI R16,    LOSE_LOW
    CALL    DisplayHex

    LDI R16,    CHAR_L
    LDI R17,    DIGIT3
    CALL    DisplayChar

    LDI R16,    CHAR_E
    LDI R17,    DIGIT0
    CALL    DisplayChar

    LDI R16,    END_BLINK_DELAY
    LDI R17,    END_BLINK_RDS
    CALL    BlinkDisplay

;TODO SoundStuff
    RET
;    
;______________________________________________________________________________
;    

;Procedure: GameWin()
;Description: This Procedure is called when the user wins. 
;Operational Description: This procedure displays the score and ends the game.
;                            It also plays any sounds and determines whether
;                                        a new high score has been achieved.
;Arguments:      None
;Return Values:  None
;Shared Variables: highscore - the user's high score
;                    SoundToPlay - the tune for the speaker to play
;                    timeLeft - the time the user has left - set to 0 to end the 
;                        game
;Local Variables: score - the user's score weighed by the settings
;Input:          None 
;Output:         7-seg display, game LED bar, speaker
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None
;Constants:      HIGHSCORE_SOUND - the tune to play when the user achieves
;                    a high score
;                VICTORY_SOUND - the tune to play when the user wins
;                BLINKTIME - the amount of time to blink the display for
;                NO_SOUND - signals to the speaker not to play anything
;    
;GameWin():
;    ClearDisplay()
;    score = ComputeScore()
;    if (score > settings[highscore]):
;        settings = score
;        SoundToPlay = HIGHSCORE_SOUND
;    else:
;        SoundToPlay = VICTORY_SOUND
;    BlinkDisplay(score, BLINKTIME)
;    SoundToPlay = NO_SOUND
;    timeLeft = 0
;    return

GameWin:
; if new high score, then blink, else just display
    CALL    ComputeScore
    LDS     R17,    HighScore
    CP      R16,    R17
    BRGE    NewHighScore
    CALL    ClearDisplay
    CLR     R17
    CALL    DisplayHex

    LDI     R16,    WIN_SIGNIFIER
    CALL    DisplayMISC

    
    LDI     R16,    DELAY_WIN
    CALL    Delay16
    LDI     R16,    DELAY_WIN
    CALL    Delay16
    LDI     R16,    DELAY_WIN
    CALL    Delay16
    LDI     R16,    DELAY_WIN
    CALL    Delay16

    JMP     ExitGameWin

NewHighScore:
    STS     HighScore,  R16
    LDI     R17,    HIGHSCORE_SETTING
    CALL    DisplayHex
    CLI

    LDI     R16,    WIN_SIGNIFIER
    CALL    DisplayMISC

    LDI     R16,    CHAR_H
    LDI     R17,    DIGIT3
    CALL    DisplayChar
    SEI

    LDI     R16,    COLON
    CALL    DisplayMisc

    LDI R16,    END_BLINK_DELAY
    LDI R17,    END_BLINK_RDS
    CALL    BlinkDisplay

ExitGameWin:
    RET
    

; returns in r16
; Max points = 255
; Min points = 0(Lose Game)
; Score = T + G - S + 
;   DIS_FACTOR(DIS_RANGE_H - DIS)
ComputeScore:
    LDS     R24,    TimeLeftSeconds
    LDS     R23,    Gravity
    LDS     R22,    Size
    LDS     R21,    DisappearanceRate
    LDS     R20,    RandomMode

;TODO - Random Mode

    ADD     R24,    R23
    SUB     R24,    R22
    CPI     R21,    FALSE
    BRNE    ComputeDisappearanceFactor

    ; dont let it wrap
    CPI     R24,    99  ; maximum score with j G & S
    BRLT    ExitComputeScore
    LDI     R24,    1   ; min score for winning
    JMP     ExitComputeScore


ComputeDisappearanceFactor:
    LDI     R23,    DISAPPEARANCE_RANGE_HIGH
    INC     R23     ; max score FF
    SUB     R23,    R21

    LDI     R21,    DIS_FACTOR
    MUL     R21,    R23 ; result in r0
    ADD     R24,    R0
    
ExitComputeScore:
    MOV     R16,    R24
    RET
         
