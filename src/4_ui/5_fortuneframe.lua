-- ============================================================
--  5_fortuneframe.lua  --  Khung Co Duyen: MOT COT MOI THE
--
--  Mo NGAY khi tinh anh/boss chet, khong phai mot the trong bang.
--  Cac cot dat canh nhau, moi cot la MOT the bam duoc -- kieu chon loi
--  cua TFT.
--
--  SO COT DOC TU CFG.FORTUNE_KINDS, khong go cung. Be ngang khung giu
--  nguyen, cot tu chia lai -- them hay bot the khong phai sua file nay.
--
--  KHONG DONG BANG ESC. Phai chon mot the moi di tiep. Do la ly do
--  bindEsc() trong 1_panel.lua hoi API.fortuneFrameShown(pid) truoc khi
--  lam gi: neu khung nay dang mo thi ESC khong dong ma cung khong mo
--  bang nhan vat.
--
--  Khung nay khong sinh ngau nhien: the da duoc rut o 10_fortune.lua, tu
--  su kien quai chet, tren MOI may. O day chi VE lai thu da co.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local W      = 0.46     -- be ngang ca khung
local PAD    = 0.018
local GAP    = 0.010
local HEAD_H = 0.030    -- dong tieu de
local COT_H  = 0.185    -- cao mot cot
local ICON_H = 0.052

-- Le trong THAT = le + vien trang tri cua backdrop.
--
-- EscMenuBackdrop ve mot duong vien go day an vao mep trong. Dat tieu de
-- o dung PAD la no nam DE LEN vien do -- dung loi ma bang nhan vat
-- (CFG.PANEL_BORDER) va the chon hero (CFG.CARD_BORDER) da dinh, moi
-- cai mot lan.
local function P()
  return PAD + (CFG.PANEL_BORDER or 0.0)
end

-- So the mot luot. Doc moi lan chu khong nho: build() chay sau khi CFG
-- da nap xong, va giu mot ban sao cuc bo la mot cho nua co the lech.
local function nCol()
  local n = CFG.FORTUNE_KINDS and #CFG.FORTUNE_KINDS or 0
  return (n > 0) and n or 1
end

local function colW()
  local n = nCol()
  return (W - 2 * P() - (n - 1) * GAP) / n
end

local function frameH()
  return P() + HEAD_H + GAP + COT_H + P()
end

local function stateOf(pid)
  if S.fortuneUI == nil then S.fortuneUI = {} end
  if S.fortuneUI[pid] == nil then
    S.fortuneUI[pid] = { root = nil, col = {}, shown = false }
  end
  return S.fortuneUI[pid]
end

local function show(f, on)
  if f ~= nil then BlzFrameSetVisible(f, on) end
end

-- ---------- Dung khung ----------

local function build(pid)
  local st = stateOf(pid)
  if st.root ~= nil then return true end
  if BlzGetOriginFrame == nil or BlzCreateFrameByType == nil then return false end

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  local bg = API.backdrop(CFG.PANEL_BACKDROP, parent, pid, CFG.FRAME_BG)
  if bg == nil then return false end
  st.root = bg
  BlzFrameSetAbsPoint(bg, FRAMEPOINT_CENTER, CFG.FORTUNE_X, CFG.FORTUNE_Y)
  BlzFrameSetSize(bg, W, frameH())

  -- Chu: chia ti le phong ca toa do lan kich thuoc -- cung bai hoc voi
  -- text() cua bang nhan vat, BlzFrameSetScale phong luon khoang cach
  -- toi diem neo cua cha.
  local function label(name, parent, dx, dy, w, scale, center)
    local t = BlzCreateFrameByType("TEXT", name, parent, "", pid)
    if t == nil then return nil end
    local s = scale or 1.0
    BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT,
                     dx / s, -(dy / s))
    BlzFrameSetSize(t, w / s, 0.016 / s)
    if BlzFrameSetTextAlignment ~= nil then
      BlzFrameSetTextAlignment(t, TEXT_JUSTIFY_TOP,
        center and TEXT_JUSTIFY_CENTER or TEXT_JUSTIFY_LEFT)
    end
    API.frameScale(t, s)
    API.frameDead(t)
    return t
  end

  st.titleF = label("QuayTitle", bg, P(), P(), W - 2 * P(),
                  CFG.PANEL_SCALE_HEAD, true)

  local cw   = colW()
  local topY = P() + HEAD_H + GAP

  for i = 1, nCol() do
    local x = P() + (i - 1) * (cw + GAP)
    local c = {}

    -- CA COT la mot nut. Bam dau trong cot cung duoc, khong phai ngam
    -- vao mot nut nho o duoi -- do la cai lam kieu chon loi cua TFT
    -- bam thay da tay.
    c.btn = BlzCreateFrameByType("GLUEBUTTON", "QuayCot" .. i, bg,
                                 CFG.FRAME_BUTTON_TEMPLATE, pid)
    if c.btn == nil then return false end
    BlzFrameSetSize(c.btn, cw, COT_H)
    BlzFrameSetPoint(c.btn, FRAMEPOINT_TOPLEFT, bg, FRAMEPOINT_TOPLEFT,
                     x, -topY)
    BlzTriggerRegisterFrameEvent(S.fortuneTrig, c.btn, FRAMEEVENT_CONTROL_CLICK)

    -- Vien + ruot, cung cach bang nhan vat ve nut: hai o mau dac long
    -- nhau. Backdrop 9 o (EscMenuBackdrop) co goc khong co lai theo
    -- frame nen khong dung duoc cho o nho.
    local d = CFG.PANEL_BTN_BORDER or 0.0016
    local function o(name, dx, dy, w2, h2, tex)
      local f = BlzCreateFrameByType("BACKDROP", name, c.btn, "", pid)
      if f == nil then return end
      BlzFrameSetSize(f, w2, h2)
      BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, c.btn, FRAMEPOINT_TOPLEFT, dx, -dy)
      BlzFrameSetTexture(f, tex, 0, true)
      API.frameDead(f)
    end
    o("QuayEdge" .. i, 0.0, 0.0, cw, COT_H, CFG.PANEL_BTN_EDGE)
    o("QuayFill" .. i, d, d, cw - 2 * d, COT_H - 2 * d, CFG.PANEL_BTN_FILL)

    c.icon = BlzCreateFrameByType("BACKDROP", "QuayIcon" .. i, c.btn, "", pid)
    if c.icon ~= nil then
      BlzFrameSetSize(c.icon, ICON_H, ICON_H)
      BlzFrameSetPoint(c.icon, FRAMEPOINT_TOP, c.btn, FRAMEPOINT_TOP,
                       0.0, -0.016)
      API.frameDead(c.icon)
    end

    c.name = label("QuayTen" .. i, c.btn, 0.004, 0.016 + ICON_H + 0.012,
                cw - 0.008, CFG.PANEL_SCALE_NAME, true)
    c.desc = label("QuayMota" .. i, c.btn, 0.004, 0.016 + ICON_H + 0.038,
                 cw - 0.008, CFG.PANEL_SCALE_SUB, true)

    st.col[i] = c
  end

  BlzFrameSetVisible(bg, false)
  API.trace("fortuneframe: dung khung pid " .. pid)
  return true
