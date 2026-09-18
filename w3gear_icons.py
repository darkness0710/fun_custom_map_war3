# -*- coding: utf-8 -*-
"""Sinh BLP cho icon Trang Bi va dang ky vao war3map.imp.

QUY UOC DUONG DAN -- thiet ke de THEM CANH GIOI KHONG PHAI SUA CODE:

    docs/01-tmp/<slot>/NN-*.png          anh nguon (nguoi ve)
        |  w3blp.py encode
        v
    test2.w3x/gear/<slot>/NN.blp         trong map
        |  war3map.imp
        v
    CFG.GEAR_ICON_PATH = "gear\\%s\\%02d.blp"

<slot> lay tu truong 'key' cua CFG.GEAR -- TIENG ANH, vi no thanh duong
dan that trong map (CLAUDE.md: ten thu muc phai tieng Anh).
NN la so CANH GIOI 1..20, khop CFG.REALMS.

Them canh gioi 2 cho Kiem = tha docs/01-tmp/kiem/02-*.png roi chay lai
script nay. Khong sua mot dong Lua nao.
"""
import glob
import io
import os
import re
import struct
import sys

sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, ".")
import w3blp

MAP = "test2.w3x"
SRC = "docs/01-tmp"
# Ban nguon cua icon trang bi, tach khoi thu muc map.
#
# Truoc day la "docs/01-tmp/convert": mot dong 160 file phang, ten theo
# anh nguon chu khong theo duong dan trong map -- tra lai thi phai doi
# chieu bang mat. Gio xep y HET cau truc trong map.
KEEP = "models/gear"

# thu muc anh nguon (tieng Viet, do nguoi ve dat) -> khoa slot (tieng Anh)
SLOT = {
    "mu":         "helm",
    "day-chuyen": "necklace",
    "ao":         "armor",
    "kiem":       "sword",
    "khien":      "shield",
    "ao-choang":  "cloak",
    "giay":       "boots",
    "nhan":       "ring",
}

SIZE = int(os.environ.get("GEAR_ICON_SIZE", "128"))
QUALITY = 80
# Anh canh gioi hien to (~340 px o 1080p) nen phai net hon icon 65 px.
REALM_SIZE = int(os.environ.get("REALM_ICON_SIZE", "256"))


def realm_of(fname):
    """01-pham-nhan-kiem.png -> 1"""
    m = re.match(r"(\d+)", os.path.basename(fname))
    return int(m.group(1)) if m else None


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


def hero_icons(entries, have, flag):
    """Icon hero: docs/01-tmp/hero/<id>.png -> test2.w3x/hero/<id>.blp

    Cung day chuyen voi Trang Bi, chi khac ten thu muc. <id> la ma unit
    bon ky tu (H001...) -- khop CFG.HEROES, ghep bang MA chu khong bang
    thu tu, vi bang hero co the doi thu tu ma ma thi khong.
    """
    made = 0
    for png in sorted(glob.glob(os.path.join(SRC, "hero", "*.png"))):
        uid = os.path.splitext(os.path.basename(png))[0]
        rel = "hero\%s.blp" % uid
        out = os.path.join(MAP, rel.replace("\\", os.sep))
        w3blp.encode(png, out, SIZE, QUALITY)
        w3blp.cmd_check(out, png)
        made += 1
        if rel.lower() not in have:
            entries.append((flag, rel))
            have.add(rel.lower())
    return made


def ui_icons(entries, have, flag):
    """O mau giao dien: docs/01-tmp/ui/<ten>.png -> test2.w3x/ui/<ten>.blp

    Anh 8x8 mot mau dac. Truoc day phai DOAN duong dan texture co san
    cua Warcraft, va doan sai thi ra o xanh la; gio mau nao can thi tu
    ve mot o, duong dan biet chac theo cach dung.
    """
    made = 0
    for png in sorted(glob.glob(os.path.join(SRC, "ui", "*.png"))):
        name = os.path.splitext(os.path.basename(png))[0]
        rel = "ui\%s.blp" % name
        out = os.path.join(MAP, rel.replace("\\", os.sep))
        # 8px, khong mipmap nhieu: o mau dac thi thu nho van ra chinh no.
        w3blp.encode(png, out, 8, QUALITY)
        made += 1
        if rel.lower() not in have:
            entries.append((flag, rel))
            have.add(rel.lower())
    return made


def realm_icons(entries, have, flag):
    """Anh canh gioi: docs/01-tmp/realm/NN-ten.png -> test2.w3x/realm/NN.blp

    Cung day chuyen voi Trang Bi. NN la so CANH GIOI 1..20, khop
    CFG.REALMS theo THU TU -- phan chu sau dau gach chi de nguoi doc,
    script khong dung toi.

    To hon icon (REALM_SIZE) vi no hien o kho ~340 px chu khong phai o
    icon 65 px: dung 128 thi mo nhin ra ngay.
    """
    made = 0
    for png in sorted(glob.glob(os.path.join(SRC, "realm", "*.png"))):
        r = realm_of(png)
        if r is None:
            print("  bo qua (ten khong bat dau bang so): %s" % png)
            continue
        rel = "realm\%02d.blp" % r
        out = os.path.join(MAP, rel.replace("\\", os.sep))
        w3blp.encode(png, out, REALM_SIZE, QUALITY)
        w3blp.cmd_check(out, png)
        made += 1
        if rel.lower() not in have:
            entries.append((flag, rel))
            have.add(rel.lower())
    return made


def main():
    ver, entries = imp_read(os.path.join(MAP, "war3map.imp"))
    have = set(n.replace("/", "\\").lower() for _, n in entries)
    flag = entries[0][0] if entries else 13

    made, added = 0, 0
    os.makedirs(KEEP, exist_ok=True)
    for folder, key in sorted(SLOT.items(), key=lambda kv: kv[1]):
        for png in sorted(glob.glob(os.path.join(SRC, folder, "*.png"))):
            r = realm_of(png)
            if r is None:
                print("  [bo qua] %s -- ten khong bat dau bang so canh gioi" % png)
                continue
            rel = "gear\\%s\\%02d.blp" % (key, r)
            out = os.path.join(MAP, rel.replace("\\", os.sep))
            n, lv, (w, h) = w3blp.encode(png, out, SIZE, QUALITY)
            d = w3blp.cmd_check(out, png)
            made += 1

            # Ban nguon, cung ten cung cau truc voi ban trong map.
            import shutil
            keep = os.path.join(KEEP, key)
            os.makedirs(keep, exist_ok=True)
            shutil.copyfile(out, os.path.join(keep, "%02d.blp" % r))

            if rel.lower() not in have:
                entries.append((flag, rel))
                have.add(rel.lower())
                added += 1

    made += hero_icons(entries, have, flag)
    made += realm_icons(entries, have, flag)
    made += ui_icons(entries, have, flag)

    imp_write(os.path.join(MAP, "war3map.imp"), ver, entries)
    print("\n  sinh %d file BLP (%dpx), them %d muc vao war3map.imp (tong %d)"
          % (made, SIZE, added, len(entries)))


if __name__ == "__main__":
    main()
