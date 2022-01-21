;	.8080
;;	TITLE DISKSTAT DISK STATISTICS

;;	NAME ('DISKST')

;------------------------------------------------------------------
; Utility to display disc characteristics and file allocation
;
; Copyright 1983 D. Powys-Lybbe
; Author: D. Powys-Lybbe, MML Systems Ltd., London
; Date: 20th June 1983
;
;------------------------------------------------------------------
; Revisions
; =========
;
; 2015-05-08 John Elliott: Started with the published 1.0 source and 
;           altered it until it builds the version distributed by PCW PD, 
;           which I have called 1.1.
;
; 2015-05-09 John Elliott: Converted to 8080 mnemonics (RMAC syntax) using 
;           XZI, and tidied up by hand. Added a header preventing DISKSTAT 
;           from being run under DOS, plus configurable escape codes.
;
;------------------------------------------------------------------

;------------------------------------------------------------------------
	PAGE


	PUBLIC DEF$DSK,DPB,DPH2,DPH3,DPB$PTR,DPH$PTR,VERS,VERS$REL,VERS$OS
	PUBLIC SAVESP
	PUBLIC BADSEL,SELMSG,BADVERS,VERMSG,BIOS,BADBIOS,JMPMSG
	PUBLIC BIOSPB,BIOS$FUNC,BIOS$AREG,BIOS$BCREG,BIOS$DEREG,BIOS$HLREG
	PUBLIC WAITCR,WAITBUFF,WAITLEN,FETCHDP
	PUBLIC CLEARSCRN,CSNMSG,SCREEN1,S1MSG,S1DSK
	PUBLIC OPTION,OPTQUIT,OPTMSG,OPTBUF,OPTLEN,OPTCHR
	PUBLIC MAKEHEX,WRDHEX,DBLHEX,BYTHEX,NBLHEX,TESTHEX,NEXTHEX
	PUBLIC  HEXCHR,HEXTXT
	PUBLIC MAKEDEC,DEC2,ERRDEC,GIGDEC,MEGDEC,WRDDEC,BYTDEC,TXTDEC,ZROBCD
	PUBLIC TOBCD,BCD,TESTDEC,NEXTDEC,DECCHR,DECTXT
	PUBLIC MAKEMAX,MAKEM1,MAKEM2,MAKEM3,MAKEM4,MAKEM5,MAKEM6,MAKEM8
	PUBLIC MAKEM7,MAKEM9,MAKE01,MAKE02,MAKE03,MAKE04,MAKEM0
	PUBLIC MAKEDIR,DIRDB,DBSIZE,MAKED0,MAKED1,MAKED2,MAKED3,MAKED4
	PUBLIC MAKEDAT,MAKED5,MAKED6
	PUBLIC MAKETOT,MAKED7,MAKED8
	PUBLIC MMEGX8,MMEGX4,MMEGX2,MGIGX8,MGIGX4,MGIGX2,MGIGX128
	PUBLIC SHOWBLK,POSN,SDBMSG,SDBDSK,SDBHEX,SDBDEC,SDBMAX
	PUBLIC SDBDIR,SDBDAT,SDBTOT
	PUBLIC SHOWHDR
	PUBLIC SHOWALV,SALMSG,SALDSK
	PUBLIC SHOWFIL,SFLMSG,SFLDSK
	PUBLIC SHOWDIR,SDRMSG,SDRDSK
	PUBLIC GOODVERS,USECCP,MAIN,TASK1,TABLE1,RETURN


;------------------------------------------------------------------------
	PAGE

;		===============
;		DISC DATA AREAS
;		===============

;--------------------------------------------------------------
;
; CP/M disc parameters
;
;--------------------------------------------------------------

	DSEG
DEF$DSK:DB	0		; Selected disc

DPB:				; Drive disk parameter block
DPB$SPT:DS	2
DPB$BSH:DS	1
DPB$BLM:DS	1
DPB$EXM:DS	1
DPB$DSM:DS	2
DPB$DRM:DS	2
DPB$AL0:DS	1
DPB$AL1:DS	1
DPB$CKS:DS	2
DPB$OFF:DS	2
LEN$DPB2 EQU	$-DPB		; length of CP/M 2 dpb
DPB$PSH:DS	1
DPB$PHM:DS	1
LEN$DPB3 EQU	$-DPB		; length of CP/M + dpb

DPH2:				; CP/M 2 disk parameter header
DPH2$XLT:
	DS	2
DPH2$ZRO:
	DS	6
DPH2$DIR:
	DS	2
DPH2$DPB:
	DS	2
DPH2$CSV:
	DS	2
DPH2$ALV:
	DS	2
LEN$DPH2 EQU	$-DPH2		; length of CP/M 2 dph

DPH3:				; CP/M + disk parameter header
DPH3$XLT:
	DS	2
DPH3$ZRO:
	DS	9
DPH3$MF:DS	1
DPH3$DPB:
	DS	2
DPH3$CSV:
	DS	2
DPH3$ALV:
	DS	2
DPH3$DIR:
	DS	2
DPH3$DAT:
	DS	2
DPH3$HSH:
	DS	2
DPH3$BNK:
	DS	1
LEN$DPH3 EQU	$-DPH3		; length of CP/M + dph
	DW	0,0,0,0,0
	DB	0

DPB$PTR:DW	0		; address of dpb
DPH$PTR:DW	0		; address of dph

VERS:				; O.S. Version number
VERS$REL:
	DS	1		; O.S. Version/Release number
VERS$OS:DS	1		; O.S. number

POSN:	DW	0		; pointer to text string

; ------;
; stack ;
; ------;
	DS	64		; dont know how much stack BIOS requires
SAVESP:	DW	0

; ----------------;
; address equates ;
; ----------------;
	
BDOS	EQU	5		; BDOS entry point
DEFFCB	EQU	5CH		; CCP puts default FCB here
DEFDMA	EQU	80H		; CCP sets default DMA here

; -----------------;
; constant equates ;
; -----------------;
	
BS	EQU	08H		; <BACK SPACE>
CR	EQU	0DH		; <RETURN>
LF	EQU	0AH		; <LINE FEED>
JUMP	EQU	0C3H		; JP instruction

	CSEG

;-------------------------------------------------------------------------;
	PAGE


;-------;
; start ;
;-------;
	CSEG

;
; [1.2] Add a header to terminate gracefully if run under DOS.
;
	DB	0EBh, 04h	; JMPS +04
	XCHG
	JMP	ENTRY
	DB	0B4h, 09h	; MOV AH, C_WRITESTR
	DB	0BAh		; MOV DX, 
	DW	VERMSG		;	  VERMSG
	DB	0CDh, 021h	; INT 21h
	DB	0CDh, 020h	; INT 20h

	DB	CR,'MML DISKSTAT 1.2 (8080)',cr,lf
	DB	'Date: 2015-05-09',cr,lf
	DB	1Ah

;
; Terminal customisation area
;
DOT:	DB	'.'		; Empty space
BLOCK:	DB	'#'		; Directory block
SOLID:	DB	'+'		; Data block
HOLLOW:	DB	'-'		; Erased block
CLS:	DB	'$',0,0,0,0,0,0,0	; Clear screen string
;
ENTRY:	LDA	DOT
	STA	DOT1
	LDA	BLOCK
	STA	BLOCK1
	LDA	HOLLOW
	STA	HOLLO1
	LDA	SOLID
	STA	SOLID1

	LXI	D,CLS		; If there is a clear-screen message,
	LXI	H,CSNMSG	; copy it over csnmsg
	LDAX	D
	CPI	'$'		; If it's blank (first character is $)
	JZ	CCLS1		; then don't.

CPYCLS:	LDAX	D
	MOV	M,A
	CPI	'$'
	JZ	CCLS1
	INX	H
	INX	D
	JMP	CPYCLS
CCLS1:

;
; If this is run on a Z80, optimise LDIR.
;
	SUB	A
	JPE	IS080
	LXI	H,0B0EDh	; Replace the LDIR subroutine 
	SHLD	LDIR		; with LDIR ; RET
	MVI	A,0C9h
	STA	LDIR+2
IS080:
;
; End of 1.2 initialisation code
;
	MVI	C,12		; BDOS: RETURN VERSION NUMBER
	CALL	BDOS
	SHLD	VERS
	MOV	A,H
	CPI	00H		; check for CP/M
	JNZ	NOTCPM		; [1.1] Check for MP/M
;
	MOV	A,L
	CPI	22H
	JZ	GOODVERS
;
	MOV	A,L
	CPI	31H
	JZ	GOODVERS
	JMP	BADVERS
;
NOTCPM:	CPI	1		; [1.1] MP/M?
	JNZ	BADVERS
	MOV	A,L
	CPI	30H		; MP/M II?
	JZ	GOODVERS
	JMP	BADVERS
;
	PAGE
				; ================= ;
				; various utilities ;
				; ================= ;

; -------------- ;
; Error routines ;
; -------------- ;

BADSEL:
	LXI	D,SELMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	MVI	C,0		; BDOS: SYSTEM RESET
	JMP	BDOS		; and crash out

	DSEG
SELMSG:	DB	'FATAL ERROR - Unable to select drive','$'
	CSEG

BADVERS:
	LXI	D,VERMSG
	MVI	C,9		; BDOS: PRINT STRING
	JMP	BDOS		; & RETURN
	DSEG
VERMSG:	DB	'MUST USE CP/M 2.2, MP/M 3.0 OR CP/M 3.1','$' ; [1.1]
	CSEG
;
; Emulate the Z80's LDIR instruction
;
LDIR:	PUSH	PSW
LDIR1:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	LDIR1	
	POP	PSW
	RET
;
; --------------------------- ;
; Direct calls to CP/M 2 BIOS ;
; --------------------------- ;

