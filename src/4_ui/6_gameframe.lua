-- ============================================================
--  6_gameframe.lua  --  Bang tran dau: phim R
--
--  Bang THU HAI. Bang nhan vat (ESC) tra loi "nhan vat toi the nao";
--  bang nay tra loi "tran dau dang the nao".
--
--  HAI THE:
--    I.  Tong Quan     dot may/100, canh gioi, quai con song, NUT GOI DOT
--    II. Nhiem Vu Phu  de trong -- 25 block danh cho phan nay (ADR 0014)
--
--  BA LUAT PHAI GIU, ca ba deu da tung cat du an nay mot lan:
--
--  1. KHONG tu dang ky phim ESC. bindEsc() trong 1_panel.lua la chu so
--     huu ESC duy nhat; no hoi API.gameFrameShown() roi tu quyet dinh.
--     Hai bo dang ky ESC tren cung mot trigger la MOT cu bam no HAI lan
--     -- do la ly do CFG.PANEL_ESC_LOCK ton tai.
--
--  2. PHAI tra tieu diem ban phim sau moi cu bam. GLUEBUTTON giu tieu
--     diem va nuot het phim, nen bam nut goi dot xong thi ESC chet. Tat
--     roi bat lai frame la cach tra o ban 1.31.
--
--  3. GetLocalPlayer CHI dung cho viec HIEN/AN. Moi thay doi trang thai
--     di qua kenh dong bo -- bam nut chi gui CFG.OP_WAVE_CALL, con viec
--     goi dot that su chay tren MOI may.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local W      = 0.46
local PAD    = 0.018
local GAP    = 0.008
local TAB_H  = 0.026
local LINE   = 0.021
local BTN_H  = 0.032
local ROWS   = 4        -- so dong chu cua the Tong Quan

local TAB_OVERVIEW = 1
local TAB_QUESTS   = 2

-- Le trong THAT = le + vien trang tri cua backdrop. Cung bai hoc voi
-- bang nhan vat va khung Co Duyen: dat chu o dung PAD la no nam DE LEN
-- vien go cua EscMenuBackdrop.
local function P()
  return PAD + (CFG.PANEL_BORDER or 0.0)
end

local function bodyH()
  return ROWS * LINE + GAP + BTN_H
end

local function frameH()
  return P() + TAB_H + GAP + bodyH() + P()
end

local function stateOf(pid)
  if S.gameUI == nil then S.gameUI = {} end
  if S.gameUI[pid] == nil then
    S.gameUI[pid] = { root = nil, tab = TAB_OVERVIEW, row = {}, tabBtn = {},
                      shown = false }
  end
  return S.gameUI[pid]
end

local function show(f, on)
  if f ~= nil then BlzFrameSetVisible(f, on) end
end

-- ---------- Dung khung ----------

