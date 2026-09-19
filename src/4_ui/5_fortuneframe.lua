-- ============================================================
--  5_fortuneframe.lua  --  Khung Co Duyen: MOT COT MOI THE
--
--  Mo NGAY khi tinh anh/boss chet, khong phai mot the trong bang.
--  Cac cot dat canh nhau, moi cot mot the va MOT NUT SELECT ngay duoi.
--
--  VI SAO NUT RIENG, khong bam ca cot nhu truoc: chon the Co Duyen la
--  KHONG HOAN TAC duoc -- bam nham mot cai la mat ca luot. Ba cot sat
--  nhau va phu kin ca khung thi khong co cho nao de "bam hut"; mot nut
--  nho o duoi thi phai co y moi trung. Cung ly do voi bang chon hero.
--
--  SO COT DOC TU CFG.FORTUNE_DRAW, khong go cung. Be ngang khung giu
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
-- The + nut = dung bang chieu cao cot cu (0.185), nen khung KHONG doi
-- kich thuoc: 0.153 + 0.006 + 0.026 = 0.185.
local COT_H  = 0.153    -- cao phan THE (trang tri)
local BTN_H  = 0.026    -- cao nut SELECT
local BTN_GAP = 0.006   -- khe giua the va nut
local BTN_PAD = 0.006   -- nut hep hon the moi ben bay nhieu
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
  -- SO THE RUT RA, khong phai so loai co san. Tu 2026-09-20 co BA loai
  -- ma chi rut HAI -- ve ba cot thi mot cot luon rong.
  local n = CFG.FORTUNE_DRAW or 0
  local avail = CFG.FORTUNE_KINDS and #CFG.FORTUNE_KINDS or 0
  if n <= 0 or n > avail then n = avail end
  return (n > 0) and n or 1
end

local function colW()
  local n = nCol()
  return (W - 2 * P() - (n - 1) * GAP) / n
end

local function frameH()
  return P() + HEAD_H + GAP + COT_H + BTN_GAP + BTN_H + P()
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

    local d = CFG.PANEL_BTN_BORDER or 0.0016

    -- ----- THE: chi trang tri, KHONG bam duoc -----
    c.card = BlzCreateFrameByType("BACKDROP", "QuayCot" .. i, bg, "", pid)
    if c.card == nil then return false end
    BlzFrameSetSize(c.card, cw, COT_H)
    BlzFrameSetPoint(c.card, FRAMEPOINT_TOPLEFT, bg, FRAMEPOINT_TOPLEFT,
                     x, -topY)
    BlzFrameSetTexture(c.card, CFG.PANEL_BTN_EDGE, 0, true)
    API.frameDead(c.card)

    -- Ruot thut vao mot vien, cung cach bang nhan vat ve nut: hai o mau
    -- dac long nhau. Backdrop 9 o (EscMenuBackdrop) co goc khong co lai
    -- theo frame nen khong dung duoc cho o nho.
    local fill = BlzCreateFrameByType("BACKDROP", "QuayFill" .. i, c.card, "", pid)
    if fill ~= nil then
      BlzFrameSetSize(fill, cw - 2 * d, COT_H - 2 * d)
      BlzFrameSetPoint(fill, FRAMEPOINT_TOPLEFT, c.card, FRAMEPOINT_TOPLEFT, d, -d)
      BlzFrameSetTexture(fill, CFG.PANEL_BTN_FILL, 0, true)
      API.frameDead(fill)
    end

    c.icon = BlzCreateFrameByType("BACKDROP", "QuayIcon" .. i, c.card, "", pid)
    if c.icon ~= nil then
      BlzFrameSetSize(c.icon, ICON_H, ICON_H)
      BlzFrameSetPoint(c.icon, FRAMEPOINT_TOP, c.card, FRAMEPOINT_TOP,
                       0.0, -0.014)
      API.frameDead(c.icon)
    end

    c.name = label("QuayTen" .. i, c.card, 0.004, 0.014 + ICON_H + 0.010,
                cw - 0.008, CFG.PANEL_SCALE_NAME, true)
    c.desc = label("QuayMota" .. i, c.card, 0.004, 0.014 + ICON_H + 0.034,
                 cw - 0.008, CFG.PANEL_SCALE_SUB, true)

    -- ----- NUT SELECT rieng cua cot nay -----
    --
    -- NEO VAO BANG (bg), KHONG vao c.card. c.card da di qua frameDead()
    -- -- tuc BlzFrameSetEnable(f, false) -- va nut nam trong mot frame
    -- da TAT thi khong nhan duoc cu bam nao: nhin thi day du, bam thi
    -- chet lang. Bang chon hero da dinh dung loi nay mot lan.
    local bw = cw - 2 * BTN_PAD
    c.btn = BlzCreateFrameByType("GLUEBUTTON", "QuaySel" .. i, bg,
                                 CFG.FRAME_BUTTON_TEMPLATE, pid)
    if c.btn == nil then return false end
    BlzFrameSetSize(c.btn, bw, BTN_H)
    BlzFrameSetPoint(c.btn, FRAMEPOINT_TOPLEFT, bg, FRAMEPOINT_TOPLEFT,
                     x + BTN_PAD, -(topY + COT_H + BTN_GAP))
    BlzTriggerRegisterFrameEvent(S.fortuneTrig, c.btn, FRAMEEVENT_CONTROL_CLICK)

    local function plate(name, dx, dy, w2, h2, tex)
      local f = BlzCreateFrameByType("BACKDROP", name, c.btn, "", pid)
      if f == nil then return end
      BlzFrameSetSize(f, w2, h2)
      BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, c.btn, FRAMEPOINT_TOPLEFT, dx, -dy)
      BlzFrameSetTexture(f, tex, 0, true)
      API.frameDead(f)
    end
    plate("QuaySelEdge" .. i, 0.0, 0.0, bw, BTN_H, CFG.PANEL_BTN_EDGE)
    plate("QuaySelFill" .. i, d, d, bw - 2 * d, BTN_H - 2 * d, CFG.PANEL_BTN_FILL)

    local bt = label("QuaySelTxt" .. i, c.btn, 0.004, (BTN_H - 0.016) * 0.5,
                     bw - 0.008, CFG.PANEL_SCALE_NAME, true)
    if bt ~= nil then
      BlzFrameSetText(bt, CFG.C_GOLD .. API.t("pick_select") .. CFG.C_END)
    end

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