BIOS:
	PUSH	D		; must save DE as sometimes passed to BIOS
	XCHG
	LHLD	1		; pointer to BIOS WARM BOOT
	MOV	A,M
	CPI	JUMP		; check actually pointing to BIOS (not XSUB)
	JNZ	BADBIOS
	DAD	D		; DE = offset from WARM BOOT to BIOS function
	POP	D
	MOV	A,M
	CPI	JUMP		; check actually pointing to BIOS (not XSUB)
	JNZ	BADBIOS
	PCHL

BADBIOS:			; (NOTE DE may be on stack)
	LXI	D,JMPMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	MVI	C,0		; BDOS: SYSTEM RESET
	JMP	BDOS		; and crash out

	DSEG
JMPMSG:	DB	'FATAL ERROR - Unable to find BIOS','$'
	CSEG


; --------------------------- ;
; Direct calls to CP/M 3 BIOS ;
; --------------------------- ;

	DSEG
BIOSPB:
BIOS$FUNC:
	DS	1		; BIOS function number (WARM BOOT = 1)
BIOS$AREG:
	DS	1		; A register contents
BIOS$BCREG:
	DS	2		; BC register contents
BIOS$DEREG:
	DS	2		; DE register contents
BIOS$HLREG:
	DS	2		; HL register contents
	CSEG


	PAGE

; ------------------------------ ;
; Conversion into HEX characters ;
; ------------------------------ ;

;-----------------------------------------------------------------------;
; HEXBYT								;
; Input:	<B> = Count of bytes to be converted			;
;		<HL> -> first byte to be translated			;
;		POSN = pointer to text field				;
; Destroys:	All registers						;
; Function:	Converts <B> bytes starting at <HL> into 2 digit	;
;		hexadecimal characters which are added to next		;
;		hexadecimal field in the text string. POSN is updated	;
;		to point to the end of this hexadecimal field.		;
;-----------------------------------------------------------------------;

;-----;
HEXBYT:
;-----;
	PUSH	H
	PUSH	B
	MOV	A,M
	CALL	BYTHEX
	POP	B
	POP	H
	INX	H
	DCR	B
	JNZ	HEXBYT
;	# DJNZ HEXBYT
	RET

;-----------------------------------------------------------------------;
; HEXTBL								;
; Input:	<B> = Count of bytes to be converted			;
;		<HL> -> start of array of <B> byte to be translated	;
;		<DE> -> start of table of conversion formats		;
;			1 = single byte					;
;			2 = pair of bytes to be combined as one word	;
;			3 = pair of bytes to reversed in text fields	;
;		POSN = pointer to text field				;
; Destroys:	All registers						;
; Function:	Converts <B> bytes starting at <HL> according to	;
;		format type in table pointed at by <DE>. Each entry	;
;		in the table <DE> corresponds to field positions.	;
;-----------------------------------------------------------------------;

;-----;
HEXTBL:	
;-----;
	LDAX	D
	PUSH	D
	CPI	2
	JZ	HEXTBL2
	CPI	3
	JZ	HEXTBL3

; byte
	MOV	A,M
	PUSH	B
	PUSH	H
	CALL	BYTHEX
	JMP	NXTTBL

; word
HEXTBL2:
	DCR	B		; decrement <B> as using two bytes
	PUSH	B
	MOV	E,M
	INX	H
	MOV	D,M
	PUSH	H
	XCHG
	CALL	WRDHEX		; <HL> -> text
	JMP	NXTTBL

; double byte
HEXTBL3:
	DCR	B		; decrement <B> as using two bytes
	PUSH	B
	INX	H
	MOV	A,M		; display 2nd byte first
	DCX	H
	PUSH	H
	CALL	BYTHEX
	POP	H
	MOV	A,M		; display 1st byte next
	INX	H
	PUSH	H
	CALL	BYTHEX

NXTTBL:	POP	H
	POP	B
	POP	D
	INX	D
	INX	H
	DCR	B
	JNZ	HEXTBL
;	# DJNZ HEXTBL
	RET

;-----------------------------------------------------------------------;
; WRDHEX								;
; Input:	<HL>  = word to converted into hexadecimal text		;
;		POSN = pointer to text field				;
; Destroys:	All registers						;
; Function:	Converts word in <HL> into four hexadecimal characters	;
;		which are added to next hexadecimal field in the	;
;		text string. POSN is updated to point to the end	;
;		of this hexadecimal field.				;
;-----------------------------------------------------------------------;

;-----;
WRDHEX:				; display hex word in <HL> into text
;-----;

	PUSH	H		; must preserve HL
	CALL	NEXTHEX		; returns DE -> 'h'
	DCX	D
	DCX	D
	DCX	D
	DCX	D
	POP	H
	PUSH	H
	MOV	A,H
	CALL	OUTNBL
	POP	H
	MOV	A,L
	CALL	OUTNBL
	RET

;-----------------------------------------------------------------------;
; DBLHEX								;
; Input:	<HL>  = word to converted into hexadecimal text		;
;		POSN = pointer to text field				;
; Destroys:	All registers						;
; Function:	Converts word in <HL> into two pairs of hexadecimal	;
;		characters with the high byte displayed first. Each is	;
;		added to the next hexadecimal field in the text string.	;
;		POSN is updated to point to the end of the second	;
;		is hexadecimal field.					;
;-----------------------------------------------------------------------;

;-----;
DBLHEX:				; display high hex byte into text
;-----;
	MOV	A,H
	PUSH	H
	CALL	BYTHEX
	POP	H
				; display high hex byte into text
	MOV	A,L
	JMP	BYTHEX

;-----------------------------------------------------------------------;
; BYTHEX								;
; Input:	<A>  = byte to converted into hexadecimal text		;
;		POSN = pointer to text field				;
; Destroys:	All registers						;
; Function:	Converts byte in <A> into two hexadecimal characters	;
;		which are added to next hexadecimal field in the	;
;		text string. POSN is updated to point to the end	;
;		of this hexadecimal field.				;
;-----------------------------------------------------------------------;

;-----;
BYTHEX:				; converts byte in <A> into hexadecimal text
;-----;
	PUSH	PSW
	CALL	NEXTHEX		; returns DE -> 'h'
	DCX	D
	DCX	D
	POP	PSW
	CALL	OUTNBL
	RET

;-----;
OUTNBL:				; convert byte in <A> into two hex chars at <DE>
;-----;
	PUSH	PSW
	RRC
	RRC
	RRC
	RRC
	CALL	NBLHEX
	POP	PSW
;-----;
NBLHEX:				; convert nibble in A into hex char in (DE)
;-----;
	ANI	0FH
	MOV	C,A
	MVI	B,0
	LXI	H,HEXTXT
	DAD	B
	MOV	A,M
	STAX	D
	INX	D
	RET

;-----------------------------------------------------------------------;
; NEXTHEX								;
; Input:	POSN = pointer to text field				;
; Returns:	<DE> -> to end of hexadecimal filed			;
; Destroys:	<A>, <BC>, <HL> 					;
; Function:	Starting at location (POSN), scans text for hexadecimal ;
;		field of the form ??h or ????h where ? is any valid	;
;		hexadecimal character (0123456789ABCDEF). POSN is	;
;		updated to point to the end of this hexadecimal field.	;
;-----------------------------------------------------------------------;


TESTHEX:
	CPI	CR		; check if end of line, as must not pass this
	RZ			; even if this means overwriting text.

;------;
NEXTHEX:			; find next hex location in text
;------;

	CALL	HEXCHR		; find first hex character
	JNZ	TESTHEX
	CALL	HEXCHR		; find second hex character
	JNZ	TESTHEX
	INX	D
	LDAX	D
	CPI	'h'
	JNZ	TESTHEX
	RET

HEXCHR:	LHLD	POSN
	INX	H
	MOV	A,M
	MOV	D,H
	MOV	E,L
	CPI	CR		; test for end of line
	RZ
	SHLD	POSN		; update POSN
	LXI	H,HEXTXT
	MVI	B,16
NXT1:	CMP	M
	RZ
	INX	H
;	# DJNZ NXT1
	DCR	B
	JNZ	NXT1
	ORI	-1
	RET
	DSEG
HEXTXT:	DB	'0123456789ABCDEF'
	CSEG

	PAGE
				; ================= ;
				; various functions ;
				; ================= ;


; ------------------------------ ;
; Wait for <RETURN> for keyboard ;
; ------------------------------ ;

WAITCR:
	LXI	D,CRMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	MVI	C,10		; DIRECT CONSOLE BUFFER
	LXI	D,WAITBUFF
	CALL	BDOS
	LDA	WAITLEN
	ORA	A
	RZ
	JMP	WAITCR

	DSEG
CRMSG:	DB	CR,LF,'Hit <RETURN> to continue ','$'
WAITBUFF:
	DB	1
WAITLEN:
	DS	1
	DS	1
	CSEG


; ---------------------------- ;
; Fetch DPH and DPB for device ;
; ---------------------------- ;

FETCHDP:
	CALL	GETDPB

	LDA	VERS$REL
	CPI	22H
	CZ	GETDPH2

	LDA	VERS$REL
	CPI	31H
	CZ	GETDPH3

	RET

; ---------------- ;
; Fetch CP/M 2 DPH ;
; ---------------- ;

GETDPH2:

	LDA	DEF$DSK		; Current selected disk
	MOV	C,A		; BIOS: Disk drive to select
	MVI	E,-1		; Not first time login
	LXI	H,001BH-0003H	; offset from WARM BOOT to select function
	CALL	BIOS
	MOV	A,L
	ORA	H
	JZ	BADSEL

	SHLD	DPH$PTR		; save address of DPH
	LXI	D,DPH2
	LXI	B,LEN$DPH2
;;;	# LDIR
	CALL	LDIR
	RET

; ---------------- ;
; Fetch CP/M + DPH ;
; ---------------- ;

