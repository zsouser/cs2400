	; **********************************
	;  File: CountVowels.s
	;  Programmer: Zach Souser
	;  Description: A program that prints a string,
	;	prints it again with the vowels capitalized
	;	and prints the count of the vowels in the string
	;	in hexadecimal
	;  Project: CountVowels.arj               
	;  Date: October 2012
	;************************************

		AREA PrintText, CODE, READONLY
SWI_WriteC	EQU	&0     ;output character in r0 
SWI_Exit	EQU	&11    ;finish program
		ENTRY
		ADR	r3, String	; store the string
		BL	Print		; print the string un-modified
		ADR	r3, String	; re-store the string
		BL	PrintVowels	; print the string with vowels modified
		ADR	r3, String	; re-store the string
		BL	PrintCount	; print the count
		ALIGN
		SWI 	SWI_Exit	; finish
Print		LDRB	r0,[r3], #1	; get a character
		CMP 	r0, #0		; end mark NUL?
		SWINE 	SWI_WriteC	; if not, print
		BNE	Print
		ADD	r14, r14, #3	; pass next word boundary
		BIC	r14, r14, #3	; round back to boundary
		MOV	pc, r14		; return
PrintVowels	LDRB	r0,[r3], #1	; get a character	
		TEQ	r0, #"a"	; test for 'a'
		TEQNE	r0, #"e"	; test for 'e'
		TEQNE	r0, #"i"	; test for 'i'
		TEQNE	r0, #"o"	; test for 'o'
		TEQNE	r0, #"u"	; test for 'u'
		SUBEQ	r0, r0, #&20	; lower case letter found, capitalize it
		TEQNE	r0, #"A"	; test for 'A'
		TEQNE	r0, #"E"	; test for 'E'
		TEQNE	r0, #"I"	; test for 'I'
		TEQNE	r0, #"O"	; test for 'O'
		TEQNE	r0, #"U"	; test for 'U'
		ADDEQ	r1, r1, #1	; vowel found, count it
		CMP 	r0, #0		; check for end of string
		SWINE 	SWI_WriteC	; if not, print
		BNE	PrintVowels	
		ADD	r14, r14, #3	; pass next word boundary
		BIC	r14, r14, #3	; round back to boundary
		MOV	pc, r14		; return
PrintCount	MOV	r2,#8		; count of nibbles = 8
LOOP		MOV	r0,r1,LSR #28	; get top nibble
		CMP 	r0, #9		; hexanumber 0-9 or A-F
		ADDGT 	r0,r0, #"A"-10	; ASCII alphabetic
		ADDLE 	r0,r0, #"0"	; ASCII numeric
		SWI 	SWI_WriteC	; print character
		MOV	r1,r1,LSL #4	; shift left one nibble
		SUBS	r2,r2, #1	; decrement nibble count
		BNE	LOOP		; if more nibbles,loop back
		MOV 	pc, r14		; return
String		= 	"Assembly language is hard, but I like it.", &0a, &0d, 0
		END