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
--  CHI SO CON RONG -- 2026-09-17. Khung chay day du nhung chua mon nao
--  cong gi. Cho do chi so se nam la API.gearMult / gearStat ben
--  duoi; chung dang tra ve 1.0 va 0.
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

-- ---------- CHO DAT CHI SO ----------
--
-- CON RONG CO Y. Ca hai ham duoi day la cho chi so se nam khi chot
-- xong. Giu chung ton tai ngay tu bay gio de noi goi san co (7_effect)
-- khong phai sua lai khi do.
--
-- RANG BUOC da biet khi thiet ke phan chi so:
--   1. Suc manh phai bam CANH GIOI, khong bam so bac tuyet doi -- neu
--      khong thi cai tran Tu Vi mat tac dung bao ve (ADR 0021).
--   2. Mot cap o canh gioi 20 phai dang hon mot cap o canh gioi 1. Nho
--      vay the 1 Co Duyen phang (3 da) van can duoc the 2 leo x1.30:
--      da phang, nhung thu da mua duoc thi leo.
--   3. Cap Hoan Hao ngon 6.67 trong tong 15 lan thu cua ca canh gioi --
--      gan mot nua ngan sach cho rieng mot cap. No phai dang.

local function multOf(pid)       -- nhan so sat thuong
  return 1.0
end

local function statOf(pid)      -- cong them chi so
  return 0
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local iron  = API.getIron(pid)
  local out = {}
  for i = 1, itemCount() do
    local item = CFG.GEAR[i]
    local st  = stOf(pid, i)
    local it  = { icon = item.icon, name = fullName(pid, i) }

    if st.tier <= 0 then
      it.status = CFG.C_GREY .. API.t("gear_not_refined") .. CFG.C_END
    else
      it.status = CFG.C_GREY .. st.level .. "/" .. levelMax() .. CFG.C_END
    end

    if canRefine(pid, i) then
      local pct = math.floor(nextOdds(pid, i) * 100.0 + 0.5)
      it.desc   = API.t("gear_up", levelNameOf(st.level + 1), pct)
      it.btn    = API.t("gear_btn_up") .. "  " .. API.num(CFG.GEAR_PRICE)
      it.btnOn = (iron >= CFG.GEAR_PRICE)

    elseif st.tier >= tierMax() then
      it.desc   = CFG.C_JADE .. API.t("gear_max") .. CFG.C_END

    elseif canEvolve(pid, i) then
      it.desc   = API.t("gear_need_iron")
      it.btn    = API.t("gear_btn_dismantle") .. "  " .. API.num(CFG.GEAR_DISMANTLE)
      it.btnOn = (iron >= CFG.GEAR_DISMANTLE)

    else
      -- Hoan Hao roi nhung Tu Vi chua toi. Day la luc cai TRAN hien ra,
      -- va no phai noi RO dang cho gi -- khong co nut ma khong giai
      -- thich thi nguoi choi tuong giao dien hong.
      it.desc = CFG.C_GREY .. API.t("gear_cap", tierNameOf(st.tier + 1)) .. CFG.C_END
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
  API.panelAddTab({
    name        = API.t("panel_gear"),
    kind       = "list",
    rows      = itemCount(),
    items      = tabItems,
    itemAction = tabItemAction,
  })
  API.syncOn(CFG.OP_GEAR_UP,   refine)
  API.syncOn(CFG.OP_GEAR_DISMANTLE, dismantle)
  API.trace("gear: " .. itemCount() .. " mon x " .. tierMax() .. " canh gioi x " ..
            levelMax() .. " cap, the san sang (chi so con rong)")
end

API.gearName     = fullName
API.gearTier    = function(pid, i) local st = stOf(pid, i); return st and st.tier or 0 end
API.gearLevel     = function(pid, i) local st = stOf(pid, i); return st and st.level  or 0 end
API.gearMult    = multOf
API.gearStat   = statOf
API.startGear   = startGear
