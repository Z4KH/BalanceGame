; This file implements the event handler for timer0, which generates regular interrupts
; every ms. The function determines when a switch is being pressed or the rotary encoder has
; been turned a full cycle and sets the appropriate variable. It also handles debouncing the switches.
; Registers Used:
    ; R18 = [PrevRotState1,PrevRotState0,0,RotCW,RotCCW,StartSwitch,ModeSwitch,RotSwitch]
    ; R19 = Temporary Register used mainly for ALU operations - saved on stack
    ; R21 = Temporary Register used mainly for loading bits and ALU operations - saved on stack
    ; R22 = Temporary Register for Comparing rotary encoder bits - saved on stack
    ; R23 = Temporary Register used for loading the previous state of the rotary enoder bits - saved on stack

; Hardware input ports:
    ; E5 = RotarySwitch
    ; E6 = ModeSwitch
    ; E7 = StartSwitch
    ; E4,5 = Rotary Encoder


; Revision History:
; 5/04/2024 Zachary Pestrikov   Wrote event handler to check switches and drafted rotary encoder checker
; 5/05/2024 Zachary Pestrikov   Finalized event handler


.cseg 

;Procedure: ButtonEventHandler
;Description:    This Procedure handles all timer interrupts and adjusts the variables based on input
;Operational Description:    The procedure is invoked whenever there is an interrupt. It reads
;                            all the inputs and updates shared variables if these have changed.
;                            It also determines whether there has been a cycle of the rotary
;                            encoder by comparing the new rotary_encoder register to bytes that
;                            represent cycles. It also debounces the switch by waiting until the 
;                            switch has stopped bouncing to update the values.
;Arguments:      None
;Return Values:  None 
;Shared Variables: Switch status byte(R18) all determined by hardware inputs 
;Local Variables: Debounce_cntrRot:       counter for debouncing rotary switch
;                   Debounce_cntrMode:       counter for dobouncing mode switch
;                   Debounce_cntrStart:     counter for debouncing start switch
;                   ExpectedCCW:      holds order of CCW rotations with next one in lowest two bits
;                   R19,21,23 all temporary registers used to shift variables around
;Input:          All different switches and rotary encoder from port E
;Output:         None
;Error Handling: Switches are debounced. Interrupts are disabled
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  Interrupts disabled by AVR

ButtonEventHandler:      ; R18 = Local Variable to hold input data
        PUSH R19        ; save all used registers on the stack
        PUSH R21
        PUSH R22
        PUSH R23
        IN   R21, SREG       ; save status register on the stack
        PUSH R21
        CLR R21         ; clear all used registers to prepare them for use
        CLR R22
        CLR R23
        IN R21, PINE       ; switches are on port E -> loaded into R21
CheckRotSwitchFunc:     ; begin checking switches starting with the rotary switch
        CLR R19
        BST R21, 5       ; get rotary switch from bit 5 in ports 
        BLD R19, 0
        CPI R19, 1          ; check if set
        BRNE DebounceRot     ; if the switch is down(=0), debounce the switch
        LDI R22, DEBOUNCE_TIME          
        STS Debounce_cntrRot, R22                    ; Since the switch is up, debounce_cntr <- debounce_time

CheckModeSwitchFunc:    ; check if the mode switch is being pressed and deobounce it
        CLR R19         ; must ensure that R19 is clear because only loading individual bits
        BST R21, 6       ; Get mode switch from bit 6 of port E(stored in R21)
        BLD R19, 0
        CPI R19, 1      ; check if mode switch set(=0)
        BRNE DebounceMode     ; if set(=0), then debounce
        LDI R22, 20     ; if not set(=1), then reset the debounce counter for this switch to 20ms
        STS Debounce_cntrMode, R22
        
CheckStartSwitchFunc:   ; check if start switch is being pressed and debounce it
        CLR R19          ; must ensure that R19 is clear because only loading individual bits        
        BST R21, 7       ; Get start switch from bit 7 of port E(stored in R21)
        BLD R19, 0
        CPI R19, 1      ; check if start switch set(=0)       
        BRNE DebounceStart  ; if set(=0), then debounce
        LDI R22, 20         ; if not set(=1), then reset the debounce counter for this switch to 20ms
        STS Debounce_cntrStart, R22
        JMP CheckRotation   ; finished checking switches, now check rotations


