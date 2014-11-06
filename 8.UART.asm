UART_BUSY	BIT	00h
SPK		EQU	P3.7
PROG		EQU	0000h

		ORG	PROG+0000h
		SJMP	START
		ORG	PROG+0023h
		LCALL	UART_ISR
		RETI
		;
		ORG	PROG+0030h
START:
		CLR	UART_BUSY
        	MOV     TMOD, #00100001b	; Timer1 in Mode 2, Timer0 in Mode 1
      	 	MOV     TH1, #0FDh		; Baud Rate = 9600 bps at 11.0592MHz
	      	MOV     SCON, #01010000b	; UART in Mode 1
		SETB	ES			; Enable UART Interrupt
		SETB	EA			; Enable Interrupt
		SETB	TR1			; Start Timer 1
LOOP:
		JNB	P3.2,SEND
		SJMP	LOOP
SEND:		CALL	DE
		JNB	P3.2, $
		MOV	A,P0
		CALL	UART_PUTC
		JMP	LOOP
;
UART_ISR:
        	JB      RI, RECEIVED
TRANSMITTED:
		CLR	UART_BUSY
        	CLR     TI
        	RET
RECEIVED:
		MOV	A, SBUF
		CPL	A
		CJNE	A,P0,BEEP
		MOV	R0, #3
FLASH:
		MOV	P1,#00h
		LCALL	DELAY
		MOV	P1,#0FFh
		LCALL	DELAY
		DJNZ	R0,FLASH
		JMP	FINISH
BEEP:
		CALL	BZ
FINISH:		CLR     RI
		RET


;
UART_PUTC:
		JB	UART_BUSY, UART_PUTC
		SETB	UART_BUSY
		MOV	SBUF, A
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

DELAY:		MOV	R5,#20	;R5*20 mS
D1:     	MOV	R6,#40
D2:     	MOV	R7,#249
		DJNZ	R7,$
 		DJNZ	R6,D2
  		DJNZ	R5,D1
   		RET
        	END