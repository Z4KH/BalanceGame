; "SoundIMUconsts.inc"
; This file holds all the constants for the sound and IMU

; No procedures included
; No Registers changed

; Revision History:
;	06/01/2024	Zachary Pestrikov	initial constants added
;	06/02/2024	Zachary Pestrikov	speaker constants finalized
;	06/03/2024	Zachary Pestrikov	spi and imu constants added
;	06/04/2024	Zachary Pestrikov	spi and imu constants finalized
;	06/05/2024	Zachary Pestrikov	documentation added



; Port B initialization
.EQU    DDRBinit    = 0b00100111    ; Port B inputs and outputs

; Speaker/Speaker Timer Initialization
.EQU    TCCR1Ainit  = 0b01000000    ; Set com1a to 01 for the timer counter
.EQU    TCCR1Binit  = 0b00001011    ; Initialize square waveform and 64 prescaler

; Speaker Consts
.EQU    SpeakerBit  = 5             ; Speaker is bit 5 in port B
.EQU    CLOCK_FRQ_FACTORlow = 0b00100100   ; Low byte of the frequency factor(8000000 / 2 / prescaler)
.EQU    CLOCK_FRQ_FACTORhigh = 0b11110100  ; High byte of the frequency factor(8000000 / 2 / prescaler)

; SPI Consts
.EQU    SlaveSelect = 0
.EQU    TRANSMIT    = 0b01111111  ; anded to transmit
.EQU    RECIEVE     = 0b10000000    ; ORED to recieve
.EQU    SPCRinit    = 0b01011101
.EQU    TXCOMPLETE  = 0b10000000    ; the spsr spif flag is set to indicate a transfer has completed
.EQU    DD_MOSI     = 2 ; portb2 is mosi
.EQU    DD_SCK      = 1 ; portb1 is sck


;   IMU Consts
.EQU    IMUconfig   =   0x1A    ; configuration register addr
.EQU    AccelConfig1    =   0x1C    ; first Acceleration configuration address
.EQU    AccelConfig2    =   0x1D    ; second acceleration configuration address
.EQU    ACCEL_XOUT_H    =   59    ; x-axis accel high register addr
.EQU    ACCEL_XOUT_L    =   60    ; x-axis accel low register addr
.EQU    ACCEL_YOUT_H    =   61    ; Y-axis accel high register addr
.EQU    ACCEL_YOUT_L    =   62    ; Y-axis accel low register addr
.EQU    ACCEL_ZOUT_H    =   63    ; Z-axis accel high register addr
.EQU    ACCEL_ZOUT_L    =   64    ; Z-axis accel low register addr
