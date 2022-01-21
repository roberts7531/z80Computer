;==================================================================================
; Contents of this file are copyright Grant Searle
; HEX routines from Joel Owens.
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; http://searle.hostei.com/grant/index.html
;
; eMail: home.micros01@btinternet.com
;
; If the above don't work, please perform an Internet search to see if I have
; updated the web page hosting service.
;
;==================================================================================

;------------------------------------------------------------------------------
;
; Z80 Monitor Rom
;
;------------------------------------------------------------------------------
; General Equates
;------------------------------------------------------------------------------

CR		.EQU	0DH
LF		.EQU	0AH
ESC		.EQU	1BH
CTRLC		.EQU	03H
CLS		.EQU	0CH

; CF registers
CF_DATA		.EQU	$10

CF_ERROR	.EQU	$11
CF_SECCOUNT	.EQU	$12
CF_SECTOR	.EQU	$13
CF_CYL_LOW	.EQU	$14
CF_CYL_HI	.EQU	$15
CF_HEAD		.EQU	$16
CF_STATUS	.EQU	$17
CF_COMMAND	.EQU	$17
CF_LBA0		.EQU	$13
CF_LBA1		.EQU	$14
CF_LBA2		.EQU	$15
CF_LBA3		.EQU	$16

;CF Features

C
;CF Commands
CF_READ_SEC	.EQU	020H
CF_WRITE_SEC	.EQU	030H



loadAddr	.EQU	0D000h	; CP/M load address
numSecs		.EQU	24	; Number of 512 sectors to be loaded


;BASIC cold and warm entry points
BASCLD		.EQU	$2000
BASWRM		.EQU	$2003

SER_BUFSIZE	.EQU	40H
SER_FULLSIZE	.EQU	30H
SER_EMPTYSIZE	.EQU	5

RTS_HIGH	.EQU	0E8H
RTS_LOW		.EQU	0EAH


CON		.EQU	$01
STATUSIN		.EQU	$00
STATUSOUT		.EQU	$02

		.ORG	$9000
serBuf		.ds	SER_BUFSIZE
serInPtr	.ds	2
serRdPtr	.ds	2
serBufUsed	.ds	1


secNo		.ds	1
dmaAddr		.ds	2

stackSpace	.ds	32
STACK   	.EQU    $	; Stack top


;------------------------------------------------------------------------------
;                         START OF MONITOR ROM
;------------------------------------------------------------------------------

MON		.ORG	$0000		; MONITOR ROM RESET VECTOR
;------------------------------------------------------------------------------
; Reset
;------------------------------------------------------------------------------
RST00		DI			;Disable INTerrupts
		jp INIT


		.ORG 0008H
		jp conout
		.ORG 0010H
		jp conin
		.ORG 0018H
		jp CKINCHAR
		.ORG 0038H
		jp serialInt
		

;------------------------------------------------------------------------------
; Serial interrupt handlers
; Same interrupt called if either of the inputs receives a character
; so need to check the status of each SIO input.
;------------------------------------------------------------------------------
serialInt:	PUSH     AF
                ld a,1
                out ($02),a
                PUSH     HL

intl:           IN A,($00)
                AND $2
                JP Z,intl
		

serialIntA:
		LD	HL,(serInPtr)
		INC	HL
		LD	A,L
		CP	(serBuf+SER_BUFSIZE) & $FF
		JR	NZ, notAWrap
		LD	HL,serBuf
notAWrap:
		LD	(serInPtr),HL
		IN	A,($01)
		LD	(HL),A

		LD	A,(serBufUsed)
		INC	A
		LD	(serBufUsed),A
		CP	SER_FULLSIZE
		JR	C,rtsA0
	        
rtsA0:
		POP	HL
		ld a,0
                out ($02),a
		POP	AF
		EI
		RETI

;------------------------------------------------------------------------------
; Console input routine
; Use the "primaryIO" flag to determine which input port to monitor.
;------------------------------------------------------------------------------


conin:
		PUSH	HL
		
coninA:

waitForCharA:
		LD	A,(serBufUsed)
		CP	$00
		JR	Z, waitForCharA
		LD	HL,(serRdPtr)
		INC	HL
		LD	A,L
		CP	(serBuf+SER_BUFSIZE) & $FF
		JR	NZ, notRdWrapA
		LD	HL,serBuf
notRdWrapA:
		DI
		LD	(serRdPtr),HL

		LD	A,(serBufUsed)
		DEC	A
		LD	(serBufUsed),A

		
rtsA1:
		LD	A,(HL)
		EI

		POP	HL

		RET	; Char ready in 
;------------------------------------------------------------------------------
; Console output routine
; Use the "primaryIO" flag to determine which output port to send a character.
;------------------------------------------------------------------------------
conout:		PUSH AF
TXALOOP1:       IN A,($00)
                AND $4
                JP Z,TXALOOP1
TXALOOP:        IN A,($00)
                AND $1
                JP NZ,TXALOOP
                POP AF; Retrieve character
                OUT      ($01),A         ; Output the character
                RET


;------------------------------------------------------------------------------
; Check if there is a character in the input buffer
; Use the "primaryIO" flag to determine which port to check.
;------------------------------------------------------------------------------
CKINCHAR
		LD	A,(serBufUsed)
		CP	$0
		RET


;------------------------------------------------------------------------------
; Filtered Character I/O
;------------------------------------------------------------------------------

RDCHR		RST	10H
		CP	LF
		JR	Z,RDCHR		; Ignore LF
		CP	ESC
		JR	NZ,RDCHR1
		LD	A,CTRLC		; Change ESC to CTRL-C
RDCHR1		RET

WRCHR		CP	CR
		JR	Z,WRCRLF	; When CR, write CRLF
		CP	CLS
		JR	Z,WR		; Allow write of "CLS"
		CP	' '		; Don't write out any other control codes
		JR	C,NOWR		; ie. < space
WR		RST	08H
NOWR		RET

WRCRLF		LD	A,CR
		RST	08H
		LD	A,LF
		RST	08H
		LD	A,CR
		RET


;------------------------------------------------------------------------------
; Initialise hardware and start main loop
;------------------------------------------------------------------------------
INIT		ld a,0
		out ($02),a
		LD   SP,STACK		; Set the Stack Pointer

		LD	HL,serBuf
		LD	(serInPtr),HL
		LD	(serRdPtr),HL


		xor	a			;0 to accumulator
		LD	(serBufUsed),A

		IM	1
		EI
.END
