
;---------------------------------------
; Quick Crack Intro For TAT
;
;---------------------------------------
apage    = $aa
atext    = $0b00
aline    = 1024+(40*11)
         ;
newprog  = $1000
codearea = $033c
         ;
logoline1 = 1024+(40*5)
logoline2 = 1024+(40*14)
         ;
logoc1   = logoline1+$d400
logoc2   = logoline2+$d400
;---------------------------------------
         *= $080d
         ;
         sei
         ldx #$ff
         txs
         lda #$0c
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
         jsr drawlogo
         jsr ainit
         ;
         ldy #39
col1x1   lda cols1x1,y
         sta aline+$d400,y
         lda logocols,y
         sta logoc1,y
         sta logoc2,y
         dey
         bpl col1x1
         ;
         lda #$7f
         sta $dc0d
         lda #$1b
         sta $d011
         lda #$30
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
restore  rti
;---------------------------------------
progirq
         lda #23
         sta $d018
         ldx #(11*8)+$32
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
         ldx #(12*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda #200
         sta $d016
         ;
         jsr ascroll
         jsr logofx
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
ascroll  lda adelay
         beq asc00
         dec adelay
         rts
asc00    lda axpos
         sec
         sbc #$03
         and #$07
         sta axpos
         bcc asc01
         rts
asc01    ldx #$00
asc02    lda aline+1,x
         sta aline,x
         inx
         cpx #$28
         bne asc02
         jsr anext
         sta aline+39
         rts
anext    ldy #$00
         lda (apage),y
         bne an00
         jsr ainit
         jmp anext
an00     inc apage
         bne an01
         inc apage+1
an01     cmp #$1f
         bne an02
         jsr apause
         jmp anext
an02     rts
         ;
         ; Set Pause Length
         ;
apause   ldy #$00
         lda (apage),y
         tax
         lda await,x
         sta adelay
         inc apage
         bne ap01
         inc apage+1
ap01     rts
         ;
ainit    ldx #<atext
         ldy #>atext
         stx apage
         sty apage+1
         rts
;---------------------------------------
axpos    .byte $00
adelay   .byte $00
await    .byte 100,125,150,175,200
         .byte 225,250
;---------------------------------------
drawlogo ldx #$00
drawlg1  lda logodata,x
         sta logoline1,x
         sta logoline2,x
         inx
         cpx #$a0
         bne drawlg1
         rts
;---------------------------------------
logofx   lda logoc1
         sta temp1
         lda logoc2
         sta temp2
         ldx #$00
logofx2  lda logoc1+1,x
         sta logoc1,x
         sta logoc1+41,x
         sta logoc1+82,x
         sta logoc1+123,x
         sta logoc1+164,x
         lda logoc2+1,x
         sta logoc2,x
         sta logoc2+41,x
         sta logoc2+82,x
         sta logoc2+123,x
         sta logoc2+164,x
         inx
         cpx #40
         bne logofx2
         lda temp1
         sta logoc1+39
         lda temp2
         sta logoc2+39
         rts
;---------------------------------------
temp1    .byte $00
temp2    .byte $00
;---------------------------------------
logodata .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$e2,$e2,$a0,$fc,$6c
         .byte $a0,$ec,$fb,$a0,$7b,$fe
         .byte $a0,$e2,$e2,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$a0,$a0,$e1,$a0,$fc
         .byte $fe,$a0,$61,$a0,$a0,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$a0
         .byte $a0,$e1,$a0,$75,$e1,$a0
         .byte $61,$a0,$a0,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$a0,$a0,$e1
         .byte $a0,$75,$e1,$a0,$61,$a0
         .byte $a0,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20,$20
         .byte $20,$20,$20,$20,$20
         ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
cols1x1  .byte $00,$06,$02,$04,$0a
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0a,$04,$02,$06,$00
         ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
logocols .byte $00,$06,$02,$04,$0a
         .byte $0f,$07,$01,$07,$0f
         .byte $0a,$04,$02,$06,$00
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $0f,$0f,$0f,$0f,$0f
         .byte $00,$09,$02,$08,$0a
         .byte $0f,$07,$01,$07,$0f
         .byte $0a,$08,$02,$09,$00
;---------------------------------------
