
;---------------------------------------
; TAT Intro V4
;---------------------------------------
apage    = $aa
aline    = 1024+(40*9)
atext    = $2c00       ; Text Pointer.
bpage    = apage+2
bline    = 1024+(40*13)
btext    = $3600       ; Text Pointer.
mline    = 1024+(40*0)
mline2   = 1024+(40*19)
         ;
minit    = $1000
mplay    = $1003
         ;
start    = $4000 ; Next Part
area     = $0100 ; Linker Code Area
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
         sta colnum
         lda #$80
         sta 657
         ;
         lda #$04
         sta acheck
         sta awidth
         sta bwidth
         sta bcheck
         jsr ainit
         jsr binit
         ;
         ldy #119
         lda #$0f
col3x3   sta aline+$d400,y
         sta bline+$d400,y
         dey
         bpl col3x3
         ;
         ldy #39
wipe1    lda #$49
         sta $0400+(40*6),y
         sta $0400+(40*18),y
         lda #$00
         sta $d800+(40*6),y
         sta $d800+(40*18),y
         lda $0f60+40,y
         sta 1024+(40*7),y
         lda $0f60+80,y
         sta 1024+(40*17),y
         dey
         bpl wipe1
         ;
         lda #$00
         jsr minit
         jsr mplay
         ;
         lda #$7f
         sta $dc0d
         lda $dc0d
         lda #$1b
         sta $d011
         lda #$01
         sta $d012
         lda #$01
         sta $d019
         sta $d01a
         ldx #<irq
         ldy #>irq
         stx $0314
         sty $0315
         cli
         ;
case     jsr $ffe4
         cmp #" "
         bne case

         jmp $9000

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
f0f46    sei
         lda #$34
         sta $01
         ldx #$00
i0f4d    lda $4000,x
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
irq      jsr mplay
         lda #200
         sta $d016
         lda #26
         sta $d018
         lda mxpos1
         sta $d016
         lda #$0f
         sta $d021
         lda #$06
         sta $d022
         lda #$0e
         sta $d023
         jsr mover2
         ;
         ldx #(7*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda #200
         sta $d016
         lda #$00
         sta $d021
         ;
         ldx #(9*8)+$32
         cpx $d012
         bne *-3
         lda #24
         sta $d018
         lda $d016
         and #$f0
         ora axpos
         sta $d016
         jsr bscroll
         ;
         ldx #(13*8)+$32
         cpx $d012
         bne *-3
         ldx #$08
         dex
         bne *-1
         lda #24
         sta $d018
         lda $d016
         and #$f0
         ora bxpos
         sta $d016
         jsr ascroll
         ;
         ldx #(17*8)+$32
         cpx $d012
         bne *-3
         ldx #$08
         dex
         bne *-1
         lda #200
         sta $d016
         lda #26
         sta $d018
         ;
         ldx #(18*8)+$34
         cpx $d012
         bne *-3
         lda mxpos1+1
         sta $d016
         lda #$0d
         sta $d021
         lda #$09
         sta $d022
         lda #$05
         sta $d023
         jsr mover
         ;
         jsr colfx
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
ascroll  lda axpos
         sec
         sbc #$02
         and #$07
         sta axpos
         bcc asc1
         rts
         ;
asc1     ldx #$00
asc2     lda aline+1,x
         sta aline,x
         lda aline+41,x
         sta aline+40,x
         lda aline+81,x
         sta aline+80,x
         inx
         cpx #40
         bne asc2
         ;
         lda awidth
acheck   = *+1
         cmp #$04
         bne asc3
         ;
         jsr anext
         lda #$00
         sta awidth
         ;
asc3     tax
         ;
lbyte1   = *+1
         lda $2400,x
         sta aline+39
         ;
lbyte2   = *+1
         lda $2500,x
         sta aline+79
         ;
lbyte3   = *+1
         lda $2600,x
         sta aline+119
         inc awidth
         rts
         ;
anext    ldy #$00
         sty awidth
         lda (apage),y
         bne anext0
         ;
         jsr ainit
         jmp anext
         ;
