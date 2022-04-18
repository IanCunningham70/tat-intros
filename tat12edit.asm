
;---------------------------------------
; Intro-Editor v12.00
; By Case/TAT
;---------------------------------------
tpage    = $aa
mpage    = tpage+2
lineno   = $0811
starbit  = $0812
rpage    = $e0
         ;
mihi2    = $086c
milo2    = $086b
mphi2    = $09e7
mplo2    = $09e6
;---------------------------------------
         *= $3400
         ;
editor   sei
         ldx #$ff
         txs
         jsr clear
         jsr menu
         lda #$00
         sta pageno
         sta xpos
         sta ypos
         ;
mihi1    = *+1
milo1    = *+1
         jsr $1000
         lda #$7f
         sta $dc0d
         lda #$1b
         sta $d011
         lda #$fa
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
keyloop  jsr info
         ;
keyscan  jsr $ffe4
         cmp #"$"
         bne isadd
         jmp directry
isadd    cmp #"+"
         bne issub
         jmp addline
issub    cmp #"-"
         bne iscase
         jmp subline
iscase   cmp #"{ct i}"
         bne isa
         jsr killirq
         jsr setinfo
         jmp editor
isa      cmp #"a"
         bne isb
         jmp edline1
isb      cmp #"b"
         bne isc
         jmp edline2
isc      cmp #"c"
         bne isd
         jmp edtext
isd      cmp #"d"
         bne ise
         jmp loadtext
ise      cmp #"e"
         bne isf
         jmp savetext
isf      cmp #"f"
         bne isg
         jmp loadchar
isg      cmp #"g"
         bne ish
         jmp loadtune
ish      cmp #"h"
         bne isi
         jsr killirq
         jmp $080d
isi      cmp #"i"
         bne isj
         jmp saveint
isj      cmp #"j"
         bne isloop
         jsr setstar
isloop   jmp keyscan
;---------------------------------------
addline  lda lineno
         cmp #50
         bne addl1
         jmp keyloop
addl1    inc lineno
         jsr info
         jmp keyloop
;---------------------------------------
subline  lda lineno
         cmp #$01
         beq subl1
         dec lineno
         jsr info
subl1    jmp keyloop
;---------------------------------------
info     ldy #22
         ldx lineno
         dex
         lda linehi,x
         sta $0400+(40*19),y
         lda linelo,x
         iny
         sta $0400+(40*19),y
         ;
         lda starbit
         beq stoff
         ldy #$02
info1    lda sontxt,y
         and #$7f
         sta 1057+(40*15),y
         dey
         bpl info1
         rts
stoff    ldy #$02
info2    lda sofftxt,y
         and #$7f
         sta 1057+(40*15),y
         dey
         bpl info2
         rts
;---------------------------------------
sontxt   .text "on "
sofftxt  .text "off"
;---------------------------------------
setstar  lda starbit
         beq staron
         lda #$00
         sta starbit
         jsr info
         rts
staron   lda #$01
         sta starbit
         jsr info
         rts
;---------------------------------------
restore  ;
         jmp $9000
         rti
;---------------------------------------
progirq  ;
         ldx #$04
         dex
         bne *-1
         lda #$05
         sta $d020
         ;
mphi1    = *+1
mplo1    = *+1
         ;
mb       jsr $1003
         lda #$00
         sta $d020
         ;
         lda #$01
         sta $d019
         jmp $ea31
;---------------------------------------
clear    lda #$0c
         sta $d021
         sta 646
         jsr $e544
         lda #$00
         sta $d020
         sta $d021
         sta 650
         lda #$80
         sta 657
         lda #23
         sta $d018
         lda #200
         sta $d016
         rts
;---------------------------------------
menu     ldx #$00
menu1    lda $3000,x
         sta $0400,x
         lda $3100,x
         sta $0500,x
         lda $3200,x
         sta $0600,x
         lda $3300,x
         sta $0700,x
         inx
         bne menu1
         ldy #37
         lda #$0f
