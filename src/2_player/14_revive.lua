-- ============================================================
--  14_revive.lua  --  Hero chet roi song lai
--
--  VI SAO PHAI CO. Truoc file nay onAnyDeath() chi xu ly NHA CHINH va
--  QUAI -- khong mot dong nao cho hero. Quet ca cay nguon: duong song
--  lai duy nhat la Ankh 500 vang, hoac bi dong Hoi Sinh cua A006.
--
--  Nghia la chet o wave 30 ma khong co Ankh thi ngoi xem 70 wave con
--  lai. Trong map co-op ba nguoi, do la cho mot nguoi nghi choi giua
--  chung ma van phai ngoi do.
--
--  Te hon: measureParty() BO QUA hero chet, nen boss nho lai theo --
--  doi hai nguoi thang de hon doi ba nguoi co mot xac. Nghich ly, va
--  no am tham.
--
--  SONG LAI O NHA CHINH, KHONG PHAI CHO VUA CHET. Cho vua chet la cho
--  vua thua: song lai ngay giua bay quai la chet lan hai trong ba
--  giay. Ve nha thi doan duong quay lai chinh la phan gia phai tra.
--
--  KHONG CAN DONG BO. Su kien chet cua Warcraft ban tren MOI may voi
--  cung mot unit, nen moi may tu chay cung mot nhanh va ra cung ket
--  qua. Khac han callback frame (ADR 0012) -- cai do chi ban tren may
--  bam.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Tra ve pid neu unit nay la hero CUA MOT NGUOI CHOI, khong thi nil.
--
-- Kiem 'd.hero == u' chu khong chi kiem chu so huu: pet cung thuoc ve
-- nguoi choi o vai ban truoc, va thap canh thi luon thuoc ve ho.
local function heroPidOf(u)
  if u == nil then return nil end
  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d = S.p[pid]
    if d ~= nil and d.hero == u then return pid end
  end
  return nil
end

-- Cho song lai: quanh NHA CHINH, toa ra theo slot de ba nguoi khong
-- chong len nhau. Thieu nha thi lui ve dung cho cu.
local function revivePoint(pid, u)
  if S.house ~= nil and API.alive(S.house) and API.heroFanPoint ~= nil then
    return API.heroFanPoint(pid, GetUnitX(S.house), GetUnitY(S.house),
                            CFG.HERO_SPAWN_OFFSET or 500.0)
  end
  return GetUnitX(u), GetUnitY(u)
end

local function revive(pid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  d.reviving = nil

  local u = d.hero
  if API.alive(u) then return end          -- Ankh hay A006 da lo truoc

  local x, y = revivePoint(pid, u)
  if ReviveHero == nil then
    API.warn(pid, "Khong co ReviveHero -- hero khong song lai duoc.")
    return
  end
  ReviveHero(u, x, y, true)

  -- Day mau/mana ve day. ReviveHero cua Warcraft tra hero ve mot phan
  -- mau, ma song lai voi mot vach mau giua bay quai la chet lan hai.
  SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
  SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA))

  -- Canh bam vao unit. Unit khong bi xoa nen effect con nguyen, nhung
  -- goi lai cho chac: check() ton trong d.wingPick va khong deo lai
  -- neu dang dung bo.
  if API.wingCheck ~= nil then API.wingCheck(pid) end
  -- Chi so thi khong doi -- cung mot unit -- nhung mot lan tinh lai
  -- khong ton gi va no don sach moi thu co the da truot.
  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  if API.panelRefresh ~= nil then API.panelRefresh(pid) end

  API.say(pid, API.t("hero_revived"))
  API.trace("revive: pid " .. pid .. " song lai o " ..
            math.floor(x) .. "," .. math.floor(y))
end

-- Goi tu onAnyDeath() trong 5_boot/1_events.lua.
--
-- Tra ve true neu da nhan xu ly, de ben goi khong day tiep sang
-- onMobDeath -- hero khong phai quai, va onMobDeath cong tien thuong.
local function onHeroDeath(u)
  local pid = heroPidOf(u)
  if pid == nil then return false end

  local d = S.p[pid]
  local secs = CFG.HERO_REVIVE_SECONDS or 30.0
  if secs <= 0.0 then return true end      -- 0 = tat han he nay

  -- Mot cho hen duy nhat. Khong co co nay thi mot hero chet -> Ankh
  -- cuu -> chet lai se xep HAI cai hen, va cai thu nhat se "song lai"
  -- mot hero dang song.
  if d ~= nil then d.reviving = true end

  -- BAO CHO CA BAN DO. Bao rieng nguoi vua chet la vo nghia -- ho dang
  -- nhin man hinh xam. Gia tri nam o cho hai nguoi kia biet doi vua
  -- mat mot phan ba hoa luc trong 30 giay.
  API.say(pid, API.t("hero_died", math.floor(secs)))
  API.trace("revive: pid " .. pid .. " chet -- hen " .. secs .. "s")

  API.after(secs, function() revive(pid) end)
  return true
end

local function startRevive()
  if CFG.HERO_REVIVE_SECONDS == nil or CFG.HERO_REVIVE_SECONDS <= 0.0 then
    API.trace("revive: TAT (CFG.HERO_REVIVE_SECONDS = 0)")
    return
  end
  if ReviveHero == nil then
    API.warn(nil, "Khong co ReviveHero -- hero chet se nam luon.")
    return
  end
  API.trace("revive: hero song lai sau " .. CFG.HERO_REVIVE_SECONDS ..
            "s, o quanh nha chinh")
end

API.onHeroDeath  = onHeroDeath
API.startRevive  = startRevive
