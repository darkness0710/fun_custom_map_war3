-- ============================================================
--  2_wave.lua  --  220 stage
--
--  Luat: docs/02-he-thong/dot-quai.md
--  Duong cong: docs/03-du-lieu/duong-cong-suc-manh.md
--
--  MOT bien stage duy nhat, 1..220. Canh gioi va tang deu SUY RA tu no
--  -- giu hai bien song song la chung se lech nhau.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- ---------- Chi so hoa stage ----------
-- Mot canh gioi = TIERS_PER_REALM tang + 1 boss. So 11 khong hard-code.
local function stagesPerRealm()
  return CFG.TIERS_PER_REALM + 1
end

local function totalStages()
  return #CFG.REALMS * stagesPerRealm()
end

-- Tra ve: canh gioi 1..20, tang 1..10, co phai boss khong
local function decode(stage)
  local per   = stagesPerRealm()
  local realm = math.floor((stage - 1) / per) + 1
  local k     = ((stage - 1) % per) + 1
  local isBoss = (k == per)
  local tier   = isBoss and CFG.TIERS_PER_REALM or k
  return realm, tier, isBoss
end

local function realmName(realm)
  local r = CFG.REALMS[realm]
  if r == nil then return "?" end
  return r.ten
end

local function realmCoi(realm)
  local r = CFG.REALMS[realm]
  if r == nil then return 1 end
  return r.coi
end

-- Chu hien cho nguoi choi: "Truc Co tang 4" hoac "Truc Co vien man"
local function stageLabel(stage)
  local realm, tier, isBoss = decode(stage)
  if isBoss then return realmName(realm) .. " -- BOSS" end
  if tier >= CFG.TIERS_PER_REALM then
    return realmName(realm) .. " " .. CFG.TIER_VIEN_MAN
  end
  return realmName(realm) .. " tang " .. tier
end

-- ---------- Duong cong ----------

local function ehpOf(stage, realm)
  return CFG.MOB_EHP_BASE
       * CFG.MOB_EHP_GROWTH ^ (stage - 1)
       * CFG.MOB_EHP_REALM_STEP ^ (realm - 1)
end

local function dmgOf(stage, realm)
  return CFG.MOB_DMG_BASE
       * CFG.MOB_DMG_GROWTH ^ (stage - 1)
       * CFG.MOB_DMG_REALM_STEP ^ (realm - 1)
end

local function armorOf(realm)
  return CFG.MOB_ARMOR_BASE + CFG.MOB_ARMOR_PER_REALM * (realm - 1)
end

-- Duong cong sinh ra EHP; MAU THAT suy nguoc ra tu giap. Cong giap o
-- dau thi chia mau o do. (ADR 0010)
local function hpFromEhp(ehp, armor)
  return ehp / (1 + CFG.ARMOR_DR_PER_POINT * armor)
end

-- So nguoi choi dang song, dem lai moi wave (ADR 0009).
local function playerCount()
  if not CFG.SCALE_RECOUNT_EACH_WAVE then return #S.pids end
  local n = API.activeCount()
  if n < 1 then n = 1 end
  return n
end

-- ---------- Sinh quai ----------

local function applyStats(u, ehp, dmg, armor)
  local hp = math.floor(hpFromEhp(ehp, armor) + 0.5)
  if hp < 1 then hp = 1 end

  if BlzSetUnitMaxHP ~= nil then
    BlzSetUnitMaxHP(u, hp)
    SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
  end
  if BlzSetUnitArmor ~= nil then
    BlzSetUnitArmor(u, armor)
  end
  if BlzSetUnitBaseDamage ~= nil then
    BlzSetUnitBaseDamage(u, math.floor(dmg + 0.5), 0)
  end
end

local function spawnPoint()
  if S.enemyX ~= nil then
    local jx = GetRandomReal(-CFG.SPAWN_JITTER, CFG.SPAWN_JITTER)
    local jy = GetRandomReal(-CFG.SPAWN_JITTER, CFG.SPAWN_JITTER)
    return API.clampToMap(S.enemyX + jx, S.enemyY + jy)
  end
  return API.blockCenter(3, 3)