GETDPH3:

	LDA	DEF$DSK		; Current selected disk
	STA	BIOS$BCREG	; save in BIOSPB

	LXI	H,-1		; Not first time login
	XCHG			; XXX No need for XCHG here
	SHLD	BIOS$DEREG	; save in BIOSPB
	XCHG			; XXX No need for XCHG here

	MVI	A,9		; BIOS: select the sepcified disk drive
	STA	BIOS$FUNC	; save in BIOSPB

	MVI	C,50		; BDOS: DIRECT BIOS CALL
	LXI	D,BIOSPB	; BIOS parameter block
	CALL	BDOS		; IMPORTANT: dont trace this as BDOS
				; copies DPH into keyboard character buffer
	MOV	A,L		; BDOS returns address of its copy of DPH
	ORA	H
	JZ	BADSEL

	SHLD	DPH$PTR		; save address of DPH but this is of no value
	LXI	D,DPH3
	LXI	B,LEN$DPH3
;;;	# LDIR
	CALL	LDIR

	RET

; --------- ;
; Fetch DPB ;
; --------- ;

GETDPB:

	MVI	C,31		; BDOS: GET ADDR (DPB PARMS)
	CALL	BDOS

	SHLD	DPB$PTR		; save address of DPB
	LXI	D,DPB
	LXI	B,LEN$DPB3	; copy maximum length regardless
;;;	# LDIR
	CALL	LDIR

	RET

;--------;
CLEARSCRN:
				; clear screen
;--------;
	LXI	D,CSNMSG
	MVI	C,9		; BDOS: PRINT STRING
	JMP	BDOS		; & RETURN
	DSEG
CSNMSG:	DB	CR,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF
	DB	CR,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF
	DB	CR,LF,LF,LF,LF,LF,'$' ; 25 line feeds
	CSEG

;------;
SCREEN1:			; display menu
;------;
	LDA	DEF$DSK
	ADI	'A'
	STA	S1DSK
	LXI	D,S1MSG
	MVI	C,9		; BDOS: PRINT STRING
	JMP	BDOS		; & RETURN
	DSEG
S1MSG:	DB	CR,'MML:DISKSTAT         DRIVE '
S1DSK:	DB	'A: CHARACTERISTICS '
	DB	CR,LF,LF,LF,LF,LF,LF,LF,LF,LF,LF ; 10 line feeds
	DB	CR,LF,'                   1    Display DPB statistics '
	DB	CR,LF,'                   2    Display DPH statistics '
	DB	CR,LF,'                   3    Display disk ALLOCATION '
	DB	CR,LF		; Later,'                   4    Display file ALLOCATION '
	DB	CR,LF		; Later,'                   5    Display directory ALLOCATION '
	DB	CR,LF,'                   9    Select new disk '
	DB	CR,LF,LF,LF,LF,'$' ; 5 line feeds
	CSEG

;-----;
OPTION:				; request option
;-----;

	LXI	D,OPTMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	LXI	D,OPTBUF
	MVI	C,10		; BDOS: READ CONSOLE BUFFER
	CALL	BDOS

	LDA	OPTLEN
	CPI	0
	JZ	OPTQUIT
	CPI	1
	JNZ	OPTION

	LDA	OPTCHR
	CPI	'1'
	JC	OPTION
	CPI	'9'+1
	JNC	OPTION		; value in range 1 to 9
	SUI	'0'

	RET

OPTQUIT:
	ORI	-1
	RET

	DSEG
OPTMSG:	DB	CR,'     Enter your choice, or <RETURN>   ',BS,BS,'$'
OPTBUF:	DB	2		; maximum length of buffer
OPTLEN:	DS	1		; number of characters returned
OPTCHR:	DS	2		; space for up to 2 characters
	CSEG


;------;
MAKEHEX:			; module in showblk
;------;


;	'   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16 '
;sdbbyt	'  00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h'
;	'     SPT  BSH BLM EXM    DSM     DRM  AL0-AL1    CKS     OFF  PSH PHM'
;sdbhex	'    0000h 00h 00h 00h   0000h   0000h 00h 00h   0000h   0000h 00h 00h'

	LXI	H,SDBBYT
	SHLD	POSN

	LDA	VERS$REL
	CPI	31H
	JZ	MAKEH3

	XRA	A		; CP/M 2  does not have PSH & PHM
	STA	DPB$PSH		; - set to zero
	STA	DPB$PHM

MAKEH3:

	LXI	H,DPB
	MVI	B,17
	CALL	HEXBYT

	LXI	H,SDBHEX
	SHLD	POSN

	LXI	H,DPB
	MVI	B,17
	LXI	D,HBTYPE
	CALL	HEXTBL

	RET

	DSEG
HBTYPE:	DB	2,1,1,1,2,2,1,1,2,2,1,1
	CSEG


;------;
MAKEDEC:			; module in showblk
;------;

	LXI	H,SDBDEC
	SHLD	POSN

	LHLD	DPB$SPT
	CALL	WRDDEC		; <HL> -> text

	LDA	DPB$BSH
	CALL	BYTDEC		; <A> -> text
	LDA	DPB$BLM
	CALL	BYTDEC		; <A> -> text

	LDA	DPB$EXM
	CALL	BYTDEC		; <A> -> text

	LHLD	DPB$DSM
	CALL	WRDDEC		; <HL> -> text

	LHLD	DPB$DRM
	CALL	WRDDEC		; <HL> -> text

	LDA	DPB$AL0
	CALL	BYTDEC		; <A> -> text
	LDA	DPB$AL1
	CALL	BYTDEC		; <A> -> text

	LHLD	DPB$CKS
	CALL	WRDDEC		; <HL> -> text

	LHLD	DPB$OFF
	CALL	WRDDEC		; <HL> -> text

	LDA	VERS$REL
	CPI	31H
	JNZ	DEC2

	LDA	DPB$PSH
	CALL	BYTDEC		; <A> -> text
	LDA	DPB$PHM
	CALL	BYTDEC		; <A> -> text

	RET

DEC2:	XRA	A
	CALL	BYTDEC		; <A> -> text
	XRA	A
	CALL	BYTDEC		; <A> -> text
	RET

ERRDEC:				; fill display with 3 asterisks as error
	CALL	NEXTDEC		; <DE> -> leftmost digit
	XCHG
	LHLD	POSN		; [1.1]
	MVI	A,'*'		; set 1st 3 digits to '*'
	MOV	M, A
	DCX	H
	MOV	M, A
	DCX	H
	MOV	M, A
	XCHG	
	RET


BYTDEC:				; display byte in A as decimal characters
	MVI	H,0
	MOV	L,A

WRDDEC:				; display word in HL as decimal characters
	LXI	B,0
	JMP	TXTDEC

MEGDEC:				; display byte,word in C & HL as decimal characters
	MVI	B,0

GIGDEC:				; display double word in BC & HL as decimal characters


TXTDEC:
	XCHG
	PUSH	D		; save 4 bytes of binary number
	PUSH	B
	CALL	NEXTDEC		; <DE> -> leftmost digit
	POP	B
	POP	D
	CALL	TOBCD		; converts <B>, <C>, <D>, <E> into bcd at BCD
	LHLD	POSN
	XCHG			; recover <DE> -> leftmost digit
	MVI	A,'0'		; initialise 1st digit to a zero
	STAX	D		; (just to make sure )

	LXI	H,BCDLSB	; start with least significent digit
TXTDEC1:
	CALL	TXTBCD
	RZ
	DCX	H
	JMP	TXTDEC1		; continue till all 10 digits done

TXTBCD:				; HL -> bcd digit, <DE> -> txt postion
	CALL	ZROBCD		; zero when no more BCD digits (destroys <A>, <BC>)
	RZ
	MOV	A,M
	ADI	'0'
	STAX	D
	DCX	D
	XRA	A
	MOV	M,A		; zero BCD byte ESSENTIAL to exit when done
	ORI	-1
	RET

ZROBCD:				; test for all bytes of BCD being zero
				; this is important as eventually all bytes
				; will be set to zero during transfer to text
	PUSH	H
	LXI	H,BCD
	XRA	A
	MVI	B,10
NXTZRO:	ORA	M
	JNZ	NXTZ1
	INX	H
	DCR	B
	JNZ	NXTZRO
;	# DJNZ NXTZRO
NXTZ1:	POP	H
	RET

;----;
TOBCD:				; print binary number 0-65535 from <HL>
;----;
	LXI	H,BINARY
	MOV	M,E		; least significant digit
	INX	H
	MOV	M,D
	INX	H
	MOV	M,C
	INX	H
	MOV	M,B		; most significent digit

	PUSH	B
	LXI	H,BCD
	MVI	B,10
	XRA	A
SETBCD:	MOV	M,A
	INX	H
;;;	# DJNZ SETBCD		; first zero all digits
	DCR	B
	JNZ	SETBCD
	POP	B

	MOV	A,B
	ORA	A
	JNZ	UPGIG

	ORA	C
	JNZ	UPMEG

	ORA	D
	JNZ	UPWRD

	ORA	E
	JNZ	UPBYT
	RET			; number is zero so return

UPBYT:	LXI	B,BCDBYT	; start of BCD pointer
	LXI	H,BYT10
	JMP	UPNXT

UPWRD:	LXI	B,BCDWRD	; start of BCD pointer
	LXI	H,WRD10
	JMP	UPNXT

UPMEG:	LXI	B,BCDMEG	; start of BCD pointer
	LXI	H,MEG10
	JMP	UPNXT

UPGIG:	LXI	B,BCDGIG	; start of BCD pointer
	LXI	H,GIG10
;
UPNXT:	LXI	D,BINARY	; binary number to be converted
	PUSH	B		; save BCD pointer
	MVI	C,-1
PDECL:	PUSH	H
	PUSH	D
	INR	C
	XRA	A
	MVI	B,4
	PUSH	PSW		; DJNZ preserved flags, but the 8080's 
NDECL:	POP	PSW		; DCR / JNZ doesn't, so we have to maintain
	LDAX	D		; the flags manually.
	ADC	M
	STAX	D		; and reduce count
	INX	D
	INX	H
