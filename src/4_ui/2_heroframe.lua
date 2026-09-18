-- ============================================================
--  2_heroframe.lua  --  Bang chon hero: MOT COT MOI HERO
--
--  Dung khi CFG.HERO_PICK_MODE = "frame". Ba cot doc dat canh nhau,
--  moi cot mot hero, va MOT nut SELECT chung o duoi -- cung khuon voi
--  khung Co Duyen (5_fortuneframe.lua), khac o cho phai CHON roi moi
--  XAC NHAN.
--
--  NUT CHON NAM TRONG TUNG COT, khong phai mot nut chung o duoi.
--
--  Chon hero la viec KHONG LAM LAI DUOC (CFG.HERO_UNIQUE), nen the
--  khong duoc phep dinh chi vi mot cu cham. Nhung cach chua KHONG phai
--  la "chon truoc, xac nhan sau":
--
--  Trang thai "dang chon" song duoc bao lau thi do la bay nhieu thoi
--  gian de MAT no. Nguoi choi khac lay mot hero -> applyHeroPick goi
--  refreshOthers -> pickerShow -> buildPanel dung lai ca bang, va
--  destroyPanel xoa sach lua chon. Dang dua tay bam thi the nhay cho.
--  Khong sai -- applyHeroPick van chan dung -- nhung nguoi choi thay
--  "tu nhien mat", va do la loi giao dien that.
--
--  Nut rieng trong tung cot thi khong co trang thai nao de mat, ma van
--  chong duoc bam nham: phai trung dung cai nut chu khong phai cham vao
--  the la dinh.
--
--  So cot DOC TU danh sach hero con trong, khong go cung. Bang co ba
--  hero thi ba cot; them hero thu tu la bang tu chia lai.
--
--  DAY LA MODAL. Chua chon xong thi ESC khong mo duoc gi khac de len
--  tren -- cung luat voi khung Co Duyen, va bindEsc() trong 1_panel.lua
--  hoi API.heroFrameShown(pid) truoc tien. Truoc day no khong hoi, nen
--  bam ESC luc dang chon hero la bang nhan vat mo de len va bang chon
--  hero nam ket phia sau.
--
--  Cung hai rang buoc nhu 3_skillframe, va vi cung mot ly do:
--
--  1. Su kien bam frame CHI no tren may nguoi bam. Nen bam khong doi
--     trang thai -- no gui mot mau tin qua API.syncSend (3_sync.lua),
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
    if _G[list[i]] == nil then missing[#missing + 1] = list[i] end
  end
  return missing
end

local function framesAvailable()
  if FRAME_OK ~= nil then return FRAME_OK end
  local missing = checkNatives({
    "BlzGetOriginFrame", "BlzCreateFrameByType", "BlzFrameSetPoint",
    "BlzFrameSetSize", "BlzFrameSetVisible", "BlzFrameSetTexture",
    "BlzTriggerRegisterFrameEvent", "BlzGetTriggerFrame",
  })
  FRAME_OK = (#missing == 0)
  if not FRAME_OK then
    API.trace("herocard: thieu native -- " .. table.concat(missing, " "))
  end
  return FRAME_OK
end

-- ---------- Hinh hoc ----------
--
-- Moi con so SUY RA tu co icon va co chu, khong go tay. Doi
-- CFG.CARD_SCALE_DESC mot cai ma phai sua bon hang so roi rac la kieu
-- loi bang phim E da dinh mot lan.

-- Doc tu CFG chu khong go o day: ba con so nay la num de chinh bo cuc,
-- va moi con so chinh duoc phai nam mot cho.
local function W()      return CFG.CARD_W end
local function GAP()    return CFG.CARD_GAP end
local function ICON_H() return CFG.CARD_ICON end
local BTN_H   = 0.026   -- nut CHON trong moi cot
local HEAD_H  = 0.030   -- dong tieu de
local DESC_N  = 3       -- so gach mo ta ve duoc trong mot cot

-- Le trong THAT = le + vien trang tri cua backdrop.
--
-- EscMenuBackdrop ve mot duong vien go day an vao mep trong. Dat chu o
-- dung PAD la no nam DE LEN vien do -- dung loi ma bang nhan vat
-- (PANEL_BORDER), the chon hero cu (CARD_BORDER) va khung Co Duyen da
-- dinh, moi cai mot lan.
local function P()
  return CFG.CARD_PAD + (CFG.CARD_BORDER or 0.0)
end

local function colW(n)
  if n < 1 then n = 1 end
  return (W() - 2 * P() - (n - 1) * GAP()) / n
end

-- Cao phan NOI DUNG cua mot cot: icon + ten + vai + DESC_N gach.
local function bodyH()
  local line = CFG.CARD_LINE
  return CFG.CARD_PAD + ICON_H() + 0.010      -- icon
       + line * CFG.CARD_SCALE_NAME + 0.004   -- ten
       + line + 0.006                         -- vai
       + DESC_N * (line + 0.003)              -- ba gach
end

-- Ca cot = noi dung + nut CHON o duoi.
local function colH()
  return bodyH() + 0.006 + BTN_H + CFG.CARD_PAD
end

local function frameH()
  return P() + HEAD_H + GAP() + colH() + P()
end

local function stateOf(pid)
  local hf = S.hframe
  if hf.byPid[pid] == nil then
    hf.byPid[pid] = { panel = nil, col = {}, map = {}, shown = false }
  end
  return hf.byPid[pid]
end

local function destroyPanel(pid)
  local st = stateOf(pid)
  if st.panel ~= nil and BlzDestroyFrame ~= nil then
    BlzDestroyFrame(st.panel)
  end
  st.panel = nil
  st.col   = {}
  st.map   = {}
  st.shown = false
end

local function hideFrame(pid)
  local st = stateOf(pid)
  if st.panel ~= nil and BlzFrameSetVisible ~= nil then
    BlzFrameSetVisible(st.panel, false)
  end
  st.shown = false
end

-- Bang nhan vat hoi ham nay truoc khi xu ly ESC.
local function isShown(pid)
  local hf = S.hframe
  if hf == nil or hf.byPid == nil then return false end
  local st = hf.byPid[pid]
  return st ~= nil and st.shown == true
end

-- ---------- Mot dong chu ----------

-- Neo TRAI vao mot o co be ngang THAT.
--
-- Phai dat be ngang: text frame khong co kich thuoc thi Warcraft can
-- giua no quanh diem neo, va chu dai thi tran deu ca hai ben. Co o roi
-- thi BlzFrameSetTextAlignment moi ep duoc.
--
-- CHIA cho ti le phong, CA TOA DO lan kich thuoc -- BlzFrameSetScale
-- phong luon khoang cach tu frame toi diem neo cua cha, nen frame dat
-- cach cha x se duoc ve o x * scale.
local function textLine(pid, parent, name, x, y, w, scale, center)
  local f = BlzCreateFrameByType("TEXT", name, parent, "", pid)
  if f == nil then return nil end
  local s = scale or 1.0
  BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT,
                   x / s, -(y / s))
  BlzFrameSetSize(f, w / s, CFG.CARD_LINE / s)
  if BlzFrameSetTextAlignment ~= nil
     and TEXT_JUSTIFY_TOP ~= nil and TEXT_JUSTIFY_CENTER ~= nil
     and TEXT_JUSTIFY_LEFT ~= nil then
    BlzFrameSetTextAlignment(f, TEXT_JUSTIFY_TOP,
      center and TEXT_JUSTIFY_CENTER or TEXT_JUSTIFY_LEFT)
  end
  API.frameScale(f, scale)
  API.frameDead(f)
  return f
end

-- ---------- Mot cot ----------
--
--        [icon]
--         Hart
--    Warrior - Tanker
--     Don quai dong
--     Chiu don khoe
--    Yeu truoc boss      <- gach cuoi luon la DIEM YEU, to do
local function buildCol(pid, parent, hero, x, cw)
  local c = {}
  local H = colH()
  local d = CFG.PANEL_BTN_BORDER or 0.0016

  -- COT KHONG PHAI LA NUT nua -- chi la mot cai khung. Bam vao than the
  -- khong lam gi ca; chi cai nut o duoi moi an. Do la phan chong bam
  -- nham, va no re hon han mot buoc xac nhan rieng.
  --
  -- Vien + ruot: hai o mau dac long nhau. Backdrop 9 o (EscMenuBackdrop)
  -- co goc khong co lai theo frame nen khong dung duoc cho o nho. Chi
  -- hai texture TeamColor04/27 la DA CHUNG MINH ve ra hinh.
  local function plate(name, parentF, dx, dy, w2, h2, tex)
    local f = BlzCreateFrameByType("BACKDROP", name, parentF, "", pid)
    if f == nil then return nil end
    BlzFrameSetSize(f, w2, h2)
    BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, parentF, FRAMEPOINT_TOPLEFT,
                     dx, -dy)
    BlzFrameSetTexture(f, tex, 0, true)
    API.frameDead(f)
    return f
  end

  c.root = plate("HeroColEdge", parent, x, P() + HEAD_H + GAP(), cw, H,
                 CFG.PANEL_BTN_EDGE)
  if c.root == nil then return nil end
  plate("HeroColFill", c.root, d, d, cw - 2 * d, H - 2 * d,
        CFG.PANEL_BTN_FILL)

  if hero.icon ~= nil then
    local ic = BlzCreateFrameByType("BACKDROP", "HeroColIcon", c.root, "", pid)
    if ic ~= nil then
      BlzFrameSetSize(ic, ICON_H(), ICON_H())
      BlzFrameSetPoint(ic, FRAMEPOINT_TOP, c.root, FRAMEPOINT_TOP,
                       0.0, -CFG.CARD_PAD)
      BlzFrameSetTexture(ic, hero.icon, 0, true)
      API.frameDead(ic)
    end
  end

  if BlzFrameSetText == nil then return c end

  local line = CFG.CARD_LINE
  local tw   = cw - 2 * 0.004
  local y    = CFG.CARD_PAD + ICON_H() + 0.010

  local nm = textLine(pid, c.root, "HeroColName", 0.004, y, tw,
                      CFG.CARD_SCALE_NAME, true)
  BlzFrameSetText(nm, CFG.C_GOLD .. hero.name .. CFG.C_END)
  y = y + line * CFG.CARD_SCALE_NAME + 0.004

  if hero.role ~= nil then
    local r = textLine(pid, c.root, "HeroColRole", 0.004, y, tw,
                       CFG.CARD_SCALE_DESC, true)
    BlzFrameSetText(r, CFG.C_GREY .. hero.role .. CFG.C_END)
  end
  y = y + line + 0.006

  -- MOT GACH MOT DONG. Cot hep nen noi ba gach lam mot dong la tran ra
  -- ngoai -- text frame cua Warcraft KHONG tu xuong dong, chu thua chi
  -- de len cot ben canh.
  --
  -- Gach cuoi luon la diem yeu nen to do: do la thu duy nhat lam nguoi
  -- choi phai nghi xem nen chon con nao.
  local list = (API.lang() == "en" and hero.desc_en) or hero.desc_vi
  if list ~= nil then
    for i = 1, DESC_N do
      local txt = list[i]
      if txt ~= nil then
        local color = (i == #list) and CFG.C_RED or CFG.C_JADE
        local f = textLine(pid, c.root, "HeroColDesc" .. i, 0.004, y, tw,
                           CFG.CARD_SCALE_DESC, true)
        BlzFrameSetText(f, color .. txt .. CFG.C_END)
      end
      y = y + line + 0.003
    end
  end

  -- ---------- Nut CHON cua rieng cot nay ----------
  --
  -- NEO VAO BANG, KHONG vao c.root. c.root la mot o trang tri, ma moi o
  -- trang tri deu di qua frameDead() -- tuc BlzFrameSetEnable(f, false).
  -- Nut nam trong mot frame da bi TAT thi khong nhan duoc cu bam nao:
  -- nhin thi day du, bam thi chet lang.
  --
  -- Da dinh that o ban truoc: ba cot ve ra dep, nut CHON khong an.
  local bw = cw - 2 * CFG.CARD_PAD
  c.btn = BlzCreateFrameByType("GLUEBUTTON", "HeroColBtn", parent,
                               CFG.CARD_BUTTON_TEMPLATE, pid)
  if c.btn == nil then return c end
  BlzFrameSetSize(c.btn, bw, BTN_H)
  BlzFrameSetPoint(c.btn, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT,
                   x + CFG.CARD_PAD,
                   -(P() + HEAD_H + GAP() + bodyH() + 0.006))

  plate("HeroBtnEdge", c.btn, 0.0, 0.0, bw, BTN_H, CFG.PANEL_BTN_EDGE)
  plate("HeroBtnFill", c.btn, d, d, bw - 2 * d, BTN_H - 2 * d,
        CFG.PANEL_BTN_FILL)

  local bt = textLine(pid, c.btn, "HeroColBtnTxt", 0.004,
                      (BTN_H - line) * 0.5, bw - 0.008,
                      CFG.CARD_SCALE_NAME, true)
  if bt ~= nil then
    BlzFrameSetText(bt, CFG.C_GOLD .. API.t("pick_select") .. CFG.C_END)
  end

  return c
end



-- ---------- Ca bang ----------

-- Chay tren MOI may. Bang dung giong het nhau khap noi; chi khac o chuyen
-- hien cho ai -- do la UI, khong phai trang thai game, nen dung
-- GetLocalPlayer o day la an toan.
local function buildPanel(pid, list)
  local st = stateOf(pid)
  destroyPanel(pid)
  st.list = list

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  local n  = #list
  local cw = colW(n)

  local bg, how = API.backdrop(CFG.CARD_BACKDROP, parent, pid, CFG.FRAME_BG)
  st.panel = bg
  if st.panel == nil then return false end

  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.CARD_X, CFG.CARD_Y)
  BlzFrameSetSize(st.panel, W(), frameH())

  if BlzFrameSetText ~= nil then
    local t = textLine(pid, st.panel, "HeroPanelTitle", P(), P(),
                       W() - 2 * P(), CFG.CARD_SCALE_TITLE, true)
    if t ~= nil then
      BlzFrameSetText(t, CFG.C_GOLD .. API.t("pick_title") .. CFG.C_END)
    end
  end

  local made = 0
  for i = 1, n do
    local c = buildCol(pid, st.panel, list[i], P() + (i - 1) * (cw + GAP()), cw)
    if c ~= nil and c.btn ~= nil then
      BlzTriggerRegisterFrameEvent(S.hframe.trig, c.btn, FRAMEEVENT_CONTROL_CLICK)
      -- Ghi SO THU TU trong CFG.HEROES, khong phai id: kenh dong bo chi
      -- tai duoc so nho. Xem src/1_core/3_sync.lua.
      st.map[c.btn] = { pid = pid, idx = API.heroIndex(list[i].id) }
      st.col[i] = c
      made = made + 1
    end
  end

  API.trace("herocard: pid " .. pid .. " -- tao " .. made .. "/" .. n ..
            " cot, nen = " .. tostring(how))
  if made == 0 then
    API.msg(nil, CFG.C_RED .. "herocard: khong tao duoc cot nao -- thu doi " ..
      "CFG.CARD_BUTTON_TEMPLATE." .. CFG.C_END)
    destroyPanel(pid)
    return false
  end

  st.shown = true
  BlzFrameSetVisible(st.panel, false)
  if GetLocalPlayer() == Player(pid) then
    BlzFrameSetVisible(st.panel, true)
  end
  return true
