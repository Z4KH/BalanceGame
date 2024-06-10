; "InitSoundIMU.asm"
; This file initializes the sound, SPI, and IMU for the game board

; Procedures Included:
;	InitSoundIMU
;	InitPortB
;	InitSound
;	InitSPI
;	InitIMU

; Revision History:
;   06/01/2024  Zachary Pestrikov   Wrote File
;	06/04/2024	Zachary Pestrikov 	Debugged SPI initialization
;	06/05/2024	Zachary Pestrikov	Documented

; Registers Changed:
;   R20 
;	R17 

;____________________________________________________________________________________
.cseg

;Procedure: InitSoundIMU()
;Description: This Procedure initializes the speaker, the serial peripherial interface,
;			and the IMU.
;Operational Description: This procedure calls a sequence of functions to initialize
;							the speaker/spi port, the speaker timer, the spi, and the imu.
;Arguments:      None
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
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      None
;Registers Changed: None

InitSoundIMU:
    CALL    InitPortB
    CALL    InitSound
    CALL    InitSPI
    CALL    InitIMU
    RET

;______________________________________________________________________________________

;Procedure: InitPortB()
;Description: This Procedure initializes the output port to handle all speaker and SPI
;				interactions
;Operational Description: This procedure sets MOSI, SCK, SS, and the speaker control bit
;							to outputs, and all other pins in port b to inputs.
;Arguments:      None
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
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      DDRBinit - determines the state of the pins in port B.
;Registers Changed: R20 - Used to output to DDRB

InitPortB:
    LDI R20, DDRBinit   ; get the output and input bits
    OUT DDRB,   R20
    RET

;____________________________________________________________________________________

;Procedure: InitSound()
;Description: This Procedure initializes the speaker and turns it off.
;Operational Description: This procedure sets initializes the speaker to generate
;							square waves. The timer prescaler is set to 64. The 
;							speaker is able to output any frequency up to 15.6kHz
;							that results in an integer when passed through the function
;							CLOCK_FRQ_FACTOR / frequency(hz). The procedure also initializes
;							the timer counter register.
;Arguments:      None
;Return Values:  None
;Shared Variables: None
;Local Variables: None
;Input:          None
;Output:         Speaker turned off
;Error Handling: None
;Algorithms:     None
;Data Structures: None
;Limitations:    None
;Known Bugs:     None
;Special Notes:  None
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      TCCR1Ainit - value to initialize the timer counter.
;					TCCR1Binit	- value to initialize the square waves and prescaler
;					SpeakerBit	-	The pin in port b that drives the speaker.
;Registers Changed: R20 - Used to output to portb and tccr1a/b

InitSound:
    LDI R20, TCCR1Ainit
    OUT TCCR1A, R20     ; init timer counter
    LDI R20, TCCR1Binit
    OUT TCCR1B, R20     ; init prescaler & square waves
TurnSpeakerOff:
    CLR R20
    CBI PORTB,  SpeakerBit 
    OUT OCR1AL, R20     ; want timer counter compare to be 0 so no sound plays at all
    OUT OCR1AH, R20  
    RET

;___________________________________________________________________________________

;Procedure: InitSPI()
;Description: This Procedure initializes the CPU's serial peripherial interface.
;Operational Description: This procedure outputs to the spi control register and 
;							defines the CPU as the master. It sets up the spi clock as
;							well and then outputs a byte to the data register.
;Arguments:      None  
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
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      SPCRinit - stores the bits to initialize the spi control register
;					SlaveSelect	- the bit in PORTB that controls the slave select line
;					TRUE	- 0xFF
;Registers Changed: R20 - used to output to SPCR
;					R17	-	input to SPIcom procedure

InitSPI:
    LDI R20,    SPCRinit
    OUT SPCR,   R20 ; initialize the SPI control
    SBI PORTB, SlaveSelect	; SS active low
    LDI R17, TRUE       ; initialize SPDR
    CALL SPIcom			; output to SPDR
    RET

;___________________________________________________________________________________
    
;Procedure: InitIMU()
;Description:  This procedure initializes the IMU to report +-2g acceleration.
;Operational Description: The procedure communicates with the IMU registers via 
;						port B and SPI and configurates the measurements. All
;						special settings are turned off.
;Arguments:      None
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
;Critical Code:  None. Interrupts cannot happen yet.
;Constants:      IMUconfig - the address of the IMU configuration register
;					AccelConfig[1,2] - the address of the IMU acceleration
						;configuration register
;Registers Changed: R20 - data sent to IMU registers
;					R17	-	holds the register addresses


InitIMU:
    CLR R20						; Sending all 0's for +-2g and no special settings
    LDI R17,    IMUconfig		; first configurate the IMU
    CALL    TransmitIMU
    CLR R20
    LDI R17,    AccelConfig1	; set +-2g
    CALL    TransmitIMU
    CLR R20
    LDI R17,    AccelConfig2	; no filter
    CALL    TransmitIMU
    RET
    
;____________________________________________________________________________________
