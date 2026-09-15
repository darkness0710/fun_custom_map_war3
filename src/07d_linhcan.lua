-- ============================================================
--  07d_linhcan.lua  --  Linh Can (tu vi cua nguoi choi)
--
--  Nguon suc manh LON NHAT: x20 trong hop dong x967
--  (docs/03-du-lieu/duong-cong-suc-manh.md). 20 bac, dung chung thang
--  ten voi 20 canh gioi cua phe dich.
--
--  Bang hien THANG BAC chu khong chi hien bac hien tai: nguoi choi phai
--  thay duoc minh dang o dau, sap len cai gi, va con bao xa nua.
--
--  Dong bo: bam frame chi no tren may nguoi bam, nen no gui
--  BlzSendSyncData va moi may moi goi breakthrough().
--  Rieng MO/DONG bang la UI thuan -- lam cuc bo duoc, khong can dong bo.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local SYNC_PREFIX = "DLC"
local ROWS_AHEAD  = 5    -- so bac ke tiep hien trong bang
local ROWS_BACK   = 1    -- so bac da qua hien trong bang

local FRAME_OK, SYNC_OK = nil, nil

local function framesAvailable()
  if FRAME_OK ~= nil then return FRAME_OK end
  FRAME_OK = (BlzGetOriginFrame ~= nil and BlzCreateFrameByType ~= nil
          and BlzFrameSetAbsPoint ~= nil and BlzFrameSetPoint ~= nil
          and BlzFrameSetSize ~= nil and BlzFrameSetTexture ~= nil
          and BlzFrameSetVisible ~= nil and BlzFrameSetText ~= nil
          and BlzTriggerRegisterFrameEvent ~= nil and BlzGetTriggerFrame ~= nil
          and ORIGIN_FRAME_GAME_UI ~= nil and FRAMEEVENT_CONTROL_CLICK ~= nil
          and FRAMEPOINT_CENTER ~= nil and FRAMEPOINT_TOP ~= nil
          and FRAMEPOINT_TOPLEFT ~= nil)
  if not FRAME_OK then API.trace("linhcan: THIEU native frame") end
  return FRAME_OK
end

local function syncAvailable()
  if SYNC_OK ~= nil then return SYNC_OK end
  SYNC_OK = (BlzSendSyncData ~= nil and TriggerRegisterPlayerSyncEvent ~= nil
         and BlzGetTriggerSyncData ~= nil)
  return SYNC_OK
end

-- ---------- Toan ----------

local function maxRank() return #CFG.REALMS end

local function rankName(r)
  local e = CFG.REALMS[r]
  if e == nil then return "?" end
  return e.ten
end

local function powerAt(r) return CFG.LINHCAN_STEP ^ (r - 1) end

-- Chi so can dat tai bac r.
--
-- GIAI NGUOC, khong nhan thang. Sat thuong hero = sat thuong nen + chi
-- so, nen nhan thang chi so len x1.17 moi bac chi cho x10.4 sat thuong
-- sau 20 bac -- thieu mot nua. Cong thuc nay bu lai phan nen.
local function statAt(r)
  local b = CFG.LINHCAN_DMG_BASE
  return (b + CFG.LINHCAN_STAT_BASE) * powerAt(r) - b
end

local function costOf(r)
  return math.floor(CFG.LINHCAN_COST_BASE * CFG.LINHCAN_COST_STEP ^ (r - 1) + 0.5)
end

-- Cong PHAN CHENH giua hai bac, khong dat lai tu dau -- SetHeroStr cong
-- don, dat lai tu dau se de len bonus cua trang bi sau nay.
local function applyRank(hero, fromR, toR)
  if hero == nil then return end
  local d = math.floor(statAt(toR) - statAt(fromR) + 0.5)
  if d == 0 then return end
  SetHeroStr(hero, GetHeroStr(hero, false) + d, true)
  SetHeroAgi(hero, GetHeroAgi(hero, false) + d, true)
  SetHeroInt(hero, GetHeroInt(hero, false) + d, true)
