	; **********************************
	;  File: encrypt.s
	;  Programmer: Zach Souser
	;  Description: Outputs a 4-bit word
	;	represented in hex, encrypts 
	;	it and decrypts it, and shows
	; 	to the user that it is the same
	;	after the decryption process
	;  Project: encrypt.arj               
	;  Date: October 24, 2012
	;************************************
		AREA encrypt, CODE, READONLY
		ENTRY
SWI_WriteC	EQU	&0
SWI_Exit	EQU	&11
		ADR	r5, String	; load address of string
loop		LDR 	r0, [r5], #32	; load 4-byte word
		TEQ	r0, #0		; check for end
		SWIEQ	SWI_Exit	; exit
		STMFD	sp!, {r0}	; store r0
		BL	Print		; print
		= &0a, &0d, "The original word:", 0
		ALIGN
		LDMFD	sp!, {r0}	; load r0
		MOV	r1, r0		; prepare r0 to be printed
		STMFD	sp!, {r0}	; store r0
		BL	PrintHex	; print
		LDMFD	sp!, {r0}	; load r0
		BL	Encrypt		; encrypt
		STMFD	sp!, {r0}	; store r0
		BL	Print		; print
		= &0a, &0d, "The encrypted word:", 0
		ALIGN
		LDMFD	sp!, {r0}	; load r0
		MOV	r1, r0		; prepare r0 to be pritned
		STMFD	sp!, {r0}	; store r0
		BL	PrintHex	; print
		LDMFD	sp!, {r0}	; store r0
		BL	Decrypt		; decrypt
		STMFD	sp!, {r0}	; store r0
		BL	Print		; print
		= &0a, &0d, "The decrypted word:", 0
		ALIGN
		LDMFD	sp!, {r0}	; restore r0
		MOV	r1, r0		; prepare word to be printed
		BL	PrintHex	; print the decrypted word
		ADD	r5, r5, #3	; move to next word boundary
		BIC	r5, r5, #3	; round the boundary
		BL	loop		; loop
Permute		LDR 	r1, Mask1	; load Mask1
		AND 	r1, r1, r0	; mask r1
		LDR 	r2, Mask2	; load Mask2
		AND 	r2, r2, r0	; mask r2
		LDR 	r3, Mask3	; load Mask3
		AND 	r3, r3, r0	; mask r3
		LDR 	r4, Mask4	; load Mask4
		AND 	r4, r4, r0	; mask r4
		MOV 	r1, r1, LSR #24	; shift r1
		MOV 	r2, r2, LSR #8	; shift r2
		MOV 	r3, r3, LSL #8	; shift r3
		MOV 	r4, r4, LSL #24	; shift r4
		MOV	r0, #0		; clear r0
		ORR 	r0, r0, r1	; pack r1
		ORR 	r0, r0, r2	; pack r2
		ORR 	r0, r0, r3	; pack r3
		ORR 	r0, r0, r4	; pack r4
		MOV	pc, r14		; return	
Encrypt		STMFD	sp!, {r14}	; store lr
		BL	Permute		; permute
		LDR	r1, Key		; load key	
		EOR 	r0, r1, r0	; encrypt
		LDMFD	sp!, {r14}	; restore lr
		MOV	pc, r14		; return
Decrypt		STMFD	sp!, {r14}	; store lr
		LDR	r2, Key		; load key
		EOR	r0, r2, r0	; decrypt
		BL	Permute		; permute
		LDMFD	sp!, {r14}	; restore lr
		MOV	pc, r14		; return
Print		LDRB	r0,[r14], #1	; get a character
		CMP 	r0, #0		; end mark NUL?
		SWINE 	SWI_WriteC	; if not, print
		BNE	Print		; loop
		ADD	r14, r14, #3	; pass next word boundary
		BIC	r14, r14, #3	; round back to boundary
		MOV	pc, r14		; return
PrintHex	MOV	r2,#8		; count of nibbles = 8
HEXLOOP		MOV	r0,r1,LSR #28	; get top nibble
		CMP 	r0, #9		; hexanumber 0-9 or A-F
		ADDGT 	r0,r0, #"A"-10	; ASCII alphabetic
		ADDLE 	r0,r0, #"0"	; ASCII numeric
		SWI 	SWI_WriteC	; print character
		MOV	r1,r1,LSL #4	; shift left one nibble
		SUBS	r2,r2, #1	; decrement nibble count
		BNE	HEXLOOP		; if more nibbles,loop back
		MOV 	pc, r14		; return
Key		DCD 	&FFDAA66D
String		= 	"Yesterday, all my troubles seemed so far away", 0
Mask1		DCD 	&FF000000
Mask2		DCD 	&00FF0000
Mask3		DCD 	&0000FF00
Mask4		DCD 	&000000FF
		END