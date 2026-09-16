-- ============================================================
--  2_heroframe.lua  --  Bang chon hero, mot cot doc
--
--  Dung khi CFG.HERO_PICK_MODE = "frame". Moi hero MOT DONG rong bang
--  ca bang: icon ben trai, ten + vai o tren, ba gach mo ta o duoi.
--
--  VI SAO DOC CHU KHONG PHAI BA THE NGANG.
--
--  Frame chu cua Warcraft KHONG tu xuong dong, va text frame khong dat
--  kich thuoc thi bi can giua quanh diem neo. The ngang rong 0.17 nghia
--  la moi dong mo ta dai hon chung ay tran ra hai ben va de len chu cua
--  the ben canh -- chu cang dai vung de cang rong, nen loi luc co luc
--  khong. No con ep 'mota' phai ngan 3-4 tu, mot rang buoc sinh ra tu
--  han che ky thuat chu khong tu thiet ke.
--
--  Dong rong bang ca bang thi chu luon co cho. Ba cho khac cung sua
--  theo: nen dung template co vien that thay cho o mau phang, chu co
--  ba co de co phan cap, va nhip doc SUY RA tu co icon/co chu chu khong
--  go tay.
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
    { "FRAMEPOINT_LEFT",              FRAMEPOINT_LEFT },
    { "FRAMEPOINT_TOPLEFT",           FRAMEPOINT_TOPLEFT },
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

-- ---------- Hinh hoc ----------

-- Cao mot dong: SUY RA tu co icon va hai dong chu, khong go tay.
--
-- Truoc day chieu cao la mot hang so trong CFG con vi tri tung dong chu
-- la ba con so roi rac (y, y+0.018, y+0.040). Doi co chu mot cai la ca
-- ba lech het, va do dung la loi bang phim E da dinh mot lan.
local function rowH()
  local text = 2 * CFG.CARD_LINE + 0.006
  local h = (text > CFG.CARD_ICON) and text or CFG.CARD_ICON
  return h + 2 * CFG.CARD_PAD
end

-- Vien trang tri cua backdrop an mat mot phan mep trong. CARD_PAD 0.010
-- khong du, nen tieu de leo len dung duong vien vang.
local function titleTop()
  return CFG.CARD_BORDER + CFG.CARD_PAD
end

local function headH()
  return titleTop() + CFG.CARD_LINE * CFG.CARD_SCALE_TITLE + 0.008
end

-- ---------- Mot dong chu ----------

