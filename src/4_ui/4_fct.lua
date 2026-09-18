-- ============================================================
--  4_fct.lua  --  Chu bay: sat thuong gay ra / nhan vao / linh khi
--
--  CAI BAY LON NHAT: Warcraft III chi cho khoang 100 text tag ton tai
--  cung luc. Mot wave co 50 con; ve mot chu moi don danh la trong vai
--  giay dat tran, va tu do KHONG CON chu nao hien nua -- ke ca chu quan
--  trong nhu "nha chinh sap chet".
--
--  Nen o day khong ve tung don. Sat thuong duoc CONG DON theo muc tieu
--  trong CFG.FCT_FLUSH giay, roi moi ve MOT chu -- va moi lan ve cung
--  chi ve toi da CFG.FCT_MAX_TAGS cai, uu tien con dau nhat.
--
--  Chu bay la UI thuan nen hien theo tung nguoi bang GetLocalPlayer --
--  an toan, khong dung toi trang thai game.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local EVT_OK = nil

local function eventsAvailable()
  if EVT_OK ~= nil then return EVT_OK end
  EVT_OK = (EVENT_PLAYER_UNIT_DAMAGED ~= nil and GetEventDamage ~= nil
        and GetEventDamageSource ~= nil and CreateTextTag ~= nil)
  if not EVT_OK then API.trace("fct: THIEU su kien sat thuong") end
  return EVT_OK
end

-- 1234 -> "1.2K", 1234567 -> "1.2M". Cuoi game sat thuong len hang van,
-- chu dai che mat man hinh.
local function short(n)
  n = math.floor(n + 0.5)
  if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
  if n >= 1000    then return string.format("%.1fK", n / 1000) end
  return tostring(n)
end

-- Ve mot chu bay. pid = nil thi ai cung thay.
local function tag(x, y, text, r, g, b, pid, rise)
  local tt = CreateTextTag()
  if tt == nil then return end

  SetTextTagText(tt, text, CFG.FCT_SIZE)
  SetTextTagPos(tt, x, y, CFG.FCT_HEIGHT)
  SetTextTagColor(tt, r, g, b, 255)
  SetTextTagVelocity(tt, 0.0, (rise or CFG.FCT_RISE))
  SetTextTagPermanent(tt, false)
  SetTextTagLifespan(tt, CFG.FCT_LIFE)
  SetTextTagFadepoint(tt, CFG.FCT_LIFE * 0.5)

  if pid ~= nil then
    SetTextTagVisibility(tt, GetLocalPlayer() == Player(pid))
  end
end

-- ---------- Cong don ----------

local function keyOf(u) return u end

local function addPending(u, pid, amount, kind)
  local f = S.fct
  local k = keyOf(u)
  local e = f.pending[k]
  if e == nil then
    e = { u = u, pid = pid, dealt = 0.0, taken = 0.0 }
    f.pending[k] = e
    f.count = f.count + 1
  end
  if kind == "dealt" then e.dealt = e.dealt + amount
  else                    e.taken = e.taken + amount end
end

-- Ve toi da MAX_TAGS moi lan, uu tien con dau nhat. Phan con lai bi bo
-- -- co y: chu bay la phan hoi, khong phai so ke toan.
local function flush()
  local f = S.fct
  if f.count == 0 then return end

  local list = {}
  for _, e in pairs(f.pending) do list[#list + 1] = e end
  table.sort(list, function(a, b)
    return (a.dealt + a.taken) > (b.dealt + b.taken)
  end)

  local n = #list
  if n > CFG.FCT_MAX_TAGS then n = CFG.FCT_MAX_TAGS end

  for i = 1, n do
    local e = list[i]
    if e.u ~= nil and API.alive(e.u) then
      local x, y = GetUnitX(e.u), GetUnitY(e.u)
      if e.dealt > 0 then
        tag(x, y, short(e.dealt), 255, 230, 120, e.pid)
      end
      if e.taken > 0 then
        tag(x, y, "-" .. short(e.taken), 255, 90, 90, e.pid)
      end
    end
  end

  f.pending = {}
  f.count = 0
end

-- ---------- Su kien ----------

local function onDamage()
  if not CFG.FCT_ENABLED then return end

  local amount = GetEventDamage()
  if amount == nil or amount < CFG.FCT_MIN then return end

  local target = GetTriggerUnit()
  local source = GetEventDamageSource()
  if target == nil then return end

  -- NHA CHINH: ai cung thay (pid = nil).
  --
  -- Truoc day ham nay chi ve cho hero cua nguoi choi, nen ca tran danh
  -- quanh nha chinh dien ra khong mot con so nao -- thu quan trong nhat
  -- cua van lai la thu duy nhat khong co phan hoi.
  --
  -- Khong gan cho mot pid nao: nha chinh do la ca ba nguoi cung thua,
  -- nen mot nguoi thay so con hai nguoi kia khong thay la sai.
  if S.house ~= nil then
    if target == S.house then
      addPending(target, nil, amount, "taken")
      return
    end
    if source == S.house then
      addPending(target, nil, amount, "dealt")
      return
    end
  end

  -- Sat thuong hero cua nguoi choi NHAN VAO: ve tren dau hero, mau do.
  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d = S.p[pid]
    if d ~= nil and d.hero == target then
      addPending(target, pid, amount, "taken")
      return
    end
  end

  -- Sat thuong hero GAY RA: ve tren dau muc tieu, mau vang.
  if source == nil then return end
  local spid = GetPlayerId(GetOwningPlayer(source))
  local sd = S.p[spid]
  if sd ~= nil and sd.hero == source then
    addPending(target, spid, amount, "dealt")
  end
end

-- Goi tu 04_player moi khi cong linh khi.
local function onQi(pid, amount)
  if not CFG.FCT_ENABLED or not CFG.FCT_SHOW_GOLD then return end
  if amount == nil or amount <= 0 then return end

  local d = S.p[pid]
  if d == nil or d.hero == nil then return end

  d.fctGold = (d.fctGold or 0) + amount
end

-- Linh khi cong don rieng: 50 con moi wave, ve tung dong la ngap man hinh.
local function flushGold()
  if not CFG.FCT_ENABLED or not CFG.FCT_SHOW_GOLD then return end
  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d = S.p[pid]
    if d ~= nil and d.hero ~= nil and (d.fctGold or 0) > 0 then
      if API.alive(d.hero) then
        tag(GetUnitX(d.hero), GetUnitY(d.hero), "+" .. short(d.fctGold),
            255, 215, 0, pid, CFG.FCT_RISE * 0.6)
      end
      d.fctGold = 0
    end
  end
end

local function startFct()
  S.fct = { pending = {}, count = 0 }
  if not CFG.FCT_ENABLED then return end
  if not eventsAvailable() then
    API.msg(nil, CFG.C_RED .. "Khong bat duoc su kien sat thuong -- tat chu bay."
      .. CFG.C_END)
    return
  end

  local t = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
  TriggerAddAction(t, onDamage)

  S.fctTimer = CreateTimer()
  TimerStart(S.fctTimer, CFG.FCT_FLUSH, true, function()
    flush()
    flushGold()
  end)

  API.trace("fct: san sang, gom moi " .. CFG.FCT_FLUSH .. "s, toi da " ..
            CFG.FCT_MAX_TAGS .. " chu/lan")
end

API.fctOnQi = onQi
API.fctTag       = tag
API.startFct     = startFct
