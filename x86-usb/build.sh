#!/bin/bash

# build.sh maded by cirnik for ArgOS-usb-x86

echo "Building ArgOS-usb-x86..."
mkdir -p releases

echo "Compiling bootloader..."
nasm -f bin src/boot.asm -o releases/boot.bin
if [ $? -ne 0 ]; then
    echo "Error building boot.bin"
    exit 1
fi

echo "Compiling programs..."
nasm -f bin src/devs.asm -o releases/devs.bin
if [ $? -ne 0 ]; then
    echo "Error building devs.bin"
    exit 1
fi

OUTPUT="releases/naos.usb" 
FORMAT="usb" # usb, iso or img only

echo "Creating disk image..."
python3 src/create.py releases/boot.bin "$OUTPUT" releases/devs.bin --format "$FORMAT"

if [ $? -eq 0 ]; then
    echo "Build complete! Created $OUTPUT"
else
    echo "Error creating disk image"
    exit 1
fi
