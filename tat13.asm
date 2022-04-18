
;---------------------------------------
logodata = $2800
logoline = 1024
apage    = $aa
atext    = $2c00
aline    = 1024+(40*21)
aread    = $e0
awrite   = aread+2
line1    = 1024+(40*11)
text1    = $0da0
line2    = 1024+(40*16)
text2    = $0dc0
newprog  = $3000
codearea = $033c
;---------------------------------------
         *= $080d
         ;
         sei
         ldx #$ff
         txs
         lda #$08
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
         jsr dologo
         lda #$00
         jsr $1000
         jsr ainit
         ;
         ldx #<text1
         ldy #>text1
         stx aread
         sty aread+1
         ldx #<line1
         ldy #>line1
         stx awrite
         sty awrite+1
         jsr write4x2
         ldx #<text2
         ldy #>text2
         stx aread
         sty aread+1
         ldx #<line2
         ldy #>line2
         stx awrite
         sty awrite+1
         jsr write4x2
         ;
         lda #$7f
         sta $dc0d
         lda #$1b
         sta $d011
         lda #$00
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
         beq linker
         jmp keyscan
linker   jmp linknext
;---------------------------------------
restore  ;
         rti
;---------------------------------------
progirq  ;
         lda #$00
         sta $d015
         jsr letter1
         jsr letter2
         jsr letter3
         jsr rastfx
         ;
         ldx #$34
         cpx $d012
         bne *-3
         ldx #$0b
         dex
         bne *-1
rcol1    = *+1
         lda #$06
         sta $d020
         sta $d021
         ldx #$0b
         dex
         bne *-1
         lda #$00
         sta $d020
         sta $d021
         ;
         jsr $1003
         jsr ascroll
         ;
         ldx #$88
         cpx $d012
         bne *-3
         ldx #$0b
         dex
         bne *-1
rcol2    = *+1
         lda #$06
         sta $d020
         sta $d021
         ldx #$0b
         dex
         bne *-1
         lda #$00
         sta $d020
         sta $d021
         ;
         ldx #$08
         dex
         bne *-1
         ;
         lda #24
         sta $d018
         lda #216
         sta $d016
         lda #$0d
         sta $d021
         lda #$09
         sta $d022
         lda #$05
         sta $d023
         ;
         ldx #$aa
         cpx $d012
         bne *-3
         ldx #$08
         dex
         bne *-1
         lda #$07
         sta $d021
         lda #$02
         sta $d022
         lda #$0a
         sta $d023
         ;
         ldx #$d7
         cpx $d012
         bne *-3
         ldx #$08
         dex
         bne *-1
         lda $d016
         and #$f0
         ora axpos
         sta $d016
         lda #$0f
         sta $d021
         lda #$06
         sta $d022
         lda #$0e
         sta $d023
         ;
         ldx #$fb
         cpx $d012
         bne *-3
         lda #200
         sta $d016
         lda #26
         sta $d018
         lda #$00
         sta $d021
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
dologo   ldx #$00
dologo1  lda logodata,x
         sta logoline,x
         lda logodata+256,x
         sta logoline+256,x
         inx
         bne dologo1
         ldy #39
         lda #$0c
dologo2  sta $d800,y
         dey
         bpl dologo2
         rts
;---------------------------------------
letter1  lda delay
         sec
         sbc #$02
         and #$07
         sta delay
         bcc lett1a
         rts
lett1a   ldx cpoint1
         cpx #$3f
         beq lett1b
lett1c   jsr flash1
         inc cpoint1
         rts
lett1b   ldx #$00
         stx cpoint1
         jmp lett1c
;---------------------------------------
letter2  lda delay+1
         sec
         sbc #$02
         and #$07
         sta delay+1
         bcc lett2a
         rts
lett2a   ldx cpoint2
         cpx #$3f
         beq lett2b
lett2c   jsr flash2
         inc cpoint2
         rts
lett2b   ldx #$00
         stx cpoint2
         jmp lett2c
;---------------------------------------
letter3  lda delay+2
         sec
         sbc #$02
         and #$07
         sta delay+2
         bcc lett3a
         rts
lett3a   ldx cpoint3
         cpx #$3f
         beq lett3b
lett3c   jsr flash3
         inc cpoint3
         rts
lett3b   ldx #$00
         stx cpoint3
         jmp lett3c
;---------------------------------------
flash1   ldy #$00
         lda colors,x
flash1a  sta $d801+(40*1),y
         sta $d801+(40*2),y
         sta $d801+(40*3),y
         sta $d801+(40*4),y
         sta $d801+(40*5),y
         sta $d801+(40*6),y
         sta $d801+(40*7),y
         sta $d801+(40*8),y
         sta $d801+(40*9),y
         iny
         cpy #12
         bne flash1a
         rts
;---------------------------------------
flash2   ldy #$00
         lda colors,x
flash2a  sta $d80e+(40*1),y
         sta $d80e+(40*2),y
         sta $d80e+(40*3),y
         sta $d80e+(40*4),y
         sta $d80e+(40*5),y
         sta $d80e+(40*6),y
         sta $d80e+(40*7),y
         sta $d80e+(40*8),y
         sta $d80e+(40*9),y
         iny
         cpy #12
         bne flash2a
         rts
;---------------------------------------
flash3   ldy #$00
         lda colors,x
flash3a  sta $d81b+(40*1),y
         sta $d81b+(40*2),y
         sta $d81b+(40*3),y
         sta $d81b+(40*4),y
         sta $d81b+(40*5),y
         sta $d81b+(40*6),y
         sta $d81b+(40*7),y
         sta $d81b+(40*8),y
         sta $d81b+(40*9),y
         iny
         cpy #12
         bne flash3a
         rts
