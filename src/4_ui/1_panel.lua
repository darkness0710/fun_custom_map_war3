-- ============================================================
--  1_panel.lua  --  Bang nhan vat (phim R -- xem CFG.PANEL_KEY)
--
--  MOT khung, bon the. Moi he tu dang ky noi dung cua minh qua
--  API.panelAddTab -- khung khong biet gi ve Linh Can hay Ky Nang.
--
--  HAI KIEU THAN BANG, khong phai mot.
--
--  Ban truoc chi co mot kieu: bang tinh hang x o, moi the tu khai bao
--  cot cua no, va mot nut "+" rong 0.028 o mep phai. Bon he thi khong
--  cung hinh dang, nen ep ca bon vao bang tinh lam cai nao cung do:
--
--    Linh Can  la mot cai thang co DUNG MOT hanh dong (dot pha len bac
--              ke). Bang tinh hien 7 dong, ma 6 dong khong bam duoc --
--              thong tin tham khao chen cho dung mot viec lam duoc.
--    Ky Nang   la 7 mon nang cap doc lap. Nam cot chia 680px thi cot
--              "Bac" con 81px, va chu dai tran sang cot ben.
--    Trang Bi  6 mon, Phap Khi 5 mon -- cung hinh dang voi Ky Nang.
--
--  Nen: "list" (3/4 the) va "focus" (1/4 the). The khai bao DU LIEU,
--  bang lo BO CUC -- nguoc han ban truoc, noi the phai khai bao cot.
--
--  Nho vay them mot he moi khong phai dung them bang, cung khong phai
--  do be ngang cot: tra ve mot danh sach muc la xong.
--
--  Mo/dong va doi the la UI THUAN -> lam cuc bo duoc, khong can dong
--  bo. Chi HANH DONG (dot pha, nang cap, mua) moi phai qua
--  BlzSendSyncData, va do la viec cua tung he.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local TAB_H  = 0.026
local HEAD_H = 0.022    -- dong tien
-- KHONG CON NUT CLOSE. Dong bang ESC, hoac bam lai phim mo bang.
--
-- Nut cu nam o chan khung va bam khong an: thanh giao dien duoi cua
-- Warcraft phu khoang 0.12 duoi man hinh va an TREN frame cua ta, nen
-- no nuot cu bam truoc khi toi duoc nut. Frame bi che mot phan van
-- "nhin thay duoc" nen nhin thi khong ra loi.
--
-- Doi len dinh khung thi het loi, nhung mot phim ESC van gon hon mot
-- cai nut phai ram chuot toi -- va ESC la thu nguoi choi bam theo phan
-- xa de dong bat cu thu gi. Nen bo han nut, giu mot dong chu nho chi
-- cho biet bam gi.
local GAP    = 0.006
local LINE   = 0.016    -- khoang cach hai dong chu trong mot muc

-- Cao than bang o kieu "focus". Bang phai CAO BANG NHAU o moi the,
-- neu khong doi the mot cai la khung nhay -- nen lay max voi kieu list.
local FOCUS_H = 0.200

-- ---------- Than kieu "grid": o trang bi xep quanh hinh nguoi ----------
--
-- Doc tu the dang ky (tab.slots), khong go tay: doi CFG.GEAR_SLOTS la
-- bang tu co theo, y het cach MAX_ITEMS doc so dong tu the dai nhat.
local GRID_SLOTS = nil
local GRID_COLS, GRID_ROWS = 0, 0
local CELL_GAP = 0.008

-- Mot o = icon o tren, nut Upgrade ngay duoi.
local function cellH()  return ICON() + 0.004 + BTN_H() end
local function rowStep() return cellH() + CELL_GAP end

local function gridH()
  if GRID_ROWS <= 0 then return 0.0 end
  return GRID_ROWS * rowStep() - CELL_GAP
end

-- Le trong THAT = le + vien trang tri cua backdrop. Moi thu ben trong
-- dung con so nay, nen doi backdrop chi phai sua mot cho.
local function PAD()   return CFG.PANEL_PAD + (CFG.PANEL_BORDER or 0.0) end
local function ROW()   return CFG.PANEL_ROW end
local function ICON()  return CFG.PANEL_ICON end
local function BTN_W() return CFG.PANEL_BTN_W end
local function BTN_H() return CFG.PANEL_BTN_H end

-- Bao nhieu dong phai dung san. Tinh tu the dai nhat da dang ky, chu
-- khong go tay: them mot he 9 muc thi bang tu no rong ra.
local MAX_ITEMS = 1

-- Than bang cao bang the CAO NHAT trong ba kieu. Bang phai cao bang
-- nhau o moi the, neu khong doi the mot cai la khung nhay.
local function bodyH()
  local h = MAX_ITEMS * ROW()
  if FOCUS_H > h then h = FOCUS_H end
  local g = gridH()
  if g > h then h = g end
  return h
end

local function panelH()
  return PAD() + TAB_H + GAP + HEAD_H + GAP + bodyH() + PAD()
end

local function tabTop()
  return PAD()
end

local function bodyTop()
  return tabTop() + TAB_H + GAP + HEAD_H + GAP
end

-- Be ngang phan chu cua mot muc: tru icon ben trai va nut ben phai.
local function textW()
  return CFG.PANEL_W - 2 * PAD() - ICON() - 0.008 - BTN_W() - 0.008
end

