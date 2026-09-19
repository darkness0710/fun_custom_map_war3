-- ============================================================
--  11_board.lua  --  Multiboard: bon thu KHONG nam tren thanh tai nguyen
--
--  VI SAO CAN. Map nay co BON dong tien, ma thanh tai nguyen cua
--  Warcraft chi co HAI o:
--
--    Vang, Go              thanh tai nguyen  -- luon thay
--    Linh Khi, Da          S.p[pid]          -- chi thay khi bam ESC
--    luot Co Duyen         chat              -- troi mat
--
--  Tuc HAI TRONG BON dong tien vo hinh, va mot trong hai la LINH KHI --
--  thu mua Tu Vi, truc tien trinh chinh. Cau "du 500 chua?" la cau
--  nguoi choi hoi lien tuc, ma phai bam ESC moi tra loi duoc.
--
--  VI SAO MULTIBOARD CHU KHONG PHAI MOT KHUNG TU VE. Day la thu duy
--  nhat LUON HIEN ma khong can BlzFrame: no la UI goc cua Warcraft, co
--  chac tren 1.31.1, nguoi choi thu nho duoc, va no khong dam voi bon
--  khung tu ve cua map (chung deu neo giua man hinh).
--
--  MOI HANG LA MOT NGUOI CHOI, khong phai chi minh. Do la cho bien no
--  tu mot cai HUD thanh mot cong cu CO-OP: nhin mot cai biet ai sap
--  dot pha, ai dang ngheo, ai con luot quay chua tieu.
--
--  DONG BO: noi dung multiboard la trang thai TOAN CUC. Moi may phai
--  ghi cung mot thu -- tuyet doi khong ghi trong nhanh GetLocalPlayer
--  (ADR 0012). Ham nay chay tu mot dong ho chung nen moi may tu chay
--  cung so lan.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Be ngang TUNG COT, tinh theo be ngang man hinh.
--
-- LOI DA SHIP: ban dau chi dat be ngang cho HANG TIEU DE. Multiboard
-- cua Warcraft giu be ngang theo TUNG O chu khong theo cot -- nen hang
-- tieu de gian theo so cua ta con hang du lieu giu mac dinh, va hai
-- hang le nhau tren man hinh.
--
-- Khong co ham nao dat "be ngang cua mot cot". Phai dat cho MOI o, va
-- do la ly do put() luon tra bang nay chu khong nhan tham so.
local COLW = { 0.085, 0.075, 0.055, 0.042, 0.042 }
local COLS = #COLW

local function fmtNum(n)
  return API.num(math.floor((n or 0) + 0.5))
end

-- Ghi mot o. Gop lai mot cho vi moi o deu phai lam BON viec giong nhau
-- (lay item, dat kieu, dat chu + be ngang, giai phong handle) -- quen
-- cai cuoi thi ro ri mot handle moi lan ve lai, va ta ve moi nua giay.
local function put(mb, row, col, text)
  local it = MultiboardGetItem(mb, row - 1, col - 1)
  if it == nil then return end
  MultiboardSetItemStyle(it, true, false)
  MultiboardSetItemValue(it, text)
  MultiboardSetItemWidth(it, COLW[col] or 0.05)
  MultiboardReleaseItem(it)
end

local function header(mb)
  put(mb, 1, 1, CFG.C_GOLD .. API.t("board_player") .. CFG.C_END)
  put(mb, 1, 2, CFG.C_GOLD .. API.t("board_realm")  .. CFG.C_END)
  put(mb, 1, 3, CFG.C_GOLD .. API.t("panel_qi")     .. CFG.C_END)
  put(mb, 1, 4, CFG.C_GOLD .. API.t("cur_iron")     .. CFG.C_END)
  put(mb, 1, 5, CFG.C_GOLD .. API.t("board_roll")   .. CFG.C_END)
end

local function refresh()
  local mb = S.board
  if mb == nil then return end

  -- Tieu de mang so dot. No la thu duy nhat cua BAN DAU (khong theo
  -- tung nguoi), va truoc day chi doc duoc khi bam R.
  local total = (API.totalStages ~= nil) and API.totalStages() or 0
  MultiboardSetTitleText(mb, API.t("board_title", S.stage or 0, total))

  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d   = S.p[pid]
    local row = i + 1

    put(mb, row, 1, GetPlayerName(Player(pid)))

    if d == nil or d.hero == nil then
      -- Chua chon hero: de trong chu khong ghi so 0. So 0 doc ra la
      -- "co ma het", con trong doc ra la "chua bat dau" -- hai thu khac
      -- nhau, va nguoi cung doi can phan biet duoc.
      put(mb, row, 2, CFG.C_GREY .. "--" .. CFG.C_END)
      put(mb, row, 3, "")
      put(mb, row, 4, "")
      put(mb, row, 5, "")
    else
      local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
      local name = (API.realmName ~= nil) and API.realmName(rank) or tostring(rank)
      put(mb, row, 2, name)
      put(mb, row, 3, CFG.C_JADE .. fmtNum(API.getQi(pid)) .. CFG.C_END)
      put(mb, row, 4, fmtNum(API.getIron(pid)))

      -- Luot quay: to len khi CON luot, xam khi het. Mot con so 0 nam
      -- im thi mat bo qua; mot con so vang thi no tu goi.
      local n = (API.fortuneRolls ~= nil) and API.fortuneRolls(pid) or 0
      put(mb, row, 5, (n > 0) and (CFG.C_GOLD .. n .. CFG.C_END)
                               or (CFG.C_GREY .. "0" .. CFG.C_END))
    end
  end
end

local function startBoard()
  if not CFG.BOARD_SHOW then
    API.trace("board: TAT (CFG.BOARD_SHOW = false)")
    return
  end
  if CreateMultiboard == nil then
    API.trace("board: KHONG co CreateMultiboard -- Linh Khi va Da chi " ..
              "doc duoc trong bang ESC")
    return
  end

  local mb = CreateMultiboard()
  if mb == nil then
    API.trace("board: CreateMultiboard tra ve nil")
    return
  end
  S.board = mb

  -- Mot hang tieu de + mot hang moi nguoi choi.
  MultiboardSetRowCount(mb, #S.pids + 1)
  MultiboardSetColumnCount(mb, COLS)
  header(mb)
  refresh()
  MultiboardDisplay(mb, true)

  S.boardTimer = CreateTimer()
  TimerStart(S.boardTimer, CFG.BOARD_TICK or 0.5, true, refresh)

  API.trace("board: " .. (#S.pids + 1) .. " hang x " .. COLS ..
            " cot, nhip " .. (CFG.BOARD_TICK or 0.5) .. "s")
end

API.boardRefresh = refresh
API.startBoard   = startBoard
