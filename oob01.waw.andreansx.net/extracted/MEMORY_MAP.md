# Brocade FastIron LS648 (IronWare) — RE prep / memory map

Target: **`FGS07202r.bin`** (and siblings) — Brocade/Foundry FastIron LS648-STK firmware.
SoC: **Freescale MPC8248** (PowerQUICC II, G2_LE core), **big-endian**, 400 MHz, 256 MB DRAM,
512 KB boot flash, 30 MB code flash. (All per the unit's `show version`.)

---

## 1. Why raw IDA gave `.byte` soup

`FGS07202r.bin` is **not** a flat code image. It is a packed IronWare container:

| Region            | Offset            | Contents                                                            |
|-------------------|-------------------|---------------------------------------------------------------------|
| Foundry header    | `0x00`–`0x1E`     | ASCII version `07.2.02rT7e1` (12 B) + metadata/checksum             |
| **LZMA payload**  | `0x1F` → …        | LZMA-alone stream: props `0x5D` (lc3/lp0/pb2), 64 MiB dict          |
| Trailing footer   | … → EOF           | model tag (`FGSL…`) + checksums (`FEv2` style) — ignore for RE       |

The PPC code only exists *after* LZMA decompression (the boot monitor inflates it into
DRAM at boot). IDA was disassembling the compressed stream → garbage `.byte` lines.

Decompressed image: **`FGS07202r.dec.bin`, 12,864,936 bytes (`0xC44DA8`)** — byte-exact
to the size declared in the LZMA header.

---

## 2. Load base = `0x00400000` (proven, not guessed)

Three independent confirmations:

1. **BSS-clear arithmetic.** `_start` (image offset `0x100`) zeroes BSS from `0x01044DA8`.
   The loaded image ends at `base + 0xC44DA8`. Solving `base + 0xC44DA8 = 0x01044DA8`
   → `base = 0x00400000`. (BSS always sits right after the loaded image.)
2. **Pointer cloud.** Reconstructing 115k `lis`/`ori`/`addi` 32-bit pointers, **55.9%**
   fall inside `[0x400000, 0x400000+12.8 MB]`.
3. **String pointers.** **23%** of in-range pointers resolve to the *exact start* of a
   NUL-terminated string (`"Type/Length"`, `"Filter list : "`, `"DA %s "`, …). A wrong
   base gives ~0%.

### Memory map (FGS07202r)

| Symbol           | Address                     | Notes                                          |
|------------------|-----------------------------|------------------------------------------------|
| Load base        | `0x00400000`                | image offset 0 → this address                  |
| `_start` (entry) | `0x00400100`                | first non-zero byte; BSS-clear prologue        |
| Loaded image end | `0x01044DA8`                | `base + 0xC44DA8`                              |
| **BSS**          | `0x01044DA8 – 0x0253CCC8`   | zero-init at boot; not file-backed (sparse)    |
| `_SDA_BASE_` (r13)  | `0x0104CD88`             | EABI small-data anchor (into BSS)              |
| `_SDA2_BASE_` (r2)  | `0x00E85CE8`             | EABI read-only small-data (into image)         |
| `ironware_main`  | `0x00550CD4`                | C entry; `_start` does `mtlr;blr` here         |

> Set `r2`/`r13` (via the `_SDA_BASE_`/`_SDA2_BASE_` symbols the IDA script creates) so
> Hex-Rays resolves `lwz rX, off(r2/r13)` small-data globals instead of raw offsets.

### `_start` prologue (verified, capstone, BE)
```
00400100  lis r10,0x104 ; ori r10,r10,0x4DA8   ; r10 = 0x01044DA8  BSS start
00400108  lis r11,0x253 ; ori r11,r11,0xCCC8   ; r11 = 0x0253CCC8  BSS end
00400110  li  r0,0
00400114  stw r0,0(r10) ; addi r10,r10,4 ; cmpw r10,r11 ; blt 0x400114   ; clear BSS
00400124  lis r13,0x104 ; ori r13,r13,0xCD88  ; r13 = _SDA_BASE_  = 0x0104CD88
0040012C  lis r2,0xE8   ; ori r2,r2,0x5CE8    ; r2  = _SDA2_BASE_ = 0x00E85CE8
00400134  lis r10,0x55  ; ori r10,r10,0x0CD4 ; mtlr r10 ; blr  -> 0x00550CD4 (main)
00400144+ li r0,N ; sc  (x N)                 ; IronWare syscall/trap stubs
```

---

## 3. All four application images (same base)

Same boot monitor → same load base `0x00400000`; only the BSS extent differs.

| File            | packed    | decompressed | image end    | BSS end      | entry        |
|-----------------|-----------|--------------|--------------|--------------|--------------|
| FGS07202a.bin   | 2,862,567 | 13,181,608   | `0x010922A8` | `0x0258AB80` | `0x00400100` |
| FGS07202r.bin   | 2,823,122 | 12,864,936   | `0x01044DA8` | `0x0253CCC8` | `0x00400100` |
| FGSL07202r.bin  | 3,127,804 | 14,399,984   | `0x011BB9F0` | `0x027E2570` | `0x00400100` |
| FGSR07202r.bin  | 3,507,521 | 16,670,776   | `0x013E6038` | `0x02ABC108` | `0x00400100` |

FGSL = base-L3 (the one that loads on this unit), FGSR = edge-L3 (license-gated),
FGS = L2 only. For studying L3/TCP-IP, **`FGSL07202r.dec.bin`** is the most interesting.

---

## 4. Loading into IDA

**Option A — manual + fixup script (recommended):**
1. `File > Open` → `FGS07202r.dec.bin` → **Binary file**, processor **PowerPC big endian [PPC]**.
2. Loading address / RAM base = **`0x00400000`**.
3. After initial analysis: `File > Script file…` → `ida_setup_fls648.py`.
   It creates the BSS segment, sets `_start`/`ironware_main`, the SDA anchors, and analyzes.

**Option B — over ida-pro-mcp:** start the MCP server (Edit > Plugins > MCP /
Ctrl+Option+M) after step 1–2; the agent can then run the same fixups + drive analysis.

Processor tip: in PPC processor options, the core is a **G2_LE / 603e-class** (classic
PPC, not VLE, not Book-E). Default PPC big-endian is correct.

---

## 5. Phase 2 — boot monitor `fgz05000.bin` (the SoC register map)

`fgz05000.bin` = **416,213-byte boot monitor v05.0.00T7e5** (matches `show ver` exactly).
Unlike the app images it is **not LZMA-packed**: header (version + `FEv2` block at `0x40`),
then executable PPC starting at `0x100` (branch vectors `b 0x2F00`…), plus a bzip2 blob at
`0x2F546`. This is the authoritative source for:
- the **HRCW / IMMR base** (MPC8248 internal registers — DPRAM, CPM, SIU, memory ctrl),
- **DRAM controller** setup (ORx/BRx, refresh) confirming the 256 MB / `0x400000` layout,
- the **reset vector** (`0xFFF00100` boot-flash high vectors) and decompress-and-jump path.

Recover its base the same way (pointer cloud / absolute refs); the prologue differs from
the app images so the BSS-arithmetic trick won't apply directly.

> **TODO (open):** MPC8248 IMMR base not yet pinned (peripheral MMIO for FCC/SCC ethernet,
> CPM, parameter RAM). Pull it from the boot monitor's memory-controller init.

---

## 6. Reproducibility

- `extract_fls648.py` — unpack any `*.bin` (LZMA carve + decompress) and auto-print the
  load base/BSS/entry from the prologue. Run with no args to do all images.
- `ida_setup_fls648.py` — in-IDA fixups (segments, SDA anchors, entry, analysis);
  self-tuning, works for any of the four images.
- `*.dec.bin` — decompressed runtime images (gitignored if large; regenerate via the script).
