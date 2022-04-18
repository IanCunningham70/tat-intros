

;---------------------------------------
; TAT Intro v7
;---------------------------------------
apage    = $aa
atext    = $2300
aline    = 1024+(40*20)
bpage    = apage+2
btext    = $3000
bline    = 1024+(40*23)
logodata = $3400
mline    = 1024+(40*3)
newprog  = $4000
codearea = $033c
         ;
ptext    = $0fc0
ptext2   = $0fe0
lpage    = $e0
spage    = lpage+2
pline    = 1024+(40*15)
pline2   = 1024+(40*17)
;---------------------------------------
         *= $080d
         ;
         sei
         ldx #$ff
         txs
         lda #$0e
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
         lda #$00
         jsr $1000
         jsr ainit
         jsr binit
         jsr writer
         ;
         ldy #79
col2x2   lda #$0f
         sta aline+$d400,y
         sta bline+$d400,y
         dey
         bpl col2x2
         ;
         lda #$7f
         sta $dc0d
         lda $dc0d
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
keyscan  jsr $ffe4
         cmp #" "
         bne keyscan
         jmp linker
;---------------------------------------
restore  rti
;---------------------------------------
progirq  lda #26
         sta $d018
         ldx #$34
         cpx $d012
         bne *-3
         ldx #$06
         dex
         bne *-1
rast1    ldy timings,x
         lda cols1,x
         dey
         bne *-1
         sta $d020
         sta $d021
         inx
         cpx #22
         bne rast1
         ;
         ldx #$4b
         cpx $d012
         bne *-3
         ldx #$07
         dex
         bne *-1
         lda #24
         sta $d018
         lda mxpos1
         sta $d016
         lda #$0f
         sta $d022
         lda #$0e
         sta $d023
         ;
         jsr ascroll
         jsr bscroll
         jsr colfx
         ;
         ldx #$94
         cpx $d012
         bne *-3
         lda #200
         sta $d016
         lda #26
         sta $d018
         ldx #$04
         dex
         bne *-1
rast2    ldy timings,x
         dey
         bne *-1
         lda cols2,x
         sta $d020
         sta $d021
         inx
         cpx #24
         bne rast2
         ;
         ldx #(18*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda #$1c
         sta $d011
         ;
         ldx #(20*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda $d016
         and #$f0
         ora axpos
         sta $d016
         ;
         ldx #(22*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda $d016
         and #$f0
         ora bxpos
         sta $d016
         ;
         jsr $1003
         jsr mover
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
mover    ldx #$00
         lda lsinus,x
         sta mxpos1
         lda loffset,x
         tax
         ldy #$00
ml1      lda logodata,x
         sta mline,y
         lda logodata+(256*1),x
         sta mline+40,y
         lda logodata+(256*2),x
         sta mline+80,y
         lda logodata+(256*3),x
         sta mline+120,y
         lda logodata+(256*4),x
         sta mline+160,y
         lda logodata+(256*5),x
         sta mline+200,y
         lda logodata+(256*6),x
         sta mline+240,y
         lda logodata+(256*7),x
         sta mline+280,y
         lda logodata+(256*8),x
         sta mline+320,y
         inx
         iny
         cpy #$28
         bne ml1

         lda mover+1
         clc
         adc #$01
         sta mover+1
         rts
;---------------------------------------
ascroll  lda axpos
         sec
         sbc #$02
         and #$07
         sta axpos
         bcc asc01
         rts
asc01    ldx #$00
asc02    lda aline+1,x
         sta aline,x
         lda aline+41,x
         sta aline+40,x
         inx
         cpx #$28
         bne asc02
         jsr anext
         sta aline+39
         clc
         adc #128
         sta aline+79
         rts
anext    lda asize
         cmp #$01
         beq an00
         lda achar
         clc
         adc #64
         sta achar
         inc asize
         rts
an00     ldy #$00
         sty asize
         lda (apage),y
         bne an01
         jsr ainit
         jmp an00
an01     inc apage
         bne an02
         inc apage+1
an02     sta achar
         rts
ainit    ldx #<atext
         ldy #>atext
         stx apage
         sty apage+1
         lda #$01
         sta asize
         lda #$20
         sta achar
         rts
;---------------------------------------
bscroll  lda bxpos
         sec
         sbc #$03
         and #$07
         sta bxpos
         bcc bsc01
         rts
bsc01    ldx #$00
bsc02    lda bline+1,x
         sta bline,x
         lda bline+41,x
         sta bline+40,x
         inx
         cpx #$28
         bne bsc02
         jsr bnext
         sta bline+39
         clc
         adc #128
         sta bline+79
         rts
