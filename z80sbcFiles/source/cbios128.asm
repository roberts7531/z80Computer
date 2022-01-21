;==================================================================================
; Contents of this file are copyright Grant Searle
; Blocking/unblocking routines are the published version by Digital Research
; (bugfixed, as found on the web)
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

ccp		.EQU	0D000h		; Base of CCP.
bdos		.EQU	ccp + 0806h	; Base of BDOS.
bios		.EQU	ccp + 1600h	; Base of BIOS.

; Set CP/M low memory datA, vector and buffer addresses.

iobyte		.EQU	03h		; Intel standard I/O definition byte.
userdrv		.EQU	04h		; Current user number and drive.
tpabuf		.EQU	80h		; Default I/O buffer and command line storage.


SER_BUFSIZE	.EQU	60
SER_FULLSIZE	.EQU	50
SER_EMPTYSIZE	.EQU	5


RTS_HIGH	.EQU	0E8H
RTS_LOW		.EQU	0EAH

SIOA_D		.EQU	$00
SIOA_C		.EQU	$02
SIOB_D		.EQU	$01
SIOB_C		.EQU	$03

int38		.EQU	38H
nmi		.EQU	66H

blksiz		.equ	4096		;CP/M allocation size
hstsiz		.equ	512		;host disk sector size
hstspt		.equ	32		;host disk sectors/trk
hstblk		.equ	hstsiz/128	;CP/M sects/host buff
cpmspt		.equ	hstblk * hstspt	;CP/M sectors/track
secmsk		.equ	hstblk-1	;sector mask
					;compute sector mask
;secshf		.equ	2		;log2(hstblk)

wrall		.equ	0		;write to allocated
wrdir		.equ	1		;write to directory
wrual		.equ	2		;write to unallocated



; CF registers
CF_DATA		.EQU	$10
CF_FEATURES	.EQU	$11
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
CF_8BIT		.EQU	1
CF_NOCACHE	.EQU	082H
;CF Commands
CF_READ_SEC	.EQU	020H
CF_WRITE_SEC	.EQU	030H
CF_SET_FEAT	.EQU 	0EFH

LF		.EQU	0AH		;line feed
FF		.EQU	0CH		;form feed
CR		.EQU	0DH		;carriage RETurn

;================================================================================================

		.ORG	bios		; BIOS origin.

;================================================================================================
; BIOS jump table.
;================================================================================================
		JP	boot		;  0 Initialize.
wboote:		JP	wboot		;  1 Warm boot.
		JP	const		;  2 Console status.
		JP	conin		;  3 Console input.
		JP	conout		;  4 Console OUTput.
		JP	list		;  5 List OUTput.
		JP	punch		;  6 punch OUTput.
		JP	reader		;  7 Reader input.
		JP	home		;  8 Home disk.
		JP	seldsk		;  9 Select disk.
		JP	settrk		; 10 Select track.
		JP	setsec		; 11 Select sector.
		JP	setdma		; 12 Set DMA ADDress.
		JP	read		; 13 Read 128 bytes.
		JP	write		; 14 Write 128 bytes.
		JP	listst		; 15 List status.
		JP	sectran		; 16 Sector translate.

;================================================================================================
; Disk parameter headers for disk 0 to 15
;================================================================================================
		; disk Parameter header for disk 00
dpbase:	.DW 	0000h, 0000h
		.DW		0000h, 0000h
		.DW		dirbf, dpblk
		.DW		chk00, all00
; disk parameter header for disk 01
        .DW		0000h, 0000h
		.DW  	0000h, 0000h
		.DW		dirbf, dpblk
		.DW		chk01, all01
; disk parameter header for disk 02
        .DW		0000h, 0000h
		.DW  	0000h, 0000h
		.DW		dirbf, dpblk
		.DW		chk02, all02
; disk parameter header for disk 03
        .DW		0000h, 0000h
		.DW  	0000h, 0000h
		.DW		dirbf, dpblk
		.DW		chk03, all03
;
; sector translate vector
trans:	.DB 	1, 7, 13, 19	;sectors 1, 2, 3, 4
		.DB		25, 5, 11, 17	;sectors 5, 6, 7, 6
		.DB		23, 3, 9, 15	;sectors 9, 10, 11, 12
		.DB		21, 2, 8, 14	;sectors 13, 14, 15, 16
		.DB		20, 26, 6, 12 	;sectors 17, 18, 19, 20
		.DB		18, 24, 4, 10	;sectors 21, 22, 23, 24
		.DB		16, 22	;sectors 25, 26
