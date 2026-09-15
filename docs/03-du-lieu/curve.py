# -*- coding: utf-8 -*-
REALMS = ["Pham Nhan","Luyen Khi","Truc Co","Kim Dan","Nguyen Anh","Hoa Than",
          "Luyen Hu","Hop The","Dai Thua","Do Kiep","Chan Tien","Thien Tien",
          "Kim Tien","Thai At","Dai La","Tien De","Thanh Nhan","Dao To",
          "Hon Don Than","Sang The Than"]

EHP_BASE, EHP_G, EHP_R = 20.0, 1.018, 1.22
DMG_BASE, DMG_G, DMG_R = 6.0,  1.016, 1.12
ARMOR_PER_REALM = 1.0
ELITE_EHP, BOSS_EHP = 10.0, 80.0
ELITE_DMG, BOSS_DMG = 2.5, 3.0

def T(r):
    if r <= 4:  return 20.0
    if r <= 10: return 28.0
    if r <= 16: return 36.0
    return 45.0

def ehp(s, r): return EHP_BASE * EHP_G**(s-1) * EHP_R**(r-1)
def dmg(s, r): return DMG_BASE * DMG_G**(s-1) * DMG_R**(r-1)
def armor(r):  return ARMOR_PER_REALM * (r-1)

def fmt(v):
    v = round(v)
    return f"{v:,}"

print("| # | Canh gioi | stage | EHP linh T1 | EHP linh T10 | HP that T10 | Giap | Dmg T10 | EHP tinh anh T10 | EHP boss | Dmg boss | DPS doi can (solo) |")
print("|---|---|---|---|---|---|---|---|---|---|---|---|")
tot = 0.0
for i, name in enumerate(REALMS, start=1):
    s1, s10, sb = 11*(i-1)+1, 11*(i-1)+10, 11*i
    a = armor(i)
    e1, e10 = ehp(s1,i), ehp(s10,i)
    hp10 = e10 / (1 + 0.06*a)
    d10 = dmg(s10,i)
    eb, db = BOSS_EHP*ehp(sb,i), BOSS_DMG*dmg(sb,i)
    dps = 60*e10/T(i)
    tot += 12*T(i)
    print(f"| {i} | {name} | {s1}-{sb} | {fmt(e1)} | {fmt(e10)} | {fmt(hp10)} | {a:.0f} | {fmt(d10)} | {fmt(ELITE_EHP*e10)} | {fmt(eb)} | {fmt(db)} | {fmt(dps)} |")

print()
print(f"Tong tang truong EHP  : x{ehp(220,20)/ehp(1,1):,.0f}")
print(f"Tong tang truong DMG  : x{dmg(220,20)/dmg(1,1):,.0f}")
print(f"Moi canh gioi          : x{(EHP_G**11)*EHP_R:.3f} EHP")
print(f"  trong do: tang 1->10 : x{EHP_G**9:.3f}   buoc qua canh gioi: x{(EHP_G**2)*EHP_R:.3f}")
print(f"Tong thoi luong        : {tot/60:.0f} phut ({tot/3600:.2f} gio)")
print(f"  goi som cat 25%      : {tot*0.75/60:.0f} phut")
print()
d1 = 60*ehp(1,1)/T(1); d220 = 60*ehp(220,20)/T(20)
print(f"DPS doi can  stage 1   : {d1:,.0f}   (solo)")
print(f"DPS doi can  stage 220 : {d220:,.0f}   (solo)  -> hop dong x{d220/d1:,.0f}")
for P in (1,2,3):
    m = 1 + 0.60*(P-1)
    print(f"  P={P}: tong {d220*m:,.0f} DPS  -> moi hero {d220*m/P:,.0f}")
print()
print("Nhip so lan wave (EHP linh, moi 11 stage mot canh gioi):")
for s in (1,11,22,55,110,165,220):
    r = (s-1)//11 + 1
    print(f"  stage {s:3d} (canh gioi {r:2d}): EHP {ehp(s,r):>10,.0f}   dmg {dmg(s,r):>8,.0f}")