menu2    sta $d801+(40*1),y
         sta $d801+(40*3),y
         dey
         bpl menu2
         rts
;---------------------------------------
dotext   ldx textno
         lda textlo,x
         ldy texthi,x
         jsr $ab1e
         rts
;---------------------------------------
textno   .byte $00
textlo   .byte <txt1,<txt2,<txt3,<txt4
         .byte <txt5
texthi   .byte >txt1,>txt2,>txt3,>txt4
         .byte >txt5
;---------------------------------------
txt1     .text "{home}{yellow}Load Chars:"
         .byte $00
txt2     .text "{home}{yellow}Load Music:"
         .byte $00
txt3     .text "{home}{yellow}Load Text:"
         .byte $00
txt4     .text "{home}{yellow}Save Text:"
         .byte $00
txt5     .text "{home}{yellow}Save Intro:"
         .byte $00
;---------------------------------------
space    lda #<sptext
         ldy #>sptext
         jsr $ab1e
space1   jsr $ffe4
         cmp #" "
         bne space1
         rts
;---------------------------------------
sptext   .text "{return}{light green}Press Space."
         .byte $00
;---------------------------------------
directry ;
         jsr killirq
         jsr clear
dir      lda #$24
         sta $fb
         lda #$fb
         sta $bb
         lda #$00
         sta $bc
         lda #$01
         sta $b7
         lda #$08
         sta $ba
         lda #$60
         sta $b9
         jsr $f3d5
         lda $ba
         jsr $ffb4
         lda $b9
         jsr $ff96
         lda #$00
         sta $90
         ldy #$03
dir00    sty $fb
         jsr $ffa5
         sta $fc
         ldy $90
         bne dir03
         jsr $ffa5
         ldy $fb
         dey
         bne dir00
         ldx $fc
         jsr $bdcd
         lda #$20
         jsr $ffd2
dir01    jsr $ffa5
         ldx $90
         bne dir03
         tax
         beq dir02
         jsr $ffd2
         jmp dir01
dir02    lda #$0d
         jsr $ffd2
         ldy #$02
         bne dir00
dir03    jsr $f642
         lda #$0d
         jsr $ffd2
         jsr space
         jmp editor
;---------------------------------------
killirq  sei
         jsr $fda3
         jsr $e5a0
         jsr $e544
         lda #$00
         sta $d020
         sta $d021
         lda #$31
         sta $0314
         lda #$ea
         sta $0315
         lda #$1b
         sta $d011
         lda #$f0
         sta $d01a
         lda #$00
         sta $d418
         cli
         rts
;---------------------------------------
loadchar jsr clear
         lda #$00
         sta textno
         jsr dotext
         jsr filename
         lda flength
         bne loadc1
         jmp editor
loadc1   jsr killirq
         ldx #<$2000
         ldy #>$2000
         stx loadlo
         sty loadhi
         jsr loadfile
         jmp editor
;---------------------------------------
loadtune jsr clear
         lda #$01
         sta textno
         jsr dotext
         jsr filename
         lda flength
         bne loadm1
         jmp editor
loadm1   jsr killirq
         ldx #<$1000
         ldy #>$1000
         stx loadlo
         sty loadhi
         ;
         stx rpage
         sty rpage+1
         ;
         ldx #$10
zap2     ldy #$00
         lda #$00
zap1     sta (rpage),y
         iny
         bne zap1
         inc rpage+1
         inx
         cpx #$20
         bne zap2
         jsr loadfile
