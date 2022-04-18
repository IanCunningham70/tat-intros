

;---------------------------------------

         ; Script Intro

;---------------------------------------
bline    = $d800+(40*9)
charset  = $2200
tpage    = $aa
cpage    = tpage+2
newprog  = $2800
codearea = $033c
tline    = 1024+(40*11)
kpage    = cpage+2
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
         jsr inittext
         ;
         ldx #<bline
         ldy #>bline
         stx kpage
         sty kpage+1
         ;
         lda #$00
         sta cpoint
         sta kpoint
         jsr $1000
         ;
         lda #$4c
         sta wait1
         sta wait2
         ;
         ldy #$07
         lda #$00
zapbits  sta cbyte0,y
         dey
         bpl zapbits
         ;
         ldx #$00
dotext   lda $0f00,x
         sta tline,x
         inx
         cpx #160
         bne dotext
         ;
         lda #$7f
         sta $dc0d
         lda #$1b
         sta $d011
         lda #$10
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
         sta fade0
wait1    jmp wait1
         ;
keyscan  jsr $ffe4
         cmp #" "
         bne keyscan
         ;
         lda #$ad
         sta byte1
         lda #$20
         sta kill1
wait2    jmp wait2
         ;
         lda #$20
         ldx #$00
wipetext sta tline,y
         inx
         cpx #160
         bne wipetext
         ;
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
restore
         rti
;---------------------------------------
progirq  ;
         ;
text0    lda ton
text1    lda toff
         ;
fade0    lda bon
fade1    lda boff
         ;
kill1    lda killer
         ;
         ldx #$74
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda bcol
         sta $d020
         sta $d021
         ldx #$0b
         dex
         bne *-1
         lda #$00
         sta $d020
         sta $d021
         ldx #$0b
         dex
         bne *-1
         lda #24
         sta $d018
         lda #200
         sta $d016
         lda tcol
         sta $d021
         ;
         jsr $1003
         ;
         ldx #(17*8)+$32
         cpx $d012
         bne *-3
         ldx #$09
         dex
         bne *-1
         lda #$00
         sta $d021
         lda #21
         sta $d018
         ;
         ldx #$c0
         cpx $d012
         bne *-3
         ldx #$0b
         dex
         bne *-1
         lda bcol
         sta $d020
         sta $d021
         ldx #$0b
         dex
         bne *-1
         lda #$00
         sta $d020
         sta $d021
         ;
byte1    lda scroller
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
scroller ldx #$00
moveleft lda bline+1,x
         sta bline,x
         lda bline+41,x
         sta bline+40,x
         lda bline+81,x
         sta bline+80,x
         lda bline+121,x
         sta bline+120,x
         lda bline+161,x
         sta bline+160,x
         lda bline+201,x
         sta bline+200,x
         lda bline+241,x
         sta bline+240,x
         lda bline+281,x
         sta bline+280,x
         inx
         cpx #$28
         bne moveleft
         lda #$20
         clc
         rol cbyte0
         bcc line0
         lda bscol
line0    sta bline+39
         lda #$00
         clc
         rol cbyte1
         bcc line1
         lda bscol
line1    sta bline+79
         lda #$00
         clc
         rol cbyte2
         bcc line2
         lda bscol
line2    sta bline+119
         lda #$00
         clc
         rol cbyte3
         bcc line3
         lda bscol
line3    sta bline+159
         lda #$00
         clc
         rol cbyte4
         bcc line4
         lda bscol
line4    sta bline+199
         lda #$00
         clc
         rol cbyte5
         bcc line5
         lda bscol
line5    sta bline+239
         lda #$00
         clc
         rol cbyte6
         bcc line6
         lda bscol
line6    sta bline+279
         lda #$00
         clc
         rol cbyte7
         bcc line7
         lda bscol
line7    sta bline+319
         inc cwidth
         lda cwidth
charsize = *+1
         cmp #$08
         bne charexit
         lda #$00
         sta cwidth
         lda #$00
         sta cpage+1
         ldy #$00
         lda (tpage),y
         cmp #$1f
         bne char2
         jsr setcol
char2    tax
         ldy widths,x
         sty charsize
         inc tpage
         bne calcpos
         inc tpage+1
calcpos  sta cpage
         asl cpage
         rol cpage+1
         asl cpage
         rol cpage+1
         asl cpage
         rol cpage+1
         clc
         lda cpage+1
         adc #>charset
         sta cpage+1
         ldy #$00
