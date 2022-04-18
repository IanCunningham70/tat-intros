
;---------------------------------------
; TAT Intro 5 - UpScrolling 1x2 Char.
;---------------------------------------

;---------------------------------------
utext    = $2800
uline    = 1024+(40*10)
tline    = 1024+(40*8)
;---------------------------------------
         *= $080d
         ;
         lda #$02
         sta $d011
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
         lda #$01
         sta upfast
         ;
         lda #$28
         sta uthi
         lda #$00
         sta utlo
         sta upcount
         sta lcnum
         sta lcdel
         sta ypos
         sta cpoint
         sta col1
         sta col2
         sta col3
         sta linecol
         jsr $1000
         lda #$0f
         sta upcol
         ;
         lda #$ad
         sta byte1
         sta byte2
         sta byte3
         sta byte4
         sta byte5
         lda #$4c
         sta wipe1
         sta wipe2
         ;
         ldx #$00
drawlogo lda $2600,x
         sta $0400,x
         lda $2600+140,x
         sta $0400+140,x
         lda #$08
         sta $d800,x
         sta $d800+140,x
         inx
         cpx #140
         bne drawlogo
         ;
         ldy #39
textline lda $0f00,y
         sta tline,y
         clc
         adc #64
         sta tline+40,y
         dey
         bpl textline
         ;
         lda #$ff
         sta $d015
         sta $d01d
         lda #$00
         sta $d01b
         sta $d017
         lda #%11100000
         sta $d010
         ;
         ldy #$00
setsp    lda #150
         sta 2040,y
         lda #$00
         sta $d027,y
         iny
         cpy #$08
         bne setsp
         ;
         lda #24
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
         clc
         adc #48
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
         ;
         lda #$7f
         sta $dc0d
         lda $dc0d
         lda #$01
         sta $d012
         lda #$01
         sta $d019
         sta $d01a
         lda #<irq
         sta $0314
         lda #>irq
         sta $0315
         lda #24
         sta $d018
         cli
         ;
         lda #$04
         sta counter
holdon   lda counter
         beq dologo
         dec counter
         jsr delay
         jmp holdon
dologo   lda #$20
         sta byte3
         lda #$04
         sta counter
holdon2  lda counter
         beq continue
         dec counter
         jsr delay
         jmp holdon2
continue lda #$20
         sta byte1
         sta byte2
keyscan  jsr $ffe4
         beq *-3
space    cmp #" "
         bne pause
         jmp wipeout
pause    cmp #$03
         bne keyscan
         lda upfast
         beq pause2
         lda #$00
         sta upfast
         jmp keyscan
pause2   lda #$01
         sta upfast
         jmp keyscan
;---------------------------------------
delay    ldx #$ff
delay1   ldy #$ff
         dey
         bne *-1
         dex
         bne delay1
         rts
;---------------------------------------
counter  .byte $04
;---------------------------------------
wipeout  lda #$00
         sta lcnum

         lda #$20
         sta byte4
wipe1    jmp wipe1
         lda #$00
         sta lcnum
         lda #$ad
         sta byte1
         sta byte2
         lda #$20
         sta byte5
wipe2    jmp wipe2
         lda #$00
         sta lcnum
         lda #$02
         sta counter
holdon3  lda counter
         beq next
         dec counter
         jsr delay
         jmp holdon3
next
         jmp $9000
;---------------------------------------
linker   sei
         jsr $ffe4
         lda #$00
         ldx #$40
killzak  sta $d400,x
         dex
         bne killzak
         sei
         jsr $ff5b
         jsr $fd15
         jsr $e3bf
         jsr $fda3
         cli
         ldx #$40
trancode lda linkcode,x
         sta $033c,x
         dex
         bpl trancode
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
linkcode sei
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
         jmp $0801
;---------------------------------------
irq      lda #$98
         sta $d011
         lda #216
         sta $d016
col1     = *+1
         lda #$00
         sta $d021
col2     = *+1
         lda #$00
         sta $d022
col3     = *+1
         lda #$00
         sta $d023
         ;
byte1    lda upscroll
         ;
         ldx #(7*8)+$32
         cpx $d012
         bne *-3
linecol  = *+1
         lda #$00
         sta $d021
         ;
         ldx #(9*8)+$32
         cpx $d012
         bne *-3
         lda #200
         sta $d016
         ;
         lda #125
         sta $d001
         sta $d003
         sta $d005
         sta $d007
         sta $d009
         sta $d00b
         sta $d00d
         sta $d00f
         ;
         ldx #(10*8)+$32
         cpx $d012
         bne *-3
         ldx #$08
         dex
         bne *-1
upcol    = *+1
         lda #$0f
         sta $d021
         lda ypos
         ora #$10
         sta $d011
         ;
         jsr $1003
         ;
byte2    lda ycol
byte3    lda logon
byte4    lda logoff
byte5    lda chroff
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
udelay   = *+1
upscroll lda #$00
         bpl ups1
         dec udelay
         rts
