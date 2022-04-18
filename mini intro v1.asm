
;```````````````````````````````````````
newprog  = $1400
codearea = $033c
apage    = $aa
atext    = $1200
aline    = 1024+(40*10)
;```````````````````````````````````````
         *= $1000

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
         jsr ainit
         ldy #119
col      lda #$0f
         sta aline+$d400,y
         lda #"["
         sta aline,y
         dey
         bpl col
         lda #$01
         sta color
         lda #$7f
         sta $dc0d
         sta $dd0d
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

keyscan  jsr $ffe4
         beq *-3
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
         ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
         jsr $a65e
         jsr $a68e
         jmp $a7ae
;```````````````````````````````````````
restore  ;rti
         jmp $9000
;```````````````````````````````````````
progirq  lda #18
         sta $d018

         jsr ascroll

         lda $d016
         and #$f0
         ora axpos
         sta $d016

         lda #$01
         sta $d019
         jmp $ea31
;```````````````````````````````````````
ascroll  lda adelay
         beq asc00
         dec adelay
         rts
asc00    lda axpos
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
         lda aline+81,x
         sta aline+80,x

         lda aline+$d401,x
         sta aline+$d400,x
         sta aline+$d400+40,x
         sta aline+$d400+80,x
         inx
         cpx #$28
         bne asc02
         jsr anext
         sta aline+39
         clc
         adc #$54
         sta aline+79
         clc
         adc #$54
         sta aline+119
         lda color
         sta aline+$d400+39
         sta aline+$d400+79
         sta aline+$d400+119
         rts
anext    lda asize
         cmp #$02
         beq an00
         lda achar
         clc
         adc #$1c
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
an02     cmp #$20
         bne an03
         lda #$1b
an03     cmp #$1f
         bne an04
         jsr apause
         jmp anext
an04     sta achar
         ldx color
         cpx #$0f
         bne an05
         ldx #$01
         stx color
         rts
an05     inc color
         rts
         ;
         ; set pause length
         ;
apause   ldy #$00
         lda (apage),y
         tax
         lda await,x
         sta adelay
         lda #$20
         sta achar
         inc apage
         bne ap01
         inc apage+1
ap01     rts
;```````````````````````````````````````
ainit    ldx #<atext
         ldy #>atext
         stx apage
         sty apage+1
         lda #$01
         sta asize
         lda #$20
         sta achar
         rts
;```````````````````````````````````````
axpos    .byte $00
adelay   .byte $00
asize    .byte $00
achar    .byte $00
await    .byte 100,125,150,175,200
         .byte 225,250
color    .byte $01
;```````````````````````````````````````