;;;	# DJNZ NDECL		; this doesnt effect any flags
	PUSH	PSW
	DCR	B
	JNZ	NDECL
	POP	PSW
	
	POP	D
	POP	H
	JC	PDECL		; repeatedly subtract amount till carry set
	PUSH	H
	PUSH	D
	XRA	A
	MVI	B,4
NINCL:	LDAX	D
	SBB	M
	STAX	D		; and increase
	INX	D
	INX	H
;;;	# DJNZ NINCL		; this doesnt effect any flags
	DCR	B
	JNZ	NINCL

	POP	D
	INX	SP
	INX	SP		; loose <HL> (digits) saved on stack
	MOV	A,C
	POP	B		; pointer to BCD
	STAX	B
	INX	B
	MOV	A,M
	INX	H		; [1.1] Check both bytes of the word at (HL)
	ORA	M		; not just the low one.
	DCX	H
	JNZ	UPNXT

	RET

	DSEG

BCD:				; 10 bytes, 10 digits of BCD text
BCDGIG:				; max number is 4294967295
BCD$0:	DB	4
BCD$1:	DB	2
BCDMEG:				; max number is 16777215
BCD$2:	DB	9
BCD$3:	DB	4
BCD$4:	DB	9
BCDWRD:				; max number is 65535
BCD$5:	DB	6
BCD$6:	DB	7
BCDBYT:				; max number is 255
BCD$7:	DB	2
BCD$8:	DB	9
BCDLSB:
BCD$9:	DB	5

GIG10:	DW	13824,-15259	; -1000000000 (C465 3600H)
	DW	7936, -1526	;  -100000000 (FA0A 1F00H)
MEG10:	DW	27008,  -153	;   -10000000 (FF67 6980H)
	DW	-16960,   -16	;    -1000000 (FFF0 BDC0H)
	DW	31072,    -2	;     -100000 (FFFE 7960H)
WRD10:	DW	-10000,    -1	;      -10000 (FFFF D8F0H)
	DW	-1000,    -1	;       -1000 (FFFF FC18H)
BYT10:	DW	-100,    -1	;        -100 (FFFF FF9CH)
	DW	-10,    -1	;         -10 (FFFF FFF6H)
	DW	-1,    -1	;          -1 (FFFF FFFFH)
	DW	0,     0	;           0 (0000 0000H) this terminates all

BINARY:	DB	0,0,0,0		; binary number filled from E, D, C, & B

	CSEG

TESTDEC:
	CPI	CR
	RZ
NEXTDEC:			; find next dec location in text and convert to space
				; and return DE -> to end of 00h string

	CALL	DECCHR		; find first dec character
	JNZ	TESTDEC
NXT3:	MVI	A,' '		; erase each digit as we go
	STAX	D
	CALL	DECCHR		; scan subsequent dec characters
	JZ	NXT3
	DCX	D
	MVI	A,'0'
	STAX	D		; initialise 1st digit to a zero
	XCHG
	SHLD	POSN
	XCHG			; [1.1] Bring DE back
	RET

DECCHR:	LHLD	POSN
	INX	H
	MOV	A,M
	MOV	D,H
	MOV	E,L
	CPI	CR
	RZ
	SHLD	POSN
	LXI	H,DECTXT
	MVI	B,12		; [1.1] Check 12 chars, not 11.
NXT2:	CMP	M
	RZ
	INX	H
;;;	# DJNZ NXT2
	DCR	B
	JNZ	NXT2
	ORI	-1
	RET
	DSEG
DECTXT:	DB	'0123456789+*'	; + used for bit flag, * used for errors
	CSEG

;------;
MAKEMAX:			; module in showblk
;------;

;'          BLOCK       EXTENT      MAX DISK    DIRECTORY   CHECK SUM   SECTOR'
;'          SIZE (K)    FOLDS       SIZE (K)    ENTRIES     ENTRIES     SIZE'
;'DPB(DEC):  16K          15        1048576      65536       65536      32768'

	LXI	H,SDBMAX
	SHLD	POSN

	LDA	DPB$BSH
	LXI	H,128
	ORA	A
	JZ	MAKEM2
MAKEM1:	DAD	H
	DCR	A
	JNZ	MAKEM1
MAKEM2:	MOV	A,H		; /256
	RRC			; /512
	RRC			; /1024
	PUSH	PSW
	LDA	DPB$BLM
	LXI	B,-128
	ORA	A
	JZ	MAKEM4
MAKEM3:	DAD	B
	DCR	A
	JNZ	MAKEM3
MAKEM4:	DAD	B
	POP	PSW		; recover K
	MOV	B,A		; and save
	MOV	A,H
	ORA	L
	MOV	A,B
	PUSH	PSW
	CNZ	ERRDEC
	POP	PSW
	CZ	BYTDEC		; <A> -> text

	LDA	DPB$BLM
	ADI	1		; +1
	RAR
	RAR
	RAR			; /8
	MOV	B,A		; save EXM+1
	LHLD	DPB$DSM
	XRA	A		; (there must be an easier way)
	SUB	H
	DCR	A
	CMC
	ADC	H		; a = 0 if H = 0, else a = -1
	ANA	B
	ADD	B
	ADI	-1		; -1  (convert into EXM)
	MOV	B,A		; and save	

	LDA	DPB$EXM
	CMP	B
	PUSH	PSW
	CNZ	ERRDEC
	POP	PSW
	CZ	BYTDEC		; <A> -> text

	XRA	A
	LHLD	DPB$DSM
	LXI	B,1
	DAD	B		; increment dsm by 1
	ACI	0
	MOV	C,A		; and save in C
	LDA	DPB$BSH
	ADI	-3
	MOV	B,A
	ORA	A
	MOV	A,C		; giga byte
	JZ	MAKEM6
MAKEM5:	DAD	H
	ACI	0
	DCR	B
	JNZ	MAKEM5
;;;	# DJNZ MAKEM5
MAKEM6:	MOV	C,A
	CALL	MEGDEC		; <C> & <HL> -> text

	XRA	A
	LHLD	DPB$DRM
	LXI	B,1
	DAD	B		; increment drm by 1
	ACI	0
	MOV	C,A
	CALL	MEGDEC		; <C> & <HL> -> text

	LHLD	DPB$DRM
	MOV	A,H
	ANA	A
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A		; /2
	MOV	A,H
	ANA	A
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A		; /4
	MOV	D,H
	MOV	E,L
	INX	D		; DE=HL+1

	LHLD	DPB$CKS
	MOV	A,H
	ORA	L
	JZ	MAKEM8		; no check sum
	MOV	A,H
	ANI	7FH
	ORA	L
	JZ	MAKEM7		; bit 15 set for non removable
;;; 	# SBC HL,DE
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A	
	ORA	L		; Set the Z based on HL

	XCHG
	JZ	MAKEM8
	CALL	ERRDEC
	JMP	MAKEM9
MAKEM8:	MVI	C,0
	CALL	MMEGX4		; <C>, <HL> * 4
	CALL	MEGDEC		; <C> & <HL> -> text
	JMP	MAKEM9
MAKEM7:	XRA	A
	CALL	NEXTDEC
;;;	# LD DE,(POSN)		; [1.1]
	XCHG
	LHLD	POSN

	DCX	H
	MVI	M,'+'
	INX	H
	INX	H
	XCHG
MAKEM9:

	LDA	VERS$REL
	CPI	31H
	JNZ	MAKEM0

	LDA	DPB$PSH
	LXI	H,128
	ORA	A
	JZ	MAKE02
MAKE01:	DAD	H
	DCR	A
	JNZ	MAKE01
MAKE02:	PUSH	H
	LDA	DPB$PHM
	LXI	B,-128
	ORA	A
	JZ	MAKE04
MAKE03:	DAD	B
	DCR	A
	JNZ	MAKE03
MAKE04:	DAD	B
	MOV	A,H
	ORA	L
	POP	H
	PUSH	PSW
	CNZ	ERRDEC
	POP	PSW
	CZ	WRDDEC		; <HL> -> text

	RET

MAKEM0:	LXI	H,128		; CP/M 2 sector size
	CALL	WRDDEC		; <HL> -> text
	RET


;--------;
MAKEDIR:			; module in showblk
;--------;

;'                             Data       1K    128 byte  '
;'                            Blocks    Blocks   Records    Capacity'
;'              Directory      65535  16777215  16777215    16777215 Entries'
;'              Data           65535  16777215  16777215  4294967296 Bytes'
;'                             65000  16777215  16777215'

	DSEG
DIRDB:	DB	0		; save number of director blocks
DBSIZE:	DB	0		; save data block size in K
	CSEG

	LXI	H,SDBDIR
	SHLD	POSN

	LHLD	DPB$AL0
	XRA	A
	MVI	B,16
MAKED0:	DAD	H
	ACI	0
;;;	# DJNZ MAKED0		; number of directory data blocks
	DCR	B
	JNZ	MAKED0
	STA	DIRDB

	CALL	BYTDEC		; <A> -> text

	LDA	DPB$BSH
	LXI	H,128
	ORA	A
	JZ	MAKED2
MAKED1:	DAD	H
	DCR	A
	JNZ	MAKED1
MAKED2:	MOV	A,H		; /256
	RRC			; /512
	RRC			; /1024
	STA	DBSIZE		; save data block size in K

	MOV	C,A
	MVI	B,0
	LDA	DIRDB
	LXI	H,0
	ORA	A
	JZ	MAKED4
MAKED3:	DAD	B
	DCR	A
	JNZ	MAKED3
MAKED4:	PUSH	H
	CALL	WRDDEC		; <HL> -> text
	POP	H

	MVI	C,0
	CALL	MMEGX8		; multiply by 8

	PUSH	H
	PUSH	B
	CALL	MEGDEC		; number of records (<C> & <HL> -> text)
	POP	B
	POP	H

	CALL	MMEGX4		; multiply by 4
	CALL	MEGDEC		; number of entries (<C> & <HL> -> text)
	RET

;--------;
MAKEDAT:			; module in showblk
;--------;

