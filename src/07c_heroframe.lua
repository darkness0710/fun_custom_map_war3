-- ============================================================
--  07c_heroframe.lua  --  Chon hero bang the (card)
--
--  Dung khi CFG.HERO_PICK_MODE = "frame". Ve mot hang the, moi the mot
--  hero: icon lon, ten, vai.
--
--  Cung hai rang buoc nhu 07b_skillframe, va vi cung mot ly do:
--
--  1. Su kien bam frame CHI no tren may nguoi bam. Nen bam khong doi
--     trang thai -- no gui mot mau tin qua API.syncSend (02b_sync.lua),
--     va moi may goi API.applyHeroPick khi nhan duoc. Lech may la bi da
--     ra khoi tran, khong phai loi hien thi.
--
--  2. Moi nguoi mot bang rieng. Lenh/timer chay tren moi may, nen mot
--     bang dung chung se bi nguoi thu hai huy mat.
--
--  Thieu native frame thi tu lui ve popup chu, khong sap.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local FRAME_OK = nil

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
    { "BlzGetOriginFrame",            BlzGetOriginFrame },
    { "BlzCreateFrameByType",         BlzCreateFrameByType },
    { "BlzFrameSetAbsPoint",          BlzFrameSetAbsPoint },
    { "BlzFrameSetPoint",             BlzFrameSetPoint },
    { "BlzFrameSetSize",              BlzFrameSetSize },
    { "BlzFrameSetTexture",           BlzFrameSetTexture },
    { "BlzFrameSetVisible",           BlzFrameSetVisible },
    { "BlzTriggerRegisterFrameEvent", BlzTriggerRegisterFrameEvent },
    { "BlzGetTriggerFrame",           BlzGetTriggerFrame },
    { "ORIGIN_FRAME_GAME_UI",         ORIGIN_FRAME_GAME_UI },
    { "FRAMEEVENT_CONTROL_CLICK",     FRAMEEVENT_CONTROL_CLICK },
    { "FRAMEPOINT_CENTER",            FRAMEPOINT_CENTER },
    { "FRAMEPOINT_TOP",               FRAMEPOINT_TOP },
  })
  FRAME_OK = (#missing == 0)
  if not FRAME_OK then
    API.trace("herocard: THIEU " .. table.concat(missing, " "))
  end
  return FRAME_OK
end

local function stateOf(pid)
  local hf = S.hframe
  if hf.byPid[pid] == nil then
    hf.byPid[pid] = { panel = nil, map = {} }
  end
  return hf.byPid[pid]
end

local function destroyPanel(pid)
  local st = stateOf(pid)
  if st.panel ~= nil and BlzDestroyFrame ~= nil then
    BlzDestroyFrame(st.panel)
  end
  st.panel = nil
  st.map = {}
end

local function hideFrame(pid)
  local st = stateOf(pid)
  if st.panel ~= nil and BlzFrameSetVisible ~= nil then
    BlzFrameSetVisible(st.panel, false)
  end
end

-- Mot the: nut bam lam nen, ben trong co icon, ten, vai.
local function buildCard(pid, parent, hero, x)
  local card = BlzCreateFrameByType("GLUEBUTTON", "HeroCard", parent,
                                    CFG.FRAME_BUTTON_TEMPLATE, pid)
  if card == nil then return nil end

  BlzFrameSetSize(card, CFG.CARD_W, CFG.CARD_H)
  BlzFrameSetPoint(card, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, x, 0.0)

  if hero.icon ~= nil then
    local ic = BlzCreateFrameByType("BACKDROP", "HeroCardIcon", card, "", pid)
    if ic ~= nil then
      BlzFrameSetSize(ic, CFG.CARD_ICON, CFG.CARD_ICON)
      BlzFrameSetPoint(ic, FRAMEPOINT_TOP, card, FRAMEPOINT_TOP,
                       0.0, -CFG.CARD_H * 0.10)
      BlzFrameSetTexture(ic, hero.icon, 0, true)
    end
  end

  if BlzFrameSetText ~= nil then
    local nameLbl = BlzCreateFrameByType("TEXT", "HeroCardName", card, "", pid)
    if nameLbl ~= nil then
      BlzFrameSetPoint(nameLbl, FRAMEPOINT_TOP, card, FRAMEPOINT_TOP,
                       0.0, -(CFG.CARD_H * 0.10 + CFG.CARD_ICON + 0.010))
      BlzFrameSetText(nameLbl, CFG.C_GOLD .. hero.name .. CFG.C_END)
    end
    if hero.role ~= nil then
      local roleLbl = BlzCreateFrameByType("TEXT", "HeroCardRole", card, "", pid)
      if roleLbl ~= nil then
        BlzFrameSetPoint(roleLbl, FRAMEPOINT_TOP, card, FRAMEPOINT_TOP,
                         0.0, -(CFG.CARD_H * 0.10 + CFG.CARD_ICON + 0.030))
        BlzFrameSetText(roleLbl, CFG.C_GREY .. hero.role .. CFG.C_END)
      end
    end
  end

  return card
end

-- Chay tren MOI may. Bang dung giong het nhau khap noi; chi khac o chuyen
-- hien cho ai -- do la UI, khong phai trang thai game, nen dung
-- GetLocalPlayer o day la an toan.
local function buildPanel(pid, list)
  local st = stateOf(pid)
  destroyPanel(pid)

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  local n = #list
  local totalW = n * CFG.CARD_W + (n - 1) * CFG.CARD_GAP

  st.panel = BlzCreateFrameByType("BACKDROP", "HeroPanel", parent, "", pid)
  if st.panel == nil then return false end
  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.CARD_X, CFG.CARD_Y)
  BlzFrameSetSize(st.panel, totalW + 0.03, CFG.CARD_H + 0.05)
  BlzFrameSetTexture(st.panel, CFG.FRAME_BG, 0, true)

  if BlzFrameSetText ~= nil then
    local title = BlzCreateFrameByType("TEXT", "HeroPanelTitle", st.panel, "", pid)
    if title ~= nil then
      BlzFrameSetPoint(title, FRAMEPOINT_TOP, st.panel, FRAMEPOINT_TOP, 0.0, -0.008)
      BlzFrameSetText(title, CFG.PICK_TITLE)
    end
  end

  st.map = {}
  local made = 0
  local step = CFG.CARD_W + CFG.CARD_GAP
  local firstX = -(totalW - CFG.CARD_W) * 0.5

  for i = 1, n do
    local card = buildCard(pid, st.panel, list[i], firstX + (i - 1) * step)
    if card ~= nil then
      BlzTriggerRegisterFrameEvent(S.hframe.trig, card, FRAMEEVENT_CONTROL_CLICK)
      -- Ghi SO THU TU trong CFG.HEROES, khong phai id: kenh dong bo chi
      -- tai duoc so nho. Xem src/02b_sync.lua.
      st.map[card] = { pid = pid, idx = API.heroIndex(list[i].id) }
      made = made + 1
    end
  end

  API.trace("herocard: pid " .. pid .. " -- tao " .. made .. "/" .. n .. " the")
  if made == 0 then
    API.msg(nil, CFG.C_RED .. "herocard: khong tao duoc the nao -- thu doi " ..
      "CFG.FRAME_BUTTON_TEMPLATE." .. CFG.C_END)
    destroyPanel(pid)
    return false
  end

  BlzFrameSetVisible(st.panel, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.panel, true)
  end
  return true