end

local function showFrame(pid)
  if not framesAvailable() then
    API.msg(pid, CFG.C_GOLD .. "Bang chon hero khong ve duoc -- lui ve popup chu."
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

-- ---------- Bam ----------
--
-- CHI chay tren may nguoi bam.
local function onCardClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  -- Tra tieu diem ban phim NGAY. GLUEBUTTON giu tieu diem sau khi bam,
  -- va frame giu tieu diem thi nuot het phim.
  if BlzFrameSetEnable ~= nil then
    BlzFrameSetEnable(f, false); BlzFrameSetEnable(f, true)
  end

  for pid, st in pairs(S.hframe.byPid) do
    if GetLocalPlayer() == Player(pid) and st.shown then
      local pick = st.map[f]
      if pick ~= nil and pick.idx ~= nil then
        -- Khong doi gi o day. Chi bao cho moi may biet -- va
        -- applyHeroPick ben kia van kiem lai mot lan nua, vi hai nguoi
        -- co the bam cung mot con trong cung mot nhip.
        API.syncSend(pid, CFG.OP_HERO, pick.idx)
        return
      end
    end
  end
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
    API.msg(nil, CFG.C_RED .. "Khong ve duoc bang chon hero tren ban nay -- " ..
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
API.heroFrameShown = isShown
API.startHeroFrame = startHeroFrame
