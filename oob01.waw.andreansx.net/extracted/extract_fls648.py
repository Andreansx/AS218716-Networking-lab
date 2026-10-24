#!/usr/bin/env python3
"""
Brocade/Foundry FastIron (IronWare) firmware unpacker + load-base finder.

These .bin images are:  [Foundry header] [LZMA-alone stream] [trailing footer]
The LZMA payload is the raw PPC (big-endian, MPC8248 / PowerQUICC II) RAM image
that the boot monitor decompresses and jumps to.

Load base is recovered WITHOUT guessing, from the image's own startup code:
the first thing _start does (file offset 0x100) is clear BSS with
    lis/ori r10 = BSS_start ;  lis/ori r11 = BSS_end ; loop stw
BSS sits immediately after the loaded image, so:
    load_base = BSS_start - len(decompressed_image)
which always lands on a clean boundary (0x00400000 for these images).

Usage:  python3 extract_fls648.py FGS07202r.bin [more.bin ...]
        (no args -> all *.bin in the parent oob-fls648 dir)
"""
import sys, os, struct, lzma, glob

LZMA_SIG = b"\x5d\x00\x00\x00\x04"   # props=0x5D (lc3lp0pb2) + 64MiB dict (LE 0x04000000)

def find_lzma(data):
    i = data.find(LZMA_SIG, 0, 64)
    return i if i != -1 else -1

def decompress(data, off):
    props = data[off]
    dictsize = struct.unpack("<I", data[off+1:off+5])[0]
    usize    = struct.unpack("<Q", data[off+5:off+13])[0]
    dec = lzma.LZMADecompressor(format=lzma.FORMAT_ALONE)
    out = dec.decompress(data[off:])
    return out, props, dictsize, usize, len(dec.unused_data)

def find_base(img):
    """Decode the BSS-clear prologue at offset 0x100 to recover the load base."""
    def lis_ori(o):
        w1, w2 = struct.unpack(">II", img[o:o+8])
        if (w1 & 0xFC1F0000) != 0x3C000000:      # addis rD,0,HI  (lis)
            return None
        hi = w1 & 0xFFFF
        op = w2 & 0xFC000000
        if op == 0x60000000:                     # ori rD,rD,LO
            return ((hi << 16) | (w2 & 0xFFFF)), o + 8
        if op == 0x38000000:                     # addi rD,rD,LO (sign-ext)
            lo = w2 & 0xFFFF
            lo = lo - 0x10000 if lo & 0x8000 else lo
            return ((hi << 16) + lo) & 0xFFFFFFFF, o + 8
        return None
    a = lis_ori(0x100)
    if not a:
        return None
    bss_start, nxt = a
    b = lis_ori(nxt)
    bss_end = b[0] if b else None
    base = (bss_start - len(img)) & 0xFFFFFFFF
    return base, bss_start, bss_end

def main(argv):
    here = os.path.dirname(os.path.abspath(__file__))
    parent = os.path.dirname(here)
    files = argv[1:] or sorted(glob.glob(os.path.join(parent, "*.bin")))
    outdir = here
    print(f"{'file':22} {'in':>9} {'out':>10}  {'base':>10} {'img_end':>10} {'bss_end':>10}  entry")
    for f in files:
        path = f if os.path.isabs(f) else os.path.join(parent, f)
        if not os.path.exists(path):
            print(f"{os.path.basename(f):22} -- not found"); continue
        data = open(path, "rb").read()
        off = find_lzma(data)
        if off < 0:
            print(f"{os.path.basename(f):22} {len(data):9} -- no LZMA stream (not a packed image?)"); continue
        out, props, ds, usize, tail = decompress(data, off)
        ok = (len(out) == usize)
        bn = os.path.splitext(os.path.basename(f))[0]
        outpath = os.path.join(outdir, bn + ".dec.bin")
        open(outpath, "wb").write(out)
        bi = find_base(out)
        if bi:
            base, bss_start, bss_end = bi
            entry = base + 0x100
            print(f"{os.path.basename(f):22} {len(data):9} {len(out):10}  "
                  f"0x{base:08X} 0x{bss_start:08X} 0x{bss_end or 0:08X}  0x{entry:08X}"
                  f"{'' if ok else '  [SIZE MISMATCH]'}")
        else:
            print(f"{os.path.basename(f):22} {len(data):9} {len(out):10}  base? (prologue not BSS-clear)")
    print(f"\n[*] decompressed images written next to this script ({outdir})")

if __name__ == "__main__":
    main(sys.argv)