;
dpblk: ;disk parameter block for all disks.
          	.DW  	26	;sectors per track
			.DB	3	;block shift factor
			.DB	7	;block mask
			.DB	0	;null mask
			.DW	242 	;disk size-1
			.DW	63	;directory max
			.DB	192	;alloc 0
			.DB	0	;alloc 1
			.DW	0	;check size
			.DW	2	;track offset
;
; end of fixed tables
;


;================================================================================================
; Cold boot
;================================================================================================

boot:
		DI				; Disable interrupts.
		LD	SP,biosstack		; Set default stack.

;		Turn off ROM

		LD	A,$01
		OUT ($00),A

;	Initialise SIO

		
		CALL	printInline
		.DB FF
		.TEXT "Z80 CP/M BIOS 1.0 by G. Searle 2007-13"
		.DB CR,LF
		.DB CR,LF
		.TEXT "CP/M 2.2 "
		.TEXT	"Copyright"
		.TEXT	" 1979 (c) by Digital Research"
		.DB CR,LF,0


		CALL	cfWait
		LD 	A,CF_8BIT	; Set IDE to be 8bit
		OUT	(CF_FEATURES),A
		LD	A,CF_SET_FEAT
		OUT	(CF_COMMAND),A


		CALL	cfWait
		LD 	A,CF_NOCACHE	; No write cache
		OUT	(CF_FEATURES),A
		LD	A,CF_SET_FEAT
		OUT	(CF_COMMAND),A

		XOR	a				; Clear I/O & drive bytes.
		LD	(userdrv),A

		LD	(serBufUsed),A
		LD	HL,serBuf
		LD	(serInPtr),HL
		LD	(serRdPtr),HL

		

		JP	gocpm

;================================================================================================
; Warm boot
;================================================================================================

wboot:
		DI				; Disable interrupts.
		LD	SP,biosstack		; Set default stack.



		

		LD	B,11 ; Number of sectors to reload

		LD	A,0
		LD	(hstsec),A
		LD	HL,ccp
rdSectors:

		CALL	cfWait

		LD	A,(hstsec)
		OUT 	(CF_LBA0),A
		LD	A,0
		OUT 	(CF_LBA1),A
		OUT 	(CF_LBA2),A
		LD	a,0E1H
		OUT 	(CF_LBA3),A
		LD 	A,1
		OUT 	(CF_SECCOUNT),A

		PUSH 	BC

		CALL 	cfWait

		LD 	A,CF_READ_SEC
		OUT 	(CF_COMMAND),A

		CALL 	cfWait

		LD 	c,2
rd4secs512:
		call 	cfWait
		LD 	b,128
rdByte512:
		in 	A,(CF_DATA)
		LD 	(HL),A
		iNC 	HL
		dec 	b
		JR 	NZ, rdByte512
		dec 	c
		JR 	NZ,rd4secs512

;mans
		CALL	cfWait

		LD	A,(hstsec)
		OUT 	(CF_LBA0),A
		LD	A,0
		OUT 	(CF_LBA1),A
		OUT 	(CF_LBA2),A
		LD	a,0E2H
		OUT 	(CF_LBA3),A
		LD 	A,1
		OUT 	(CF_SECCOUNT),A

		CALL 	cfWait

		LD 	A,CF_READ_SEC
		OUT 	(CF_COMMAND),A

		CALL 	cfWait

		LD 	c,2
rd4secs5122:
		call 	cfWait
		LD 	b,128
rdByte5122:
		in 	A,(CF_DATA)
		LD 	(HL),A
		iNC 	HL
		dec 	b
		JR 	NZ, rdByte5122
		dec 	c
		JR 	NZ,rd4secs5122

		POP 	BC

		LD	A,(hstsec)
		inc a
		LD	(hstsec),A

		djnz	rdSectors


;================================================================================================
; Common code for cold and warm boot
;================================================================================================