end

local function sendToHouse(u)
  if S.houseX == nil then return end
  IssuePointOrder(u, "attack", S.houseX, S.houseY)
end

-- kind: "mob" | "elite" | "boss"
local function spawnOne(stage, realm, kind)
  local uid = CFG.MOB_UNIT[realmCoi(realm)]
  if uid == nil then return nil end

  local x, y = spawnPoint()
  local face = API.angleXY(x, y, S.houseX or x, S.houseY or y)
  local u = CreateUnit(S.enemy, uid, x, y, face)
  if u == nil then
    S.wave.spawnFail = (S.wave.spawnFail or 0) + 1
    return nil
  end

  local P     = S.wave.players
  local ehp   = ehpOf(stage, realm) * (1 + CFG.SCALE_EHP_PER_PLAYER * (P - 1))
  local dmg   = dmgOf(stage, realm) * (1 + CFG.SCALE_DMG_PER_PLAYER * (P - 1))
  local armor = armorOf(realm)

  if kind == "elite" then
    ehp = ehp * CFG.ELITE_EHP
    dmg = dmg * CFG.ELITE_DMG
    SetUnitScale(u, CFG.ELITE_SCALE, CFG.ELITE_SCALE, CFG.ELITE_SCALE)
    SetUnitVertexColor(u, 255, 210, 120, 255)
  elseif kind == "boss" then
    -- Boss dung he so rieng: mot than, dong nguoi don ha hieu qua hon.
    ehp = ehpOf(stage, realm) * CFG.BOSS_EHP
        * (1 + CFG.SCALE_BOSS_EHP_PER_PLAYER * (P - 1))
    dmg = dmgOf(stage, realm) * CFG.BOSS_DMG
        * (1 + CFG.SCALE_DMG_PER_PLAYER * (P - 1))
    SetUnitScale(u, CFG.BOSS_SCALE, CFG.BOSS_SCALE, CFG.BOSS_SCALE)
    SetUnitVertexColor(u, 255, 120, 120, 255)
  end

  applyStats(u, ehp, dmg, armor)
  S.mobs[u] = kind
  -- Ghi lai stage luc SINH, khong dung stage hien tai luc chet.
  -- Quai don lai qua nhieu wave (do duoc: stage 6 con 174 con song),
  -- nen tra theo stage hien tai la tu thuong them cho viec giet cham.
  S.mobStage[u] = stage
  S.alive = S.alive + 1
  sendToHouse(u)
  return u
end

-- ---------- Kinh te ----------

local function waveIncome(stage)
  return CFG.LINHKHI_BASE * CFG.LINHKHI_GROWTH ^ (stage - 1)
end

-- Linh khi cho mot con, theo loai. Tra ve SO THUC, khong lam tron.
--
-- O stage 1, mot con linh dang gia 60 x 0.60 / 50 = 0.72 linh khi. Lam
-- tron xuong la 0 -- giet sach 50 con dau game duoc khong dong nao.
-- Lam tron len thanh 1 thi thu nhap dau game vot 23% so voi duong cong.
-- Ca hai deu sai, nen giu so thuc va cong don phan le o payBounty.
local function bountyOf(stage, kind)
  local total = waveIncome(stage)
  if kind == "elite" then
    return total * (1 - CFG.LINHKHI_MOB_SHARE) / CFG.WAVE_ELITE_COUNT
  elseif kind == "boss" then
    return total
  end
  return total * CFG.LINHKHI_MOB_SHARE / CFG.WAVE_MOB_COUNT
end

