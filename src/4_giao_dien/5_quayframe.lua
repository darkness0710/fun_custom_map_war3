-- ============================================================
--  5_quayframe.lua  --  Khung Co Duyen: BA COT DOC
--
--  Mo NGAY khi tinh anh/boss chet, khong phai mot the trong bang.
--  Ba cot dat canh nhau, moi cot la MOT the bam duoc -- kieu chon loi
--  cua TFT.
--
--  KHONG DONG BANG ESC. Phai chon mot the moi di tiep. Do la ly do
--  bindEsc() trong 1_panel.lua hoi API.quayFrameDangMo(pid) truoc khi
--  lam gi: neu khung nay dang mo thi ESC khong dong ma cung khong mo
--  bang nhan vat.
--
--  Khung nay khong sinh ngau nhien: the da duoc rut o 10_quay.lua, tu
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

local function cotW()
  return (W - 2 * PAD - 2 * GAP) / 3
end

local function khungH()
  return PAD + HEAD_H + GAP + COT_H + PAD
end

local function stateOf(pid)
  if S.quayUI == nil then S.quayUI = {} end
  if S.quayUI[pid] == nil then
    S.quayUI[pid] = { root = nil, cot = {}, shown = false }
  end
  return S.quayUI[pid]
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
  BlzFrameSetAbsPoint(bg, FRAMEPOINT_CENTER, CFG.QUAY_X, CFG.QUAY_Y)
  BlzFrameSetSize(bg, W, khungH())

  -- Chu: chia ti le phong ca toa do lan kich thuoc -- cung bai hoc voi
  -- text() cua bang nhan vat, BlzFrameSetScale phong luon khoang cach
  -- toi diem neo cua cha.
  local function chu(ten, cha, dx, dy, w, scale, giua)
    local t = BlzCreateFrameByType("TEXT", ten, cha, "", pid)
    if t == nil then return nil end
    local s = scale or 1.0
    BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, cha, FRAMEPOINT_TOPLEFT,
                     dx / s, -(dy / s))
    BlzFrameSetSize(t, w / s, 0.016 / s)
    if BlzFrameSetTextAlignment ~= nil then
      BlzFrameSetTextAlignment(t, TEXT_JUSTIFY_TOP,
        giua and TEXT_JUSTIFY_CENTER or TEXT_JUSTIFY_LEFT)
    end
    API.frameScale(t, s)
    API.frameDead(t)
    return t
  end

  st.tieuDe = chu("QuayTitle", bg, PAD, PAD, W - 2 * PAD,
                  CFG.PANEL_SCALE_HEAD, true)

  local cw   = cotW()
  local topY = PAD + HEAD_H + GAP

  for i = 1, 3 do
    local x = PAD + (i - 1) * (cw + GAP)
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
    BlzTriggerRegisterFrameEvent(S.quayTrig, c.btn, FRAMEEVENT_CONTROL_CLICK)

    -- Vien + ruot, cung cach bang nhan vat ve nut: hai o mau dac long
    -- nhau. Backdrop 9 o (EscMenuBackdrop) co goc khong co lai theo
    -- frame nen khong dung duoc cho o nho.
    local d = CFG.PANEL_BTN_BORDER or 0.0016
    local function o(ten, dx, dy, w2, h2, tex)
      local f = BlzCreateFrameByType("BACKDROP", ten, c.btn, "", pid)
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

    c.ten = chu("QuayTen" .. i, c.btn, 0.004, 0.016 + ICON_H + 0.012,
                cw - 0.008, CFG.PANEL_SCALE_NAME, true)
    c.mota = chu("QuayMota" .. i, c.btn, 0.004, 0.016 + ICON_H + 0.038,
                 cw - 0.008, CFG.PANEL_SCALE_SUB, true)

    st.cot[i] = c
  end

  BlzFrameSetVisible(bg, false)
  API.trace("quayframe: dung khung pid " .. pid)
  return true
end

-- ---------- Ve lai ----------

local function refresh(pid)
  local st = stateOf(pid)
  if st.root == nil then return end
  local the = API.quayThe(pid)
  if the == nil then return end

  BlzFrameSetText(st.tieuDe, CFG.C_GOLD .. API.t("quay_tieude") .. CFG.C_END ..
    "   " .. CFG.C_GREY .. API.t("quay_con", API.num(API.quaySoLuot(pid))) ..
    CFG.C_END)

  for i = 1, 3 do
    local c = st.cot[i]
    local t = the[i]
    if c ~= nil and t ~= nil then
      if c.icon ~= nil then
        BlzFrameSetTexture(c.icon, API.quayIcon(t.loai) or "", 0, true)
      end
      BlzFrameSetText(c.ten,  CFG.C_GOLD .. API.quayMoTa(t) .. CFG.C_END)
      BlzFrameSetText(c.mota, CFG.C_GREY .. API.t("quay_the_" .. t.loai) ..
                              CFG.C_END)
    end
  end
end

-- ---------- Bat / tat ----------

local function hienThi(pid, want)
  local st = stateOf(pid)
  if st.root == nil then return end
  st.shown = want
  BlzFrameSetVisible(st.root, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.root, want)
  end
end

local function showFrame(pid)
  if not API.quayConLuot(pid) then return end
  if not build(pid) then return end
  refresh(pid)
  hienThi(pid, true)
end

local function hideFrame(pid)
  hienThi(pid, false)
end

local function refreshFrame(pid)
  refresh(pid)
end

-- Bang nhan vat hoi ham nay truoc khi xu ly ESC.
local function dangMo(pid)
  local st = S.quayUI and S.quayUI[pid] or nil
  return st ~= nil and st.shown == true
end

-- ---------- Bam ----------

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end
  for pid, st in pairs(S.quayUI or {}) do
    if GetLocalPlayer() == Player(pid) and st.shown then
      for i = 1, 3 do
        if st.cot[i] ~= nil and f == st.cot[i].btn then
          -- Nha tieu diem ban phim, neu khong frame giu phim va ESC
          -- khong toi duoc trigger nua -- cung loi da dinh o bang.
          if BlzFrameSetEnable ~= nil then
            BlzFrameSetEnable(f, false); BlzFrameSetEnable(f, true)
          end
          API.syncSend(pid, CFG.OP_QUAY, i)
          return
        end
      end
    end
  end
end

local function startQuayFrame()
  S.quayUI   = {}
  S.quayTrig = CreateTrigger()
  TriggerAddAction(S.quayTrig, onClick)
  API.trace("quayframe: san sang")
end

API.quayFrameShow    = showFrame
API.quayFrameHide    = hideFrame
API.quayFrameRefresh = refreshFrame
API.quayFrameDangMo  = dangMo
API.startQuayFrame   = startQuayFrame
