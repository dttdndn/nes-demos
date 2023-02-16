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
; set colors to white, black, white, white
  lda #$30
  sta $2007
  lda #$3f
  sta $2007
  lda #$30
  sta $2007
  lda #$30
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

; set scroll coordinates to (0,0)
  lda #$00
  sta $2005
  lda #$00
  sta $2005

; enable background rendering
  lda #%00000000
  sta $2000
  lda #%00001110
  sta $2001

; loop forever
-:
  jmp -

Nmi:
  rti

Irq:
  rti

; setup interrupt vectors
.org $fffa
.dw Nmi, Reset, Irq

; === CHR ===================================================================

.incbin "./checkerboard_8k.bin"