bnext    lda bsize
         cmp #$01
         beq bn00
         lda bchar
         clc
         adc #64
         sta bchar
         inc bsize
         rts
bn00     ldy #$00
         sty bsize
         lda (bpage),y
         bne bn01
         jsr binit
         jmp bn00
bn01     inc bpage
         bne bn02
         inc bpage+1
bn02     sta bchar
         rts
binit    ldx #<btext
         ldy #>btext
         stx bpage
         sty bpage+1
         lda #$01
         sta bsize
         lda #$20
         sta bchar
         rts
;---------------------------------------
colnum   = *+1
colfx    lda #$00
         ldy #$00
colfx1   and #$7f
         tax
         lda coltab1,x
         sta $d800+(40*15),y
         sta $d800+(40*16),y
         sta $d800+(40*17),y
         sta $d800+(40*18),y
         inx
         txa
         iny
         cpy #$28
         bne colfx1
         inc colnum
         rts
;---------------------------------------
coltab1  .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$07,$07,$0a,$0a,$02
         .byte $02,$00,$00,$09,$09,$05
         .byte $05,$0d,$0d,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$01
         .byte $01,$01,$01,$01,$01,$0d
         .byte $0d,$05,$05,$09,$09,$00
         .byte $00,$02,$02,$0a,$0a,$07
         .byte $07,$01,$01,$01,$01,$01
;---------------------------------------
writer   ldx #<ptext
         ldy #>ptext
         stx lpage
         sty lpage+1
         ldx #<pline
         ldy #>pline
         stx spage
         sty spage+1
         ldy #$00
         sty ycount
         jsr write
         ;
         ; 2nd Line
         ;
         ldx #<ptext2
         ldy #>ptext2
         stx lpage
         sty lpage+1
         ldx #<pline2
         ldy #>pline2
         stx spage
         sty spage+1
         ldy #$00
         sty ycount
         jsr write
         rts
;---------------------------------------
write    ldy #$00
         lda (lpage),y
         ldy #$00
         sta (spage),y
         ;
         clc
         adc #64
         ldy #$01
         sta (spage),y
         ;
         clc
         adc #64
         ldy #40
         sta (spage),y
         ;
         clc
         adc #64
         ldy #41
         sta (spage),y
         ;
         lda spage
         clc
         adc #$02
         sta spage
         lda spage+1
         adc #$00
         sta spage+1
         inc lpage
         bne write0
         inc lpage+1
write0   inc ycount
         ldy ycount
         cpy #20
         bne write
         rts
;---------------------------------------
linker
         sei
         jsr $ffe4
         lda #$00
         ldx #$40
killsid  sta $d400,x
         dex
         bne killsid
         sei
         jsr $ff5b
         jsr $fd15
         jsr $e3bf
         jsr $fda3
         cli
         ldx #$40
tranloop lda linkcode,x
         sta codearea,x
         dex
         bpl tranloop
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
         jmp codearea
         ;
         ; ----------------------------
         ;
linkcode sei
         lda #$34
         sta $01
         ldx #$00
nextbyte lda newprog,x
         sta $0801,x
         ldy #$37
         sty $01
         bit $d418
         ldy #$34
         sty $01
         inx
         bne nextbyte
         lda $0345
         cmp #$00
         beq tranexit
         inc $0345
         inc $0348
         jmp $0341
tranexit lda #$00
         sta $0800
         sta $d418
         lda #$37
         sta $01
         cli
         jmp $080d
