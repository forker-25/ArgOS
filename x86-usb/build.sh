#!/bin/bash

echo "Building NaOS..."
mkdir -p releases
echo "Compiling bootloader..."
nasm -f bin src/boot.asm -o releases/boot.bin
if [ $? -ne 0 ]; then
    echo "Error building boot.bin"
    exit 1
fi

echo "Creating disk image..."
python3 src/create.py releases/boot.bin releases/naos.img

if [ $? -eq 0 ]; then
    echo "Build complete! Created releases/naos.img"
else
    echo "Error creating disk image"
    exit 1
fi
