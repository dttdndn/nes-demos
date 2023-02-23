
# NES Demos

Examples, experiments and demos for the NES/Famicom 8-bit console.

Written in 6502 assembly and compiled using [asm6f](https://github.com/freem/asm6f).

Run and tested against the [Mesen2](https://github.com/SourMesen/Mesen2) emulator.

## 01-backdrop-color

PPU rendering is disabled and the screen is filled with a solid white color using the backdrop color.

## 02-solid-background

PPU rendering is enabled and the screen is filled with a solid blue color using background palette and tiles.

## 03-checkboard

Render a fullscreen checkerboard pattern.

## 04-scroll

Scrolls a checkerboard screen horizontally.

## 05-sprite

Renders a sprite a the center of the screen.

## 06-sprites-oam-dma

Renders all 64 sprites using OAM DMA.

## 07-sound-pulse

Plays a contant sound using pulse 1 channel.