end

local function showFrame(pid)
  if not framesAvailable() then
    API.msg(pid, CFG.C_GOLD .. "The chon hero khong ve duoc -- lui ve popup chu."
      .. CFG.C_END)
    return API.showPicker(pid)
  end

  local d = S.p[pid]
  if d == nil or not d.active then return false end
  if CFG.HERO_MAX_PER_PLAYER > 0 and d.heroCount >= CFG.HERO_MAX_PER_PLAYER then
    hideFrame(pid)
    return false
  end

  local list = API.heroesAvailable()
  if #list == 0 then
    hideFrame(pid)
    API.msg(pid, CFG.C_RED .. "Khong con hero nao de chon." .. CFG.C_END)
    return false
  end

  return buildPanel(pid, list)
end

-- CHI chay tren may nguoi bam.
local function onCardClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  local hit = nil
  for _, st in pairs(S.hframe.byPid) do
    if st.map[f] ~= nil then hit = st.map[f]; break end
  end
  if hit == nil then return end
  if hit.idx == nil then return end
  if GetLocalPlayer() ~= Player(hit.pid) then return end

  -- Khong doi gi o day. Chi bao cho moi may biet.
  API.syncSend(hit.pid, CFG.OP_HERO, hit.idx)
end

-- Chay tren MOI may, tu kenh dong bo. Day la cho duy nhat duoc phep doi
-- trang thai game.
local function onPicked(pid, idx)
  local h = CFG.HEROES[idx]
  if h == nil then return end
  API.applyHeroPick(pid, h.id)
end

local function startHeroFrame()
  S.hframe = { trig = nil, syncTrig = nil, byPid = {} }
  if CFG.HERO_PICK_MODE ~= "frame" then return end
  if not framesAvailable() then
    API.msg(nil, CFG.C_RED .. "Khong ve duoc the chon hero tren ban nay -- " ..
      "se dung popup chu." .. CFG.C_END)
    return
  end

  S.hframe.trig = CreateTrigger()
  TriggerAddAction(S.hframe.trig, onCardClick)

  API.syncOn(CFG.OP_HERO, onPicked)
  API.trace("herocard: trigger san sang, dong bo=" .. API.syncMode())
end

API.showHeroFrame  = showFrame
API.hideHeroFrame  = hideFrame
API.startHeroFrame = startHeroFrame