;---------------------------------------
delay    .byte $00,$00,$00,$00,$00
cpoint1  .byte $0c
cpoint2  .byte $06
cpoint3  .byte $00
         ;----------------------------
colors   .byte $0e,$0f,$01,$07,$08,$02
         .byte $02,$02,$02,$02,$02,$02
         .byte $02,$02,$02,$02,$08,$07
         .byte $01,$0f,$0c,$0b,$0b,$0b
         .byte $0b,$0b,$0b,$0b,$0b,$0b
         .byte $0b,$0b,$0c,$0f,$01,$0f
         .byte $0d,$05,$05,$05,$05,$05
         .byte $05,$05,$05,$05,$05,$05
         .byte $0d,$0f,$01,$0f,$0e,$06
         .byte $06,$06,$06,$06,$06,$06
         .byte $06,$06,$06,$06
;---------------------------------------
ascroll  lda adelay
         beq asc00
         dec adelay
         rts
asc00    lda axpos
         sec
         sbc aspeed
         and #$07
         sta axpos
         bcc asc01
         rts
asc01    ldx #$00
asc02    lda aline+1,x
         sta aline,x
         lda aline+41,x
         sta aline+40,x
         lda aline+81,x
         sta aline+80,x
         lda aline+121,x
         sta aline+120,x
         inx
         cpx #$28
         bne asc02
         jsr anext
         sta aline+39
         clc
         adc #64
         sta aline+79
         clc
         adc #64
         sta aline+119
         clc
         adc #64
         sta aline+159
         rts
anext    lda asize
an1      = *+1
         cmp #$01
         beq an00
         lda achar
         clc
         adc #32
         sta achar
         inc asize
         rts
an00     ldy #$01
         sty an1
         dey
         sty asize
         lda (apage),y
         bne an01
         jsr ainit
         jmp an00
an01     inc apage
         bne an02
         inc apage+1
an02     ldy #$06
an02a    cmp atab1,y
         beq an02b
         dey
         bpl an02a
         jmp an03
an02b    sec
         sbc #$80
         tax
         lda await,x
         sta adelay
         lda #$20
         jmp an10
an03     ldy #$06
an03a    cmp atab2,y
         beq an03b
         dey
         bpl an03a
         jmp an04
an03b    sec
         sbc #$b0
         sta aspeed
         lda #$20
         jmp an10
an04     cmp #"!"
         bne an05
         lda #$1c
         ldx #$00
         stx an1
         jmp an10
an05     cmp #"."
         bne an06
         lda #$1e
         ldx #$00
         stx an1
         jmp an10
an06     cmp #","
         bne an10
         lda #$1f
         ldx #$00
         stx an1
         jmp an10
an10     sta achar
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
axpos    .byte $00
adelay   .byte $00
asize    .byte $00
achar    .byte $00
aspeed   .byte $02
await    .byte 100,125,150,175,200
         .byte 225,250
atab1    .byte $81,$82,$83,$84,$85,$86
         .byte $87
atab2    .byte $b1,$b2,$b3,$b4,$b5,$b6
         .byte $b7
;---------------------------------------
rastfx   lda delay+3
         sec
         sbc #$04
         and #$07
         sta delay+3
         bcc rastfx1
         rts
rastfx1  ldx rpoint
         cpx #75
         beq rastfx2
rastfx3  lda rastcol,x
         sta rcol1
         sta rcol2
         inc rpoint
         rts
rastfx2  ldx #$00
         stx rpoint
         jmp rastfx3
;---------------------------------------
rpoint   .byte $00
rastcol  .byte $00,$06,$02,$04,$0a
         .byte $0f,$07,$01,$07,$0f
         .byte $0a,$08,$02,$09,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$06,$02,$04,$0a
         .byte $0f,$07,$01,$07,$0f
         .byte $0a,$08,$02,$09,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
;---------------------------------------
         ; Set Line & Text Pointers
         ; In (AREAD) & (AWRITE) Before
         ; Jumping To Routine.
write4x2 ;
         lda #$00
         sta chardone
write0   ldx #$02
         ldy #$00
         lda (aread),y
         sta thischar
         ;
write1   ldy #$00
         lda thischar
         sta (awrite),y
         clc
         adc #64
         ldy #40
         sta (awrite),y
         clc
         adc #64
         ldy #80
         sta (awrite),y
         clc
         adc #64
         ldy #120
         sta (awrite),y
         ;
         lda awrite
         clc
         adc #$01
         sta awrite
         lda awrite+1
         adc #$00
         sta awrite+1
         ;
         lda thischar
         clc
         adc #32
         sta thischar
         dex
         bne write1
         ;
         lda aread
         clc
         adc #$01
         sta aread
         lda aread+1
         adc #$00
         sta aread+1
         ;
         inc chardone
         lda chardone
         cmp #20
         bne write0
         rts
;---------------------------------------
thischar .byte $00
chardone .byte $00
;---------------------------------------
linknext sei
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
         lda #$0c
         sta $d021
         sta 646
         jsr $e544
         lda #$00
         sta $d020
         sta $d021
         lda #$80
         sta 657
         lda #23
         sta $d018
         lda #<linktext
         ldy #>linktext
         jsr $ab1e
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
linkcode sei
         lda #$34
         sta $01
         ldx #$00
nextbyte lda newprog,x
         sta $0801,x
         ldy #$37
         sty $01
         sta $d418
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
linktext .text "{home}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{right}{right}{right}"
         .text "Intro Designed & "
         .text "Coded By Case/TAT"
         .byte $00
;---------------------------------------

