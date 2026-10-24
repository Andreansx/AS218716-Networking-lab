#!/usr/bin/env python
# IDA setup for Brocade FastIron (IronWare) decompressed RAM image  *.dec.bin
# PPC, BIG-ENDIAN, MPC8248 / PowerQUICC II (G2_LE core).
#
# HOW TO USE
#   1. File > Open > pick e.g. FGS07202r.dec.bin
#   2. In the load dialog choose:
#         "Binary file"
#         Processor type:  PowerPC big endian  [PPC]
#   3. Click "Set" / OK. When asked for the loading address / "RAM start
#      address" or segment base, enter:   0x00400000
#      (Disassembly memory organization: ROM/RAM base = 0x00400000, size = file size.)
#   4. Let auto-analysis run a moment, then:  File > Script file...  > this file.
#
# The script is self-tuning: it reads the BSS-clear prologue at base+0x100 to
# recover the BSS extent and the EABI small-data bases (r13/_SDA_BASE_,
# r2/_SDA2_BASE_), so it works for FGS / FGSL / FGSR / FGS-a alike.
import ida_segment, ida_bytes, ida_entry, ida_name, ida_funcs, ida_auto, idc, ida_idp

def u32(ea):
    return ida_bytes.get_dword(ea)

def lis_ori(ea):
    """Decode  lis rD,HI ; (ori|addi) rD,rD,LO  -> (value, next_ea) or None."""
    w1, w2 = u32(ea), u32(ea + 4)
    if (w1 & 0xFC1F0000) != 0x3C000000:            # addis rD,0,HI (lis)
        return None
    hi = w1 & 0xFFFF
    op = w2 & 0xFC000000
    if op == 0x60000000:                            # ori rD,rD,LO
        return ((hi << 16) | (w2 & 0xFFFF)), ea + 8
    if op == 0x38000000:                            # addi rD,rD,LO (sign-extended)
        lo = w2 & 0xFFFF
        lo = lo - 0x10000 if lo & 0x8000 else lo
        return ((hi << 16) + lo) & 0xFFFFFFFF, ea + 8
    return None

def main():
    seg = ida_segment.get_first_seg()
    base = seg.start_ea
    img_end = seg.end_ea
    entry = base + 0x100
    print("[*] loaded image segment: 0x%08X - 0x%08X (entry 0x%08X)" % (base, img_end, entry))

    # --- recover BSS extent + SDA bases from the prologue --------------------
    a = lis_ori(entry)                       # r10 = BSS start
    b = lis_ori(a[1]) if a else None         # r11 = BSS end
    sda13 = lis_ori(base + 0x124)            # r13 = _SDA_BASE_
    sda2  = lis_ori(base + 0x12C)            # r2  = _SDA2_BASE_
    mainj = lis_ori(base + 0x134)            # r10 = C entry (mtlr;blr target)

    if not a or not b:
        print("[!] prologue at base+0x100 is not the expected BSS-clear; "
              "did you load at 0x00400000 with PPC big-endian?")
        return
    bss_start, bss_end = a[0], b[0]
    if bss_start != img_end:
        print("[!] WARNING bss_start 0x%08X != image end 0x%08X "
              "(load base/size likely wrong)" % (bss_start, img_end))

    # --- create the BSS segment ---------------------------------------------
    if ida_segment.getseg(bss_start) is None or ida_segment.get_segm_end(bss_start) < bss_end:
        s = ida_segment.segment_t()
        s.start_ea, s.end_ea = bss_start, bss_end
        s.bitness = 1  # 32-bit
        ida_segment.add_segm_ex(s, "BSS", "BSS",
                                ida_segment.ADDSEG_OR_DIE | ida_segment.ADDSEG_SPARSE)
        print("[+] BSS segment 0x%08X - 0x%08X" % (bss_start, bss_end))

    # name the loaded segment + make it a code-bearing class
    ida_segment.set_segm_name(seg, "RAM")
    ida_segment.set_segm_class(seg, "CODE")

    # --- EABI small-data anchors so Hex-Rays resolves @sda globals -----------
    if sda13:
        ida_name.set_name(sda13[0], "_SDA_BASE_", ida_name.SN_FORCE)
        print("[+] _SDA_BASE_  (r13) = 0x%08X" % sda13[0])
    if sda2:
        ida_name.set_name(sda2[0], "_SDA2_BASE_", ida_name.SN_FORCE)
        print("[+] _SDA2_BASE_ (r2)  = 0x%08X" % sda2[0])

    # --- entry point + C entry ----------------------------------------------
    ida_bytes.del_items(entry, ida_bytes.DELIT_SIMPLE, 4)
    ida_auto.auto_make_code(entry)
    ida_funcs.add_func(entry)
    ida_name.set_name(entry, "_start", ida_name.SN_FORCE)
    ida_entry.add_entry(entry, entry, "_start", True)
    if mainj:
        ida_auto.auto_make_code(mainj[0])
        ida_funcs.add_func(mainj[0])
        ida_name.set_name(mainj[0], "ironware_main", ida_name.SN_FORCE)
        print("[+] ironware_main = 0x%08X" % mainj[0])

    print("[*] planning analysis over 0x%08X-0x%08X ..." % (base, img_end))
    ida_auto.plan_and_wait(base, img_end)
    print("[*] done. Summary:")
    print("    base        0x%08X" % base)
    print("    image end   0x%08X" % img_end)
    print("    BSS         0x%08X - 0x%08X" % (bss_start, bss_end))
    print("    _start      0x%08X" % entry)
    if mainj: print("    main        0x%08X" % mainj[0])

main()
