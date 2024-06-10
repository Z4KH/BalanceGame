; Div16
;
;
; Description:       This function divides the 16-bit unsigned value passed in
;                    R17|R16 by the 16-bit unsigned value passed in R21|R20.
;                    The quotient is returned in R17|R16 and the remainder is
;                    returned in R3|R2.
;
; Operation:         The function divides R17|R16 by R21|R20 using a restoring
;                    division algorithm with a 16-bit temporary register R3|R2
;                    and shifting the quotient into R17|R16 as the dividend is
;                    shifted out.  Note that the carry flag is the inverted
;                    quotient bit (and this is what is shifted into the
;                    quotient) so at the end the entire quotient is inverted.
;
; Arguments:         R21|R20 - 16-bit unsigned dividend.
;                    R17|R16 - 16-bit unsigned divisor.
; Return Values:     R21|R20 - 16-bit quotient.
;                    R3|R2   - 16-bit remainder.
;
; Local Variables:   bitcnt (R22) - number of bits left in division.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Registers Changed: flags, R2, R3, R16, R17, R22
; Stack Depth:       0 bytes
;
; Algorithms:        Restoring division.
; Data Structures:   None.
;
; Known Bugs:        None.
; Limitations:       None.
;
; Revision History:   4/15/18   Glen George      initial revision
;                     6/1/24    Zachary Pestrikov   Updated Registers used

.cseg
Div16:
        LDI     R22, 16                 ;number of bits to divide into
        CLR     R3                      ;clear temporary register (remainder)
        CLR     R2

Div16Loop:                              ;loop doing the division
        ROL     R20                     ;rotate bit into temp (and quotient
        ROL     R21                     ;   into R17|R16)
        ROL     R2
        ROL     R3
        CP      R2, R16                 ;check if can subtract divisor
        CPC     R3, R17
        BRCS    Div16SkipSub            ;cannot subtract, don't do it
        SUB     R2, R16                 ;otherwise subtract the divisor
        SBC     R3, R17
Div16SkipSub:                           ;C = 0 if subtracted, C = 1 if not
        DEC     R22                     ;decrement loop counter
        BRNE    Div16Loop               ;if not done, keep looping
        ROL     R20                     ;otherwise shift last quotient bit in
        ROL     R21
        COM     R20                     ;and invert quotient (carry flag is
        COM     R21                     ;   inverse of quotient bit)
        ;RJMP   EndDiv16                ;and done (remainder is in R3|R2)

EndDiv16:                               ;all done, just return
        RET

;________________________________________________________________________________
