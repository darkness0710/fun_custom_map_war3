-- ============================================================
--  1_panel.lua  --  Bang nhan vat (phim E)
--
--  MOT khung duy nhat voi 4 the. Moi he tu dang ky noi dung cua minh
--  qua API.panelAddTab -- khung nay khong biet gi ve Linh Can hay Ky
--  Nang, no chi ve chu va nut.
--
--  Nho vay them mot he moi khong phai dung them bang: goi panelAddTab
--  la xong. Va bon he khong the lech nhau ve giao dien.
--
--  Mo/dong va doi the la UI THUAN -> lam cuc bo duoc, khong can dong
--  bo. Chi HANH DONG (dot pha, nang cap) moi phai qua BlzSendSyncData,
--  va do la viec cua tung he.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local ROWS = 8

local FRAME_OK = nil

local function framesAvailable()
  if FRAME_OK ~= nil then return FRAME_OK end
  FRAME_OK = (BlzGetOriginFrame ~= nil and BlzCreateFrameByType ~= nil
          and BlzFrameSetAbsPoint ~= nil and BlzFrameSetPoint ~= nil
          and BlzFrameSetSize ~= nil and BlzFrameSetTexture ~= nil
          and BlzFrameSetVisible ~= nil and BlzFrameSetText ~= nil
          and BlzTriggerRegisterFrameEvent ~= nil and BlzGetTriggerFrame ~= nil
          and ORIGIN_FRAME_GAME_UI ~= nil and FRAMEEVENT_CONTROL_CLICK ~= nil
          and FRAMEPOINT_CENTER ~= nil and FRAMEPOINT_TOPLEFT ~= nil)
  if not FRAME_OK then API.trace("panel: THIEU native frame") end
  return FRAME_OK
end

-- ---------- Dang ky the ----------
-- tab = { ten, rows(pid)->{chuoi},
--         actionLabel(pid)->chuoi|nil, action(pid),        -- nut o chan bang
--         rowLabel(pid,i)->chuoi|nil,  rowAction(pid,i) }  -- nut cua tung dong

local function addTab(tab)
  S.panel.tabs[#S.panel.tabs + 1] = tab
  return #S.panel.tabs
end

-- The chua lam: hien ro la chua lam thay vi de trong. Mot the trong
-- khien nguoi choi tuong giao dien hong.
local function placeholderTab(ten, mota)
  return {
    ten = ten,
    rows = function()
      return { CFG.C_GREY .. "He nay chua cai." .. CFG.C_END, "", mota }
    end,
    actionLabel = function() return nil end,
    action = function() end,
  }
end

-- ---------- Bang ----------

local function stateOf(pid)
  if S.panel.byPid[pid] == nil then
    S.panel.byPid[pid] = { panel = nil, head = nil, rows = {}, rowBtn = {},
                           tabBtn = {}, btnAction = nil, btnActionTxt = nil,
                           btnClose = nil, tab = 1, shown = false }
  end
  return S.panel.byPid[pid]
end

local function refresh(pid)
  local st = stateOf(pid)
  if st.panel == nil then return end

  local tab = S.panel.tabs[st.tab]
  if tab == nil then return end

  -- Nhan the: the dang mo to vang, cac the khac xam.
  for i = 1, #S.panel.tabs do
    local t = st.tabBtn[i]
    if t ~= nil and t.txt ~= nil then
      local nm = S.panel.tabs[i].ten
      if i == st.tab then
        BlzFrameSetText(t.txt, CFG.C_GOLD .. nm .. CFG.C_END)
      else
        BlzFrameSetText(t.txt, CFG.C_GREY .. nm .. CFG.C_END)
      end
    end
  end

  if st.head ~= nil then
    BlzFrameSetText(st.head, CFG.C_GOLD .. "== " .. tab.ten .. " ==" .. CFG.C_END ..
      "    Linh Khi " .. CFG.C_JADE .. API.num(API.getLinhKhi(pid)) .. CFG.C_END ..
      "    Tinh Thach " .. CFG.C_JADE .. API.num(API.getTinhThach(pid)) .. CFG.C_END)
  end

  local lines = tab.rows(pid) or {}
  for i = 1, ROWS do
    BlzFrameSetText(st.rows[i], lines[i] or "")

    -- Nut rieng cho tung dong. Mot nut chung o chan bang khong du: the
    -- Ky Nang co bay dong, moi dong mot ky nang nang rieng.
    local rb = st.rowBtn[i]
    if rb ~= nil then
      local nhan = tab.rowLabel and tab.rowLabel(pid, i) or nil
      BlzFrameSetVisible(rb.btn, nhan ~= nil)
      if nhan ~= nil and rb.txt ~= nil then BlzFrameSetText(rb.txt, nhan) end
    end
  end

  local label = tab.actionLabel and tab.actionLabel(pid) or nil
  if st.btnAction ~= nil then
    BlzFrameSetVisible(st.btnAction, label ~= nil)
    if label ~= nil and st.btnActionTxt ~= nil then
      BlzFrameSetText(st.btnActionTxt, label)
    end
  end
end

local function hide(pid)
  local st = stateOf(pid)
  if st.panel ~= nil then BlzFrameSetVisible(st.panel, false) end
  st.shown = false
end

local function build(pid)
  local st = stateOf(pid)
  if st.panel ~= nil then return true end

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  st.panel = BlzCreateFrameByType("BACKDROP", "CharPanel", parent, "", pid)
  if st.panel == nil then return false end
  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.PANEL_X, CFG.PANEL_Y)
  BlzFrameSetSize(st.panel, CFG.PANEL_W, CFG.PANEL_H)
  BlzFrameSetTexture(st.panel, CFG.FRAME_BG, 0, true)

  local function text(name, dx, dy)
    local t = BlzCreateFrameByType("TEXT", name, st.panel, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT, dx, dy)
    end
    return t
  end

  local function button(name, label, dx, dy, w)
    local b = BlzCreateFrameByType("GLUEBUTTON", name, st.panel,
                                   CFG.FRAME_BUTTON_TEMPLATE, pid)
    if b == nil then return nil end
    BlzFrameSetSize(b, w, 0.024)
    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT, dx, dy)
    local t = BlzCreateFrameByType("TEXT", name .. "Txt", b, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_CENTER, b, FRAMEPOINT_CENTER, 0, 0)
      BlzFrameSetText(t, label)
    end
    BlzTriggerRegisterFrameEvent(S.panel.trig, b, FRAMEEVENT_CONTROL_CLICK)
    return { btn = b, txt = t }
  end

  -- Hang the
  local n = #S.panel.tabs
  local tw = (CFG.PANEL_W - 0.024 - (n - 1) * 0.006) / n
  st.tabBtn = {}
  for i = 1, n do
    st.tabBtn[i] = button("CharTab" .. i, S.panel.tabs[i].ten,
                          0.012 + (i - 1) * (tw + 0.006), -0.012, tw)
  end

  st.head = text("CharHead", 0.012, -0.046)

  st.rows = {}
  st.rowBtn = {}
  for i = 1, ROWS do
    local y = -0.074 - (i - 1) * 0.021
    st.rows[i] = text("CharRow" .. i, 0.012, y)
    local rb = button("CharRowBtn" .. i, "+", CFG.PANEL_W - 0.040, y + 0.004, 0.026)
    if rb ~= nil then
      st.rowBtn[i] = rb
      BlzFrameSetVisible(rb.btn, false)
    end
  end

  local footY = -0.084 - ROWS * 0.021
  local a = button("CharAction", "", 0.012, footY, 0.12)
  if a ~= nil then st.btnAction, st.btnActionTxt = a.btn, a.txt end
  local c = button("CharClose", "Dong", 0.140, footY, 0.08)
  if c ~= nil then st.btnClose = c.btn end

  BlzFrameSetVisible(st.panel, false)
  API.trace("panel: dung bang cho pid " .. pid .. " (" .. n .. " the)")
  return true
