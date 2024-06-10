; "Recieve.asm"
; this file handles recieving data from the IMU through SPI

; Procedures Included:
;	RecieveIMU

; Revision History:
;	06/02/2024	Zachary Pestrikov	Wrote Initial Procedure
;	06/04/2024	Zachary Pestrikov	Debugged RecieveIMU
;	06/05/2024	Zachary Pestrikov	added documentation

; Registers Changed:
;	R17

;____________________________________________________________________________________

.cseg

;Procedure: RecieveIMU(RegIMU)
;Description: This procedure reads data from a register(RegIMU) in the IMU, and returns 
;			it in R16
;Operational Description: Given a 7 bit IMU register address(regIMU),
;                            this procedure will tell the IMU to send its data 
;							via SPI. The procedure then returns the data in r16
;Arguments:      RegIMU(R17) - 7 bit IMU register address
;Return Values:  dataOut - 8 bit data in regIMU returned in R16
;Shared Variables: None
;Local Variables: None
;Input:          IMU
;Output:         None
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. 
;Constants:      SlaveSelect - the bit in portb that controls the slave select line
;					RECIEVE - encodes a read to the IMU
;					TRUE - 0xff
;Registers Changed: R17 - RegIMU and data set to IMU
RecieveIMU:
    CBI PORTB, SlaveSelect   
    ORI R17,    RECIEVE
    CALL    SPIcom     ; first transmit the imu register
    LDI R17,    TRUE         ; transmit anything AS DATA
    CALL    SPIcom     ; 4 clocks
    SBI PORTB, SlaveSelect
    RET	;	data is returned in R16


;____________________________________________________________________________________
