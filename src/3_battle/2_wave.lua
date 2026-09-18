-- ============================================================
--  2_wave.lua  --  100 stage
--
--  Luat: docs/02-he-thong/dot-quai.md
--  Duong cong: docs/03-du-lieu/duong-cong-suc-manh.md
--
--  MOT bien stage duy nhat, 1..100. Canh gioi va tang deu SUY RA tu no
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
  return API.pick(CFG.REALMS[realm])
end

-- Tang cua mot stage, thanh chu: "So Ki", "Vien Man", hoac "BOSS".
--
-- Bon tang co TEN rieng (CFG.TIER_NAMES) chu khong danh so: "Truc Co So
-- Ki" doc ra nghia ngay, con "Truc Co Tang 3" thi phai nho tang 3 tren
-- tong bao nhieu.
--
-- Lui ve danh so neu bang ten thieu phan tu -- doi TIERS_PER_REALM ma
-- quen them ten thi van chay, chi la ten xau, chu khong no loi.
--
-- Chu o day di qua API.t/API.pick chu khong go thang: truoc day
-- stageLabel noi " tang " bang tieng Viet ngay ca khi CFG.LANG = "en",
-- nen ban tieng Anh hien ra "Mortal tang 4".
local function tierLabel(stage)
  local _, tier, isBoss = decode(stage)
  if isBoss then return API.t("stage_boss") end
  local name = CFG.TIER_NAMES and CFG.TIER_NAMES[tier] or nil
  if name ~= nil then return API.pick(name) end
  if tier >= CFG.TIERS_PER_REALM then return API.t("tier_perfection") end
  return API.t("tier_word") .. " " .. tier
end

-- Ten quai = canh gioi + TANG + hau to theo loai.
--
-- Co TANG trong ten vi khong co no thi ca 5 stage cua mot canh gioi ra
-- cung mot cai ten. Ma quai don lai qua nhieu wave (do duoc: stage 6
-- con 174 con song), nen tren map luc nao cung co vai the he cung luc
-- -- nhin vao mot con khong biet no thuoc dot nao, cung khong biet no
-- dang o dung gia tri thuong cua stage nao.
--
-- Boss khong can tang: no la lan do kiep DUY NHAT cua canh gioi do.
--
-- 20 canh gioi x 4 tang x 2 loai + 20 boss = 180 ten, sinh ra tu 20 ten
-- canh gioi + 4 ten tang + 3 hau to -- khong phai 180 unit type.
--
-- BlzSetUnitName doi ten TUNG con luc chay, nen doi tieng khong phai
-- dung toi Object Editor. Thieu native thi quai giu ten goc cua mau
-- lam no ("Footman", "Ghoul"...) -- 5_natives.lua do va bao truoc.
local function mobName(stage, kind)
  local realm = decode(stage)
  if kind == "boss" then
    return realmName(realm) .. " - " .. API.t("boss_suffix")
  end
  local suffix = (kind == "elite") and "elite_suffix" or "mob_suffix"
  return realmName(realm) .. " " .. tierLabel(stage) .. " - " .. API.t(suffix)
end

local function realmWorld(realm)
  local r = CFG.REALMS[realm]
  if r == nil then return 1 end
  return r.world
end

-- Chu hien cho nguoi choi: "Truc Co Tang 4" hoac "Truc Co Vien Man".
-- Cung mot nguon voi ten quai, nen dong bao wave va con quai tren map
-- khong the goi khac nhau.
local function stageLabel(stage)
  local realm = decode(stage)
  return realmName(realm) .. " " .. tierLabel(stage)
end

-- ---------- Duong cong ----------

-- He so Linh Can cua mot BAC, tinh thang tu bang chi so.
--
-- Goi qua API vi statAt nam trong 3_cultivation.lua. Tra ve 1.0 neu he do
-- chua san sang -- quai van sinh duoc, chi la khong bam theo.
local function cultPowerAt(rank)
  if API.cultStatAt == nil then return 1.0 end
  local b = CFG.CULT_DMG_BASE
  return (b + API.cultStatAt(rank)) / (b + API.cultStatAt(1))
end