;'                             Data       1K    128 byte  '
;'                            Blocks    Blocks   Records    Capacity'
;'              Directory      65535  16777215  16777215    16777215 Entries'
;'              Data           65535  16777215  16777215  4294967296 Bytes'
;'                             65000  16777215  16777215'

	LXI	H,SDBDAT
	SHLD	POSN

	LHLD	DPB$DSM		; total disk blocks
	LDA	DIRDB		; blocks reserved for directory
	DCR	A
	MOV	C,A
	MVI	B,0

;;;	# SBC HL,BC		; leaving number of data blocks
	MOV	A,L
	SUB	C
	MOV	L,A
	MOV	A,H
	SBB	B
	MOV	H,A

	PUSH	H
	CALL	WRDDEC		; <HL> -> text
	POP	H

	XRA	A
	MOV	B,A
	MOV	C,A		; BC = 0

	LDA	DPB$BLM
	INR	A
	RRC
	RRC
	RRC			; /8
MAKED5:	RRC			; [1.1] This loop rewritten ...
	JC	MAKED6
	PUSH	PSW
	CALL	MGIGX2
	POP	PSW
	JMP	MAKED5		; [1.1] ... to here

MAKED6:	PUSH	B
	PUSH	H
	CALL	GIGDEC		; 1K blocks (<BC> & <HL> -> text)
	POP	H
	POP	B
	CALL	MGIGX8		; multiply B,C,H,& L by 8

	PUSH	H
	PUSH	B
	CALL	GIGDEC		; number of records (<BC> & <HL> -> text)
	POP	B
	POP	H
	
	CALL	MGIGX128	; multiply B,C,H,& L by 128
	CALL	GIGDEC		; number of bytes (<BC> & <HL> -> text)

	RET

;--------;
MAKETOT:			; module in showblk
;--------;

;'                             Data       1K    128 byte  '
;'                            Blocks    Blocks   Records    Capacity'
;'              Directory      65535  16777215  16777215    16777215 Entries'
;'              Data           65535  16777215  16777215  4294967296 Bytes'
;'                             65000  16777215  16777215'

	LXI	H,SDBTOT
	SHLD	POSN

	XRA	A
	LXI	B,1
	LHLD	DPB$DSM		; total disk blocks
	DAD	B
	ADC	A
	MOV	C,A

	PUSH	B
	PUSH	H
	CALL	WRDDEC		; <HL> -> text
	POP	H
	POP	B

	LDA	DPB$BLM
	INR	A
	RRC
	RRC
	RRC			; /8
MAKED7:	RRC			; [1.1] Rewritten to match maked5/maked6
	JC	MAKED8
	PUSH	PSW
	CALL	MGIGX2
	POP	PSW
	JMP	MAKED7
;
MAKED8:	PUSH	B
	PUSH	H
	CALL	GIGDEC		; 1K blocks (<BC> & <HL> -> text)
	POP	H
	POP	B

	CALL	MGIGX8		; multiply B,C,H,& L by 8
	CALL	GIGDEC		; number of records (<BC> & <HL> -> text)
	
	RET

MMEGX8:	CALL	MMEGX2		; multiply C,H,& L by 8
MMEGX4:	CALL	MMEGX2		; multiply C,H,& L by 4
MMEGX2:	MOV	A,L		; multiply C,H,& L by 2
	ADD	A
	MOV	L,A
	MOV	A,H
	ADC	A
	MOV	H,A
	MOV	A,C
	ADC	A
	MOV	C,A
	RET

MGIGX8:	CALL	MGIGX2		; multiply B,C,H,& L by 8
MGIGX4:	CALL	MGIGX2		; multiply B,C,H,& L by 4
MGIGX2:	MOV	A,L		; multiply B,C,H,& L by 2
	ADD	A
	MOV	L,A
	MOV	A,H
	ADC	A
	MOV	H,A
	MOV	A,C
	ADC	A
	MOV	C,A
	MOV	A,B
	ADC	A
	MOV	B,A
	RET

MGIGX128:
				; multipy B,C,H,& L by 128
	MOV	A,B
	ANA	A
	RAR			; we can only use lowest bit
	MOV	A,C
	RAR
	MOV	B,A
	MOV	A,H
	RAR
	MOV	C,A
	MOV	A,L
	RAR
	MOV	H,A
	MVI	A,0
	RAR
	MOV	L,A
	RET



;------;
SHOWBLK:			; menu 1 option 1    Display DPB statistics
;------;
	LDA	DEF$DSK
	ADI	'A'
	STA	SDBDSK

	CALL	MAKEHEX

	CALL	MAKEDEC

	CALL	MAKEMAX

	CALL	MAKEDIR

	CALL	MAKEDAT

	CALL	MAKETOT


	LXI	D,SDBMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	CALL	WAITCR

	RET

	DSEG
SDBMSG:
	DB	CR,   '                         DRIVE '
SDBDSK:	DB	'A: DISC PARAMETER BLOCK'
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'   0   1   2   3   4   5   6   7   8'
	DB	'   9  10  11  12  13  14  15  16 '
	DB	CR,LF,'DPB:     '
SDBBYT:	DB	'  00h 00h 00h 00h 00h 00h 00h 00h 00h'
	DB	' 00h 00h 00h 00h 00h 00h 00h 00h'
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'     SPT  BSH BLM EXM    DSM     DRM  '
	DB	'AL0-AL1    CKS     OFF  PSH PHM'
	DB	CR,LF,'DPB(HEX):'
SDBHEX:	DB	'    0000h 00h 00h 00h   0000h   0000h '
	DB	'00h 00h   0000h   0000h 00h 00h'
	DB	CR,LF,'DPB(DEC):'
SDBDEC:	DB	'   65535  255 255 255  65535   65535  '
	DB	'255 255  65535   65535  255 255'
	DB	CR,LF
	DB	CR,LF,'          BLOCK       EXTENT    '
	DB	'  MAX DISK    DIRECTORY   CHECK SUM   SECTOR'
	DB	CR,LF,'          '
	DB	'SIZE (K)    FOLDS       SIZE (K)    ENTRIES'
	DB	'     ENTRIES     SIZE'
	DB	CR,LF,'DPB(DEC): '
SDBMAX:	DB	' 16K          15        1048576      65536 '
	DB	'      65536      32768'
SDBERR:	DB	CR,LF,''
	DB	CR,LF
	DB	CR,LF,'ALLOCATION OF DISK BLOCKS'
	DB	CR,LF,'                             Data       1K    128 byte  '
	DB	CR,LF,'                            Blocks    Blocks   Records  '
	DB	'  Capacity'
	DB	LF
SDBDIR:	DB	CR,LF,'              Directory      65535  16777215  16777215  '
	DB	'  16777215 Entries'
SDBDAT:	DB	CR,LF,'              Data           65535  16777215  16777215  '
	DB	'4294967296 Bytes'
	DB	CR,LF,'                          --------  --------  --------'
SDBTOT:	DB	CR,LF,'                             65000  16777215  16777215'
	DB	LF
	DB	'$'
	CSEG

;------;
MAKEDPH3:
				; menu 1 option 2    Display DPH statistics
;------;

;	'   0   1   2   3   4   5   6   7   8   9  10  11  '
;s3byt1	'  00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
;	'  12  13  14  15  16  17  18  19  20  21  22  23  24  '
;s3byt2	'  00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
;	'  XLT     -0- -0- -0- -0- -0- -0- -0- -0- -0- MF  '
;s3hex1	'  0000h   00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
;	'  DPB     CSV     ALV     DIRBCB  DTABCB  HASH    HBANK'
;s3hex2	'  0000h   0000h   0000h   0000h   0000h   0000h   00h '

	LXI	H,S3BYT1
	SHLD	POSN

	LXI	H,DPH3
	MVI	B,12
	CALL	HEXBYT

	PUSH	H
	LXI	H,S3BYT2
	SHLD	POSN
	POP	H

	MVI	B,13
	CALL	HEXBYT

	LXI	H,S3HEX1
	SHLD	POSN

	LXI	H,DPH3
	LXI	D,H3TYPE
	MVI	B,12
	CALL	HEXTBL


	PUSH	H
	LXI	H,S3HEX2
	SHLD	POSN
	POP	H

	MVI	B,13
	CALL	HEXTBL

	RET


	DSEG
H3TYPE:	DB	2,1,1,1,1,1,1,1,1,1,1
	DB	2,2,2,2,2,2,1
	CSEG


;------;
MAKEDPH2:
				; menu 1 option 2    Display DPH statistics
;------;

;	'   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  '
;s2byt	'  00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
;	'  XLT     -0- -0- -0- -0- -0- -0- DIRBCB  DPB     CSV     ALV     '
;s2hex	'  0000h   00h 00h 00h 00h 00h 00h 0000h   0000h   0000h   0000h   '

	LXI	H,S2BYT
	SHLD	POSN

	LXI	H,DPH2
	MVI	B,16
	CALL	HEXBYT

	LXI	H,S2HEX
	SHLD	POSN

	LXI	H,DPH2
	LXI	D,H2TYPE
	MVI	B,16
	CALL	HEXTBL

	RET


	DSEG
H2TYPE:	DB	2,1,1,1,1,1,1,2,2,2,2 ; 11 fields
	CSEG


	RET

;------;
SHOWHDR:			; menu 1 option 2    Display DPH statistics
;------;

	LDA	VERS$REL
	CPI	31H
	CZ	OUTDPH3

	LDA	VERS$REL
	CPI	22H
	CZ	OUTDPH2

	LDA	VERS$REL	; [1.1] Add a stub for MP/M.
	CPI	30H
	CZ	OUTDPHM

	RET

;------;
OUTDPH3:			; menu 1 option 2    Display DPH statistics
;------;

	LDA	DEF$DSK
	ADI	'A'
	STA	SH3DSK

	CALL	MAKEDPH3

	LXI	D,SH3MSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	CALL	WAITCR

	RET


	DSEG