setinfo  jsr clear
         lda #<intext
         ldy #>intext
         jsr $ab1e
         ;-----------------------------
         clc
         ldx #1
         ldy #$06
         jsr $fff0
         jsr $ffcf
         lda #$00
         sta totbyte
         ldx #<$0406+(40*1)
         ldy #>$0406+(40*1)
         stx rpage
         sty rpage+1
         jsr recode
         lda totbyte
         sta mihi1
         sta mihi2
         lda #$00
         sta totbyte
         ldx #<$0408+(40*1)
         ldy #>$0408+(40*1)
         stx rpage
         sty rpage+1
         jsr recode
         lda totbyte
         sta milo1
         sta milo2
         ;-----------------------------
         clc
         ldx #2
         ldy #$06
         jsr $fff0
         jsr $ffcf
         lda #$00
         sta totbyte
         ldx #<$0406+(40*2)
         ldy #>$0406+(40*2)
         stx rpage
         sty rpage+1
         jsr recode
         lda totbyte
         sta mphi1
         sta mphi2
         lda #$00
         sta totbyte
         ldx #<$0408+(40*2)
         ldy #>$0408+(40*2)
         stx rpage
         sty rpage+1
         jsr recode
         lda totbyte
         sta mplo1
         sta mplo2
         jmp editor
;---------------------------------------
intext   .text "{home}{gray}"
         .text "Please Enter The Follo"
         .text "wing Information:"
         .byte $0d
         .text "{yellow}Init:${pink}1000{yellow}      Don"
         .text "'t Make Any Errors,"
         .byte $0d
         .text "{yellow}Play:${pink}1003{yellow}      Wit"
         .text "h Your Inputs.{pink}      "
         .byte $00
;---------------------------------------
recode   ldy #$00
         lda (rpage),y
         jsr encode
         asl a
         asl a
         asl a
         asl a
         sta $aa
         ldy #$01
         lda (rpage),y
         jsr encode
         clc
         adc $aa
         sta totbyte
         rts
;---------------------------------------
encode   and #$3f
         pha
         and #$20
         bne enc00
         pla
         and #$07
         clc
         adc #$09
         jmp enc01
enc00    pla
         and #$0f
enc01    rts
;---------------------------------------
totbyte  .byte $00
;---------------------------------------
loadtext jsr clear
         lda #$02
         sta textno
         jsr dotext
         jsr filename
         lda flength
         bne loadt1
         jmp editor
loadt1   jsr killirq
         ldx #<$2800
         ldy #>$2800
         stx loadlo
         sty loadhi
         jsr loadfile
         jmp editor
;---------------------------------------
savetext jsr clear
         lda #$03
         sta textno
         jsr dotext
         jsr filename
         lda flength
         bne savet1
         jmp editor
savet1   jsr killirq
         ldx #<$2800
         ldy #>$2800
         stx startlo
         sty starthi
         ldx #$00
         ldy #$28
         stx mpage
         sty mpage+1
         ldx pagemax
         inx
savet2   lda mpage
         clc
         adc #40
         sta mpage
         lda mpage+1
         adc #$00
         sta mpage+1
         dex
         bne savet2
         ldx mpage
         ldy mpage+1
         stx endlo
         sty endhi
         jsr savefile
         jmp editor
;---------------------------------------
saveint  jsr clear
         lda #$04
         sta textno
         jsr dotext
         jsr filename
         lda flength
         bne savei1
         jmp editor
savei1   jsr killirq
         ldx #<$0801
         ldy #>$0801
         stx startlo
         sty starthi
         ldx #<$2fff
         ldy #>$2fff
         stx endlo
         sty endhi
         lda #$ad
         sta $091e
         jsr savefile
         lda #$4c
         sta $091e
         jmp editor
;---------------------------------------
flength  .byte $00
fname    .text "*****************"
;---------------------------------------
filename ldy #$08
ft       lda ftext,y
         and #$7f
         sta $0400+(2*40),y
         lda #$01
         sta $d800+(2*40),y
         dey
         bpl ft
         ldy #$0f
         lda #$2a
stars    sta fname,y
         dey
         bpl stars
         lda #$00
         sta flength
         clc
         ldx #2
         ldy #10
         jsr $fff0
         ldx #$00
i6363    stx $22
         lda #$a4
         jsr $ffd2
         dec $d3
ikloop   jsr $ffe4
         beq ikloop
         pha
         lda #$20
         jsr $ffd2
         dec $d3
         pla
         ldx $22
         cmp #$0d
         beq i63a8
         cmp #$14
         beq i639e
