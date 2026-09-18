-- ============================================================
--  5_gear.lua  --  Sau mon, moi mon tien hoa 100 bac
--
--  Moi mon di 20 canh gioi x 5 cap. TRAN la TU VI cua nguoi choi.
--  Luat day du: docs/02-he-thong/trang-bi-kiem.md  ·  ADR 0021
--
--    (0,0)  "Kiem"                      <- tho, chua luyen
--      LUYEN  1 da, 100%
--    (1,1)  "Kiem Pham Nhan - So Cap"
--      LUYEN  1 da, 75% / 50% / 25% / 15%
--    (1,5)  "Kiem Pham Nhan - Hoan Hao"
--      TIEN GIAI  10 da, 100%, doi Tu Vi >= canh gioi 2
--    (2,1)  "Kiem Luyen Khi - So Cap"
--      ...
--
--  BAY MON, MOI MON MOT VAI -- 2026-09-18:
--    Mu    Int           Day Chuyen  ca ba      Ao   Str
--    Giay  Agi           Kiem  %sat thuong gay ra (ke ca hoi mau)
--    Khien %giam don danh nhan vao   Nhan  %giam phep nhan vao
--  Bon mon cong diem thi LEO theo Tu Vi, ba mon nhan % thi PHANG.
--  Xem muc "CHI SO" ben duoi va CFG.GEAR_STAT_BASE.
--
--  NGAU NHIEN PHAI NAM TRONG HAM NHAN TU KENH DONG BO. Bam frame chi no
--  tren may nguoi bam; goi GetRandomInt o do la moi may tieu mot so khac
--  nhau tu chuoi ngau nhien, va TU GIAY DO moi so ngau nhien cua ca van
--  deu lech -- ke ca the Co Duyen. Xem dau 10_fortune.lua.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function itemCount() return #CFG.GEAR end
local function levelMax()   return #CFG.GEAR_CAP end
local function tierMax()  return #CFG.REALMS end

-- Trang thai mot mon: { canh = 0..20, cap = 0..5 }.
-- canh = 0 nghia la chua luyen lan nao.
local function stOf(pid, i)
  local d = S.p[pid]
  if d == nil then return nil end
  if d.gear == nil then d.gear = {} end
  if d.gear[i] == nil then d.gear[i] = { tier = 0, level = 0 } end
  return d.gear[i]
end

-- ---------- Ten ----------

local function levelNameOf(c)
  local t = CFG.GEAR_CAP[c]
  return (t ~= nil) and API.pick(t) or tostring(c)
end

local function tierNameOf(r)
  local t = CFG.REALMS[r]
  return (t ~= nil) and API.pick(t) or tostring(r)
end

