; 'WaitStart.asm'
; This file handles all activity when the game is stopped

; Procedures Included:
;   WaitStart()

; Registers Changed:
;   R16
;   R19
;   

; Revision History:
;   6/9/2024    Zachary Pestrikov   Drafted File

;________________________________________________________________________________

;    
;Procedure: WaitStart()
;Description: This Procedure is run while the game is not being played. It sweeps
;                up and down the leds while adjusting the settings based on 
;                user input.
;Operational Description: This procedure checks each of the buttonPress functions
;                            to determine what to do, and changes the settings
;                            based on the rotary encoder. It then displays the 
;                            value of the setting. The user can go to the next
;                            setting my clicking the mode button. Rotating the
;                            rotary encoder forward will increase the setting
;                            by a certain step size, and the setting will be 
;                            decreased by rotating the rotary encoder backwards.
;                            Pressing the rotary encoder will return the setting
;                            to its default value. Once the user presses the
;                            start button, the game will begin.
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
;Local Variables: led(R16) - the led to display at a given time
;                   setting - the current setting the user can change
;Input:          Start Button
;                Mode Button
;                Rotary Encoder
;                Rotary Button
;Output:         7-segment display
;                70 unit LED bar
;Error Handling: If the user attempts to surpass the limits of the settings, the
;                setting will hold its limit value.
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Clearing a particular digit
;Constants:      GRAVITY_INIT - the default gravity
;                SIZE_INIT   - the default size
;                FALSE - Value that represents false in the program
;                WaitStartLEDs - table of led pattern to play while waiting for
;                        the start button to be pressed
;                gravityRangeHigh/gravityRangeLow - limits of the gravity setting
;                sizeRangeHigh/sizeRangeLow - limits of the size setting
;                dissapearanceRateRangeHigh/dissapearanceRateRangeLow - limits of
;                    the disapearanceRate setting
;               GRAVITY_SETTING - the hex to display when setting == gravity
;               SIZE_SETTING - the hex to display when setting == SIZE
;               HS_SETTING - the hex to display when setting == HIGHSCORE
;               DISAPPEARANCE_SETTING - displayhex disappearance == setting
;               RANDOM_MODE_SETTING - hex to display, setting == randomMode
;               MUSIC_SETTING_LOW/HIGH - hex to display, setting == music
;               NUM_SETTINGS - the total number of settings the user can choose
;               GRAVITY_STEP_SIZE-size that gravity is changed for each rotation
;               SIZE_STEP_SIZE  - size that size is changed by for each rotation
;               HS_STEP_SIZE    - size that hs is changed by for each rotation
;               MUSIC_STEP_SIZE - size to change music setting by
;               DISAPPEARANCE_STEP  - size to change disappearance rate by
;               TRUE - value that represents true in the program
;               MODE_BUTTON - the led number that references the mode button
;               Indicies of settings:
    ;               GRAVITY_IDX
    ;               SIZE_IDX
    ;               HS_IDX
    ;               DISAPPEARANCE_IDX
    ;               RANDOM_MODE_IDX
    ;               MUSIC_IDX
;Registers Changed: 
;                   R20 - setting step size
;                   R19 - setting
;                   R16 - LED
;    
;    

.cseg
WaitStart:
    CALL ClearDisplay
    LDI     R19,    GRAVITY_IDX ; start with gravity                  
    LDI     ZL, LOW(2 * WaitStartLEDs)   ;start at the beginning of the
    LDI     ZH, HIGH(2 * WaitStartLEDs)  ;   LED sweep table

WaitStartLoop:
    LPM     R16, Z+                 ;get the DisplayGameLEDs arguments
    LPM     R17, Z+                ;   from the table

    PUSH    ZL                      ;save registers around function call
    PUSH    ZH
    PUSH    R19
    CALL   DisplayGameLED          ;turn on led
    POP     R19
    POP     ZH                      ;restore the registers
    POP     ZL

    LDI     R20, HIGH(2 * EndWaitStartLEDs)      ;setup for end check
    CPI     ZL, LOW(2 * EndWaitStartLEDs)        ;check if at end of table
    CPC     ZH, R20
    BRNE    HandleSettings          ; continue if not done
    LDI     ZL, LOW(2 * WaitStartLEDs)   ;go back to beginning of the
    LDI     ZH, HIGH(2 * WaitStartLEDs)  ;   LED sweep table if done