-- Neo TRAI vao mot o co be ngang THAT.
--
-- Phai dat be ngang: text frame khong co kich thuoc thi Warcraft can
-- giua no quanh diem neo, va chu dai thi tran deu ca hai ben. Co o roi
-- thi BlzFrameSetTextAlignment moi ep duoc ve mep trai.
local function textLine(pid, parent, name, x, y, w, scale, text)
  local f = BlzCreateFrameByType("TEXT", name, parent, "", pid)
  if f == nil then return nil end

  BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, x, -y)
  BlzFrameSetSize(f, w, CFG.CARD_LINE)
  if BlzFrameSetTextAlignment ~= nil
     and TEXT_JUSTIFY_TOP ~= nil and TEXT_JUSTIFY_LEFT ~= nil then
    BlzFrameSetTextAlignment(f, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
  end
  API.frameScale(f, scale)
  BlzFrameSetText(f, text)
  API.frameDead(f)
  return f
end

-- ---------- Mot dong hero ----------
--
--   [icon]  Ten      Vai - Vai tro
--           manh 1  |  manh 2  |  DIEM YEU
local function buildRow(pid, parent, hero, dy)
  local row = BlzCreateFrameByType("GLUEBUTTON", "HeroRow", parent,
                                   CFG.CARD_BUTTON_TEMPLATE, pid)
  if row == nil then return nil end

  local P = CFG.CARD_PAD
  BlzFrameSetSize(row, CFG.CARD_W, rowH())
  BlzFrameSetPoint(row, FRAMEPOINT_TOP, parent, FRAMEPOINT_TOP, 0.0, -dy)

  if hero.icon ~= nil then
    local ic = BlzCreateFrameByType("BACKDROP", "HeroRowIcon", row, "", pid)
    if ic ~= nil then
      BlzFrameSetSize(ic, CFG.CARD_ICON, CFG.CARD_ICON)
      BlzFrameSetPoint(ic, FRAMEPOINT_LEFT, row, FRAMEPOINT_LEFT, P, 0.0)
      BlzFrameSetTexture(ic, hero.icon, 0, true)
      API.frameDead(ic)
    end
  end

  if BlzFrameSetText == nil then return row end

  local x = P + CFG.CARD_ICON + P
  local w = CFG.CARD_W - x - P

  -- Ten va vai nam tren CUNG mot frame. Gop chuoi thi khoi phai do be
  -- ngang cua ten de biet dat vai o dau -- ma do be ngang chu thi
  -- Warcraft khong co native nao lam duoc.
  local head = CFG.C_GOLD .. hero.name .. CFG.C_END
  if hero.role ~= nil then
    head = head .. "   " .. CFG.C_GREY .. hero.role .. CFG.C_END
  end
  textLine(pid, row, "HeroRowName", x, P, w, CFG.CARD_SCALE_NAME, head)

  -- Ba gach noi thanh MOT dong. Gach cuoi luon la diem yeu nen to do --
  -- do la thu duy nhat lam nguoi choi phai nghi xem nen chon con nao.
  local list = (API.lang() == "en" and hero.mota_en) or hero.mota
  if list ~= nil and #list > 0 then
    local parts = {}
    for i = 1, #list do
      local mau = (i == #list) and CFG.C_RED or CFG.C_JADE
      parts[i] = mau .. list[i] .. CFG.C_END
    end
    textLine(pid, row, "HeroRowDesc", x, P + CFG.CARD_LINE + 0.006, w,
             CFG.CARD_SCALE_DESC,
             table.concat(parts, CFG.C_GREY .. "  |  " .. CFG.C_END))
  end

  return row
end

-- ---------- Ca bang ----------

-- Chay tren MOI may. Bang dung giong het nhau khap noi; chi khac o chuyen
-- hien cho ai -- do la UI, khong phai trang thai game, nen dung
-- GetLocalPlayer o day la an toan.
local function buildPanel(pid, list)
  local st = stateOf(pid)
  destroyPanel(pid)

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  local n  = #list
  local P  = CFG.CARD_PAD
  local H  = rowH()
  local hd = headH()

  local bg, how = API.backdrop(CFG.CARD_BACKDROP, parent, pid, CFG.FRAME_BG)
  st.panel = bg
  if st.panel == nil then return false end

  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.CARD_X, CFG.CARD_Y)
  BlzFrameSetSize(st.panel, CFG.CARD_W + 2 * P,
                  hd + n * H + (n - 1) * CFG.CARD_GAP + P)

  if BlzFrameSetText ~= nil then
    local title = BlzCreateFrameByType("TEXT", "HeroPanelTitle", st.panel, "", pid)
    if title ~= nil then
      -- Neo TRAI vao mot o co be ngang THAT roi can giua bang
      -- SetTextAlignment -- dung ly do da ghi o textLine(). Neo bang
      -- FRAMEPOINT_TOP ma khong dat kich thuoc thi Warcraft can frame
      -- quanh diem neo, va frameScale lai phong quanh TAM, nen mep tren
      -- troi len tren diem neo. Cong voi vien backdrop la chu de len
      -- duong vien vang.
      BlzFrameSetPoint(title, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT,
                       P, -titleTop())
      -- CHIA cho ti le phong. BlzFrameSetScale phong quanh DIEM NEO chu
      -- khong quanh tam: neo TOPLEFT thi o chu no sang phai va xuong
      -- duoi. Dat be ngang 0.360 roi phong 1.25 la o thanh 0.450, va chu
      -- can giua trong o do lech phai 0.045 -- khoang 81 px o 1080p.
      --
      -- Cac dong hero khong lo chuyen nay vi chung can TRAI: o rong hon
      -- thi chu van dung yen. Chi can GIUA moi lo ra loi.
      BlzFrameSetSize(title, CFG.CARD_W / CFG.CARD_SCALE_TITLE, CFG.CARD_LINE)
      if BlzFrameSetTextAlignment ~= nil
         and TEXT_JUSTIFY_TOP ~= nil and TEXT_JUSTIFY_CENTER ~= nil then
        BlzFrameSetTextAlignment(title, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
      end
      API.frameScale(title, CFG.CARD_SCALE_TITLE)
      BlzFrameSetText(title, CFG.C_GOLD .. API.t("pick_title") .. CFG.C_END)
      API.frameDead(title)
    end
  end

  st.map = {}
  local made = 0
  for i = 1, n do
    local row = buildRow(pid, st.panel, list[i], hd + (i - 1) * (H + CFG.CARD_GAP))
    if row ~= nil then
      BlzTriggerRegisterFrameEvent(S.hframe.trig, row, FRAMEEVENT_CONTROL_CLICK)
      -- Ghi SO THU TU trong CFG.HEROES, khong phai id: kenh dong bo chi
      -- tai duoc so nho. Xem src/1_nen/3_sync.lua.
      st.map[row] = { pid = pid, idx = API.heroIndex(list[i].id) }
      made = made + 1
    end
  end

  API.trace("herocard: pid " .. pid .. " -- tao " .. made .. "/" .. n ..
            " dong, nen = " .. tostring(how))
  if made == 0 then
    API.msg(nil, CFG.C_RED .. "herocard: khong tao duoc dong nao -- thu doi " ..
      "CFG.CARD_BUTTON_TEMPLATE." .. CFG.C_END)
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
API.startHeroFrame = startHeroFrame