gocpm:
		xor	a			;0 to accumulator
		ld	(hstact),a		;host buffer inactive
		ld	(unacnt),a		;clear unalloc count

		LD	A,0C3h
		LD	($38),A
		LD	HL,serialInt		; ADDress of serial interrupt.
		LD	($39),HL

		LD	HL,tpabuf		; ADDress of BIOS DMA buffer.
		LD	(dmaAddr),HL
		LD	A,0C3h			; Opcode for 'JP'.
		LD	(00h),A			; Load at start of RAM.
		LD	HL,wboote		; ADDress of jump for a warm boot.
		LD	(01h),HL
		LD	(05h),A			; Opcode for 'JP'.
		LD	HL,bdos			; ADDress of jump for the BDOS.
		LD	(06h),HL
		LD	A,(userdrv)		; Save new drive number (0).
		LD	c,A			; Pass drive number in C.

		IM	1
		EI				; Enable interrupts

		JP	ccp			; Start CP/M by jumping to the CCP.

;================================================================================================
; Console I/O routines
;================================================================================================

serialInt:	PUSH     AF
                ld a,1
                out ($02),a
                PUSH     HL

intl:           IN A,($00)
                AND $2
                JP Z,intl

                IN       A,($01)
                PUSH     AF
                LD       A,(serBufUsed)
                CP       SER_BUFSIZE     ; If full then ignore
                JR       NZ,notFull
                POP      AF
                JR       rts0

notFull:        LD       HL,(serInPtr)
                INC      HL
                LD       A,L             ; Only need to check low byte becasuse buffer<256 bytes
                CP       (serBuf+SER_BUFSIZE) & $FF
                JR       NZ, notWrap
                LD       HL,serBuf
notWrap:        LD       (serInPtr),HL
                POP      AF
                LD       (HL),A
                LD       A,(serBufUsed)
                INC      A
                LD       (serBufUsed),A
                CP       SER_FULLSIZE
                JR       C,rts0
rts0:           

                POP      HL
		ld a,0
                out ($02),a
                POP      AF
                EI
                RETI

;------------------------------------------------------------------------------------------------
const:
		LD	A,(iobyte)
		AND	00001011b ; Mask off console and high bit of reader
		CP	00001010b ; redirected to reader on UR1/2 (Serial A)
		JR	constA
		
		
constA:
		PUSH	HL
		LD	A,(serBufUsed)
		CP	$00
		JR	Z, dataAEmpty
 		LD	A,0FFH
		POP	HL
		RET
dataAEmpty:
		LD	A,0
		POP	HL
        	RET



;------------------------------------------------------------------------------------------------
reader:		
		PUSH	HL
		PUSH	AF
reader2:	LD	A,(iobyte)
		AND	$08
		CP	$08
	
		JR	coninA
;------------------------------------------------------------------------------------------------
conin:
		PUSH	HL
		PUSH	AF
		LD	A,(iobyte)
		AND	$03
		CP	$02
		JR	Z,reader2	; "BAT:" redirect
		
		

coninA:
		POP	AF
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

		CP	SER_EMPTYSIZE
		JR	NC,rtsA1
	      
rtsA1:
		LD	A,(HL)
		EI

		POP	HL

		RET			; Char ready in A


		; Char ready in A

;------------------------------------------------------------------------------------------------
list:		PUSH	AF		; Store character
list2:		LD	A,(iobyte)
		AND	$C0
		CP	$40
		
		JR	conoutA1

;------------------------------------------------------------------------------------------------
punch:		PUSH	AF		; Store character
		LD	A,(iobyte)
		AND	$20
		CP	$20
		
		JR	conoutA1

;------------------------------------------------------------------------------------------------
conout:		PUSH	AF		; Store character
		LD	A,(iobyte)
		AND	$03
		CP	$02
		JR	Z,list2		; "BAT:" redirect
			
conoutA1:
TXALOOP1:       IN A,($00)
                AND $4
                JP Z,TXALOOP1
TXALOOP:        IN A,($00)
                AND $1
                JP NZ,TXALOOP
		LD	A,C
		OUT	($01),A		; OUTput the character
		POP	AF		; RETrieve character
		RET




;------------------------------------------------------------------------------------------------
CKSIOA
		SUB	A
		OUT 	(SIOA_C),A
		IN   	A,(SIOA_C)	; Status byte D2=TX Buff Empty, D0=RX char ready	
		RRCA			; Rotates RX status into Carry Flag,	
		BIT  	1,A		; Set Zero flag if still transmitting character	
        	RET

CKSIOB
		SUB	A
		OUT 	(SIOB_C),A
		IN   	A,(SIOB_C)	; Status byte D2=TX Buff Empty, D0=RX char ready	
		RRCA			; Rotates RX status into Carry Flag,	
		BIT  	1,A		; Set Zero flag if still transmitting character	
        	RET