a6385    = *+1
         cpx #$10
         bcs i6363
         cmp #$20
         bcc i6363
         cmp #$80
         bcc i6394
         cmp #$a0
         bcc i6363
i6394    sta fname,x
         inx
         jsr $ffd2
         jmp i6363
i639e    cpx #$00
         beq i6363
         dex
         dec $d3
         jmp i6363
i63a8    cpx #$00
         bne i63ae
         rts
i63ae    lda $22
         sta flength
         rts
;---------------------------------------
ftext    .text "filename:"
;---------------------------------------
loadfile lda #$08
         tax
         ldy #$00
         jsr $ffba
         lda #$10
         ldx #<fname
         ldy #>fname
         jsr $ffbd
loadlo   = *+1
         ldx #$00
loadhi   = *+1
         ldy #$00
         lda #$00
         jsr $ffd5
         rts
;---------------------------------------
savefile pha
         lda $2b
         pha
         lda $2c
         pha
         lda $2d
         pha
         lda $2e
         pha
startlo  = *+1
         ldx #$00
starthi  = *+1
         ldy #$00
         stx $2b
         sty $2c
endlo    = *+1
         ldx #$00
endhi    = *+1
         ldy #$00
         stx $2d
         sty $2e
         lda #$08
         tax
         ldy #$00
         jsr $ffba
         lda flength
         ldx #<fname
         ldy #>fname
         jsr $ffbd
         jsr $e159
         pla
         sta $2e
         pla
         sta $2d
         pla
         sta $2c
         pla
         sta $2b
         pla
         rts
;---------------------------------------
edline1  lda #$00
         sta pagemax
         sta ymax
         lda #$00
         sta pageno
         ldx #<$0f00
         ldy #>$0f00
         stx homelo
         sty homehi
         lda #$3f
         sta ab0
         sta ab1
         jmp teditor
;---------------------------------------
edline2  lda #$00
         sta pagemax
         sta ymax
         lda #$00
         sta pageno
         ldx #<$0f28
         ldy #>$0f28
         stx homelo
         sty homehi
         lda #$3f
         sta ab0
         sta ab1
         jmp teditor
;---------------------------------------
edtext   ldx lineno
         dex
         stx pagemax
         lda #$00
         sta ymax
         sta pageno
         ldx #<$2800
         ldy #>$2800
         stx homelo
         sty homehi
         lda #$7f
         sta ab0
         lda #$3f
         sta ab1
         jmp teditor
;---------------------------------------
teditor  jsr clear
         lda #<edinfo
         ldy #>edinfo
         jsr $ab1e
         jsr showpage
edit     ldy #$00
         lda (tpage),y
         eor #$80
         sta (tpage),y
         ;
         jsr $ffe4
         beq *-3
         pha
         ldy #$00
         lda (tpage),y
         and #$7f
         sta (tpage),y
         pla
         cmp #"{ct c}"
         beq edit
isf1     cmp #133
         bne isf3
         jmp nextpage
isf3     cmp #134
         bne isf5
         jmp lastpage
isf5     cmp #135
         bne isf7
         jmp centre
isf7     cmp #136
         bne isdown
         jsr savepage
         jmp editor
isdown   cmp #17
         bne isup
         jmp teditor
isup     cmp #145
         bne isright
         jmp teditor
isright  cmp #29
         bne isleft
         jmp mright
isleft   cmp #157
         bne isclr
         jmp mleft
isclr    cmp #147
         bne ishome
         jmp clrarea
ishome   cmp #19
         bne isdel
         jsr home
         jmp edit
isdel    cmp #20
         bne isins
         jmp delete
isins    cmp #148
         bne isret
         jmp insert
isret    cmp #13
         bne isret2
         jmp return
isret2   cmp #141
         bne istext
         jmp return
istext   cmp #$7f
         bcc istext2
ab0      = *+1
         and #$7f
         jmp istext3
ab1      = *+1
istext2  and #$3f
istext3  ldy #$00
         sta (tpage),y
         jmp mright
