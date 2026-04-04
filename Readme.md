# FantaSeq64 - A minimal Commodore 64 MIDI Player

A MIDI player for the Commodore 64 using the Passport MH-02 midi cartridge.
The sequencer is interrupt-driven and plays a sequence of MIDI events from
a pre-built event table. It has been tested and confirmed working on real hardware.

***

## Hardware Requirements

- Commodore 64 (NTSC)
- Passport MH-02 MIDI cartridge
    - Motorola 6840 PTM (Programmable Timer Module) at `$DE00`
    - Motorola 6850 ACIA at `$DE08`/`$DE09`

***

## Project Structure

```
.
├── CMakeLists.txt
├── cmake/
│   ├── AcmeAssembler.cmake   # ACME assembler CMake helper
│   ├── HatoucanBasic.cmake   # hatoucan tokenizer CMake helper
│   └── run_hatoucan.cmake    # CMake script invoked at build time
└── src/
    ├── all.asm               # Top-level entry point (passed to ACME)
    ├── constants.h           # Pure symbol definitions — no code or data emitted 
    ├── variables.asm         # Emits actual bytes into the binary — no equates here
    ├── irq.asm               # IRQ handler
    ├── main.asm              # Initializer, main drain loop, teardown
    └── loader.bas            # BASIC loader (lowercase, hatoucan-compatible)
```


***

## Build Requirements

All these tools are optional. You can pick your own C64 assembler and easily create a simple makefile. Use your preferred tools.


- [CMake](https://cmake.org/) 3.5 or later
- [ACME cross-assembler](https://sourceforge.net/projects/acme-crossass/) for 6502/6510
- [Python 3](https://www.python.org/)
- [hatoucan](https://git.catseye.tc/hatoucan/) BASIC tokenizer

***

## Building

### 1. Configure

```bash
cmake \
  -B ./build \
  -DACME_EXECUTABLE=/path/to/acme \
  -DHATOUCAN_SCRIPT=/path/to/hatoucan/hatoucan/script/hatoucan \
  .
```


### 2. Build

```bash
cmake --build ./build
```

or

```bash
make
```

in the build directory.


### Build Outputs

If you use the ACME assembler your output files will look like these:

| File | Description |
| :-- | :-- |
| `build/fantaseq64.prg` | Assembled machine code, loads to `$C000` |
| `build/loader.prg` | Tokenized BASIC loader |
| `build/fantaseq64.report` | ACME assembly report with segment sizes |
| `build/fantaseq64.labels` | VICE monitor label file |


***

## Memory Map

| Address Range | Contents |
| :-- | :-- |
| `$00FB`–`$00FC` | Zero page event table pointer |
| `$0C00`+ | MIDI event table |
| `$C000`–`$C002` | Entry point jump |
| `$C003`–`$C00A` | Variables ( `HALTED`, `DELTA`, `BUFHEAD`, etc.) |
| `$C100`–`$C1FF` | Circular buffer (256 bytes, page-aligned) |
| `$C00B`–`$C0FF` | Initializer, main loop, teardown, IRQ handler |


***

## Loading on the C64

Load the files in this order:

```basic
LOAD "FANTASEQ64.PRG",8,1
LOAD "EVENTS.PRG",8,1
LOAD "LOADER.PRG",8
RUN
```

- The `,1` on the first `LOAD` is mandatory — it forces the kernal to honour the `$C000` load address in the `.prg` header
- Press any key to stop the sequencer and return to BASIC

***

## Adjusting BPM

Edit line 105 of `src/loader.bas`:

```basic
105 bpm = 60
```

The timer latch is computed automatically from the BPM and PPQN values. Because the 6840 PTM uses a 16-bit counter (max value 65535), the minimum supported tempo at 24 PPQN without overflow is approximately 40 BPM.

***



***

## Architecture Overview

The system is divided into three layers:

1. **BASIC Loader** (`loader.bas`) — computes timer latch values, configures the 6840 PTM, and calls the assembly initializer via `SYS`
2. **IRQ Handler** (`irq.asm`) — fires on every timer tick at a configurable PPQN value, reads events from the event table, writes MIDI bytes into the circular buffer.
3. **Main** (`main.asm`) — initializes hardware, drains the circular buffer to the 6850 ACIA, keypress detection, and clean teardown

The IRQ and main loop communicate exclusively through the circular buffer and the `HALTED` flag.

### Circular Buffer Constraints

For simplicity and speed, the IRQ handler does not check for buffer overruns before writing. The application generating the MIDI event table is responsible for tracking buffer usage and setting appropriate thresholds or delays to ensure the 256-byte buffer is not overwhelmed during dense musical passages (e.g., large simultaneous chords).