end

-- ---------- Bang ----------

local function stateOf(pid)
  local f = S.lcframe
  if f.byPid[pid] == nil then
    f.byPid[pid] = { panel = nil, btnUp = nil, btnClose = nil,
                     head = nil, foot = nil, rows = {}, shown = false }
  end
  return f.byPid[pid]
end

-- Mot dong cua thang bac.
local function rowText(pid, r, cur)
  local name = rankName(r)
  local pw   = string.format("x%.2f", powerAt(r))

  if r < cur then
    return CFG.C_GREY .. "  " .. r .. "  " .. name .. "   " .. pw ..
           "   da qua" .. CFG.C_END
  elseif r == cur then
    return CFG.C_GOLD .. "> " .. r .. "  " .. name .. "   " .. pw ..
           "   dang o day" .. CFG.C_END
  end

  -- Bac tuong lai: hien gia de len TU BAC HIEN TAI toi bac do.
  local sum = 0
  for k = cur, r - 1 do sum = sum + costOf(k) end
  local co = (API.getLinhKhi(pid) >= sum) and CFG.C_JADE or CFG.C_GREY
  return "  " .. r .. "  " .. name .. "   " .. pw ..
         "   " .. co .. API.num(sum) .. CFG.C_END
end

local function refreshText(pid)
  local st = stateOf(pid)
  if st.panel == nil then return end

  local d   = S.p[pid]
  local cur = d.linhCan

  if st.head ~= nil then
    BlzFrameSetText(st.head, CFG.C_GOLD .. "== LINH CAN ==" .. CFG.C_END ..
      "   bac " .. cur .. "/" .. maxRank() ..
      "   suc manh " .. CFG.C_JADE .. string.format("x%.2f", powerAt(cur)) .. CFG.C_END ..
      "   chi so +" .. API.num(statAt(cur) - CFG.LINHCAN_STAT_BASE))
  end

  local first = cur - ROWS_BACK
  if first < 1 then first = 1 end
  for i = 1, #st.rows do
    local r = first + i - 1
    if r <= maxRank() then
      BlzFrameSetText(st.rows[i], rowText(pid, r, cur))
    else
      BlzFrameSetText(st.rows[i], "")
    end
  end

  if st.foot ~= nil then
    if cur >= maxRank() then
      BlzFrameSetText(st.foot, CFG.C_JADE .. "Da toi dinh cua thang tu vi." .. CFG.C_END)
    else
      local c  = costOf(cur)
      local co = (API.getLinhKhi(pid) >= c) and CFG.C_JADE or CFG.C_RED
      BlzFrameSetText(st.foot,
        "Dot pha len " .. CFG.C_GOLD .. rankName(cur + 1) .. CFG.C_END ..
        "  gia " .. co .. API.num(c) .. CFG.C_END ..
        "   dang co " .. API.num(API.getLinhKhi(pid)))
    end
  end
end

local function hidePanel(pid)
  local st = stateOf(pid)
  if st.panel ~= nil then BlzFrameSetVisible(st.panel, false) end
  st.shown = false
end

