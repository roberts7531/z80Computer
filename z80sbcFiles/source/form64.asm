seldsk:		.equ	0E61Bh	;pass disk no. in c
setdma:		.equ	0E624h	;pass address in bc
settrk:		.equ	0E61Eh	;pass track in reg C
setsec:		.equ	0E621h	;pass sector in reg c
write:		.equ	0EA77h	;write one CP/M sector to disk

.org	5000h
		out (00h),a
		ld	sp,format_stack
		ld	a,00h	;starting disk
		ld	(disk),a
disk_loop:	ld	c,a	;CP/M disk a
		call 	seldsk
		ld	a,2	;starting track (offset = 2)
		ld	(track),a
track_loop:	ld	a,0	;starting sector
		ld	(sector),a
		ld	hl,directory_sector 	;address of data to write
		ld	(address),hl
		ld	a,(track)
		ld	c,a	;CP/M track
		call	settrk
sector_loop:	ld	a,(sector)
		ld	c,a	;CP/M sector
		call	setsec
		ld	bc,(address)	;memory location
		call	setdma
		call	write
		ld	a,(sector)
		cp	26
		jp	z,next_track
		inc	a
		ld	(sector),a
		jp	sector_loop
next_track:	ld	a,(track)
		cp	77
		jp	z,next_disk
		inc	a
		ld	(track),a
		jp	track_loop
next_disk:	ld	a,(disk)
		inc	a
		cp	4
		jp	z,done
		ld	(disk),a
		jp	disk_loop
done:	jp	0e600H
disk:	.db	00h
sector:	.db	00h
track:	.db	00h
address:	.dw	0000h
directory_sector:
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h   	;sector filled with 0E5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h   	;sector filled with 0E5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h
.db   	0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h,0e5h, 0e5h, 0e5h,0e5h
.ds	32	;stack space
format_stack:
.end
