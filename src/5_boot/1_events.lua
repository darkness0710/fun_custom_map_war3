-- ============================================================
--  1_events.lua  --  Trigger
--
--  Hai viec: nha chinh chet, va chan nguoi choi chon nha chinh.
--  Su kien popup chon hero do 07_heropick tu dang ky lay.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function onAnyDeath()
  local u = GetTriggerUnit()
  if u == nil then return end
  if u == S.house then
    API.onHouseDeath()
    return
  end
  -- Hero cua nguoi choi: hen gio song lai, va KHONG day sang
  -- onMobDeath -- ham do cong tien thuong cho ke giet.
  if API.onHeroDeath ~= nil and API.onHeroDeath(u) then return end
  API.onMobDeath(u, GetKillingUnit())
end

-- Nha chinh la muc tieu phai giu, khong phai quan de dieu khien. Lot
-- vao Ctrl+A roi lo ra lenh cho no la hong ca van.
--
-- Warcraft III khong co cach danh dau mot unit la "khong chon duoc" ma
-- van cho ke dich danh -- ability Locust lam no vo hinh voi ca hai phia,
-- ma nha chet la thua nen khong dung duoc. Nen phai bo chon thu cong.
local function onSelect()
  if CFG.HOUSE_SELECTABLE then return end
  if S.house == nil or GetTriggerUnit() ~= S.house then return end

  local p = GetTriggerPlayer()
  -- Hoan sang tick sau: doi trang thai ngay trong su kien cua engine la
  -- cong thuc gay loi, xem ADR 0005.
  API.after(0.0, function()
    if S.house ~= nil then SelectUnitRemoveForPlayer(S.house, p) end
  end)
end

-- Lenh thu: "-sp" phat mot diem ky nang cho hero cua nguoi go.
--
-- Tra loi TRONG MOI TRUONG HOP. Lenh thu im lang la thu vo dung nhat:
-- khong biet no that bai hay khong duoc dang ky.
local function onChat()
  local pid = GetPlayerId(GetTriggerPlayer())
  local d = S.p[pid]

  -- Lenh dang ky khop TIEN TO, nen "-spawn" cung roi vao day. Kiem lai
  -- chuoi day du roi hay lam gi -- neu khong thi moi lenh moi bat dau
  -- bang "-sp" deu bi lenh nay nuot.
  local raw = GetEventPlayerChatString()
  if raw ~= nil and raw:match("^%s*%-sp%s*$") == nil then return end

  if d == nil then
    API.warn(pid, "-sp: ban khong nam trong danh sach nguoi choi.")
    return
  end
  if d.hero == nil then
    API.warn(pid, "-sp: ban chua chon hero.")
    return
  end
  if CFG.SKILL_MODE == "learn" then
    if API.grantSkillPoints(d.hero, 1) then
      API.info(pid, CFG.C_GOLD .. "-sp: +1 diem ky nang." .. CFG.C_END ..
        " Bam nut + tren hero de chon.")
      API.info(pid, CFG.C_GREY .. "Khong thay nut + nghia la Techtree - Hero" ..
        " Abilities cua hero con rong." .. CFG.C_END)
    else
      API.warn(pid, "-sp: UnitModifySkillPoints tu choi.")
    end

  elseif CFG.SKILL_MODE == "pick" then
    API.showSkillPicker(pid)

  elseif CFG.SKILL_MODE == "frame" then
    API.showSkillFrame(pid)

  else
    API.warn(pid, "-sp: SKILL_MODE dang la \"" ..
      tostring(CFG.SKILL_MODE) .. "\" -- doi sang \"learn\", \"pick\" hoac \"frame\".")
  end
end

-- Lenh dev "-wave N": nhay thang toi stage N.
-- Khong co no thi khong ai kiem duoc stage 180 -- doi 2 tieng de xem
-- mot con so khong phai la cach lam viec.
local function onWaveCmd()
  local pid = GetPlayerId(GetTriggerPlayer())
  local raw = GetEventPlayerChatString()
  if raw == nil then return end

  local n = tonumber(raw:match("^%s*%-wave%s+(%d+)"))
  if n == nil then
    API.warn(pid, "Dung: -wave <so tu 1 den " ..
      API.totalStages() .. ">")
    return
  end
  API.jumpToStage(n)
  API.info(pid, CFG.C_GOLD .. "Nhay toi stage " .. n .. "." .. CFG.C_END)