ups1     lda ypos
         sec
upfast   = *+1
         sbc #$01
         and #$07
         sta ypos
         bcc moveup
         rts
         ;
moveup   ldx #$27
uploop   lda uline+40,x
         sta uline,x
         lda uline+80,x
         sta uline+40,x
         lda uline+120,x
         sta uline+80,x
         lda uline+160,x
         sta uline+120,x
         lda uline+200,x
         sta uline+160,x
         lda uline+240,x
         sta uline+200,x
         lda uline+280,x
         sta uline+240,x
         lda uline+320,x
         sta uline+280,x
         lda uline+360,x
         sta uline+320,x
         lda uline+400,x
         sta uline+360,x
         lda uline+440,x
         sta uline+400,x
         lda uline+480,x
         sta uline+440,x
         lda uline+520,x
         sta uline+480,x
         lda uline+560,x
         sta uline+520,x
         dex
         bpl uploop
         ;
         lda upcount
         cmp #$01
         beq upnext0
         ;
         ldx #$00
uprint2  lda uline+520,x
         clc
         adc #64
         sta uline+560,x
         inx
         cpx #$28
         bne uprint2
         inc upcount
         jmp unext
         ;
upnext0  ldx #$00
         stx upcount
uthi     = *+2
utlo     = *+1
uloop2   lda utext,x
         bne uprint
         lda #$00
         sta utlo
         lda #$28
         sta uthi
         ldx #$00
         jmp uloop2
uprint   sta uline+560,x
         inx
         cpx #$28
         bne uloop2
         jmp updone
unext    lda utlo
         clc
         adc #$28
         sta utlo
         bcc updone
         inc uthi
updone   rts
;---------------------------------------
ycol     lda cdel
         sec
         sbc #$04
         and #$07
         sta cdel
         bcc ycol1
         rts
ycol1    ldx cpoint
         cpx #14
         beq ycol2
         inc cpoint
         inx
         lda color,x
         sta linecol
         rts
ycol2    lda #$00
         sta cpoint
         rts
;---------------------------------------
ypos     .byte $00
upcount  .byte $00
cpoint   .byte $00
cdel     .byte $00
lcnum    .byte $00
lcdel    .byte $00
         ;
color    .byte $00,$06,$02,$04,$0a
         .byte $0f,$07,$01,$07,$0f
         .byte $0a,$08,$02,$09,$00
;---------------------------------------
logon    lda lcdel
         sec
         sbc #$04
         and #$07
         sta lcdel
         bcc logon1
         rts
logon1   lda lcnum
         cmp #11
         beq logon2
         inc lcnum
         ldx lcnum
         lda logoc1a,x
         sta col1
         lda logoc2a,x
         sta col2
         lda logoc3a,x
         sta col3
         rts
logon2   lda #$00
         sta lcnum
         sta lcdel
         lda #$ad
         sta byte3
         rts
;---------------------------------------
logoff   lda lcdel
         sec
         sbc #$04
         and #$07
         sta lcdel
         bcc logoff1
         rts
logoff1  lda lcnum
         cmp #11
         beq logoff2
         inc lcnum
         ldx lcnum
         lda logoc1b,x
         sta col1
         lda logoc2b,x
         sta col2
         lda logoc3b,x
         sta col3
         rts
logoff2  lda #$ad
         sta byte4
         sta wipe1
         rts
;---------------------------------------
chroff   lda lcdel
         sec
         sbc #$06
         and #$07
         sta lcdel
         bcc chroff1
         rts
chroff1  lda lcnum
         cmp #23
         beq chroff2
         inc lcnum
         ldx lcnum
         lda chrc1,x
         sta linecol
         sta upcol
         rts
chroff2  lda #$ad
         sta byte5
         sta wipe2
         rts
;---------------------------------------
chrc1    .byte $01,$01,$01,$07,$07,$07
         .byte $0f,$0f,$0f,$0a,$0a,$0a
         .byte $08,$08,$08,$02,$02,$02
         .byte $09,$09,$09,$00,$00,$00
;---------------------------------------
         *= $0d00
;---------------------------------------
logoc1a
         .byte $00,$00,$00,$06,$06,$06
         .byte $0e,$0e,$0e,$0f,$0f,$0f
logoc2a
         .byte $00,$00,$00,$06,$06,$06
         .byte $0e,$0e,$0e,$0e,$0e,$0e
logoc3a
         .byte $00,$00,$00,$06,$06,$06
         .byte $06,$06,$06,$06,$06,$06
;---------------------------------------
logoc1b
         .byte $0f,$0f,$0f,$0e,$0e,$0e
         .byte $06,$06,$06,$00,$00,$00
logoc2b
         .byte $0e,$0e,$0e,$0e,$0e,$0e
         .byte $06,$06,$06,$00,$00,$00
logoc3b
         .byte $06,$06,$06,$06,$06,$06
         .byte $06,$06,$06,$00,$00,$00
;---------------------------------------
