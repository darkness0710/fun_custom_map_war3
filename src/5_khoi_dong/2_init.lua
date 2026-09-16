-- ============================================================
--  2_init.lua  --  Khoi dong & moc vao main() cua map
--
--  File nay phai la file cuoi cung: build.py dong khoi do...end ngay
--  sau day.
-- ============================================================

-- In so do luoi ra chat. Day la cach kiem tra buoc 1: doi chieu con so
-- o day voi thuoc do trong World Editor.
local function reportGrid()
  local g = S.grid
  API.msg(nil, CFG.C_GOLD .. "=== Luoi " .. g.cols .. "x" .. g.rows ..
    " (" .. (g.cols * g.rows) .. " o) ===" .. CFG.C_END)
  API.msg(nil, "Vung choi duoc : " .. g.tilesW .. " x " .. g.tilesH .. " o dia hinh"
    .. "  (" .. API.num(g.playMaxX - g.playMinX) .. " x "
    .. API.num(g.playMaxY - g.playMinY) .. " don vi)")
  API.msg(nil, "Moi block      : " .. g.blockTilesW .. " x " .. g.blockTilesH .. " o"
    .. "  (" .. API.num(g.blockW) .. " x " .. API.num(g.blockH) .. " don vi)")
  API.msg(nil, "Long song      : " .. g.riverTiles .. " o  ("
    .. API.num(g.river) .. " don vi)")
  API.msg(nil, "Le hai ben     : " .. g.marginTilesX .. " o ngang, "
    .. g.marginTilesY .. " o doc")
  API.msg(nil, "Goc luoi (1,1) : " .. API.num(g.originX) .. ", " .. API.num(g.originY))
end

-- Ping minimap tam moi block de nhin thay luoi ngay khi vao map.
local function pingBlocks()
  API.forEachBlock(function(col, row, idx, x0, y0, x1, y1)
    local cx, cy = (x0 + x1) * 0.5, (y0 + y1) * 0.5
    PingMinimapEx(cx, cy, 8.0, 255, 200, 0, false)
  end)
end

-- Ket thuc van. Doi 3 giay cho nguoi choi doc duoc ly do truoc khi
-- man hinh ket qua che mat.
local function endGame(win, reason)
  if not S.running then return end
  S.running = false
  API.stopWaves()

  API.msg(nil, " ")
  if win then
    API.msg(nil, CFG.C_GOLD .. "THANG -- " .. reason .. CFG.C_END)
  else
    API.msg(nil, CFG.C_RED .. "THUA -- " .. reason .. CFG.C_END)
  end

  API.after(3.0, function()
    for i = 1, #S.pids do
      local p = Player(S.pids[i])
      if win then
        CustomVictoryBJ(p, reason, true, true)
      else
        CustomDefeatBJ(p, reason)
      end
    end
  end)
end