;------------------------------------------------------------------------------------------------
listst:		LD	A,$FF		; Return list status of 0xFF (ready).
		RET

;================================================================================================
; Disk processing entry points
;================================================================================================

seldsk:			;select disk given by register c
		LD	HL, 0000h	;error return code
		LD	a, c
		LD	(hstdsk),A
		;CP	disks	;must be between 0 and 3
		;RET	NC	;no carry if 4, 5,...
;			disk number is in the proper range
;	defs	10	;space for disk select
;			compute proper disk Parameter header address
		LD	A,(hstdsk)
		LD	l, a	;l=disk number 0, 1, 2, 3
		LD	h, 0	;high order zero
		ADD 	HL,HL	;*2
		ADD	HL,HL	;*4
		ADD	HL,HL	;*8
		ADD	HL,HL	;*16 (size of each header)
		LD	DE, dpbase
		ADD	HL,DE	;hl=,dpbase (diskno*16). Note typo "DAD 0" here in original 8080 source.
		ret

chgdsk:		LD 	(sekdsk),A
		RLC	a		;*2
		RLC	a		;*4
		RLC	a		;*8
		RLC	a		;*16
		LD 	HL,dpbase
		LD	b,0
		LD	c,A	
		ADD	HL,BC

		RET

;------------------------------------------------------------------------------------------------
home:
		ld	a,(hstwrt)	;check for pending write
		or	a
		jr	nz,homed
		ld	(hstact),a	;clear host active flag
homed:
		LD 	BC,0000h

;------------------------------------------------------------------------------------------------
settrk:			;set track given by register c
		LD	a, c
		LD	(hsttrk),A
		ret

;------------------------------------------------------------------------------------------------
setsec:			;set sector given by register c
		LD	a, c
		LD	(hstsec),A
		ret

;------------------------------------------------------------------------------------------------
setdma:			;set dma address given by registers b and c
		LD	l, c	;low order address
		LD	h, b	;high order address
		LD	(dmaad),HL 	;save the address
		ret

;------------------------------------------------------------------------------------------------
sectran:	
		EX	DE,HL 	;hl=.trans
		ADD 	HL,BC	;hl=.trans (sector)
		ret		;debug no translation
;PUSH 	BC
;		POP 	HL
;		RET

;------------------------------------------------------------------------------------------------
read1:
		;read the selected CP/M sector
		xor	a
		ld	(unacnt),a
		ld	a,1
		ld	(readop),a		;read operation
		ld	(rsflag),a		;must read data
		ld	a,wrual
		ld	(wrtype),a		;treat as unalloc
		jp	rwoper			;to perform the read


;------------------------------------------------------------------------------------------------
write1:
		;write the selected CP/M sector
		xor	a		;0 to accumulator
		ld	(readop),a	;not a read operation
		ld	a,c		;write type in c
		ld	(wrtype),a
		cp	wrual		;write unallocated?
		jr	nz,chkuna	;check for unalloc
;
;		write to unallocated, set parameters
		ld	a,blksiz/128	;next unalloc recs
		ld	(unacnt),a
		ld	a,(sekdsk)		;disk to seek
		ld	(unadsk),a		;unadsk = sekdsk
		ld	hl,(sektrk)
		ld	(unatrk),hl		;unatrk = sectrk
		ld	a,(seksec)
		ld	(unasec),a		;unasec = seksec
;
chkuna:
;		check for write to unallocated sector
		ld	a,(unacnt)		;any unalloc remain?
		or	a	
		jr	z,alloc		;skip if not
;
;		more unallocated records remain
		dec	a		;unacnt = unacnt-1
		ld	(unacnt),a
		ld	a,(sekdsk)		;same disk?
		ld	hl,unadsk
		cp	(hl)		;sekdsk = unadsk?
		jp	nz,alloc		;skip if not
;
;		disks are the same
		ld	hl,unatrk
		call	sektrkcmp	;sektrk = unatrk?
		jp	nz,alloc		;skip if not
;
;		tracks are the same
		ld	a,(seksec)		;same sector?
		ld	hl,unasec
		cp	(hl)		;seksec = unasec?
		jp	nz,alloc		;skip if not
;
;		match, move to next sector for future ref
		inc	(hl)		;unasec = unasec+1
		ld	a,(hl)		;end of track?
		cp	cpmspt		;count CP/M sectors
		jr	c,noovf		;skip if no overflow
