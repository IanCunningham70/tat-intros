

;---------------------------------------
;TAT Intro 8
;---------------------------------------
picdata  = $5400
spage    = $aa
spage2   = spage+2
schars   = $4800
stext    = $5000
volbyte  = $15b4
;---------------------------------------
         *= $4a00
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
         lda #$ad
         sta byte1
         sta byte0
         lda #$00
         sta $3fff
         ;
         ldx #$00
         lda #$00
wipespr  sta $0800,x
         sta $0900,x
         sta $0a00,x
         sta $0b00,x
         sta $0c00,x
         sta $0d00,x
         sta $0e00,x
         sta $0f00,x
         sta $2000,x
         sta $2100,x
         sta $2200,x
         sta $2300,x
         sta $2400,x
         sta $2500,x
         sta $2600,x
         sta $2700,x
         sta $2800,x
         sta $2900,x
         sta $2a00,x
         sta $2b00,x
         sta $2c00,x
         sta $2d00,x
         sta $2e00,x
         sta $2f00,x
         sta $3000,x
         sta $3100,x
         sta $3200,x
         sta $3300,x
         sta $3400,x
         sta $3500,x
         sta $3600,x
         sta $3700,x
         sta $3800,x
         sta $3900,x
         sta $3a00,x
         sta $3b00,x
         sta $3c00,x
         sta $3d00,x
         sta $3e00,x
         inx
         bne wipespr
         ;
         ldx #$00
drawpic  lda $3f40,x
         sta $0400,x
         lda $403f,x
         sta $04ff,x
         lda $413e,x
         sta $05fe,x
         lda $423d,x
         sta $06fd,x
         lda $4338,x
         sta $d800,x
         lda $4437,x
         sta $d8ff,x
         lda $4536,x
         sta $d9fe,x
         lda $4635,x
         sta $dafd,x
         inx
         bne drawpic
         ;
         lda #$3f
         sta $04bf
         ;
         lda #$00
         jsr $1000
         jsr spset
         jsr spoint
         jsr sinit
         ;
         lda #$7f
         sta $dc0d
         lda #$1b
         sta $d011
         lda #$20
         sta $d012
         lda #$01
         sta $d019
         sta $d01a
         ldx #<progirq
         ldy #>progirq
         stx $0314
         sty $0315
         ldx #<restore
         ldy #>restore
         stx $0318
         sty $0319
         cli
         ;
         lda #$20
         sta byte2
wait1    jmp wait1
         ;
keyscan  jsr $ffe4
         cmp #$20
         bne keyscan
         ;
         lda #$ad
         sta byte0
         lda #$20
         sta byte4
wait2    jmp wait2
         ;
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
         nop
         nop
f0f46    sei
         lda #$34
         sta $01
         ldx #$00
i0f4d    lda $7300,x
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
restore  rti
;---------------------------------------
progirq  ;
color    = *+1
         lda #$00
         sta $d020
         sta $d021
         ;
         lda $d016
         ora #$10
         sta $d016
         lda $d011
         ora #$20
         sta $d011
         lda $d018
         ora #$08
         sta $d018
         ;
         ldx #$34
         cpx $d012
         bne *-3
         lda #$3b
         sta $d011
         ;
         jsr $1003
         ;
byte0    lda spscroll
byte1    lda pageon
byte2    lda fadeon
         ;
         ; ----------------------------
         ;
byte4    lda pageoff
byte5    lda fadeoff
byte6    lda voloff
         ;
         ldx #$f8
         cpx $d012
         bne *-3
         lda #$33
         sta $d011
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
pageon   ldy xvalue
         ldx random,y
         ;
         lda #>picdata
         sta l1+2
         lda #$20
         sta s1+2
         ldy #$60
l1       lda picdata,x
s1       sta $2000,x
         inc l1+2
         inc s1+2
         iny
         cpy #$7e
         bne l1

         lda xvalue
         cmp #$ff
         beq pageon2
         inc xvalue
         rts
