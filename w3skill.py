#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
w3skill.py -- sinh TEN, TOOLTIP va VI TRI O cho ky nang hero.

    python w3skill.py show               # in ra se ghi gi, khong ghi
    python w3skill.py gen                # ghi vao war3map.wts + war3map.w3a
    python w3skill.py gen --lang vi      # ghi ban tieng Viet

VAN DE NO GIAI. Doc duoc tu war3map.w3a: 6 trong 7 ability cua Hart KHONG co
ten, tooltip hay vi tri o rieng -- chung hien nguyen ten Blizzard. Re chuot
vao "Chuong" thi game noi "Shockwave", va mo ta la mo ta Shockwave.

NGUON SU THAT LA CFG.SKILLS. Ten va con so trong tooltip deu suy ra tu bang
do, nen tooltip KHONG THE noi khac voi bang phim E -- ca hai ra tu mot cho.
Doi mot he so trong CFG roi chay lai file nay la tooltip tu khop.

CHUOI NAM O DAU. World Editor khong nhet chu thang vao war3map.w3a; no ghi
vao war3map.wts roi de lai mot tham chieu "TRIGSTR_nnn". File nay lam y het
-- do duoc tu chinh A006, object duy nhat da co vo day du.

CHAY LAI NHIEU LAN VAN RA MOT KET QUA. Chuoi sinh ra chiem tu id GEN_BASE
tro len; moi lan chay ghi de dung khoi do, khong dung toi chuoi cua World
Editor ben duoi.