;
;		overflow to next track
		ld	(hl),0		;unasec = 0
		ld	hl,(unatrk)
		inc	hl
		ld	(unatrk),hl		;unatrk = unatrk+1
;
noovf:
		;match found, mark as unnecessary read
		xor	a		;0 to accumulator
		ld	(rsflag),a		;rsflag = 0
		jr	rwoper		;to perform the write
;
alloc:
		;not an unallocated record, requires pre-read
		xor	a		;0 to accum
		ld	(unacnt),a		;unacnt = 0
		inc	a		;1 to accum
		ld	(rsflag),a		;rsflag = 1

;------------------------------------------------------------------------------------------------
rwoper:
		;enter here to perform the read/write
		xor	a		;zero to accum
		ld	(erflag),a		;no errors (yet)
		ld	a,(seksec)		;compute host sector
		or	a		;carry = 0
		rra			;shift right
		or	a		;carry = 0
		rra			;shift right
		ld	(sekhst),a		;host sector to seek
;
;		active host sector?
		ld	hl,hstact	;host active flag
		ld	a,(hl)
		ld	(hl),1		;always becomes 1
		or	a		;was it already?
		jr	z,filhst		;fill host if not
;
;		host buffer active, same as seek buffer?
		ld	a,(sekdsk)
		ld	hl,hstdsk	;same disk?
		cp	(hl)		;sekdsk = hstdsk?
		jr	nz,nomatch
;
;		same disk, same track?
		ld	hl,hsttrk
		call	sektrkcmp	;sektrk = hsttrk?
		jr	nz,nomatch
;
;		same disk, same track, same buffer?
		ld	a,(sekhst)
		ld	hl,hstsec	;sekhst = hstsec?
		cp	(hl)
		jr	z,match		;skip if match
;
nomatch:
		;proper disk, but not correct sector
		ld	a,(hstwrt)		;host written?
		or	a
		call	nz,writehst	;clear host buff
;
filhst:
		;may have to fill the host buffer
		ld	a,(sekdsk)
		ld	(hstdsk),a
		ld	hl,(sektrk)
		ld	(hsttrk),hl
		ld	a,(sekhst)
		ld	(hstsec),a
		ld	a,(rsflag)		;need to read?
		or	a
		call	nz,readhst		;yes, if 1
		xor	a		;0 to accum
		ld	(hstwrt),a		;no pending write
;
match:
		;copy data to or from buffer
		ld	a,(seksec)		;mask buffer number
		and	secmsk		;least signif bits
		ld	l,a		;ready to shift
		ld	h,0		;double count
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
;		hl has relative host buffer address
		ld	de,hstbuf
		add	hl,de		;hl = host address
		ex	de,hl			;now in DE
		ld	hl,(dmaAddr)		;get/put CP/M data
		ld	c,128		;length of move
		ld	a,(readop)		;which way?
		or	a
		jr	nz,rwmove		;skip if read
;
;	write operation, mark and switch direction
		ld	a,1
		ld	(hstwrt),a		;hstwrt = 1
		ex	de,hl			;source/dest swap
;
rwmove:
		;C initially 128, DE is source, HL is dest
		ld	a,(de)		;source character
		inc	de
		ld	(hl),a		;to dest
		inc	hl
		dec	c		;loop 128 times
		jr	nz,rwmove
;
;		data has been moved to/from host buffer
		ld	a,(wrtype)		;write type
		cp	wrdir		;to directory?
		ld	a,(erflag)		;in case of errors
		ret	nz			;no further processing
;
;		clear host buffer for directory write
		or	a		;errors?
		ret	nz			;skip if so
		xor	a		;0 to accum
		ld	(hstwrt),a		;buffer written
		call	writehst
		ld	a,(erflag)
		ret

;------------------------------------------------------------------------------------------------
;Utility subroutine for 16-bit compare
sektrkcmp:
		;HL = .unatrk or .hsttrk, compare with sektrk
		ex	de,hl
		ld	hl,sektrk
		ld	a,(de)		;low byte compare
		cp	(HL)		;same?
		ret	nz			;return if not
;		low bytes equal, test high 1s
		inc	de
		inc	hl
		ld	a,(de)
		cp	(hl)	;sets flags
		ret

;================================================================================================
; Convert track/head/sector into LBA for physical access to the disk
;================================================================================================


;================================================================================================
; Read physical sector from host
;================================================================================================

