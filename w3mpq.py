#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
w3mpq.py -- xem ben trong file .w3x da dong goi co nhung gi.

    python w3mpq.py info  <file.w3x>
    python w3mpq.py has   <file.w3x> "units\\HotS\\Uther\\Uther.blp"

Dung de tra loi MOT cau hoi ma tu ngoai khong doan duoc: file nay CO
thuc su nam trong map da dong goi khong, va o duong dan nao.

World Editor doc thang thu muc map khi hien preview, nhung game thi doc
file MPQ do no dong goi. Hai thu do co the khac nhau -- da dinh mot lan:
model hien dep trong World Editor ma vao game den si.

Chi doc bang bam (hash table), khong giai nen. The la du de tra loi
"co hay khong" va "bao nhieu byte".
"""

import os
import struct
import sys

# Bang ma cua MPQ, sinh theo dung thuat toan cua Blizzard.
_CRYPT = []


def _init_crypt():
    if _CRYPT:
        return
    seed = 0x00100001
    tbl = [0] * 0x500
    for i in range(0x100):
        idx = i
        for _ in range(5):
            seed = (seed * 125 + 3) % 0x2AAAAB
            t1 = (seed & 0xFFFF) << 16
            seed = (seed * 125 + 3) % 0x2AAAAB
            t2 = seed & 0xFFFF
            tbl[idx] = t1 | t2
            idx += 0x100
    _CRYPT.extend(tbl)


def _hash(s, kind):
    """kind: 0 = vi tri bang, 1 = bam A, 2 = bam B, 3 = khoa giai ma."""
    _init_crypt()
    seed1, seed2 = 0x7FED7FED, 0xEEEEEEEE
    for ch in s.upper().replace("/", "\\"):
        c = ord(ch)
        seed1 = _CRYPT[(kind << 8) + c] ^ ((seed1 + seed2) & 0xFFFFFFFF)
        seed2 = (c + seed1 + seed2 + (seed2 << 5) + 3) & 0xFFFFFFFF
    return seed1 & 0xFFFFFFFF


def _decrypt(data, key):
    _init_crypt()
    out = bytearray()
    seed2 = 0xEEEEEEEE
    for i in range(len(data) // 4):
        seed2 = (seed2 + _CRYPT[0x400 + (key & 0xFF)]) & 0xFFFFFFFF
        v = struct.unpack_from("<I", data, i * 4)[0]
        v = v ^ ((key + seed2) & 0xFFFFFFFF)
        key = (((~key << 0x15) + 0x11111111) | (key >> 0x0B)) & 0xFFFFFFFF
        seed2 = (v + seed2 + (seed2 << 5) + 3) & 0xFFFFFFFF
        out += struct.pack("<I", v)
    return bytes(out)


class Mpq(object):
    def __init__(self, path):
        raw = open(path, "rb").read()
        off = raw.find(b"MPQ\x1a")
        if off < 0:
            raise SystemExit("[loi] khong thay chu ky MPQ trong " + path)
        self.raw, self.base = raw, off
        (self.hsize, self.asize, self.ver, self.bshift,
         hpos, bpos, self.hcnt, self.bcnt) = struct.unpack_from("<IIHHIIII", raw, off + 4)

        h = _decrypt(raw[off + hpos: off + hpos + self.hcnt * 16], _hash("(hash table)", 3))
        self.hash = [struct.unpack_from("<IIHHI", h, i * 16) for i in range(self.hcnt)]
        b = _decrypt(raw[off + bpos: off + bpos + self.bcnt * 16], _hash("(block table)", 3))
        self.block = [struct.unpack_from("<IIII", b, i * 16) for i in range(self.bcnt)]

    def find(self, name):
        """Tra ve (kich thuoc nen, kich thuoc that) hoac None."""
        i0 = _hash(name, 0) % self.hcnt
        a, bb = _hash(name, 1), _hash(name, 2)
        i = i0
        while True:
            h1, h2, needle, plat, blk = self.hash[i]
            if blk == 0xFFFFFFFF:
                return None                 # o trong -> khong co
            if h1 == a and h2 == bb and blk != 0xFFFFFFFE:
                pos, csz, usz, flags = self.block[blk]
                return csz, usz, flags
            i = (i + 1) % self.hcnt
            if i == i0:
                return None


def _encrypt(data, key):
    _init_crypt()
    out = bytearray()
    seed2 = 0xEEEEEEEE
    for i in range(len(data) // 4):
        seed2 = (seed2 + _CRYPT[0x400 + (key & 0xFF)]) & 0xFFFFFFFF
        v = struct.unpack_from("<I", data, i * 4)[0]
        enc = v ^ ((key + seed2) & 0xFFFFFFFF)
        key = (((~key << 0x15) + 0x11111111) | (key >> 0x0B)) & 0xFFFFFFFF
        # seed2 cap nhat theo BAN RO, nen giai ma la phep nguoc dung.
        seed2 = (v + seed2 + (seed2 << 5) + 3) & 0xFFFFFFFF
        out += struct.pack("<I", enc)
    return bytes(out)


def pack(folder, out_path):
    """Dong goi mot thu muc map thanh file .w3x choi duoc.

    De thoat khoi World Editor. Ctrl+F9 dong goi ban trong BO NHO cua
    World Editor, va moi lan Save no sinh lai war3map.lua -- xoa sach
    code vua chen. Tu dong goi thi khong dinh ca hai.

    KHONG NEN file nao. Map to hon, nhung bo di toan bo phan nen/giai nen
    -- va kich thuoc khong phai van de o day.
    """
    files = []
    for root, dirs, names in os.walk(folder):
        dirs.sort()
        for n in sorted(names):
            full = os.path.join(root, n)
            rel = os.path.relpath(full, folder).replace(os.sep, chr(92))
            files.append((rel, open(full, "rb").read()))
    if not files:
        raise SystemExit("[loi] thu muc rong: " + folder)

    # Bang bam phai la luy thua cua 2, va nen rong gap doi so file de it va cham.
    hcnt = 4
    while hcnt < len(files) * 2:
        hcnt *= 2

    HEADER = 32
    data, blocks, pos = bytearray(), [], HEADER
    for rel, raw in files:
        data += raw
        # 0x80000000 = EXISTS. Khong nen, khong ma hoa.
        blocks.append((pos, len(raw), len(raw), 0x80000000))
        pos += len(raw)

    hash_tbl = [[0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF, 0xFFFF, 0xFFFFFFFF]
                for _ in range(hcnt)]
    for idx, (rel, raw) in enumerate(files):
        i = _hash(rel, 0) % hcnt
        while hash_tbl[i][4] != 0xFFFFFFFF:      # do cho -- tim o trong
            i = (i + 1) % hcnt
        hash_tbl[i] = [_hash(rel, 1), _hash(rel, 2), 0, 0, idx]

    hbuf = b"".join(struct.pack("<IIHHI", *h) for h in hash_tbl)
    bbuf = b"".join(struct.pack("<IIII", *b) for b in blocks)
    hpos = HEADER + len(data)
    bpos = hpos + len(hbuf)
    asize = bpos + len(bbuf)

    head = struct.pack("<4sIIHHIIII", b"MPQ" + bytes([0x1A]), HEADER, asize,
                       0, 3, hpos, bpos, hcnt, len(blocks))
    with open(out_path, "wb") as f:
        f.write(head)
        f.write(bytes(data))
        f.write(_encrypt(hbuf, _hash("(hash table)", 3)))
        f.write(_encrypt(bbuf, _hash("(block table)", 3)))

    return len(files), asize


def cmd_pack(folder, out_path):
    n, size = pack(folder, out_path)
    print("[ok] %s -> %s" % (folder, out_path))
    print("     %d file, %s byte" % (n, format(size, ",")))

    # Doc lai bang chinh bo doc cua minh: moi file phai tim thay duoc.
    m = Mpq(out_path)
    missing = []
    for root, dirs, names in os.walk(folder):
        for nm in names:
            rel = os.path.relpath(os.path.join(root, nm), folder).replace(os.sep, chr(92))
            if m.find(rel) is None:
                missing.append(rel)
    if missing:
        print("[loi] doc lai khong thay: " + ", ".join(missing))
        return 1
    print("     doc lai: tim thay du %d/%d file" % (n, n))
    return 0


def cmd_info(path):
    m = Mpq(path)
    print("%s -- %s byte tren dia" % (os.path.basename(path),
                                      format(os.path.getsize(path), ",")))
    print("  hashTable=%d o, blockTable=%d file" % (m.hcnt, m.bcnt))
    dung = sum(1 for h in m.hash if h[4] != 0xFFFFFFFF and h[4] != 0xFFFFFFFE)
    print("  o hash dang dung: %d" % dung)


def cmd_has(path, *names):
    m = Mpq(path)
    for name in names:
        r = m.find(name)
        if r is None:
            print("  KHONG CO   %s" % name)
        else:
            csz, usz, flags = r
            print("  co         %-44s nen %s -> that %s byte"
                  % (name, format(csz, ","), format(usz, ",")))


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    cmd, path = sys.argv[1], sys.argv[2]
    if cmd == "info":
        cmd_info(path)
        return 0
    if cmd == "has" and len(sys.argv) >= 4:
        cmd_has(path, *sys.argv[3:])
        return 0
    if cmd == "pack" and len(sys.argv) >= 4:
        return cmd_pack(path, sys.argv[3])
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())
