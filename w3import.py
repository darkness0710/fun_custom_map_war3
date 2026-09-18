#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
w3import.py -- import file vao map ma khong phai mo Import Manager.

    python w3import.py list
    python w3import.py add models/heroes/UtherV2.mdx war3mapImported/UtherV2.mdx
    python w3import.py add models/heroes/Uther.blp  "units/HotS/Uther/Uther.blp"
    python w3import.py rm  war3mapImported/UtherV2.mdx

Map dang FOLDER thi "import" chi la hai viec:
  1. Dat file dung duong dan tuong doi ben trong thu muc map
  2. Ghi ten no vao war3map.imp

DUONG DAN LA THU QUAN TRONG NHAT. File .mdx ghi CUNG duong dan texture no
can, doc bang:

    python w3obj.py ... hoac xem TEXS chunk

Dat texture sai cho la model ra mau xanh la, va khong co loi nao bao.

DINH DANG war3map.imp:

    int   phien ban = 1
    int   so muc
      moi muc:
        byte  co
        chuoi ket thuc bang byte 0

Byte "co" la 21 (0x15), DO tu file World Editor tu tao ra. Truoc do
doan la 13 va World Editor doc phai thi bo qua luon war3map.lua khi dong
goi -- vao game khong co dong code nao chay, khong loi nao bao.
"""

import os
import shutil
import struct
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
# 0x15 = 21. DO DUOC tu file World Editor tu tao, khong phai doan.
# Truoc do doan la 13 -- World Editor doc phai thi bo qua luon
# war3map.lua khi dong goi, vao game khong co dong code nao chay va
# khong loi nao bao. Mat mot buoi.
#
# World Editor ghi 21 cho CA duong dan mac dinh lan duong dan tu dat.
CO_MAC_DINH = 21


def find_map():
    for n in sorted(os.listdir(ROOT)):
        p = os.path.join(ROOT, n)
        if n.lower().endswith((".w3x", ".w3m")) and os.path.isdir(p):
            return p
    raise SystemExit("[loi] khong thay map dang folder trong " + ROOT)


def imp_path(map_dir):
    return os.path.join(map_dir, "war3map.imp")


def read_imp(map_dir):
    """Tra ve (phien ban, [(co, duong dan), ...]). Chua co file thi bang rong."""
    p = imp_path(map_dir)
    if not os.path.exists(p):
        return 1, []
    raw = open(p, "rb").read()
    ver, n = struct.unpack_from("<ii", raw, 0)
    off, out = 8, []
    for _ in range(n):
        have = raw[off]
        off += 1
        end = raw.index(b"\0", off)
        out.append((have, raw[off:end].decode("latin-1")))
        off = end + 1
    if off != len(raw):
        print("[canh bao] doc xong con thua %d byte" % (len(raw) - off))
    return ver, out


def write_imp(map_dir, ver, entries):
    out = [struct.pack("<ii", ver, len(entries))]
    for have, path_ in entries:
        out.append(bytes([have]))
        out.append(path_.encode("latin-1") + b"\0")
    with open(imp_path(map_dir), "wb") as f:
        f.write(b"".join(out))


def normalize(path_):
    """Warcraft dung dau \\ trong duong dan."""
    return path_.replace("/", "\\").lstrip("\\")


def cmd_list(map_dir):
    ver, entries = read_imp(map_dir)
    print("war3map.imp -- phien ban %d, %d muc" % (ver, len(entries)))
    for have, path_ in entries:
        on_disk = os.path.join(map_dir, path_.replace("\\", os.sep))
        exists = "co" if os.path.exists(on_disk) else "THIEU TREN DIA"
        size = os.path.getsize(on_disk) if os.path.exists(on_disk) else 0
        print("  co=%-3d %-44s %9s byte  %s"
              % (have, path_, format(size, ","), exists))


def cmd_add(map_dir, source, dich):
    if not os.path.exists(source):
        raise SystemExit("[loi] khong thay file nguon: " + source)
    dich = normalize(dich)

    on_disk = os.path.join(map_dir, dich.replace("\\", os.sep))
    thu_muc = os.path.dirname(on_disk)
    if thu_muc and not os.path.isdir(thu_muc):
        os.makedirs(thu_muc)
    shutil.copy2(source, on_disk)

    ver, entries = read_imp(map_dir)
    entries = [m for m in entries if m[1].lower() != dich.lower()]
    entries.append((CO_MAC_DINH, dich))
    write_imp(map_dir, ver, entries)

    print("[ok] %s  ->  %s  (%s byte)"
          % (source, dich, format(os.path.getsize(on_disk), ",")))
    return 0


def cmd_rm(map_dir, dich):
    dich = normalize(dich)
    ver, entries = read_imp(map_dir)
    con = [m for m in entries if m[1].lower() != dich.lower()]
    if len(con) == len(entries):
        print("[canh bao] khong co muc nao ten " + dich)
    write_imp(map_dir, ver, con)

    on_disk = os.path.join(map_dir, dich.replace("\\", os.sep))
    if os.path.exists(on_disk):
        os.remove(on_disk)
    print("[ok] da go " + dich)
    return 0


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    map_dir = find_map()
    cmd = sys.argv[1]
    if cmd == "list":
        cmd_list(map_dir)
        return 0
    if cmd == "add" and len(sys.argv) >= 4:
        return cmd_add(map_dir, sys.argv[2], sys.argv[3])
    if cmd == "rm" and len(sys.argv) >= 3:
        return cmd_rm(map_dir, sys.argv[2])
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())