-- EHP quai BAM THEO duong cong Linh Can -- xem CFG.MOB_EHP_FOLLOW_CULT.
--
-- Ca hai ve deu co cung thua so he so Linh Can nen no triet tieu, va ti
-- le "may phat mot con" phang theo dinh nghia. Mu cua MOB_EHP_GROWTH la
-- (TANG - 1), khong phai (stage - 1): phan tang truong theo canh gioi
-- da nam trong he so roi, dem hai lan la nhan doi do doc.
local function ehpOf(stage, realm)
  if CFG.MOB_EHP_FOLLOW_CULT then
    local _, tier = decode(stage)
    return CFG.MOB_EHP_BASE * cultPowerAt(realm)
         * CFG.MOB_EHP_GROWTH ^ (tier - 1)
  end
  return CFG.MOB_EHP_BASE
       * CFG.MOB_EHP_GROWTH ^ (stage - 1)
       * CFG.MOB_EHP_REALM_STEP ^ (realm - 1)
end

-- Sat thuong quai cung bam theo, nhung DOC HON: mau toi da cua hero len
-- theo Suc Manh, tuc len theo dung he so do. Giu nguyen duong cong cu
-- thi cuoi van quai go khong not hero.
--
-- MOB_DMG_FOLLOW_POW < 1 nen quai doc cham hon hero khoe len mot chut --
-- co y, de nguoi choi thay minh cung day len chu khong dam chan tai cho.
local function dmgOf(stage, realm)
  if CFG.MOB_EHP_FOLLOW_CULT then
    local _, tier = decode(stage)
    return CFG.MOB_DMG_BASE
         * cultPowerAt(realm) ^ (CFG.MOB_DMG_FOLLOW_POW or 1.0)
         * CFG.MOB_DMG_GROWTH ^ (tier - 1)
  end
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
-- ex/ey: sinh o DUNG cho do thay vi o cua vao. Boss dung de goi thuoc
-- ha quanh minh, va thuoc ha phai di qua day de cung duong cong, cung
-- tien thuong, va cung duoc dem vao S.alive.
local function spawnOne(stage, realm, kind, ex, ey)
  local uid = CFG.MOB_UNIT[realmWorld(realm)]
  if uid == nil then return nil end

  local x, y = spawnPoint()
  if ex ~= nil and ey ~= nil then x, y = ex, ey end
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
  end

  applyStats(u, ehp, dmg, armor)
  if BlzSetUnitName ~= nil then BlzSetUnitName(u, mobName(stage, kind)) end
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
--
-- Ba ham cu -- waveIncome(), bountyOf(), payBounty() -- da xoa het.
--
-- Chung ton tai de giai MOT bai toan: thu nhap la duong cong mu
-- 60 x 1.0319^(stage-1), chia cho 50 con, nen o stage 1 mot con dang
-- gia 0.72 Linh Khi. Lam tron xuong la ca wave dau duoc 0 dong; lam
-- tron len la thu nhap dau game vot 23%. Nen phai giu so thuc va cong
-- don phan le.
--
-- Thu nhap gio PHANG: mot con dung mot dong. Khong con phan le nao de
-- cong don, nen ca ba ham thanh thua. rewardAll() goi thang
-- API.addQi / addGold / addLumber.
--
-- He so x1.25 cua Phap Khi "Tu Linh Tran" mat theo, va do la dung: he
-- Phap Khi dang khoa (CFG.RELIC_LOCKED).

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

  -- Hai Phap Khi cong vao nha chinh. Nha la cua CHUNG, nen chi can MOT
  -- nguoi mua la ca doi duoc -- do la ly do chung dat gia cao hon hai
  -- mon ca nhan o tren.
  local bonusMax, bonusRegen = 0.0, 0.0
  if API.relicAnyHas ~= nil then
    if API.relicAnyHas("nhahp")    then bonusMax   = 0.30 end
    if API.relicAnyHas("nharegen") then bonusRegen = 0.15 end
  end
  newMax = math.floor(newMax * (1 + bonusMax) + 0.5)
  if newMax < 1 then newMax = 1 end

  BlzSetUnitMaxHP(S.house, newMax)
  local heal = ratio + CFG.HOUSE_REGEN_PER_WAVE + bonusRegen
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
    -- Boss KHONG di qua spawnOne: no khong lay chi so tu duong cong ma
    -- DO suc manh that cua doi. Xem 3_boss.lua.
    local x, y = spawnPoint()
    local face = API.angleXY(x, y, S.houseX or x, S.houseY or y)
    local u = API.bossSpawn and API.bossSpawn(stage, realm, x, y, face) or nil
    if u ~= nil then
      S.mobs[u] = "boss"
      S.mobStage[u] = stage
      S.alive = S.alive + 1
      sendToHouse(u)
    else
      S.wave.spawnFail = (S.wave.spawnFail or 0) + 1
    end
    API.msg(nil, CFG.C_RED .. API.t("boss_coming", realmName(realm)) .. CFG.C_END)
  else
    for _ = 1, CFG.WAVE_MOB_COUNT do spawnOne(stage, realm, "mob") end
    for _ = 1, CFG.WAVE_ELITE_COUNT do spawnOne(stage, realm, "elite") end
    API.msg(nil, CFG.C_GOLD .. "[" .. stage .. "/" .. totalStages() .. "] " ..
      stageLabel(stage) .. CFG.C_END)

    -- Ghi ro wave nay gom NHUNG GI, bang dung cai ten dang nam tren con
    -- quai. Mot wave co hai loai ma dong bao chi noi mot cau chung thi
    -- nguoi choi khong doi chieu duoc cai minh nhin thay voi cai vua doc.
    API.msg(nil, "   " .. CFG.C_GREY .. API.t("wave_comp",
      CFG.WAVE_MOB_COUNT,   mobName(stage, "mob"),
      CFG.WAVE_ELITE_COUNT, mobName(stage, "elite")) .. CFG.C_END)
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
  return CFG.WAVE_TIME[realmWorld(realm)] or 30.0