CANH BAO. Dong World Editor truoc khi chay -- no giu ban map trong bo nho,
Save sau do la ghi de mat. Cung cai bay ma build.py canh bao.
"""

import argparse
import io
import os
import re
import shutil
import sys

import w3obj

ROOT    = os.path.dirname(os.path.abspath(__file__))
BAK_DIR = os.path.join(ROOT, "build")
CFG_LUA = os.path.join(ROOT, "src", "1_core", "1_config.lua")
LANG_LUA = os.path.join(ROOT, "src", "1_core", "6_i18n.lua")

# Chuoi do file nay sinh bat dau tu day. World Editor danh so tu 1 len, nen
# de mot khoang cach lon thi hai ben khong bao gio giam len nhau.
GEN_BASE = 1000

# Bay o trong cua command card (luoi 4x3).
#
# DA DO, khong phai tri nho: anh chup trong game 2026-09-16 cho thay lenh
# co ban chiem tron hang y=0 (Move / Hold / Attack / Stop) va o (0,1)
# (Patrol). Bay o con lai vua dung bay ky nang.
#
# Do lai bat cu luc nao bang "-nat card" trong game: no doc
# ABILITY_IF_BUTTON_POSITION_NORMAL_X/Y cua ca lenh co ban lan bay ky nang
# tren chinh con hero dang cam, roi bao o nao passive hai ability cung nhan.
# DA DO (anh chup trong game, 2026-09-16): lenh co ban chiem tron hang
# y=0 (Move / Hold / Attack / Stop) va o (0,1) (Patrol). Bay o con lai la
# (1,1) (2,1) (3,1) va tron hang y=2.
#
# Hang y=2 la hang DUY NHAT du bon o lien nhau, nen ba ky nang chu dong
# Q W E nam o day, roi mot passive dong lap cho thu tu. Ba passive dong con lai len
# hang y=1 -- xep sao cung duoc, chung khong co phim tat.
O_ACTIVE = [(0, 2), (1, 2), (2, 2)]
O_PASSIVE = [(3, 2), (1, 1), (2, 1), (3, 1)]


def die(msg):
    print("[loi] " + msg)
    sys.exit(1)


# ---------- doc CFG ----------

def read(path):
    return io.open(path, encoding="utf-8").read()


def cfg_num(src, key, default=None):
    m = re.search(r"^CFG\.%s\s*=\s*([0-9.]+)" % key, src, re.M)
    if m:
        return float(m.group(1))
    if default is None:
        die("khong thay CFG.%s" % key)
    return default


def cfg_str(src, key, default=None):
    m = re.search(r'^CFG\.%s\s*=\s*"([^"]*)"' % key, src, re.M)
    return m.group(1) if m else default


def parse_skills(src, hero):
    """CFG.SKILLS[id('H001')] -> danh sach dict, giu nguyen thu tu."""
    anchor = "CFG.SKILLS[id('%s')] = {" % hero
    if anchor not in src:
        die("khong thay %s -- hero nay chua khai bao ky nang" % anchor)
    blk = src.split(anchor, 1)[1]
    # Khoi ket thuc o dong "}" dau tien nam sat le trai.
    blk = re.split(r"\n\}", blk, 1)[0]

    out = []
    # Moi muc bat dau bang "{ id = id('Annn')" va keo toi dau "}," ke tiep.
    for chunk in re.findall(r"\{\s*id = id\('(\w+)'\)(.*?)\},", blk, re.S):
        aid, body = chunk
        d = {"id": aid}
        for k in ("vi", "en", "kind", "desc_vi", "desc_en", "fx", "hotkey"):
            m = re.search(r'\b%s\s*=\s*"((?:[^"\\]|\\.)*)"' % k, body)
            if m:
                d[k] = m.group(1)
        for k in ("factor", "pct", "armorVal", "statVal", "cd", "mana"):
            m = re.search(r"\b%s\s*=\s*([0-9.]+)" % k, body)
            if m:
                d[k] = float(m.group(1))
        out.append(d)
    if not out:
        die("doc duoc 0 ky nang tu %s" % anchor)
    return out


def parse_lang(src, lang):
    blk = src.split("T.%s = {" % lang, 1)[1].split("\n}", 1)[0]
    return dict(re.findall(r"(\w+)\s*=\s*\"([^\"]*)\"", blk))


# ---------- so lieu tung bac, khop 4_skill.lua ----------

class Curve(object):
    def __init__(self, src):
        self.dmg     = cfg_num(src, "SKILL_DMG_STEP")
        self.cd      = cfg_num(src, "SKILL_CD_STEP")
        self.passive = cfg_num(src, "SKILL_PASSIVE_STEP")
        self.mana    = cfg_num(src, "SKILL_MANA_STEP")
        self.maxlv   = int(cfg_num(src, "SKILL_MAX_LEVEL"))

    def factor(self, sk, lv): return sk.get("factor", 0.0) * self.dmg ** (lv - 1)
    def pct(self, sk, lv):  return sk.get("pct", 0.0) * self.passive ** (lv - 1)
    def cdAt(self, sk, lv): return sk.get("cd", 0.0) * self.cd ** (lv - 1)
    def armorAt(self, sk, lv): return sk.get("armorVal", 0.0) * self.passive ** (lv - 1)
    def manaAt(self, sk, lv):
        m = sk.get("mana", 0.0)
        return int(m * self.mana ** (lv - 1) + 0.5) if m else 0

    def fmt(self, sk, lv):
        if sk.get("statVal"):
            return "+%d" % round(self.statVal(sk, lv))
        if sk.get("armorVal"):
            return "+%.0f" % self.giapAt(sk, lv)
        if sk.get("kind") in ("aura", "passive"):
            return "%.0f%%" % (self.pct(sk, lv) * 100)
        return "x%.2f" % self.factor(sk, lv)

    def statVal(self, sk, lv):
        # Chi phan theo BAC KY NANG. Phan nhan theo bac Tu Vi khong dua
        # vao duoc: tooltip la chuoi TINH, sinh mot lan luc dong goi, con
        # bac Tu Vi thi doi luc chay. Bang phim ESC hien so THAT.
        return sk["statVal"] * self.passive ** (lv - 1)


def name_of(sk, lang):
    return (sk.get("en") or sk.get("vi")) if lang == "en" else \
           (sk.get("vi") or sk.get("en"))


def desc_of(sk, lang):
    return (sk.get("desc_en") or sk.get("desc_vi")) if lang == "en" else \
           (sk.get("desc_vi") or sk.get("desc_en"))


def short_name(name, hotkey):
    """Dong chu tren nut. Warcraft KHONG tu them hotkey tat vao day -- muon
    nguoi choi thay "Palm Strike [Q]" thi phai tu ghi chu [Q] vao."""
    if not hotkey:
        return name
    return "%s [|cffffcc00%s|r]" % (name, hotkey)


def tooltip(sk, lv, cur, lang, T):
    """Tooltip mo rong cua MOT bac."""
    lines = []
    desc = desc_of(sk, lang) or ""
    if "%s" in desc:
        desc = desc.replace("%s", cur.fmt(sk, lv))
    desc = desc.replace("%%", "%")
    lines.append(desc)
    lines.append("")

    rank = ("Level %d/%d" if lang == "en" else "Bac %d/%d") % (lv, cur.maxlv)
    lines.append(rank)

    if sk.get("factor"):
        # Ghi ro an theo chi so nao -- nguoi choi khong co cach nao biet
        # neu khong noi. Hien tai code lay chi so CAO NHAT cua hero.
        s = ("Scales with your highest attribute."
             if lang == "en" else "An theo chi so cao nhat cua hero.")
        lines.append(s)

    dung = []
    if sk.get("cd"):
        dung.append("%s %.1fs" % (T.get("panel_cd", "cd"), cur.cdAt(sk, lv)))
    if sk.get("mana"):
        dung.append("%s %d" % (T.get("panel_mana", "mana"), cur.manaAt(sk, lv)))
    if dung:
        lines.append("   ".join(dung))

    return "\n".join(lines).strip()


# ---------- war3map.wts ----------

WTS_RE = re.compile(r"STRING\s+(\d+)\s*\n(?://[^\n]*\n)?\{\n(.*?)\n\}", re.S)


def wts_read(path):
    raw = io.open(path, encoding="utf-8-sig").read()
    have = {}
    for m in WTS_RE.finditer(raw):
        have[int(m.group(1))] = m.group(2)
    return raw, have


def wts_write(path, raw, new):
    """Bo moi chuoi tu GEN_BASE tro len roi ghi lai -- nho vay chay lai
    nhieu lan khong phinh file."""
    def drop(m):
        return "" if int(m.group(1)) >= GEN_BASE else m.group(0)

    body = WTS_RE.sub(drop, raw).rstrip() + "\n"
    parts = [body]
    for sid in sorted(new):
        parts.append("\nSTRING %d\n// [w3skill.py]\n{\n%s\n}\n" % (sid, new[sid]))
    out = "".join(parts)

    os.makedirs(BAK_DIR, exist_ok=True)
    shutil.copyfile(path, os.path.join(BAK_DIR, "war3map.wts.orig"))
    io.open(path, "w", encoding="utf-8-sig", newline="\r\n").write(out)
    return len(out)


# ---------- lenh ----------

def build_plan(lang):
    cfg  = read(CFG_LUA)
    cur  = Curve(cfg)
    T    = parse_lang(read(LANG_LUA), lang)
    sks  = parse_skills(cfg, "H001")

    active = [s for s in sks if s.get("kind") == "active"]
    passive = [s for s in sks if s.get("kind") != "active"]
    if len(active) > len(O_ACTIVE) or len(passive) > len(O_PASSIVE):
        die("Hart co %d chu dong / %d bi dong -- command card chi co %d/%d o"
            % (len(active), len(passive), len(O_ACTIVE), len(O_PASSIVE)))

    o = {}
    for i, s in enumerate(active):
        o[s["id"]] = O_ACTIVE[i]
    for i, s in enumerate(passive):
        o[s["id"]] = O_PASSIVE[i]

    plan, strings, sid = [], {}, GEN_BASE
    for s in sks:
        name = name_of(s, lang)
        strings[sid] = name
        item = {"id": s["id"], "vi": name, "o": o[s["id"]],
                "hotkey": s.get("hotkey"), "anam": sid, "tips": [], "tens": []}
        sid += 1
        for lv in range(1, cur.maxlv + 1):
            strings[sid] = tooltip(s, lv, cur, lang, T)
            item["tips"].append((lv, sid))
            sid += 1
            # Tooltip NGAN (atp1) la dong chu hien khi re chuot len nut.
            # Truoc day khong ai ghi no, nen no thua ke tu ability goc:
            # re vao "Chuong" thi game noi "Shockwave". Va day cung la
            # cho DUY NHAT in duoc phim tat ra man hinh.
            strings[sid] = short_name(name, s.get("hotkey"))
            item["tens"].append((lv, sid))
            sid += 1
        plan.append(item)
    return plan, strings, cur


def cmd_show(lang):
    plan, strings, cur = build_plan(lang)
    print("tieng: %s   |   %d ability, %d chuoi (id %d..%d)\n"
          % (lang, len(plan), len(strings), GEN_BASE, GEN_BASE + len(strings) - 1))
    for it in plan:
        print("  %s  %-14s  o (%d,%d)" % (it["id"], it["vi"], it["o"][0], it["o"][1]))
    print("\n--- tooltip mau: %s bac 1 va bac %d ---" % (plan[0]["vi"], cur.maxlv))
    for lv, sid in (plan[0]["tips"][0], plan[0]["tips"][-1]):
        print("\n[bac %d]\n%s" % (lv, strings[sid]))


def cmd_gen(map_dir, lang):
    plan, strings, cur = build_plan(lang)
    w3a = os.path.join(map_dir, "war3map.w3a")
    wts = os.path.join(map_dir, "war3map.wts")
    for p in (w3a, wts):
        if not os.path.isfile(p):
            die("khong thay " + p)

    (version, orig, custom), _ = w3obj.read_file(w3a)
    by = {(o.newid or o.base): o for o in custom}

    for it in plan:
        ob = by.get(it["id"])
        if ob is None:
            die("war3map.w3a khong co ability %s -- tao trong Object Editor truoc"
                % it["id"])
        w3obj.set_field(ob, "anam", "TRIGSTR_%03d" % it["anam"])
        w3obj.set_field(ob, "abpx", it["o"][0])
        w3obj.set_field(ob, "abpy", it["o"][1])
        if it["hotkey"]:
            w3obj.set_field(ob, "ahky", it["hotkey"])
        for lv, sid in it["tips"]:
            w3obj.set_field(ob, "aub1", "TRIGSTR_%03d" % sid, level=lv)
        for lv, sid in it["tens"]:
            w3obj.set_field(ob, "atp1", "TRIGSTR_%03d" % sid, level=lv)
        print("  %s  ten + %d tooltip + o (%d,%d)%s"
              % (it["id"], len(it["tips"]), it["o"][0], it["o"][1],
                 ("  hotkey " + it["hotkey"]) if it["hotkey"] else ""))

    raw, _ = wts_read(wts)
    n = wts_write(wts, raw, strings)
    print("[ok] war3map.wts -- %d chuoi moi, %d byte" % (len(strings), n))

    if not w3obj.write_back(w3a, version, orig, custom):
        die("ghi war3map.w3a that bai")
    print("[ok] xong. Ban cu o build/war3map.w3a.orig va build/war3map.wts.orig")


def find_map(explicit):
    if explicit:
        p = explicit if os.path.isabs(explicit) else os.path.join(ROOT, explicit)
    else:
        f = [os.path.join(ROOT, n) for n in sorted(os.listdir(ROOT))
             if n.lower().endswith((".w3x", ".w3m"))
             and os.path.isdir(os.path.join(ROOT, n))]
        if len(f) != 1:
            die("khong xac dinh duoc map -- dung --map")
        p = f[0]
    if not os.path.isdir(p):
        die("khong thay thu muc map: " + p)
    return p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("lenh", choices=["show", "gen"])
    ap.add_argument("--map")
    ap.add_argument("--lang", choices=["en", "vi"])
    a = ap.parse_args()

    lang = a.lang or cfg_str(read(CFG_LUA), "LANG", "en")
    if a.lenh == "show":
        cmd_show(lang)
    else:
        cmd_gen(find_map(a.map), lang)
    return 0


if __name__ == "__main__":
    sys.exit(main())
