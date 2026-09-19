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
-- 5 tu 2026-09-19: them dong TU CHINH. Moi hinh hoc khac suy ra tu day
-- (chieu cao khung, vi tri hai nut duoi), nen doi mot so nay la du.
local ROWS   = 5        -- so dong chu cua the Tong Quan

local TAB_OVERVIEW = 1
local TAB_QUESTS   = 2

-- Mot hang nhiem vu phu: chu ben trai, nut ben phai.
-- 4 hang x 0.030 = 0.120, vua trong bodyH() = 0.124. The I va the II
-- dung chung than bang nen KHONG duoc cao hon no.
-- 1 dong dau (LINE) + 4 hang x QROW = 0.021 + 0.100 = 0.121, vua trong
-- bodyH() = 0.124. The I va the II dung chung than bang nen KHONG duoc
-- cao hon no.
local QROW   = 0.025
local QBTN_H = 0.021

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

  -- Hang duoi chia doi: GOI DOT ben trai, VE NHA ben phai.
  --
  -- VE NHA nam o the TONG QUAN chu khong o the Nhiem Vu Phu, du no sinh
  -- ra cho phan pho ban: the Tong Quan la the mo mac dinh, nen dat o day
  -- moi dung nghia "dung duoc moi luc".
  local cw = W - 2 * P()
  st.call = button("GameCall", P(), top + ROWS * LINE + GAP,
                   cw * 0.62, BTN_H)
  st.home = button("GameHome", P() + cw * 0.64, top + ROWS * LINE + GAP,
                   cw * 0.36, BTN_H)

  -- ----- Than the II: nhiem vu phu -----
  --
  -- Dung SAN ca bon hang. Dung theo so luong luc chay thi doi
  -- CFG.SIDE_QUESTS la phai dung lai khung -- ma khung chi dung mot lan.
  -- DONG DAU: Tu Vi HIEN TAI cua nguoi choi.
  --
  -- Thieu dong nay thi nut chi noi "can Nguyen Anh" ma khong noi minh
  -- dang o dau -- nguoi choi biet DICH nhung khong biet minh cach no
  -- bao xa, va the la khong biet bao gio moi lam duoc.
  st.quests = label("GameQuests", bg, P(), top, W - 2 * P(),
                    CFG.PANEL_SCALE_NAME, false)

  st.quest = {}
  local qw = W - 2 * P()
  for i = 1, #(CFG.SIDE_QUESTS or {}) do
    local qy = top + LINE + (i - 1) * QROW
    st.quest[i] = {
      lbl = label("GameQName" .. i, bg, P(), qy + 0.005, qw * 0.58,
                  CFG.PANEL_SCALE_NAME, false),
      btn = button("GameQBtn" .. i, P() + qw * 0.60, qy, qw * 0.40, QBTN_H),
    }
  end

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
  API.warn(pid, "gameframe: dung bang loi, xem file vet.")

  local st = stateOf(pid)
  if st ~= nil and st.root ~= nil and BlzDestroyFrame ~= nil then
    BlzDestroyFrame(st.root)
  end
  if st ~= nil then st.root = nil end
  return false
end

-- ---------- Ve lai ----------

-- ---------- Nhiem vu phu ----------

local function realmName(r)
  local t = CFG.REALMS and CFG.REALMS[r]
  return (t ~= nil) and API.pick(t) or tostring(r)
end

-- BA ly do khoa, va moi ly do phai NOI RA duoc. Mot nut xam khong giai
-- thich thi nguoi choi tuong giao dien hong -- cung bai hoc voi nut
-- "CHO Kim Dan" o the Trang Bi.
local function questState(pid, i)
  local q = (CFG.SIDE_QUESTS or {})[i]
  if q == nil then return nil, nil end
  local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
  if rank < q.rank then return "rank", q end
  if API.findRegion(q.arrive) == nil then return "norgn", q end
  return "ok", q
end

