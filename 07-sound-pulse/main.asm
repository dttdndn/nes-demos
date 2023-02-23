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
-
  lda $2002
  and #$80
  beq -

; disable PPU
  lda #%00000000
  sta $2000
  lda #%00000000
  sta $2001

; zero APU
  lda #$00
  ldx #$00
-
  sta $4000, x
  inx
  cpx $18
  bne -

; enable pulse 1 channel
  lda #%00000001
  sta $4015

; duty 50%, infinite play, constant volume, full volume
  lda #%01111111
  sta $4000

; no sweep
  lda #%00000000
  sta $4001

; play A 220 Hz
  lda #%11111011
  sta $4002
  lda #%11111001
  sta $4003

; loop forever (game loop)
-
  jmp -

Nmi:
  rti

Irq:
  rti

; setup interrupt vectors
.org $fffa
.dw Nmi, Reset, Irq

; === CHR ===================================================================

.incbin "../blank_8k.chr"
