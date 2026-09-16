-- ============================================================
--  1_player.lua  --  Dang ky nguoi choi va quan he dong minh
--
--  Buoc 1 chi lam dung hai viec: biet ai dang choi, va dat quan he
--  ba nguoi choi <-> phe dich. Chua co hero, chua co chi so.
-- ============================================================

local function initPlayers()
  S.pids = {}
  S.p = {}

  for i = 1, #CFG.PLAYER_SLOTS do
    local pid = CFG.PLAYER_SLOTS[i]
    local p = Player(pid)
    -- Slot trong hoac do may giu deu bi bo qua, nen choi mot minh van vao duoc.
    if GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING
       and GetPlayerController(p) == MAP_CONTROL_USER then
      S.p[pid] = { active = true, hero = nil, heroCount = 0,
                   slots = {},
                   linhKhi = 0, linhKhiTotal = 0,
                   linhCan = 1, fctGold = 0,

                   tb = {},       -- [so thu tu o trang bi] = cap
                   tbUps = 0,     -- tong so lan da nang, de tra gia
                   pk = {} }      -- [ma phap khi] = true
      S.pids[#S.pids + 1] = pid
    end
  end

  -- Ba nguoi choi la dong minh, chung tam nhin.
  for i = 1, #S.pids do
    for j = 1, #S.pids do
      if i ~= j then
        SetPlayerAllianceStateBJ(Player(S.pids[i]), Player(S.pids[j]), bj_ALLIANCE_ALLIED_VISION)
      end
    end
  end

  -- Phe dich doi dau voi tat ca.
  S.enemy = Player(CFG.ENEMY_SLOT)
  for i = 1, #S.pids do
    SetPlayerAllianceStateBJ(S.enemy, Player(S.pids[i]), bj_ALLIANCE_UNALLIED)
    SetPlayerAllianceStateBJ(Player(S.pids[i]), S.enemy, bj_ALLIANCE_UNALLIED)
  end

  -- Nha chinh dung slot rieng, khong thuoc ve rieng ai. No la dong minh
  -- cua ca ba nguoi choi va CHUNG TAM NHIN -- nho vay tam nhin 1500 cua
  -- no moi co ich cho ho. Va no doi dau voi phe dich de bi nham lam
  -- muc tieu.
  S.houseOwner = Player(CFG.HOUSE_SLOT)
  for i = 1, #S.pids do
    SetPlayerAllianceStateBJ(Player(S.pids[i]), S.houseOwner, bj_ALLIANCE_ALLIED_VISION)
    SetPlayerAllianceStateBJ(S.houseOwner, Player(S.pids[i]), bj_ALLIANCE_ALLIED_VISION)
  end
  SetPlayerAllianceStateBJ(S.houseOwner, S.enemy, bj_ALLIANCE_UNALLIED)
  SetPlayerAllianceStateBJ(S.enemy, S.houseOwner, bj_ALLIANCE_UNALLIED)

  -- Tat quyen dieu khien chung mot cach TUONG MINH.
  -- bj_ALLIANCE_ALLIED_VISION o tren da tat san, nhung dat lai ro rang
  -- thi doc code khong phai tra xem hang so BJ do bat/tat nhung gi.
  if SetPlayerAlliance ~= nil and ALLIANCE_SHARED_CONTROL ~= nil then
    for i = 1, #S.pids do
      local p = Player(S.pids[i])
      SetPlayerAlliance(p, S.houseOwner, ALLIANCE_SHARED_CONTROL, false)
      SetPlayerAlliance(S.houseOwner, p, ALLIANCE_SHARED_CONTROL, false)
      if ALLIANCE_SHARED_ADVANCED_CONTROL ~= nil then
        SetPlayerAlliance(p, S.houseOwner, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
        SetPlayerAlliance(S.houseOwner, p, ALLIANCE_SHARED_ADVANCED_CONTROL, false)
      end
    end
  end

  -- Slot nha chinh trung slot nguoi choi hoac slot dich thi quan he
  -- dong minh o tren se da nhau. Bao ngay thay vi de no hong am tham.
  if CFG.HOUSE_SLOT == CFG.ENEMY_SLOT then
    API.msg(nil, CFG.C_RED .. "CFG.HOUSE_SLOT trung ENEMY_SLOT -- nha chinh dang"
      .. " thuoc phe dich." .. CFG.C_END)
  end
  for i = 1, #CFG.PLAYER_SLOTS do
    if CFG.PLAYER_SLOTS[i] == CFG.HOUSE_SLOT then
      API.msg(nil, CFG.C_RED .. "CFG.HOUSE_SLOT trung slot nguoi choi "
        .. CFG.HOUSE_SLOT .. "." .. CFG.C_END)
    end
  end

  return #S.pids
end

-- ---------- Khoa hero: kinh nghiem & ky nang ----------
--
-- SuspendHeroXP chan viec NHAN kinh nghiem, nen hero dung yen o cap
-- hien tai. Goi nhieu lan len cung mot unit la vo hai, nen bo quet co
-- the chay lai thoai mai.

-- Rut sach diem ky nang.
--
-- Warcraft III khong co native doc so diem ky nang hien co, nen tru dan
-- tung diem toi khi native bao khong tru duoc nua. Chan 20 vong de
-- khong bao gio treo du native co tra ve gi.
local function stripSkillPoints(u)
  if not CFG.STRIP_SKILL_POINTS then return 0, "tat" end
  if UnitModifySkillPoints == nil then return 0, "native khong ton tai" end

  local n = 0
  for _ = 1, 20 do
    if not UnitModifySkillPoints(u, -1) then break end
    n = n + 1
  end
  return n, "ok"
end

-- Phat diem ky nang. Dung o che do "learn" -- goi luc tao hero, hoac
-- bat cu khi nao ban muon thuong (don sach dot quai, moc thoi gian...).
local function grantSkillPoints(u, n)
  if u == nil or n == nil or n <= 0 then return false end
  if UnitModifySkillPoints == nil then return false end
  if CFG.STRIP_SKILL_POINTS then
    API.msg(nil, CFG.C_RED .. "Phat diem ky nang khi STRIP_SKILL_POINTS con bat" ..
      " -- bo quet se an mat ngay." .. CFG.C_END)
  end
  return UnitModifySkillPoints(u, n)
end

-- Do danh sach ability THAT cua hero ra file vet. Moi unit chi do mot
-- lan de khong lam ngap file.
--
-- Day la cach lay ID that thay vi doan: danh sach ID hero skill tren
-- mang khong dang tin, va doan sai thi UnitRemoveAbility im lang khong
-- lam gi -- kieu that bai kho phat hien nhat.
local function dumpAbilities(u)
  if not CFG.TRACE or S.dumped[u] then return end
  if BlzGetUnitAbilityByIndex == nil or BlzGetAbilityId == nil then
    API.trace("abil: khong co BlzGetUnitAbilityByIndex de liet ke")
    S.dumped[u] = true
    return
  end
  S.dumped[u] = true

  local list = {}
  for i = 0, 40 do
    local ab = BlzGetUnitAbilityByIndex(u, i)
    if ab == nil then break end
    list[#list + 1] = API.idToStr(BlzGetAbilityId(ab))
  end
  API.trace("abil " .. GetUnitName(u) .. " (" .. #list .. "): " ..
            table.concat(list, " "))
end

-- Go ky nang goc, va GHI LAI ket qua tung id.
--
-- UnitRemoveAbility tra ve boolean: true nghia la unit CO ability do va
-- da go duoc, false nghia la unit khong he co no. Day la cach duy nhat
-- con lai de biet id doan dung hay sai, vi 1.31.1 khong co
-- BlzGetUnitAbilityByIndex de liet ke truc tiep.
local function removeStockAbilities(u)
  local report = (CFG.TRACE and not S.abilReported[u])
  if report then S.abilReported[u] = true end

  local hits = {}
  for i = 1, #CFG.HERO_REMOVE_ABILITIES do
    local aid = CFG.HERO_REMOVE_ABILITIES[i]
    local ok = UnitRemoveAbility(u, aid)
    if report and ok then hits[#hits + 1] = API.idToStr(aid) end
  end

  if report then
    if #hits == 0 then
      API.trace("remove " .. GetUnitName(u) .. ": KHONG id nao trung " ..
                "(" .. #CFG.HERO_REMOVE_ABILITIES .. " id da thu)")
    else
      API.trace("remove " .. GetUnitName(u) .. ": go duoc " ..
                table.concat(hits, " "))
    end
  end
end

local function lockHero(u)
  if u == nil then return false end
  if not IsUnitType(u, UNIT_TYPE_HERO) then return false end

  if CFG.LOCK_HERO_XP then SuspendHeroXP(u, true) end

  local n, how = stripSkillPoints(u)
  if not S.spReported[u] then
    S.spReported[u] = true
    API.trace("skillpoint " .. GetUnitName(u) .. ": rut " .. n .. " diem (" .. how .. ")")
  end

  dumpAbilities(u)
  removeStockAbilities(u)
  return true
end

-- Quet moi unit trong vung choi duoc. Bat duoc ca nhung hero sinh ra o
-- cho code nay khong goi toi.
local function sweepHeroes()
  if not (CFG.LOCK_HERO_XP or CFG.STRIP_SKILL_POINTS) then return 0 end
  local g = CreateGroup()
  GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, nil)

  local n = 0
  local u = FirstOfGroup(g)
  while u ~= nil do
    GroupRemoveUnit(g, u)
    if lockHero(u) then n = n + 1 end
    u = FirstOfGroup(g)
  end

  DestroyGroup(g)
  return n
end

local function startHeroLock()
  local n = sweepHeroes()
  API.trace("lockHero: quet dau tien khoa " .. n .. " hero")
  if CFG.HERO_XP_SWEEP > 0 then
    S.xpTimer = CreateTimer()
    TimerStart(S.xpTimer, CFG.HERO_XP_SWEEP, true, sweepHeroes)
  end
end

-- ---------- BA DONG TIEN ----------
--
--   Linh Khi   bien rieng, hien o bang phim R   <- quai thuong, 1/con
--   Vang       thanh tai nguyen VANG cua Warcraft <- quai thuong, 1/con
--   Go         thanh tai nguyen GO cua Warcraft   <- tinh anh 1, boss 5
--
-- Vi sao Linh Khi khong con nam tren thanh tai nguyen: thanh do chi co
-- HAI o ma gio co BA dong tien. Vang va Go duoc uu tien vi chung la thu
-- nguoi choi tieu lien tuc (shop moi wave, ky nang moi tinh anh); Linh
-- Khi chi tieu o DUNG MOT cho (Linh Can), nen nam trong bang la du.
--
-- Hai dong tien cu, Ngo Tinh va Tinh Thach, da bo: Ngo Tinh thanh Go,
-- con Tinh Thach khong con he nao tieu sau khi Phap Khi bi khoa -- giu
-- lai la de nguoi choi nhin mot con so tang mai ma khong bao gio dung
-- duoc. Xem docs/02-he-thong/kinh-te.md

-- ---------- Linh Khi ----------
local function addLinhKhi(pid, amount)
  if amount == nil or amount == 0 then return end
  local d = S.p[pid]
  if d == nil then return end
  d.linhKhi = (d.linhKhi or 0) + amount
  if d.linhKhi < 0 then d.linhKhi = 0 end
  if amount > 0 then
    d.linhKhiTotal = (d.linhKhiTotal or 0) + amount
    API.fctOnLinhKhi(pid, amount)
  end
end

local function getLinhKhi(pid)
  local d = S.p[pid]
  return (d ~= nil) and (d.linhKhi or 0) or 0
end

local function spendLinhKhi(pid, amount)
  if getLinhKhi(pid) < amount then return false end
  addLinhKhi(pid, -amount)
  return true
end

-- ---------- Vang (thanh tai nguyen) ----------
local function addVang(pid, amount)
  if amount == nil or amount == 0 then return end
  local p = Player(pid)
  local cur = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
  local moi = cur + amount
  if moi < 0 then moi = 0 end
  SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, moi)
end

local function getVang(pid)
  return GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD)
end

local function spendVang(pid, amount)
  if getVang(pid) < amount then return false end
  addVang(pid, -amount)
  return true
end

-- ---------- Go (thanh tai nguyen) ----------
local function addGo(pid, amount)
  if amount == nil or amount == 0 then return end
  local p = Player(pid)
  local cur = GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER)
  local moi = cur + amount
  if moi < 0 then moi = 0 end
  SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, moi)
end

local function getGo(pid)
  return GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_LUMBER)
end

local function spendGo(pid, amount)
  if getGo(pid) < amount then return false end
  addGo(pid, -amount)
  return true
end

local function activeCount()
  local n = 0
  for i = 1, #S.pids do
    if S.p[S.pids[i]].active then n = n + 1 end
  end
  return n
end

API.addLinhKhi       = addLinhKhi
API.getLinhKhi       = getLinhKhi
API.spendLinhKhi     = spendLinhKhi
API.addVang          = addVang
API.getVang          = getVang
API.spendVang        = spendVang
API.addGo            = addGo
API.getGo            = getGo
API.spendGo          = spendGo
API.grantSkillPoints = grantSkillPoints
API.lockHero      = lockHero
API.sweepHeroes   = sweepHeroes
API.startHeroLock = startHeroLock
API.initPlayers = initPlayers
API.activeCount = activeCount