SetRotSwitch:       ; called if determined that rotswitch is being pressed
        LDI R19, 1      ; set rotswitch shared var in R18 to true
        BST R19, 0
        BLD R18, 0      ; RotSwitch is in 0th bit of R18
        JMP CheckModeSwitchFunc     ; done checking Rotswitch, move on to mode switch
RotCtrSub:          ; rot switch debounce counter is below 0 => set to 0
        LDI R19, 0
        STS Debounce_cntrRot, R19
        JMP CheckModeSwitchFunc ; done checking rotswitch, mote onto mode switch
DebounceRot:        ; if the rotary switch is being pressed, debounce it
        LDS R19, Debounce_cntrRot   ; get the debounce counter 
        DEC R19                         ; decrement the debounce counter
        STS Debounce_cntrRot, R19   ; store the debounce counter
        CPI R19, 0                  ; check if the debounce counter is 0
        BREQ SetRotSwitch           ; if the debounce counter is 0, set the shared rotswitch variable
        BRLT RotCtrSub              ; if the debounce counter less than 0,  halt the debouncing and wait for next press
        JMP CheckModeSwitchFunc     ; done checking rotswitch, mote onto mode switch

SetModeSwitch:       ; called if determined that modeswitch is being pressed
        LDI R19, 1      ; set modeswitch shared var in R18 to true
        BST R19, 0
        BLD R18, 1      ; ModeSwitch is in 1st bit of R18
        JMP CheckStartSwitchFunc     ; done checking Modeswitch, move on to start switch
ModeCtrSub:          ; mode switch debounce counter is below 0 => set to 0
        LDI R19, 0
        STS Debounce_cntrMode, R19
        JMP CheckStartSwitchFunc     ; done checking Modeswitch, move on to start switch
DebounceMode:       ; if the mode switch is being pressed, debounce it
        LDS R19, Debounce_cntrMode     ; get the debounce counter  
        DEC R19                             ; decrement the debounce counter
        STS Debounce_cntrMode, R19  ; store the debounce counter
        CPI R19, 0                      ; check if the debounce counter is 0
        BREQ SetModeSwitch          ; if the debounce counter is 0 => done debouncing
        BRLT ModeCtrSub            ; if the debounce counter less than 0, halt the debouncing and wait for next press
        JMP CheckStartSwitchFunc    ; done checking Modeswitch, move on to start switch

SetStartSwitch:       ; called if determined that startswitch is being pressed
        LDI R19, 1      ; set startswitch shared var in R18 to true
        BST R19, 0
        BLD R18, 2      ; StartSwitch is in 2nd bit of R18
        JMP CheckRotation     ; done checking startswitch, move on to rotations
StartCtrSub:                ; start switch debounce counter is below 0 => set to 0
        LDI R19, 0
        STS Debounce_cntrStart, R19
        JMP CheckRotation    ; done checking startswitch, move on to rotations
DebounceStart:      ; if the start switch is being pressed, debounce it
        LDS R19, Debounce_cntrStart       ; get the debounce counter  
        DEC R19                  ; decrement the debounce counter
        STS Debounce_cntrStart, R19 ; store the debounce counter
        CPI R19, 0             ; check if the debounce counter is 0
        BREQ SetStartSwitch   ; if the debounce counter is 0 => done debouncing
        BRLT StartCtrSub             ; if the debounce counter less than 0, halt the debouncing and wait for next press
        JMP CheckRotation    ; done checking startswitch, move on to rotations




CheckRotation:          ; Check rotary encoder for new movement, First make sure that current state is a new state
        CLR R19         ; clear used registers
        CLR R22
        BST R21, 3      ; load lower bit of rotary encoder into r19(0)
        BLD R19, 0
        BST R21, 4      ; load upper bit of rotary encoder into r19(1)
        BLD R19, 1      ; rotary encoder loaded into R19
        BST R18, 6     ; Load previous state into R22 from upper bits of switch status byte
        BLD R22, 0      
        BST R18, 7
        BLD R22, 1 
        CP  R19, R22    ; now check if matches old state
        BRNE CCWRotation   ; Check CCW rotation first, then CW rotation
        BREQ    ExitInterrupt ; if same state as before, then finished


ExitInterrupt:  ; once done checking all switches and roations, exit the interrupt
; first store the state of the rotary encoder in the higest bits of the switch status register(R18)
        BST R19, 0      ; the current rotary encoder state is already in lowest bits of R19 from checking for rotations
        BLD R18, 6
        BST R19, 1
        BLD R18, 7
        POP R21         ; pop used registers off of the stack
        OUT SREG, R21   ; pop the status register off of the stack
        POP R23
        POP R22
        POP R21
        POP R19
        RET            ; this was called from timer interrupt => need reti