-- Cong don phan le, tra ra khi du mot don vi. Tong tra ra bam dung
-- duong cong thu nhap, khong mat mat do lam tron.
local function payBounty(pid, amount)
  local d = S.p[pid]
  if d == nil then return end
  d.lkFrac = (d.lkFrac or 0) + amount
  local whole = math.floor(d.lkFrac)
  if whole > 0 then
    d.lkFrac = d.lkFrac - whole
    API.addLinhKhi(pid, whole)
  end
end

-- ---------- Mot wave ----------

-- Mau nha tinh lai moi wave theo sat thuong mot con linh o stage do.
-- Khong tinh lai thi den canh gioi 5 nha da thanh giay.
--
-- Giu nguyen TI LE mau dang co, roi hoi them REGEN_PER_WAVE -- neu dat
-- lai day mau moi wave thi lot bao nhieu cung khong sao.
local function rescaleHouse(stage, realm)
  if S.house == nil or BlzSetUnitMaxHP == nil then return end

  local oldMax = GetUnitState(S.house, UNIT_STATE_MAX_LIFE)
  local ratio  = 1.0
  if oldMax > 0 then
    ratio = GetUnitState(S.house, UNIT_STATE_LIFE) / oldMax
  end

  local P = S.wave.players
  local newMax = CFG.HOUSE_HP_HITS * dmgOf(stage, realm)
               * (1 + CFG.SCALE_DMG_PER_PLAYER * (P - 1))
  newMax = math.floor(newMax + 0.5)
  if newMax < 1 then newMax = 1 end

  BlzSetUnitMaxHP(S.house, newMax)
  local heal = ratio + CFG.HOUSE_REGEN_PER_WAVE
  if heal > 1.0 then heal = 1.0 end
  SetUnitState(S.house, UNIT_STATE_LIFE, newMax * heal)
end

local function spawnStage(stage)
  local realm, tier, isBoss = decode(stage)

  S.stage = stage
  S.wave.players = playerCount()
  S.wave.spawnFail = 0
  rescaleHouse(stage, realm)

  if isBoss then
    spawnOne(stage, realm, "boss")
    API.msg(nil, CFG.C_RED .. "=== " .. realmName(realm) ..
      " DO KIEP -- BOSS ===" .. CFG.C_END)
  else
    for _ = 1, CFG.WAVE_MOB_COUNT do spawnOne(stage, realm, "mob") end
    for _ = 1, CFG.WAVE_ELITE_COUNT do spawnOne(stage, realm, "elite") end
    API.msg(nil, CFG.C_GOLD .. "[" .. stage .. "/" .. totalStages() .. "] " ..
      stageLabel(stage) .. CFG.C_END)
  end

  if S.wave.spawnFail > 0 then
    API.msg(nil, CFG.C_RED .. "Khong sinh duoc " .. S.wave.spawnFail ..
      " con -- kiem tra CFG.MOB_UNIT." .. CFG.C_END)
  end
  API.trace("stage " .. stage .. " (" .. stageLabel(stage) .. ") P=" ..
            S.wave.players .. " song=" .. S.alive)
end

local function waveSeconds(stage)
  local realm = decode(stage)
  return CFG.WAVE_TIME[realmCoi(realm)] or 30.0
end

-- Dong ho chay bat ke wave truoc da don chua -- do la ap luc chinh.
-- Nhung qua tran unit song thi HOAN, neu khong mot lan vo tran se keo
-- theo day chuyen va khong bao gio go lai duoc. (L5)
local function onWaveTimer()
  if not S.running then return end

  local nextStage = S.stage + 1
  if nextStage > totalStages() then
    API.endGame(true, "Da chan duoc Sang The Than.")
    return
  end

  if S.alive >= CFG.WAVE_MAX_ALIVE then
    API.msg(nil, CFG.C_GREY .. "Qua dong quai tren map -- hoan wave." .. CFG.C_END)
    TimerStart(S.waveTimer, CFG.WAVE_TICK, false, onWaveTimer)
    return
  end

  spawnStage(nextStage)
  TimerStart(S.waveTimer, waveSeconds(nextStage), false, onWaveTimer)
end