anext0   tax
         lda $2340,x
         sta acheck
         lda $2300,x
         sta lbyte1
         sta lbyte2
         sta lbyte3
         inc apage
         bne anext3
         inc apage+1
anext3   rts
ainit    lda #<atext
         sta apage
         lda #>atext
         sta apage+1
         rts
;---------------------------------------
bscroll  lda bxpos
         sec
         sbc #$03
         and #$07
         sta bxpos
         bcc bsc1
         rts
bsc1     ldx #$00
bsc2     lda bline+1,x
         sta bline,x
         lda bline+41,x
         sta bline+40,x
         lda bline+81,x
         sta bline+80,x
         inx
         cpx #40
         bne bsc2
         lda bwidth
bcheck   = *+1
         cmp #$04
         bne bsc3
         jsr bnext
         lda #$00
         sta bwidth
bsc3     tax
lbyte4   = *+1
         lda $2400,x
         sta bline+39
lbyte5   = *+1
         lda $2500,x
         sta bline+79
lbyte6   = *+1
         lda $2600,x
         sta bline+119
         inc bwidth
         rts
bnext    ldy #$00
         sty bwidth
         lda (bpage),y
         bne bnext0
         jsr binit
         jmp bnext
bnext0   tax
         lda $2340,x
         sta bcheck
         lda $2300,x
         sta lbyte4
         sta lbyte5
         sta lbyte6
         inc bpage
         bne bnext3
         inc bpage+1
bnext3   rts
binit    lda #<btext
         sta bpage
         lda #>btext
         sta bpage+1
         rts
;---------------------------------------
awidth   .byte $00
axpos    .byte $00
bwidth   .byte $00
bxpos    .byte $00
;---------------------------------------
colnum   = *+1
colfx    lda #$00
         ldy #$00
colfx1   and #$7f
         tax
         lda coltab1,x
         sta $d800+(40*7),y
         sta $d800+(40*17),y
         inx
         txa
         iny
         cpy #$28
         bne colfx1
         inc colnum
         rts
;---------------------------------------
mover    ldx #$00
         lda lsinus,x
         and #$07
         eor #$07
         ora #$10
         sta mxpos1
         lda loffset,x
         tax
         ldy #$00
ml1      lda $3000,x
         sta mline,y
         lda $3100,x
         sta mline+40,y
         lda $3200,x
         sta mline+80,y
         lda $3300,x
         sta mline+120,y
         lda $3400,x
         sta mline+160,y
         lda $3500,x
         sta mline+200,y
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
mover2   ldx #$7f
         lda lsinus,x
         and #$07
         eor #$07
         ora #$10
         sta mxpos1+1
         lda loffset,x
         tax
         ldy #$00
bl1      lda $3000,x
         sta mline2,y
         lda $3100,x
         sta mline2+40,y
         lda $3200,x
         sta mline2+80,y
         lda $3300,x
         sta mline2+120,y
         lda $3400,x
         sta mline2+160,y
         lda $3500,x
         sta mline2+200,y
         inx
         iny
         cpy #$28
         bne bl1

         lda mover2+1
         clc
         adc #$01
         sta mover2+1
         rts
;---------------------------------------
mxpos1   .byte $00,$00
         ;