-- So La Ma cho nhan the: I. Linh Can, II. Ky Nang, ...
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII" }

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
--
-- kind = "list":
--   items(pid) -> { { icon, name, desc, status, btn, btnOn }, ... }
--   itemAction(pid, i)
--   empty  -- chu hien khi items rong
--
-- kind = "focus":
--   info(pid) -> { title, sub, row = { {lbl, before, after}, ... },
--                  progress (0..1), note, btn, btnOn }
--   action(pid)
--
-- kind = "grid":
--   slots    -- { {cot, dong}, ... } mot cap cho moi o, dung thu tu items
--   items(pid) -> nhu "list", dung them:
--                   short  -- ten ngan, cho bang thong ke ben phai
--                   stat   -- mon nay dang cong gi
--   itemAction(pid, i)
--   statHead -- tieu de cot thong ke

local function addTab(tab)
  if tab.kind == nil then tab.kind = "list" end
  S.panel.tabs[#S.panel.tabs + 1] = tab
  return #S.panel.tabs
end

-- The chua lam: hien ro la chua lam thay vi de trong. Mot the trong
-- khien nguoi choi tuong giao dien hong.
local function placeholderTab(name, desc)
  return {
    name   = name,
    kind  = "list",
    items = function() return {} end,
    empty = CFG.C_GREY .. API.t("panel_empty") .. CFG.C_END .. "  " .. desc,
  }
end

-- ---------- Trang thai ----------

local function stateOf(pid)
  if S.panel.byPid[pid] == nil then
    S.panel.byPid[pid] = { panel = nil, money = nil, tabBtn = {},
                           item = {}, focus = nil,
                           tab = 1, shown = false }
  end
  return S.panel.byPid[pid]
end

-- ---------- Ve lai ----------

local function setEnabled(f, on)
  if f ~= nil and BlzFrameSetEnable ~= nil then BlzFrameSetEnable(f, on) end
end

local function show(f, on)
  if f ~= nil then BlzFrameSetVisible(f, on) end
end

local function refreshList(st, pid, tab)
  local items = (tab.items and tab.items(pid)) or {}

  for i = 1, MAX_ITEMS do
    local it = items[i]
    local w  = st.item[i]
    if w ~= nil then
      local has = (it ~= nil)
      show(w.bg, has and (i % 2 == 0))
      show(w.name, has)
      show(w.state, has)
      show(w.sub, has)
      show(w.icon, has and it.icon ~= nil)
      show(w.btn, has and it.btn ~= nil)

      if has then
        if it.icon ~= nil then BlzFrameSetTexture(w.icon, it.icon, 0, true) end
        BlzFrameSetText(w.name,  CFG.C_GOLD .. (it.name or "?") .. CFG.C_END)
        BlzFrameSetText(w.state, it.status or "")
        BlzFrameSetText(w.sub,   CFG.C_GREY .. (it.desc or "") .. CFG.C_END)
        if it.btn ~= nil then
          -- Chu XAM khi khong du tien. Vien va ruot la o mau tu ve nen
          -- BlzFrameSetEnable khong doi mau chung -- khong lam gi thi
          -- nut bam duoc va nut mo trong y het nhau.
          BlzFrameSetText(w.btnTxt, (it.btnOn ~= false) and it.btn
                                    or (CFG.C_GREY .. it.btn .. CFG.C_END))
          -- Nut mo di khi khong du tien: van THAY duoc gia, chi khong
          -- bam duoc. An han nut thi nguoi choi khong biet mon do ton
          -- bao nhieu de ma de danh.
          setEnabled(w.btn, it.btnOn ~= false)
        end
      end
    end
  end

  -- Dong "chua co gi" cho the giu cho.
  show(st.empty, #items == 0)
  if #items == 0 and st.empty ~= nil then
    BlzFrameSetText(st.empty, tab.empty or "")
  end
end

local function refreshFocus(st, pid, tab)
  local f = st.focus
  if f == nil then return end
  local d = (tab.info and tab.info(pid)) or {}

  BlzFrameSetText(f.titleF, CFG.C_GOLD .. (d.title or "") .. CFG.C_END)
  BlzFrameSetText(f.sub,    CFG.C_JADE .. (d.sub or "") .. CFG.C_END)

  local row = d.row or {}
  for i = 1, #f.row do
    local r = f.row[i]
    local v = row[i]
    show(r.alt, v ~= nil)
    show(r.lbl, v ~= nil)
    show(r.before, v ~= nil)
    show(r.after, v ~= nil)
    if v ~= nil then
      BlzFrameSetText(r.lbl,  CFG.C_GREY .. (v[1] or "") .. CFG.C_END)
      BlzFrameSetText(r.before, v[2] or "")
      -- Mui ten nam trong cung frame voi gia tri sau, de khong phai do
      -- be ngang cua gia tri truoc moi biet dat mui ten o dau.
      BlzFrameSetText(r.after,   CFG.C_GREY .. "->  " .. CFG.C_END ..
                               CFG.C_JADE .. (v[3] or "") .. CFG.C_END)
    end
  end

  local p = d.progress or 0.0
  if p < 0.0 then p = 0.0 elseif p > 1.0 then p = 1.0 end
  local full = CFG.PANEL_W - 2 * PAD()
  -- NEN phai hien -- backdropFrame() tao ra o trang thai an, va truoc
  -- day khong ai bat no len. Ket qua: chi thay o vang cua phan da day,
  -- lo lung khong ro no la thanh gi. Mot thanh tien do khong co nen thi
  -- khong phai thanh tien do.
  show(f.barBg, true)
  -- Be ngang 0 lam frame hong; an han di thay vi dat kich thuoc 0.
  show(f.barFill, p > 0.01)
  if p > 0.01 then BlzFrameSetSize(f.barFill, full * p, 0.010) end

  BlzFrameSetText(f.note, CFG.C_GREY .. (d.note or "") .. CFG.C_END)

  show(f.btn, d.btn ~= nil)
  if d.btn ~= nil then
    BlzFrameSetText(f.btnTxt, (d.btnOn ~= false) and d.btn
                              or (CFG.C_GREY .. d.btn .. CFG.C_END))
    setEnabled(f.btn, d.btnOn ~= false)
  end
end

-- Ve lai luoi trang bi. Hai nua: o ben trai, bang thong ke ben phai --
-- cung mot nguon du lieu (tab.items) nen khong the lech nhau.
local function refreshGrid(st, pid, tab)
  local g = st.grid
  if g == nil or g.root == nil then return end
  local items = (tab.items and tab.items(pid)) or {}

  if g.statHead ~= nil then
    BlzFrameSetText(g.statHead, CFG.C_GOLD .. (tab.statHead or "") .. CFG.C_END)
  end

  for i = 1, #g.cell do
    local it, c = items[i], g.cell[i]
    local has = (it ~= nil)
    local hasBtn = has and it.btn ~= nil
    show(c.edge, has)
    show(c.icon, has and it.icon ~= nil)
    show(c.btn,  hasBtn)
    -- Co nut thi khong co chu, va nguoc lai -- hai thu dung CHUNG mot
    -- cho nen bat ca hai la chung de len nhau.
    show(c.note, has and not hasBtn)
    if has then
      if it.icon ~= nil then BlzFrameSetTexture(c.icon, it.icon, 0, true) end
      if not hasBtn and c.note ~= nil then
        BlzFrameSetText(c.note, CFG.C_GREY .. (it.note or "") .. CFG.C_END)
      end
      if it.btn ~= nil then
        -- Cung quy uoc voi kieu "list": khong du tien thi chu XAM chu
        -- khong an nut -- an di la nguoi choi khong biet mon do ton bao
        -- nhieu de ma de danh.
        BlzFrameSetText(c.btnTxt, (it.btnOn ~= false) and it.btn
                                  or (CFG.C_GREY .. it.btn .. CFG.C_END))
        setEnabled(c.btn, it.btnOn ~= false)
      end
    end
  end

  for i = 1, #g.stat do
    local it, w = items[i], g.stat[i]
    local has = (it ~= nil)
    show(w.alt, has); show(w.lbl, has); show(w.val, has)
    if has then
      BlzFrameSetText(w.lbl, CFG.C_GREY .. (it.short or it.name or "?") .. CFG.C_END)
      -- 'stat' da mang mau cua chinh no tu 5_gear.lua. Boc them mot lop
      -- mau o day la loi mau LONG NHAU: Warcraft khong co ngan xep mau,
      -- mot |r dong het ca hai va phan con lai cua dong mat mau.
      BlzFrameSetText(w.val, it.stat or "")
    end
  end
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
      local nm = (ROMAN[i] or i) .. ". " .. S.panel.tabs[i].name
      BlzFrameSetText(t.txt,
        (i == st.tab and CFG.C_GOLD or CFG.C_GREY) .. nm .. CFG.C_END)
    end
  end

  if st.money ~= nil then
    local money = {
      { API.t("panel_qi"), API.getQi(pid),  CFG.C_JADE },
      { API.t("panel_gold"),    API.getGold(pid),     CFG.C_GOLD },
      { API.t("panel_lumber"),      API.getLumber(pid),       CFG.C_GOLD },
      { API.t("panel_iron"),      API.getIron(pid),       CFG.C_GREY },
    }
    for i = 1, #money do
      local m = st.money[i]
      if m ~= nil then
        BlzFrameSetText(m.lbl, CFG.C_GREY .. money[i][1] .. CFG.C_END)
        BlzFrameSetText(m.amt,   money[i][3] .. API.num(money[i][2]) .. CFG.C_END)
      end
    end
  end

  local kind   = tab.kind or "list"
  local isList = (kind == "list")

  -- Dong cua kieu "list" dung san o MOI the, nen the khac phai tat het
  -- chung di truoc -- neu khong the Trang Bi se co bay dong ma cu nam
  -- de duoi luoi.
  if not isList then
    for i = 1, MAX_ITEMS do
      local w = st.item[i]
      if w ~= nil then
        show(w.bg, false); show(w.icon, false); show(w.name, false)
        show(w.state, false); show(w.sub, false); show(w.btn, false)
      end
    end
    show(st.empty, false)
  end
  if st.focus ~= nil then show(st.focus.root, kind == "focus") end
  if st.grid  ~= nil then show(st.grid.root,  kind == "grid")  end

  if kind == "focus" then
    refreshFocus(st, pid, tab)
  elseif kind == "grid" then
    refreshGrid(st, pid, tab)
  else
    refreshList(st, pid, tab)
  end
end

local function hide(pid)
  local st = stateOf(pid)
  if st.panel ~= nil then BlzFrameSetVisible(st.panel, false) end
  st.shown = false
end

-- ---------- Dung bang ----------

local function build(pid)
  local st = stateOf(pid)
  if st.panel ~= nil then return true end

  local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
  if parent == nil then return false end

  local P, W = PAD(), CFG.PANEL_W
  local bg, how = API.backdrop(CFG.PANEL_BACKDROP, parent, pid, CFG.FRAME_BG)
  st.panel = bg
  if st.panel == nil then return false end
  BlzFrameSetAbsPoint(st.panel, FRAMEPOINT_CENTER, CFG.PANEL_X, CFG.PANEL_Y)
  BlzFrameSetSize(st.panel, W, panelH())

  -- Mot dong chu neo TRAI (hoac PHAI) vao mot o co be ngang THAT.
  -- Khong dat kich thuoc thi Warcraft can giua chu quanh diem neo va
  -- chu dai tran deu hai ben -- do la loi "chu de len cot ben canh"
  -- cua ban truoc.
  local function text(name, parentF, dx, dy, w, scale, right, h)
    local t = BlzCreateFrameByType("TEXT", name, parentF, "", pid)
    if t == nil then return nil end
    local s = scale or 1.0
    -- CHIA cho ti le phong -- CA TOA DO lan kich thuoc.
    --
    -- Do duoc tu anh chup: BlzFrameSetScale(f, s) khong chi phong hinh
    -- cua f, no phong luon KHOANG CACH tu f toi diem neo cua cha. Mot
    -- frame dat cach cha (dx, dy) voi ti le s se duoc ve o (dx*s, dy*s).
    --
    -- Ban truoc chi bu kich thuoc, nen moi dong chu co ti le khac 1.0
    -- deu bi keo ve goc tren-trai cua cha, va keo cang nhieu khi cang xa
    -- goc. Do la ly do DUY NHAT khien ca bon the vo bo cuc cung mot lan:
    --   dong tien (0.85) -> nhan cot 2 de len so cot 1: "0Insight"
    --   mo ta muc (0.85) -> keo len ngang hang TEN va trat vao icon
    --   ten muc   (1.05) -> day sang phai, roi khoi cot cua no
    --
    -- Kiem lai bang phep cong: cot 3 dang le o 0.3653, do duoc 0.3653 x
    -- 0.85 = 0.3105 -- dung bang chenh lech nhin thay tren man hinh.
    BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, parentF, FRAMEPOINT_TOPLEFT,
                     dx / s, -(dy / s))
    -- Truyen h = can GIUA trong mot o cao h, thay vi bam mep tren cua
    -- mot o cao LINE. Can theo mep tren thi phai doan chieu cao chu de
    -- biet tam no o dau -- va doan sai la lech vai pixel, dung cai lam
    -- dong "1/10" khong thang voi nut ben canh.
    BlzFrameSetSize(t, w / s, (h or LINE) / s)
    local mid = (h ~= nil and TEXT_JUSTIFY_MIDDLE ~= nil)
                and TEXT_JUSTIFY_MIDDLE or TEXT_JUSTIFY_TOP
    if BlzFrameSetTextAlignment ~= nil and TEXT_JUSTIFY_TOP ~= nil then
      BlzFrameSetTextAlignment(t, mid,
        right and TEXT_JUSTIFY_RIGHT or TEXT_JUSTIFY_LEFT)
    end
    API.frameScale(t, scale)
    API.frameDead(t)   -- chu nam de len nut se NUOT cu bam
    return t
  end

  -- CHA la tham so, khong co dinh st.panel.
  --
  -- Truoc day ham nay va backdropFrame() luon gan vao st.panel, ke ca
  -- khi goi tu cum "focus". Ket qua: nut va thanh tien do la ANH EM cua
  -- f.root chu khong phai CON, nen tat f.root khong tat duoc chung --
  -- "BREAK THROUGH -> Qi Refining" hien tren CA BON the.
  local function button(name, label, dx, dy, w, h, parentF)
    parentF = parentF or st.panel
    local b = BlzCreateFrameByType("GLUEBUTTON", name, parentF,
                                   CFG.FRAME_BUTTON_TEMPLATE, pid)
    if b == nil then return nil end
    BlzFrameSetSize(b, w, h)
    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, parentF, FRAMEPOINT_TOPLEFT, dx, -dy)
    -- VIEN cua nut: HAI O MAU DAC LONG NHAU, khong mượn template.
    --
    -- O ngoai phu kin nut = duong vien. O trong thut vao moi be d = ruot.
    -- Ca hai la CON cua nut nen tu an/hien va tu di theo nut, va
    -- frameDead nen khong nuot cu bam. Tao TRUOC chu de chu nam tren.
    --
    -- Vi sao khong dung backdrop co san: xem CFG.PANEL_BTN_EDGE.
    local d = CFG.PANEL_BTN_BORDER or 0.0016
    local function o(name, dx2, dy2, w2, h2, tex)
      local f = BlzCreateFrameByType("BACKDROP", name, b, "", pid)
      if f == nil then return end
      BlzFrameSetSize(f, w2, h2)
      BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, b, FRAMEPOINT_TOPLEFT, dx2, -dy2)
      BlzFrameSetTexture(f, tex, 0, true)
      API.frameDead(f)
    end
    o(name .. "Edge", 0.0, 0.0, w, h, CFG.PANEL_BTN_EDGE)
    o(name .. "Fill", d, d, w - 2 * d, h - 2 * d, CFG.PANEL_BTN_FILL)

    local t = BlzCreateFrameByType("TEXT", name .. "Txt", b, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_CENTER, b, FRAMEPOINT_CENTER, 0, 0)
      BlzFrameSetText(t, label)
      API.frameDead(t)
    end
    BlzTriggerRegisterFrameEvent(S.panel.trig, b, FRAMEEVENT_CONTROL_CLICK)
    return { btn = b, txt = t }
  end

  local function backdropFrame(name, dx, dy, w, h, tex, parentF)
    parentF = parentF or st.panel
    local f = BlzCreateFrameByType("BACKDROP", name, parentF, "", pid)
    if f == nil then return nil end
    BlzFrameSetSize(f, w, h)
    BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, parentF, FRAMEPOINT_TOPLEFT, dx, -dy)
    if tex ~= nil then BlzFrameSetTexture(f, tex, 0, true) end
    BlzFrameSetVisible(f, false)
    API.frameDead(f)
    return f
  end

  -- Hang the
  local n  = #S.panel.tabs
  local tw = (W - 2 * P - (n - 1) * GAP) / n
  for i = 1, n do
    st.tabBtn[i] = button("CharTab" .. i, S.panel.tabs[i].name,
                          P + (i - 1) * (tw + GAP), tabTop(), tw, TAB_H)
  end

  -- Dong tien: BA COT rong bang nhau, nhan can TRAI, so can PHAI.
  --
  -- Ban truoc nhet ca ba cap vao MOT frame chu, ngan nhau bang bon dau
  -- cach. Chu Warcraft khong deu nen bon dau cach khong ra mot be ngang
  -- co dinh: ba cap khong bao gio thang hang, va moi lan so doi do dai
  -- thi hai cap sau truot sang ngang. Nhin la thay lech, va lech khac
  -- nhau moi lan mo bang.
  --
  -- Cot co diem dau CO DINH thi khong con gi truot duoc.
  local moneyY = tabTop() + TAB_H + GAP
                 + (HEAD_H - LINE * CFG.PANEL_SCALE_SUB) * 0.5
  -- Ba cot tien chi chiem 78% be ngang; 22% con lai de chu thich ESC.
  --
  -- Chu thich KHONG dat duoc o hang the: nam nut da chia kin be ngang
  -- roi, dat o goc phai la de thang len "V. Shop".
  local hintW  = (W - 2 * P) * 0.22
  local SO_TIEN = 4
  local colW   = (W - 2 * P - hintW) / SO_TIEN
  st.money = {}
  for i = 1, SO_TIEN do
    local x = P + (i - 1) * colW
    st.money[i] = {
      lbl = text("CharMoneyL" .. i, st.panel, x, moneyY, colW * 0.58,
                  CFG.PANEL_SCALE_SUB, false),
      amt   = text("CharMoneyV" .. i, st.panel, x + colW * 0.58, moneyY,
                  colW * 0.42 - 0.008, CFG.PANEL_SCALE_SUB, true),
    }
  end

  -- Chu nho cuoi dong tien, KHONG phai nut: chi cho biet bam gi de dong.
  -- text() da goi API.frameDead nen no khong nuot cu bam nao.
  st.hint = text("CharHint", st.panel, W - P - hintW, moneyY, hintW,
                 CFG.PANEL_SCALE_SUB, true)
  if st.hint ~= nil then
    BlzFrameSetText(st.hint, CFG.C_GREY ..
      ((CFG.PANEL_KEY == nil) and API.t("panel_close_esc")
                               or API.t("panel_close", CFG.PANEL_KEY)) ..
      CFG.C_END)
  end

  local top = bodyTop()

  -- ----- Than kieu "list": MAX_ITEMS muc dung san -----
  for i = 1, MAX_ITEMS do
    local y  = top + (i - 1) * ROW()
    local xt = P + ICON() + 0.008
    local w  = textW()

    local it = {}
    it.bg    = backdropFrame("CharBg" .. i, P, y, W - 2 * P, ROW() - 0.004,
                             CFG.PANEL_GRID_TEX)
    it.icon  = backdropFrame("CharIcon" .. i, P, y + 0.006, ICON(), ICON(), nil)
    it.name  = text("CharName" .. i,  st.panel, xt, y + 0.006, w * 0.62,
                    CFG.PANEL_SCALE_NAME, false)
    -- Dong bac ("1/10"): o cao TRON DONG, can giua theo chieu doc. Nut
    -- ben phai cung can giua dong, nen hai cai chung mot tam -- khong
    -- con phu thuoc chieu cao chu.
    it.state = text("CharState" .. i, st.panel, xt + w * 0.62, y,
                    w * 0.38, CFG.PANEL_SCALE_NAME, true, ROW())
    it.sub   = text("CharSub" .. i,   st.panel, xt, y + 0.006 + LINE + 0.004, w,
                    CFG.PANEL_SCALE_SUB, false)

    local b = button("CharBtn" .. i, "", W - P - BTN_W(),
                     y + (ROW() - BTN_H()) * 0.5, BTN_W(), BTN_H())
    if b ~= nil then it.btn, it.btnTxt = b.btn, b.txt end

    show(it.name, false); show(it.state, false); show(it.sub, false)
    show(it.btn, false)
    st.item[i] = it
  end

  st.empty = text("CharEmpty", st.panel, P, top + 0.010, W - 2 * P,
                  CFG.PANEL_SCALE_NAME, false)
  show(st.empty, false)

  -- ----- Than kieu "focus" -----
  do
    local f = { row = {} }
    local fh = bodyH()

    -- Frame goc CHI de bat/tat ca cum bang MOT loi goi -- no khong ve gi.
    --
    -- Ban truoc no la BACKDROP phu PANEL_GRID_TEX. PANEL_GRID_TEX la mot
    -- o mau DAC (TeamColor27, den): dung cho mot dong cao 0.044 thi ra
    -- vach ke, dung cho ca than bang thi ra MOT TAM DEN to bang nua
    -- khung. Ke vach la viec cua tung dong, khong phai cua ca khoi.
    --
    -- "FRAME" la kieu frame rong: co toa do, co con, khong co hinh. No
    -- khong phai control nen khong goi frameDead -- khong co hinh thi
    -- cung khong nuot duoc cu bam.
    f.root = BlzCreateFrameByType("FRAME", "CharFocus", st.panel, "", pid)
    if f.root == nil then
      -- Lui ve kieu cu: xau nhung con hien duoc. Mot the TRONG te hon
      -- mot the co tam den.
      API.trace("panel: khong tao duoc FRAME rong -- lui ve BACKDROP")
      f.root = BlzCreateFrameByType("BACKDROP", "CharFocus", st.panel, "", pid)
      if f.root ~= nil then
        BlzFrameSetTexture(f.root, CFG.PANEL_GRID_TEX, 0, true)
        API.frameDead(f.root)
      end
    end
    if f.root ~= nil then
      BlzFrameSetSize(f.root, W - 2 * P, fh)
      BlzFrameSetPoint(f.root, FRAMEPOINT_TOPLEFT, st.panel,
                       FRAMEPOINT_TOPLEFT, P, -top)
      show(f.root, false)

      local fw = W - 2 * P
      f.titleF = text("CharFTitle", f.root, 0.004, 0.006, fw * 0.55,
                      CFG.PANEL_SCALE_HEAD, false)
      f.sub    = text("CharFSub",   f.root, fw * 0.45, 0.008, fw * 0.55 - 0.004,
                      CFG.PANEL_SCALE_NAME, true)

      -- Ba dong so lieu, moi dong mot vach ke rieng -- cung cach the
      -- kieu "list" ke dong chan, de hai kieu than trong nhu mot bang.
      for i = 1, 3 do
        local y = 0.044 + (i - 1) * 0.024
        f.row[i] = {
          alt    = (CFG.PANEL_GRID and i % 2 == 0)
                  and backdropFrame("CharFRow" .. i, 0.0, y - 0.004, fw, 0.022,
                                    CFG.PANEL_GRID_TEX, f.root) or nil,
          lbl  = text("CharFL" .. i, f.root, 0.010, y, fw * 0.34,
                       CFG.PANEL_SCALE_NAME, false),
          before = text("CharFA" .. i, f.root, fw * 0.36, y, fw * 0.22,
                       CFG.PANEL_SCALE_NAME, true),
          after   = text("CharFB" .. i, f.root, fw * 0.60, y, fw * 0.38 - 0.010,
                       CFG.PANEL_SCALE_NAME, false),
        }
      end

      -- Thanh tien do + nut + ghi chu dat theo DAY cua than bang, khong
      -- theo dinh. Than bang cao bang the dai nhat (7 ky nang = 0.336),
      -- nen neo theo dinh thi ca cum dinh o nua tren va nua duoi bo
      -- trong -- do la cai "vo bo cuc" cua the I.
      --
      -- Toa do theo F.ROOT, khong theo st.panel. f.root nam o (P, -top)
      -- nen diem panel (P + x, top + y) chinh la diem root (x, y).
      local noteY = fh - 0.022
      local btnH  = BTN_H() + 0.006
      local btnY  = noteY - btnH - 0.010
      local barY  = btnY - 0.020

      f.barBg = backdropFrame("CharFBarBg", 0.0, barY, fw, 0.010,
                              CFG.PANEL_BAR_BG, f.root)
      f.barFill = backdropFrame("CharFBarFill", 0.0, barY, fw * 0.5, 0.010,
                                CFG.PANEL_BAR_FILL, f.root)

      local b = button("CharFBtn", "", fw * 0.10, btnY,
                       fw * 0.80, btnH, f.root)
      if b ~= nil then f.btn, f.btnTxt = b.btn, b.txt end

      f.note = text("CharFNote", f.root, 0.010, noteY, fw - 0.020,
                      CFG.PANEL_SCALE_SUB, false)
    end
    st.focus = f
  end

  -- ----- Than kieu "grid" -----
  if GRID_SLOTS ~= nil and GRID_ROWS > 0 then
    local g  = { cell = {}, stat = {} }
    local fw = W - 2 * P

    -- Chia doi be ngang: luoi o ben trai, bang thong ke ben phai. Bang
    -- rong 0.74 nen xep doc het thi thua ngang va thieu doc -- ma thieu
    -- doc thi CA BON the cung cao len theo (bodyH lay max).
    local dollW = fw * 0.62
    local colW  = dollW / GRID_COLS
    local btnW  = colW - 0.016
    if btnW > 0.132 then btnW = 0.132 end   -- du cho "TIEN GIAI  10"

    g.root = BlzCreateFrameByType("FRAME", "CharGrid", st.panel, "", pid)
    if g.root == nil then
      API.trace("panel: khong tao duoc FRAME rong cho luoi trang bi")
    else
      BlzFrameSetSize(g.root, fw, bodyH())
      BlzFrameSetPoint(g.root, FRAMEPOINT_TOPLEFT, st.panel,
                       FRAMEPOINT_TOPLEFT, P, -top)
      show(g.root, false)

      -- Cho hinh bong nguoi: cot giua, ba dong tren.
      --
      -- Chua co file thi ve o mau nen (PANEL_GRID_TEX) chu khong bo
      -- trong: mot o trong giua luoi trong nhu loi ve, mot o toi mau thi
      -- trong nhu cho danh san. Go duong dan chua import vao
      -- CFG.GEAR_SILHOUETTE se ra o XANH LA, khong phai o trong.
      if GRID_COLS >= 3 then
        g.doll = backdropFrame("CharGridDoll", colW + 0.006, 0.0,
                               colW - 0.012, 3 * rowStep() - CELL_GAP,
                               CFG.GEAR_SILHOUETTE or CFG.PANEL_GRID_TEX, g.root)
      end

      local d = CFG.PANEL_BTN_BORDER or 0.0016
      for i = 1, #GRID_SLOTS do
        local col, row = GRID_SLOTS[i][1], GRID_SLOTS[i][2]
        local cx = (col - 1) * colW
        local cy = (row - 1) * rowStep()
        local ix = cx + (colW - ICON()) * 0.5
        local c  = {}

        -- Vien quanh icon, cung cach nut tu ve vien: hai o mau long nhau.
        c.edge = backdropFrame("CharGridEdge" .. i, ix - d, cy - d,
                               ICON() + 2 * d, ICON() + 2 * d,
                               CFG.PANEL_BTN_EDGE, g.root)
        c.icon = backdropFrame("CharGridIcon" .. i, ix, cy,
                               ICON(), ICON(), nil, g.root)

        local by = cy + ICON() + 0.004
        local b = button("CharGridBtn" .. i, "", cx + (colW - btnW) * 0.5,
                         by, btnW, BTN_H(), g.root)
        if b ~= nil then c.btn, c.btnTxt = b.btn, b.txt end

        -- Dong chu DUNG CHO NUT khi mon nay khong bam duoc gi.
        --
        -- O trong khong loi giai thich thi nguoi choi tuong giao dien
        -- hong -- kieu "list" cu da co cho nay (it.desc), luoi o thi
        -- khong, nen phai lam lai.
        c.note = text("CharGridNote" .. i, g.root, cx, by + 0.004, colW,
                      CFG.PANEL_SCALE_SUB, false)

        show(c.edge, false); show(c.icon, false)
        show(c.btn, false); show(c.note, false)
        g.cell[i] = c
      end

      -- Bang thong ke ben phai: mot dong moi mon.
      local sx = dollW + 0.014
      local sw = fw - sx
      g.statHead = text("CharGridSH", g.root, sx, 0.0, sw,
                        CFG.PANEL_SCALE_NAME, false)
      for i = 1, #GRID_SLOTS do
        local y = 0.026 + (i - 1) * 0.020
        g.stat[i] = {
          alt = (CFG.PANEL_GRID and i % 2 == 0)
                and backdropFrame("CharGridSA" .. i, sx - 0.004, y - 0.003,
                                  sw, 0.019, CFG.PANEL_GRID_TEX, g.root) or nil,
          lbl = text("CharGridSL" .. i, g.root, sx, y, sw * 0.42,
                     CFG.PANEL_SCALE_SUB, false),
          val = text("CharGridSV" .. i, g.root, sx + sw * 0.42, y,
                     sw * 0.58, CFG.PANEL_SCALE_SUB, true),
        }
      end
    end
    st.grid = g
  end

  BlzFrameSetVisible(st.panel, false)
  API.trace("panel: dung bang pid " .. pid .. " (" .. n .. " the, " ..
            MAX_ITEMS .. " dong, luoi " .. GRID_COLS .. "x" .. GRID_ROWS ..
            ", nen = " .. tostring(how) .. ")")
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