local function buildBody(pid)
  local st = stateOf(pid)
  if st.root ~= nil then return true end
  if BlzGetOriginFrame == nil or BlzCreateFrameByType == nil then return false end

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  local bg = API.backdrop(CFG.PANEL_BACKDROP, parent, pid, CFG.FRAME_BG)
  if bg == nil then return false end
  st.root = bg
  BlzFrameSetAbsPoint(bg, FRAMEPOINT_CENTER, CFG.GAME_X, CFG.GAME_Y)
  BlzFrameSetSize(bg, W, frameH())

  -- Chu: CHIA ca toa do lan kich thuoc cho ti le phong.
  -- BlzFrameSetScale phong luon KHOANG CACH toi diem neo cua cha, nen
  -- khong chia thi moi dong co ti le khac 1.0 deu bi keo ve goc tren
  -- trai -- dung loi da lam vo bo cuc bang nhan vat mot lan.
  local function label(name, parentF, dx, dy, w, scale, center)
    local t = BlzCreateFrameByType("TEXT", name, parentF, "", pid)
    if t == nil then return nil end
    local s = scale or 1.0
    BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, parentF, FRAMEPOINT_TOPLEFT,
                     dx / s, -(dy / s))
    BlzFrameSetSize(t, w / s, LINE / s)
    if BlzFrameSetTextAlignment ~= nil then
      BlzFrameSetTextAlignment(t, TEXT_JUSTIFY_TOP,
        center and TEXT_JUSTIFY_CENTER or TEXT_JUSTIFY_LEFT)
    end
    API.frameScale(t, s)
    API.frameDead(t)
    return t
  end

  local function button(name, x, y, w, h)
    local b = BlzCreateFrameByType("GLUEBUTTON", name, bg,
                                   CFG.FRAME_BUTTON_TEMPLATE, pid)
    if b == nil then return nil end
    BlzFrameSetSize(b, w, h)
    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, bg, FRAMEPOINT_TOPLEFT, x, -y)
    BlzTriggerRegisterFrameEvent(S.gameTrig, b, FRAMEEVENT_CONTROL_CLICK)

    -- Vien + ruot: hai o mau dac long nhau. Backdrop 9 o co goc khong co
    -- lai theo frame nen khong dung duoc cho nut nho.
    local d = CFG.PANEL_BTN_BORDER or 0.0016
    local function fill(nm, dx, dy, w2, h2, tex)
      local f = BlzCreateFrameByType("BACKDROP", nm, b, "", pid)
      if f == nil then return end
      BlzFrameSetSize(f, w2, h2)
      BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, b, FRAMEPOINT_TOPLEFT, dx, -dy)
      BlzFrameSetTexture(f, tex, 0, true)
      API.frameDead(f)
    end
    fill(name .. "E", 0.0, 0.0, w, h, CFG.PANEL_BTN_EDGE)
    fill(name .. "F", d, d, w - 2 * d, h - 2 * d, CFG.PANEL_BTN_FILL)

    local txt = label(name .. "T", b, 0.0, (h - 0.012) * 0.5, w,
                      CFG.PANEL_SCALE_NAME, true)
    return { btn = b, txt = txt }
  end

  -- ----- Hai nhan the -----
  local tw = (W - 2 * P() - GAP) * 0.5
  for i = 1, 2 do
    st.tabBtn[i] = button("GameTab" .. i, P() + (i - 1) * (tw + GAP), P(),
                          tw, TAB_H)
  end

  -- ----- Than the I -----
  local top = P() + TAB_H + GAP
  for i = 1, ROWS do
    st.row[i] = label("GameRow" .. i, bg, P(), top + (i - 1) * LINE,
                      W - 2 * P(), CFG.PANEL_SCALE_NAME, false)
  end

  st.call = button("GameCall", P(), top + ROWS * LINE + GAP,
                   W - 2 * P(), BTN_H)

  -- ----- Than the II: mot dong duy nhat -----
  st.quests = label("GameQuests", bg, P(), top + LINE, W - 2 * P(),
                    CFG.PANEL_SCALE_NAME, true)

  BlzFrameSetVisible(bg, false)
  API.trace("gameframe: dung khung pid " .. pid)
  return true
end

-- Boc pcall quanh buildBody(): loi Lua trong callback cua Warcraft khong in ra
-- dau ca, nen khong boc thi mot dong sai o giua bien thanh "bam phim ra
-- cai hop rong" -- khong manh moi nao.
--
-- Hong thi DON RAC. Backdrop da tao la da HIEN; de lai thi nguoi choi
-- co mot cai hop khong dong duoc, va moi lan bam lai them mot cai.
local function build(pid)
  local ok, res = pcall(buildBody, pid)
  if ok and res ~= false then return res end

  API.trace("gameframe: DUNG BANG LOI -- " .. tostring(res))
  API.msg(pid, CFG.C_RED .. "gameframe: dung bang loi, xem file vet." .. CFG.C_END)

  local st = stateOf(pid)
  if st ~= nil and st.root ~= nil and BlzDestroyFrame ~= nil then
    BlzDestroyFrame(st.root)
  end
  if st ~= nil then st.root = nil end
  return false
end

-- ---------- Ve lai ----------

