src=main.asm
project=${PWD##*/}
rom=$project.nes
asm=asm6f
emu=Mesen

$asm $src $rom
$emu $rom
