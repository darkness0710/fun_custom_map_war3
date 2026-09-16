-- ============================================================
--  1_panel.lua  --  Bang nhan vat (phim E)
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
local FOOT_H = 0.030
local GAP    = 0.006
local LINE   = 0.016    -- khoang cach hai dong chu trong mot muc

-- Cao than bang o kieu "focus". Bang phai CAO BANG NHAU o moi the,
-- neu khong doi the mot cai la khung nhay -- nen lay max voi kieu list.
local FOCUS_H = 0.200

local function PAD()   return CFG.PANEL_PAD end
local function ROW()   return CFG.PANEL_ROW end
local function ICON()  return CFG.PANEL_ICON end
local function BTN_W() return CFG.PANEL_BTN_W end
local function BTN_H() return CFG.PANEL_BTN_H end

-- Bao nhieu dong phai dung san. Tinh tu the dai nhat da dang ky, chu
-- khong go tay: them mot he 9 muc thi bang tu no rong ra.
local MAX_ITEMS = 1

local function bodyH()
  local list = MAX_ITEMS * ROW()
  return (list > FOCUS_H) and list or FOCUS_H
end

local function panelH()
  return PAD() + TAB_H + GAP + HEAD_H + GAP + bodyH() + GAP + FOOT_H + PAD()
end

local function bodyTop()
  return PAD() + TAB_H + GAP + HEAD_H + GAP
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
--   items(pid) -> { { icon, ten, mota, trangThai, nut, batNut }, ... }
--   itemAction(pid, i)
--   trong  -- chu hien khi items rong
--
-- kind = "focus":
--   info(pid) -> { tieuDe, phu, dong = { {nhan, truoc, sau}, ... },
--                  tienDo (0..1), ghiChu, nut, batNut }
--   action(pid)

