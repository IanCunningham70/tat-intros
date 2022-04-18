
;---------------------------------------
; TAT Intro V1
;---------------------------------------
logodata = $0c00
logoline = $0400+(40*8)
logocols = $d400+logoline
         ;
aline    = $0400+(40*17)
acols    = $d400+aline
apage    = $aa
atext    = $1900
;---------------------------------------
         *= $0e00
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
         ldy #39
col1x1   lda acolors,y
         sta acols,y
         dey
         bpl col1x1
         ;
         jsr ainit
         lda #$00
         jsr $1048
         ;
         lda #$7f
         sta $dc0d
         lda $dc0d
         lda #$1b
         sta $d011
         lda #216
         sta $d016
         lda #$72
         sta $d012
         ldx #$00
         stx $d019
         inx
         stx $d01a
         ldy #>irq
         ldx #<irq
         sty $0315
         stx $0314
         cli
         ;
keyscan  jsr $ffe4
         cmp #" "
         bne keyscan
      ;  jmp $9000
;---------------------------------------
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
i0f4d    lda $2000,x
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
irq
         bit $ca5e
         nop
         lda #216
         sta $d016
         lda #18
         sta $d018
         lda #$06
         sta $d021
         lda #$0e
         sta $d022
         lda #$0f
         sta $d023
         ;
         jsr ascroll
         ;
         ldx #(16*8)+$32
         cpx $d012
         bne *-3
         ldx #$0a
         dex
         bne *-1
         lda #$00
         sta $d021
         lda #23
         sta $d018
         lda #200
         sta $d016
         lda $d016
         and #$f0
         ora axpos
         sta $d016
         ;
         jsr $1021
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
