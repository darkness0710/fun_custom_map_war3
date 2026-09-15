-- ============================================================
--  07d_linhcan.lua  --  Linh Can (tu vi cua nguoi choi)
--
--  Nguon suc manh LON NHAT: x20 trong hop dong x967
--  (docs/03-du-lieu/duong-cong-suc-manh.md). 20 bac, dung chung thang
--  ten voi 20 canh gioi cua phe dich.
--
--  Cung kien truc dong bo nhu 07b/07c: bam frame chi no tren may nguoi
--  bam, nen bam KHONG doi trang thai -- no gui BlzSendSyncData, va moi
--  may goi breakthrough() khi nhan duoc.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local SYNC_PREFIX = "DLC"

local FRAME_OK, SYNC_OK = nil, nil

local function framesAvailable()
  if FRAME_OK ~= nil then return FRAME_OK end
  FRAME_OK = (BlzGetOriginFrame ~= nil and BlzCreateFrameByType ~= nil
          and BlzFrameSetAbsPoint ~= nil and BlzFrameSetPoint ~= nil
          and BlzFrameSetSize ~= nil and BlzFrameSetTexture ~= nil
          and BlzFrameSetVisible ~= nil and BlzFrameSetText ~= nil
          and BlzTriggerRegisterFrameEvent ~= nil and BlzGetTriggerFrame ~= nil
          and ORIGIN_FRAME_GAME_UI ~= nil and FRAMEEVENT_CONTROL_CLICK ~= nil
          and FRAMEPOINT_CENTER ~= nil and FRAMEPOINT_TOP ~= nil)
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

local function maxRank()
  return #CFG.REALMS
end

local function rankName(r)
  local e = CFG.REALMS[r]
  if e == nil then return "?" end
  return e.ten
end

-- Suc manh cong don tai bac r.
local function powerAt(r)
  return CFG.LINHCAN_STEP ^ (r - 1)
end

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

-- ---------- Ap dung ----------

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
                     txtNow = nil, txtNext = nil, shown = false }
  end
  return f.byPid[pid]
end

local function refreshText(pid)
  local st = stateOf(pid)
  if st.panel == nil then return end

  local d = S.p[pid]
  local r = d.linhCan

  if st.txtNow ~= nil then
    BlzFrameSetText(st.txtNow, CFG.C_GOLD .. "Linh Can: " .. rankName(r) ..
      CFG.C_END .. "   bac " .. r .. "/" .. maxRank() ..
      "   suc manh x" .. string.format("%.2f", powerAt(r)))
  end

  if st.txtNext ~= nil then
    if r >= maxRank() then
      BlzFrameSetText(st.txtNext, CFG.C_JADE .. "Da toi dinh." .. CFG.C_END)
    else
      local c = costOf(r)
      local co = (API.getLinhKhi(pid) >= c) and CFG.C_JADE or CFG.C_RED
      BlzFrameSetText(st.txtNext, "Bac ke: " .. rankName(r + 1) ..
        "  x" .. string.format("%.2f", powerAt(r + 1)) ..
        "   gia " .. co .. API.num(c) .. CFG.C_END .. " linh khi")
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

  local function line(name, dy)
    local t = BlzCreateFrameByType("TEXT", name, st.panel, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_TOP, st.panel, FRAMEPOINT_TOP, 0.0, dy)
    end
    return t
  end

  local title = line("LinhCanTitle", -0.010)
  if title ~= nil then
    BlzFrameSetText(title, CFG.C_GOLD .. "== LINH CAN ==" .. CFG.C_END)
  end
  st.txtNow  = line("LinhCanNow",  -0.045)
  st.txtNext = line("LinhCanNext", -0.075)

  st.btnUp = BlzCreateFrameByType("GLUEBUTTON", "LinhCanUp", st.panel,
                                  CFG.FRAME_BUTTON_TEMPLATE, pid)
  if st.btnUp ~= nil then
    BlzFrameSetSize(st.btnUp, 0.11, 0.028)
    BlzFrameSetPoint(st.btnUp, FRAMEPOINT_TOP, st.panel, FRAMEPOINT_TOP,
                     -0.065, -0.112)
    local t = BlzCreateFrameByType("TEXT", "LinhCanUpTxt", st.btnUp, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_CENTER, st.btnUp, FRAMEPOINT_CENTER, 0, 0)
      BlzFrameSetText(t, "Dot pha")
    end
    BlzTriggerRegisterFrameEvent(S.lcframe.trig, st.btnUp, FRAMEEVENT_CONTROL_CLICK)
  end

  st.btnClose = BlzCreateFrameByType("GLUEBUTTON", "LinhCanClose", st.panel,
                                     CFG.FRAME_BUTTON_TEMPLATE, pid)
  if st.btnClose ~= nil then
    BlzFrameSetSize(st.btnClose, 0.08, 0.028)
    BlzFrameSetPoint(st.btnClose, FRAMEPOINT_TOP, st.panel, FRAMEPOINT_TOP,
                     0.075, -0.112)
    local t = BlzCreateFrameByType("TEXT", "LinhCanCloseTxt", st.btnClose, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_CENTER, st.btnClose, FRAMEPOINT_CENTER, 0, 0)
      BlzFrameSetText(t, "Dong")
    end
    BlzTriggerRegisterFrameEvent(S.lcframe.trig, st.btnClose, FRAMEEVENT_CONTROL_CLICK)
  end

  BlzFrameSetVisible(st.panel, false)
  API.trace("linhcan: da dung bang cho pid " .. pid)
  return true
