#!/usr/bin/env python3

# argos fs&bin writer, made by cirnik

import os
import sys
import struct
import argparse
import tempfile
import shutil
import subprocess

def create_file_entry(name, start_sector, size_sectors, file_size=0):
    entry = bytearray(32)
    name_bytes = name.encode('ascii')[:11]
    entry[:len(name_bytes)] = name_bytes
    entry[12:14] = struct.pack('<H', start_sector)
    entry[14:16] = struct.pack('<H', size_sectors)
    entry[16:20] = struct.pack('<L', file_size)
    entry[20] = 1 if name.lower().endswith('.bin') else 0
    return bytes(entry)

def create_raw_image(bootloader_file, output_file, program_files, size_mb=16, label="IMAGE"):
    with open(bootloader_file, 'rb') as f:
        bootloader = f.read()
    if len(bootloader) > 512:
        print(f"Error: Bootloader too big ({len(bootloader)} bytes)")
        return False
    boot_sector = bootloader.ljust(512, b'\x00')
    disk_size = size_mb * 1024 * 1024
    sector_size = 512
    total_sectors = disk_size // sector_size
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
        if program_file.lower().endswith('crash.bin'):
            size_sectors = min(8, (len(data) + sector_size - 1) // sector_size)
            data = data[:size_sectors * sector_size].ljust(size_sectors * sector_size, b'\x00')
        else:
            size_sectors = (len(data) + sector_size - 1) // sector_size
        if current_sector + size_sectors > total_sectors:
            print(f"Warning: Not enough space for {program_file}, skipping")
            continue
        filename = os.path.basename(program_file)
        entry = create_file_entry(filename, current_sector, size_sectors, len(data))
        if entry_offset + 32 <= 512:
            file_table[entry_offset:entry_offset + 32] = entry
            entry_offset += 32
        else:
            print(f"Warning: Too many files, {filename} skipped")
            continue
        padded_data = data.ljust(size_sectors * sector_size, b'\x00')
        program_data.append(padded_data)
        print(f"Added file: {filename} (sector {current_sector}, {size_sectors} sectors)")
        current_sector += size_sectors
    with open(output_file, 'wb') as f:
        f.write(boot_sector)
        f.write(file_table)
        for data in program_data:
            f.write(data)
        current_size = f.tell()
        if current_size > disk_size:
            final_size = ((current_size + sector_size - 1) // sector_size) * sector_size
            print(f"Warning: Content exceeds configured image size, extending to {final_size} bytes")
        else:
            final_size = disk_size
        if current_size < final_size:
            f.write(b'\x00' * (final_size - current_size))
    file_size = os.path.getsize(output_file)
    print(f"\nRaw image created: {output_file}")
    print(f"Size: {file_size} bytes ({file_size / (1024*1024):.2f} MB)")
    return True

def find_iso_tool():
    for cmd in ("genisoimage", "mkisofs", "xorrisofs", "xorriso"):
        if shutil.which(cmd):
            return cmd
    return None

def create_iso_image(bootloader_file, output_file, program_files, size_mb=16):
    iso_tool = find_iso_tool()
    if not iso_tool:
        print("Warning: no ISO creation tool (genisoimage/mkisofs/xorriso) found.\n"
              "Falling back to raw image with .iso extension.")
        return create_raw_image(bootloader_file, output_file, program_files, size_mb, label="ISO")
    with tempfile.TemporaryDirectory() as td:
        boot_target = os.path.join(td, "boot.bin")
        shutil.copyfile(bootloader_file, boot_target)
        for pf in program_files:
            if not os.path.exists(pf):
                print(f"Warning: File {pf} not found, skipping")
                continue
            shutil.copy(pf, td)
        if iso_tool in ("genisoimage", "mkisofs", "xorrisofs"):
            cmd = [
                iso_tool,
                "-o", output_file,
                "-b", "boot.bin",
                "-no-emul-boot",
                "-boot-load-size", "4",
                "-boot-info-table",
                "-J", "-R",
                td
            ]
        else:
            cmd = [
                "xorriso", "-as", "mkisofs",
                "-o", output_file,
                "-b", "boot.bin",
                "-no-emul-boot",
                "-boot-load-size", "4", 
                "-boot-info-table",
                "-J", "-R",
                td
            ]
        print("Running:", " ".join(cmd)) # ME IN FUTURE DONT FORGOT PLEASE!
        try:
            res = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            print(res.stdout.decode(errors='ignore'))
            print(f"\nISO created: {output_file}")
            return True
        except subprocess.CalledProcessError as e:
            print("ISO creation failed:", e)
            print("stderr:", e.stderr.decode(errors='ignore'))
            print("Falling back to raw image with .iso extension.")
            return create_raw_image(bootloader_file, output_file, program_files, size_mb, label="ISO")

def main():
    parser = argparse.ArgumentParser(description="Create raw USB-like image or ISO from bootloader+program files")
    parser.add_argument("bootloader", help="bootloader file (512 bytes max)")
    parser.add_argument("output", help="output filename (you can give any extension; use --format to force)")
    parser.add_argument("programs", nargs="*", help="program files to include")
    parser.add_argument("--size-mb", type=int, default=16, help="image size in MB for raw images (default 16)")
    parser.add_argument("--format", choices=["img","usb","iso"], help="output format (img/raw, usb (raw+different ext), iso)")
    args = parser.parse_args()

    if not os.path.exists(args.bootloader):
        print(f"Error: Bootloader {args.bootloader} not found")
        sys.exit(1)

    fmt = args.format
    if not fmt:
        _, ext = os.path.splitext(args.output)
        ext = ext.lower().lstrip('.')
        if ext == "usb":
            fmt = "usb"
        elif ext == "iso":
            fmt = "iso"
        else:
            fmt = "img"
    base, ext = os.path.splitext(args.output)
    if fmt == "usb":
        out = base + ".usb"
    elif fmt == "iso":
        out = base + ".iso"
    else:
        out = base + ".img"

    if fmt in ("img", "usb"):
        ok = create_raw_image(args.bootloader, out, args.programs, size_mb=args.size_mb)
    else:
        ok = create_iso_image(args.bootloader, out, args.programs, size_mb=args.size_mb)

    if ok:
        print("\nSuccess!")
    else:
        print("\nError creating image")
        sys.exit(1)

if __name__ == "__main__":
    main()