local function buildPanel(pid)
  local st = stateOf(pid)
  if st.panel ~= nil then return true end

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  st.panel = BlzCreateFrameByType("BACKDROP", "LinhCanPanel", parent, "", pid)
  if st.panel == nil then return false end
  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.LINHCAN_X, CFG.LINHCAN_Y)
  BlzFrameSetSize(st.panel, CFG.LINHCAN_W, CFG.LINHCAN_H)
  BlzFrameSetTexture(st.panel, CFG.FRAME_BG, 0, true)

  -- Can trai cho thang bac doc thanh cot, khong phai chu can giua.
  local function text(name, dx, dy)
    local t = BlzCreateFrameByType("TEXT", name, st.panel, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT, dx, dy)
    end
    return t
  end

  st.head = text("LinhCanHead", 0.012, -0.012)

  local n = ROWS_BACK + 1 + ROWS_AHEAD
  st.rows = {}
  for i = 1, n do
    st.rows[i] = text("LinhCanRow" .. i, 0.012, -0.044 - (i - 1) * 0.021)
  end

  st.foot = text("LinhCanFoot", 0.012, -0.050 - n * 0.021)

  local function button(name, label, dx)
    local b = BlzCreateFrameByType("GLUEBUTTON", name, st.panel,
                                   CFG.FRAME_BUTTON_TEMPLATE, pid)
    if b == nil then return nil end
    BlzFrameSetSize(b, 0.10, 0.026)
    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT,
                     dx, -0.076 - n * 0.021)
    local t = BlzCreateFrameByType("TEXT", name .. "Txt", b, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_CENTER, b, FRAMEPOINT_CENTER, 0, 0)
      BlzFrameSetText(t, label)
    end
    BlzTriggerRegisterFrameEvent(S.lcframe.trig, b, FRAMEEVENT_CONTROL_CLICK)
    return b
  end

  st.btnUp    = button("LinhCanUp",    "Dot pha", 0.012)
  st.btnClose = button("LinhCanClose", "Dong",    0.130)

  BlzFrameSetVisible(st.panel, false)
  API.trace("linhcan: dung bang cho pid " .. pid .. " (" .. n .. " dong)")
  return true
end

-- Mo/dong. UI thuan nen lam cuc bo duoc.
local function setShown(pid, want)
  if not framesAvailable() then
    local d = S.p[pid]
    local r = d.linhCan
    API.msg(pid, CFG.C_GOLD .. "Linh Can: " .. rankName(r) .. " (bac " .. r ..
      "/" .. maxRank() .. ", x" .. string.format("%.2f", powerAt(r)) .. ")" .. CFG.C_END)
    if r < maxRank() then
      API.msg(pid, "Bac ke " .. rankName(r + 1) .. " gia " ..
        API.num(costOf(r)) .. ". Go -lc up de dot pha.")
    end
    return
  end

  if not buildPanel(pid) then return end
  local st = stateOf(pid)
  st.shown = want
  refreshText(pid)

  BlzFrameSetVisible(st.panel, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.panel, st.shown)
  end
end

local function toggle(pid)
  local st = stateOf(pid)
  setShown(pid, not st.shown)
end

-- ---------- Dot pha ----------
-- Chay tren MOI may, tu su kien dong bo.

local function setRank(pid, newR, free)
  local d = S.p[pid]
  if d == nil then return end
  if newR < 1 then newR = 1 end
  if newR > maxRank() then newR = maxRank() end

  local old = d.linhCan
  if newR == old then return end

  d.linhCan = newR
  applyRank(d.hero, old, newR)
  refreshText(pid)

  if free then
    API.msg(pid, CFG.C_GREY .. "[dev] Linh Can -> " .. rankName(newR) ..
      " (bac " .. newR .. ", x" .. string.format("%.2f", powerAt(newR)) .. ")" .. CFG.C_END)
  end
end

local function breakthrough(pid)
  local d = S.p[pid]
  if d == nil then return end

  local r = d.linhCan
  if r >= maxRank() then
    API.msg(pid, CFG.C_GREY .. "Da toi dinh cua thang tu vi." .. CFG.C_END)
    return
  end

  local c = costOf(r)
  if not API.spendLinhKhi(pid, c) then
    API.msg(pid, CFG.C_RED .. "Khong du linh khi." .. CFG.C_END ..
      " Can " .. API.num(c) .. ", dang co " .. API.num(API.getLinhKhi(pid)) .. ".")
    refreshText(pid)
    return
  end

  setRank(pid, r + 1, false)
  API.msg(nil, CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END ..
    " dot pha len " .. CFG.C_JADE .. rankName(r + 1) .. CFG.C_END ..
    " (x" .. string.format("%.2f", powerAt(r + 1)) .. ")")

  if d.hero ~= nil then
    API.fx([[Abilities\Spells\Human\Resurrect\ResurrectTarget.mdl]],
           GetUnitX(d.hero), GetUnitY(d.hero))
  end