end

-- Mo/dong. Doi hien theo tung may la an toan: no khong dung trang thai game.
local function toggle(pid)
  if not framesAvailable() then
    -- Khong ve duoc thi van choi duoc: bao bang chu.
    local d = S.p[pid]
    local r = d.linhCan
    API.msg(pid, CFG.C_GOLD .. "Linh Can: " .. rankName(r) .. " (bac " .. r ..
      "/" .. maxRank() .. ", x" .. string.format("%.2f", powerAt(r)) .. ")" .. CFG.C_END)
    if r < maxRank() then
      API.msg(pid, "Dot pha len " .. rankName(r + 1) .. " gia " ..
        API.num(costOf(r)) .. " linh khi. Go -lc up de dot pha.")
    end
    return
  end

  if not buildPanel(pid) then return end
  local st = stateOf(pid)
  st.shown = not st.shown
  refreshText(pid)

  BlzFrameSetVisible(st.panel, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.panel, st.shown)
  end
end

-- ---------- Dot pha ----------
-- Chay tren MOI may, tu su kien dong bo. Day la cho duy nhat duoc phep
-- doi trang thai.
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
    return
  end

  d.linhCan = r + 1
  applyRank(d.hero, r, r + 1)
  refreshText(pid)

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
          breakthrough(pid)   -- chi dung cho mot nguoi choi
        end
        return
      end
    end
  end
end

local function onSync()
  local pid = GetPlayerId(GetTriggerPlayer())
  local data = BlzGetTriggerSyncData()
  if data == "up" then breakthrough(pid) end
end

-- Bang "-lc" mo bang, "-lc up" dot pha khong can bang (cho ban nao
-- khong ve duoc frame).
local function onChat(pid, raw)
  if raw ~= nil and raw:match("^%s*%-lc%s+up") then
    if syncAvailable() then
      if GetLocalPlayer() == Player(pid) then BlzSendSyncData(SYNC_PREFIX, "up") end
    else
      breakthrough(pid)
    end
    return
  end
  toggle(pid)
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
  API.trace("linhcan: san sang, dong bo " .. tostring(syncAvailable()))
end

-- Goi khi hero vua duoc tao: ap lai bac hien tai (thuong la 1, nhung
-- neu nguoi choi doi hero sau nay thi khong mat tu vi).
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
API.linhCanChat    = onChat
API.linhCanApply   = applyToHero
API.startLinhCan   = startLinhCan
