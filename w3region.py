#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
w3region.py -- sinh va doc war3map.w3r (vung cua World Editor).

    python w3region.py list            # in cac vung dang co
    python w3region.py gen             # sinh/lam moi 25 vung block
    python w3region.py gen --dry       # chi in ra, khong ghi

MUC DICH. Luoi 25 block hien chi ton tai duoi dang TOA DO tinh luc chay
(src/1_core/4_geometry.lua). World Editor khong nhin thay chung, nen khong
cach nao cam chuot ma sua. File nay ghi chung thanh VUNG THAT trong
war3map.w3r -- mo World Editor la thay du 25 o trong Region Palette, keo
tha va doi kich thuoc duoc.

Chay lai bao nhieu lan cung ra ket qua giong nhau: vung ten "Blk.." bi
sinh lai tu dau, moi vung khac giu nguyen.

TEN VUNG LA VI TRI, KHONG PHAI VAI TRO.
    Blk01..Blk25 -- doi vinh vien, khong bao gio doi ten.
    Vai tro ("day la phu ban", "day la linh mach") song trong CFG ben
    Lua. Nho vay doi y ve vai tro khong dong toi file nhi phan nao, va
    khong lam gay tham chieu gg_rct_<Ten> nao.

DINH DANG (do bang cach doc nguoc file World Editor tu ghi ra -- khop
tung byte 138/138):

    int    phien ban = 5
    int    so vung
      moi vung:
        float  left, bottom, right, top
        cstring ten
        int    so thu tu tao
        char[4] hieu ung thoi tiet (0 = khong)
        cstring am thanh nen
        byte[4] mau hien trong World Editor

