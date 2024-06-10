; "GetAccel.asm"
; This file handles reading accelerometer data from the IMU
;
; Procedures Included:
;	GetAccelX
;	GetAccelY
;	GetAccelZ
;
; Revision History
;	06/02/2024	Zachary Pestrikov	Wrote Procedures
;	06/04/2024	Zachary Pestrikov	Edited Function Calls
;	06/05/2024	Zachary Pestrikov	Added Documentation

; Registers Changed:
;	R16
;	R17
;	R21

;__________________________________________________________________________


.cseg

;Procedure: GetAccelX()
;Description: This procedure gets the X accelerometer value from the IMU in
;				g's. The range is +-2g and the format is Q1.14.
;Operational Description: This procedure reads from the x-acceleration 
;							measurement register in
;                            the IMU via SPI. It returns the value in R17|R16
;Arguments:      None 
;Return Values:  accelX(R17|R16) - the 16-bit x-axis acceleration Q1.14 in g's
;Shared Variables: None
;Local Variables: None
;Input:          On-board IMU
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. 
;Constants:      ACCEL_XOUT_H/L - The high and low X-accelerometer 
;					IMU register addresses
;Registers Changed: R16 - Low byte of acceleration
;					R17 - high byte of acceleration
;					R21 - buffer

GetAccelX:
    LDI R17,    ACCEL_XOUT_H
    CALL    RecieveIMU      ; get the high bit
    MOV R21, R16            ; save it in r21
    LDI R17,    ACCEL_XOUT_L
    CALL    RecieveIMU      ; get the low bit, put in r16
    MOV R17, R21            ; put data in r17|r16
    RET

;__________________________________________________________________________

;Procedure: GetAccelY()
;Description: This procedure gets the Y accelerometer value from the IMU in
;				g's. The range is +-2g and the format is Q1.14.
;Operational Description: This procedure reads from the Y-acceleration 
;							measurement register in
;                            the IMU via SPI. It returns the value in R17|R16
;Arguments:      None 
;Return Values:  accelY(R17|R16) - the 16-bit Y-axis acceleration Q1.14 in g's
;Shared Variables: None
;Local Variables: None
;Input:          On-board IMU
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. 
;Constants:      ACCEL_YOUT_H/L - The high and low Y-accelerometer 
;					IMU register addresses
;Registers Changed: R16 - Low byte of acceleration
;					R17 - high byte of acceleration
;					R21 - buffer

GetAccelY:
    LDI R17,    ACCEL_YOUT_H
    CALL    RecieveIMU      ; get the high bit
    MOV R21, R16            ; save it in r21
    LDI R17,    ACCEL_YOUT_L
    CALL    RecieveIMU      ; get the low bit, put in r16
    MOV R17, R21            ; put in r17|r16
    RET

;__________________________________________________________________________

;Procedure: GetAccelZ()
;Description: This procedure gets the Z accelerometer value from the IMU in
;				g's. The range is +-2g and the format is Q1.14.
;Operational Description: This procedure reads from the Z-acceleration 
;							measurement register in
;                            the IMU via SPI. It returns the value in R17|R16
;Arguments:      None 
;Return Values:  accelZ(R17|R16) - the 16-bit Y-axis acceleration Q1.14 in g's
;Shared Variables: None
;Local Variables: None
;Input:          On-board IMU
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. 
;Constants:      ACCEL_ZOUT_H/L - The high and low Z-accelerometer 
;					IMU register addresses
;Registers Changed: R16 - Low byte of acceleration
;					R17 - high byte of acceleration
;					R21 - buffer

GetAccelZ:
    LDI R17,    ACCEL_ZOUT_H
    CALL    RecieveIMU      ; get the high bit
    MOV R21, R16            ; save it in r21
    LDI R17,    ACCEL_ZOUT_L
    CALL    RecieveIMU      ; get the low bit, put in r16
    MOV R17, R21            ; put in r17|r16
    RET

;__________________________________________________________________________