HandleSettings:
    CALL    ModePress                   ; sets zero if mode pressed
    BRNE    GravitySettingSelected  ; mode not pressed => don't change setting
    LDI     R16,    MODE_BUTTON
    LDI     R17,    TRUE

    PUSH    ZL                      ;save registers around function call
    PUSH    ZH
    PUSH    R19
    CALL   DisplayGameLED          ;turn on mode led
    POP     R19
    POP     ZH                      ;restore the registers
    POP     ZL

    CPI     R19, NUM_SETTINGS           ; if mode is pressed ensure that
    BRNE    ChangeSetting               ; wrap if user is 
    CLR     R19                             ;   on final setting
ChangeSetting:
    INC     R19




GravitySettingSelected:
    CPI     R19, GRAVITY_IDX
    BRNE    NotGravitySettingSelected
    


    ;display its value
    PUSH    ZH ;save z
    PUSH    ZL

    LDI     ZL, LOW(2 * HexDecimal)   
    LDI     ZH, HIGH(2 * HexDecimal)
    
    LDI     R20,    GRAVITY_RANGE_LOW
    DEC     R20
GetGfromTable:
    INC     R20 ; move through table
    CP     R20,    R25 ; compare with the value
    BRNE    GetGfromTable   
    ; now the value is correct
    CLR     R21
    DEC     R20 ;use as the offset to Z, 0 indexed
    ADD     ZL, R20
    ADC     ZH, R21   ; add the offset to Z
    LPM     R16, Z+     ; get the value
    LDI     R17,    GRAVITY_SETTING
    CALL    DisplayHex ;display to 7-segment display
    LDI     R16,    COLON_DECIMAL
    CALL    DisplayMisc ;   display the decimal point
    LDI     R16,    CHAR_G  ; 'G' - gravity
    LDI     R17,    DIGIT2
    CALL    DisplayChar
    
    POP     ZL
    POP     ZH ; restore Z
      

    LDS     R25,    Gravity
    LDI     R20,    GRAVITY_STEP_SIZE
    LDI     R21,    GRAVITY_RANGE_LOW
    LDI     R22,    GRAVITY_RANGE_HIGH
    LDI     R23,    GRAVITY_INIT
    CALL    CheckRotations   

    STS     Gravity,    R25 ; in case of change
    JMP     CheckStartPressed


NotGravitySettingSelected:
    CPI     R19, SIZE_IDX
    BRNE    NotSizeSettingSelected ; not size setting so keep going


    LDS     R25,    Size    ; get size
        ;display its value
    PUSH    ZH ;save z
    PUSH    ZL

    LDI     ZL, LOW(2 * HexDecimal)   
    LDI     ZH, HIGH(2 * HexDecimal)
    
    LDI     R20,    SIZE_RANGE_LOW
    DEC     R20
GetSfromTable:
    INC     R20 ; move through table
    CP     R20,    R25 ; compare with the value
    BRNE    GetSfromTable   
    ; now the value is correct
    CLR     R21
    DEC     R20 ;use as the offset to Z, 0 indexed
    ADD     ZL, R20
    ADC     ZH, R21   ; add the offset to Z
    LPM     R16, Z+     ; get the value
    LDI     R17,    SIZE_SETTING
    CALL    DisplayHex ;display to 7-segment display
    LDI     R16,    COLON
    CALL    DisplayMisc ;   display the colon


    POP     ZL
    POP     ZH ; restore Z
      
    LDI     R20,    SIZE_STEP_SIZE
    LDI     R21,    SIZE_RANGE_LOW
    LDI     R22,    SIZE_RANGE_HIGH
    LDI     R23,    SIZE_INIT
    CALL    CheckRotations   

    STS     Size,    R25 ; in case of change
    JMP     CheckStartPressed


