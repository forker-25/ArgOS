#!/usr/bin/env python3

import os
import sys
import struct


def create_file_entry(name, start_sector, size_sectors, file_size=0):
    entry = bytearray(32)
    name_bytes = name.encode('ascii')[:11]
    entry[:len(name_bytes)] = name_bytes
    entry[12:14] = struct.pack('<H', start_sector)
    entry[14:16] = struct.pack('<H', size_sectors)
    entry[16:20] = struct.pack('<L', file_size)
    entry[20] = 1 if name.endswith('.bin') else 0
    return bytes(entry)


def create_simple_image(bootloader_file, output_file, program_files):
    with open(bootloader_file, 'rb') as f:
        bootloader = f.read()

    if len(bootloader) > 512:
        print(f"Error: Bootloader too big ({len(bootloader)} bytes)")
        return False

    bootloader = bootloader.ljust(512, b'\x00')

    file_table = bytearray(512)
    current_sector = 2
    program_data = []
    entry_offset = 0

    for program_file in program_files:
        if not os.path.exists(program_file):
            print(f"Warning: File {program_file} not found, skipping")
            continue

        with open(program_file, 'rb') as f:
            data = f.read()

        if program_file.endswith('crash.bin'):
            size_sectors = min(8, (len(data) + 511) // 512)
            data = data[:size_sectors * 512].ljust(size_sectors * 512, b'\x00')
        else:
            size_sectors = (len(data) + 511) // 512

        filename = os.path.basename(program_file)
        entry = create_file_entry(filename, current_sector, size_sectors,
                                  len(data))

        if entry_offset + 32 <= 512:
            file_table[entry_offset:entry_offset + 32] = entry
            entry_offset += 32
        else:
            print(f"Warning: Too many files, {filename} skipped")
            continue

        padded_data = data.ljust(size_sectors * 512, b'\x00')
        program_data.append(padded_data)

        current_sector += size_sectors
        print(
            f"Added file: {filename} (sector {current_sector - size_sectors}, {size_sectors} sectors)"
        )

    with open(output_file, 'wb') as f:
        f.write(bootloader)
        f.write(file_table)

        for data in program_data:
            f.write(data)

        current_size = f.tell()

        sector_size = 512
        aligned_size = (
            (current_size + sector_size - 1) // sector_size) * sector_size
        floppy_size = 2880 * sector_size

        if aligned_size <= floppy_size:
            final_size = floppy_size
        else:
            final_size = aligned_size
            print(
                f"Warning: Content exceeds floppy capacity, using {final_size} bytes"
            )

        if current_size < final_size:
            padding = final_size - current_size
            f.write(b'\x00' * padding)
            print(f"Padded to sector-aligned size ({final_size} bytes)")

        actual_size = f.tell()
        if actual_size % sector_size != 0:
            print(f"Error: Final size {actual_size} is not sector-aligned!")
            return False

    file_size = os.path.getsize(output_file)
    print(f"\nDisk image created: {output_file}")
    print(f"Size: {file_size} bytes ({file_size / (1024*1024):.2f} MB)")
    return True


def main():
    if len(sys.argv) < 3:
        print(
            "Usage: python3 create.py <bootloader.bin> <output.img> [program1.bin] [program2.bin] ..."
        )
        sys.exit(1)

    bootloader_file = sys.argv[1]
    output_file = sys.argv[2]
    program_files = sys.argv[3:] if len(sys.argv) > 3 else []

    if not os.path.exists(bootloader_file):
        print(f"Error: Bootloader {bootloader_file} not found")
        sys.exit(1)

    if create_simple_image(bootloader_file, output_file, program_files):
        print("\nSuccess!")
    else:
        print("\nError creating image")
        sys.exit(1)


if __name__ == "__main__":
    main()
