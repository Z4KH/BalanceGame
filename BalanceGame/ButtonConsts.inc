; This file contains the hardware definitions for the timer and ports.
;
; Revision History:
;    12/09/12  Glen George      initial revision
;     9/21/13  Glen George      changed fractional part from .1085 to .10852
;     9/21/13  Glen George      updated comments
;     4/20/18  Glen George      updated to match new hardware
;     5/02/18  Glen George      created from original clock.inc file
;     8/25/18  Glen George      added Timer 0 values
;     4/02/19  Glen George      removed PORTD_DIR, not needed in new hardware
;     5/04/24  Zachary Pestrikov    added file to project
;     5/05/24  Zachary Pestrikov    edited constants
;     5/06/24  Zachary Pestrikov    removed unnecessary definitions and added initCCW

; I/O port definitions

.EQU    INDATA     = 0b00000000		;data direction 0 is input

; Additional Constants
.EQU    INITCCW      = 0b11100001    ; full CCW rotation starting with 01

; Timer consts
.EQU    DEBOUNCE_TIME   =   80  ;  20ms

; button consts
.EQU INIT_BUTTONS_STATE = 0xC0 ; Set initial rotary encoder state as 11, all other vars to 0




  
