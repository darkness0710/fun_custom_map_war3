# -*- coding: utf-8 -*-
"""w3blp.py -- doi anh thuong sang BLP1 (dinh dang texture cua Warcraft III).

DINH DANG DO DUOC TU CHINH FILE .blp TRONG MAP NAY, khong tra tai lieu
ngoai. Doc lai bang: python w3blp.py info <file.blp>

    0   4 byte   "BLP1"
    4   u32      compression  0 = JPEG, 1 = bang mau
    8   u32      alphaBits    0 hoac 8
   12   u32      width
   16   u32      height
   20   u32      extra
   24   u32      hasMipmaps
   28   16 x u32 offset cua tung muc mipmap
   92   16 x u32 size   cua tung muc mipmap
  156   u32      jpegHeaderSize
  160   ...      phan dau JPEG DUNG CHUNG cho moi muc
                 roi den du lieu tung muc tai offset[k]

BA DIEU DA DO, khong doan:

  1. JPEG ben trong luon BON KENH, ke ca khi alphaBits = 0.
     (war3mapMap.blp: alphaBits=0 ma SOF0 van 4 kenh, id=[0,1,2,3])
  2. KHONG co marker Adobe APP14 -- nen khong co phep bien doi mau nao,
     bon kenh la B, G, R, A tho.
  3. Phan dung chung la DQT + DHT; phan rieng tung muc la SOF + SOS tro
     di. Tach dung cho do thi 8 muc mipmap chi ton mot ban bang Huffman.

VI SAO 4 KENH MA KHONG SUBSAMPLE: JPEG chi subsample duoc kenh mau khi
anh la YCbCr 3 kenh. Bon kenh tho thi moi kenh luu day du -- do la ly do
file ra to hon uoc tinh tren anh RGB thuong khoang 2,4 lan. Da do:
128x128 that su ton ~24 KB chu khong phai ~10 KB.

Dung:
    python w3blp.py encode <anh> <ra.blp> [--size 128] [--quality 80]
    python w3blp.py decode <file.blp> <ra.png>
    python w3blp.py info   <file.blp>
    python w3blp.py check  <file.blp> <anh goc>     doc lai, so voi anh goc
"""
import io
import os
import struct
import sys

from PIL import Image, ImageChops

MAGIC = b"BLP1"
HDR = 156


# ---------------------------------------------------------------- JPEG

def split_jpeg(blob):
    """Tach mot stream JPEG lam (phan dung chung, phan rieng).

    Dung chung: DQT (bang luong tu) + DHT (bang Huffman) -- giong nhau o
    moi muc mipmap nen chi luu mot ban.
    Rieng:      SOF (kich thuoc) + SOS (du lieu) tro di.
    """
    i, shared, sof = 2, [], None
    while i < len(blob) - 1:
        if blob[i] != 0xFF:
            break
        m = blob[i + 1]
        if m == 0xD9:                       # EOI
            break
        ln = (blob[i + 2] << 8) | blob[i + 3]
        seg = blob[i:i + 2 + ln]
        if m in (0xDB, 0xC4):               # DQT, DHT
            shared.append(seg)
        elif m in (0xC0, 0xC1):             # SOF0/1
            sof = seg
        elif m == 0xDA:                      # SOS -- tu day la du lieu
            return b"\xff\xd8" + b"".join(shared), sof + blob[i:]
        i += 2 + ln
    raise ValueError("stream JPEG khong co SOS")


# ------------------------------------------------------------- mipmap