end

-- ---------- Ve lai ----------

local function refresh(pid)
  local st = stateOf(pid)
  if st.root == nil then return end
  local card = API.fortuneCards(pid)
  if card == nil then return end

  BlzFrameSetText(st.titleF, CFG.C_GOLD .. API.t("fortune_title") .. CFG.C_END ..
    "   " .. CFG.C_GREY .. API.t("fortune_left", API.num(API.fortuneRolls(pid))) ..
    CFG.C_END)

  -- Duyet theo SO THE THAT su rut duoc, khong theo so cot: hai so nay
  -- chi lech neu ai do doi CFG giua chung -- nhung lech la mot cot giu
  -- chu cu cua luot truoc, kieu sai im lang.
  for i = 1, #st.col do
    local c = st.col[i]
    local t = card[i]
    if c ~= nil and t ~= nil then
      if c.icon ~= nil then
        BlzFrameSetTexture(c.icon, API.fortuneIcon(t.kind) or "", 0, true)
      end
      BlzFrameSetText(c.name,  CFG.C_GOLD .. API.fortuneLabel(t) .. CFG.C_END)
      BlzFrameSetText(c.desc, CFG.C_GREY .. API.t("fortune_card_" .. t.kind) ..
                              CFG.C_END)
    end
  end
end

-- ---------- Bat / tat ----------

local function setVisible(pid, want)
  local st = stateOf(pid)
  if st.root == nil then return end
  st.shown = want
  BlzFrameSetVisible(st.root, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.root, want)
  end
end

local function showFrame(pid)
  if not API.fortuneHasRolls(pid) then return end
  if not build(pid) then return end
  refresh(pid)
  setVisible(pid, true)
end

local function hideFrame(pid)
  setVisible(pid, false)
end

local function refreshFrame(pid)
  refresh(pid)
end

-- Bang nhan vat hoi ham nay truoc khi xu ly ESC.
local function isShown(pid)
  local st = S.fortuneUI and S.fortuneUI[pid] or nil
  return st ~= nil and st.shown == true
end

-- ---------- Bam ----------

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end
  for pid, st in pairs(S.fortuneUI or {}) do
    if GetLocalPlayer() == Player(pid) and st.shown then
      for i = 1, #st.col do
        if st.col[i] ~= nil and f == st.col[i].btn then
          -- Nha tieu diem ban phim, neu khong frame giu phim va ESC
          -- khong toi duoc trigger nua -- cung loi da dinh o bang.
          if BlzFrameSetEnable ~= nil then
            BlzFrameSetEnable(f, false); BlzFrameSetEnable(f, true)
          end
          API.syncSend(pid, CFG.OP_FORTUNE, i)
          return
        end
      end
    end
  end
end

local function startFortuneFrame()
  S.fortuneUI   = {}
  S.fortuneTrig = CreateTrigger()
  TriggerAddAction(S.fortuneTrig, onClick)
  API.trace("fortuneframe: san sang")
end

API.fortuneFrameShow    = showFrame
API.fortuneFrameHide    = hideFrame
API.fortuneFrameRefresh = refreshFrame
API.fortuneFrameShown  = isShown
API.startFortuneFrame   = startFortuneFrame
