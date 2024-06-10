;   'InitButtons.asm'
; This file initializes the hardware input ports for all switches and rotary
; encoder.
; Registers used:
    ; R16 - Count Register for clock to generate interrupts
    ; R18 - [PrevRot1,PrevRot2,0,RotCW,RotCCW,StartSwitch,ModeSwitch,RotSwitch]
    ; R19 - Temporary Register used to store variables in memory

; Revision History:
    ; 5/04/2024 Zachary Pestrikov   Wrote file
    ; 5/05/2024 Zachary Pestrikov   Edited registers used in Initialize()





;Procedure: InitButtons
;Description:    This Procedure initializes the I/O ports for the
;                switches and rotary encoder.
;Operational Description:    The procedure sets all variables to 0
;Arguments:      None
;Return Values:  None
;Shared Variables: Switch Status register(R18) initizlized to false, except prevRot = 11,
;                   Expected CCW - initialized to expect 01 as next CCW rotation
;                   Count Register - R16 - determines when to interrupt
;Local Variables: R19 - used to store ExpectedCCW
;Input:          None
;Output:         None
;Error Handling: Interrupts are dissabled
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None - Interrupt is not called until after function runs

.cseg

InitButtons:                 ; Reset all values
        LDI R18, INIT_BUTTONS_STATE         
        LDI R19, INITCCW ; Next Expected CCW Rotation = 01
        STS ExpectedCCW, R19
InitButtonPort:
        LDI    R16, INDATA             ;Port E is all the inputs
        OUT     DDRE, R16
        RET
