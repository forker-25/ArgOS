#!/bin/bash

COMPILE_C=${1:-"yes"}

echo "Building NaOS..."
mkdir -p releases
echo "Compiling bootloader..."
nasm -f bin src/boot_compact.asm -o releases/boot.bin
if [ $? -ne 0 ]; then
    echo "Error building boot.bin"
    exit 1
fi

echo "Compiling programs..."
nasm -f bin src/hello.asm -o releases/hello.bin
nasm -f bin src/neofetch.asm -o releases/sysinfo.bin
nasm -f bin src/colors.asm -o releases/colors.bin
nasm -f bin src/memory.asm -o releases/memory.bin
nasm -f bin src/ascii.asm -o releases/ascii.bin
nasm -f bin src/cpuid.asm -o releases/cpuid.bin
nasm -f bin src/random.asm -o releases/random.bin
nasm -f bin src/reboot.asm -o releases/reboot.bin
nasm -f bin src/credits.asm -o releases/credits.bin
nasm -f bin src/ramdump.asm -o releases/ramdump.bin

if [ "$COMPILE_C" = "yes" ]; then
    echo "Compiling C program..."
    gcc -m32 -ffreestanding -nostdlib -fno-stack-protector -Os -c src/crash.c -o releases/crash.o
    ld -m elf_i386 -Ttext 0x1000 --oformat binary releases/crash.o -o releases/crash.bin
    CRASH_PROGRAM="releases/crash.bin"
else
    echo "Skipping C compilation..."
    CRASH_PROGRAM=""
fi

echo "Creating disk image..."
if [ "$COMPILE_C" = "yes" ]; then
    python3 src/create.py releases/boot.bin releases/naos.img releases/hello.bin releases/sysinfo.bin releases/colors.bin releases/memory.bin releases/ascii.bin releases/cpuid.bin releases/random.bin releases/reboot.bin releases/credits.bin releases/ramdump.bin $CRASH_PROGRAM
else
    python3 src/create.py releases/boot.bin releases/naos.img releases/hello.bin releases/sysinfo.bin releases/colors.bin releases/memory.bin releases/ascii.bin releases/cpuid.bin releases/random.bin releases/reboot.bin releases/credits.bin releases/ramdump.bin
fi

if [ $? -eq 0 ]; then
    echo "Build complete! Created releases/naos.img"
    if [ "$COMPILE_C" = "yes" ]; then
        echo "Programs: hello, sysinfo, colors, memory, ascii, cpuid, random, reboot, credits, ramdump, crash"
        echo "Usage: ./build.sh [yes|no] - yes=compile C programs, no=skip C compilation"
    else
        echo "Programs: hello, sysinfo, colors, memory, ascii, cpuid, random, reboot, credits, ramdump"
        echo "C programs skipped. Use './build.sh yes' to include C programs"
    fi
else
    echo "Error creating disk image"
    exit 1
fi
