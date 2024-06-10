; "Transmit.asm"
; this file handles transmitting data to the IMU through SPI

; Procedures Included:
;	TransmitIMU
;	SPIcom

; Revision History:
;	06/02/2024	Zachary Pestrikov	Wrote initial draft of function
;	06/04/2024	Zachary Pestrikov	Debugged and finalized
;	06/05/2024	Zachary Pestrikov	Added Documentation

; Registers Changed:
;	R16
;	R17

;_________________________________________________________________________

.cseg


;Procedure: TransmitIMU(data, regIMU)
;Description: This procedure writes data to a register in the IMU
;Operational Description: Given a byte of data(data) and a 7 bit IMU register 
;							address(regIMU), this procedure will load the IMU 
;							register with the data via SPI.
;Arguments:      data(R20) - byte of data to be sent to IMU
;                regIMU(R17) - 7-bit(lower) IMU register address
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
;Critical Code:  None. 
;Constants:      SlaveSelect - The bit in portb that controls the SS line
;					TRANSMIT	- encodes a write to the IMU
;Registers Changed: R17 - the value loaded into SPDR
;					R16 - changed by SPIcom

TransmitIMU:
    CBI PORTB, SlaveSelect   
    ANDI R17,    TRANSMIT
    CALL    SPIcom; first transmit the imu register
    MOV R17,    R20        ; next transmit the data
    CALL    SPIcom; 4 clocks
    SBI PORTB, SlaveSelect
    RET

;_________________________________________________________________________


;Procedure: SPIcom(data)
;Description: This procedure communicates with external devices via SPI
;Operational Description: Given a byte of data(data) the procedure loads 
;							data into the SPDR register and reads from it
;							after the transmission is complete.
;Arguments:      data(R17) - byte of data to be loaded into SPDR
;Return Values:  dataRead(R16) - byte of data read from SPDR
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
;Critical Code:  None. 
;Constants:      None
;Registers Changed: R17 - the value loaded into SPDR
;					R16 - the data read from SPDR
SPIcom:
    OUT SPDR,   R17	; write
WaitTransmit:		; wait for transmission to complete
    SBIS SPSR,SPIF
    RJMP WaitTransmit
TransmitComplete:
    IN R16, SPDR    ; read data reg into r16
    RET

;____________________________________________________________________________