-- Tra ban phim ve cho game sau moi cu bam.
--
-- LOI THAT: bam vao mot the roi bam ESC thi bang khong dong. Bam ra
-- ngoai mot cai roi ESC thi lai duoc.
--
-- Nguyen nhan: GLUEBUTTON GIU TIEU DIEM ban phim sau khi duoc bam. Frame
-- dang giu tieu diem nuot het phim, nen ca
-- BlzTriggerRegisterPlayerKeyEvent lan EVENT_PLAYER_END_CINEMATIC deu
-- khong no. Bam ra cho khac la mat tieu diem, nen ESC lai chay -- dung
-- kieu "luc duoc luc khong" ma anh chup khong the hien.
--
-- Tat roi bat lai la cach tra tieu diem o ban 1.31. Nut nao gui duoc cu
-- bam thi von da dang bat, nen bat lai luon dung trang thai; va cac
-- duong ben duoi deu goi refresh() ngay sau do, refresh dat lai trang
-- thai bat/tat theo du tien hay khong.
local function releaseFocus(f)
  if f == nil or BlzFrameSetEnable == nil then return end
  BlzFrameSetEnable(f, false)
  BlzFrameSetEnable(f, true)
end

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end
  releaseFocus(f)

  for pid, st in pairs(S.panel.byPid) do
    if GetLocalPlayer() == Player(pid) then
      local tab = S.panel.tabs[st.tab]

      if st.focus ~= nil and f == st.focus.btn then
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

      if st.grid ~= nil then
        for i = 1, #st.grid.cell do
          local c = st.grid.cell[i]
          if c ~= nil and f == c.btn then
            if tab ~= nil and tab.itemAction ~= nil then tab.itemAction(pid, i) end
            return
          end
        end
      end

      for i = 1, MAX_ITEMS do
        local w = st.item[i]
        if w ~= nil and f == w.btn then
          if tab ~= nil and tab.itemAction ~= nil then tab.itemAction(pid, i) end
          return
        end
      end
    end
  end
