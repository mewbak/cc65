;
; Ullrich von Bassewitz, 06.08.1998
;
; void cputcxy (unsigned char x, unsigned char y, char c);
; void cputc (char c);
;

    	.export	       	_cputcxy, _cputc, cputdirect, putchar
	.export		advance, newline, plot
	.import		popa, _gotoxy
	.import		xsize, revers

	.include	"pet.inc"
	.include	"../cbm/cbm.inc"

_cputcxy:
	pha	    	    	; Save C
	jsr	popa	    	; Get Y
	jsr	_gotoxy	    	; Set cursor, drop x
	pla		    	; Restore C

; Plot a character - also used as internal function

_cputc: cmp    	#$0A  	    	; CR?
    	bne	L1
    	lda	#0
    	sta	CURS_X
       	beq    	plot	    	; Recalculate pointers

L1: 	cmp	#$0D  	    	; LF?
       	bne	L2
	ldy	CURS_Y
	iny
	bne	newline	    	; Recalculate pointers

; Printable char of some sort

L2:    	cmp	#' '
    	bcc	cputdirect  	; Other control char
    	tay
    	bmi	L10
    	cmp	#$60
    	bcc	L3
    	and	#$DF
    	bne	cputdirect  	; Branch always
L3: 	and	#$3F

cputdirect:
	jsr	putchar	    	; Write the character to the screen

; Advance cursor position

advance:
   	iny
   	cpy	xsize
   	bne	L9
   	ldy	#0    	    	; new line
newline:
   	clc
   	lda	xsize
   	adc	SCREEN_PTR
   	sta	SCREEN_PTR
   	bcc	L4
   	inc	SCREEN_PTR+1
L4:	inc	CURS_Y
L9:    	sty	CURS_X
   	rts

; Handle character if high bit set

L10:	and	#$7F
       	cmp    	#$7E 	    	; PI?
	bne	L11
	lda	#$5E 	    	; Load screen code for PI
	bne	cputdirect
L11:	ora	#$40
	bne	cputdirect



; Set cursor position, calculate RAM pointers

plot:	ldy	CURS_Y
	lda	ScrLo,y
	sta	SCREEN_PTR
	lda	ScrHi,y
	ldy	xsize
	cpy	#40
       	beq	@L1
       	asl    	SCREEN_PTR		; 80 column mode
 	rol	a
@L1:	ora	#$80			; Screen at $8000
	sta	SCREEN_PTR+1
	rts


; Write one character to the screen without doing anything else, return X
; position in Y

putchar:
    	ora	revers	  	; Set revers bit
       	ldy    	CURS_X
	sta	(SCREEN_PTR),y	; Set char
	rts

; Screen address tables - offset to real screen

.rodata

ScrLo: 	.byte  	$00, $28, $50, $78, $A0, $C8, $F0, $18
	.byte	$40, $68, $90, $B8, $E0, $08, $30, $58
	.byte	$80, $A8, $D0, $F8, $20, $48, $70, $98
	.byte	$C0

ScrHi:	.byte	$00, $00, $00, $00, $00, $00, $00, $01
	.byte	$01, $01, $01, $01, $01, $02, $02, $02
	.byte	$02, $02, $02, $02, $03, $03, $03, $03
	.byte	$03