read:
		;Read one CP/M sector from disk.
		;Return a 00h in register a if the operation completes properly, and 01h if an error occurs during the read.
		;Disk number in 'diskno'
		;Track number in 'track'
		;Sector number in 'sector'
		;Dma address in 'dmaad' (0-65535)
			ld	hl,hstbuf	;buffer to place disk sector (256 bytes)
rd_status_loop_1:	in	a,(CF_STATUS)	;check status
readhst:			and	80h	;check BSY bit
			jp	nz,rd_status_loop_1	;loop until not busy
rd_status_loop_2:	in	a,(CF_STATUS)	;check status
			and	40h	;check DRDY bit
			jp	z,rd_status_loop_2	;loop until ready
			ld	a,01h	;number of sectors = 1
			out	(CF_SECCOUNT),a	;sector count register
			ld	a,(hstsec)	;sector
			out	(CF_LBA0),a	;lba bits 0 - 7
			ld	a,(hsttrk)	;track
			out	(CF_LBA1),a	;lba bits 8 - 15
			ld	a,(hstdsk)	;disk (only bits 16 and 17 used)
			out	(CF_LBA2),a	;lba bits 16 - 23
			ld	a,11100000b	;LBA mode, select host drive 0
			out	(CF_LBA3),a	;drive/head register
			ld	a,20h	;Read sector command
			out	(CF_STATUS),a
rd_wait_for_DRQ_set:	in	a,(CF_STATUS)	;read status
			and	08h	;DRQ bit
			jp	z,rd_wait_for_DRQ_set	;loop until bit set
rd_wait_for_BSY_clear: 	in	a,(CF_STATUS)
			and	80h
			jp	nz,rd_wait_for_BSY_clear
			;in	a,(0fh)	;clear INTRQ
read_loop:	in	a,(CF_DATA)	;get data
			ld	(hl),a
			inc	hl
			in	a,(CF_STATUS)	;check status
			and	08h	;DRQ bit
			jp	nz,read_loop	;loop until clear
			ld	hl,(dmaad)	;memory location to place data read from disk
			ld	de,hstbuf	;host buffer
			ld	b,128	;size of CP/M sector
rd_sector_loop:	ld	a,(de)	;get byte from host buffer
			ld	(hl),a	;put in memory
			inc	hl
			inc	de
			djnz 	rd_sector_loop	;put 128 bytes into memory
			in	a,(CF_STATUS)	;get status
			and	01h	;error bit
			ret
;================================================================================================
; Write physical sector to host
;================================================================================================

write:
		ld	hl,(dmaad)	;memory location of data to write
writehst:		ld	de,hstbuf	;host buffer
		ld	b,128	;size of CP/M sector
wr_sector_loop:	ld	a,(hl)	;get byte from memory
		ld	(de),a	;put in host buffer
		inc	hl
		inc	de
		djnz 	wr_sector_loop	;put 128 bytes in host buffer
		ld	hl,hstbuf	;location of data to write to disk
wr_status_loop_1:	in	a,(CF_STATUS)	;check status
		and	80h	;check BSY bit
		jp	nz,wr_status_loop_1	;loop until not busy
wr_status_loop_2:	in	a,(CF_STATUS)	;check status
		and	40h	;check DRDY bit
		jp	z,wr_status_loop_2	;loop until ready
		ld	a,01h	;number of sectors = 1
		out	(CF_SECCOUNT),a	;sector count register
		ld	a,(hstsec)
		out	(CF_LBA0),a	;lba bits 0 - 7 = "sector"
		ld	a,(hsttrk)
		out	(CF_LBA1),a	;lba bits 8 - 15 = "track"
		ld	a,(hstdsk)
		out	(CF_LBA2),a	;lba bits 16 - 23, use 16 to 20 for "disk"
		ld	a,11100000b	;LBA mode, select drive 0
		out	(CF_LBA3),a	;drive/head register
		ld	a,30h	;Write sector command
		out	(CF_COMMAND),a
wr_wait_for_DRQ_set:	in	a,(CF_STATUS)	;read status
		and	08h	;DRQ bit
		jp	z,wr_wait_for_DRQ_set 	;loop until bit set
write_loop:	ld	a,(hl)
		out	(CF_DATA),a	;write data
		inc	hl
		in	a,(CF_STATUS)	;read status
		and	08h	;check DRQ bit
		jp	nz,write_loop	;write until bit cleared