plotchar lda (cpage),y
         sta cbyte0,y
         iny
         cpy #$08
         bne plotchar
         ldy #$00
         lda (tpage),y
         beq inittext
charexit rts
inittext ldx #$00
         ldy #$24
         stx tpage
         sty tpage+1
         rts
setcol   inc tpage
         bne setc1
         inc tpage+1
setc1    ldy #$00
         lda (tpage),y
         sta bscol
         inc tpage
         bne setc2
         inc tpage+1
setc2    ldy #$00
         lda (tpage),y
setcol1  rts
;---------------------------------------
ton      lda delay
         sec
         sbc #$02
         and #$07
         sta delay
         bcc ton1
         rts
ton1     ldx cpoint
         cpx #10
         beq ton2
         lda toncol,x
         sta tcol
         inc cpoint
         rts
ton2     lda #$ad
         sta text0
         sta wait1
         lda #$00
         sta cpoint
         lda #$20
         sta byte1
         rts
;---------------------------------------
toff     lda delay+1
         sec
         sbc #$02
         and #$07
         sta delay+1
         bcc toff1
         rts
toff1    ldx cpoint
         cpx #10
         beq toff2
         lda toffcol,x
         sta tcol
         inc cpoint
         rts
toff2    lda #$ad
         sta text1
         lda #$00
         sta cpoint
         lda #$20
         sta fade1
         rts
;---------------------------------------
bon      lda delay+2
         sec
         sbc #$02
         and #$07
         sta delay+2
         bcc bon1
         rts
bon1     ldx cpoint
         cpx #10
         beq bon2
         lda boncol,x
         sta bcol
         inc cpoint
         rts
bon2     lda #$ad
         sta fade0
         lda #$00
         sta cpoint
         lda #$20
         sta text0
         rts
;---------------------------------------
boff     lda delay+3
         sec
         sbc #$02
         and #$07
         sta delay+3
         bcc boff1
         rts
boff1    ldx cpoint
         cpx #10
         beq boff2
         lda boffcol,x
         sta bcol
         inc cpoint
         rts
boff2    lda #$ad
         sta fade1
         sta wait2
         lda #$00
         sta cpoint
         rts
;---------------------------------------
killer   ldx kpoint
         cpx #160
         beq killer3
         ;
         ldy #$00
         lda #$00
         sta (kpage),y
         ldy #160
         sta (kpage),y
         inc kpage
         bne killer2
         inc kpage+1
killer2  inc kpoint
         rts
killer3  lda #$ad
         sta kill1
         lda #$20
         sta text1
         lda #$00
         sta cpoint
         rts
;---------------------------------------

bscol    .byte $02,$00
         ;
cbyte0   .byte $00
cbyte1   .byte $00
cbyte2   .byte $00
cbyte3   .byte $00
cbyte4   .byte $00
cbyte5   .byte $00
cbyte6   .byte $00
cbyte7   .byte $00
cwidth   .byte $00
         ;
widths   .byte $08,$08,$08,$08,$08,$08
         .byte $08,$08,$08,$08,$08,$08
         .byte $08,$09,$08,$08,$08,$08
         .byte $08,$08,$08,$08,$08,$09
         .byte $08,$08,$08,$08,$09,$06
         .byte $08,$09,$04,$08,$08,$08
         .byte $08,$08,$09,$06,$06,$06
         .byte $09,$08,$05,$08,$04,$09
         .byte $08,$08,$08,$08,$09,$08
         .byte $08,$08,$08,$08,$04,$05
         .byte $08,$08,$08,$08,$09,$08
         .byte $08,$08,$08,$08,$08,$08
         .byte $08,$06,$08,$08,$08,$09
         .byte $08,$08,$08,$08,$08,$08
         .byte $08,$08,$08,$09,$08,$08
         ;
tcol     .byte $00
bcol     .byte $00
cpoint   .byte $00
delay    .byte $00,$00,$00,$00,$00,$00
         ;
toncol   .byte $00,$06,$02,$04,$0a
         .byte $0f,$07,$01,$07,$0f
toffcol  .byte $0f,$07,$01,$07,$0f
         .byte $0a,$04,$02,$06,$00
         ;
boncol   .byte $00,$09,$02,$08,$0a
         .byte $0f,$07,$01,$07,$0f
boffcol  .byte $0f,$07,$01,$07,$0f
         .byte $0a,$08,$02,$09,$00
         ;
kpoint   .byte $00,$00
;---------------------------------------