SH3MSG:	DB	CR,'                     DRIVE '
SH3DSK:	DB	'A: DISK PARAMETER HEADER'
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'   0   1   2   3   4   5   6   7   8   9  10  11  '
	DB	CR,LF,'DPH(HEX):'
S3BYT1:	DB	'  00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'  12  13  14  15  16  17  18  19  20  21  22  23  24  '
	DB	CR,LF,'DPH(HEX):'
S3BYT2:	DB	'  00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'  XLT     -0- -0- -0- -0- -0- -0- -0- -0- -0- MF  '
	DB	CR,LF,'DPH(HEX):'
S3HEX1:	DB	'  0000h   00h 00h 00h 00h 00h 00h 00h 00h 00h 00h '
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'  DPB     CSV     ALV     DIRBCB  DTABCB  HASH    HBANK'
	DB	CR,LF,'DPH(HEX):'
S3HEX2:	DB	'  0000h   0000h   0000h   0000h   0000h   0000h   00h '
	DB	CR,LF
	DB	LF,LF,LF,LF,LF,LF,LF,LF
	DB	'$'

	CSEG

;------;
OUTDPH2:			; menu 1 option 2    Display DPH statistics
;------;

	LDA	DEF$DSK
	ADI	'A'
	STA	SH2DSK

	CALL	MAKEDPH2

	LXI	D,SH2MSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	CALL	WAITCR

	RET


	DSEG
SH2MSG:	DB	CR,'                     DRIVE '
SH2DSK:	DB	'A: DISK PARAMETER HEADER'
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'   0   1   2   3   4   5   6   7'
	DB	'   8   9  10  11  12  13  14  15  '
	DB	CR,LF,'DPH(HEX):'
S2BYT:	DB	'  00h 00h 00h 00h 00h 00h 00h 00h '
	DB	'00h 00h 00h 00h 00h 00h 00h 00h '
	DB	CR,LF
	DB	CR,LF,'         '
	DB	'  XLT     -0- -0- -0- -0- -0- -0- DIRBCB  DPB     CSV     '
	DB	'ALV     '
	DB	CR,LF,'DPH(HEX):'
S2HEX:	DB	'  0000h   00h 00h 00h 00h 00h 00h 0000h   0000h   0000h   '
	DB	'0000h   '
	DB	CR,LF,LF,LF,LF,LF,LF,LF
	DB	LF,LF,LF,LF,LF,LF,LF,LF
	DB	'$'

	CSEG

;------;
OUTDPHM:			; menu 1 option 2    Display DPH statistics
;------;

	LDA	DEF$DSK
	ADI	'A'
	STA	SHMDSK

	LXI	D,SHMMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	CALL	WAITCR

	RET

	DSEG
SHMMSG:	DB	CR,'                     DRIVE '
SHMDSK:	DB	'A: DISK PARAMETER HEADER'
	DB	CR,LF
	DB	CR,LF
	DB	'         ', CR,LF
	DB	'    * * * U N A B L E   T O   D I S P L A Y   '
	DB	'U N D E R   M P / M II * * *'
	DB	CR,LF
	DB	CR,LF
	DB	'         '
	DB	CR,LF
	DB	CR,LF
	DB	LF,LF,LF,LF,LF,LF,LF
	DB	LF,LF,LF,LF,LF,LF,LF
	DB	'$'

	CSEG


	PAGE

; -------------------------------------------- ;
; utilities used in allocation vector analysis ;
; -------------------------------------------- ;

	DSEG
LENALV:	DS	2		; length of allocation vector in bytes
ALVDIR:	DS	2		; datablocks allocated to directory
ALVDAT:	DS	2		; datablocks allocated to data
ALVZRO:	DS	2		; datablocks not allocated
ALVERA:	DS	2		; datablocks allocated to erased data
ALVLST:	DS	2		; datablocks allocated to overwritten data
ALVBAD:	DS	2		; datablocks with duplicated data access
ALVRNG:	DS	2		; datablocks outside maximum number
ALVLEN	EQU	$-LENALV
USER:	DB	0		; save user number
	CSEG

;--;
ALV:				; return <HL> = <HL>/8, & <C> = <HL> mod 7
;--;
	MVI	C,0
	CALL	ALV1		; /2
	CALL	ALV1		; /4
	CALL	ALV1		; /8
	MOV	A,C
	RLC
	RLC
	RLC
	MOV	C,A
	RET

ALV1:	MOV	A,H
	ANA	A
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A		; <HL> = <HL> / 2
	MOV	A,C
	RAR
	MOV	C,A		; C contains lost bits
	RET

TSTBIT:				; tst bit number <C> at offset <HL> from ALLOC
				; return CF=NZ if bit already set

	PUSH	B
	PUSH	H
	LXI	H,BITMAP
	MVI	B,0
	DAD	B
	MOV	A,M		; bit to set
	LXI	B,ALLOC
	POP	H
	PUSH	H
	DAD	B
	MOV	B,A		; save bit to set
	MOV	A,M
	ANA	B		; test if bit set
	POP	H
	POP	B
	RET			; 0 = if not set, > 0 if set

SETBIT:				; set bit number <C> at offset <HL> from ALLOC
				; return CF=NZ if bit already set

	PUSH	B
	PUSH	H
	LXI	H,BITMAP
	MVI	B,0
	DAD	B
	MOV	A,M		; bit to set
	LXI	B,ALLOC
	POP	H
	PUSH	H
	DAD	B
	MOV	B,A		; save bit to set
	MOV	A,M
	MOV	C,A		; save byte before setting bit
	ORA	B
	MOV	M,A		; set bit
	MOV	A,C
	ANA	B		; test if bit set
	POP	H
	POP	B
	RET			; 0 = if not set, > 0 if set



BITMAP:	DB	10000000B	; 0
	DB	01000000B	; 1
	DB	00100000B	; 2
	DB	00010000B	; 3
	DB	00001000B	; 4
	DB	00000100B	; 5
	DB	00000010B	; 6
	DB	00000001B	; 7

UPDAT:
	JNZ	ERRBIT		; bit already set
	PUSH	H
	LHLD	ALVDAT
	INX	H
	SHLD	ALVDAT		; increment count of data
	POP	H
	RET


ERRBIT:				; flag bit already set
	PUSH	H
	LHLD	ALVBAD
	INX	H
	SHLD	ALVBAD		; increment count of duplicate data
	POP	H
	RET

UPERA:
	JNZ	LSTBIT		; bit already set
	PUSH	H
	LHLD	ALVERA
	INX	H
	SHLD	ALVERA		; increment count of erased data
	POP	H
	RET

LSTBIT:
	PUSH	H
	LHLD	ALVLST
	INX	H
	SHLD	ALVLST		; increment count of overwritten data
	POP	H
	RET

UPRNG:
	PUSH	H
	LHLD	ALVRNG
	INX	H
	SHLD	ALVRNG		; increment count of blocks outside range
	POP	H
	RET

;
; [1.1] Ability to render the first 256 bytes of the allocation vector
; graphically
;
RENDER$ALV:
	PUSH	PSW
	CALL	ALV$LENGTH
	MOV	B,C		; B = length of ALV
	LXI	H,0
;
RENDER$ALV$LOOP:
	PUSH	H
	CALL	ALV		; Locate the bit
	CALL	TSTBIT		; Read it
	POP	H
	JZ	ALV$NEXT	; If the bit is zero, don't paint
	XCHG
	MOV	A,E
	ANI	0C0H
	RLC
	RLC
	RLC			; A = row number, 0-3	
	LXI	H,ALV$TXT
	ADD	L
	MOV	L,A
	MVI	A,0
	ADC	H
	MOV	H,A		; ADD HL,A
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A		; LD HL,(HL)
	MOV	A,E
	ANI	3FH		; A = column number, 0-63
	ADD	L
	MOV	L,A
	MVI	A,0
	ADC	H
	MOV	H,A
	LDA	DOT		; If there isn't a dot there, it must have
	CMP	M		; been populated by a previous pass
	XCHG
	JNZ	ALV$NEXT
	POP	PSW
	STAX	D		; Write the character requested
	PUSH	PSW
ALV$NEXT:
	INX	H
	DCR	B
	JNZ	RENDER$ALV$LOOP
;;;	# DJNZ RENDER$ALV_LOOP
	POP	PSW
	RET
;
; The four lines of the graphical ALV map
;
ALV$TXT:
	DW	ALV11
	DW	ALV12
	DW	ALV13
	DW	ALV14
;
; Initialise the graphical display of the allocation vector.
;
ALV$BLANK:
	LXI	H, ALV11	; Zap the first line
	CALL	BLANK64
	LXI	H, ALV12	; Second line
	CALL	BLANK64
	LXI	H, ALV13	; Third line
	CALL	BLANK64
	LXI	H, ALV14	; Fourth line
	CALL	BLANK64
	LHLD	DPB$DSM
	CALL	ALV$LENGTH	; Fill up to the number of blocks
	LXI	H, ALV11	; on the disk with '.'
	LDA	DOT
	CALL	ALV$FILL
	RZ
	LXI	H, ALV12
	CALL	ALV$FILL
	RZ
	LXI	H, ALV13
	CALL	ALV$FILL
	RZ
	LXI	H, ALV14
	CALL	ALV$FILL
	RET
;
; Blank one row of the ALV display buffer: 64 characters at HL.
;
BLANK64:
	MVI	B,64		; Write 64 blanks at HL.
BLANK64A:
	MVI	M,' '
	INX	H
;;;	# DJNZ BLANK64A
	DCR	B
	JNZ	BLANK64A
	RET
;
; Write the lesser of C and 64 copies of A at HL.
;
ALV$FILL:
	MVI	B,64

ALV$FILL1:
	MOV	M,A
	INX	H
	DCR	C
	RZ
;;;	# DJNZ ALV$FILL1
	DCR	B
	JNZ	ALV$FILL1
	ORA	A
	RET
