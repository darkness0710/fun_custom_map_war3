-- ============================================================
--  3_skillframe.lua  --  Giao dien chon ky nang tu ve
--
--  Dung khi CFG.SKILL_MODE = "frame". Ve bang icon bang
--  BlzCreateFrameByType -- khong can file .fdf/.toc, khong phai import
--  gi trong World Editor.
--
--  HAI DIEU QUYET DINH TOAN BO THIET KE FILE NAY:
--
--  1. Frame la giao dien THUAN CLIENT, nam ngoai mo phong. Su kien bam
--     CHI no tren may nguoi bam. Doi trang thai game ngay trong do thi
--     may do re nhanh khoi hai may kia -- Warcraft III chay lockstep,
--     lech la da nguoi choi ra.
--
--     Nen: bam -> chi gui mot mau tin qua API.syncSend. Moi may, ke ca
--     may nguoi bam, nhan duoc roi MOI doi trang thai. Cung mot thay
--     doi, cung mot thu tu, khong lech. Kenh do 3_sync.lua lo.
--
--     (Popup dialog o 07_heropick khong dinh loi nay: dialog la UI cap
--     game, cu bam di qua duong lenh dong bo san.)
--
--  2. Moi nguoi choi phai co BANG RIENG. Lenh chat chay tren moi may,
--     nen mot bang dung chung se bi nguoi thu hai huy mat khi ho cung
--     go -sp.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local FRAME_OK = nil   -- nil = chua kiem tra