end

-- "-lc" mo bang Linh Can, "-lc up" dot pha thang khong can bang.
local function onCultCmd()
  API.cultChat(GetPlayerId(GetTriggerPlayer()), GetEventPlayerChatString())
end

-- Lenh dev cho tien: "-go 300" Go, "-vang 5000" Vang.
-- Khong co no thi muon thu bac Tu Vi 15 phai cay 155 wave.
--
-- "-lk" DA BO. No lech dung MOT ky tu voi "-lc" (mo the Tu Vi), va hai
-- lenh do lam hai viec khac han nhau -- go nham la cong tien thay vi mo
-- bang. Muon Linh Khi thi dung "-debug", no day het ca bon dong tien.
local function onMoneyCmd()
  local pid = GetPlayerId(GetTriggerPlayer())
  local raw = GetEventPlayerChatString()
  if raw == nil then return end

  local n = tonumber(raw:match("^%s*%-go%s+(%d+)"))
  if n ~= nil then
    API.addLumber(pid, n)
    API.info(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " go -> " ..
      API.num(API.getLumber(pid)) .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  n = tonumber(raw:match("^%s*%-vang%s+(%d+)"))
  if n ~= nil then
    API.addGold(pid, n)
    API.info(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " vang -> " ..
      API.num(API.getGold(pid)) .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  API.warn(pid, "Dung: -go <so> | -vang <so>")
end


-- "-debug": day CA BON dong tien len CFG.DEBUG_MONEY.
--
-- Chi chay khi CFG.DEBUG bat -- KHAC voi nhom lenh dev o tren (chung
-- theo CFG.DEV_COMMANDS). Hai cong tac tach nhau la co y: tat bao cao
-- chi tiet van go duoc lenh dev, va nguoc lai. Lenh nay dua het tien
-- cho nguoi choi nen no thuoc ve cong tac "dang soi ky", khong phai
-- cong tac "dang go lenh".
local function onDebugCmd()
  local pid = GetPlayerId(GetTriggerPlayer())

  -- Khop chat: "-debug" hoac "-debug   ", KHONG an "-debugxyz".
  local raw = GetEventPlayerChatString()
  if raw == nil or raw:match("^%s*%-debug%s*$") == nil then return end

  -- Cong tac tat thi NOI RA. Khong lam gi ma cung khong bao la kieu
  -- hong te nhat: nguoi go tuong lenh hong, di sua nham cho khac.
  if not CFG.DEBUG then
    API.warn(pid, "-debug can CFG.DEBUG = true" .. CFG.C_END ..
      CFG.C_GREY .. "  (sua o dau src/1_core/1_config.lua roi chay lai build.py)")
    API.trace("-debug: TU CHOI -- CFG.DEBUG = false")
    return
  end

  local n = CFG.DEBUG_MONEY or 999999

  API.addQi(pid, n)
  API.addGold(pid, n)
  API.addLumber(pid, n)
  if API.addIron ~= nil then API.addIron(pid, n) end

  API.info(pid, CFG.C_GOLD .. "[debug] +" .. API.num(n) ..
    " moi loai" .. CFG.C_END .. CFG.C_GREY ..
    "  (Linh Khi " .. API.num(API.getQi(pid)) ..
    " | Vang " .. API.num(API.getGold(pid)) ..
    " | Go " .. API.num(API.getLumber(pid)) ..
    " | Da " .. API.num((API.getIron ~= nil) and API.getIron(pid) or 0) ..
    ")" .. CFG.C_END)
  API.panelRefresh(pid)
  API.trace("debug: pid " .. pid .. " +" .. n .. " ca bon dong tien")
end

local function registerEvents()
  local tDeath = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(tDeath, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddAction(tDeath, onAnyDeath)

  if not CFG.HOUSE_SELECTABLE then
    local tSelect = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerUnitEvent(tSelect, Player(S.pids[i]),
                                     EVENT_PLAYER_UNIT_SELECTED, nil)
    end
    TriggerAddAction(tSelect, onSelect)
  end

  -- Nha chinh la hero, ma hero Warcraft co san sau o tui: keo mot binh
  -- mau tha vao no la binh do bien mat vao tui nha chinh. Tra ngay ra
  -- dat -- xem onHousePickup() trong 3_battle/1_house.lua.
  if EVENT_PLAYER_UNIT_PICKUP_ITEM ~= nil and API.onHousePickup ~= nil then
    local tPickup = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(tPickup, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(tPickup, API.onHousePickup)
  else
    API.trace("house: KHONG co EVENT_PLAYER_UNIT_PICKUP_ITEM -- " ..
              "nha chinh van co the nuot do")
  end

  if CFG.DEV_COMMANDS then
    local tChat = CreateTrigger()
    for i = 1, #S.pids do
      -- exactMatch = false: "-sp " thua dau cach van an
      TriggerRegisterPlayerChatEvent(tChat, Player(S.pids[i]), "-sp", false)
    end
    TriggerAddAction(tChat, onChat)

    local tWave = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tWave, Player(S.pids[i]), "-wave", false)
    end
    TriggerAddAction(tWave, onWaveCmd)
  end

  if CFG.DEV_COMMANDS then
    local tMoney = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-go", false)
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-vang", false)
    end
    TriggerAddAction(tMoney, onMoneyCmd)
  end

  -- "-debug" theo CFG.DEBUG, khong theo CFG.DEV_COMMANDS.
  --
  -- LUON DANG KY, con CHAY hay khong thi hoi CFG.DEBUG o trong ham.
  --
  -- Ban truoc boc ca cum trong "if CFG.DEBUG then": cong tac tat thi
  -- trigger khong ton tai, go lenh ra khong co gi, va khong mot dong
  -- nao noi vi sao. Dung cai kieu "nuot loi" ma CLAUDE.md cam.
  --
  -- Khop TIEN TO chu khong khop chinh xac: "-debug " thua mot dau cach
  -- van phai an -- bai hoc da ghi san o lenh "-sp". Phan chan
  -- "-debugxyz" chuyen vao ham, bang mot phep khop chat.
  local tDebug = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tDebug, Player(S.pids[i]), "-debug", false)
  end
  TriggerAddAction(tDebug, onDebugCmd)
  API.trace("lenh -debug: " ..
            (CFG.DEBUG and "BAT" or "TAT (CFG.DEBUG = false)"))

  -- Loi choi, khong phai lenh dev -- luon dang ky.
  local tCult = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tCult, Player(S.pids[i]), "-lc", false)
  end
  TriggerAddAction(tCult, onCultCmd)

  -- "-next" goi dot ke tiep. LUON dang ky, khong theo DEV_COMMANDS.
  --
  -- Duong CHINH la nut tren bang tran dau (phim R). Lenh nay giu lai lam
  -- DUONG LUI: framesAvailable() co the tra false (thieu native frame),
  -- va luc do khong con cach nao khoi dong van -- bang nhan vat da phai
  -- in "Khong ve duoc bang -- dung lenh chat" vi dung ly do do.
  --
  -- Khong phai lenh cheat: no doi da don sach quai moi goi duoc, nen
  -- khong bo qua duoc phan nao ca.
  do
    local tNext = CreateTrigger()
    for i = 1, #S.pids do
      -- false = khop TIEN TO. Voi true thi go du mot dau cach thua la
      -- khong khop, va khong khop thi im lang hoan toan.
      TriggerRegisterPlayerChatEvent(tNext, Player(S.pids[i]), "-next", false)
    end
    TriggerAddAction(tNext, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      API.trace("-next: pid " .. pid .. ", song=" .. S.alive ..
                ", stage=" .. S.stage)
      -- Chi goi som duoc khi da don sach. Cho phep goi som luc con quai
      -- la cho nguoi choi bo qua phan kho cua wave nay va nhan tien cua
      -- wave sau -- pha dung cai duong cong dang giu ca van.
      if S.alive > 0 then
        API.msg(pid, CFG.C_RED .. API.t("wave_notclear", S.alive) .. CFG.C_END)
        return
      end
      -- Dang o cua so nghi thi -next la thu DUY NHAT di tiep duoc, nen
      -- bao ro ai la nguoi bam.
      local waiting = API.waveWaiting()
      if API.waveNow() then
        -- Dung CHUNG khoa voi nut goi dot trong 6_gameframe.lua: hai
        -- duong lam cung mot viec thi phai noi cung mot cau.
        API.msg(nil, CFG.C_GREY ..
          API.t("wave_called", GetPlayerName(Player(pid))) ..
          (waiting ~= nil and (" (" .. waiting .. ")") or "") .. CFG.C_END)
      end
    end)
  end

  -- "-icon <ma>": tao mot item roi in TEN va DUONG DAN ICON THAT cua no.
  --
  -- Day la cach duy nhat biet mot duong dan icon co that: game dong goi
  -- bang CASC nen khong liet ke tu ngoai duoc, ma go nham thi Warcraft
  -- ve o XANH LA chu khong bao loi. Doan ba lan, sai ba lan.
  --
  -- Dung de di tim icon cho CFG.GEAR: "-icon ciri", "-icon hval"...
  -- thay cai nao hop nghia thi chep duong dan vao bang.
  if CFG.DEV_COMMANDS then
    local tIcon = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tIcon, Player(S.pids[i]), "-icon", false)
    end
    TriggerAddAction(tIcon, function()
      local pid  = GetPlayerId(GetTriggerPlayer())
      local code = GetEventPlayerChatString():match("^%s*%-icon%s+(%S%S%S%S)")
      if code == nil then
        API.warn(pid, "Dung: -icon <4 ky tu>, vi du -icon bspd")
        return
      end
      if CreateItem == nil then
        API.warn(pid, "-icon: ban nay khong co CreateItem.")
        return
      end
      local it = CreateItem(FourCC(code), 0.0, 0.0)
      if it == nil then
        API.warn(pid, "-icon " .. code .. ": khong co item nay.")
        API.trace("icon " .. code .. ": KHONG CO")
        return
      end
      local name = (GetItemName ~= nil) and GetItemName(it) or "?"
      local path = (BlzGetItemIconPath ~= nil) and BlzGetItemIconPath(it) or "?"
      API.msg(pid, CFG.C_GOLD .. code .. CFG.C_END .. "  " .. name)
      API.msg(pid, CFG.C_GREY .. "   " .. tostring(path) .. CFG.C_END)
      API.trace("icon " .. code .. " = " .. name .. " | " .. tostring(path))
      RemoveItem(it)
    end)
  end

  -- "-fx <duong dan>": ve thu mot model ngay duoi chan hero.
  --
  -- Model go sai duong dan thi Warcraft KHONG ve gi va KHONG bao loi --
  -- im hon ca icon, vi icon con ra o xanh la de thay. Khong co cach nao
  -- BIET mot duong dan model co that ngoai viec ve thu.
  --
  --   -fx Abilities\Spells\Human\Avatar\AvatarCaster.mdl
  --
  -- Thay hien ra gi thi chep duong dan vao CFG.FX_SLAM_* / FX_HIT_*.
  if CFG.DEV_COMMANDS then
    local tFx = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tFx, Player(S.pids[i]), "-fx", false)
    end
    TriggerAddAction(tFx, function()
      local pid  = GetPlayerId(GetTriggerPlayer())
      local path = GetEventPlayerChatString():match("^%s*%-fx%s+(.+)$")
      if path == nil then
        API.msg(pid, CFG.C_RED ..
          "Dung: -fx <duong dan .mdl>" .. CFG.C_END)
        return
      end
      path = path:gsub("%s+$", "")
      local d = S.p[pid]
      local h = d and d.hero or nil
      if h == nil then
        API.warn(pid, "-fx: ban chua co hero.")
        return
      end
      API.fx(path, GetUnitX(h), GetUnitY(h))
      -- Khong the biet no CO ve ra hay khong: AddSpecialEffect tra ve
      -- mot handle du duong dan sai. Nen phai NHIN, va dong nay chi de
      -- doi chieu xem vua thu cai nao.
      API.msg(pid, CFG.C_GREY .. "[fx] " .. path ..
        CFG.C_END .. CFG.C_GOLD .. "  -- nhin xem co gi hien khong" ..
        CFG.C_END)
      API.trace("fx thu: " .. path)
    end)
  end

  -- "-spawn": tao thang mot con H001 bang CreateUnit, canh hero.
  --
  -- De so sanh voi con dat san trong World Editor: cung loai unit, cung
  -- man hinh, mot con do WE dat, mot con do code tao. Neu chi con do code
  -- tao bi den thi loi nam o cach tao, khong phai o file model.
  if CFG.DEV_COMMANDS then
    local tSpawn = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tSpawn, Player(S.pids[i]), "-spawn", false)
    end
    TriggerAddAction(tSpawn, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      local d = S.p[pid]
      local x, y = S.houseX or 0.0, S.houseY or 0.0
      if d ~= nil and d.hero ~= nil then
        x, y = GetUnitX(d.hero) + 200.0, GetUnitY(d.hero)
      end
      local uid = CFG.HEROES[1] and CFG.HEROES[1].id
      local u = CreateUnit(Player(pid), uid, x, y, 270.0)
      API.info(pid, CFG.C_GREY .. "[dev] CreateUnit " .. API.idToStr(uid) ..
        (u ~= nil and " -> ok" or " -> NIL") .. CFG.C_END)
      API.trace("-spawn: " .. API.idToStr(uid) ..
                (u ~= nil and " tao duoc" or " TAO THAT BAI"))
    end)
  end

  -- "-sync" bao duong dong bo nao dang chay va ping co ve khong. Luon
  -- dang ky: khi bang khong an thi day la cho dau tien phai nhin.
  local tSync = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tSync, Player(S.pids[i]), "-sync", true)
  end
  TriggerAddAction(tSync, function()
    API.syncChat(GetPlayerId(GetTriggerPlayer()))
  end)

  -- "-nat" liet ke native ban nay co. Luon dang ky: khi mot he im lang
  -- khong chay, day la cho thu hai phai nhin sau file vet.
  local tNat = CreateTrigger()
  for i = 1, #S.pids do
    -- false = khop TIEN TO. Voi true thi "-nat dam" khong khop gi ca va
    -- trigger khong no -- go lenh xong im lang, tuong la khong co ket qua.
    TriggerRegisterPlayerChatEvent(tNat, Player(S.pids[i]), "-nat", false)
  end
  TriggerAddAction(tNat, function()
    API.nativeChat(GetPlayerId(GetTriggerPlayer()), GetEventPlayerChatString())
  end)

  -- "-mod N" ep mot tu chinh de XEM kieu troi cua no ngay, thay vi doi
  -- RNG boc trung. Cung la cach tra loi "troi khong chay hay chay ma mo".
  if CFG.DEV_COMMANDS then
    local tMod = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tMod, Player(S.pids[i]), "-mod", false)
    end
    TriggerAddAction(tMod, function()
      if API.modifierDevSet ~= nil then
        API.modifierDevSet(GetPlayerId(GetTriggerPlayer()),
                           GetEventPlayerChatString())
      end
    end)
  end

  -- "-sky N" bat MOT ma thoi tiet de nhin. Xem chu thich devSky().
  if CFG.DEV_COMMANDS then
    local tSky = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tSky, Player(S.pids[i]), "-sky", false)
    end
    TriggerAddAction(tSky, function()
      if API.modifierDevSky ~= nil then
        API.modifierDevSky(GetPlayerId(GetTriggerPlayer()),
                           GetEventPlayerChatString())
      end
    end)
  end

  -- "-reg" DO hoi mau that cua hero. Lenh dev: no ha mau hero xuong nua
  -- va doi chi so trong luc do, khong phai thu de go giua tran.
  if CFG.DEV_COMMANDS then
    local tReg = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tReg, Player(S.pids[i]), "-reg", false)
    end
    TriggerAddAction(tReg, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      local raw = GetEventPlayerChatString() or ""
      -- "-reg" mau | "-reg mana" mana | "-reg 5" / "-reg mana 5" doi so giay
      local kind = raw:find("mana", 1, true) and "mana" or "hp"
      API.nativeRegen(pid, tonumber(raw:match("(%d+)")), kind)
    end)
  end

  -- Ba lenh dev de thu he QUAY ma khong phai cay quai.
  --
  -- "-don"     giet sach quai dang song. Day la cai dang gia nhat: no
  --            di qua DUNG duong that -- su kien chet -> rewardAll ->
  --            cong tien + luot quay -> wave sau ra. Thu bang -quay thi
  --            chi thu duoc cai bang, con -don thu ca day chuyen.
  -- "-quay N"  cong thang N luot quay.
  -- "-da N"    cong thang N da Huyen Thiet.