local function fillQuests(pid, st)
  for i = 1, #(st.quest or {}) do
    local w = st.quest[i]
    local why, q = questState(pid, i)
    local on = (q ~= nil)
    show(w.lbl, on)
    if w.btn ~= nil then show(w.btn.btn, on) end
    if on then
      -- Canh gioi yeu cau nam o NHAN, luon hien -- ke ca khi da mo
      -- khoa. Chi hien luc khoa thi nguoi choi khong the lap ke hoach:
      -- muon biet con sau can gi phai doi toi luc bi chan moi biet.
      BlzFrameSetText(w.lbl, (why == "ok" and CFG.C_GOLD or CFG.C_GREY)
        .. API.t("sq_title", i, API.pick(q), realmName(q.rank)) .. CFG.C_END)
      if w.btn ~= nil and w.btn.txt ~= nil then
        local txt
        if why == "ok" then
          txt = API.t("sq_go")
        elseif why == "norgn" then
          -- Day la loi cua NGUOI LAM MAP, khong phai cua nguoi choi --
          -- nen to mau do chu khong xam.
          txt = CFG.C_RED .. API.t("sq_norgn") .. CFG.C_END
        else
          txt = CFG.C_GREY .. API.t("sq_locked") .. CFG.C_END
        end
        BlzFrameSetText(w.btn.txt, txt)
        if BlzFrameSetEnable ~= nil then
          BlzFrameSetEnable(w.btn.btn, why == "ok")
        end
      end
    end
  end
