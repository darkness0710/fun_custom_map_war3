#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
w3obj.py -- doc va ghi file du lieu Object Editor cua Warcraft III.

    python w3obj.py dump    test2.w3x/war3map.w3a
    python w3obj.py check   test2.w3x/war3map.w3a     # doc roi ghi lai,
                                                      # so tung byte
    python w3obj.py checkall test2.w3x                # kiem moi file co

    python w3obj.py levels  test2.w3x/war3map.w3a 10  # alev = 10 cho MOI
                                                      # ability tu tao
    python w3obj.py set     test2.w3x/war3map.w3a A001 alev 10
    python w3obj.py set     test2.w3x/war3map.w3a A001 anam "Chuong"

    Them --dry de chi in ra, khong ghi.

MUC DICH. Bang skill can 21 ability x 10 level = 210 dong du lieu. Go tay
trong World Editor thi hong vi moi tay chu khong phai vi kho. File nay
cho phep SINH RA chung, giong cach build.py sinh war3map.lua.

CACH LAM CHO AN TOAN. File sai dinh dang thi World Editor co the khong mo
duoc map, hoac lang le nuot mat object -- kieu hong te nhat vi khong bao
gi. Nen truoc khi sinh bat cu thu gi, lenh "check" doc file DO CHINH WORLD
EDITOR ghi ra roi dung lai no tu dau. Khop tung byte thi bo ghi moi dung
duoc. Khong khop la co cho tao hieu sai, va tao dung lai.

DINH DANG (gioi cho phien ban 2, la ban 1.31 dang dung):

    int   phien ban
    int   so object GOC bi sua      -- bang 1
      moi object:
        char[4] id goc
        char[4] id moi              -- 0 o bang 1
        int     so truong sua
          moi truong:
            char[4] ma truong
            int     kieu   0=int 1=real 2=unreal 3=string
            int     level          \  CHI co o w3a, w3d, w3q.
            int     con tro du lieu/  Day la cho 10 level nam.
            <gia tri theo kieu>
            char[4] dau het truong
    int   so object TU TAO          -- bang 2
      ... giong het

