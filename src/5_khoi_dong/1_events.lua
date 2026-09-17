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
    API.msg(pid, CFG.C_RED .. "-sp: ban khong nam trong danh sach nguoi choi." .. CFG.C_END)
    return
  end
  if d.hero == nil then
    API.msg(pid, CFG.C_RED .. "-sp: ban chua chon hero." .. CFG.C_END)
    return
  end
  if CFG.SKILL_MODE == "learn" then
    if API.grantSkillPoints(d.hero, 1) then
      API.msg(pid, CFG.C_GOLD .. "-sp: +1 diem ky nang." .. CFG.C_END ..
        " Bam nut + tren hero de chon.")
      API.msg(pid, CFG.C_GREY .. "Khong thay nut + nghia la Techtree - Hero" ..
        " Abilities cua hero con rong." .. CFG.C_END)
    else
      API.msg(pid, CFG.C_RED .. "-sp: UnitModifySkillPoints tu choi." .. CFG.C_END)
    end

  elseif CFG.SKILL_MODE == "pick" then
    API.showSkillPicker(pid)

  elseif CFG.SKILL_MODE == "frame" then
    API.showSkillFrame(pid)

  else
    API.msg(pid, CFG.C_RED .. "-sp: SKILL_MODE dang la \"" ..
      tostring(CFG.SKILL_MODE) .. "\" -- doi sang \"learn\", \"pick\" hoac \"frame\"."
      .. CFG.C_END)
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
    API.msg(pid, CFG.C_RED .. "Dung: -wave <so tu 1 den " ..
      API.totalStages() .. ">" .. CFG.C_END)
    return
  end
  API.jumpToStage(n)
  API.msg(pid, CFG.C_GOLD .. "Nhay toi stage " .. n .. "." .. CFG.C_END)
end

-- "-lc" mo bang Linh Can, "-lc up" dot pha thang khong can bang.
local function onLinhCanCmd()
  API.linhCanChat(GetPlayerId(GetTriggerPlayer()), GetEventPlayerChatString())
end

-- Lenh dev cho tien: "-lk 5000" Linh Khi, "-go 300" Go, "-vang 5000" Vang.
-- Khong co no thi muon thu bac Linh Can 15 phai cay 155 wave.
local function onMoneyCmd()
  local pid = GetPlayerId(GetTriggerPlayer())
  local raw = GetEventPlayerChatString()
  if raw == nil then return end

  local n = tonumber(raw:match("^%s*%-lk%s+(%d+)"))
  if n ~= nil then
    API.addLinhKhi(pid, n)
    API.msg(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " linh khi -> " ..
      API.num(API.getLinhKhi(pid)) .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  n = tonumber(raw:match("^%s*%-go%s+(%d+)"))
  if n ~= nil then
    API.addGo(pid, n)
    API.msg(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " go -> " ..
      API.num(API.getGo(pid)) .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  n = tonumber(raw:match("^%s*%-vang%s+(%d+)"))
  if n ~= nil then
    API.addVang(pid, n)
    API.msg(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " vang -> " ..
      API.num(API.getVang(pid)) .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  API.msg(pid, CFG.C_RED .. "Dung: -lk <so> | -go <so> | -vang <so>" .. CFG.C_END)
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
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-lk", false)
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-go", false)
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-vang", false)
    end
    TriggerAddAction(tMoney, onMoneyCmd)
  end

  -- Loi choi, khong phai lenh dev -- luon dang ky.
  local tLC = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tLC, Player(S.pids[i]), "-lc", false)
  end
  TriggerAddAction(tLC, onLinhCanCmd)

  -- "-next" goi dot ke tiep. LUON dang ky, khong theo DEV_COMMANDS:
  -- voi CFG.WAVE_WAIT_FIRST thi day la thu duy nhat khoi dong duoc van,
  -- tat no di la ngoi nhin man hinh trong mai mai.
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
      local cho = API.waveWaiting()
      if API.waveNow() then
        API.msg(nil, CFG.C_GREY .. GetPlayerName(Player(pid)) ..
          " -> " .. API.t("wave_next") ..
          (cho ~= nil and (" (" .. cho .. ")") or "") .. CFG.C_END)
      end
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
      API.msg(pid, CFG.C_GREY .. "[dev] CreateUnit " .. API.idToStr(uid) ..
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
      local loai = raw:find("mana", 1, true) and "mana" or "hp"
      API.nativeRegen(pid, tonumber(raw:match("(%d+)")), loai)
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
  if CFG.DEV_COMMANDS then
    local tDev = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-don", false)
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-quay", false)
      TriggerRegisterPlayerChatEvent(tDev, Player(S.pids[i]), "-da", false)
    end
    TriggerAddAction(tDev, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      local raw = GetEventPlayerChatString() or ""
      local n   = tonumber(raw:match("(%d+)"))

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
        API.msg(pid, CFG.C_GREY .. "[dev] da giet " .. d .. " con." .. CFG.C_END)
        return
      end

      if raw:match("^%s*%-quay") ~= nil then
        n = n or 10
        if API.quayThemLuot ~= nil then API.quayThemLuot(pid, n) end
        API.msg(pid, CFG.C_GREY .. "[dev] +" .. n .. " luot quay." .. CFG.C_END)
        API.panelRefresh(pid)
        return
      end

      if raw:match("^%s*%-da") ~= nil then
        n = n or 100
        local d = S.p[pid]
        if d ~= nil then API.addDa(pid, n) end
        API.msg(pid, CFG.C_GREY .. "[dev] +" .. n .. " da." .. CFG.C_END)
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
  local tVung = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tVung, Player(S.pids[i]), "-vung", true)
  end
  TriggerAddAction(tVung, function()
    local pid = GetPlayerId(GetTriggerPlayer())
    API.msg(pid, CFG.C_GOLD .. "=== Phan vung 25 block ===" .. CFG.C_END)

    local thieu = 0
    -- In tu hang TREN xuong, dung chieu nguoi choi nhin ban do.
    for row = S.grid.rows, 1, -1 do
      local line = ""
      for col = 1, S.grid.cols do
        local idx = API.blockIndex(col, row)
        local d   = API.blockRoleDef(idx)
        if API.blockRegion(idx) == nil then thieu = thieu + 1 end
        line = line .. string.format("%-14s", idx .. " " .. API.pick(d))
      end
      API.msg(pid, line)
    end

    -- Ping tam moi block, mau theo vai tro.
    API.forEachBlock(function(col, row, idx, x0, y0, x1, y1)
      local m = API.blockRoleDef(idx).mau
      PingMinimapEx((x0 + x1) * 0.5, (y0 + y1) * 0.5, 6.0,
                    m[1], m[2], m[3], false)
    end)

    if thieu > 0 then
      API.msg(pid, CFG.C_RED .. "Thieu " .. thieu .. " vung " ..
        CFG.BLOCK_RGN_PREFIX .. ".. trong World Editor." .. CFG.C_END ..
        CFG.C_GREY .. " Chay: python w3region.py gen" .. CFG.C_END)
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