-- ---------- Phep do chu tieng Viet co dau ----------
--
-- CAU HOI: ban 1.31.1 co ve duoc chu tieng Viet co dau khong?
--
-- Ca du an dang viet KHONG DAU vi tin rang khong ve duoc -- nhung chua
-- ai do. Lenh "-font" tra loi bang mot phep thu duy nhat.
--
-- GHEP TU MA UNICODE, khong go chu co dau thang vao file. Hai ly do:
--   1. ascii.py cam ky tu ngoai ASCII trong src/
--   2. quan trong hon: cach nay CHUNG MINH byte gui di la byte nao,
--      khong phu thuoc vao viec file duoc luu bang ma hoa gi
local function u8(cp)
  if cp < 0x80 then return string.char(cp) end
  if cp < 0x800 then
    return string.char(0xC0 + math.floor(cp / 0x40), 0x80 + cp % 0x40)
  end
  return string.char(0xE0 + math.floor(cp / 0x1000),
                     0x80 + math.floor(cp / 0x40) % 0x40,
                     0x80 + cp % 0x40)
end

-- Sau ma RIENG cua tieng Viet -- khong nam trong Latin-1, nen font nao
-- chi phu Latin-1 (nhu VNARIAL) se truot het sau cai.
local VN = {
  { 0x1EA3, "a hoi" }, { 0x1EC7, "e nang" }, { 0x01B0, "u moc" },
  { 0x0110, "D gach" }, { 0x1EF9, "y nga" }, { 0x1EDF, "o hoi" },
}

