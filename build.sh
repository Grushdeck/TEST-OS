#!/bin/bash

nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin kernel.asm -o kernel.bin
dd if=/dev/zero of=testos.img bs=512 count=2880
dd if=bootloader.bin of=testos.img conv=notrunc
dd if=kernel.bin of=testos.img seek=1 conv=notrunc

echo "Done! File: testos.img"