NotSizeSettingSelected:
    CPI     R19, HIGH_SCORE_IDX
    BRNE    NotHsSettingSelected
    
    LDI     R16,    COLON
    CALL    DisplayMisc ;   display the colon

    LDS     R16, HighScore  ; display the hs
    LDI     R17, HIGHSCORE_SETTING
    CALL    DisplayHex

    ; display h on high bit
    LDI     R16,    CHAR_H  ;'hs' - highscore
    LDI     R17,    DIGIT3
    CALL    DisplayChar

    ; high score cannot change, but no other settings can change either
    CALL    RotCCW          ; clear the vars
    CALL    RotCW
    CALL    RotPress
    JMP     CheckStartPressed

NotHsSettingSelected:
    CPI     R19, DISAPPEARANCE_IDX
    BRNE    NotDisappearanceSelected
    
    LDS     R25, DisappearanceRate

    ; display the setting
    MOV     R16,    R25
    LDI     R17,    DISAPPEARANCE_SETTING
    CALL    DisplayHex ;display to 7-segment display
    CLI

    LDI     R16,    COLON
    CALL    DisplayMisc ;   display the colon
      
    
    ; Display 'F' if disappearance turned off
    CPI     R25,    FALSE
    BRNE    DisplayDisappearanceValue
    LDI     R16,    CHAR_F
    LDI     R17,    DIGIT0
    CALL    DisplayChar


DisplayDisappearanceValue:    
    CLR     R16    ; don't want to display on digit1
    LDI     R17,    DIGIT1
    CALL    DisplayChar
    SEI

    ; Update value
    LDI     R20,    DISAPPEARANCE_STEP
    LDI     R21,    DISAPPEARANCE_RANGE_LOW
    LDI     R22,    DISAPPEARANCE_RANGE_HIGH
    LDI     R23,    FALSE   ; init = false
    CALL    CheckRotations   

    STS     DisappearanceRate,    R25 ; in case of change
    JMP     CheckStartPressed

NotDisappearanceSelected:
    CPI     R19, RANDOM_MODE_IDX
    BRNE    MusicSettingSelected
    
    ;display random mode
    LDI     R16,    COLON
    CALL    DisplayMisc ;   display the colon

    CLI
    CLR     R16
    LDI     R17,    DIGIT3
    CALL    DisplayChar

    LDI     R17,    DIGIT1
    CALL    DisplayChar

    LDI     R16,    CHAR_R  ; 'r' - random
    LDI     R17,    DIGIT2
    CALL    DisplayChar


    LDS     R25,    RandomMode

    CPI     R25, FALSE
    BREQ    DisplayRMfalse
    LDI     R16,    CHAR_T
    JMP     DisplayRMvalue

DisplayRMfalse:
    LDI     R16,    CHAR_F

DisplayRMvalue:
    LDI     R17,    DIGIT0
    CALL    DisplayChar
    SEI

    CALL    RotCW
    BREQ    SetRMTrue
    CALL    RotCCW
    BREQ    SetRMFalse
    CALL    RotPress
    BRNE    StoreRM

SetRMFalse:
    LDI R25,    FALSE
    JMP StoreRM

SetRMTrue:
    LDI R25,    TRUE
    
StoreRM:
    STS RandomMode, R25
    JMP CheckStartPressed

MusicSettingSelected:  ; if none of the previous settings => music setting
    ;display MUSIC mode
    LDI     R16,    COLON
    CALL    DisplayMisc ;   display the colon

    CLR     R16
    LDI     R17,    MUSIC_SETTING
    CALL    DisplayHex
    CLI

    LDI     R16,    CHAR_G  ; 'GS' - gamesound
    LDI     R17,    DIGIT3
    CALL    DisplayChar

    CLR     R16
    LDI     R17,    DIGIT1
    CALL    DisplayChar


    LDS     R25,    Music

    CPI     R25, FALSE
    BREQ    DisplayMusicfalse
    LDI     R16,    CHAR_T
    JMP     DisplayMusicvalue