local function addTab(tab)
  if tab.kind == nil then tab.kind = "list" end
  S.panel.tabs[#S.panel.tabs + 1] = tab
  return #S.panel.tabs
end

-- The chua lam: hien ro la chua lam thay vi de trong. Mot the trong
-- khien nguoi choi tuong giao dien hong.
local function placeholderTab(ten, mota)
  return {
    ten   = ten,
    kind  = "list",
    items = function() return {} end,
    trong = CFG.C_GREY .. API.t("panel_empty") .. CFG.C_END .. "  " .. mota,
  }
end

-- ---------- Trang thai ----------

local function stateOf(pid)
  if S.panel.byPid[pid] == nil then
    S.panel.byPid[pid] = { panel = nil, money = nil, tabBtn = {},
                           item = {}, focus = nil,
                           btnClose = nil, tab = 1, shown = false }
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
      local co = (it ~= nil)
      show(w.bg, co and (i % 2 == 0))
      show(w.name, co)
      show(w.state, co)
      show(w.sub, co)
      show(w.icon, co and it.icon ~= nil)
      show(w.btn, co and it.nut ~= nil)

      if co then
        if it.icon ~= nil then BlzFrameSetTexture(w.icon, it.icon, 0, true) end
        BlzFrameSetText(w.name,  CFG.C_GOLD .. (it.ten or "?") .. CFG.C_END)
        BlzFrameSetText(w.state, it.trangThai or "")
        BlzFrameSetText(w.sub,   CFG.C_GREY .. (it.mota or "") .. CFG.C_END)
        if it.nut ~= nil then
          BlzFrameSetText(w.btnTxt, it.nut)
          -- Nut mo di khi khong du tien: van THAY duoc gia, chi khong
          -- bam duoc. An han nut thi nguoi choi khong biet mon do ton
          -- bao nhieu de ma de danh.
          setEnabled(w.btn, it.batNut ~= false)
        end
      end
    end
  end

  -- Dong "chua co gi" cho the giu cho.
  show(st.empty, #items == 0)
  if #items == 0 and st.empty ~= nil then
    BlzFrameSetText(st.empty, tab.trong or "")
  end
end

local function refreshFocus(st, pid, tab)
  local f = st.focus
  if f == nil then return end
  local d = (tab.info and tab.info(pid)) or {}

  BlzFrameSetText(f.tieuDe, CFG.C_GOLD .. (d.tieuDe or "") .. CFG.C_END)
  BlzFrameSetText(f.phu,    CFG.C_JADE .. (d.phu or "") .. CFG.C_END)

  local dong = d.dong or {}
  for i = 1, #f.dong do
    local r = f.dong[i]
    local v = dong[i]
    show(r.nhan, v ~= nil)
    show(r.truoc, v ~= nil)
    show(r.sau, v ~= nil)
    if v ~= nil then
      BlzFrameSetText(r.nhan,  CFG.C_GREY .. (v[1] or "") .. CFG.C_END)
      BlzFrameSetText(r.truoc, v[2] or "")
      -- Mui ten nam trong cung frame voi gia tri sau, de khong phai do
      -- be ngang cua gia tri truoc moi biet dat mui ten o dau.
      BlzFrameSetText(r.sau,   CFG.C_GREY .. "->  " .. CFG.C_END ..
                               CFG.C_JADE .. (v[3] or "") .. CFG.C_END)
    end
  end

  local p = d.tienDo or 0.0
  if p < 0.0 then p = 0.0 elseif p > 1.0 then p = 1.0 end
  local full = CFG.PANEL_W - 2 * PAD()
  -- Be ngang 0 lam frame hong; an han di thay vi dat kich thuoc 0.
  show(f.barFill, p > 0.01)
  if p > 0.01 then BlzFrameSetSize(f.barFill, full * p, 0.010) end

  BlzFrameSetText(f.ghiChu, CFG.C_GREY .. (d.ghiChu or "") .. CFG.C_END)

  show(f.btn, d.nut ~= nil)
  if d.nut ~= nil then
    BlzFrameSetText(f.btnTxt, d.nut)
    setEnabled(f.btn, d.batNut ~= false)
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
      local nm = (ROMAN[i] or i) .. ". " .. S.panel.tabs[i].ten
      BlzFrameSetText(t.txt,
        (i == st.tab and CFG.C_GOLD or CFG.C_GREY) .. nm .. CFG.C_END)
    end
  end

  if st.money ~= nil then
    BlzFrameSetText(st.money,
      API.t("panel_linhkhi")   .. " " .. CFG.C_GOLD .. API.num(API.getLinhKhi(pid))   .. CFG.C_END ..
      "    " .. API.t("panel_ngotinh")   .. " " .. CFG.C_JADE .. API.num(API.getNgoTinh(pid))   .. CFG.C_END ..
      "    " .. API.t("panel_tinhthach") .. " " .. CFG.C_JADE .. API.num(API.getTinhThach(pid)) .. CFG.C_END)
  end

  local isList = (tab.kind ~= "focus")
  for i = 1, MAX_ITEMS do
    local w = st.item[i]
    if w ~= nil and not isList then
      show(w.bg, false); show(w.icon, false); show(w.name, false)
      show(w.state, false); show(w.sub, false); show(w.btn, false)
    end
  end
  if st.focus ~= nil then show(st.focus.root, not isList) end
  if not isList then show(st.empty, false) end

  if isList then refreshList(st, pid, tab) else refreshFocus(st, pid, tab) end
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
  local function text(name, parentF, dx, dy, w, scale, phai)
    local t = BlzCreateFrameByType("TEXT", name, parentF, "", pid)
    if t == nil then return nil end
    BlzFrameSetPoint(t, FRAMEPOINT_TOPLEFT, parentF, FRAMEPOINT_TOPLEFT, dx, -dy)
    BlzFrameSetSize(t, w, LINE)
    if BlzFrameSetTextAlignment ~= nil and TEXT_JUSTIFY_TOP ~= nil then
      BlzFrameSetTextAlignment(t, TEXT_JUSTIFY_TOP,
        phai and TEXT_JUSTIFY_RIGHT or TEXT_JUSTIFY_LEFT)
    end
    API.frameScale(t, scale)
    API.frameDead(t)   -- chu nam de len nut se NUOT cu bam
    return t
  end

  local function button(name, label, dx, dy, w, h)
    local b = BlzCreateFrameByType("GLUEBUTTON", name, st.panel,
                                   CFG.FRAME_BUTTON_TEMPLATE, pid)
    if b == nil then return nil end
    BlzFrameSetSize(b, w, h)
    BlzFrameSetPoint(b, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT, dx, -dy)
    local t = BlzCreateFrameByType("TEXT", name .. "Txt", b, "", pid)
    if t ~= nil then
      BlzFrameSetPoint(t, FRAMEPOINT_CENTER, b, FRAMEPOINT_CENTER, 0, 0)
      BlzFrameSetText(t, label)
      API.frameDead(t)
    end
    BlzTriggerRegisterFrameEvent(S.panel.trig, b, FRAMEEVENT_CONTROL_CLICK)
    return { btn = b, txt = t }
  end

  local function backdropFrame(name, dx, dy, w, h, tex)
    local f = BlzCreateFrameByType("BACKDROP", name, st.panel, "", pid)
    if f == nil then return nil end
    BlzFrameSetSize(f, w, h)
    BlzFrameSetPoint(f, FRAMEPOINT_TOPLEFT, st.panel, FRAMEPOINT_TOPLEFT, dx, -dy)
    if tex ~= nil then BlzFrameSetTexture(f, tex, 0, true) end
    BlzFrameSetVisible(f, false)
    API.frameDead(f)
    return f
  end

  -- Hang the
  local n  = #S.panel.tabs
  local tw = (W - 2 * P - (n - 1) * GAP) / n
  for i = 1, n do
    st.tabBtn[i] = button("CharTab" .. i, S.panel.tabs[i].ten,
                          P + (i - 1) * (tw + GAP), P, tw, TAB_H)
  end

  -- Dong tien
  st.money = text("CharMoney", st.panel, P, P + TAB_H + GAP, W - 2 * P,
                  CFG.PANEL_SCALE_SUB, false)

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
    it.state = text("CharState" .. i, st.panel, xt + w * 0.62, y + 0.006,
                    w * 0.38, CFG.PANEL_SCALE_NAME, true)
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
    local f = { dong = {} }
    -- Mot frame goc de bat/tat ca cum bang MOT loi goi.
    f.root = BlzCreateFrameByType("BACKDROP", "CharFocus", st.panel, "", pid)
    if f.root ~= nil then
      BlzFrameSetSize(f.root, W - 2 * P, FOCUS_H)
      BlzFrameSetPoint(f.root, FRAMEPOINT_TOPLEFT, st.panel,
                       FRAMEPOINT_TOPLEFT, P, -top)
      BlzFrameSetTexture(f.root, CFG.PANEL_GRID_TEX, 0, true)
      API.frameDead(f.root)
      show(f.root, false)

      local fw = W - 2 * P
      f.tieuDe = text("CharFTitle", f.root, 0.004, 0.006, fw * 0.55,
                      CFG.PANEL_SCALE_HEAD, false)
      f.phu    = text("CharFSub",   f.root, fw * 0.45, 0.008, fw * 0.55 - 0.004,
                      CFG.PANEL_SCALE_NAME, true)

      for i = 1, 3 do
        local y = 0.040 + (i - 1) * 0.020
        f.dong[i] = {
          nhan  = text("CharFL" .. i, f.root, 0.010, y, fw * 0.34,
                       CFG.PANEL_SCALE_NAME, false),
          truoc = text("CharFA" .. i, f.root, fw * 0.36, y, fw * 0.22,
                       CFG.PANEL_SCALE_NAME, true),
          sau   = text("CharFB" .. i, f.root, fw * 0.60, y, fw * 0.38 - 0.010,
                       CFG.PANEL_SCALE_NAME, false),
        }
      end

      f.barBg = backdropFrame("CharFBarBg", P, top + 0.108, fw, 0.010,
                              CFG.PANEL_BAR_BG)
      f.barFill = backdropFrame("CharFBarFill", P, top + 0.108, fw * 0.5, 0.010,
                                CFG.PANEL_BAR_FILL)

      local b = button("CharFBtn", "", P + fw * 0.10, top + 0.130,
                       fw * 0.80, BTN_H() + 0.006)
      if b ~= nil then f.btn, f.btnTxt = b.btn, b.txt end

      f.ghiChu = text("CharFNote", f.root, 0.010, 0.176, fw - 0.020,
                      CFG.PANEL_SCALE_SUB, false)
    end
    st.focus = f
  end

  -- Chan bang
  local footY = panelH() - PAD() - FOOT_H
  local c = button("CharClose", API.t("panel_close"),
                   W - P - 0.09, footY, 0.09, FOOT_H - 0.004)
  if c ~= nil then st.btnClose = c.btn end

  BlzFrameSetVisible(st.panel, false)
  API.trace("panel: dung bang pid " .. pid .. " (" .. n .. " the, " ..
            MAX_ITEMS .. " dong, nen = " .. tostring(how) .. ")")
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

local function onClick()
  local f = BlzGetTriggerFrame()
  if f == nil then return end

  for pid, st in pairs(S.panel.byPid) do
    if GetLocalPlayer() == Player(pid) then
      if f == st.btnClose then hide(pid); return end

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
local function bindKey()
  if BlzTriggerRegisterPlayerKeyEvent == nil or OSKEY_E == nil then
    API.trace("panel: KHONG co BlzTriggerRegisterPlayerKeyEvent/OSKEY_E -- chi con -c")
    return false
  end
  local t = CreateTrigger()
  for i = 1, #S.pids do
    BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), OSKEY_E, 0, true)
  end
  TriggerAddAction(t, function() toggle(GetPlayerId(GetTriggerPlayer())) end)
  API.trace("panel: da gan phim E")
  return true
end

local function startPanel()
  -- So dong dung san = the dai nhat. Tinh o day chu khong go tay: them
  -- mot he 9 muc thi bang tu rong ra, khong phai nho sua hang so.
  for i = 1, #S.panel.tabs do
    local t = S.panel.tabs[i]
    if t.soMuc ~= nil and t.soMuc > MAX_ITEMS then MAX_ITEMS = t.soMuc end
  end

  S.panel.trig = CreateTrigger()
  TriggerAddAction(S.panel.trig, onClick)
  S.keyBound = bindKey()
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