end

-- ---------- Su kien ----------

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  for pid, st in pairs(S.lcframe.byPid) do
    if GetLocalPlayer() == Player(pid) then
      if f == st.btnClose then
        hidePanel(pid)
        return
      elseif f == st.btnUp then
        if syncAvailable() then
          BlzSendSyncData(SYNC_PREFIX, "up")
        else
          breakthrough(pid)
        end
        return
      end
    end
  end
end

local function onSync()
  local pid  = GetPlayerId(GetTriggerPlayer())
  local data = BlzGetTriggerSyncData()
  if data == nil then return end

  if data == "up" then
    breakthrough(pid)
  else
    local n = tonumber(data:match("^set:(%d+)$"))
    if n ~= nil then setRank(pid, n, true) end
  end
end

-- "-lc" mo bang · "-lc up" dot pha · "-lc <so>" nhay thang toi bac (dev)
local function onChat(pid, raw)
  if raw == nil then toggle(pid); return end

  if raw:match("^%s*%-lc%s+up") then
    if syncAvailable() then
      if GetLocalPlayer() == Player(pid) then BlzSendSyncData(SYNC_PREFIX, "up") end
    else
      breakthrough(pid)
    end
    return
  end

  local n = tonumber(raw:match("^%s*%-lc%s+(%d+)"))
  if n ~= nil then
    if not CFG.DEV_COMMANDS then
      API.msg(pid, CFG.C_RED .. "Lenh dev dang tat (CFG.DEV_COMMANDS)." .. CFG.C_END)
      return
    end
    if syncAvailable() then
      if GetLocalPlayer() == Player(pid) then
        BlzSendSyncData(SYNC_PREFIX, "set:" .. n)
      end
    else
      setRank(pid, n, true)
    end
    return
  end

  toggle(pid)
end

-- Phim E. Su kien phim la CUC BO, nhung mo/dong bang cung la UI thuan
-- nen khong can dong bo.
local function bindKey()
  if BlzTriggerRegisterPlayerKeyEvent == nil or OSKEY_E == nil then
    API.trace("linhcan: KHONG co BlzTriggerRegisterPlayerKeyEvent/OSKEY_E -- chi con -lc")
    return false
  end

  local t = CreateTrigger()
  for i = 1, #S.pids do
    BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), OSKEY_E, 0, true)
  end
  TriggerAddAction(t, function()
    toggle(GetPlayerId(GetTriggerPlayer()))
  end)
  API.trace("linhcan: da gan phim E")
  return true
end

local function startLinhCan()
  S.lcframe = { trig = nil, syncTrig = nil, byPid = {} }

  S.lcframe.trig = CreateTrigger()
  TriggerAddAction(S.lcframe.trig, onClick)

  if syncAvailable() then
    S.lcframe.syncTrig = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerSyncEvent(S.lcframe.syncTrig, Player(S.pids[i]),
                                     SYNC_PREFIX, false)
    end
    TriggerAddAction(S.lcframe.syncTrig, onSync)
  end

  S.keyBound = bindKey()
  API.trace("linhcan: san sang, dong bo=" .. tostring(syncAvailable()) ..
            " phimE=" .. tostring(S.keyBound))
end

-- Goi khi hero vua duoc tao: ap lai bac hien tai, de doi hero khong mat tu vi.
local function applyToHero(pid, hero)
  local d = S.p[pid]
  if d == nil or hero == nil then return end
  applyRank(hero, 1, d.linhCan)
end

API.linhCanRank    = function(pid) return S.p[pid] and S.p[pid].linhCan or 1 end
API.linhCanPower   = function(pid) return powerAt(API.linhCanRank(pid)) end
API.linhCanCost    = costOf
API.linhCanStatAt  = statAt
API.linhCanToggle  = toggle
API.linhCanRefresh = refreshText
API.linhCanChat    = onChat
API.linhCanApply   = applyToHero
API.startLinhCan   = startLinhCan