;
; Given HL = (number of blocks on the disk - 1), return C = number of blocks  
; to display (with 0 => 256).
;
ALV$LENGTH:
	
	MOV	A,H
	MVI	C,0
	ORA	A		; If H is nonzero return C = 0
	RNZ
	MOV	C,L		; Otherwise return C = L+1
	INR	C
	RET
;
; [End of 1.1 helper functions]
;

;------;
SHOWALV:			; menu 1 option 3    Display disk ALLOCATION
;------;
	LDA	DEF$DSK
	ADI	'A'
	STA	SALDSK

	LXI	H,LENALV	; start of datablock counts
	MOV	D,H
	MOV	E,L
	INX	D
	LXI	B,ALVLEN-1	; length of datablock counts
	MVI	M,0
;;;	# LDIR
	CALL	LDIR		; and zero all

	LHLD	DPB$DSM		; number of data blocks less 1
	CALL	ALV		; return <HL> = <HL>/8, & <C> = <HL> mod 7

	INX	H
	SHLD	LENALV		; length of ALV in bytes
	LXI	D,ALLOC		; start of ALV
	DAD	D		; end of ALV

	XCHG
	LHLD	BDOS+1		; base of BDOS
	DCX	H
	ANA	A
;;;	# SBC HL,DE		; <HL> = top of TPA - top of ALLOC
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A

	JNC	ALVOK

	LXI	D,ALVERR
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	JMP	WAITCR		; wait for <RETURN> then return

	DSEG
ALVERR:	DB	CR,LF,'TPA too small for allocation vector','$'
	CSEG

; ---------------------------- ;
; initialise allocation vector ;
; ---------------------------- ;

ALVOK:	CALL	ALV$BLANK	; [1.1] Initialise ALV map
	LHLD	LENALV
	MOV	B,H
	MOV	C,L
	LXI	H,ALLOC
	MOV	D,H
	MOV	E,L
	INX	D
	DCX	B
	MVI	M,0
;;;	# LDIR			; set allocation vector to 0
	CALL	LDIR

	LHLD	DPB$AL0		; directory ALV0 and ALV1
	SHLD	ALLOC		; and fill alloc bits with these

	LXI	H,7		; ??? render_alv overwrites HL 
	LDA	BLOCK
	CALL	RENDER$ALV	; Fill graphical ALV with directory blocks

; ----------------------- ;
; count directory entries ;
; ----------------------- ;

	MVI	B,16
	LXI	D,0
CNTALV:	DAD	H
	JNC	NOCNT
	INX	D
NOCNT:	DCR	B
	JNZ	CNTALV
;;;	# DJNZ CNTALV
	XCHG
	SHLD	ALVDIR		; number of directory entries

; -------------- ;
; scan directory ;
; -------------- ;

	LXI	D,DEFFCB
	MVI	A,'?'
	STAX	D
	MVI	C,17		; BDOS: SEARCH FOR FIRST
	CALL	BDOS

NEXTDIR:
	CPI	-1
	JZ	DOERA
	MOV	L,A
	MVI	H,0
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LXI	D,DEFDMA
	DAD	D
	MOV	A,M
	ANI	NOT 00011111B	; test for high bits set
	JNZ	NXTDCB

	LXI	D,16
	DAD	D
	XCHG			; <DE> -> first data block allocation
	LHLD	DPB$DSM
	MOV	A,H
	ORA	A
	JNZ	WRDALV

; test 16 file data block bytes
	MVI	B,16		; byte wide data blocks
NXTDB:	PUSH	H
	LDAX	D
	ORA	A
	JZ	NULDB
	CMP	L		; check range
	JZ	UPDB
	JNC	ERRDB
UPDB:	MOV	L,A
	MVI	H,0
	CALL	ALV		; return <HL> = <HL>/8, <C>=MOD(<HL>,7)
	CALL	SETBIT		; returns CF=NZ if bit already set
	CALL	UPDAT
	JMP	NULDB
ERRDB:	CALL	UPRNG		; data block outside range
NULDB:	POP	H		; recover DSM
	INX	D		; increment to next data block allocation
	DCR	B
	JNZ	NXTDB
;;;	# DJNZ NXTDB
	JMP	NXTDCB

; test 8 file data block words
WRDALV:
	XCHG			; move back to HL
	MVI	B,8
NXTDW:	PUSH	H
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,E
	ORA	D
	JZ	NULDW
	LHLD	DPB$DSM
	XRA	A
;;;	# SBC HL,DE
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A	

	JC	ERRDW
	XCHG
	CALL	ALV		; return <HL> = <HL>/8, <C>=MOD(<HL>,7)
	CALL	SETBIT		; returns CF=NZ if bit already set
	CALL	UPDAT
	JMP	NULDW
ERRDW:	CALL	UPRNG		; data block outside range
NULDW:	POP	H		; recover data block pointer
	INX	H
	INX	H		; increment to next data block allocation
;;;	# DJNZ NXTDW
	DCR	B
	JNZ	NXTDW

	JMP	NXTDCB

NXTDCB:
	LXI	D,DEFFCB
	XRA	A
	STAX	D		; set default drive
	MVI	C,18		; BDOS: SEARCH FOR NEXT
	CALL	BDOS
	JMP	NEXTDIR

; -------------- ;
; scan era files ;
; -------------- ;

ERABYT	EQU	0E5H		; CP/M byte for erased file

DOERA:
	LHLD	DPB$DSM		; Populate data blocks with '+'
	LDA	SOLID
	CALL	RENDER$ALV

	MVI	E,-1		; to fetch user code
	MVI	C,32		; BDOS: SET/GET USER CODE
	CALL	BDOS
	STA	USER		; save user number

	MVI	E,5		; set user = 5
	MVI	C,32		; BDOS: SET/GET USER CODE
	CALL	BDOS

	LXI	D,DEFFCB
	MVI	A,'?'
	STAX	D
	MVI	C,17		; BDOS: SEARCH FOR FIRST
	CALL	BDOS


NEXTERA:
	CPI	-1
	JZ	ERASED
	MOV	L,A
	MVI	H,0
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LXI	D,DEFDMA
	DAD	D
	MOV	A,M
	ANI	NOT 00011111B	; test for high bits set
	JZ	NXTERA
	MOV	A,M
	CPI	ERABYT
	JNZ	NXTERA

	PUSH	H
	MVI	B,32
TSTERA:	MOV	A,M
	CPI	ERABYT
	JNZ	NOTERA
	INX	H
	DCR	B
	JNZ	TSTERA
	;;;# DJNZ TSTERA	; (doesnt change flags)
NOTERA:	POP	H
	JZ	ERASED1		; as all 0e5's must be at end

	LXI	D,16
	DAD	D
	XCHG			; <DE> -> first data block allocation
	LHLD	DPB$DSM
	MOV	A,H
	ORA	A
	JNZ	WRDERA

; test 16 erased file data block bytes
	MVI	B,16
NXTEDB:	PUSH	H		; save DSM
	LDAX	D
	ORA	A
	JZ	NULEDB
	CMP	L		; check range
	JZ	UPEDB
	JNC	ERREDB
UPEDB:	MOV	L,A
	MVI	H,0
	CALL	ALV		; return <HL> = <HL>/8, <C>=MOD(<HL>,7)
	CALL	SETBIT		; returns CF=NZ if bit already set
	CALL	UPERA
	JMP	NULEDB
ERREDB:	CALL	UPRNG		; data block outside range
NULEDB:	POP	H		; recover DSM
	INX	D		; increment to next data block byte
;;;	# DJNZ NXTEDB
	DCR	B
	JNZ	NXTEDB

	JMP	NXTERA

; test 8 erased file data block words
WRDERA:
	XCHG			; move back to HL
	MVI	B,8
NXTEDW:	PUSH	H
	MOV	E,M
	INX	H
	MOV	D,M
	MOV	A,E
	ORA	D
	JZ	NULEDW
	LHLD	DPB$DSM
	XRA	A

	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A

;;;	# SBC HL,DE
	JC	ERREDW
	XCHG
	CALL	ALV		; return <HL> = <HL>/8, <C>=MOD(<HL>,7)
	CALL	SETBIT		; returns CF=NZ if bit already set
	CALL	UPERA
	JMP	NULEDW
ERREDW:	CALL	UPRNG		; data block outside range
NULEDW:	POP	H		; recover data block pointer
	INX	H
	INX	H		; increment to next data block word
;;;	# DJNZ NXTEDW
	DCR	B
	JNZ	NXTEDW

NXTERA:
	LXI	D,DEFFCB
	MVI	A,ERABYT AND 11100000B ; ignore water mark,
	STAX	D		; (only works when user=5)
	MVI	C,18		; BDOS: SEARCH FOR NEXT
	CALL	BDOS
	JMP	NEXTERA

ERASED:				; reached end of file
	LHLD	DPB$DSM		; Populate erased blocks with '+'
	LDA	HOLLOW
	CALL	RENDER$ALV
ERASED1:
	LDA	USER		; recover user number
	MOV	E,A
	MVI	C,32		; BDOS: SET/GET USER CODE
	CALL	BDOS

; --------------------------- ;
; calculate unused datablocks ;
; --------------------------- ;

	LHLD	LENALV
	MOV	B,H
	MOV	C,L
	LHLD	DPB$DSM
	LXI	D,ALLOC
NXTCNT:	PUSH	B
	LDAX	D
	MVI	B,8
NEXT8:	ADD	A
	JNC	NOTALC
	DCX	H		; reduce count by 1
NOTALC:	DCR	B
	JNZ	NEXT8
;;;	# DJNZ NEXT8
	INX	D
	POP	B
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	NXTCNT

	INX	H		; as started with dsm, not dsm+1
	SHLD	ALVZRO

