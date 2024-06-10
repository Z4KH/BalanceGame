;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   SEGTABLE                                 ;
;                           Tables of 7-Segment Codes                        ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains tables of 7-segment codes.  The segment ordering is
; given below.  The tables included are:
;    ASCIISegTable - table of codes for 7-bit ASCII characters
;    DigitSegTable - table of codes for hexadecimal digits
;
; Revision History:
;     5/18/24  auto-generated           initial revision
;     5/18/24  Glen George              added DigitSegTable
;	  5/18/24  Zachary Pestrikov 		added LEDBitDecodingTable



; local include files
;    none




;table is in the code segment
        .cseg



; DigitSegTable
;
; Description:      This is the segment pattern table for hexadecimal digits.
;                   It contains the active-high segment patterns for all hex
;                   digits (0123456789AbCdEF).  None of the codes set the
;                   decimal point.  
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Glen George
; Last Modified:    May 18, 2024

DigitSegTable:


;        DB       gfeedcba    gfeedcba   ; Hex Digit

        .DB     0b01111111, 0b00000110   ; 0, 1
        .DB     0b10111011, 0b10001111   ; 2, 3
        .DB     0b11000110, 0b11001101   ; 4, 5
        .DB     0b11111101, 0b00000111   ; 6, 7
        .DB     0b11111111, 0b11000111   ; 8, 9
        .DB     0b11110111, 0b11111100   ; A, b
        .DB     0b01111001, 0b10111110   ; C, d
        .DB     0b11111001, 0b11110001   ; E, F


LEDBitDecodingTable:	; table that stores the bit of Led in an LED group
						; the LEDs go from left to right in their byte
;        DB       binary	binary	     ; LED number(left to right)

        .DB     0b10000000, 0b01000000   ; 0, 1
        .DB     0b00100000, 0b00010000   ; 2, 3
        .DB     0b00001000, 0b00000100   ; 4, 5
        .DB     0b00000010, 0b00000001   ; 6, 7