-- Chay sau khi map da nap xong (goi tu timer 0 giay ben duoi).
local function bootstrap()
  if S.running then return end

  API.trace("bootstrap: bat dau")
  API.msg(nil, CFG.C_GOLD .. "[build " .. CFG.VERSION .. "] code da chay." .. CFG.C_END)

  -- Chi de phat trien: mo toan bo suong mu.
  if CFG.REVEAL_MAP then
    FogEnable(false)
    FogMaskEnable(false)
    API.msg(nil, CFG.C_GOLD .. "[dev] Da mo toan bo suong mu (CFG.REVEAL_MAP)." .. CFG.C_END)
  end

  local n = API.initPlayers()
  API.trace("initPlayers: " .. n .. " nguoi choi")

  -- Kenh dong bo phai san sang TRUOC moi he khac: cac he dang ky tin
  -- nhan cua minh trong ham start cua chung.
  API.startSync()
  API.langCheck()

  -- Do xem ban nay co nhung native nao. Khong doi gi, chi ghi vet --
  -- nhung moi lan doan thay vi do, du an nay deu doan sai (ADR 0012).
  API.startNatives()

  API.buildGrid()
  API.trace("buildGrid: xong")

  -- Nha chinh dung sau khi co luoi, de bao cao duoc no nam o block nao.
  API.createHouse()
  API.trace("createHouse: tra ve")

  API.resolveEnemyRegion()
  API.trace("resolveEnemyRegion: xong")

  -- Phai chay TRUOC khi nguoi choi kip chon hero.
  --
  -- HAI CACH, vi chua biet cach nao an:
  --   1. Preload() thang duong dan file   <- cach chinh
  --   2. tao mot con moi loai hero roi xoa ngay
  --
  -- PreloadStart/PreloadEnd moi la cap nap THAT. PreloadGenStart/
  -- PreloadGenEnd la de SINH file preload -- lan trong do thi Preload()
  -- chi ghi ten vao file chu khong nap gi ca. Bo ghi vet cua du an nay
  -- dung dung ho PreloadGen*, nen phai goi dung cap o day.
  if CFG.PRELOAD ~= nil and Preload ~= nil then
    if PreloadStart ~= nil then PreloadStart() end
    for i = 1, #CFG.PRELOAD do Preload(CFG.PRELOAD[i]) end
    if PreloadEnd ~= nil then PreloadEnd(0.5) end
    API.trace("preload: da goi Preload cho " .. #CFG.PRELOAD .. " file")
  end

  API.preloadHeroes()

  API.startHeroLock()
  API.trace("startHeroLock: xong")

  -- Cac he dang ky the TRUOC, roi bang moi dung -- bang can biet co
  -- bao nhieu the de chia be ngang.
  -- Thu tu dang ky = thu tu the trong bang. Bon he, bon dong tien nguon
  -- khac nhau -- xem docs/02-he-thong/kinh-te.md
  API.startLinhCan()   -- I.   Linh Khi
  API.startSkills()    -- II.  Ngo Tinh
  API.startTrangBi()   -- III. Linh Khi (tranh vi voi Linh Can, co y)
  API.startPhapKhi()   -- IV.  Tinh Thach
  API.startPanel()

  API.startSkillFx()
  API.startFct()
  API.startWaves()
  API.startHeroFrame()
  API.startSkillFrame()
  API.startSkillPicking()
  API.startPicking()
  API.trace("startPicking: tra ve")

  API.registerEvents()
  API.trace("registerEvents: xong")

  S.running = true
  API.trace("BOOTSTRAP HOAN TAT")

  if CFG.DEBUG then
    reportGrid()
    pingBlocks()
    API.report()
    API.heroPickReport()
    API.dbg(n .. " nguoi choi vao map.")
  end
end

API.endGame    = endGame
API.reportGrid = reportGrid
API.pingBlocks = pingBlocks
API.bootstrap  = bootstrap

-- ---------- Moc vao vong doi cua map ----------
-- Khoi code nay chay luc nap chunk, truoc khi main() duoc goi. Ta boc
-- InitGlobals (main() goi no ngay sau InitBlizzard), roi hen timer 0 giay
-- de bootstrap chay khi map thuc su san sang.
-- Vet nay chay luc NAP CHUNK, truoc ca main(). No phan biet duoc hai
-- truong hop rat khac nhau:
--   co dong nay, khong co "bootstrap" -> chunk nap duoc nhung moc hong
--   khong co dong nao ca              -> map khong he chua code nay
API.trace("chunk: da nap, dang moc InitGlobals")

do
  local function chay()
    TimerStart(CreateTimer(), 0.00, false, function()
      DestroyTimer(GetExpiredTimer())
      bootstrap()   -- tu chan neu da chay roi (S.running)
    end)
  end

  -- HAI DUONG, chu khong mot.
  --
  -- Khi code duoc nhet vao war3map.wct (o custom script cua World
  -- Editor), World Editor quyet dinh dat no o dau trong war3map.lua --
  -- va no co the dat TRUOC "function InitGlobals()". Luc do
  -- prevInitGlobals bat duoc nil, roi dinh nghia that cua InitGlobals
  -- de len ban thay the cua ta: moc mat, khong bao gi.
  --
  -- Nen ngoai moc do con hen thang mot timer ngay luc nap chunk. Cai
  -- nao toi truoc thi chay, bootstrap tu chan lan thu hai.
  local prevInitGlobals = InitGlobals
  InitGlobals = function()
    if prevInitGlobals ~= nil then prevInitGlobals() end
    chay()
  end

  chay()
end