; ---------------------- ;
; fill text with results ;
; ---------------------- ;

	LXI	H,ALV01
	SHLD	POSN
	XRA	A
	LHLD	DPB$DSM
	LXI	D,1
	DAD	D
	ACI	0
	MVI	C,0
	CALL	MEGDEC		; write total number of datablocks

	LXI	H,ALV02
	SHLD	POSN
	LHLD	ALVDIR		; datablocks allocated to directory
	CALL	WRDDEC

	LXI	H,ALV03
	SHLD	POSN
	LHLD	ALVDAT		; datablocks allocated to data
	CALL	WRDDEC

	LXI	H,ALV04
	SHLD	POSN
	LHLD	ALVERA		; datablocks allocated to erased data
	CALL	WRDDEC

	LXI	H,ALV05
	SHLD	POSN
	LHLD	ALVLST		; datablocks allocated to overwritten data
	CALL	WRDDEC

	LXI	H,ALV06
	SHLD	POSN
	LHLD	ALVBAD		; datablocks with duplicated data access
	CALL	WRDDEC

	LXI	H,ALV07
	SHLD	POSN
	LHLD	ALVZRO		; datablocks not allocated
	CALL	WRDDEC

	LXI	H,ALV08
	SHLD	POSN
	LHLD	ALVDIR
	XRA	A
	MOV	C,A
	XCHG
	LHLD	ALVDAT
	DAD	D
	ADC	C
	XCHG
	LHLD	ALVERA
	DAD	D
	ADC	C
	XCHG
	LHLD	ALVZRO
	DAD	D
	ADC	C
	MOV	C,A
	CALL	MEGDEC

	LXI	H,ALV09
	SHLD	POSN
	LHLD	ALVRNG		; datablocks with duplicated data access
	CALL	WRDDEC

; ------------ ;
; display text ;
; ------------ ;

	LXI	D,SALMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	JMP	WAITCR		; wait for <RETURN> then return

	DSEG
SALMSG:	DB	CR,'                     DRIVE '
SALDSK:	DB	'A: DISK ALLOCATION'
	DB	CR,LF
;
; [1.1] Reformatted into two columns to make room for the graphical
;       allocation map.
;
	DB	CR,LF,'                           DATA BLOCKS '
	DB	CR,LF
	DB	CR,LF,'      TOTAL (DRM+1)             '
ALV01:	DB	' 65536 '
	DB	CR,LF
	DB	CR,LF,'      Directory                 '
ALV02:	DB	'    16 '
	DB	CR,LF,'      Data                      '
ALV03:	DB	' 65535 '
	DB	'      Duplicated data           '
ALV06:	DB	' 65535 '
	DB	CR,LF,'      Erased and recoverable    '
ALV04:	DB	' 65535 '
	DB	'      Erased and reused         '
ALV05:	DB	' 65535 '
	DB	CR,LF,'      Unused                    '
ALV07:	DB	' 65535 '
	DB	'      Blocks outside range      '
ALV09:	DB	' 65535 '
	DB	CR,LF,'                                '
	DB	' ----- '
	DB	CR,LF, '                                '
ALV08:	DB	' 65536 '
	DB	CR,LF,LF
;
; [1.1] Display allocation
;
	DB	'    ---- Display of data block allocation '
	DB	'(first 256 bits only) ----'
	DB	CR,LF,'    '
	DB	'0....5...10...15...20...25...30...35...40...45...50...55...60...'
	DB	CR,LF
	DB	'  0 '
ALV11:	DB	'                                '
	DB	'                                '
	DB	CR,LF
	DB	' 64 '
ALV12:	DB	'                                '
	DB	'                                '
	DB	CR,LF
	DB	'128 '
ALV13:	DB	'                                '
	DB	'                                '
	DB	CR,LF
	DB	'196 '
ALV14:	DB	'                                '
	DB	'                                '
	DB	CR,LF
	DB	'256    '
BLOCK1:	DB	'# Directory  '
SOLID1:	DB	'+ Data block  '
HOLLO1:	DB	'- Erased block  '
DOT1:	DB	'. Unused          '
	DB	CR,LF,LF,LF
	DB	'$'
	CSEG

;------;
SHOWFIL:			; menu 1 option 4    Display file ALLOCATION
;------;
	LDA	DEF$DSK
	ADI	'A'
	STA	SFLDSK
	LXI	D,SFLMSG
	MVI	C,9		; BDOS: PRINT STRING
	JMP	BDOS		; & RETURN

	DSEG
SFLMSG:	DB	CR,'                     DRIVE '
SFLDSK:	DB	'A: FILE ALLOCATION'
	DB	LF
	DB	CR,LF,LF,LF,LF,LF,'$' ; 10 line feeds
	CSEG

;------;
SHOWDIR:			; menu 1 option 5    Display directory ALLOCATION 
;------;
	LDA	DEF$DSK
	ADI	'A'
	STA	SDRDSK
	LXI	D,SDRMSG
	MVI	C,9		; BDOS: PRINT STRING
	JMP	BDOS		; & RETURN

	DSEG
SDRMSG:	DB	CR,'                     DRIVE '
SDRDSK:	DB	'A: DIRECTORY ALLOCATION'
	DB	LF
	DB	CR,LF,LF,LF,LF,LF,'$' ; 10 line feeds
	CSEG

	PAGE

;-----;
SELECT:				; menu 1 option 9    Select new disk
;-----;

	LDA	DEF$DSK
	STA	OLDDSK		; save in case of error

	CALL	CLEARSCRN
	LXI	D,SLDMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

; ---------------------- ;
; Request new drive name ;
; ---------------------- ;

SEL0:
	LXI	D,LOGMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	LXI	D,SELBUFF
	MVI	C,10		; BDOS: DIRECT CONSOLE BUFFER
	CALL	BDOS
	LDA	SELLEN
	ORA	A
	RZ			; nothing selected
	CPI	1
	JZ	SEL1
	CPI	2
	JNZ	SEL0
	LDA	SELDB2
	CPI	':'
	JNZ	SEL0
SEL1:	LDA	SELDB1
	CPI	'a'
	JC	SEL2
	CPI	'z'+1
	JNC	SEL0
	ADI	'A'-'a'		; convert to lower case
SEL2:	SUI	'A'
	CPI	15+1
	JNC	SEL0		; outside range 0-15
	
	STA	DEF$DSK		; Current selected disk

	MVI	C,13		; BDOS: RESET DISK SYSTEM
	CALL	BDOS

	LDA	DEF$DSK
	MOV	E,A
	MVI	C,14		; BDOS: SELECT DISK
	CALL	BDOS
	ORA	A
	JNZ	SELERR

	CALL	FETCHDP		; fetch dpb and dph for drive

	RET

SELERR:	LDA	OLDDSK		; recover previously selecte disk
	STA	DEF$DSK
	MOV	E,A
	MVI	C,14		; BDOS: SELECT DISK
	CALL	BDOS
	ORA	A
	JNZ	BADSEL

	CALL	FETCHDP		; fetch dpb and dph for drive

	LXI	D,OLDMSG
	MVI	C,9		; BDOS: PRINT STRING
	CALL	BDOS

	CALL	WAITCR

	RET

	DSEG

SLDMSG:	DB	CR,'                     SELECT NEW DISK'
	DB	LF
	DB	CR,LF,LF,LF,LF,LF,'$' ; 5 line feeds

OLDDSK:	DB	0

LOGMSG:	DB	CR,'Enter drive name (A:, B:, etc ) ?    ',BS,BS,BS,'$'
SELBUFF:
	DB	3
SELLEN:
	DS	1
SELDB1:	DS	1
SELDB2:	DS	2

OLDMSG:	DB	CR,LF,'--- Unable to select new disk ---'
	DB	CR,LF,LF,LF,LF,LF,'$' ; 5 line feeds

	CSEG

	PAGE

;-------;
GOODVERS:
;-------;

	LDA	DEFFCB
	DCR	A
	CPI	-1
	JNZ	USECCP		; use ccp disk

	MVI	C,25		; BDOS: RETURN CURRENT DISK
	CALL	BDOS

USECCP:	STA	DEF$DSK		; Current selected disk

	MVI	C,13		; BDOS: RESET DISK SYSTEM
	CALL	BDOS

	LDA	DEF$DSK
	MOV	E,A
	MVI	C,14		; BDOS: SELECT DISK
	CALL	BDOS
	ORA	A
	JNZ	BADSEL

;;;	# LD (SAVESP),SP	; must use local stack as BIOS may be hungry
	LXI	H,0
	DAD	SP
	SHLD	SAVESP

	LXI	SP,SAVESP

	CALL	FETCHDP		; fetch dpb and dph for drive

	CALL	MAIN		; now display as requested

;;;	# LD SP,(SAVESP)
	LHLD	SAVESP
	SPHL

	MVI	C,0		; BDOS: SYSTEM RESET
	JMP	BDOS		; & exit

;---;
MAIN:
;---;

	CALL	CLEARSCRN	; clear screen
	CALL	SCREEN1		; display menu
	CALL	OPTION		; request option
	CPI	-1
	RZ

	CALL	TASK1
	JMP	MAIN

;----;
TASK1:
;----;

	MOV	C,A
	MVI	B,0
	DCX	B
	LXI	H,TABLE1
	DAD	B
	DAD	B
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL

TABLE1:	DW	SHOWBLK		; menu 1 option 1    Display DPB statistics
	DW	SHOWHDR		; menu 1 option 2    Display DPH statistics
	DW	SHOWALV		; menu 1 option 3    Display disk ALLOCATION
	DW	SHOWFIL		; menu 1 option 4    Display file ALLOCATION
	DW	SHOWDIR		; menu 1 option 5    Display directory ALLOCATION 
	DW	RETURN
	DW	RETURN
	DW	RETURN
	DW	SELECT		; menu 1 option 9    Select new disk

RETURN:	RET

	DSEG
ALLOC	EQU	$		; allocation vector placed at end of program
	END
;
;
;
;
; Line numbers containing untranslated opcodes:
;
; 00277 00344 00488 00563 00593 00609 00847 00869 00917 00930
; 01014 01099 01138 01149 01215 01276 01863 01895 01941 01954
; 01986 02000 02027 02045 02101 02117 02128 02191 02221 02237
; 02248 02283 02601 02608
;