;---------------------------------------
home     lda #<$0400
         sta tpage
         lda #>$0400
         sta tpage+1
         lda #$00
         sta ypos
         sta xpos
         ;
homelo   = *+1
         ldx #$00
homehi   = *+1
         ldy #$28
         ;
         stx mpage
         sty mpage+1
         ;
         ldx pageno
         beq home2
home1    lda mpage
         clc
         adc #40
         sta mpage
         lda mpage+1
         adc #$00
         sta mpage+1
         dex
         bne home1
home2    rts
;---------------------------------------
showpage jsr home
sp01     ldy #$00
sp00     lda (mpage),y
         sta (tpage),y
         iny
         cpy #40
         bne sp00
         jsr home
         rts
;---------------------------------------
nextpage ldx pageno
         cpx pagemax
         beq nextp00
         jsr savepage
         inc pageno
nextp00  jsr showpage
         jmp edit
;---------------------------------------
lastpage ldx pageno
         beq lastp00
         jsr savepage
         dec pageno
lastp00  jsr showpage
         jmp edit
;---------------------------------------
savepage jsr home
savep00  ldy #$00
savep01  lda (tpage),y
         sta (mpage),y
         iny
         cpy #40
         bne savep01
         rts
;---------------------------------------
mdown    lda ypos
         cmp ymax
         beq mdown10
         lda tpage
         clc
         adc #40
         sta tpage
         lda tpage+1
         adc #$00
         sta tpage+1
         inc ypos
mdown10  jmp edit
;---------------------------------------
mup      lda ypos
         beq mup10
         lda tpage
         sec
         sbc #40
         sta tpage
         lda tpage+1
         sbc #$00
         sta tpage+1
         dec ypos
mup10    jmp edit
;---------------------------------------
mright   lda xpos
         cmp #39
         beq mright10
         lda tpage
         clc
         adc #$01
         sta tpage
         lda tpage+1
         adc #$00
         sta tpage+1
         inc xpos
         jmp edit
mright10 lda ypos
         cmp ymax
         beq mright20
         lda #$00
         sta xpos
         inc ypos
         lda tpage
         clc
         adc #$01
         sta tpage
         lda tpage+1
         adc #$00
         sta tpage+1
mright20 jmp edit
;---------------------------------------
mleft    lda xpos
         beq mleft10
         lda tpage
         sec
         sbc #$01
         sta tpage
         lda tpage+1
         sbc #$00
         sta tpage+1
         dec xpos
         jmp edit
mleft10  lda ypos
         beq mright20
         lda #39
         sta xpos
         dec ypos
         lda tpage
         sec
         sbc #$01
         sta tpage
         lda tpage+1
         sbc #$00
         sta tpage+1
mleft20  jmp edit
;---------------------------------------
clrarea  jsr home
cl02     ldy #$00
         lda #32
cl01     sta (mpage),y
         iny
         cpy #40
         bne cl01
         jsr showpage
         jmp edit
;---------------------------------------
return   lda ypos
         cmp ymax
         beq ret1
         lda tpage
         clc
         adc #40
         sta tpage
         lda tpage+1
         adc #$00
         sta tpage+1
         inc ypos
         lda tpage
         sec
         sbc xpos
         sta tpage
         lda tpage+1
         sbc #$00
         sta tpage+1
         lda #$00
         sta xpos
ret1     jmp edit
;---------------------------------------
centre   ldy #79
         lda #$20
cnt0     sta cntarea,y
         dey
         bpl cnt0
         ldx ypos
         lda scrnlo,x
         sta $ee
         lda scrnhi,x
         sta $ef
         ldy #$00
cntl1    lda ($ee),y
         cmp #$20
         bne cntl2
         iny
         cpy #$28
         bne cntl1
         jmp edit
cntl2    sty $ed
         ldx #$00
         ldy #$27
cntl3    lda ($ee),y
         cmp #$20
         bne cntl4
         inx
         dey
         bpl cntl3
cntl4    stx $ec
         ldy $ed
         ldx #$00