-- In ra CA HAI noi, va do la ca phep do:
--
--   man hinh dung + file vet dung  -> ve duoc, khong can nhap font
--   man hinh SAI  + file vet dung  -> byte qua build.py nguyen ven,
--                                     font THIEU GLYPH -> nhap font
--   file vet SAI                   -> build.py lam hong byte,
--                                     nhap font cung vo ich
local function fontProbe(pid)
  local line = ""
  for i = 1, #VN do
    line = line .. VN[i][2] .. "=[" .. u8(VN[i][1]) .. "]  "
  end
  API.info(pid, CFG.C_GOLD .. "[dev] chu co dau:" .. CFG.C_END)
  API.info(pid, "   " .. line)
  API.msg(pid, "   " .. line)
  API.trace("font: " .. line)
  for i = 1, #VN do
    API.trace(string.format("font:   U+%04X %-8s byte %s",
      VN[i][1], VN[i][2],
      (function()
        local b, out = u8(VN[i][1]), {}
        for k = 1, #b do out[#out + 1] = string.format("%02X", b:byte(k)) end
        return table.concat(out, " ")
      end)()))
  end
end

  if CFG.DEV_COMMANDS then
    local tDev = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-don", false)
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-quay", false)
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-da", false)
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-font", false)
    end
    TriggerAddAction(tDev, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      local raw = GetEventPlayerChatString() or ""
      local n   = tonumber(raw:match("(%d+)"))

      if raw:match("^%s*%-font") ~= nil then
        fontProbe(pid)
        return
      end

      if raw:match("^%s*%-don") ~= nil then
        -- Gom ra danh sach TRUOC khi giet: onMobDeath xoa khoi S.mobs
        -- ngay giua chung, ma sua mot bang dang duyet bang pairs() la
        -- hanh vi khong xac dinh trong Lua.
        local ds = {}
        for u, _ in pairs(S.mobs) do ds[#ds + 1] = u end
        local d = 0
        for i2 = 1, #ds do
          if API.alive(ds[i2]) then KillUnit(ds[i2]); d = d + 1 end
        end
        API.info(pid, CFG.C_GREY .. "[dev] da giet " .. d .. " con." .. CFG.C_END)
        return
      end

      if raw:match("^%s*%-quay") ~= nil then
        n = n or 10
        if API.fortuneAddRolls ~= nil then API.fortuneAddRolls(pid, n) end
        API.info(pid, CFG.C_GREY .. "[dev] +" .. n .. " luot quay." .. CFG.C_END)
        API.panelRefresh(pid)
        return
      end

      if raw:match("^%s*%-da") ~= nil then
        n = n or 100
        local d = S.p[pid]
        if d ~= nil then API.addIron(pid, n) end
        API.info(pid, CFG.C_GREY .. "[dev] +" .. n .. " da." .. CFG.C_END)
        API.panelRefresh(pid)
        return
      end
    end)
  end

  -- "-vung" in ban do phan vung 25 block va ping minimap theo mau.
  --
  -- Luon dang ky, khong theo DEV_COMMANDS: chua he nao gan vao block,
  -- nen day la cach DUY NHAT nhin thay bang CFG.BLOCKS co dung nhu dinh
  -- khong -- va de doi chieu voi vung Blk.. trong World Editor.
  local tRegion = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tRegion, Player(S.pids[i]), "-vung", true)
  end
  TriggerAddAction(tRegion, function()
    local pid = GetPlayerId(GetTriggerPlayer())
    API.info(pid, CFG.C_GOLD .. "=== Phan vung 25 block ===" .. CFG.C_END)

    local missing = 0
    -- In tu hang TREN xuong, dung chieu nguoi choi nhin ban do.
    for row = S.grid.rows, 1, -1 do
      local line = ""
      for col = 1, S.grid.cols do
        local idx = API.blockIndex(col, row)
        local d   = API.blockRoleDef(idx)
        if API.blockRegion(idx) == nil then missing = missing + 1 end
        line = line .. string.format("%-14s", idx .. " " .. API.pick(d))
      end
      API.msg(pid, line)
    end

    -- Ping tam moi block, mau theo vai tro.
    API.forEachBlock(function(col, row, idx, x0, y0, x1, y1)
      local m = API.blockRoleDef(idx).color
      PingMinimapEx((x0 + x1) * 0.5, (y0 + y1) * 0.5, 6.0,
                    m[1], m[2], m[3], false)
    end)

    if missing > 0 then
      API.warn(pid, "Thieu " .. missing .. " vung " ..
        CFG.BLOCK_RGN_PREFIX .. ".. trong World Editor." .. CFG.C_END ..
        CFG.C_GREY .. " Chay: python w3region.py gen")
    end
    API.msg(pid, CFG.C_GREY ..
      "Chua he nao gan vao block -- day moi la ban do." .. CFG.C_END)
  end)

  -- "-c" mo bang nhan vat, duong lui neu phim E khong gan duoc.
  local tPanel = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tPanel, Player(S.pids[i]), "-c", true)
  end
  TriggerAddAction(tPanel, function()
    API.panelToggle(GetPlayerId(GetTriggerPlayer()))
  end)

  API.dbg("Trigger da dang ky.")
end

API.registerEvents = registerEvents