DisplayMusicfalse:
    LDI     R16,    CHAR_F

DisplayMusicvalue:
    LDI     R17,    DIGIT0
    CALL    DisplayChar
    SEI

    CALL    RotCW
    BREQ    SetMusicTrue
    CALL    RotCCW
    BREQ    SetMusicFalse
    CALL    RotPress
    BREQ    SetMusicTrue    ;    default is music
    BRNE    StoreMusic

SetMusicFalse:
    LDI R25,    FALSE
    JMP StoreMusic

SetMusicTrue:
    LDI R25,    TRUE
    
StoreMusic:
    STS Music, R25
    ;JMP CheckStartPressed


CheckStartPressed:
    LDI R16,    WAIT_START_DELAY
    CALL    Delay16
    LDI R16,    MODE_BUTTON  ; turn off Mode led
    LDI R17,    FALSE
    PUSH    R19
    PUSH ZL ; push registers
    PUSH ZH
    CALL    DisplayGameLED
    POP ZH
    POP ZL
    POP R19
    
    CALL    StartPress 
    BREQ    GameStart   ; repeat until start has been pressed
    JMP     WaitStartLoop
    ; Start has been Pressed
GameStart:
    LDS R16, RandomMode
    CPI R16, TRUE
    BRNE RunGame    
    LDI R16, FALSE ; ball cannot disappear in random mode
    STS DisappearanceRate, R16
RunGame:
    CALL    ClearDisplay
    LDI R16,    START_BUTTON    ; start has been pressed so display
    LDI R17,    TRUE
    CALL    DisplayGameLED
    CALL    PlayGame
    RET

PlayGame:
    RET


;______________________________________________________________________________


CheckRotations:
    LDI R24,    FALSE ; default setting for display hex is none
    CALL RotCCW
    BRNE CheckCW
    LDI R24,    TRUE    ; if change value, then need to display it 
    CP R25, R21    ; compares setting value to setting_range_low
    BREQ CheckCW    ; if setting value is at its minimum, can't do anything
    SUB    R25, R20 ; decrement setting's value
    JMP ExitCheckRotations   
CheckCW:
    CALL    RotCW
    BRNE CheckRotPress
    LDI R24,    TRUE    ; if change value, then need to display it 
    CP  R25, R22    ; compare value to setting range high
    BREQ CheckRotPress    ; if maxed out, then move on
    ADD R25,    R20 ; increment setting's value  
    JMP ExitCheckRotations
CheckRotPress:
    CALL    RotPress
    BRNE    ExitCheckRotations
    MOV R25,    R23 ; if rot pressed, set value to default
    LDI R24,    TRUE    ; if change value, then need to display it 
ExitCheckRotations:
    RET

;______________________________________________________________________________

