# C64 Passport MIDI Player

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
    ├── variables.h           # Emits actual bytes into the binary — no equates here
    ├── irq.asm               # IRQ handler, installed at $C000
    ├── main.asm              # Initializer, main drain loop, teardown at $C0A0
    └── loader.bas            # BASIC loader (lowercase, hatoucan-compatible)
```


***

## Build Requirements

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


### Build Outputs

| File | Description |
| :-- | :-- |
| `build/midiplayer.prg` | Assembled machine code, loads to `$C000` |
| `build/loader.prg` | Tokenized BASIC loader |
| `build/midiplayer.report` | ACME assembly report with segment sizes |
| `build/midiplayer.labels` | VICE monitor label file |


***

## Memory Map

| Address Range | Contents |
| :-- | :-- |
| `$00FB`–`$00FC` | Zero page event table pointer |
| `$C000`–`$C0xx` | IRQ handler |
| `$C080`–`$C088` | Variables (HALTED, DELTA_COUNT, BUF_HEAD, etc.) |
| `$C0xx`+ | Initializer, main drain loop, teardown |
| `$C200`–`$C2FF` | Circular buffer (256 bytes, page-aligned) |
| `$C300`+ | MIDI event table |

The exact address of `INIT` after the IRQ handler can be found in `build/midiplayer.labels` — look for the line:

```
al C:xxxx .INIT
```


***

## Loading on the C64

Load the files in this order:

```basic
LOAD "MIDIPLAYER.PRG",8,1
LOAD "LOADER.PRG",8
RUN
```

- The `,1` on the first `LOAD` is mandatory — it forces the kernal to honour the `$C000` load address in the `.prg` header
- Press any key to stop the sequencer and return to BASIC

***

## Adjusting BPM

Edit line 120 of `src/loader.bas`:

```basic
120 bpm = 60
```

The timer latch is computed automatically from the BPM value. Valid range is approximately 20–240 BPM with the 6840 PTM at NTSC PHI2 (1,022,727 Hz).

***

## Adjusting the INIT Address

If the IRQ handler grows or shrinks and `INIT` moves, update line 108 of `src/loader.bas` to match the address in `build/midiplayer.labels`:

```basic
108 init = 49258
```


***

## Architecture Overview

The system is divided into three layers:

1. **BASIC Loader** (`loader.bas`) — computes timer latch values, configures the 6840 PTM, and calls the assembly initializer via `SYS`
2. **IRQ Handler** (`irq.asm`) — fires on every timer tick at 24 PPQN, reads events from the event table, writes MIDI bytes into the circular buffer.
3. **Main** (`main.asm`) — initializes hardware, drains the circular buffer to the 6850 ACIA, keypress detection, and clean teardown

The IRQ and main loop communicate exclusively through the circular buffer at `$C200` and the `HALTED` flag at `$C080`.

