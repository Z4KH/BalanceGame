; SettingsConsts.inc
; This file contains the constants for the settings


; Settings init
.EQU    GRAVITY_INIT    =   10  ; left digit - units, right digit - tenths. In G's
.EQU    SIZE_INIT   = 3
.EQU    MUSIC_INIT = 0xFF
.EQU    DISAPPEARANCE_RATE_INIT =   0
.EQU    RANDOM_MODE =   0   ;random mode initialized to false

; Settings Step Sizes
.EQU    GRAVITY_STEP_SIZE   = 1 ; 0.1g
.EQU    SIZE_STEP_SIZE  =   2   ; 2 led's
.EQU    DISAPPEARANCE_STEP  =   1   ;  1 s
.EQU    RANDOM_STEP_SIZE    =   0xFF    ; oscillates between true and false

; Settings upper bounds
.EQU    GRAVITY_RANGE_HIGH  =   40  ;   4g
.EQU    SIZE_RANGE_HIGH = 35    ; ball can take up <= 35 led's
.EQU    DISAPPEARANCE_RANGE_HIGH    =   4   ; 4s

; Settings lower bounds
.EQU    GRAVITY_RANGE_LOW   =   1   ;   0.1g
.EQU    SIZE_RANGE_LOW  =   1   ; ball can take up >= 1 led
.EQU    DISAPPEARANCE_RANGE_LOW =   0

; Setting Signifier Displays
.EQU    GRAVITY_SETTING = 0x0C
.EQU    SIZE_SETTING   =   0x05  
.EQU    HIGHSCORE_SETTING =   0x05    
.EQU    DISAPPEARANCE_SETTING  =   0x0D
.EQU    MUSIC_SETTING  =   0x05

; Settings indices 
.EQU    GRAVITY_IDX = 1 ; gravity = settings[0]
.EQU    SIZE_IDX = 2
.EQU    HIGH_SCORE_IDX  =   3
.EQU    DISAPPEARANCE_IDX = 4
.EQU    RANDOM_MODE_IDX =   5

; RELATED CONSTS
.EQU    FALSE   =   0
.EQU    MAX_DISAPPEARANCE_TIME  =   2
.EQU    NUM_SETTINGS   =    6   ;the number of settings
