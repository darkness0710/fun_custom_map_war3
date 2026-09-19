# -*- coding: utf-8 -*-
"""w3avatar.py -- anh chan dung cho unit tu tao: PNG -> BLP -> vao map.

    docs/01-tmp/avatar/<slug>-avatar.png     anh nguon
            |  w3blp.py
            v
    models/icons/avatar/<id>.blp             ban nguon
    test2.w3x/avatar/<id>.blp                ban trong map
    war3map.imp                              khai bao
    war3map.w3u  uico = avatar\\<id>.blp      gan vao unit

GHEP ANH VOI UNIT BANG CACH DOC war3map.w3u, KHONG GO TAY BANG ANH XA.

Moi unit B00N da co truong 'umdl' tro toi model cua no
(war3mapImported\\Yu'lon.mdx). Rut <slug> tu ten model do roi khop voi
ten file anh. Nghia la doi model cua mot unit thi anh tu di theo -- con
mot bang go tay thi se lech im lang dung vao ngay minh quen sua no.

    python w3avatar.py list      chi in ra phep ghep, khong ghi gi
    python w3avatar.py apply     sinh BLP, chep vao map, ghi imp + uico
"""
import glob
import os
import re
import shutil
import struct
import sys

sys.stdout.reconfigure(encoding="utf-8")

import w3blp
import w3obj

MAP = "test2.w3x"
SRC = "docs/01-tmp/avatar"
KEEP = "models/icons/avatar"
INMAP = "avatar"
SIZE = int(os.environ.get("AVATAR_SIZE", "256"))
QUALITY = 80


def slug(text):
    """'Yu'lon.mdx' -> 'yulon',  'Chi-Ji.mdx' -> 'chiji'."""
    base = text.replace("/", "\\").split("\\")[-1]
    base = os.path.splitext(base)[0]
    return re.sub(r"[^a-z0-9]", "", base.lower())


def field(obj, mid):
    for m in obj.mods:
        if m.mid == mid:
            return m.value
    return None


def pairs():
    """[(unit_id, duong_dan_png, slug)] -- doc tu w3u, khong go tay."""
    (version, orig, custom), _raw = w3obj.read_file(
        os.path.join(MAP, "war3map.w3u"))

    have = {}
    for f in glob.glob(os.path.join(SRC, "*.png")):
        have[slug(os.path.basename(f)).replace("avatar", "")] = f

    out, miss = [], []
    for ob in custom:
        mdl = field(ob, "umdl")
        if mdl is None:
            continue
        s = slug(mdl)
        png = have.get(s)
        if png is None:
            miss.append((ob.newid, mdl, s))
        else:
            out.append((ob.newid, png, s))
    return out, miss


def cmd_list():
    out, skip = pairs()
    print("  %-6s %-16s %s" % ("unit", "slug tu umdl", "anh nguon"))
    for uid, png, s in out:
        print("  %-6s %-16s %s" % (uid, s, png))
    # Thu muc anh LA danh sach viec can lam. Unit khong co anh trong do
    # thi khong phai loi -- ba hero da co uico rieng tu truoc. Van in ra
    # de thay minh bo sot con nao khong.
    for uid, mdl, s in skip:
        print("  %-6s %-16s (bo qua -- khong co anh trong %s)" % (uid, s, SRC))
    print("\n  ghep %d unit, bo qua %d" % (len(out), len(skip)))
    return 0


def imp_read(path):
    if not os.path.isfile(path):
        return 1, []
    raw = open(path, "rb").read()
    ver, n = struct.unpack_from("<ii", raw, 0)
    res, off = [], 8
    for _ in range(n):
        flag = raw[off]; off += 1
        end = raw.index(b"\0", off)
        res.append((flag, raw[off:end].decode("latin-1")))
        off = end + 1
    return ver, res


def imp_write(path, ver, entries):
    body = struct.pack("<ii", ver, len(entries))
    for flag, name in entries:
        body += bytes([flag]) + name.encode("latin-1") + b"\0"
    open(path, "wb").write(body)


def cmd_apply():
    out, _skip = pairs()
    if not out:
        cmd_list()
        print("  khong co unit nao ghep duoc -- dung lai")
        return 1

    os.makedirs(KEEP, exist_ok=True)
    imp = os.path.join(MAP, "war3map.imp")
    ver, entries = imp_read(imp)
    have = set(n.replace("/", "\\").lower() for _, n in entries)
    flag = entries[0][0] if entries else 13

    added = 0
    for uid, png, _s in out:
        rel = INMAP + "\\" + uid + ".blp"
        dst = os.path.join(MAP, rel.replace("\\", os.sep))
        w3blp.encode(png, dst, SIZE, QUALITY)
        w3blp.cmd_check(dst, png)
        shutil.copyfile(dst, os.path.join(KEEP, uid + ".blp"))
        if rel.lower() not in have:
            entries.append((flag, rel))
            have.add(rel.lower())
            added += 1
    imp_write(imp, ver, entries)
    print("\n  sinh %d BLP (%dpx), them %d muc imp (tong %d)"
          % (len(out), SIZE, added, len(entries)))

    # uico phai dat SAU khi file ton tai: dat truoc thi neu buoc tren
    # hong, w3u se tro toi mot file khong co -- va o icon ra XANH LA.
    w3u = os.path.join(MAP, "war3map.w3u")
    for uid, _png, _s in out:
        w3obj.cmd_set(w3u, uid, "uico", INMAP + "\\" + uid + ".blp", False)
    return 0


def main(argv):
    cmd = argv[1] if len(argv) > 1 else ""
    if cmd == "list":
        return cmd_list()
    if cmd == "apply":
        return cmd_apply()
    print(__doc__)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