lsinus   .byte $12,$12,$12,$12,$12,$12
         .byte $12,$12,$12,$12,$12,$12
         .byte $11,$11,$11,$10,$10,$17
         .byte $17,$16,$15,$14,$13,$12
         .byte $11,$10,$16,$15,$13,$11
         .byte $17,$15,$13,$11,$16,$13
         .byte $11,$16,$13,$17,$14,$10
         .byte $15,$11,$15,$10,$14,$17
         .byte $12,$15,$10,$13,$15,$10
         .byte $12,$13,$15,$17,$10,$11
         .byte $12,$13,$13,$13,$13,$13
         .byte $13,$13,$12,$11,$10,$17
         .byte $15,$13,$12,$10,$15,$13
         .byte $10,$15,$12,$17,$14,$10
         .byte $15,$11,$15,$10,$14,$17
         .byte $13,$16,$11,$13,$16,$11
         .byte $13,$15,$17,$11,$13,$15
         .byte $16,$10,$11,$12,$13,$14
         .byte $15,$16,$17,$17,$10,$10
         .byte $11,$11,$11,$12,$12,$12
         .byte $12,$12,$12,$12,$12,$12
         .byte $12,$12,$12,$11,$11,$11
         .byte $11,$11,$11,$11,$11,$11
         .byte $11,$11,$12,$12,$12,$13
         .byte $13,$14,$14,$15,$16,$17
         .byte $10,$11,$12,$13,$15,$16
         .byte $10,$12,$14,$16,$10,$12
         .byte $15,$10,$12,$15,$10,$14
         .byte $17,$13,$16,$12,$16,$13
         .byte $17,$14,$11,$16,$13,$10
         .byte $16,$13,$11,$10,$16,$14
         .byte $13,$12,$11,$10,$10,$10
         .byte $10,$10,$10,$10,$11,$12
         .byte $13,$14,$16,$10,$11,$13
         .byte $16,$10,$13,$16,$11,$14
         .byte $17,$13,$16,$12,$16,$13
         .byte $17,$14,$10,$15,$12,$10
         .byte $15,$12,$10,$16,$14,$12
         .byte $10,$16,$15,$13,$12,$11
         .byte $10,$17,$16,$15,$14,$14
         .byte $13,$13,$12,$12,$12,$11
         .byte $11,$11,$11,$11,$11,$11
         .byte $11,$11,$11,$11
;---------------------------------------
loffset  .byte $29,$2a,$2b,$2c,$2d,$2e
         .byte $2f,$30,$31,$32,$33,$34
         .byte $35,$36,$37,$38,$39,$39
         .byte $3a,$3b,$3c,$3d,$3e,$3f
         .byte $40,$41,$41,$42,$43,$44
         .byte $44,$45,$46,$47,$47,$48
         .byte $49,$49,$4a,$4a,$4b,$4c
         .byte $4c,$4d,$4d,$4e,$4e,$4e
         .byte $4f,$4f,$50,$50,$50,$51
         .byte $51,$51,$51,$51,$52,$52
         .byte $52,$52,$52,$52,$52,$52
         .byte $52,$52,$52,$52,$52,$51
         .byte $51,$51,$51,$51,$50,$50
         .byte $50,$4f,$4f,$4e,$4e,$4e
         .byte $4d,$4d,$4c,$4c,$4b,$4a
         .byte $4a,$49,$49,$48,$47,$47
         .byte $46,$45,$44,$44,$43,$42
         .byte $41,$41,$40,$3f,$3e,$3d
         .byte $3c,$3b,$3a,$39,$39,$38
         .byte $37,$36,$35,$34,$33,$32
         .byte $31,$30,$2f,$2e,$2d,$2c
         .byte $2b,$2a,$29,$28,$27,$26
         .byte $25,$24,$23,$22,$21,$20
         .byte $1f,$1e,$1d,$1c,$1b,$1a
         .byte $19,$18,$17,$16,$15,$14
         .byte $14,$13,$12,$11,$10,$0f
         .byte $0f,$0e,$0d,$0c,$0c,$0b
         .byte $0a,$0a,$09,$08,$08,$07
         .byte $06,$06,$05,$05,$04,$04
         .byte $03,$03,$03,$02,$02,$02
         .byte $01,$01,$01,$01,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$01,$01,$01
         .byte $01,$02,$02,$02,$03,$03
         .byte $03,$04,$04,$05,$05,$06
         .byte $06,$07,$08,$08,$09,$0a
         .byte $0a,$0b,$0c,$0c,$0d,$0e
         .byte $0f,$0f,$10,$11,$12,$13
         .byte $14,$14,$15,$16,$17,$18
         .byte $19,$1a,$1b,$1c,$1d,$1e
         .byte $1f,$20,$21,$22,$23,$24
         .byte $25,$26,$27,$28
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
