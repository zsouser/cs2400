	; **********************************
	;  File: converter.s
	;  Programmer: Zach Souser
	;  Description: A program that converts
	;  		a number (0.75) between
	;		IEEE and TNS, and compares
	;		them
	;  Project: converter.arj               
	;  Date: October 8, 2012
	;************************************

		AREA Converter, CODE, READONLY
		ENTRY
SWI_Exit	EQU &11	
		LDR r0, IEEE		; store IEEE in r0
		BL ToTNS		; r4 will contain the TNS number
		LDR r0, TNS		; load TNS into r0
		TEQ r0, r4		; compare TNS in r0 to the converted IEEE
		BEQ ToIEEE		; if successful, convert back
		LDR r0, IEEE		; load IEEE into r0
		TEQ r0, r4		; compare IEEE in r0 to the converted TNS
		BEQ Success		; branch out to test for success
		SWINE SWI_Exit		; otherwise, exit unsucceessfully
ToTNS		LDR r1, Sign		; load the sign mask
		LDR r2,	IExp		; load the exponent mask
		LDR r3, ISig		; load the significand mask
		AND r1, r1, r0		; unpack sign into r1
		AND r2, r2, r0		; unpack exponent into r2
		AND r3, r3, r0		; unpack significand into r3
		MOV r2, r2, LSR #23	; shift the exponent to the right
		ADD r2, r2, #129 	; convert exponent to EXCESS 256
		MOV r3, r3, LSR #1	; shift significand right to remove extra bit
		MOV r3, r3, LSL #9	; shift significand left
		AND r4, r4, #0 		; empty r4 to prepare for converted number
		ORR r4, r4, r1		; pack the sign bit
		ORR r4, r4, r2		; pack the exponent
		ORR r4, r4, r3		; pack the significand
		MOV pc, r14		; return
ToIEEE		LDR r1, Sign		; load the sign mask
		LDR r2, TExp		; load the exponent mask
		LDR r3, TSig		; load the significand mask
		AND r1, r1, r0		; unpack sign into r1
		AND r2, r2, r0		; unpack exponent into r2
		AND r3, r3, r0		; unpack significand into r3
		SUB r2, r2, #129	; convert from EXCESS 256 to EXCESS 127
		MOV r2, r2, LSR #1	; shorten the exponent by one bit
		MOV r2, r2, LSL #24	; shift the exponent to its new position
		MOV r3, r3, LSR #8	; shift the significand to its new position
		AND r4, r4, #0		; empty r4 to prepare for converted number
		ORR r4, r4, r1		; pack the sign bit
		ORR r4, r4, r2		; pack the exponent
		ORR r4, r4, r3		; pack the significand
		MOV pc, r14		; return
Success		SWI SWI_Exit		; Success! Yay!
IEEE		DCD &3F400000		; IEEE number
TNS		DCD &400000FF		; TNS number
Sign		DCD &80000000		; Sign mask
IExp		DCD &7F800000		; IEEE exponent mask
TExp		DCD &000001FF		; TNS exponent mask
ISig		DCD &007FFFFF		; IEEE significand mask
TSig		DCD &7FFFFE00		; TNS significand mask
		END			; goodbye!