cntl5    lda ($ee),y
         sta cntarea,x
         iny
         inx
         cpy #$28
         bne cntl5
         lda $ed
         clc
         adc $ec
         lsr a
         sta $ec
         ldy #$27
         lda #$20
cntl6    sta ($ee),y
         dey
         bpl cntl6
         ldx #$00
         lda #$28
         sec
         sbc $ec
         sta $ed
         ldy $ec
cntl7    lda cntarea,x
         sta ($ee),y
         inx
         iny
         dec $ed
         bne cntl7
         jmp edit
;---------------------------------------
insert   ldx ypos
         lda scrnlo,x
         sta ilo1
         sta ilo2
         sta ilo3
         lda scrnhi,x
         sta ihi1
         sta ihi2
         sta ihi3
         ldx #$26
         ldy #$27
ihi1     = *+2
ilo1     = *+1
insloop  lda $0400,x
ihi2     = *+2
ilo2     = *+1
         sta $0400,y
         dex
         dey
         cpy xpos
         bne insloop
         lda #$20
ihi3     = *+2
ilo3     = *+1
         sta $0400,y
         jmp edit
;---------------------------------------
delete   ldx ypos
         lda scrnlo,x
         sta dlo1
         sta dlo2
         sta dlo3
         lda scrnhi,x
         sta dhi1
         sta dhi2
         sta dhi3
         ldx xpos
         ldy xpos
         dey
         cpy #$ff
         beq delquit
dhi1     = *+2
dlo1     = *+1
deloop   lda $0400,x
dhi2     = *+2
dlo2     = *+1
         sta $0400,y
         inx
         iny
         cpx #$28
         bne deloop
         lda #$20
dhi3     = *+2
dlo3     = *+1
         sta $0400,y
delquit  jmp mleft
;---------------------------------------
xpos     .byte $00
ypos     .byte $00
ymax     .byte 1
pageno   .byte $00
pagemax  .byte $00
         ;
cntarea  .text "                    "
         .text "                    "
         .text "                    "
         .text "                    "
         ;
scrnlo   .byte $00,$28,$50,$78,$a0,$c8
         .byte $f0,$18,$40,$68,$90,$b8
         .byte $e0,$08,$30,$58,$80,$a8
         .byte $d0,$f8,$20,$48,$70,$98
         .byte $c0
         ;
scrnhi   .byte $04,$04,$04,$04,$04,$04
         .byte $04,$05,$05,$05,$05,$05
         .byte $05,$06,$06,$06,$06,$06
         .byte $06,$06,$07,$07,$07,$07
         .byte $07
         ;
edinfo   .text "{home}{down}{green}"
         .text "{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}"
         .text "{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}{sh asterisk}"
         .text "{white}F1 {gray}- Next Line.    "
         .text "{white}F3 {gray}- Prevous Line."
         .byte $0d
         .text "{white}F5 {gray}- Centre Line.  "
         .text "{white}F7 {gray}- Main Menu.    "
         .byte $00
;---------------------------------------
linelo   .byte $30,$31,$32,$33,$34,$35
         .byte $36,$37,$38,$39,$30,$31
         .byte $32,$33,$34,$35,$36,$37
         .byte $38,$39,$30,$31,$32,$33
         .byte $34,$35,$36,$37,$38,$39
         .byte $30,$31,$32,$33,$34,$35
         .byte $36,$37,$38,$39,$30,$31
         .byte $32,$33,$34,$35,$36,$37
         .byte $38,$39,$30
linehi   .byte $30,$30,$30,$30,$30,$30
         .byte $30,$30,$30,$30,$31,$31
         .byte $31,$31,$31,$31,$31,$31
         .byte $31,$31,$32,$32,$32,$32
         .byte $32,$32,$32,$32,$32,$32
         .byte $33,$33,$33,$33,$33,$33
         .byte $33,$33,$33,$33,$34,$34
         .byte $34,$34,$34,$34,$34,$34
         .byte $34,$34,$35
;---------------------------------------
