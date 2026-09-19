-- ============================================================
--  15_heroname.lua  --  Hai dong chu tren bang hero
--
--  Warcraft ve bang hero bang DUNG hai dong, va ta chi doi duoc noi
--  dung, khong doi duoc bo cuc:
--
--      dong 1   ten rieng cua hero        (proper name)
--      dong 2   "Level <N> <ten unit>"    N va ten unit deu doi duoc
--
--  TRUOC FILE NAY CA HAI DONG DEU GHI "Mage" -- va dong hai ghi
--  "Level 1 Mage" VINH VIEN, vi hero trong map nay khong bao gio len
--  cap (CFG.LOCK_HERO_XP). Tuc dong quan trong thu hai cua bang noi
--  dung mot thu: mot he thong khong ton tai.
--
--  Gio:
--      dong 1   ten nhan vat              (CFG.HEROES[i].title)
--      dong 2   "Level 7 Hoa Than"        cap = bac Tu Vi, ten = canh gioi
--
--  VI SAO DAT CA CAP HERO chu khong chi doi ten unit: de nguyen cap 1
--  thi dong hai thanh "Level 1 Hoa Than" -- mot con so 1 dung canh chu
--  "bac 7", te hon ca truoc. Dat cap bang bac Tu Vi thi chu "Level"
--  thoi noi doi, va ca dong doc duoc ma khong con mot ky tu thua.
--
--  BA DIEU PHAI NHO:
--
--  1. LEN CAP THI WARCRAFT PHAT DIEM KY NANG. Map nay khong dung diem
--     do (ky nang mua bang Go), nen phai rut ngay -- neu khong nguoi
--     choi thay nut "+" nhap nhay va bam vao hoc nham ability goc.
--
--  2. KHONG HA CAP DUOC. SetHeroLevel cua Warcraft chi di len. Lenh
--     dev "-lc 3" sau khi da o bac 20 se khong ha cap xuong duoc, nen
--     dong hai giu so cu. Ghi vet chu khong im lang.
--
--  3. CAP KHONG CONG CHI SO GI. heroRecompute() ghi chi so bang so
--     TUYET DOI, nen phan Warcraft cong khi len cap bi ghi de ngay lan
--     tinh sau. Do la ly do dat cap o day an toan.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Ten nhan vat cua mot hero, tra tu CFG.HEROES theo unit type.
local function titleOf(uid)
  for i = 1, #(CFG.HEROES or {}) do
    if CFG.HEROES[i].id == uid then
      local h = CFG.HEROES[i]
      return h.title or h.name
    end
  end
  return nil
end

-- Goi sau khi pick hero, VA sau moi lan doi bac Tu Vi.
local function refresh(pid)
  if not CFG.HERO_NAME_SHOW_RANK then return end
  local d = S.p[pid]
  if d == nil or d.hero == nil or not API.alive(d.hero) then return end

  local h    = d.hero
  local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1

  -- Dong 2: ten unit = ten canh gioi.
  if BlzSetUnitName ~= nil and API.realmName ~= nil then
    BlzSetUnitName(h, API.realmName(rank))
  end

  -- Dong 1: ten nhan vat. Dat mot lan la du -- no khong doi theo bac --
  -- nhung dat lai moi lan cung khong ton gi, va no tu sua neu co he
  -- nao do lo ghi de.
  if BlzSetHeroProperName ~= nil then
    local t = titleOf(GetUnitTypeId(h))
    if t ~= nil then BlzSetHeroProperName(h, t) end
  end

  -- Cap = bac Tu Vi.
  if SetHeroLevel ~= nil and GetHeroLevel ~= nil then
    local cur = GetHeroLevel(h)
    if cur < rank then
      -- false = khong choi hoat anh len cap. Dot pha DA co hieu ung
      -- rieng (ResurrectTarget o 3_cultivation.lua); chong them mot
      -- cot sang vang nua la hai hieu ung danh nhau.
      SetHeroLevel(h, rank, false)
      -- Rut diem ky nang Warcraft vua phat. Khong rut thi nut "+" nhap
      -- nhay va nguoi choi bam vao hoc nham ability goc.
      if API.lockHero ~= nil then API.lockHero(h) end
    elseif cur > rank then
      -- SetHeroLevel KHONG ha cap duoc. Chi xay ra voi lenh dev "-lc".
      API.trace("heroname: pid " .. pid .. " cap " .. cur ..
                " > bac " .. rank .. " -- Warcraft khong ha cap duoc")
    end
  end
end

local function startHeroName()
  if not CFG.HERO_NAME_SHOW_RANK then
    API.trace("heroname: TAT (CFG.HERO_NAME_SHOW_RANK = false)")
    return
  end
  if BlzSetHeroProperName == nil then
    API.trace("heroname: KHONG co BlzSetHeroProperName -- dong 1 giu ten " ..
              "cua Object Editor")
  end
  API.trace("heroname: dong 1 = ten nhan vat, dong 2 = cap + canh gioi")
end

API.heroNameRefresh = refresh
API.startHeroName   = startHeroName
