; This file implements five functions that indicate the status of the switches
; and rotary encoder. For the switch functions, when they are called they return
; true(Z=1) or false(Z=0) based on whether the switch has been pressed since the last time they were
; called. The used registers are as follows:
    ; R18 = [PrevRot1,PrevRot2,0,RotCW,RotCCW,StartSwitch,ModeSwitch,RotSwitch]
    ; R19 = Temporary Register for local variables 

; Revision History
;   5/04/2024   Zachary Pestrikov   Wrote all five functions
;   5/05/2024   Zachary Pestrikov   Edited rotary encoder functions




.cseg 
      

;Procedure: RotPress
;Description:    This Procedure determines whether or not the Rotary switch has been pressed
;Operational Description:    The procedure checks the value of the RotSwitch variable and sets 
;                            the zero flag if it is true
;Arguments:      None
;Return Values:  Zero Flag
;Shared Variables: Switch Status Byte (R18), bit 0 reset(RotSwitch)
;Local Variables: RotSwitch(R19)
;Input:          None
;Output:         None
;Error Handling: Interrupts are dissabled during critical code
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Resetting the RotSwitch variable & checking RotSwitch variable


RotPress:
        PUSH R19    ; save REGISTERS
        CLR R19         ; temporary variable
        CLZ
        CLI                ; disable interrupts
        BST R18, 0          ; load RotSwitch variable out of R18 into temp(R19)
        BLD R19, 0
        CPI R19, 1      ; zero flag gets set if RotSwitch is true
        LDI R19, 0      
        BST R19, 0
        BLD R18, 0      ; set rotswitch to 0
        SEI
        POP R19
        RET
        


;Procedure: ModePress
;Description:    This Procedure determines whether or not the Mode switch has been pressed
;Operational Description:    The procedure checks the value of the ModeSwitch variable and sets 
;                            the zero flag if it is true
;Arguments:      None
;Return Values:  Zero Flag
;Shared Variables: Switch status byte(R18), bit 1 reset(ModeSwitch)
;Local Variables: ModeSwitch(R19)
;Input:          None
;Output:         None
;Error Handling: Interrupts are dissabled during critical code
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Resetting the ModeSwitch variable & checking RotSwitch variable

ModePress:
        PUSH R19    ; save R19
        CLR R19         ; temporary variable
        CLZ
        CLI
        BST R18, 1          ; load ModeSwitch variable out of R18 into temp(R19)
        BLD R19, 0
        CPI R19, 1
        LDI R19, 0
        BST R19, 0
        BLD R18, 1          ; set modeswitch to 0
        SEI
        POP R19
        RET



;Procedure: StartPress
;Description:    This Procedure determines whether or not the Start switch has been pressed
;Operational Description:    The procedure checks the value of the StartSwitch variable and sets 
;                            the zero flag if it is true
;Arguments:      None
;Return Values:  Zero Flag
;Shared Variables: Switch status byte(R18), bit 2(StartSwitch) reset
;Local Variables: StartSwitch(R19)
;Input:          None
;Output:         None
;Error Handling: Interrupts are dissabled during critical code
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Resetting the StartSwitch variable & checking RotSwitch variable

StartPress:
        PUSH R19    ; save R19
        CLR R19         ; temporary variable
        CLZ
        CLI
        BST R18, 2          ; load StartSwitch variable out of R18 into temp(R19)
        BLD R19, 0
        CPI R19, 1
        LDI R19, 0
        BST R19, 0
        BLD R18, 2
        SEI
        POP R19
        RET



;Procedure: RotCCW
;Description:    This Procedure determines whether or not the rotary encoder has gone through a full
;                counterclockwise cycle.
;Operational Description:    The procedure checks the value of the CCW variable and sets 
;                            the zero flag if it is true
;Arguments:      None
;Return Values:  Zero Flag
;Shared Variables: Switch status byte(R18), bit 3(RotCCWvar) reset
;Local Variables: RotCCW(R19)
;Input:          None
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Loading CCW variable from switch byte

RotCCW:
        PUSH R19    ; save R19
        CLR R19         ; temporary variable
        CLZ
        CLI
        BST R18, 3          ; load RotCCW variable out of R18 into temp(R19)
        BLD R19, 0
        CPI R19, 1
        LDI R19, 0
        BST R19, 0
        BLD R18, 3
        SEI
        POP R19
        RET




;Procedure: RotCW
;Description:    This Procedure determines whether or not the rotary encoder has gone through a full
;                clockwise cycle.
;Operational Description:    The procedure checks the value of the CW variable and sets 
;                            the zero flag if it is true
;Arguments:      None
;Return Values:  Zero Flag
;Shared Variables: Switch Status Byte(R18), bit 4(RotCWvar) reset
;Local Variables: RotCW(R19)
;Input:          None
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code: Loading CCW variable from switch byte

RotCW:
        PUSH R19    ; save R19
        CLR R19         ; temporary variable
        CLZ
        CLI
        BST R18, 4          ; load RotCW variable out of R18 into temp(R19)
        BLD R19, 0
        CPI R19, 1
        LDI R19, 0
        BST R19, 0
        BLD R18, 4
        SEI
        POP R19
        RET
 