local function checkNatives(list)
  local missing = {}
  for i = 1, #list do
    if list[i][2] == nil then missing[#missing + 1] = list[i][1] end
  end
  return missing
end

local function framesAvailable()
  if FRAME_OK ~= nil then return FRAME_OK end
  local missing = checkNatives({
    { "BlzGetOriginFrame",           BlzGetOriginFrame },
    { "BlzCreateFrameByType",        BlzCreateFrameByType },
    { "BlzFrameSetAbsPoint",         BlzFrameSetAbsPoint },
    { "BlzFrameSetPoint",            BlzFrameSetPoint },
    { "BlzFrameSetAllPoints",        BlzFrameSetAllPoints },
    { "BlzFrameSetSize",             BlzFrameSetSize },
    { "BlzFrameSetTexture",          BlzFrameSetTexture },
    { "BlzFrameSetVisible",          BlzFrameSetVisible },
    { "BlzTriggerRegisterFrameEvent", BlzTriggerRegisterFrameEvent },
    { "BlzGetTriggerFrame",          BlzGetTriggerFrame },
    { "ORIGIN_FRAME_GAME_UI",        ORIGIN_FRAME_GAME_UI },
    { "FRAMEEVENT_CONTROL_CLICK",    FRAMEEVENT_CONTROL_CLICK },
    { "FRAMEPOINT_CENTER",           FRAMEPOINT_CENTER },
    { "FRAMEPOINT_LEFT",             FRAMEPOINT_LEFT },
  })
  FRAME_OK = (#missing == 0)
  if FRAME_OK then
    API.trace("frame: du native")
  else
    API.trace("frame: THIEU " .. table.concat(missing, " "))
    API.msg(nil, CFG.C_RED .. "Giao dien tu ve khong chay duoc -- thieu: " ..
      table.concat(missing, ", ") .. CFG.C_END)
  end
  return FRAME_OK
end

local function iconOf(choice)
  if choice.icon ~= nil then return choice.icon end
  if BlzGetAbilityIcon ~= nil then
    local p = BlzGetAbilityIcon(choice.id)
    if p ~= nil and p ~= "" then return p end
  end
  return nil
end

-- ---------- Bang rieng tung nguoi ----------

local function slotOf(pid)
  local sf = S.sframe
  if sf.byPid[pid] == nil then
    sf.byPid[pid] = { panel = nil, map = {}, slot = nil }
  end
  return sf.byPid[pid]
end

local function destroyPanel(pid)
  local st = slotOf(pid)
  if st.panel ~= nil and BlzDestroyFrame ~= nil then
    BlzDestroyFrame(st.panel)
  end
  st.panel = nil
  st.map = {}
end

local function hidePanel(pid)
  local st = slotOf(pid)
  if st.panel ~= nil then BlzFrameSetVisible(st.panel, false) end
end

local function nextSlotIndex(pid)
  local d = S.p[pid]
  local slots = API.slotsFor(pid)
  for i = 1, #slots do
    if d.slots[i] == nil then return i, slots end
  end
  return nil, slots
end

-- Chay tren MOI may. Bang duoc tao giong het nhau o khap noi; chi khac
-- o chuyen hien cho ai -- va do la UI, khong phai trang thai game, nen
-- dung GetLocalPlayer o day la an toan.
local function buildPanel(pid, slotIndex)
  local st = slotOf(pid)
  local slot = API.slotsFor(pid)[slotIndex]
  destroyPanel(pid)

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then
    API.msg(nil, CFG.C_RED .. "frame: khong lay duoc GAME_UI." .. CFG.C_END)
    return false
  end

  st.panel = BlzCreateFrameByType("BACKDROP", "SkillPanel", parent, "", pid)
  if st.panel == nil then
    API.msg(nil, CFG.C_RED .. "frame: BlzCreateFrameByType tra ve nil." .. CFG.C_END)
    return false
  end
  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.FRAME_X, CFG.FRAME_Y)
  BlzFrameSetSize(st.panel, CFG.FRAME_W, CFG.FRAME_H)
  BlzFrameSetTexture(st.panel, CFG.FRAME_BG, 0, true)

  if BlzFrameSetText ~= nil then
    local title = BlzCreateFrameByType("TEXT", "SkillTitle", st.panel, "", pid)
    if title ~= nil then
      BlzFrameSetPoint(title, FRAMEPOINT_CENTER, st.panel, FRAMEPOINT_CENTER,
                       0.0, CFG.FRAME_H * 0.36)
      BlzFrameSetText(title, slot.name or ("Slot " .. slotIndex))
      API.frameDead(title)
    end
  end

  local n = #slot.choices
  local step = CFG.FRAME_ICON + CFG.FRAME_GAP
  local startX = (CFG.FRAME_W - (n * CFG.FRAME_ICON + (n - 1) * CFG.FRAME_GAP)) * 0.5

  st.map = {}
  local made = 0
  for i = 1, n do
    local choice = slot.choices[i]
    local btn = BlzCreateFrameByType("GLUEBUTTON", "SkillBtn", st.panel,
                                     CFG.FRAME_BUTTON_TEMPLATE, pid)
    if btn ~= nil then
      BlzFrameSetSize(btn, CFG.FRAME_ICON, CFG.FRAME_ICON)
      BlzFrameSetPoint(btn, FRAMEPOINT_LEFT, st.panel, FRAMEPOINT_LEFT,
                       startX + (i - 1) * step, -CFG.FRAME_H * 0.08)

      local path = iconOf(choice)
      if path ~= nil then
        local ic = BlzCreateFrameByType("BACKDROP", "SkillIcon", btn, "", pid)
        if ic ~= nil then
          BlzFrameSetAllPoints(ic, btn)
          BlzFrameSetTexture(ic, path, 0, true)
          API.frameDead(ic)
        end
      end

      if BlzFrameSetTooltip == nil and BlzFrameSetText ~= nil then
        local lbl = BlzCreateFrameByType("TEXT", "SkillLbl", st.panel, "", pid)
        if lbl ~= nil then
          BlzFrameSetPoint(lbl, FRAMEPOINT_CENTER, btn, FRAMEPOINT_CENTER,
                           0.0, -CFG.FRAME_ICON * 0.75)
          BlzFrameSetText(lbl, choice.name)
          API.frameDead(lbl)
        end
      end

      BlzTriggerRegisterFrameEvent(S.sframe.trig, btn, FRAMEEVENT_CONTROL_CLICK)
      -- Ghi SO THU TU cua lua chon, khong phai id ability: kenh dong bo
      -- chi tai duoc so nho. Xem src/1_nen/3_sync.lua.
      st.map[btn] = { pid = pid, slot = slotIndex, ci = i }
      made = made + 1
    end
  end

  API.trace("frame: pid " .. pid .. " slot " .. slotIndex ..
            " -- tao " .. made .. "/" .. n .. " nut")
  if made == 0 then
    API.msg(nil, CFG.C_RED .. "frame: khong tao duoc nut nao -- thu doi " ..
      "CFG.FRAME_BUTTON_TEMPLATE." .. CFG.C_END)
    destroyPanel(pid)
    return false
  end

  st.slot = slotIndex
  BlzFrameSetVisible(st.panel, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.panel, true)
  end
  return true
end

local function showFrame(pid)
  if not framesAvailable() then
    API.msg(pid, CFG.C_GOLD .. "Lui ve popup chu." .. CFG.C_END)
    API.showSkillPicker(pid)
    return false
  end

  local d = S.p[pid]
  if d == nil or d.hero == nil then
    API.msg(pid, CFG.C_RED .. "Chua co hero de gan ky nang." .. CFG.C_END)
    return false
  end

  local si, slots = nextSlotIndex(pid)
  if #slots == 0 then
    API.msg(pid, CFG.C_RED .. "Hero nay chua khai bao cay skill nao." .. CFG.C_END)
    return false
  end
  if si == nil then
    hidePanel(pid)
    API.msg(pid, CFG.C_GOLD .. "Da chon du " .. #slots .. " slot." .. CFG.C_END)
    return false
  end

  return buildPanel(pid, si)
end

-- ---------- Ap dung lua chon ----------
-- Chay tren MOI may, tu su kien dong bo. Day la cho duy nhat duoc phep
-- doi trang thai game.
local function applyChoice(pid, slotIndex, aid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  if slotIndex == nil or aid == nil then return end

  -- Bam hai lan truoc khi tin dong bo ve: lan thu hai bi chan o day.
  if d.slots[slotIndex] ~= nil then return end

  if not UnitAddAbility(d.hero, aid) then
    API.msg(pid, CFG.C_RED .. "Khong gan duoc ability " .. API.idToStr(aid) ..
      " -- id sai, hoac unit khong nhan duoc ability nay." .. CFG.C_END)
    return
  end
  SetUnitAbilityLevel(d.hero, aid, 1)
  d.slots[slotIndex] = aid

  hidePanel(pid)
  local slots = API.slotsFor(pid)
  API.msg(nil, CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END ..
    " da hoc " .. CFG.C_JADE .. (slots[slotIndex].name or "?") .. CFG.C_END .. ".")

  if CFG.SKILL_PICK_CHAIN then showFrame(pid) end
end

-- ---------- Bam nut: CHI chay tren may nguoi bam ----------
local function onFrameClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  -- Nut cua nguoi nao thi chi nguoi do thay va bam duoc, nhung van tra
  -- lai cho chac -- xu ly cuc bo thi khong duoc phep doan.
  local hit = nil
  for pid, st in pairs(S.sframe.byPid) do
    if st.map[f] ~= nil then hit = st.map[f]; break end
  end
  if hit == nil then return end
  if GetLocalPlayer() ~= Player(hit.pid) then return end

  -- Khong doi gi o day. Chi bao cho moi may biet.
  API.syncSend(hit.pid, CFG.OP_SKILL, hit.slot * 100 + hit.ci)
end

-- Chay tren MOI may khi co ai gui tin.
local function onPicked(pid, arg)
  local slotIndex = math.floor(arg / 100)
  local ci        = arg - slotIndex * 100

  -- Cay skill lay tu hero dang cam, giong nhau tren moi may.
  local slot = API.slotsFor(pid)[slotIndex]
  if slot == nil or slot.choices[ci] == nil then return end

  applyChoice(pid, slotIndex, slot.choices[ci].id)
end

local function startSkillFrame()
  S.sframe = { trig = nil, syncTrig = nil, byPid = {} }
  if CFG.SKILL_MODE ~= "frame" then return end
  if not framesAvailable() then return end

  S.sframe.trig = CreateTrigger()
  TriggerAddAction(S.sframe.trig, onFrameClick)

  API.syncOn(CFG.OP_SKILL, onPicked)
  API.trace("frame: trigger san sang, dong bo=" .. API.syncMode())
end

API.showSkillFrame  = showFrame
API.startSkillFrame = startSkillFrame
API.framesAvailable = framesAvailable