-- ---------- Nhip 2 giay: ra lenh lai ----------
-- Quai bi danh lac huong khong tu quay ve nha.

local function tick()
  if not S.running or S.houseX == nil then return end
  for u, _ in pairs(S.mobs) do
    if u ~= nil and API.alive(u) then sendToHouse(u) end
  end
end

-- ---------- Phat thuong ----------
--
-- MOI phan thuong di qua day. Quai thuong, tinh anh, boss -- ca hai loai
-- tien -- deu chia deu cho MOI nguoi choi, khong phu thuoc ai ket lieu.
-- Xem ADR 0013.
--
-- Mot cho duy nhat, vi truoc day Linh Khi va Tinh Thach moi cai mot vong
-- lap rieng: thu them mot loai thuong nua la quen mot cho.
local function rewardAll(stage, kind)
  local lk = bountyOf(stage, kind)
  local realm = decode(stage)
  local tt = 0
  if kind == "boss" then
    tt = CFG.TINHTHACH_BOSS_BASE + CFG.TINHTHACH_BOSS_STEP * (realm - 1)
  end

  for i = 1, #S.pids do
    local pid = S.pids[i]
    if S.p[pid] ~= nil and S.p[pid].active then
      payBounty(pid, lk)
      if tt > 0 then API.addTinhThach(pid, tt) end
    end
  end

  if kind == "boss" then
    API.msg(nil, CFG.C_JADE .. "Ha duoc boss " .. realmName(realm) ..
      ". Moi nguoi nhan " .. tt .. " Tinh Thach." .. CFG.C_END)
  end
end

-- ---------- Goi tu 08_events khi mot con chet ----------

local function onMobDeath(u, killer)
  local kind = S.mobs[u]
  if kind == nil then return end

  S.mobs[u] = nil
  S.alive = S.alive - 1
  if S.alive < 0 then S.alive = 0 end

  local stage = S.mobStage[u] or S.stage
  S.mobStage[u] = nil

  rewardAll(stage, kind)
end

-- ---------- Khoi dong ----------

local function startWaves()
  S.stage = 0
  S.mobs  = {}
  S.mobStage = {}
  S.alive = 0
  S.wave  = { players = 1, spawnFail = 0 }

  S.waveTimer = CreateTimer()
  S.waveDlg = CreateTimerDialog(S.waveTimer)
  TimerDialogSetTitle(S.waveDlg, "Dot ke tiep")
  TimerDialogDisplay(S.waveDlg, true)
  TimerStart(S.waveTimer, CFG.WAVE_FIRST_DELAY, false, onWaveTimer)

  S.tickTimer = CreateTimer()
  TimerStart(S.tickTimer, CFG.WAVE_TICK, true, tick)

  API.trace("wave: khoi dong, " .. totalStages() .. " stage")
end

local function stopWaves()
  if S.waveTimer ~= nil then PauseTimer(S.waveTimer) end
  if S.tickTimer ~= nil then PauseTimer(S.tickTimer) end
  if S.waveDlg ~= nil then TimerDialogDisplay(S.waveDlg, false) end
end

-- Lenh dev "-wave N": nhay thang toi stage N. Khong co no thi khong ai
-- kiem duoc stage 180.
local function jumpTo(stage)
  if stage < 1 then stage = 1 end
  if stage > totalStages() then stage = totalStages() end
  S.stage = stage - 1
  TimerStart(S.waveTimer, 0.5, false, onWaveTimer)
end

API.stagesPerRealm = stagesPerRealm
API.totalStages    = totalStages
API.decodeStage    = decode
API.realmName      = realmName
API.stageLabel     = stageLabel
API.ehpOf          = ehpOf
API.dmgOf          = dmgOf
API.armorOf        = armorOf
API.waveIncome     = waveIncome
API.onMobDeath     = onMobDeath
API.startWaves     = startWaves
API.stopWaves      = stopWaves
API.jumpToStage    = jumpTo