local function refresh(pid)
  local st = stateOf(pid)
  if st.root == nil then return end

  for i = 1, 2 do
    local b = st.tabBtn[i]
    if b ~= nil and b.txt ~= nil then
      local nm = (i == TAB_OVERVIEW) and API.t("game_tab_overview")
                                      or API.t("game_tab_quests")
      BlzFrameSetText(b.txt,
        (i == st.tab and CFG.C_GOLD or CFG.C_GREY) .. nm .. CFG.C_END)
    end
  end

  local isOverview = (st.tab == TAB_OVERVIEW)
  for i = 1, ROWS do show(st.row[i], isOverview) end
  if st.call ~= nil then show(st.call.btn, isOverview) end
  show(st.quests, not isOverview)

  if not isOverview then
    BlzFrameSetText(st.quests, CFG.C_GREY .. API.t("game_quests_soon") .. CFG.C_END)
    return
  end

  -- Moi con so o day doc tu he wave, khong tu tinh lai. Hai cho cung
  -- tinh mot thu thi som muon cung lech.
  local stage = S.stage or 0
  local total = API.totalStages and API.totalStages() or 0
  local r, tier, isBoss = 1, 0, false
  if API.decodeStage ~= nil and stage > 0 then
    r, tier, isBoss = API.decodeStage(stage)
  end

  BlzFrameSetText(st.row[1], CFG.C_GOLD ..
    API.t("game_stage", stage, total) .. CFG.C_END)

  if stage > 0 and API.realmName ~= nil and API.tierLabel ~= nil then
    BlzFrameSetText(st.row[2], API.t("game_realm",
      API.realmName(r), API.tierLabel(stage)))
  else
    BlzFrameSetText(st.row[2], "")
  end

  -- Con may dot nua toi boss. Boss luon la stage cuoi cua canh gioi.
  if stage > 0 and API.stagesPerRealm ~= nil then
    local per  = API.stagesPerRealm()
    local left = per - tier
    if isBoss or left <= 0 then
      BlzFrameSetText(st.row[3], CFG.C_JADE .. API.t("game_atboss") .. CFG.C_END)
    else
      BlzFrameSetText(st.row[3],
        API.t("game_toboss", left, API.realmName(r)))
    end
  else
    BlzFrameSetText(st.row[3], "")
  end

  BlzFrameSetText(st.row[4], CFG.C_GREY ..
    API.t("game_alive", S.alive or 0) .. CFG.C_END)

  if st.call ~= nil and API.waveCallState ~= nil then
    local c = API.waveCallState()
    -- Chu XAM khi khong bam duoc. Vien va ruot la o mau tu ve nen
    -- BlzFrameSetEnable khong doi mau chung -- khong lam gi thi nut bam
    -- duoc va nut mo trong y het nhau.
    BlzFrameSetText(st.call.txt,
      c.on and (CFG.C_GOLD .. c.label .. CFG.C_END)
            or (CFG.C_GREY .. c.label .. CFG.C_END))
    if BlzFrameSetEnable ~= nil then BlzFrameSetEnable(st.call.btn, c.on) end
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

local function isShown(pid)
  local st = S.gameUI and S.gameUI[pid] or nil
  return st ~= nil and st.shown == true
end

local function hideFrame(pid)
  setVisible(pid, false)
end

local function showFrame(pid)
  -- Co Duyen o tren cung: dang phai chon the thi khong mo gi khac.
  if API.fortuneFrameShown ~= nil and API.fortuneFrameShown(pid) then return end
  if not build(pid) then
    API.msg(pid, CFG.C_RED .. API.t("panel_noframe") .. CFG.C_END)
    return
  end
  -- HAI BANG LOAI TRU NHAU. Dong bang nhan vat truoc khi mo bang nay,
  -- neu khong hai backdrop de len nhau va ESC khong biet dong cai nao.
  if API.panelHide ~= nil then API.panelHide(pid) end
  refresh(pid)
  setVisible(pid, true)
end

local function toggle(pid)
  if isShown(pid) then hideFrame(pid) else showFrame(pid) end
