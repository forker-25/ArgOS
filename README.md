# Introduction to the OS

Hi, I'm Cirno (also known as Sociopatia), the creator of this operating system.  
This OS was developed on **July 30, 2025**.

Let me introduce you to some of its features and architecture.

## Overview

This operating system is primarily written in **NASM (Netwide Assembler)** with small parts written in **C**.  
When the OS boots up, it launches the `boot` program. This acts both as a **user prompt** and a **command handler**.

### Boot Behavior

Upon startup:
- The system waits for user input.
- entering `tab` in prompt will display a list of all available files.
- Typing the name of a file **without** the `.bin` extension will **execute** that binary and perform the assigned action.

## Building the OS

To build the OS:

1. Use the provided `build.sh` script — it compiles everything into a single `.img` disk image.
2. The final image will be located in the `/releases/` directory.

### Requirements

Make sure you have **GCC**(optional) and **NASM** installed in your development environment before building.