pageon2  lda #$00
         sta xvalue
         lda #$ad
         sta byte1
         sta wait1
         lda #$20
         sta byte0
         rts
;---------------------------------------
pageoff  ldy xvalue
         ldx random,y
         ;
         lda #$20
         sta k9+2
         ldy #$60
killer   lda #$00
k9       sta $2000,x
         inc k9+2
         iny
         cpy #$7e
         bne killer

         lda #$08
         sta tog+2
         ldy #$08
killer2  lda #$00
tog      sta $0800,x
         inc tog+2
         iny
         cpy #$0f
         bne killer2

         lda xvalue
         cmp #$ff
         beq pageof2
         inc xvalue
         rts
pageof2  lda #$00
         sta xvalue
         lda #$ad
         sta byte4
         lda #$20
         sta byte5
         rts
;---------------------------------------
xvalue   .byte $00
;---------------------------------------
random   .byte $d8,$56,$1f,$40,$5f,$52
         .byte $fd,$25,$95,$4d,$b2,$e4
         .byte $43,$bd,$b8,$d2,$32,$7d
         .byte $08,$14,$54,$f6,$2a,$03
         .byte $0a,$a9,$59,$a8,$4a,$0e
         .byte $73,$5d,$84,$2c,$75,$6a
         .byte $4b,$8d,$9e,$10,$8f,$c2
         .byte $f4,$b5,$c8,$93,$ca,$80
         .byte $8b,$82,$a5,$9c,$96,$3d
         .byte $e1,$2d,$11,$be,$da,$af
         .byte $27,$13,$b6,$70,$d5,$21
         .byte $a0,$45,$f2,$6f,$bb,$48
         .byte $2e,$06,$5c,$b0,$eb,$20
         .byte $e6,$66,$fa,$1b,$30,$17
         .byte $5a,$dd,$8a,$09,$28,$ee
         .byte $3a,$31,$51,$60,$71,$f7
         .byte $77,$ae,$65,$c1,$de,$26
         .byte $e9,$ad,$81,$db,$6e,$9f
         .byte $16,$4c,$c0,$e0,$6c,$49
         .byte $68,$ff,$1d,$e8,$4e,$c5
         .byte $df,$ea,$ed,$c4,$19,$a7
         .byte $7f,$d4,$ab,$29,$1c,$0f
         .byte $89,$f5,$07,$46,$15,$e7
         .byte $9b,$fc,$91,$d7,$f3,$1e
         .byte $72,$01,$d3,$78,$4f,$8e
         .byte $dc,$bf,$cb,$3e,$02,$50
         .byte $87,$9a,$2b,$c3,$cc,$83
         .byte $62,$fe,$5e,$b4,$67,$5b
         .byte $b3,$1a,$a4,$76,$f8,$57
         .byte $92,$2f,$6d,$f9,$79,$97
         .byte $b1,$d6,$aa,$7e,$88,$58
         .byte $86,$e5,$7a,$05,$3b,$44
         .byte $33,$cf,$0b,$64,$b7,$a6
         .byte $63,$f0,$ac,$61,$ec,$90
         .byte $0c,$e2,$34,$41,$22,$c9
         .byte $b9,$98,$37,$39,$12,$c7
         .byte $04,$d0,$a3,$23,$69,$a2
         .byte $ce,$94,$99,$35,$0d,$74
         .byte $bc,$24,$a1,$53,$c6,$85
         .byte $38,$36,$42,$00,$d1,$6b
         .byte $d9,$3f,$55,$7c,$ba,$47
         .byte $8c,$7b,$fb,$e3,$f1,$18
         .byte $9d,$ef,$3c,$cd
;---------------------------------------
spscroll lda sxpos
         cmp #$08
         bmi sprite1
         nop
         nop
         nop
sprite1  ldx #$00
         clc
