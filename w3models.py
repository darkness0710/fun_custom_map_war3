# -*- coding: utf-8 -*-
"""w3models.py -- import model tu models/<nhom>/<Ten>/ vao thu muc map.

DUONG DAN TEXTURE DOC TU CHUNK CUA CHINH FILE .mdx, khong doc note.txt
va khong doan. Ly do o note.txt cua tung model: dat sai cho thi model ra
o XANH LA va KHONG co loi nao bao -- khong mot dong nao trong file vet.

Quy uoc dat trong archive:

    <Ten>.mdx      ->  war3mapImported\\<Ten>.mdx
    texture        ->  dat Y NGUYEN chuoi ma .mdx yeu cau

Texture nam o GOC archive chu khong trong thu muc con, vi chuoi trong
.mdx khong co thu muc. Do la doi hoi cua file, khong phai lua chon.

Texture bat dau bang "ReplaceableTextures\\" hoac "Textures\\" la do co
san cua Warcraft -- KHONG import, import lai chi phinh map.

MPQ bam ten KHONG phan biet hoa thuong (xem _hash trong w3mpq.py), nen
ten file tren dia viet thuong ma .mdx goi viet HOA van tra ra dung file.

    python w3models.py list        chi in ra, khong ghi gi
    python w3models.py import      chep vao map + ghi war3map.imp
"""
import glob
import io
import os
import re
import shutil
import struct
import sys

sys.stdout.reconfigure(encoding="utf-8")

MAP = "test2.w3x"
SRC = "models"
IMPORTED = "war3mapImported"

# Chuoi in duoc, ket thuc bang duoi file texture/model.
REF = re.compile(rb"[ -~]{3,120}?\.(?:blp|BLP|mdx|MDX|mdl|MDL|tga|TGA)")
STOCK = ("replaceabletextures", "textures")


def imp_read(path):
    if not os.path.isfile(path):
        return 1, []
    raw = open(path, "rb").read()
    ver, n = struct.unpack_from("<ii", raw, 0)
    out, off = [], 8
    for _ in range(n):
        flag = raw[off]; off += 1
        end = raw.index(b"\0", off)
        out.append((flag, raw[off:end].decode("latin-1")))
        off = end + 1
    return ver, out


def imp_write(path, ver, entries):
    body = struct.pack("<ii", ver, len(entries))
    for flag, name in entries:
        body += bytes([flag]) + name.encode("latin-1") + b"\0"
    open(path, "wb").write(body)


def scan(folder):
    """Tra ve (duong_dan_mdx, [(chuoi_trong_mdx, file_tren_dia), ...])."""
    mdx = sorted(glob.glob(os.path.join(folder, "*.mdx")))
    if not mdx:
        # Cung HINH DANG voi nhanh thanh cong. Tra ve hinh dang khac la
        # cho goi no tung ngay dong unpack -- da dinh mot lan.
        return None, [], ([], [])
    raw = io.open(mdx[0], "rb").read()

    ondisk = {f.lower(): f for f in os.listdir(folder)}
    want, stock, missing = [], [], []
    seen = set()
    for m in REF.findall(raw):
        ref = m.decode("latin-1")
        if ref in seen:
            continue
        seen.add(ref)
        if ref.replace("/", "\\").split("\\")[0].lower() in STOCK:
            stock.append(ref)
            continue
        base = ref.replace("/", "\\").split("\\")[-1]
        real = ondisk.get(base.lower())
        if real is None:
            missing.append(ref)
        else:
            want.append((ref, os.path.join(folder, real)))
    return mdx[0], want, (stock, missing)


def collect():
    out = []
    for folder in sorted(glob.glob(os.path.join(SRC, "*", "*"))):
        if not os.path.isdir(folder):
            continue
        mdx, want, (stock, missing) = scan(folder)
        if mdx is None:
            continue
        out.append((folder, mdx, want, stock, missing))
    return out


def cmd_list():
    bad = 0
    for folder, mdx, want, stock, missing in collect():
        name = os.path.basename(mdx)
        print("=== %s" % folder)
        print("    %-46s -> %s" % (name, IMPORTED + "\\" + name))
        for ref, src in want:
            print("    %-46s -> %s" % (os.path.basename(src), ref))
        for s in stock:
            print("    %-46s    (co san cua game, bo qua)" % s)
        for m in missing:
            bad += 1
            print("    %-46s    !! KHONG THAY FILE TREN DIA" % m)
        print()
    print("  %s" % ("moi texture deu co file" if bad == 0
                    else "%d texture THIEU FILE -- model se ra o xanh la" % bad))
    return 1 if bad else 0


def cmd_import():
    if cmd_list():
        print("  dung lai: sua phan thieu truoc da")
        return 1

    imp = os.path.join(MAP, "war3map.imp")
    ver, entries = imp_read(imp)
    have = set(n.replace("/", "\\").lower() for _, n in entries)
    flag = entries[0][0] if entries else 13

    copied = added = 0
    for folder, mdx, want, _stock, _missing in collect():
        jobs = [(IMPORTED + "\\" + os.path.basename(mdx), mdx)]
        jobs += [(ref, src) for ref, src in want]
        for rel, src in jobs:
            dst = os.path.join(MAP, rel.replace("\\", os.sep))
            os.makedirs(os.path.dirname(dst) or ".", exist_ok=True)
            shutil.copyfile(src, dst)
            copied += 1
            if rel.replace("/", "\\").lower() not in have:
                entries.append((flag, rel))
                have.add(rel.replace("/", "\\").lower())
                added += 1

    imp_write(imp, ver, entries)
    print("  chep %d file, them %d muc vao war3map.imp (tong %d)"
          % (copied, added, len(entries)))
    return 0


def main(argv):
    cmd = argv[1] if len(argv) > 1 else ""
    if cmd == "list":
        return cmd_list()
    if cmd == "import":
        return cmd_import()
    print(__doc__)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