def mip_chain(img):
    """Chuoi mipmap tu anh goc xuong 1x1. Warcraft doi du chuoi: thieu
    muc nho thi luc thu nho game lay muc gan nhat va anh rang cua."""
    out = [img]
    w, h = img.size
    while w > 1 or h > 1:
        w, h = max(1, w // 2), max(1, h // 2)
        out.append(out[-1].resize((w, h), Image.LANCZOS))
    return out


def to_bgra(rgb):
    """RGB -> anh 4 kenh xep dung thu tu Warcraft doi: B, G, R, A.

    Dung mode CMYK vi do la mode 4 kenh duy nhat PIL ghi ra JPEG duoc.
    Ten kenh khong quan trong -- cai quan trong la BON BYTE mot diem anh,
    dung thu tu, va JPEG khong biet mau gi ca.

    PHAI DAO GIA TRI. PIL coi JPEG 4 kenh la CMYK va ap quy uoc "Adobe
    dao nguoc" o ca hai chieu doc va ghi. Khong dao truoc thi so ghi ra
    la phan bu, va anh vao game ra am ban.

    Do bang cach thu ca bon kha nang roi giai ma nguoc so voi anh goc:
        BGRA thuong 103.08 | RGBA thuong 101.24
        BGRA dao      4.59 | RGBA dao     16.89   (tren thang 255)
    4.59 la dung muc mat mat cua JPEG q80 -- ba cai kia la sai kenh.
    """
    r, g, b = rgb.split()
    a = Image.new("L", rgb.size, 255)
    inv = ImageChops.invert
    return Image.merge("CMYK", (inv(b), inv(g), inv(r), inv(a)))


# ------------------------------------------------------------- encode

BG = (24, 22, 28)   # nen cho anh co vung trong suot


def flatten(im, bg=BG):
    """Anh co alpha -> dan len mot nen DAC.

    convert("RGB") tran khong lam viec nay: no chi VUT kenh alpha di va
    giu nguyen RGB ben duoi -- ma vung trong suot thi RGB o do thuong la
    rac (den, trang, hoac vien loang). Ket qua la icon vien ban ma khong
    ai hieu tu dau ra.

    Icon trong bang cua map nay deu nam tren o mau dac, khong dung alpha
    vien -- nen dan phang tu day la dung, va con re hon: JPEG 4 kenh voi
    alpha that ton gap doi."""
    if im.mode not in ("RGBA", "LA", "P"):
        return im.convert("RGB")
    im = im.convert("RGBA")
    flat = Image.new("RGB", im.size, bg)
    flat.paste(im, mask=im.getchannel("A"))
    return flat


def square(im):
    """Cat GIUA ve hinh vuong.

    Khung trong game la o vuong, nen anh khong vuong ma resize thang
    sang vuong thi BOP MEO -- tranh 395x290 ep vao 256x256 la nen hinh
    lai 27%, mat nhin ra ngay. Cat giua thi mat ria chu khong meo nguoi.

    Anh nguon cua Trang Bi/hero von da vuong (1254x1254) nen day la
    phep khong lam gi voi chung.
    """
    w, h = im.size
    if w == h:
        return im
    n = min(w, h)
    return im.crop(((w - n) // 2, (h - n) // 2,
                    (w - n) // 2 + n, (h - n) // 2 + n))


def encode(src_path, out_path, size=128, quality=80):
    im = square(flatten(Image.open(src_path)))
    if size:
        im = im.resize((size, size), Image.LANCZOS)
    w, h = im.size

    shared, parts = None, []
    for m in mip_chain(im):
        buf = io.BytesIO()
        to_bgra(m).save(buf, "JPEG", quality=quality, subsampling=0)
        s, rest = split_jpeg(buf.getvalue())
        shared = s                       # giong nhau o moi muc
        parts.append(rest)

    offs, sizes = [0] * 16, [0] * 16
    pos = HDR + 4 + len(shared)
    for k, part in enumerate(parts[:16]):
        offs[k], sizes[k] = pos, len(part)
        pos += len(part)

    out = bytearray()
    out += MAGIC
    out += struct.pack("<6I", 0, 0, w, h, 4, 1)   # comp, alphaBits, w, h, extra, hasMip
    out += struct.pack("<16I", *offs)
    out += struct.pack("<16I", *sizes)
    out += struct.pack("<I", len(shared))
    out += shared
    for part in parts[:16]:
        out += part

    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    open(out_path, "wb").write(bytes(out))
    return len(out), len(parts), (w, h)


# ------------------------------------------------------------- decode

def read_header(path):
    b = open(path, "rb").read()
    if b[:4] != MAGIC:
        raise ValueError(path + ": khong phai BLP1")
    comp, alpha, w, h, extra, mip = struct.unpack_from("<6I", b, 4)
    offs = struct.unpack_from("<16I", b, 28)
    sizes = struct.unpack_from("<16I", b, 92)
    jh = struct.unpack_from("<I", b, HDR)[0]
    return b, comp, alpha, w, h, extra, mip, offs, sizes, b[160:160 + jh]


def decode(path, level=0):
    """Tra ve anh RGB cua mot muc mipmap."""
    b, comp, alpha, w, h, extra, mip, offs, sizes, shared = read_header(path)
    if comp != 0:
        raise ValueError(path + ": chi doc duoc comp=0 (JPEG)")
    stream = shared + b[offs[level]:offs[level] + sizes[level]]
    im = Image.open(io.BytesIO(stream))
    im.load()
    ch = im.split()
    # PIL doc JPEG 4 kenh thanh CMYK va DAO gia tri. Dao lai roi doi
    # B,G,R -> R,G,B. Da kiem: sai lech con 1,8% so anh goc, tuc dung
    # muc mat mat cua JPEG.
    inv = [ImageChops.invert(c) for c in ch]
    return Image.merge("RGB", (inv[2], inv[1], inv[0]))


# --------------------------------------------------------------- lenh

def cmd_info(path):
    b, comp, alpha, w, h, extra, mip, offs, sizes, shared = read_header(path)
    n = sum(1 for s in sizes if s)
    print("%s" % path)
    print("  BLP1 comp=%d alphaBits=%d %dx%d extra=%d hasMip=%d"
          % (comp, alpha, w, h, extra, mip))
    print("  %d muc mipmap, dau JPEG dung chung %d byte, tong %d byte"
          % (n, len(shared), len(b)))
    print("  size tung muc: %s" % [s for s in sizes if s])


def cmd_check(blp, src):
    got = decode(blp)
    # Dan nen GIONG HET luc encode. Khong dan thi anh nguon co alpha se
    # bi so lech o moi vung trong suot -- thuoc sai, khong phai file sai.
    # Cat GIONG HET luc encode. Khong cat thi so anh vuong voi anh goc
    # chu nhat -- lech tum lum, ma la loi cua thuoc chu khong phai file.
    ref = square(flatten(Image.open(src))).resize(got.size, Image.LANCZOS)
    px = list(ImageChops.difference(got, ref).getdata())
    d = sum(sum(t) for t in px) / (len(px) * 3)
    print("  %-46s sai lech %5.2f / 255  (%.1f%%)  %s"
          % (os.path.basename(blp), d, d / 255 * 100,
             "OK" if d < 8 else "NGHI NGO -- kiem lai thu tu kenh"))
    return d


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    cmd = argv[1]
    if cmd == "encode":
        size = 128
        quality = 80
        if "--size" in argv:
            size = int(argv[argv.index("--size") + 1])
        if "--quality" in argv:
            quality = int(argv[argv.index("--quality") + 1])
        n, lv, (w, h) = encode(argv[2], argv[3], size, quality)
        print("  %s -> %s  %dx%d, %d muc, %d byte" % (argv[2], argv[3], w, h, lv, n))
    elif cmd == "decode":
        decode(argv[2]).save(argv[3])
        print("  %s -> %s" % (argv[2], argv[3]))
    elif cmd == "info":
        cmd_info(argv[2])
    elif cmd == "check":
        cmd_check(argv[2], argv[3])
    else:
        print(__doc__)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