end

-- Phim E. Su kien phim la cuc bo, nhung mo/dong bang cung la UI thuan
-- nen khong can dong bo.
-- Phim mo bang. Doi E -> R: E da thanh phim tat cua Bat Hoai (ky nang
-- chu dong thu ba), va mot phim khong the vua bam skill vua mo bang.
-- ESC dong bang. HAI duong dang ky, khong mot:
--
--   OSKEY_ESCAPE                  co tu 1.31, nhung la duong moi
--   EVENT_PLAYER_END_CINEMATIC    duong co dien: Warcraft ban su kien
--                                 nay moi lan ai do bam ESC
--
-- Dang ky ca hai roi de hide() tu chan lan thu hai -- re hon nhieu so
-- voi viec doan xem ban nay nhan duong nao, va do chinh la kieu doan da
-- lam hong he dong bo mot lan (ADR 0012).
local function bindEsc()
  local n = 0
  local t = CreateTrigger()

  local esc = _G["OSKEY_ESCAPE"]
  if BlzTriggerRegisterPlayerKeyEvent ~= nil and esc ~= nil then
    for i = 1, #S.pids do
      BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), esc, 0, true)
    end
    n = n + 1
  end

  if TriggerRegisterPlayerEvent ~= nil and EVENT_PLAYER_END_CINEMATIC ~= nil then
    for i = 1, #S.pids do
      TriggerRegisterPlayerEvent(t, Player(S.pids[i]), EVENT_PLAYER_END_CINEMATIC)
    end
    n = n + 1
  end

  -- Khong con phim chu thi ESC phai BAT/TAT, neu khong thi khong con
  -- duong nao MO bang ngoai lenh chat "-c".
  --
  -- Con phim chu thi ESC chi TAT: luc do bam ESC de huy chon quan ma
  -- bang bat len la mot cai bay nho dat dung cho ai cung bam theo phan
  -- xa.
  local canToggle = (CFG.PANEL_KEY == nil)

  -- CHAN LAN NO THU HAI.
  --
  -- Hai duong dang ky o tren nam tren CUNG MOT trigger, nen mot lan bam
  -- ESC no HAI lan. Hoi ESC con la chi-tat thi vo hai: lan hai goi
  -- hide() tren mot bang da dong. Tu luc no thanh bat/tat thi lan hai
  -- HUY lan mot -- bang mo ra roi dong ngay trong cung mot khung hinh,
  -- nhin y het nhu ESC khong lam gi ca.
  --
  -- Do do duoc: file vet ghi "ESC dang ky qua 2 duong".
  --
  -- Van giu ca hai duong dang ky chu khong bo bot mot: khong ai biet
  -- ban sau con du ca hai khong, va chan trung o day re hon la doan.
  local escLock = {}
  TriggerAddAction(t, function()
    local pid = GetPlayerId(GetTriggerPlayer())
    if escLock[pid] then return end
    -- Khung Co Duyen dang mo thi ESC khong dong no, va cung khong mo
    -- bang nhan vat de len tren. Phai chon mot the moi di tiep.
    if API.fortuneFrameShown ~= nil and API.fortuneFrameShown(pid) then return end
    escLock[pid] = true
    API.after(CFG.PANEL_ESC_LOCK or 0.25, function() escLock[pid] = nil end)

    if stateOf(pid).shown then hide(pid)
    elseif canToggle then toggle(pid) end
  end)

  API.trace("panel: ESC dang ky qua " .. n .. " duong")
  return n > 0
