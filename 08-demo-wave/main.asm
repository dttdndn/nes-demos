; iNES header
DB "NES", $1a ; Constant (ASCII "NES" followed by MS-DOS end-of-file)
DB $01 ; Size of PRG ROM in 16 KB units
DB $01 ; Size of CHR ROM in 8 KB units (value 0 means the board uses CHR RAM)
DB $00 ; Flags 6 – Mapper, mirroring, battery, trainer
DB $00 ; Flags 7 – Mapper, VS/Playchoice, NES 2.0
DB $00 ; Flags 8 – PRG-RAM size (rarely used extension)
DB $00 ; Flags 9 – TV system (rarely used extension)
DB $00 ; Flags 10 – TV system, PRG-RAM presence (rarely used extension)
DB $00,$00,$00,$00,$00 ; Unused padding (should be filled with zero)

ENUM $0000
  scrollx:
    db 0
  scrollxd:
    db 0
  tmp:
    db 0
ENDE

; === PRG ===================================================================
ORG $c000

reset:
  sei
  cld

; setup stack
  ldx #$ff
  txs

; wait for vblank
-:
  lda $2002
  and #$80
  beq -

; disable background rendering
  lda #%00000000
  sta $2000
  lda #%00000000
  sta $2001

; set the background palette base address
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
; set colors to black, gray, gray, gray
  lda #$3f
  sta $2007
  lda #$2d
  sta $2007
  lda #$2d
  sta $2007
  lda #$2d
  sta $2007

; set the sprite palette 0 base address
  lda #$3f
  sta $2006
  lda #$11
  sta $2006
; set colors to red, yellow, yellow
  lda #$16
  sta $2007
  lda #$28
  sta $2007
  lda #$28
  sta $2007

  ; set the background attribute table base address
  lda #$23
  sta $2006
  lda #$C0
  sta $2006
  ; zero it all
  ldx #64
  lda #$00
-:
  sta $2007
  dex
  bne -

; set background nametable base address
  lda #$20
  sta $2006
  lda #$00
  sta $2006

; fill the screen with a checkerboard pattern
  ldy #30 ; 30 rows
  ldx #32 ; 32 columns
  lda #$01 ; initial tile index
-:
  sta $2007
  eor #1
  dex
  bne -
  ldx #32
  eor #1
  dey
  bne -

; zero the OAM area 0200-02ff
  lda #$00
  ldx #$ff
-:
  sta $0200, x
  dex
  bne -

; set tile index 2 and x = 4*index for all sprites
  ldx #64
-:
  txa
  asl
  asl
  tay
  lda #2
  sta $0201, y
  txa
  asl
  asl
  sta $0203, y
  dex
  bne -

; set scroll coordinates to (0,0)
  lda #$00
  sta $2005
  lda #$00
  sta $2005

; enable background & sprite rendering with NMI
  lda #%10000000
  sta $2000
  lda #%00011110
  sta $2001

; loop forever
gameloop:

; update y for sprites
  ldx #64
  -:
  ; a = x * 4
  txa
  asl
  asl
  ; a += scrollx
  adc (scrollx)
  ; y = a
  tay
  ; a = sin[y]
  lda (sin), y
  ; save result to tmp
  sta (tmp)
  ; a = x * 4
  txa
  asl
  asl
  tay
  lda (tmp)
  sta $0200, y
  dex
  bne -

jmp gameloop

; sin table index[0,255] and values [0,255]
sin:
  db $00,$03,$06,$09,$0c,$0f,$12,$15,$18,$1c,$1f,$22,$25,$28,$2b,$2e
  db $31,$34,$37,$3a,$3d,$40,$44,$47,$4a,$4d,$4f,$52,$55,$58,$5b,$5e
  db $61,$64,$67,$6a,$6d,$6f,$72,$75,$78,$7a,$7d,$80,$83,$85,$88,$8b
  db $8d,$90,$92,$95,$97,$9a,$9c,$9f,$a1,$a4,$a6,$a8,$ab,$ad,$af,$b2
  db $b4,$b6,$b8,$ba,$bc,$bf,$c1,$c3,$c5,$c7,$c9,$ca,$cc,$ce,$d0,$d2
  db $d4,$d5,$d7,$d9,$da,$dc,$dd,$df,$e0,$e2,$e3,$e5,$e6,$e7,$e9,$ea
  db $eb,$ec,$ed,$ef,$f0,$f1,$f2,$f3,$f4,$f4,$f5,$f6,$f7,$f8,$f8,$f9
  db $fa,$fa,$fb,$fb,$fc,$fc,$fd,$fd,$fd,$fe,$fe,$fe,$fe,$fe,$fe,$fe
  db $ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fd,$fd,$fd,$fc,$fc,$fb,$fb,$fa
  db $fa,$f9,$f8,$f8,$f7,$f6,$f5,$f4,$f4,$f3,$f2,$f1,$f0,$ef,$ed,$ec
  db $eb,$ea,$e9,$e7,$e6,$e5,$e3,$e2,$e0,$df,$dd,$dc,$da,$d9,$d7,$d5
  db $d4,$d2,$d0,$ce,$cc,$ca,$c9,$c7,$c5,$c3,$c1,$bf,$bc,$ba,$b8,$b6
  db $b4,$b2,$af,$ad,$ab,$a8,$a6,$a4,$a1,$9f,$9c,$9a,$97,$95,$92,$90
  db $8d,$8b,$88,$85,$83,$80,$7d,$7a,$78,$75,$72,$6f,$6d,$6a,$67,$64
  db $61,$5e,$5b,$58,$55,$52,$4f,$4d,$4a,$47,$44,$40,$3d,$3a,$37,$34
  db $31,$2e,$2b,$28,$25,$22,$1f,$1c,$18,$15,$12,$0f,$0c,$09,$06,$03

nmi:
  pha
; trigger OAM DMA at 0200-02ff
  lda #$02
  sta $4014
; compute scroll
  clc
  lda (scrollxd)
  adc #$c0
  sta (scrollxd)
  bcc noinc
  inc (scrollx)
noinc:
  ; update scroll
  lda scrollx
  sta $2005
  lda #$00
  sta $2005
  pla
  rti

irq:
  rti

; setup interrupt vectors
ORG $fffa
DW nmi, reset, irq

; === CHR ===================================================================

INCBIN "../demo_wave_8k.chr"