end

local function refreshAll()
  for i = 1, #S.pids do
    if isShown(S.pids[i]) then refresh(S.pids[i]) end
  end
end

-- ---------- Bam ----------

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  -- Tra tieu diem ban phim NGAY. GLUEBUTTON giu tieu diem sau khi bam,
  -- va frame giu tieu diem nuot het phim -- khong tra thi bam nut xong
  -- la ESC chet, kieu loi "luc duoc luc khong".
  if BlzFrameSetEnable ~= nil then
    BlzFrameSetEnable(f, false); BlzFrameSetEnable(f, true)
  end

  for pid, st in pairs(S.gameUI or {}) do
    if GetLocalPlayer() == Player(pid) and st.shown then
      for i = 1, 2 do
        if st.tabBtn[i] ~= nil and f == st.tabBtn[i].btn then
          st.tab = i
          refresh(pid)
          return
        end
      end
      if st.call ~= nil and f == st.call.btn then
        -- Chi GUI y dinh. Viec goi dot that chay tren moi may, tu
        -- ham nhan cua kenh dong bo.
        API.syncSend(pid, CFG.OP_WAVE_CALL, 0)
        return
      end
    end
  end
end

-- ---------- Nhan tu kenh dong bo ----------
-- Chay tren MOI may. Ai bam cung duoc -- ba nguoi la dong minh, va bao
-- ra chat ai vua goi la du: voi ba nguoi choi chung thi ap luc xa hoi xu
-- ly viec nay tot hon mot co che "ca ba san sang", ma moi co che la mot
-- cho co the treo.

local function onCall(pid, _)
  if API.waveNow == nil then return end
  if not API.waveNow() then
    refreshAll()
    return
  end
  API.msg(nil, CFG.C_GREY ..
    API.t("wave_called", GetPlayerName(Player(pid))) .. CFG.C_END)

  -- DONG khung o MOI may, khong rieng may nguoi bam.
  --
  -- Hai ly do, ly do sau moi la ly do that:
  --   . bang nay tra loi "tran dau dang the nao" -- goi dot xong thi
  --     cau tra loi nam o ngoai bai chien, khong nam trong bang
  --   . con mo la con bam duoc, ma khe giua "nhan loi goi" va "quai
  --     hien ra" du dai de lot mot cu bam nua
  --
  -- Day la lop thu hai. Lop thu nhat la co S.waveCalling trong
  -- waveNow() -- giao dien mot minh khong du, vi -next khong di qua no.
  for i = 1, #S.pids do hideFrame(S.pids[i]) end
end

-- ---------- Phim R ----------

local function bindKey()
  local name = CFG.GAME_KEY
  if name == nil then
    API.trace("gameframe: CFG.GAME_KEY = nil -- khong co phim mo bang")
    return false
  end
  -- Tra hang so luc GAN phim chu khong nho san: khong phu thuoc thu tu
  -- nap chunk. Cung cach bindKey() cua bang nhan vat lam.
  local key = _G["OSKEY_" .. name]
  if key == nil or BlzTriggerRegisterPlayerKeyEvent == nil then
    API.trace("gameframe: khong gan duoc phim " .. tostring(name))
    return false
  end
  local t = CreateTrigger()
  for i = 1, #S.pids do
    BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), key, 0, true)
  end
  TriggerAddAction(t, function() toggle(GetPlayerId(GetTriggerPlayer())) end)
  API.trace("gameframe: da gan phim " .. name)
  return true
end

local function startGameFrame()
  S.gameUI   = {}
  S.gameTrig = CreateTrigger()
  TriggerAddAction(S.gameTrig, onClick)
  API.syncOn(CFG.OP_WAVE_CALL, onCall)
  bindKey()
  API.trace("gameframe: san sang")
end

API.gameFrameShow    = showFrame
API.gameFrameHide    = hideFrame
API.gameFrameShown   = isShown
API.gameFrameToggle  = toggle
API.gameFrameRefresh = refreshAll
API.startGameFrame   = startGameFrame