spr1     rol $0ac8,x
         rol $0ac7,x
         rol $0ac6,x
         rol $0a88,x
         rol $0a87,x
         rol $0a86,x
         rol $0a48,x
         rol $0a47,x
         rol $0a46,x
         rol $0a08,x
         rol $0a07,x
         rol $0a06,x
         rol $09c8,x
         rol $09c7,x
         rol $09c6,x
         rol $0988,x
         rol $0987,x
         rol $0986,x
         rol $0948,x
         rol $0947,x
         rol $0946,x
         rol $0908,x
         rol $0907,x
         rol $0906,x
         rol $08c8,x
         rol $08c7,x
         rol $08c6,x
         inx
         inx
         inx
         cpx #$18
         bne spr1
         inc sxpos
         lda sxpos
         cmp #$08
         beq spr2
         rts
spr2     clc
         lda #$00
         sta sxpos
         sta spage2+1
         ldy #$00
         lda (spage),y
         bne spr3
sinit    ldy #<stext
         sty spage
         ldy #>stext
         sty spage+1
         rts
spr3     sta spage2
         ldx #$03
spr4     clc
         rol spage2
         rol spage2+1
         dex
         bne spr4
         clc
         lda #>schars
         adc spage2+1
         sta spage2+1
         ldx #$00
         ldy #$00
sprite5  lda (spage2),y
         sta $0ac6,x
         inx
         inx
         inx
         iny
         cpx #$18
         bne sprite5
         ;
         inc spage
         bne sprite6
         inc spage+1
sprite6  rts
;---------------------------------------
spoint   lda #<schars
         sta spage2
         lda #>schars
         sta spage2+1
         rts
;---------------------------------------
spset    lda #$ff
         sta $d015
         sta $d01d
         lda #$00
         sta $d01b
         sta $d017
         ;
         ; Set Colors & Memory Pointers
         ;
         ldy #$00
         ldx #$23
sp1      txa
         sta 2040,y
         sta 2044,y
         inx
         iny
         cpy #$04
         bne sp1
         ;
         ldy #$03
colspr   lda #$0c
         sta $d027,y
         lda #$00
         sta $d027+4,y
         dey
         bpl colspr
         ;
         lda #251
         sta $d001
         sta $d003
         sta $d005
         sta $d007
         lda #252
         sta $d009
         sta $d00b
         sta $d00d
         sta $d00f
         ;
         lda #90
         sta $d000
         clc
         adc #48
         sta $d002
         clc
         adc #48
         sta $d004
         clc
         adc #48
         sta $d006
         ;
         lda #91
         sta $d008
         clc
         adc #48
         sta $d00a
         clc
         adc #48
         sta $d00c
         clc
         adc #48
         sta $d00e
         rts
;---------------------------------------
sxpos    .byte $00
delay    .byte $00
;---------------------------------------
fadeon   lda fdel
         sec
         sbc #$03
         and #$07
         sta fdel
         bcc fadeon1
         rts
fadeon1  lda fpoint
         cmp #$08
         beq fadeon2
         inc fpoint
         ldx fpoint
         lda oncols,x
         sta color
         rts
fadeon2  lda #$ad
         sta byte2
         lda #$20
         sta byte1
         lda #$00
         sta fpoint
         rts
;---------------------------------------
fadeoff  lda fdel
         sec
         sbc #$03
         and #$07
         sta fdel
         bcc fadeof1
         rts
fadeof1  lda fpoint
         cmp #$08
         beq fadeof2
         inc fpoint
         ldx fpoint
         lda offcols,x
         sta color
         rts
fadeof2  lda #$ad
         sta byte5
         lda #$00
         sta fpoint
         lda #$20
         sta byte6
         rts
;---------------------------------------
voloff   lda fdel
         sec
         sbc #$03
         and #$07
         sta fdel
         bcc volof1
         rts
volof1   lda fpoint
         cmp #$0f
         beq volof2
         inc fpoint
         rts
volof2   lda #$ad
         sta byte6
         sta wait2
         rts
;---------------------------------------
fdel     .byte $00
fpoint   .byte $00
         ;
oncols   .byte $00,$06,$02,$04,$0a,$0f
         .byte $07,$01
offcols  .byte $01,$07,$0f,$0a,$08,$02
         .byte $09,$00
;---------------------------------------