-- "Kiem"  hoac  "Kiem Pham Nhan - So Cap"
local function fullName(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return "?" end
  local base = API.pick(item)
  local st = stOf(pid, i)
  if st == nil or st.tier <= 0 then return base end
  return base .. " " .. tierNameOf(st.tier) .. " - " .. levelNameOf(st.level)
end

-- ---------- Hoi trang thai ----------

-- Luyen duoc khong: chua toi Hoan Hao la duoc.
local function canRefine(pid, i)
  local st = stOf(pid, i)
  return (st ~= nil) and (st.level < levelMax())
end

-- Tien Giai duoc khong. BA dieu kien, va dieu kien thu ba la cho cai
-- tran Tu Vi thuc su co hieu luc.
local function canEvolve(pid, i)
  local st = stOf(pid, i)
  if st == nil then return false end
  if st.level < levelMax() then return false end          -- chua Hoan Hao
  if st.tier >= tierMax() then return false end       -- da het canh gioi
  local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
  return rank >= st.tier + 1                            -- Tu Vi da toi chua
end

-- Xac suat cua lan luyen KE TIEP, dang 0..1.
local function nextOdds(pid, i)
  local st = stOf(pid, i)
  if st == nil then return 0.0 end
  return CFG.GEAR_ODDS[st.level + 1] or 0.0
end

-- ---------- Luyen ----------
-- Chay tren MOI may, tu kenh dong bo.

local function refine(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return end
  if not canRefine(pid, i) then return end

  if not API.spendIron(pid, CFG.GEAR_PRICE) then
    API.msg(pid, CFG.C_RED .. API.t("no_iron") .. CFG.C_END ..
      API.t("need_have", API.num(CFG.GEAR_PRICE), API.num(API.getIron(pid))))
    API.panelRefresh(pid)
    return
  end

  local st = stOf(pid, i)
  local pct = math.floor(nextOdds(pid, i) * 100.0 + 0.5)

  -- GetRandomInt o DAY moi dung: ham nay chay tren moi may, cung thu tu.
  if GetRandomInt(1, 100) <= pct then
    st.level = st.level + 1
    if st.tier <= 0 then st.tier = 1 end   -- lan dau: vao canh gioi 1

    local name = CFG.C_JADE .. fullName(pid, i) .. CFG.C_END
    local ai  = CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END
    -- Bao cho CA DOI khi cham hai cap cuoi: ba nguoi cung leo mot thang
    -- thi viec so nhau chinh la noi dung. Cap thap thi bao rieng, neu
    -- khong ca van se co 300 dong khoe cap So Cap.
    API.msg((st.level >= levelMax() - 1) and nil or pid,
            API.t("gear_became", ai, name))

    if S.p[pid] ~= nil and S.p[pid].hero ~= nil then
      API.fx([[Abilities\Spells\Items\AIem\AIemTarget.mdl]],
             GetUnitX(S.p[pid].hero), GetUnitY(S.p[pid].hero))
    end
  else
    API.msg(pid, CFG.C_RED .. API.t("gear_failed", pct) .. CFG.C_END)
  end

  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.panelRefresh(pid)
end

-- ---------- Tien Giai ----------
-- Chay tren MOI may. KHONG co xac suat: no la mot CUA, khong phai canh
-- bac chong len canh bac. Va no bao gom luon lan len "So Cap" cua canh
-- gioi moi (von 100%), de khong co mot cu bam chac chan thua.

local function dismantle(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return end
  if not canEvolve(pid, i) then return end

  if not API.spendIron(pid, CFG.GEAR_DISMANTLE) then
    API.msg(pid, CFG.C_RED .. API.t("no_iron") .. CFG.C_END ..
      API.t("need_have", API.num(CFG.GEAR_DISMANTLE), API.num(API.getIron(pid))))
    API.panelRefresh(pid)
    return
  end

  local st = stOf(pid, i)
  st.tier = st.tier + 1
  st.level  = 1

  API.msg(nil, API.t("gear_dismantled",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. fullName(pid, i) .. CFG.C_END))

  if S.p[pid] ~= nil and S.p[pid].hero ~= nil then
    API.fx([[Abilities\Spells\Human\Resurrect\ResurrectTarget.mdl]],
           GetUnitX(S.p[pid].hero), GetUnitY(S.p[pid].hero))
  end

  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.panelRefresh(pid)
end

-- ---------- CHI SO ----------
--
-- HAI LOAI VAI, va chung khac nhau ve BAN CHAT chu khong chi ve con so:
--
--   cong diem  (str/agi/int/all)      -- KHONG tu leo, phai nhan
--                                        CULT_STAT_STEP^(canh gioi-1)
--   nhan %     (dmgpct/mitig_phys/
--               mitig_magic)             -- TU leo san, nen phai de PHANG
--
-- Cho ca hai cung mot duong cong la hai mon nhan chay mat -- xem chu
-- thich CFG.GEAR_STAT_BASE. Day la ADR 0010 lap lai o tang nguoi choi.

-- Tong so bac da di cua mot mon: 0 .. tierMax x levelMax.
local function stepsOf(pid, i)
  local st = stOf(pid, i)
  if st == nil or st.tier <= 0 then return 0 end
  return (st.tier - 1) * levelMax() + st.level
end

local function stepsMax()
  return tierMax() * levelMax()
end

-- Diem chi so CONG DON cua mot mon "cong diem".
--
--   value(T,L) = BASE x [ N x (STEP^(T-1) - 1)/(STEP-1) + L x STEP^(T-1) ]
--                         \_ N canh gioi truoc, tron _/   \_ canh gioi nay _/
--
-- Dung CHINH CULT_STAT_STEP chu khong go 1.30: doi duong cong Tu Vi thi
-- trang bi tu di theo, giong cach the "stat" cua Co Duyen lam.
local function addPoints(pid, i)
  local st = stOf(pid, i)
  if st == nil or st.tier <= 0 then return 0.0 end
  local s, n, T = CFG.CULT_STAT_STEP, levelMax(), st.tier
  local prev
  if s == 1.0 then prev = n * (T - 1)
  else               prev = n * (s ^ (T - 1) - 1) / (s - 1) end
  return CFG.GEAR_STAT_BASE * (prev + st.level * s ^ (T - 1))
end

-- Phan tram cua mot mon "nhan": TUYEN TINH theo so bac, khong leo.
local function pctOf(pid, i, maxPct)
  local m = stepsMax()
  if m <= 0 then return 0.0 end
  return (maxPct or 0.0) * stepsOf(pid, i) / m
end

-- Tong chi so tu CA SAU mon. Tra ve BA so, dung thu tu str/agi/int --
-- 7_effect cong thang vao mot cong thuc duy nhat, khong doc-cong-ghi.
local function statOf(pid)
  local str, agi, int = 0.0, 0.0, 0.0
  for i = 1, itemCount() do
    local role = CFG.GEAR[i].role
    if role == "str" or role == "agi" or role == "int" or role == "all" then
      local v = addPoints(pid, i)
      if     role == "str" then str = str + v
      elseif role == "agi" then agi = agi + v
      elseif role == "int" then int = int + v
      else
        -- Nhan: chia deu ba phan. Tong bang dung mot mon don chi so --
        -- doi lai chia ba thi sat thuong ky nang chi an mot phan ba, vi
        -- no tra theo chi so CAO NHAT chu khong theo tong.
        local third = v / 3.0
        str, agi, int = str + third, agi + third, int + third
      end
    end
  end
  return str, agi, int
end

-- % sat thuong GAY RA. An vao don thuong, sat thuong phep va hoi mau.
local function dmgPctOf(pid)
  local out = 0.0
  for i = 1, itemCount() do
    if CFG.GEAR[i].role == "dmgpct" then
      out = out + pctOf(pid, i, CFG.GEAR_DMG_MAX)
    end
  end
  return out
end

-- % sat thuong NHAN VAO duoc giam, theo LOAI don:
--   Khien ("mitig_phys")  cham don danh
--   Nhan  ("mitig_magic") cham phep
--
-- Nguoi goi noi ro dang hoi loai nao. Khong doan tu dau goi: onDamaged
-- co BlzGetEventDamageType de hoi that.
local function mitigPctOf(pid, role)
  local out = 0.0
  for i = 1, itemCount() do
    if CFG.GEAR[i].role == role then
      out = out + pctOf(pid, i, CFG.GEAR_MITIG_MAX)
    end
  end
  return out
end

-- Chu mo ta phan mon nay DANG cong, de len the trong bang. Khong co no
-- thi nguoi choi bo da ma khong thay minh mua duoc gi.
local function bonusLabel(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return "" end
  local role = item.role
  -- API.num lam TRON XUONG, ma o bac dau % con duoi 1 -- no se hien
  -- "+0%" trong khi mon do that su co cong. Phan tram phai co mot chu so
  -- thap phan.
  if role == "dmgpct" then
    return API.t("gear_bonus_dmg",
      string.format("%.1f", pctOf(pid, i, CFG.GEAR_DMG_MAX) * 100.0))
  elseif role == "mitig_phys" or role == "mitig_magic" then
    local pct = string.format("%.1f", pctOf(pid, i, CFG.GEAR_MITIG_MAX) * 100.0)
    return API.t((role == "mitig_phys") and "gear_bonus_mitig_phys"
                                         or "gear_bonus_mitig_magic", pct)
  end
  local v = addPoints(pid, i)
  if role == "all" then
    return API.t("gear_bonus_all", API.num(v / 3.0))
  end
  return "+" .. API.num(v) .. " " .. API.t("stat_" .. role)
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local iron  = API.getIron(pid)
  local out = {}
  for i = 1, itemCount() do
    local item = CFG.GEAR[i]
    local st  = stOf(pid, i)
    local it  = { icon = item.icon, name = fullName(pid, i) }

    -- 'short' + 'stat' la cua bang thong ke ben phai luoi; 'status' la
    -- cua kieu than "list" cu. Giu ca hai de doi kieu bay khong phai
    -- sua lai cho nay.
    if st.tier <= 0 then
      it.status = CFG.C_GREY .. API.t("gear_not_refined") .. CFG.C_END
      it.short  = API.pick(item)
      it.stat   = CFG.C_GREY .. "--" .. CFG.C_END
    else
      -- Cap hien tai VA phan mon nay dang cong. Khong co ve sau thi
      -- nguoi choi bo mot van da ma khong bao gio thay minh mua duoc gi.
      it.status = CFG.C_GREY .. st.level .. "/" .. levelMax() .. CFG.C_END ..
                  "   " .. CFG.C_JADE .. bonusLabel(pid, i) .. CFG.C_END
      it.short  = API.pick(item) .. " " .. st.tier .. "-" .. st.level
      it.stat   = CFG.C_JADE .. bonusLabel(pid, i) .. CFG.C_END
    end

    if canRefine(pid, i) then
      local pct = math.floor(nextOdds(pid, i) * 100.0 + 0.5)
      it.desc   = API.t("gear_up", levelNameOf(st.level + 1), pct)
      it.btn    = API.t("gear_btn_up") .. "  " .. API.num(CFG.GEAR_PRICE)
      it.btnOn = (iron >= CFG.GEAR_PRICE)

    elseif st.tier >= tierMax() then
      it.desc   = CFG.C_JADE .. API.t("gear_max") .. CFG.C_END
      it.note   = API.t("gear_note_max")

    elseif canEvolve(pid, i) then
      it.desc   = API.t("gear_need_iron")
      it.btn    = API.t("gear_btn_dismantle") .. "  " .. API.num(CFG.GEAR_DISMANTLE)
      it.btnOn = (iron >= CFG.GEAR_DISMANTLE)

    else
      -- Hoan Hao roi nhung Tu Vi chua toi. Day la luc cai TRAN hien ra,
      -- va no phai noi RO dang cho gi -- khong co nut ma khong giai
      -- thich thi nguoi choi tuong giao dien hong.
      -- 'desc' la cau day du cho kieu than "list"; 'note' la ban ngan
      -- dat vua mot o cua luoi. Hai cho hien, mot y.
      it.desc = CFG.C_GREY .. API.t("gear_cap", tierNameOf(st.tier + 1)) .. CFG.C_END
      it.note = API.t("gear_note_cap")
    end

    out[i] = it
  end
  return out
end

-- Mot nut, hai viec: truoc Hoan Hao thi Luyen, den Hoan Hao thi Tien
-- Giai. Quyet dinh o day la CUC BO nhung an toan, vi trang thai dua vao
-- (st.cap) da dong bo san -- va ca hai nhanh deu kiem lai dieu kien o
-- ben nhan.
local function tabItemAction(pid, i)
  if CFG.GEAR[i] == nil then return end
  if canRefine(pid, i) then
    API.syncSend(pid, CFG.OP_GEAR_UP, i)
  elseif canEvolve(pid, i) then
    API.syncSend(pid, CFG.OP_GEAR_DISMANTLE, i)
  end
end

local function startGear()
  -- Kieu "grid": bay o xep quanh cho hinh nguoi, nut Upgrade ngay duoi
  -- moi o, bang thong ke ben phai. Bo cuc o nam trong CFG.GEAR_SLOTS --
  -- bang chi doc, no khong biet mon nao la mon nao.
  API.panelAddTab({
    name        = API.t("panel_gear"),
    kind       = "grid",
    slots      = CFG.GEAR_SLOTS,
    statHead   = API.t("gear_stat_head"),
    items      = tabItems,
    itemAction = tabItemAction,
  })
  -- Lech so o va so mon thi bang se VE THIEU mot mon ma khong bao gi --
  -- dung kieu sai im lang cua ADR 0012. Bat o day, luc vao map.
  local nslot = (CFG.GEAR_SLOTS ~= nil) and #CFG.GEAR_SLOTS or 0
  if nslot ~= itemCount() then
    API.trace("gear: LECH -- " .. itemCount() .. " mon nhung " .. nslot ..
              " o trong CFG.GEAR_SLOTS; bang se ve thieu")
  end

  API.syncOn(CFG.OP_GEAR_UP,   refine)
  API.syncOn(CFG.OP_GEAR_DISMANTLE, dismantle)
  API.trace("gear: " .. itemCount() .. " mon x " .. tierMax() .. " canh gioi x " ..
            levelMax() .. " cap, the san sang (chi so con rong)")
end

API.gearName     = fullName
API.gearTier    = function(pid, i) local st = stOf(pid, i); return st and st.tier or 0 end
API.gearLevel     = function(pid, i) local st = stOf(pid, i); return st and st.level  or 0 end
API.gearStat    = statOf      -- tra ve str, agi, int
API.gearDmgPct  = dmgPctOf
API.gearMitigPct = mitigPctOf  -- (pid, "mitig_phys" | "mitig_magic")
API.gearBonus   = bonusLabel
API.startGear   = startGear