-- ---------- Hieu ung chia bai ----------
--
-- Truoc day doi the giua hai luot la mot cu NHAY: chu va icon doi tai
-- cho trong cung mot khung hinh, khong co gi bao la vua sang luot moi.
-- Co 12 luot lien tiep (Thanh Long) thi no thanh mot cai bang nhay
-- loan.
--
-- Chia tung cot mot, cach nhau FORTUNE_DEAL_STEP giay. Chi dung
-- BlzFrameSetVisible -- khong dung alpha hay scale: hai thu do khong
-- chac co o moi ban, ma mot hieu ung trang tri thi khong dang de lam
-- hong khung.
--
-- KHONG dong bo. No khong doi mot chut trang thai nao, va moi may co
-- khung rieng -- nen chay cuc bo la dung.
local function dealIn(pid)
  local st = stateOf(pid)
  if st.root == nil then return end
  local step = CFG.FORTUNE_DEAL_STEP or 0.10
  if step <= 0.0 or API.after == nil then return end

  for i = 1, #st.col do
    local c = st.col[i]
    if c ~= nil then
      -- An ca cot LAN nut: de lai cai nut khong thi no lo lung mot
      -- minh, nhin ra loi ve chu khong ra hieu ung.
      show(c.card, false); show(c.btn, false)
      API.after(step * i, function()
        -- Kiem lai LUC DEN GIO: nguoi choi co the da dong khung, va
        -- bat lai mot cai the le giua man hinh la mot loi nhin thay
        -- duoc.
        if not st.shown then return end
        show(c.card, true); show(c.btn, true)
      end)
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

  -- DONG BANG NHAN VAT TRUOC.
  --
  -- LOI DA SHIP: dang mo ESC ma tinh anh hoac boss chet thi khung Co
  -- Duyen bat len DE LEN bang -- hai khung cung neo vao
  -- ORIGIN_FRAME_GAME_UI, khong cai nao biet cai nao. Nguoi choi thay
  -- chu chong chit va khong bam duoc gi cho ra hon.
  --
  -- Khung nay la cai bat len KHONG XIN PHEP (tu su kien quai chet), nen
  -- no la ben phai nhuong duong -- chu khong phai bat bang di kiem xem
  -- co khung nao sap bat hay khong.
  if API.panelHide ~= nil then API.panelHide(pid) end

  refresh(pid)
  setVisible(pid, true)
  dealIn(pid)
end

local function hideFrame(pid)
  setVisible(pid, false)
end

local function refreshFrame(pid)
  refresh(pid)
  dealIn(pid)
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
