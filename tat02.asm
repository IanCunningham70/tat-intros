
;---------------------------------------
; TAT Intro V2 (FLD+Text)
;---------------------------------------
logodata = $2400
logoline = $0400+(40*0)
logocols = $d400+logoline
         ;
aline    = $0400+(40*17)
acols    = $d400+aline
apage    = $aa
atext    = $0c00
         ;
tline    = 1024+(40*9)
ttext    = $0b40
;---------------------------------------
         *= $080d
         ;
         sei
         ldx #$ff
         txs
         lda #$00
         sta $d021
         sta 646
         jsr $e544
         lda #$00
         sta $d020
         sta $d021
         sta 650
         lda #$80
         sta 657
         ;
         ldx #$00
dologo   lda logodata,x
         sta logoline,x
         lda logodata+(40*4),x
         sta logoline+(40*4),x
         lda #$08
         sta logocols,x
         sta logocols+(40*4),x
         inx
         cpx #(40*4)
         bne dologo
         ;
         jsr ainit
         lda #$00
         jsr $1000
         ;
         ldy #39
col1x1   lda acolors,y
         sta acols,y
         lda #$c0+32
         sta aline,y
         lda ttext,y
         clc
         adc #$c0
         sta tline,y
         lda ttext+40,y
         clc
         adc #$c0
         sta tline+80,y
         lda ttext+80,y
         clc
         adc #$c0
         sta tline+160,y
         lda #$0f
         sta tline+$d400,y
         sta tline+$d450,y
         sta tline+$d4a0,y
         dey
         bpl col1x1
         ;
         lda $3fff
         sta fldbyte
         lda #$ff
         sta $3fff
         ;
         lda #$7f
         sta $dc0d
         lda $dc0d
         lda #$1b
         sta $d011
         lda #216
         sta $d016
         lda #$32
         sta $d012
         lda #$01
         sta $d019
         sta $d01a
         ldy #>irq
         ldx #<irq
         sty $0315
         stx $0314
         cli
         ;
keyscan  jsr $ffe4
         cmp #" "
         bne keyscan
         ;
         lda fldbyte
         sta $3fff
         sei
         jsr $ffe4
         lda #$00
         ldx #$40
i0f08    sta $d400,x
         dex
         bne i0f08
         sei
         jsr $ff5b
         jsr $fd15
         jsr $e3bf
         jsr $fda3
         cli
         ldx #$40
i0f22    lda f0f46,x
         sta $033c,x
         dex
         bpl i0f22
         lda $2e
         sec
         sbc #$0c
         sta $2e
         lda $2d
         sec
         sbc #$29
         bcs i0f3b
         dec $2e
i0f3b    sta $2d
         lda #$08
         sta $ba
         jmp $033c
;---------------------------------------
f0f46    sei
         lda #$34
         sta $01
         ldx #$00
i0f4d    lda $2800,x
         sta $0801,x
         ldy #$37
         sty $01
         bit $d418
         ldy #$34
         sty $01
         inx
         bne i0f4d
         lda $0345
         cmp #$00
         beq i0f71
         inc $0345
         inc $0348
         jmp $0341
i0f71    lda #$00
         sta $0800
         sta $d418
         lda #$37
         sta $01
         cli
         jmp $080d
;---------------------------------------
irq
         lda #24
         sta $d018
         lda #216
         sta $d016
         lda #$09
         sta $d021
         lda #$08
         sta $d022
         lda #$0a
         sta $d023
         ;
         jsr ascroll
         ;
         ldx #(8*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda #$00
         sta $d021
         lda #200
         sta $d016
         ;
         ldx #(16*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         ;
         jsr fld
         ;
         lda $d016
         and #$f0
         ora axpos
         sta $d016
         ;
         ldx #$f9
         cpx $d012
         bne *-3
         lda #216
         sta $d016
         lda #$1b
         sta $d011
         ;
         jsr $1003
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
ascroll  lda axpos
         sec
         sbc #$03
         and #$07
         sta axpos
         bcc ashift
         rts
