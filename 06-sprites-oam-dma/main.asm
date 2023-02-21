; iNES header
.db "NES", $1a ; Constant (ASCII "NES" followed by MS-DOS end-of-file)
.db $01 ; Size of PRG ROM in 16 KB units
.db $01 ; Size of CHR ROM in 8 KB units (value 0 means the board uses CHR RAM)
.db $01 ; Flags 6 – Mapper, mirroring, battery, trainer
.db $00 ; Flags 7 – Mapper, VS/Playchoice, NES 2.0
.db $00 ; Flags 8 – PRG-RAM size (rarely used extension)
.db $00 ; Flags 9 – TV system (rarely used extension)
.db $00 ; Flags 10 – TV system, PRG-RAM presence (rarely used extension)
.db $00,$00,$00,$00,$00 ; Unused padding (should be filled with zero)

.enum $0000
  scrolly: db 0
  scrollyd: db 0
.ende

; === PRG ===================================================================
.org $c000

Reset:
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
; set colors to blue, light blue, light blue, light blue
  lda #$11
  sta $2007
  lda #$21
  sta $2007
  lda #$21
  sta $2007
  lda #$21
  sta $2007

; set the sprite palette 0 base address
  lda #$3f
  sta $2006
  lda #$11
  sta $2006
; set colors to green, yellow, red
  lda #$19
  sta $2007
  lda #$28
  sta $2007
  lda #$16
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
  sta $0200, y
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
-:
  jmp -

Nmi:
; trigger OAM DMA at 0200-02ff
  lda #$02
  sta $4014
; compute scroll
  clc
  lda (scrollyd)
  adc #32
  sta (scrollyd)
  bcc noinc
  inc (scrolly)
noinc:
  ; update scroll
  lda #$00
  sta $2005
  lda scrolly
  sta $2005
  rti

Irq:
  rti

; setup interrupt vectors
.org $fffa
.dw Nmi, Reset, Irq

; === CHR ===================================================================

.incbin "../sprite_8k.chr"