end

local function setShown(pid, want)
  if not framesAvailable() then
    API.msg(pid, CFG.C_RED .. "Khong ve duoc bang -- dung lenh chat." .. CFG.C_END)
    return
  end
  if not build(pid) then return end

  local st = stateOf(pid)
  st.shown = want
  refresh(pid)

  BlzFrameSetVisible(st.panel, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.panel, st.shown)
  end
end

local function toggle(pid)
  setShown(pid, not stateOf(pid).shown)
end

local function openTab(pid, index)
  local st = stateOf(pid)
  if S.panel.tabs[index] == nil then return end
  st.tab = index
  setShown(pid, true)
end

-- ---------- Su kien ----------

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  for pid, st in pairs(S.panel.byPid) do
    if GetLocalPlayer() == Player(pid) then
      if f == st.btnClose then
        hide(pid)
        return
      end
      if f == st.btnAction then
        local tab = S.panel.tabs[st.tab]
        if tab ~= nil and tab.action ~= nil then tab.action(pid) end
        return
      end
      for i = 1, #st.tabBtn do
        if st.tabBtn[i] ~= nil and f == st.tabBtn[i].btn then
          st.tab = i
          refresh(pid)
          return
        end
      end
      for i = 1, ROWS do
        local rb = st.rowBtn[i]
        if rb ~= nil and f == rb.btn then
          local tab = S.panel.tabs[st.tab]
          if tab ~= nil and tab.rowAction ~= nil then tab.rowAction(pid, i) end
          return
        end
      end
    end
  end
end

-- Phim E. Su kien phim la cuc bo, nhung mo/dong bang cung la UI thuan
-- nen khong can dong bo.
local function bindKey()
  if BlzTriggerRegisterPlayerKeyEvent == nil or OSKEY_E == nil then
    API.trace("panel: KHONG co BlzTriggerRegisterPlayerKeyEvent/OSKEY_E -- chi con -c")
    return false
  end
  local t = CreateTrigger()
  for i = 1, #S.pids do
    BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), OSKEY_E, 0, true)
  end
  TriggerAddAction(t, function() toggle(GetPlayerId(GetTriggerPlayer())) end)
  API.trace("panel: da gan phim E")
  return true
end

local function startPanel()
  S.panel.trig = CreateTrigger()
  TriggerAddAction(S.panel.trig, onClick)
  S.keyBound = bindKey()
  API.trace("panel: san sang, " .. #S.panel.tabs .. " the, phimE=" ..
            tostring(S.keyBound))
end

API.panelAddTab      = addTab
API.panelPlaceholder = placeholderTab
API.panelRefresh     = refresh
API.panelToggle      = toggle
API.panelOpenTab     = openTab
API.startPanel       = startPanel