end

local function bindKey()
  local name = CFG.PANEL_KEY
  if name == nil then
    API.trace("panel: khong gan phim chu (CFG.PANEL_KEY = nil), chi ESC")
    return false
  end
  local key = _G["OSKEY_" .. name]
  if BlzTriggerRegisterPlayerKeyEvent == nil or key == nil then
    API.trace("panel: KHONG co BlzTriggerRegisterPlayerKeyEvent/OSKEY_" ..
              name .. " -- chi con -c")
    return false
  end
  local t = CreateTrigger()
  for i = 1, #S.pids do
    BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), key, 0, true)
  end
  TriggerAddAction(t, function() toggle(GetPlayerId(GetTriggerPlayer())) end)
  API.trace("panel: da gan phim " .. name)
  return true
end

local function startPanel()
  -- So dong dung san = the dai nhat. Tinh o day chu khong go tay: them
  -- mot he 9 muc thi bang tu rong ra, khong phai nho sua hang so.
  for i = 1, #S.panel.tabs do
    local t = S.panel.tabs[i]
    if t.rows ~= nil and t.rows > MAX_ITEMS then MAX_ITEMS = t.rows end

    -- Kich thuoc luoi suy TU bang o cua the, khong go tay.
    if t.kind == "grid" and t.slots ~= nil then
      GRID_SLOTS = t.slots
      for k = 1, #t.slots do
        local col, row = t.slots[k][1], t.slots[k][2]
        if col > GRID_COLS then GRID_COLS = col end
        if row > GRID_ROWS then GRID_ROWS = row end
      end
    end
  end

  S.panel.trig = CreateTrigger()
  TriggerAddAction(S.panel.trig, onClick)
  S.keyBound = bindKey()
  bindEsc()
  API.trace("panel: san sang, " .. #S.panel.tabs .. " the, " .. MAX_ITEMS ..
            " dong, phimE=" .. tostring(S.keyBound))
end

-- Ve lai bang cua MOI nguoi. Khong goi refresh(nil) duoc: stateOf se
-- gan S.panel.byPid[nil] va Lua no loi "table index is nil".
local function refreshAll()
  for i = 1, #S.pids do refresh(S.pids[i]) end
end

API.panelRefreshAll  = refreshAll
API.panelAddTab      = addTab
API.panelPlaceholder = placeholderTab
API.panelRefresh     = refresh
API.panelToggle      = toggle
API.panelOpenTab     = openTab
API.startPanel       = startPanel