w3u, w3t, w3b, w3h KHONG co hai truong level/con tro. Do la khac biet duy
nhat giua hai ho file.
"""

import os
import shutil
import struct
import sys

# File nao co truong level + con tro du lieu trong moi muc sua.
LEVELED_EXT = (".w3a", ".w3d", ".w3q")
OBJ_EXTS = (".w3a", ".w3d", ".w3q", ".w3u", ".w3t", ".w3b", ".w3h")

TYPE_INT, TYPE_REAL, TYPE_UNREAL, TYPE_STRING = 0, 1, 2, 3
TYPE_NAME = {0: "int", 1: "real", 2: "unreal", 3: "string"}


class Mod(object):
    """Mot truong bi sua cua mot object."""

    def __init__(self, mid, vtype, value, level=0, dptr=0, end=None):
        self.mid = mid
        self.vtype = vtype
        self.value = value
        self.level = level
        self.dptr = dptr
        self.end = end          # 4 byte dong duoi; giu de dung lai dung y nguyen

    def __repr__(self):
        lv = "" if self.level == 0 else "  level=%d" % self.level
        return "%-6s %-7s %r%s" % (self.mid, TYPE_NAME[self.vtype],
                                   self.value, lv)


class Obj(object):
    """Mot object: id goc, id moi, danh sach truong sua."""

    def __init__(self, base, newid, mods=None):
        self.base = base
        self.newid = newid
        self.mods = mods if mods is not None else []

    def __repr__(self):
        return "%s -> %s (%d truong)" % (self.base, self.newid or "(goc)",
                                         len(self.mods))


class Reader(object):
    def __init__(self, raw):
        self.raw = raw
        self.off = 0

    def i32(self):
        v = struct.unpack_from("<i", self.raw, self.off)[0]
        self.off += 4
        return v

    def f32(self):
        v = struct.unpack_from("<f", self.raw, self.off)[0]
        self.off += 4
        return v

    def tag(self):
        v = self.raw[self.off:self.off + 4]
        self.off += 4
        return v.decode("latin-1")

    def cstr(self):
        # surrogateescape: chu tieng Viet doc ra dung, ma byte la nao khong
        # phai UTF-8 cung khong mat -- ghi lai van ra dung tung byte.
        end = self.raw.index(b"\0", self.off)
        v = self.raw[self.off:end].decode("utf-8", "surrogateescape")
        self.off = end + 1
        return v


def parse(raw, leveled):
    """raw -> (version, bang_goc, bang_tu_tao). Loi neu con byte thua."""
    r = Reader(raw)
    version = r.i32()
    tables = []
    for _ in range(2):
        objs = []
        for _ in range(r.i32()):
            base, newid = r.tag(), r.tag()
            mods = []
            for _ in range(r.i32()):
                mid = r.tag()
                vtype = r.i32()
                level = r.i32() if leveled else 0
                dptr = r.i32() if leveled else 0
                if vtype == TYPE_STRING:
                    value = r.cstr()
                elif vtype in (TYPE_REAL, TYPE_UNREAL):
                    value = r.f32()
                else:
                    value = r.i32()
                mods.append(Mod(mid, vtype, value, level, dptr, r.tag()))
            objs.append(Obj(base, newid, mods))
        tables.append(objs)

    if r.off != len(raw):
        raise ValueError("doc xong con thua %d byte -- dinh dang khong nhu hieu"
                         % (len(raw) - r.off))
    return version, tables[0], tables[1]


def build(version, orig, custom, leveled):
    """Nguoc lai cua parse(). Tra ve bytes."""
    out = [struct.pack("<i", version)]
    for objs in (orig, custom):
        out.append(struct.pack("<i", len(objs)))
        for o in objs:
            out.append(o.base.encode("latin-1"))
            out.append(o.newid.encode("latin-1"))
            out.append(struct.pack("<i", len(o.mods)))
            for m in o.mods:
                out.append(m.mid.encode("latin-1"))
                out.append(struct.pack("<i", m.vtype))
                if leveled:
                    out.append(struct.pack("<ii", m.level, m.dptr))
                if m.vtype == TYPE_STRING:
                    out.append(m.value.encode("utf-8", "surrogateescape") + b"\0")
                elif m.vtype in (TYPE_REAL, TYPE_UNREAL):
                    out.append(struct.pack("<f", m.value))
                else:
                    out.append(struct.pack("<i", m.value))
                end = m.end if m.end is not None else (o.newid or o.base)
                out.append(end.encode("latin-1"))
    return b"".join(out)


def is_leveled(path):
    return os.path.splitext(path)[1].lower() in LEVELED_EXT


def read_file(path):
    with open(path, "rb") as f:
        raw = f.read()
    return parse(raw, is_leveled(path)), raw


# Moi truong World Editor tu ghi deu ket bang BON BYTE 0 -- do duoc tren
# ca 54 truong cua war3map.w3a hien co, khong co ngoai le. Mod moi phai
# dung dung the, neu khong file lech va World Editor co the nuot mat
# object ma khong bao gi.
END_TAG = "\x00\x00\x00\x00"

# Truong nao thuoc kieu nao. Chi liet ke thu DA DO duoc -- xem
# docs/06-object-editor/sua-va-clone-ability.md. Truong khong co o day
# thi tu choi ghi, chu khong doan kieu.
FIELD_TYPE = {
    "alev": TYPE_INT,      "aher": TYPE_INT,
    "abpx": TYPE_INT,      "abpy": TYPE_INT,
    "arpx": TYPE_INT,      "arpy": TYPE_INT,
    "aubx": TYPE_INT,      "auby": TYPE_INT,
    "acdn": TYPE_UNREAL,   "adur": TYPE_UNREAL,  "ahdu": TYPE_UNREAL,
    "arac": TYPE_STRING,   "aart": TYPE_STRING,  "arar": TYPE_STRING,
    "anam": TYPE_STRING,   "aret": TYPE_STRING,  "arut": TYPE_STRING,
    "aub1": TYPE_STRING,   "atp1": TYPE_STRING,  "ahky": TYPE_STRING,
}


def set_field(obj, mid, value, level=0):
    """Sua truong neu da co, them moi neu chua. Tra ve (cu, moi)."""
    vtype = FIELD_TYPE.get(mid)
    if vtype is None:
        raise ValueError("chua do duoc kieu cua truong '%s' -- xem "
                         "docs/06-object-editor/sua-va-clone-ability.md" % mid)
    if vtype == TYPE_STRING:
        value = str(value)
    elif vtype == TYPE_INT:
        value = int(value)
    else:
        value = float(value)

    for m in obj.mods:
        if m.mid == mid and m.level == level:
            cu = m.value
            m.value = value
            return cu, value

    obj.mods.append(Mod(mid, vtype, value, level, 0, END_TAG))
    return None, value


def write_back(path, version, orig, custom):
    """Ghi lai, co sao luu va co DOC LAI de chac chan dung dinh dang."""
    leveled = is_leveled(path)
    blob = build(version, orig, custom, leveled)

    # Doc lai ngay. File sai dinh dang thi World Editor co the khong mo
    # duoc map, hoac lang le nuot mat object -- kieu hong te nhat vi
    # khong bao gi. Kiem truoc khi cham vao file that.
    try:
        v2, o2, c2 = parse(blob, leveled)
    except Exception as e:
        print("[loi] doc lai ban vua dung KHONG duoc: %s -- da huy" % e)
        return False
    if v2 != version or len(o2) != len(orig) or len(c2) != len(custom):
        print("[loi] doc lai khong khop so object -- da huy")
        return False

    bak = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build")
    os.makedirs(bak, exist_ok=True)
    shutil.copyfile(path, os.path.join(bak, os.path.basename(path) + ".goc"))
    with open(path, "wb") as f:
        f.write(blob)
    print("[ok] da ghi %s (%d byte); ban cu o build/%s.goc"
          % (path, len(blob), os.path.basename(path)))
    return True


def cmd_set(path, objid, mid, value, dry):
    (version, orig, custom), raw = read_file(path)
    hit = [o for o in orig + custom if (o.newid or o.base) == objid]
    if not hit:
        print("[loi] khong thay object '%s'" % objid)
        return False
    for o in hit:
        cu, moi = set_field(o, mid, value)
        print("  %s.%s : %s -> %s" % (objid, mid,
              "(chua co)" if cu is None else repr(cu), repr(moi)))
    if dry:
        print("[dry] khong ghi gi.")
        return True
    return write_back(path, version, orig, custom)


def cmd_levels(path, n, dry):
    """Dat Stats - Levels cho MOI ability tu tao.

    Day la viec dau tien phai lam voi bo sinh nay: 6 trong 7 ability cua
    Hart con giu so bac goc cua Blizzard (1-3). Nang qua bac do thi
    SetUnitAbilityLevel KEP XUONG IM LANG -- tra du tien, bang ghi 10/10,
    trong game van la bac 3.
    """
    (version, orig, custom), raw = read_file(path)
    n = int(n)
    doi = 0
    for o in custom:
        cu, moi = set_field(o, "alev", n)
        dau = "   " if cu == moi else "-> "
        if cu != moi:
            doi += 1
        print("  %s%-5s alev : %s -> %d"
              % (dau, o.newid or o.base, "(chua co)" if cu is None else cu, moi))
    print("[%d/%d object doi]" % (doi, len(custom)))
    if dry:
        print("[dry] khong ghi gi.")
        return True
    if doi == 0:
        print("[ok] khong co gi de doi.")
        return True
    return write_back(path, version, orig, custom)


def cmd_dump(path):
    (version, orig, custom), raw = read_file(path)
    print("%s -- %d byte, phien ban %d, %s"
          % (os.path.basename(path), len(raw), version,
             "co level" if is_leveled(path) else "khong co level"))
    for name, objs in (("GOC", orig), ("TU TAO", custom)):
        print("\n--- bang %s: %d object ---" % (name, len(objs)))
        for o in objs:
            print("  %s" % o)
            for m in o.mods:
                print("      %s" % m)


def cmd_check(path):
    """Doc file cua World Editor roi dung lai. Khop tung byte moi la dung."""
    (version, orig, custom), raw = read_file(path)
    again = build(version, orig, custom, is_leveled(path))

    name = os.path.basename(path)
    if again == raw:
        nmods = sum(len(o.mods) for o in orig + custom)
        print("[ok]   %-16s %5d byte, %d object, %d truong -- dung lai khop "
              "tung byte" % (name, len(raw), len(orig) + len(custom), nmods))
        return True

    print("[LECH] %-16s %d byte vao, %d byte ra" % (name, len(raw), len(again)))
    for i in range(min(len(raw), len(again))):
        if raw[i] != again[i]:
            lo, hi = max(0, i - 8), i + 8
            print("       byte dau tien lech o vi tri %d" % i)
            print("       WE   : %s" % raw[lo:hi].hex(" "))
            print("       minh : %s" % again[lo:hi].hex(" "))
            break
    return False


def cmd_checkall(map_dir):
    found = [os.path.join(map_dir, n) for n in sorted(os.listdir(map_dir))
             if n.lower().endswith(OBJ_EXTS)]
    if not found:
        print("khong thay file object nao trong " + map_dir)
        return False
    return all([cmd_check(p) for p in found])


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    cmd, target = sys.argv[1], sys.argv[2]
    if cmd == "dump":
        cmd_dump(target)
        return 0
    if cmd == "check":
        return 0 if cmd_check(target) else 1
    if cmd == "checkall":
        return 0 if cmd_checkall(target) else 1

    dry = "--dry" in sys.argv
    args = [a for a in sys.argv[3:] if a != "--dry"]

    if cmd == "levels":
        if len(args) != 1:
            print("dung: w3obj.py levels <file.w3a> <so bac> [--dry]")
            return 2
        return 0 if cmd_levels(target, args[0], dry) else 1

    if cmd == "set":
        if len(args) != 3:
            print("dung: w3obj.py set <file> <id> <truong> <gia tri> [--dry]")
            return 2
        return 0 if cmd_set(target, args[0], args[1], args[2], dry) else 1

    print("lenh khong biet: " + cmd)
    return 2


if __name__ == "__main__":
    sys.exit(main())