;sweeps up and down the LEDs
WaitStartLEDs:
               ;Arguments (LED number and LED on/off)
    .DB 1, 0xFF    .DB 2, 0xFF    .DB 3, 0xFF    .DB 4, 0xFF 
    .DB 5, 0xFF    .DB 6, 0xFF    .DB 7, 0xFF    .DB 8, 0xFF
    .DB 9, 0xFF    .DB 10, 0xFF    .DB 11, 0xFF    .DB 12, 0xFF
    .DB 13, 0xFF    .DB 14, 0xFF    .DB 15, 0xFF    .DB 16, 0xFF
    .DB 17, 0xFF    .DB 18, 0xFF    .DB 19, 0xFF    .DB 20, 0xFF
    .DB 21, 0xFF    .DB 22, 0xFF    .DB 23, 0xFF    .DB 24, 0xFF
    .DB 25, 0xFF    .DB 26, 0xFF    .DB 27, 0xFF    .DB 28, 0xFF
    .DB 29, 0xFF    .DB 30, 0xFF    .DB 31, 0xFF    .DB 32, 0xFF
    .DB 33, 0xFF    .DB 34, 0xFF    .DB 35, 0xFF    .DB 36, 0xFF
    .DB 37, 0xFF    .DB 38, 0xFF    .DB 39, 0xFF    .DB 40, 0xFF
    .DB 41, 0xFF    .DB 42, 0xFF    .DB 43, 0xFF    .DB 44, 0xFF
    .DB 45, 0xFF    .DB 46, 0xFF    .DB 47, 0xFF    .DB 48, 0xFF
    .DB 49, 0xFF    .DB 50, 0xFF    .DB 51, 0xFF    .DB 52, 0xFF
    .DB 53, 0xFF    .DB 54, 0xFF    .DB 55, 0xFF    .DB 56, 0xFF
    .DB 57, 0xFF    .DB 58, 0xFF    .DB 59, 0xFF    .DB 60, 0xFF
    .DB 61, 0xFF    .DB 62, 0xFF    .DB 63, 0xFF    .DB 64, 0xFF
    .DB 65, 0xFF    .DB 66, 0xFF    .DB 67, 0xFF    .DB 68, 0xFF
    .DB 69, 0xFF    .DB 70, 0xFF    
    .DB 70, 0x00    .DB 69, 0x00    .DB 68, 0x00
    .DB 67, 0x00    .DB 66, 0x00    .DB 65, 0x00    .DB 64, 0x00
    .DB 63, 0x00    .DB 62, 0x00    .DB 61, 0x00    .DB 60, 0x00
    .DB 59, 0x00    .DB 58, 0x00    .DB 57, 0x00    .DB 56, 0x00
    .DB 55, 0x00    .DB 54, 0x00    .DB 53, 0x00    .DB 52, 0x00
    .DB 51, 0x00    .DB 50, 0x00    .DB 49, 0x00    .DB 48, 0x00
    .DB 47, 0x00    .DB 46, 0x00    .DB 45, 0x00    .DB 44, 0x00
    .DB 43, 0x00    .DB 42, 0x00    .DB 41, 0x00    .DB 40, 0x00
    .DB 39, 0x00    .DB 38, 0x00    .DB 37, 0x00    .DB 36, 0x00
    .DB 35, 0x00    .DB 34, 0x00    .DB 33, 0x00    .DB 32, 0x00
    .DB 31, 0x00    .DB 30, 0x00    .DB 29, 0x00    .DB 28, 0x00
    .DB 27, 0x00    .DB 26, 0x00    .DB 25, 0x00    .DB 24, 0x00
    .DB 23, 0x00    .DB 22, 0x00    .DB 21, 0x00    .DB 20, 0x00
    .DB 19, 0x00    .DB 18, 0x00    .DB 17, 0x00    .DB 16, 0x00
    .DB 15, 0x00    .DB 14, 0x00    .DB 13, 0x00    .DB 12, 0x00
    .DB 11, 0x00    .DB 10, 0x00    .DB 9, 0x00    .DB 8, 0x00
    .DB 7, 0x00    .DB 6, 0x00    .DB 5, 0x00    .DB 4, 0x00
    .DB 3, 0x00    .DB 2, 0x00    .DB 1, 0x00


EndWaitStartLEDs:

;____________________________________________________________________________

; HexDecimal - table that converts a decimal value to the value to display
;                       in hex.

HexDecimal:

    .DB 0x01, 0x02    .DB 0x03, 0x04
    .DB 0x05, 0x06    .DB 0x07, 0x08
    .DB 0x09, 0x10    .DB 0x11, 0x12
    .DB 0x13, 0x14    .DB 0x15, 0x16
    .DB 0x17, 0x18    .DB 0x19, 0x20
    .DB 0x21, 0x22    .DB 0x23, 0x24
    .DB 0x25, 0x26    .DB 0x27, 0x28
    .DB 0x29, 0x30    .DB 0x31, 0x32
    .DB 0x33, 0x34    .DB 0x35, 0x36
    .DB 0x37, 0x38    .DB 0x39, 0x40