end

-- Dong ho KHONG duoc phep chong dot len nhau: xem CFG.WAVE_ONLY_WHEN_CLEAR.
local function onWaveTimer()
  if not S.running then return end

  local nextStage = S.stage + 1
  if nextStage > totalStages() then
    API.endGame(true, API.t("win_final", realmName(#CFG.REALMS)))
    return
  end

  -- CHAN CHINH: con mot con song thi khong dot nao moi duoc ra.
  --
  -- Bao MOT lan roi im, va tat dong ho dem di. Bao moi nhip WAVE_TICK
  -- la lap chu day man hinh; con de dong ho dung yen o 0:00 thi nguoi
  -- choi tuong game treo -- dung loi ma pauseWaves() da phai xu ly.
  if CFG.WAVE_ONLY_WHEN_CLEAR and S.alive > 0 then
    if not S.waveHold then
      S.waveHold = true
      if S.waveDlg ~= nil then TimerDialogDisplay(S.waveDlg, false) end
      API.msg(nil, CFG.C_GREY .. API.t("wave_hold", S.alive) .. CFG.C_END)
      API.trace("wave: HOAN dot " .. nextStage .. ", con song " .. S.alive)
    end
    TimerStart(S.waveTimer, CFG.WAVE_TICK, false, onWaveTimer)
    return
  end
  S.waveHold = false

  -- Boss chiem TRON stage, mot minh (L4 trong dot-quai.md). Neu dong ho
  -- het gio ma tang 10 chua don xong thi HOAN, dung sinh boss de len
  -- dam linh con song -- lam vay la pha dung cai luat khien tran boss
  -- co cam giac khac han mot wave.
  local _, _, nextIsBoss = decode(nextStage)
  if nextIsBoss and S.alive > 0 then
    TimerStart(S.waveTimer, CFG.WAVE_TICK, false, onWaveTimer)
    return
  end

  -- Chi con y nghia khi WAVE_ONLY_WHEN_CLEAR tat.
  if S.alive >= CFG.WAVE_MAX_ALIVE then
    API.msg(nil, CFG.C_GREY .. API.t("wave_hold", S.alive) .. CFG.C_END)
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
  -- Boss dung chung nhip nay chu khong nuoi dong ho rieng: mot nhip thi
  -- khong co chuyen hai dong ho troi lech nhau.
  if API.bossTick ~= nil then API.bossTick() end
end

-- Dua dong quai ke tiep ve NGAY. Goi tu lenh -next, tu luc moi nguoi
-- chon xong hero, va tu luc don sach wave.
--
-- Khong goi thang onWaveTimer(): lam vay thi bo dem cu van chay va mot
-- luc nua lai no them mot dot nua. Phai dung no truoc.
local function waveNow()
  if not S.running or S.waveTimer == nil then
    API.trace("waveNow: TU CHOI -- running=" .. tostring(S.running) ..
              " timer=" .. tostring(S.waveTimer ~= nil))
    return false
  end
  API.trace("waveNow: keo dot ke tiep (stage hien tai " .. S.stage ..
            ", cho=" .. tostring(S.waitNext) .. ")")
  S.waitNext = nil
  S.waveHold = false
  if S.waveDlg ~= nil then TimerDialogDisplay(S.waveDlg, true) end
  PauseTimer(S.waveTimer)
  TimerStart(S.waveTimer, 0.02, false, onWaveTimer)
  return true
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
  -- Ba loai quai, ba dong tien. So PHANG, khong theo stage:
  --
  --   linh thuong -> 1 Linh Khi + 1 Vang   (nhip giay)
  --   tinh anh    -> 2 Go                  (nhip wave)
  --   boss        -> 5 Go                  (nhip canh gioi)
  --
  -- Moi loai quai mo khoa dung mot he, nen ba he bi chan boi ba loai
  -- NOI DUNG khac nhau chu khong chi boi mot cai vi:
  --   Linh Khi -> Linh Can   Vang -> Shop   Go -> Ky Nang
  --
  -- Xem docs/02-he-thong/kinh-te.md
  local qi, gold, lumber, cards = 0, 0, 0, 0
  if kind == "boss" then
    qi   = CFG.REWARD_BOSS_QI
    lumber   = CFG.REWARD_BOSS_LUMBER
    cards = CFG.FORTUNE_BOSS
  elseif kind == "elite" then
    qi   = CFG.REWARD_ELITE_QI
    lumber   = CFG.REWARD_ELITE_LUMBER
    cards = CFG.FORTUNE_ELITE
  else
    qi   = CFG.REWARD_MOB_QI
    gold = CFG.REWARD_MOB_GOLD
  end

  for i = 1, #S.pids do
    local pid = S.pids[i]
    if S.p[pid] ~= nil and S.p[pid].active then
      if qi > 0 then API.addQi(pid, qi) end
      if gold > 0 then API.addGold(pid, gold) end
      -- Them luot quay CHAY TREN MOI MAY (ham nay di tu su kien quai
      -- chet), va no rut luon ba the -- do la cho duy nhat duoc goi
      -- GetRandomInt cho he quay. Xem dau 10_fortune.lua.
      if cards > 0 and API.fortuneAddRolls ~= nil then
        API.fortuneAddRolls(pid, cards)
      end
      if lumber > 0 then
        local n = lumber
        if kind == "elite" and API.relicHas ~= nil
           and API.relicHas(pid, "go") then n = n + 1 end
        API.addLumber(pid, n)
      end
    end
  end
  -- Ve lai bang khi mot dong tien nhay MOT CUC LON: Go tung diem mot,
  -- va Linh Khi cua tinh anh/boss (50/100) -- moi cai deu dang ke. Quai
  -- thuong nhay 1 moi con, ve lai moi con la 50 lan mot wave, de nhip
  -- refresh cua bang lo.
  if lumber > 0 then API.panelRefreshAll() end

  if kind == "boss" then
    API.msg(nil, CFG.C_JADE .. API.t("boss_down", realmName(realm), lumber) .. CFG.C_END)
  end
end

-- ---------- Nghi giua hai canh gioi ----------
--
-- Dung HAN dong ho va an dong ho dem. An la co y: mot cai dong ho dung
-- yen o 0:00 chi lam nguoi choi tuong game treo, dung loi ma
-- WAVE_WAIT_FIRST da phai xu ly mot lan.
local function pauseWaves(what)
  S.waitNext = what
  if S.waveTimer ~= nil then PauseTimer(S.waveTimer) end
  if S.waveDlg ~= nil then TimerDialogDisplay(S.waveDlg, false) end
  API.trace("wave: DUNG dong ho o stage " .. S.stage .. ", cho '" .. what .. "'")
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

  -- Con cuoi cung cua stage vua chet.
  -- Chi xet o day chu khong dat trong timer -- toi duoc day nghia la
  -- chac chan da tung co quai, nen S.alive = 0 la "don sach" that,
  -- khong phai "wave sinh hong khong con nao".
  if S.alive ~= 0 or S.stage <= 0 or not S.running then return end

  if API.relicOnClear ~= nil then API.relicOnClear() end

  local r, tier, wasBoss = decode(S.stage)

  -- MOC 1: vua ha boss -> dung han, cho -next sang canh gioi sau.
  if CFG.WAVE_REST and wasBoss and S.stage < totalStages() then
    pauseWaves("realm")
    API.msg(nil, CFG.C_GOLD ..
      API.t("wave_realmdone", realmName(r + 1)) .. CFG.C_END)
    return
  end

  -- MOC 2: vua don sach tang cuoi -> dung han, cho -next goi boss.
  if CFG.WAVE_REST and (not wasBoss) and tier >= CFG.TIERS_PER_REALM then
    pauseWaves("boss")
    API.msg(nil, CFG.C_GOLD ..
      API.t("wave_perfection", realmName(r)) .. CFG.C_END)
    return
  end

  -- Binh thuong: bao da don sach roi keo dot sau vao som.
  if CFG.WAVE_AUTO_NEXT then
    API.msg(nil, CFG.C_JADE .. API.t("wave_cleared") .. CFG.C_END)
    API.after(CFG.WAVE_CLEAR_DELAY, function()
      if S.alive == 0 and S.waitNext == nil then waveNow() end
    end)
  end
end

-- ---------- Khoi dong ----------

-- Goi khi mot nguoi vua chon hero xong. Dot dau khong cho het 15 giay
-- neu moi nguoi da san sang -- 15 giay do la de CHO CHON HERO, khong
-- phai mot phan cua nhip choi.
local function readyCheck()
  if CFG.WAVE_WAIT_FIRST then return end   -- dot 1 doi goi tay
  if not S.running or S.stage > 0 then return end
  local n = 0
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    if d ~= nil and d.active then
      if d.hero == nil then return end   -- con nguoi chua chon
      n = n + 1
    end
  end
  if n == 0 then return end
  API.trace("wave: ca " .. n .. " nguoi da co hero -- vao dot 1 ngay")
  waveNow()
end

local function startWaves()
  S.stage = 0
  S.mobs  = {}
  S.mobStage = {}
  S.alive = 0
  S.wave  = { players = 1, spawnFail = 0 }

  S.waveTimer = CreateTimer()
  S.waveDlg = CreateTimerDialog(S.waveTimer)
  TimerDialogSetTitle(S.waveDlg, API.t("wave_next"))

  if CFG.WAVE_WAIT_FIRST then
    -- Khong khoi dong bo dem. Dong ho an luon: hien mot cai dem 0:00
    -- dung yen chi lam nguoi choi tuong game treo.
    TimerDialogDisplay(S.waveDlg, false)
    API.msg(nil, CFG.C_GOLD .. API.t("wave_waiting") .. CFG.C_END)
  else
    TimerDialogDisplay(S.waveDlg, true)
    TimerStart(S.waveTimer, CFG.WAVE_FIRST_DELAY, false, onWaveTimer)
  end

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
API.tierLabel      = tierLabel
API.ehpOf          = ehpOf
API.dmgOf          = dmgOf
API.armorOf        = armorOf
API.mobName        = mobName
API.realmWorld       = realmWorld
-- Boss goi de sinh thuoc ha quanh minh, tai mot toa do cu the.
API.waveSpawnAt    = function(stage, realm, x, y)
  return spawnOne(stage, realm, "mob", x, y)
end
API.waveNow        = waveNow
API.waveWaiting    = function() return S.waitNext end
API.waveReadyCheck = readyCheck
API.onMobDeath     = onMobDeath
API.startWaves     = startWaves
API.stopWaves      = stopWaves
API.jumpToStage    = jumpTo