CANH BAO. World Editor giu ban map trong BO NHO no. Dang mo World Editor
ma chay file nay thi lan Save ke tiep se ghi de mat -- dong World Editor
truoc. Cung mot cai bay ma build.py da canh bao.
"""

import argparse
import io
import os
import re
import shutil
import struct
import sys

ROOT    = os.path.dirname(os.path.abspath(__file__))
BAK_DIR = os.path.join(ROOT, "build")
PREFIX  = "Blk"          # tien to cua vung do file nay quan ly

# Vien World Editor chua quanh map, tinh bang o dia hinh. Vung choi duoc
# = kich thuoc map tru 2 x vien. Do duoc: 224 - 2x6 = 212, khop voi
# CFG.RIVER_TILES = 8 (5 block x 36 + 4 song x 8 = 212, le bang 0).
BORDER_TILES = 6
TILE         = 128.0

# Phai khop CFG trong src/1_core/1_config.lua.
GRID_COLS   = 5
GRID_ROWS   = 5
RIVER_TILES = 8

# Mau hien trong World Editor. Thu tu byte CHUA KIEM CHUNG -- vung do
# World Editor tu tao co mau ff8080ff, doan la RGBA. Neu mo WE thay mau
# sai thi dao hai byte dau. Dung mau mac dinh cho moi block: chua chot
# vai tro nao, ma to mau theo vai tro chua duyet la tu noi doi.
COLOR_DEFAULT = bytes((0xFF, 0x80, 0x80, 0xFF))


def die(msg):
    print("[loi] " + msg)
    sys.exit(1)


# ---------- doc / ghi ----------

def read_regions(path):
    d = open(path, "rb").read()
    if len(d) < 8:
        die("war3map.w3r qua ngan")
    ver, n = struct.unpack_from("<ii", d, 0)
    off, out = 8, []
    for _ in range(n):
        l, b, r, t = struct.unpack_from("<4f", d, off); off += 16
        e = d.index(b"\0", off); name = d[off:e].decode("latin1"); off = e + 1
        cre, = struct.unpack_from("<i", d, off); off += 4
        wea = d[off:off + 4]; off += 4
        e = d.index(b"\0", off); amb = d[off:e].decode("latin1"); off = e + 1
        col = d[off:off + 4]; off += 4
        out.append(dict(l=l, b=b, r=r, t=t, name=name, cre=cre,
                        wea=wea, amb=amb, col=col))
    if off != len(d):
        die("doc xong con thua %d byte -- dinh dang khong nhu hieu"
            % (len(d) - off))
    return ver, out


def write_regions(path, ver, regions):
    out = [struct.pack("<ii", ver, len(regions))]
    for i, g in enumerate(regions):
        out.append(struct.pack("<4f", g["l"], g["b"], g["r"], g["t"]))
        out.append(g["name"].encode("latin1") + b"\0")
        out.append(struct.pack("<i", i))          # so thu tu tao, danh lai
        out.append(g["wea"])
        out.append(g["amb"].encode("latin1") + b"\0")
        out.append(g["col"])
    blob = b"".join(out)

    # Doc lai ngay de chac chan ghi dung. File sai dinh dang thi World
    # Editor co the khong mo duoc map, hoac lang le nuot mat vung -- kieu
    # hong te nhat vi khong bao gi.
    tmp = path + ".tmp"
    open(tmp, "wb").write(blob)
    v2, r2 = read_regions(tmp)
    os.remove(tmp)
    if v2 != ver or len(r2) != len(regions):
        die("kiem tra sau khi ghi khong khop -- da huy, file cu con nguyen")

    os.makedirs(BAK_DIR, exist_ok=True)
    if os.path.isfile(path):
        shutil.copyfile(path, os.path.join(BAK_DIR, "war3map.w3r.goc"))
    open(path, "wb").write(blob)
    return len(blob)


# ---------- hinh hoc, khop 4_geometry.lua ----------

def map_size(w3e_path):
    d = open(w3e_path, "rb").read()
    if d[:4] != b"W3E!":
        die("war3map.w3e khong dung dau file")
    off = 8 + 1 + 4
    n, = struct.unpack_from("<i", d, off); off += 4 + 4 * n
    n, = struct.unpack_from("<i", d, off); off += 4 + 4 * n
    w, h = struct.unpack_from("<ii", d, off); off += 8
    cx, cy = struct.unpack_from("<2f", d, off)
    return w - 1, h - 1, cx, cy


def grid(w3e_path):
    tw, th, cx, cy = map_size(w3e_path)
    minX = cx + BORDER_TILES * TILE
    minY = cy + BORDER_TILES * TILE
    pw, ph = tw - 2 * BORDER_TILES, th - 2 * BORDER_TILES

    bw = (pw - (GRID_COLS - 1) * RIVER_TILES) // GRID_COLS
    bh = (ph - (GRID_ROWS - 1) * RIVER_TILES) // GRID_ROWS
    # Phan du day ra hai bien lam le, giong splitAxis trong 4_geometry.lua.
    mx = (pw - GRID_COLS * bw - (GRID_COLS - 1) * RIVER_TILES) // 2
    my = (ph - GRID_ROWS * bh - (GRID_ROWS - 1) * RIVER_TILES) // 2
    return dict(minX=minX + mx * TILE, minY=minY + my * TILE,
                blockW=bw * TILE, blockH=bh * TILE,
                pitchX=(bw + RIVER_TILES) * TILE,
                pitchY=(bh + RIVER_TILES) * TILE,
                tilesW=pw, tilesH=ph, blockTiles=bw)


def bounds(g, col, row):
    x0 = g["minX"] + (col - 1) * g["pitchX"]
    y0 = g["minY"] + (row - 1) * g["pitchY"]
    return x0, y0, x0 + g["blockW"], y0 + g["blockH"]


def block_at(g, x, y):
    for row in range(1, GRID_ROWS + 1):
        for col in range(1, GRID_COLS + 1):
            x0, y0, x1, y1 = bounds(g, col, row)
            if x0 <= x <= x1 and y0 <= y <= y1:
                return col, row, (row - 1) * GRID_COLS + col
    return None


# ---------- lenh ----------

def find_map(explicit):
    if explicit:
        p = explicit if os.path.isabs(explicit) else os.path.join(ROOT, explicit)
    else:
        found = [os.path.join(ROOT, n) for n in sorted(os.listdir(ROOT))
                 if n.lower().endswith((".w3x", ".w3m"))
                 and os.path.isdir(os.path.join(ROOT, n))]
        if len(found) != 1:
            die("khong xac dinh duoc map -- dung --map")
        p = found[0]
    if not os.path.isdir(p):
        die("khong thay thu muc map: " + p)
    return p


def cmd_list(map_dir):
    w3r = os.path.join(map_dir, "war3map.w3r")
    ver, regs = read_regions(w3r)
    g = grid(os.path.join(map_dir, "war3map.w3e"))
    print("war3map.w3r -- phien ban %d, %d vung" % (ver, len(regs)))
    print("luoi: %dx%d o choi duoc, block %d o (%.0f don vi)"
          % (g["tilesW"], g["tilesH"], g["blockTiles"], g["blockW"]))
    print()
    for r in regs:
        cx, cy = (r["l"] + r["r"]) / 2, (r["b"] + r["t"]) / 2
        hit = block_at(g, cx, cy)
        where = ("block #%d (%d,%d)" % (hit[2], hit[0], hit[1])) if hit \
                else "duoi song / ngoai luoi"
        print("  %-16s (%8.0f,%8.0f)-(%8.0f,%8.0f)  %s"
              % (r["name"], r["l"], r["b"], r["r"], r["t"], where))


def cmd_gen(map_dir, dry):
    w3r = os.path.join(map_dir, "war3map.w3r")
    ver, regs = read_regions(w3r)
    g = grid(os.path.join(map_dir, "war3map.w3e"))

    keep = [r for r in regs if not r["name"].startswith(PREFIX)]
    bo  = [r for r in regs if r["name"].startswith(PREFIX)]

    new = []
    for row in range(1, GRID_ROWS + 1):
        for col in range(1, GRID_COLS + 1):
            idx = (row - 1) * GRID_COLS + col
            x0, y0, x1, y1 = bounds(g, col, row)
            new.append(dict(l=x0, b=y0, r=x1, t=y1,
                            name="%s%02d" % (PREFIX, idx), cre=0,
                            wea=b"\0\0\0\0", amb="", col=COLOR_DEFAULT))

    print("giu nguyen %d vung tu tao: %s"
          % (len(keep), ", ".join(r["name"] for r in keep) or "(khong co)"))
    print("thay the   %d vung %s* cu" % (len(bo), PREFIX))
    print("sinh moi   %d vung block %.0f x %.0f don vi"
          % (len(new), g["blockW"], g["blockH"]))

    # Vung tu tao roi vao block nao -- de doi chieu voi luoi logic.
    for r in keep:
        hit = block_at(g, (r["l"] + r["r"]) / 2, (r["b"] + r["t"]) / 2)
        if hit:
            print("   %-16s nam trong block #%d (%d,%d)"
                  % (r["name"], hit[2], hit[0], hit[1]))
        else:
            print("   %-16s KHONG nam trong block nao (duoi song?)" % r["name"])

    if dry:
        print("\n[dry] khong ghi gi.")
        return

    n = write_regions(w3r, ver, keep + new)
    print("\n[ok] da ghi %s -- %d vung, %d byte" % (w3r, len(keep + new), n))
    print("[ok] ban cu chep vao build/war3map.w3r.goc")
    print("     Mo World Editor -> phim R -> thay %s01..%s%02d."
          % (PREFIX, PREFIX, GRID_COLS * GRID_ROWS))


def cmd_rm(map_dir, name, dry):
    """Xoa mot vung theo ten. Dung cho vung bo di ma con sot lai."""
    w3r = os.path.join(map_dir, "war3map.w3r")
    ver, regs = read_regions(w3r)

    # Ten ket thuc bang * thi xoa theo TIEN TO: "Blk*" xoa ca 25 vung.
    if name.endswith("*"):
        pre = name[:-1].lower()
        khop = lambda nm: nm.lower().startswith(pre)
    else:
        khop = lambda nm: nm.lower() == name.lower()

    keep = [r for r in regs if not khop(r["name"])]
    bo  = [r for r in regs if khop(r["name"])]
    if not bo:
        print("[canh bao] khong co vung nao khop %r" % name)
        print("   dang co: " + ", ".join(r["name"] for r in regs))
        return
    print("xoa %d vung: %s" % (len(bo), ", ".join(r["name"] for r in bo)))
    print("con lai %d vung" % len(keep))
    if dry:
        print("[dry] khong ghi gi.")
        return
    n = write_regions(w3r, ver, keep)
    print("[ok] da ghi %s -- %d vung, %d byte" % (w3r, len(keep), n))
    print("     dong gg_rct_* tuong ung trong war3map.lua se mat o lan"
          " World Editor luu sau.")


def lua_ident(name):
    """Ten vung -> ten bien. World Editor thay moi ky tu khong phai chu
    so bang gach duoi: "Region 004 Copy" -> Region_004_Copy."""
    return re.sub(r"[^0-9A-Za-z]", "_", name)


def cmd_sync(map_dir, dry):
    """Sinh lai CreateRegions() trong war3map.lua tu war3map.w3r.

    HAI FILE PHAI KHOP, va khong cai nao tu bat duoc cai kia:

        war3map.w3r    du lieu vung -- cai World Editor hien ra
        war3map.lua    CreateRegions() -- cai TAO RA bien gg_rct_* luc chay

    Doi ten trong .w3r ma khong doi trong .lua thi bien van mang ten cu,
    va CFG tra ra nil -- vung "khong ton tai" trong khi World Editor van
    hien no ra. Khong mot dong loi nao.

    World Editor tu sinh lai ham nay moi lan Save, nen lech chi xay ra
    khi sua .w3r bang cong cu ngoai (chinh la lenh rename o duoi).
    """
    lua = os.path.join(map_dir, "war3map.lua")
    if not os.path.isfile(lua):
        die("khong thay war3map.lua")
    ver, regs = read_regions(os.path.join(map_dir, "war3map.w3r"))

    body = ["function CreateRegions()", "    local we"]
    for g in regs:
        body.append("    gg_rct_%s = Rect(%.1f, %.1f, %.1f, %.1f)"
                    % (lua_ident(g["name"]), g["l"], g["b"], g["r"], g["t"]))
    body.append("end")
    new = chr(10).join(body)

    src = io.open(lua, encoding="utf-8").read()
    m = re.search(r"function CreateRegions\(\).*?" + chr(10) + "end", src, re.S)
    if m is None:
        die("khong thay function CreateRegions() trong war3map.lua")
    if m.group(0) == new:
        print("   war3map.lua da khop -- khong can sua")
        return 0

    print("   CreateRegions(): %d vung" % len(regs))
    for g in regs:
        print("      gg_rct_%s" % lua_ident(g["name"]))
    if dry:
        print()
        print("[dry] khong ghi gi.")
        return 0
    io.open(lua, "w", encoding="utf-8", newline=chr(10)).write(
        src[:m.start()] + new + src[m.end():])
    return 0


def cmd_rename(map_dir, pairs, dry):
    """Doi ten vung. Ten la thu DUY NHAT noi Lua voi World Editor --
    bien toan cuc la gg_rct_<Ten> -- nen doi o day thi phai doi ca ben
    CFG. Khong co cai nao tu bat duoc cai kia, va sai thi vung tra ve
    nil lang le.

    Da kiem: war3map.wtg va war3map.wct khong nhac ten vung nao, nen
    doi ten khong lam hong trigger cua World Editor."""
    path = os.path.join(map_dir, "war3map.w3r")
    ver, regs = read_regions(path)
    have = {r["name"]: r for r in regs}

    plan, bad = [], []
    for old, new in pairs:
        if old not in have:
            bad.append("khong co vung ten %r" % old)
        elif new in have and new != old:
            bad.append("da co vung ten %r roi" % new)
        else:
            plan.append((old, new))
    if bad:
        for b in bad:
            print("[loi] " + b)
        return 1

    for old, new in plan:
        print("   %-18s -> %s" % (old, new))
        have[old]["name"] = new

    if dry:
        print()
        print("[dry] khong ghi gi.")
        return 0
    write_regions(path, ver, regs)
    # NUA VIEC CON LAI. Doi ten trong .w3r ma quen .lua thi bien van
    # mang ten cu va vung tra ra nil -- da dinh mot lan.
    return cmd_sync(map_dir, dry)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("lenh", choices=["list", "gen", "rm", "rename", "sync"])
    ap.add_argument("--ten", help="ten vung can xoa (dung voi lenh rm)")
    ap.add_argument("--doi", action="append", metavar="CU=MOI",
                    help="doi ten vung; lap lai duoc nhieu lan")
    ap.add_argument("--map")
    ap.add_argument("--dry", action="store_true")
    a = ap.parse_args()

    map_dir = find_map(a.map)
    if a.lenh == "list":
        cmd_list(map_dir)
    elif a.lenh == "sync":
        raise SystemExit(cmd_sync(map_dir, a.dry))
    elif a.lenh == "rename":
        if not a.doi:
            raise SystemExit("[loi] lenh rename can --doi 'Ten Cu=TenMoi'")
        pairs = []
        for it in a.doi:
            if "=" not in it:
                raise SystemExit("[loi] --doi phai dang 'Ten Cu=TenMoi': %r" % it)
            old, new = it.split("=", 1)
            pairs.append((old, new))
        raise SystemExit(cmd_rename(map_dir, pairs, a.dry))
    elif a.lenh == "rm":
        if not a.ten:
            raise SystemExit("[loi] lenh rm can --ten <TenVung>")
        cmd_rm(map_dir, a.ten, a.dry)
    else:
        cmd_gen(map_dir, a.dry)


if __name__ == "__main__":
    main()