CWRotation:    
        
CheckCompleteCW: ; called if new state is not a CCW rotation => CW rotation
; first must shift expectedCCW left twice because now moving farther away from full CCW rotation
        LSL R21 ; puts lowest bit into carry, highest = 0 
        BRCC NextShiftCW     ; need to put carry flag into highest bit
        LDI R22, 1    ; add 1 to set lowest bit if carry flag is set
        ADD R21, R22    
NextShiftCW:    ; shift left again because each rotary state is two bits
        LSL R21 ; puts lowest bit into carry, highest = 0 
        BRCC DoneShiftingCW     ; need to put carry flag into highest bit
        LDI R22, 1    ; add 1 to set lowest bit if carry flag set
        ADD R21, R22
DoneShiftingCW:     ;put expectedCCW back in memory, and check for full CW rotation
        STS ExpectedCCW, R21       ; put new expected ccw back into memory after shifting if rotation
        CPI R19, 0b11       ; if full rotation, then the rotary encoder should be back to 11
        BREQ FullCW         
        JMP ExitInterrupt   ; if it is not a full rotation, then we are done
FullCW:     ; a full CW rotation has been achieved
        LDI R22, 1      ; must set the rotcw variable in the switch status byte - R18
        BST R22, 0
        BLD R18, 4      ; Set RotCW(bit 4 of switch status byte(R18))
        JMP ExitInterrupt   ; done checking/updating everything




CCWRotation:  ; new state has already been determined => check first for CCW rotation
        LDS R21, ExpectedCCW    ; begin checking for ccw rotation
; if it is a CCW rotation, then the previous state of the rotary encoder will match the previous state in the 'expectedCCW' variable
        ; get bits of previous CCW state into R22
        BST R21, 6; previous CCW state will be in upper two bits of ExpectedCCW(R21)
        BLD R22, 0 ; load them into lowest bits of r22
        BST R21, 7
        BLD R22, 1  ; previous CCW state now in R22
        BST R18, 6  ; previous state of rotary encoder in upper two bits of R18
        BLD R23, 0      ; load them into r23
        BST R18, 7
        BLD R23, 1
        CP  R22, R23 ; compare previous state(R22) to the expected previous ccw state(R23)
        BRNE CheckCompleteCW; if they are equal then it is a ccw rotation, else it is a cw rotation
; if it is a ccw rotation shift expectedccw right to the next expected bits
        LSR R21 ; puts lowest bit into carry, highest = 0 
        BRCC NextShift     ; if carry flag is 0, then just move on
        LDI R22, 128    ; if C=1, then add 128 to set highest bit in expectedCCW
        ADD R21, R22    
NextShift:      ; need to shift twice because each rotary state is two bits
        LSR R21 ; puts lowest bit into carry, highest = 0 
        BRCC DoneShifting     ; if carry flag is 0, then just move on
        LDI R22, 128    ; if C=1, then add 128 to set highest bit in expectedCCW
        ADD R21, R22
DoneShifting:   ; after two LSR's we are done shifting, and can now store the variable
        STS ExpectedCCW, R21       ; put new expected ccw back into memory after shifting if rotation
CheckCompleteCCW: ; if 11 in lowest two bits => full rotation
        CPI R19, 0b11       ; compare current rotary encoder state(R19) with 11
        BREQ FullCCW    ; if it is the same, then it is a full rotation
        JMP ExitInterrupt   ; else, we are done checking because we know it can't be a CW rotation since it was a CCW rotation
FullCCW:    ; if it is a full CCW rotation, then set the appropriate bit in the switch status register
        LDI R22, 1
        BST R22, 0
        BLD R18, 3      ; RotCCW variable is in bit 3 of R18
        JMP ExitInterrupt   ; not cw rotation, so can exit
        
       





.dseg

Debounce_cntrRot:      .BYTE 1 ; counter for debouncing rotary switch
Debounce_cntrMode:       .BYTE 1 ; counter for dobouncing mode switch
Debounce_cntrStart:     .BYTE 1 ; counter for debouncing start switch
ExpectedCCW:             .BYTE 1 ; holds next expected CCW rotation in lowest two bits, and previous CCW in highest bits