end

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
  if st.home ~= nil then
    show(st.home.btn, isOverview)
    if st.home.txt ~= nil then
      BlzFrameSetText(st.home.txt, API.t("sq_home"))
    end
  end
  show(st.quests, not isOverview)

  -- Bon hang nhiem vu. Chi hien o the II.
  for i = 1, #(st.quest or {}) do
    local q = st.quest[i]
    show(q.lbl, not isOverview)
    if q.btn ~= nil then show(q.btn.btn, not isOverview) end
  end
  if not isOverview then fillQuests(pid, st) end

  if not isOverview then
    show(st.quests, true)
    if #(CFG.SIDE_QUESTS or {}) == 0 then
      BlzFrameSetText(st.quests, CFG.C_GREY .. API.t("game_quests_soon") .. CFG.C_END)
    else
      local cur = (API.cultRank ~= nil) and API.cultRank(pid) or 1
      BlzFrameSetText(st.quests, CFG.C_GREY .. API.t("sq_head") .. " " ..
        CFG.C_GOLD .. realmName(cur) .. CFG.C_END ..
        CFG.C_GREY .. string.format("  (%d/%d)", cur, #(CFG.REALMS or {})) ..
        CFG.C_END)
    end
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

  -- TU CHINH dang chay. Dong chat luc vao dot troi mat sau vai giay, ma
  -- tu chinh keo dai CA DOT -- nen no phai co mot cho tra cuu duoc.
  -- Xem labelNow() trong 5_modifier.lua.
  if API.modifierLabel ~= nil then
    local name, desc = API.modifierLabel()
    if name ~= nil then
      BlzFrameSetText(st.row[5], CFG.C_GOLD .. name .. CFG.C_END ..
        "  " .. CFG.C_GREY .. (desc or "") .. CFG.C_END)
    else
      BlzFrameSetText(st.row[5], "")
    end
  else
    BlzFrameSetText(st.row[5], "")
  end

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
    if want then
      -- Don khung chat khi MO bang.
      --
      -- Frame tu tao deu la con cua ORIGIN_FRAME_GAME_UI, ma khung chat
      -- cua Warcraft ve DE LEN lop do -- khong co cach nao dua backdrop
      -- len tren no, nen "lam overlay day hon" khong giai duoc gi.
      --
      -- ClearTextMessages() la native CHI dung giao dien, khong doi
      -- trang thai nao -- goi trong nhanh cuc bo nay la an toan.
      if ClearTextMessages ~= nil then ClearTextMessages() end
    end
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
      for i = 1, #(st.quest or {}) do
        local w = st.quest[i]
        if w.btn ~= nil and f == w.btn.btn then
          -- Bam nut la viec CUC BO (frame click chi no o may nguoi bam),
          -- ma dich chuyen la doi trang thai -- nen chi GUI y dinh. Ben
          -- nhan chay tren moi may va kiem lai du dieu kien.
          API.syncSend(pid, CFG.OP_SIDEQUEST, i)
          return
        end
      end

      if st.home ~= nil and f == st.home.btn then
        API.syncSend(pid, CFG.OP_GO_HOME, 0)
        return
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

-- ---------- Nhan tu kenh dong bo: dich chuyen toi vung nhiem vu ----------
--
-- Chay tren MOI may. KIEM LAI du dieu kien o day chu khong tin cu bam:
-- ben gui la cuc bo, mot may go trang thai van phai khong lam gi duoc.
local function onSideQuest(pid, i)
  local why, q = questState(pid, i)
  if q == nil then return end

  if why == "rank" then
    local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
    API.msg(pid, CFG.C_RED .. API.t("sq_need", realmName(q.rank),
                                    realmName(rank)) .. CFG.C_END)
    return
  end
  if why == "norgn" then
    local nm = API.regionLabel(q.arrive)
    API.msg(pid, CFG.C_RED .. API.t("sq_missing", nm) .. CFG.C_END)
    API.trace("sidequest: thieu vung " .. nm .. " -- chay `python w3region.py gen`")
    return
  end

  local d = S.p[pid]
  if d == nil or d.hero == nil or not API.alive(d.hero) then return end

  local r = API.findRegion(q.arrive)
  local cx, cy = API.regionCenter(r)
  local x, y = API.heroFanPoint(pid, cx, cy, CFG.HERO_SPAWN_OFFSET)
  SetUnitPosition(d.hero, x, y)
  -- Pet di theo, nhu o cong dich chuyen ve nha chinh.
  if d.pet ~= nil then SetUnitPosition(d.pet, x, y) end
  if PanCameraToTimedForPlayer ~= nil then
    PanCameraToTimedForPlayer(Player(pid), x, y, 0.0)
  end

  -- Nap chi so cho con boss NGAY LUC NAY: do doi o day moi dung, luc
  -- sinh (vao map) ca doi con o canh gioi 1.
  if API.sideQuestArm ~= nil then API.sideQuestArm(i) end

  API.say(pid, API.t("sq_entered",
    CFG.C_JADE .. API.pick(q) .. CFG.C_END))
  API.trace("sidequest: pid " .. pid .. " -> nhiem vu " .. i)
end

-- Dua hero (va pet) ve nha chinh. Dung chung duong voi cong
-- HeroMoveRegion o 1_house.lua -- mot cong thuc xoe quanh diem, nen
-- khoang cach giua cac hero luon giong nhau du ve bang duong nao.
local function onGoHome(pid, _)
  local d = S.p[pid]
  if d == nil or d.hero == nil or not API.alive(d.hero) then return end
  local r = API.findRegion(CFG.RGN_HOUSE)
  if r == nil then
    API.regionMissing("CFG.RGN_HOUSE", API.regionLabel(CFG.RGN_HOUSE))
    return
  end
  local cx, cy = API.regionCenter(r)
  local x, y = API.heroFanPoint(pid, cx, cy, CFG.HERO_SPAWN_OFFSET)
  SetUnitPosition(d.hero, x, y)
  if d.pet ~= nil then SetUnitPosition(d.pet, x, y) end
  if PanCameraToTimedForPlayer ~= nil then
    PanCameraToTimedForPlayer(Player(pid), x, y, 0.0)
  end

  -- Bao CA DOI. Ai dang o dau la thong tin chung: mot nguoi ve nha giua
  -- luot boss thi ca doi nen biet minh dang thieu mot tay.
  API.say(pid, API.t("sq_wenthome"))
  API.trace("gohome: pid " .. pid)
end

local function startGameFrame()
  S.gameUI   = {}
  S.gameTrig = CreateTrigger()
  TriggerAddAction(S.gameTrig, onClick)
  API.syncOn(CFG.OP_WAVE_CALL, onCall)
  API.syncOn(CFG.OP_SIDEQUEST, onSideQuest)
  API.syncOn(CFG.OP_GO_HOME,   onGoHome)
  bindKey()
  API.trace("gameframe: san sang")
end

API.goHome           = onGoHome
API.gameFrameShow    = showFrame
API.gameFrameHide    = hideFrame
API.gameFrameShown   = isShown
API.gameFrameToggle  = toggle
API.gameFrameRefresh = refreshAll
API.startGameFrame   = startGameFrame
