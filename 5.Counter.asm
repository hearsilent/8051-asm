LED_PORT	EQU	P1
SPK		EQU	P3.7
PROG		EQU	0000h

		ORG	PROG+0000h
		JMP	START
		ORG	PROG+000Bh
		LCALL	T0_ISR
		RETI
		ORG	PROG+0030h
		
START:
		MOV	TH0,#245
		MOV	TL0,#245
		MOV	TMOD,#00000110b	; Set Timer/Counter 0 to be 16-bit External Counter
		SETB	IT0		; Set External Interrupt 0 to be falling edge triggered
		SETB	ET0		; Enable Timer 0 Interrupt
		SETB	EA		; Enable Interrup
		SETB	TR0		; Turn on Counter 0
LOOP:		
		JNB	P3.2, LOOP2
		SJMP	LOOP
LOOP2:		CALL	DELAY
		JB	P3.2, LOOP
		SETB	P3.4
		CLR	P3.4
		MOV	A, TL0
		SUBB	A, #245
		MOV	R1, A
		CPL	A
		MOV	LED_PORT, A
BUZZ:	
		CJNE	R1,#0,BEEP
		SJMP	LOOP
BEEP:
		CALL	BZ
		LCALL	DE
		DJNZ	R1,BUZZ
		SJMP	LOOP

T0_ISR:		MOV	TH0, #245
		MOV	TL0, #245
		MOV	R0, #3
FLASH:		MOV	P1, #00H
		LCALL	DELAY
		MOV	P1, #0FFH
		LCALL	DELAY
		DJNZ	R0, FLASH
		MOV	R1, #0
		MOV	A, #0
		RET

BZ:		MOV	R6, #0 
B1:		CALL	DE 
		CPL	SPK
		DJNZ	R6, B1 
		RET 

DE:		MOV	R7, #180
DE1:		NOP 
		DJNZ	R7, DE1 
		RET

DELAY:		MOV	R7, #5
DEL_1:		MOV	R6, #100
DEL_2:  	MOV	R5, #100
		DJNZ	R5, $
		DJNZ	R6, DEL_2
		DJNZ	R7, DEL_1
		RET
		END