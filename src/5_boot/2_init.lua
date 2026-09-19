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
  API.info(nil, CFG.C_GOLD .. "=== Luoi " .. g.cols .. "x" .. g.rows ..
    " (" .. (g.cols * g.rows) .. " o) ===" .. CFG.C_END)
  API.info(nil, "Vung choi duoc : " .. g.tilesW .. " x " .. g.tilesH .. " o dia hinh"
    .. "  (" .. API.num(g.playMaxX - g.playMinX) .. " x "
    .. API.num(g.playMaxY - g.playMinY) .. " don vi)")
  API.info(nil, "Moi block      : " .. g.blockTilesW .. " x " .. g.blockTilesH .. " o"
    .. "  (" .. API.num(g.blockW) .. " x " .. API.num(g.blockH) .. " don vi)")
  API.info(nil, "Long song      : " .. g.riverTiles .. " o  ("
    .. API.num(g.river) .. " don vi)")
  API.info(nil, "Le hai ben     : " .. g.marginTilesX .. " o ngang, "
    .. g.marginTilesY .. " o doc")
  API.info(nil, "Goc luoi (1,1) : " .. API.num(g.originX) .. ", " .. API.num(g.originY))
end

-- Ping minimap tam moi block de nhin thay luoi ngay khi vao map.
-- Ket thuc van. Doi 3 giay cho nguoi choi doc duoc ly do truoc khi
-- man hinh ket qua che mat.
local function endGame(win, reason)
  if not S.running then return end
  S.running = false
  API.stopWaves()

  -- Bang tong ket thay cho mot dong chu.
  --
  -- Hai dong cu di qua API.info / API.warn -- KENH CHAN DOAN cho nguoi
  -- LAM MAP -- va la chuoi cung khong qua i18n. Tuc chu quan trong
  -- nhat cua ca map nam sai kenh va chi co mot thu tieng.
  if API.summaryShow ~= nil then
    API.summaryShow(win, reason)
  else
    API.msg(nil, (win and CFG.C_GOLD or CFG.C_RED) ..
            (win and API.t("end_win") or API.t("end_lose")) ..
            CFG.C_END .. "  " .. reason)
  end

  -- Doi lau hon truoc day (3s): bang tong ket co nhieu dong, va hop
  -- thoai cua Warcraft nuot man hinh ngay khi no hien.
  API.after(CFG.END_SUMMARY_SECONDS or 10.0, function()
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
  -- In ca DAU THOI GIAN build, khong chi so hieu. CFG.VERSION go tay
  -- nen hai ban build khac nhau van cung mot so -- va luc do "go lenh
  -- moi ma khong thay gi" khong phan biet duoc voi "dang chay ban cu".
  API.info(nil, CFG.C_GOLD .. "[build " .. CFG.VERSION ..
          (CFG.BUILD and ("  " .. CFG.BUILD) or "") ..
          "] code da chay." .. CFG.C_END)

  -- Mo suong mu. Khong bao gi: day la cach map nay chay binh thuong,
  -- khong phai mot cong tac dev dang bat. Bao moi van mot dong "[dev]"
  -- chi lam nguoi choi tuong minh dang o ban chua xong.
  if CFG.REVEAL_MAP then
    FogEnable(false)
    FogMaskEnable(false)
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
  API.startCheatGuard()     -- canh cheat co san cua Warcraft
  API.startRevive()         -- hero chet roi song lai o nha chinh
  API.startSummary()        -- dong ho + bo dem cho bang tong ket
  API.trace("startHeroLock: xong")

  -- Cac he dang ky the TRUOC, roi bang moi dung -- bang can biet co
  -- bao nhieu the de chia be ngang.
  -- Thu tu dang ky = thu tu the trong bang. Nam he -- xem
  -- docs/02-he-thong/kinh-te.md
  API.startCult()   -- I.   Linh Khi
  API.startSkills()    -- II.  Go
  API.startGear()   -- III. Da Huyen Thiet
  API.startRelic()   -- IV.  (tam khoa)
  API.startShop()      -- V.   Vang
  API.startHouseUp()   -- VI.  Vang -- nang cap nha chinh
  API.startFortune()      -- Co Duyen (khung rieng, khong phai the)
  API.startUseItem()
  API.startPet()            -- pet di theo hero
  API.startHeroGate()       -- HeroMoveRegion -> nha chinh
  API.startSideQuest()      -- bon Thanh Thu dung san trong hang
  API.startPanel()

  API.startSkillFx()
  API.startFct()
  API.startBoss()
  API.startModifier()      -- tu chinh cua tung stage thuong
  API.startWaves()
  API.startHeroFrame()
  API.startSkillFrame()
  API.startFortuneFrame()
  API.startGameFrame()      -- bang tran dau, phim R
  API.startCamera()         -- lenh -zoom
  API.startWing()           -- canh theo moc canh gioi
  API.startQuest()          -- trang huong dan phim tat o F9
  API.startSkillPicking()
  API.startPicking()
  API.trace("startPicking: tra ve")

  API.registerEvents()
  API.trace("registerEvents: xong")

  S.running = true
  API.trace("BOOTSTRAP HOAN TAT")

  if CFG.DEBUG then
    -- KHONG ping 25 block o day nua. Lenh "-vung" da ping ca 25 o, va
    -- con to mau theo vai tro -- ban o day vua thua vua ban minimap
    -- ngay giay dau tien, luc nguoi choi con chua chon hero.
    --
    -- Muon xem luoi thi go "-vung".
    reportGrid()
    API.report()
    API.heroPickReport()
    API.dbg(n .. " nguoi choi vao map.")
  end
end

API.endGame    = endGame
API.reportGrid = reportGrid
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
  local function run()
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
    run()
  end

  run()
end