ashift   ldx #$00
ashift1  lda aline+1,x
         sta aline,x
         inx
         cpx #40
         bne ashift1
         jsr anext
         clc
         adc #$c0
         sta aline+39
         rts
ainit    ldx #<atext
         ldy #>atext
         stx apage
         sty apage+1
         rts
anext    ldy #$00
         lda (apage),y
         bne anext1
         jsr ainit
         jmp anext
anext1   inc apage
         bne anext2
         inc apage+1
anext2   rts
;---------------------------------------
axpos    .byte $00
fldbyte  .byte $00
         ;
acolors  .byte $00,$06,$02,$04,$0a
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0a,$08,$02,$09,$00
;---------------------------------------
fldno    = *+1
fld      ldy #$00
         lda fldsinus,y
         lsr a
         lsr a
         lsr a
         lsr a
         clc
         adc #$01
         tax
fldloop  lda $d012
         cmp $d012
         beq *-3
         and #$07
         ora #$18
         sta $d011
         dex
         bne fldloop
         lda fldno
         clc
         adc #$06
         sta fldno
         rts
;---------------------------------------
fldsinus .byte $80,$83,$86,$89,$8c,$8f
         .byte $92,$95,$98,$9b,$9e,$a1
         .byte $a4,$a7,$aa,$ad,$b0,$b3
         .byte $b6,$b9,$bb,$be,$c1,$c3
         .byte $c6,$c9,$cb,$ce,$d0,$d2
         .byte $d5,$d7,$d9,$db,$de,$e0
         .byte $e2,$e4,$e6,$e7,$e9,$eb
         .byte $ec,$ee,$f0,$f1,$f2,$f4
         .byte $f5,$f6,$f7,$f8,$f9,$fa
         .byte $fb,$fb,$fc,$fd,$fd,$fe
         .byte $fe,$fe,$fe,$fe,$ff,$fe
         .byte $fe,$fe,$fe,$fe,$fd,$fd
         .byte $fc,$fb,$fb,$fa,$f9,$f8
         .byte $f7,$f6,$f5,$f4,$f2,$f1
         .byte $f0,$ee,$ec,$eb,$e9,$e7
         .byte $e6,$e4,$e2,$e0,$de,$db
         .byte $d9,$d7,$d5,$d2,$d0,$ce
         .byte $cb,$c9,$c6,$c3,$c1,$be
         .byte $bb,$b9,$b6,$b3,$b0,$ad
         .byte $aa,$a7,$a4,$a1,$9e,$9b
         .byte $98,$95,$92,$8f,$8c,$89
         .byte $86,$83,$80,$7c,$79,$76
         .byte $73,$70,$6d,$6a,$67,$64
         .byte $61,$5e,$5b,$58,$55,$52
         .byte $4f,$4c,$49,$46,$44,$41
         .byte $3e,$3c,$39,$36,$34,$31
         .byte $2f,$2d,$2a,$28,$26,$24
         .byte $21,$1f,$1d,$1b,$19,$18
         .byte $16,$14,$13,$11,$0f,$0e
         .byte $0d,$0b,$0a,$09,$08,$07
         .byte $06,$05,$04,$04,$03,$02
         .byte $02,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $02,$02,$03,$04,$04,$05
         .byte $06,$07,$08,$09,$0a,$0b
         .byte $0d,$0e,$0f,$11,$13,$14
         .byte $16,$18,$19,$1b,$1d,$1f
         .byte $21,$24,$26,$28,$2a,$2d
         .byte $2f,$31,$34,$36,$39,$3c
         .byte $3e,$41,$44,$46,$49,$4c
         .byte $4f,$52,$55,$58,$5b,$5e
         .byte $61,$64,$67,$6a,$6d,$70
         .byte $73,$76,$79,$7c
;---------------------------------------
