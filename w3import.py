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

Byte "co" CHUA DO DUOC tren ban nay. Cac tool khac ghi 5, 8, 10 hoac 13
tuy ban. Script nay ghi CO_MAC_DINH; neu World Editor mo ra thay sai thi
chay "list" sau khi WE luu de doc lai gia tri that roi sua hang so nay.
Khong doan mo: file dat dung cho moi la thu lam model hien duoc, con
war3map.imp chi de Import Manager liet ke.
"""

import os
import shutil
import struct
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
CO_MAC_DINH = 13


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
        co = raw[off]
        off += 1
        end = raw.index(b"\0", off)
        out.append((co, raw[off:end].decode("latin-1")))
        off = end + 1
    if off != len(raw):
        print("[canh bao] doc xong con thua %d byte" % (len(raw) - off))
    return ver, out


def write_imp(map_dir, ver, muc):
    out = [struct.pack("<ii", ver, len(muc))]
    for co, duong in muc:
        out.append(bytes([co]))
        out.append(duong.encode("latin-1") + b"\0")
    with open(imp_path(map_dir), "wb") as f:
        f.write(b"".join(out))


def chuan(duong):
    """Warcraft dung dau \\ trong duong dan."""
    return duong.replace("/", "\\").lstrip("\\")


def cmd_list(map_dir):
    ver, muc = read_imp(map_dir)
    print("war3map.imp -- phien ban %d, %d muc" % (ver, len(muc)))
    for co, duong in muc:
        tren_dia = os.path.join(map_dir, duong.replace("\\", os.sep))
        co_that = "co" if os.path.exists(tren_dia) else "THIEU TREN DIA"
        kich = os.path.getsize(tren_dia) if os.path.exists(tren_dia) else 0
        print("  co=%-3d %-44s %9s byte  %s"
              % (co, duong, format(kich, ","), co_that))


def cmd_add(map_dir, nguon, dich):
    if not os.path.exists(nguon):
        raise SystemExit("[loi] khong thay file nguon: " + nguon)
    dich = chuan(dich)

    tren_dia = os.path.join(map_dir, dich.replace("\\", os.sep))
    thu_muc = os.path.dirname(tren_dia)
    if thu_muc and not os.path.isdir(thu_muc):
        os.makedirs(thu_muc)
    shutil.copy2(nguon, tren_dia)

    ver, muc = read_imp(map_dir)
    muc = [m for m in muc if m[1].lower() != dich.lower()]
    muc.append((CO_MAC_DINH, dich))
    write_imp(map_dir, ver, muc)

    print("[ok] %s  ->  %s  (%s byte)"
          % (nguon, dich, format(os.path.getsize(tren_dia), ",")))
    return 0


def cmd_rm(map_dir, dich):
    dich = chuan(dich)
    ver, muc = read_imp(map_dir)
    con = [m for m in muc if m[1].lower() != dich.lower()]
    if len(con) == len(muc):
        print("[canh bao] khong co muc nao ten " + dich)
    write_imp(map_dir, ver, con)

    tren_dia = os.path.join(map_dir, dich.replace("\\", os.sep))
    if os.path.exists(tren_dia):
        os.remove(tren_dia)
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