;---------------------------------------
axpos    .byte $00
asize    .byte $00
achar    .byte $00
bxpos    .byte $00
bsize    .byte $00
bchar    .byte $00
ycount   .byte $00
mxpos1   .byte $00
;---------------------------------------
lsinus   .byte $17,$16,$15,$14,$12,$11
         .byte $10,$17,$16,$15,$14,$14
         .byte $13,$13,$12,$12,$12,$12
         .byte $13,$13,$14,$14,$16,$17
         .byte $10,$12,$14,$16,$11,$14
         .byte $17,$12,$16,$12,$16,$12
         .byte $17,$15,$12,$10,$16,$15
         .byte $14,$13,$13,$13,$13,$14
         .byte $15,$17,$11,$13,$16,$11
         .byte $15,$11,$15,$12,$17,$15
         .byte $13,$11,$10,$10,$17,$10
         .byte $10,$11,$13,$15,$17,$12
         .byte $15,$11,$15,$11,$16,$13
         .byte $11,$17,$15,$14,$13,$13
         .byte $13,$13,$14,$15,$16,$10
         .byte $12,$15,$17,$12,$16,$12
         .byte $16,$12,$17,$14,$11,$16
         .byte $14,$12,$10,$17,$16,$14
         .byte $14,$13,$13,$12,$12,$12
         .byte $12,$13,$13,$14,$14,$15
         .byte $16,$17,$10,$11,$12,$14
         .byte $15,$16,$17,$11,$12,$13
         .byte $15,$16,$17,$10,$11,$12
         .byte $13,$13,$14,$14,$15,$15
         .byte $15,$15,$14,$14,$13,$13
         .byte $11,$10,$17,$15,$13,$11
         .byte $16,$13,$10,$15,$11,$15
         .byte $11,$15,$10,$12,$15,$17
         .byte $11,$12,$13,$14,$14,$14
         .byte $14,$13,$12,$10,$16,$14
         .byte $11,$16,$12,$16,$12,$15
         .byte $10,$12,$14,$16,$17,$17
         .byte $17,$17,$17,$16,$14,$12
         .byte $10,$15,$12,$16,$12,$16
         .byte $11,$14,$16,$10,$12,$13
         .byte $14,$14,$14,$14,$13,$12
         .byte $11,$17,$15,$12,$10,$15
         .byte $11,$15,$11,$15,$10,$13
         .byte $16,$11,$13,$15,$17,$10
         .byte $11,$13,$13,$14,$14,$15
         .byte $15,$15,$15,$14,$14,$13
         .byte $13,$12,$11,$10,$17,$16
         .byte $15,$13,$12,$11

         ; ---------------------------

loffset  .byte $58,$5a,$5c,$5e,$60,$62
         .byte $64,$67,$69,$6b,$6d,$6f
         .byte $71,$73,$75,$77,$79,$7b
         .byte $7d,$7f,$81,$83,$85,$87
         .byte $88,$8a,$8c,$8e,$8f,$91
         .byte $93,$94,$96,$97,$99,$9a
         .byte $9c,$9d,$9e,$9f,$a1,$a2
         .byte $a3,$a4,$a5,$a6,$a7,$a8
         .byte $a9,$aa,$aa,$ab,$ac,$ac
         .byte $ad,$ad,$ae,$ae,$af,$af
         .byte $af,$af,$af,$af,$b0,$af
         .byte $af,$af,$af,$af,$af,$ae
         .byte $ae,$ad,$ad,$ac,$ac,$ab
         .byte $aa,$aa,$a9,$a8,$a7,$a6
         .byte $a5,$a4,$a3,$a2,$a1,$9f
         .byte $9e,$9d,$9c,$9a,$99,$97
         .byte $96,$94,$93,$91,$8f,$8e
         .byte $8c,$8a,$88,$87,$85,$83
         .byte $81,$7f,$7d,$7b,$79,$77
         .byte $75,$73,$71,$6f,$6d,$6b
         .byte $69,$67,$64,$62,$60,$5e
         .byte $5c,$5a,$58,$55,$53,$51
         .byte $4f,$4d,$4b,$48,$46,$44
         .byte $42,$40,$3e,$3c,$3a,$38
         .byte $36,$34,$32,$30,$2e,$2c
         .byte $2a,$28,$27,$25,$23,$21
         .byte $20,$1e,$1c,$1b,$19,$18
         .byte $16,$15,$13,$12,$11,$10
         .byte $0e,$0d,$0c,$0b,$0a,$09
         .byte $08,$07,$06,$05,$05,$04
         .byte $03,$03,$02,$02,$01,$01
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$01,$01,$02,$02,$03
         .byte $03,$04,$05,$05,$06,$07
         .byte $08,$09,$0a,$0b,$0c,$0d
         .byte $0e,$10,$11,$12,$13,$15
         .byte $16,$18,$19,$1b,$1c,$1e
         .byte $20,$21,$23,$25,$27,$28
         .byte $2a,$2c,$2e,$30,$32,$34
         .byte $36,$38,$3a,$3c,$3e,$40
         .byte $42,$44,$46,$48,$4b,$4d
         .byte $4f,$51,$53,$55
;---------------------------------------
cols1    .byte $06,$00,$06,$0e,$00,$06
         .byte $0e,$03,$00,$06,$0e,$03
         .byte $0d,$01,$07,$0a,$08,$02
         .byte $00,$00,$00,$00,$00,$00
         ;
cols2    .byte $06,$0e,$03,$0d,$01,$07
         .byte $0a,$08,$02,$00,$0a,$08
         .byte $02,$00,$08,$02,$00,$02
         .byte $00,$00,$00,$00,$00,$00
         ;
timings  .byte 8,8,8,8,8,8,8,1
         .byte 8,8,8,8,8,8,8,1
         .byte 8,8,8,8,8,8,8,1
         .byte 8,8,8,8,8,8,8,1
         .byte 8,8,8,8,8,8,8,1
;---------------------------------------