wr_wait_for_BSY_clear: 	in	a,(CF_STATUS)
		and	80h
		jp	nz,wr_wait_for_BSY_clear
		and	01h	;check for error
		ret

;================================================================================================
; Wait for disk to be ready (busy=0,ready=1)
;================================================================================================
cfWait:
		PUSH 	AF
cfWait1:
		in 	A,(CF_STATUS)
		AND 	080H
		cp 	080H
		JR	Z,cfWait1
		POP 	AF
		RET
cfWaitDRQ:
		push	af
cfWaitDRQ1:
		in 	A,(CF_STATUS)
		AND 	008H
		cp 	008H
		JR	NZ,cfWaitDRQ1
		POP 	AF
		RET

;================================================================================================
; Utilities
;================================================================================================

printInline:
		EX 	(SP),HL 	; PUSH HL and put RET ADDress into HL
		PUSH 	AF
		PUSH 	BC
nextILChar:	LD 	A,(HL)
		CP	0
		JR	Z,endOfPrint
		LD  	C,A
		CALL 	conout		; Print to TTY
		iNC 	HL
		JR	nextILChar
endOfPrint:	INC 	HL 		; Get past "null" terminator
		POP 	BC
		POP 	AF
		EX 	(SP),HL 	; PUSH new RET ADDress on stack and restore HL
		RET

;================================================================================================
; Data storage
;================================================================================================

dirbf: 		.ds 128 		;scratch directory area
all00: 		.ds 31			;allocation vector 0
all01: 		.ds 31			;allocation vector 1
all02: 		.ds 31			;allocation vector 0
all03: 		.ds 31			;allocation vector 1
chk00:		.ds 16
chk01:		.ds 16
chk02:		.ds 16
chk03:		.ds 16

lba0		.DB	00h
lba1		.DB	00h
lba2		.DB	00h
lba3		.DB	00h

		.DS	020h		; Start of BIOS stack area.
biosstack:	.EQU	$

sekdsk:		.ds	1		;seek disk number
sektrk:		.ds	2		;seek track number
seksec:		.ds	2		;seek sector number
;
hstdsk:		.ds	1		;host disk number
hsttrk:		.ds	2		;host track number
hstsec:		.ds	1		;host sector number
;
sekhst:		.ds	1		;seek shr secshf
hstact:		.ds	1		;host active flag
hstwrt:		.ds	1		;host written flag
;
unacnt:		.ds	1		;unalloc rec cnt
unadsk:		.ds	1		;last unalloc disk
unatrk:		.ds	2		;last unalloc track
unasec:		.ds	1		;last unalloc sector
;
erflag:		.ds	1		;error reporting
rsflag:		.ds	1		;read sector flag
readop:		.ds	1		;1 if read operation
wrtype:		.ds	1		;write operation type
dmaAddr:	.ds	2		;last dma address
hstbuf:		.ds	512		;host buffer
dmaad:		.ds 2

hstBufEnd:	.EQU	$

serBuf:	.ds	SER_BUFSIZE	; SIO A Serial buffer
serInPtr	.DW	00h
serRdPtr	.DW	00h
serBufUsed	.DB	00h


serialVarsEnd:	.EQU	$


biosEnd:	.EQU	$

; Disable the ROM, pop the active IO port from the stack (supplied by monitor),
; then start CP/M
popAndRun:
		LD	A,$01 
		OUT	($00),A

		POP	AF
		CP	$01
		JR	Z,consoleAtB
		LD	A,$01 ;(List is TTY:, Punch is TTY:, Reader is TTY:, Console is CRT:)
		JR	setIOByte
consoleAtB:	LD	A,$00 ;(List is TTY:, Punch is TTY:, Reader is TTY:, Console is TTY:)
setIOByte:	LD (iobyte),A
		JP	bios

;	IM 2 lookup for serial interrupt

		.org	0FFE0H
		.dw	serialInt


;=================================================================================
; Relocate TPA area from 4100 to 0100 then start CP/M
; Used to manually transfer a loaded program after CP/M was previously loaded
;=================================================================================

		.org	0FFE8H
		LD	A,$01
		OUT	($00),A

		LD	HL,04100H
		LD	DE,00100H
		LD	BC,08F00H
		LDIR
		JP	bios

;=================================================================================
; Normal start CP/M vector
;=================================================================================

		.ORG 0FFFEH
		.dw	popAndRun

		.END
