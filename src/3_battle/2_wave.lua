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
  -- Tra theo CANH GIOI, khong phai theo coi: quai doi hinh moi 5 stage
  -- thay vi moi 25. Thieu bac thi lui ve ma da chay that, chu khong
  -- tra nil va nuot ca wave.
  local uid = CFG.MOB_UNIT[realm] or CFG.MOB_UNIT_FALLBACK
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
  -- Tu chinh gan SAU applyStats: no doi mau con quai, ma tinh anh cung
  -- doi mau -- de tu chinh thang thi ca dot doc ra mot mau duy nhat.
  if API.modifierApply ~= nil then API.modifierApply(u) end
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

  newMax = newMax * (1 + bonusMax)

  -- Nang cap nha chinh (the VI, tra bang vang) cong SUC MANH.
  --
  -- Dat Str THAT len unit roi moi dat max: nguoi choi bam vao nha thay
  -- con so do tren bang chi so, chu khong phai mot con so chi ton tai
  -- trong dau ta. Nhung max thi van do CONG THUC NAY quyet dinh --
  -- BlzSetUnitMaxHP goi SAU cung nen no thang, du Warcraft co tu tinh
  -- lai max theo Str hay khong. Mot nguon duy nhat, khong tranh chap.
  --
  -- Day la duong DUY NHAT dung: ham nay chay lai moi wave va tinh
  -- newMax tu dau, nen ai goi BlzSetUnitMaxHP ngoai day deu bi xoa o
  -- wave sau -- va xoa im lang.
  if API.houseUpStr ~= nil then
    local str = API.houseUpStr()
    if str > 0 then
      if SetHeroStr ~= nil and GetHeroStr ~= nil then
        local base = S.houseStrBase
        if base == nil then
          base = GetHeroStr(S.house, false)
          S.houseStrBase = base
        end
        SetHeroStr(S.house, base + str, true)
      end
      newMax = newMax + str * (API.houseUpStrHp and API.houseUpStrHp() or 25.0)
    end
  end

  newMax = math.floor(newMax + 0.5)
  if newMax < 1 then newMax = 1 end

  BlzSetUnitMaxHP(S.house, newMax)
  local heal = ratio + CFG.HOUSE_REGEN_PER_WAVE + bonusRegen
  if heal > 1.0 then heal = 1.0 end
  SetUnitState(S.house, UNIT_STATE_LIFE, newMax * heal)
end

-- Tinh lai NGAY, khong doi wave sau.
--
-- 12_houseup.lua goi cai nay luc mua Kien Co: mua giua mot wave dang bi
-- don ma phai cho het wave moi thay gi la mua trong bong toi, va dung
-- luc do thi nguoi choi can no NGAY.
--
-- Doc stage/realm tu S chu khong nhan tham so: ben goi khong co ly do
-- gi phai biet minh dang o stage may, va hai noi cung giu mot con so
-- thi som muon lech.
local function rescaleNow()
  local stage = S.stage
  if stage == nil then return end
  local realm = decode(stage)
  rescaleHouse(stage, realm)
end

local function spawnStage(stage)
  local realm, tier, isBoss = decode(stage)

  S.stage = stage
  S.wave.players = playerCount()
  S.wave.spawnFail = 0
  -- Stage boss KHONG co tu chinh: boss da co bang co che rieng
  -- (CFG.BOSS_MECH), chong them mot lop nua la khong ai doc ra cai gi
  -- dang giet minh. clear() tat ca thoi tiet.
  if API.modifierClear ~= nil then API.modifierClear() end
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
    -- BOC TRUOC KHI SINH: spawnOne() hoi tu chinh de gan len tung con.
    --
    -- Goi o day la mot rang buoc dong bo, khong phai tien tay: ham nay
    -- chay tu duong da dong bo nen GetRandomInt quay cung thu tu tren
    -- moi may. Boc trong callback cua frame la lech ban game (ADR 0012).
    if API.modifierPick ~= nil then API.modifierPick(stage) end

    for _ = 1, CFG.WAVE_MOB_COUNT do spawnOne(stage, realm, "mob") end
    for _ = 1, CFG.WAVE_ELITE_COUNT do spawnOne(stage, realm, "elite") end
    API.msg(nil, CFG.C_GOLD .. "[" .. stage .. "/" .. totalStages() .. "] " ..
      stageLabel(stage) .. CFG.C_END)
    if API.modifierAnnounce ~= nil then API.modifierAnnounce() end

    -- Ghi ro wave nay gom NHUNG GI, bang dung cai ten dang nam tren con
    -- quai. Mot wave co hai loai ma dong bao chi noi mot cau chung thi
    -- nguoi choi khong doi chieu duoc cai minh nhin thay voi cai vua doc.
    API.msg(nil, "   " .. CFG.C_GREY .. API.t("wave_comp",
      CFG.WAVE_MOB_COUNT,   mobName(stage, "mob"),
      CFG.WAVE_ELITE_COUNT, mobName(stage, "elite")) .. CFG.C_END)
  end

  if S.wave.spawnFail > 0 then
    API.warn(nil, "Khong sinh duoc " .. S.wave.spawnFail ..
      " con -- kiem tra CFG.MOB_UNIT.")
  end
  API.trace("stage " .. stage .. " (" .. stageLabel(stage) .. ") P=" ..
            S.wave.players .. " song=" .. S.alive)
end

-- Dong ho khong con la NHIP nua -- no chi con mot viec: hoan viec sinh
-- quai ra khoi su kien dang chay.
--
-- waveNow() duoc goi tu cu bam frame hoac tu lenh chat, tuc dang o BEN
-- TRONG mot su kien cua engine. Sinh 51 unit ngay tai do la dung cai bay
-- ADR 0005. Nen waveNow() hen timer 0.02 giay, va ham nay chay o nhip sau.
--
-- Moi dieu kien chan (con quai song, het stage) da kiem o waveNow/callState
-- TRUOC khi toi day.
local function onWaveTimer()
  -- Co mo o waveNow() ha xuong NGAY DAY: den day dot da that su bat
  -- dau, khong con gi de tranh nhau nua. Ha truoc ca phep kiem
  -- S.running, neu khong mot lan tu choi la co ket cung mai mai.
  S.waveCalling = false
  if not S.running then return end

  local nextStage = S.stage + 1
  if nextStage > totalStages() then
    API.endGame(true, API.t("win_final", realmName(#CFG.REALMS)))
    return
  end
  spawnStage(nextStage)
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

-- Goi dot ke tiep. Day la cho DUY NHAT dot moi duoc sinh ra -- khong con
-- dong ho nao tu keo dot vao nua.
--
-- Chay tren MOI may, tu kenh dong bo (nut tren bang tran dau) hoac tu
-- lenh chat.
--
-- Khong goi thang onWaveTimer(): sinh 51 unit ngay trong su kien dang
-- chay la cai bay ADR 0005. Hen 0.02 giay de no chay o nhip sau.
local function waveNow()
  if not S.running or S.waveTimer == nil then
    API.trace("waveNow: TU CHOI -- running=" .. tostring(S.running) ..
              " timer=" .. tostring(S.waveTimer ~= nil))
    return false
  end

  -- Con quai song thi khong goi duoc. Kiem O DAY chu khong chi o giao
  -- dien: nut co the bi bam dung luc con cuoi cung chua chet, va lenh
  -- chat thi khong qua giao dien bao gio.
  if CFG.WAVE_ONLY_WHEN_CLEAR and S.alive > 0 then
    API.msg(nil, CFG.C_GREY .. API.t("wave_hold", S.alive) .. CFG.C_END)
    API.trace("waveNow: TU CHOI -- con song " .. S.alive)
    return false
  end

  if S.alive >= CFG.WAVE_MAX_ALIVE then
    API.msg(nil, CFG.C_GREY .. API.t("wave_hold", S.alive) .. CFG.C_END)
    return false
  end

  if S.stage + 1 > totalStages() then return false end

  -- KHE 0.02 GIAY. Tu day den luc spawnStage() chay, S.alive van la 0,
  -- nen phep kiem "con quai song thi thoi" o tren VAN CHO QUA. Bam hai
  -- cai lien la ra hai dot -- da dinh: 100 con mot luc.
  --
  -- Co nay dong khe do lai. No o TRONG waveNow chu khong o giao dien:
  -- lenh chat -next va nguoi choi thu hai khong di qua giao dien nao.
  if S.waveCalling then
    API.trace("waveNow: TU CHOI -- dang goi mot dot roi")
    return false
  end
  S.waveCalling = true

  API.trace("waveNow: goi dot " .. (S.stage + 1) ..
            " (cho=" .. tostring(S.waitNext) .. ")")
  S.waitNext = nil
  S.waveHold = false
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
  -- Tu chinh "Trung Linh" nhan MOI phan thuong cua stage nay.
  --
  -- Nhan ca Go va luot Co Duyen chu khong chi tien: chot 2026-09-19 vi
  -- Go se co them cho tieu. Ky vong ca van: Go 260 -> ~292, luot quay
  -- 169 -> ~185.
  local mult = (API.modifierRewardMult ~= nil) and API.modifierRewardMult() or 1.0
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

  if mult ~= 1.0 then
    qi     = math.floor(qi     * mult + 0.5)
    gold   = math.floor(gold   * mult + 0.5)
    lumber = math.floor(lumber * mult + 0.5)
    cards  = math.floor(cards  * mult + 0.5)
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
-- Danh dau dang cho viec gi. 'what' doi NHAN cua nut goi dot tren bang
-- tran dau: "boss" -> TRIEU BOSS, "realm" -> SANG CANH GIOI SAU.
local function pauseWaves(what)
  S.waitNext = what
  if S.waveTimer ~= nil then PauseTimer(S.waveTimer) end
  API.trace("wave: cho '" .. what .. "' o stage " .. S.stage)
end

-- ---------- Wave vua sach ----------
--
-- Tach rieng khoi onMobDeath vi CO HAI duong toi day:
--   1. con cuoi cung chet  -> onMobDeath
--   2. phep DO LAI phat hien so dem da lech -> recount()
--
-- Duong 2 la thu bat buoc phai co. Neu mot con bien mat ma khong sinh su
-- kien chet, onMobDeath khong chay cho no, va neu HAI MOC nay chi nam
-- trong onMobDeath thi ca van se bo qua boss -- nut goi se hien "GOI DOT"
-- thay vi "TRIEU BOSS", va khong ai biet da mat mot tran boss.
local function onWaveCleared()
  if S.stage <= 0 or not S.running then return end
  if API.relicOnClear ~= nil then API.relicOnClear() end

  local r, tier, wasBoss = decode(S.stage)

  -- MOC 1: vua ha boss -> cho goi sang canh gioi sau.
  if CFG.WAVE_REST and wasBoss and S.stage < totalStages() then
    pauseWaves("realm")
    API.msg(nil, CFG.C_GOLD ..
      API.t("wave_realmdone", realmName(r + 1)) .. CFG.C_END)
    return
  end

  -- MOC 2: vua don sach tang cuoi -> cho goi boss.
  if CFG.WAVE_REST and (not wasBoss) and tier >= CFG.TIERS_PER_REALM then
    pauseWaves("boss")
    API.msg(nil, CFG.C_GOLD ..
      API.t("wave_perfection", realmName(r)) .. CFG.C_END)
    return
  end

  API.msg(nil, CFG.C_JADE .. API.t("wave_cleared") .. CFG.C_END)
end

-- ---------- DO LAI so quai song ----------
--
-- LOI THAT (ADR 0018): S.alive ket tren 0 thi MOI loi thoat cung chet --
-- ca duong "don sach" lan nut goi tay, vi ca hai hoi cung con so do.
-- Ket la ket vinh vien, khong loi nao bao.
--
-- Nen cu CFG.WAVE_RECOUNT giay lai DO LAI thay vi tin con so dang giu.
--
-- DEM QUA S.mobs, KHONG quet map theo chu so huu.
--   S.mobs chi duoc ghi o duong sinh cua he wave, nen quai DAT SAN o cac
--   vung dat sau nay khong bao gio lot vao. Dem theo
--   GetOwningPlayer == S.enemy thi vo luon chung va S.alive khong bao gio
--   ve 0 -- dung cai bay ma phep do nay dinh chua.
--
-- Xoa khoa trong luc pairs() la HOP LE trong Lua (them khoa moi moi
-- khong duoc), nen don xac ngay tai cho duoc.
local function recount()
  if not S.running then return end
  local n, gone = 0, 0
  for u, _ in pairs(S.mobs) do
    if API.alive(u) then
      n = n + 1
    else
      S.mobs[u] = nil
      S.mobStage[u] = nil
      gone = gone + 1
    end
  end
  if gone == 0 and n == S.alive then return end

  local before = S.alive
  API.trace("wave: DO LAI -- S.alive " .. before .. " -> " .. n ..
            " (don " .. gone .. " con da bien mat khong sinh su kien chet)")
  S.alive = n

  -- Con cuoi cung bien mat ma khong ai bao: phai chay NOT phan "da don
  -- sach", neu khong ca van se bo qua boss trong im lang.
  if before > 0 and n == 0 then onWaveCleared() end
end

-- ---------- Goi tu 08_events khi mot con chet ----------

local function onMobDeath(u, killer)
  local kind = S.mobs[u]
  if kind == nil then return end

  S.mobs[u] = nil
  S.alive = S.alive - 1
  if S.alive < 0 then S.alive = 0 end
  -- Dem cho bang tong ket. Dem o DAY chu khong o onAnyDeath: cho nay
  -- da loc 'kind == nil' nen no chi dem quai cua he wave, khong dem
  -- thap canh, pet hay hero.
  S.killCount = (S.killCount or 0) + 1

  local stage = S.mobStage[u] or S.stage
  S.mobStage[u] = nil

  rewardAll(stage, kind)

  if S.alive == 0 then onWaveCleared() end
end

-- ---------- Khoi dong ----------

-- Nhan cua nut goi dot tren bang tran dau. Giao dien chi VE lai thu ham
-- nay tra ve -- no khong tu suy ra trang thai o dau ca, de nut va lenh
-- chat khong bao gio noi hai dieu khac nhau.
local function callState()
  local nextStage = S.stage + 1
  if not S.running then
    return { label = API.t("wave_btn_wait"), on = false }
  end
  if nextStage > totalStages() then
    return { label = API.t("wave_btn_done"), on = false }
  end
  if CFG.WAVE_ONLY_WHEN_CLEAR and S.alive > 0 then
    return { label = API.t("wave_btn_busy", S.alive), on = false }
  end
  if S.waitNext == "boss" then
    return { label = API.t("wave_btn_boss"), on = true }
  end
  if S.waitNext == "realm" then
    local r = decode(S.stage)
    return { label = API.t("wave_btn_realm", realmName(r + 1)), on = true }
  end
  if S.stage <= 0 then
    return { label = API.t("wave_btn_first"), on = true }
  end
  return { label = API.t("wave_btn_next", nextStage), on = true }
end

-- Tao thu 20 mau linh luc vao map, kiem hai thu, roi xoa di.
--
-- VI SAO PHAI DO. Mot ma unit bon ky tu go sai thi CreateUnit tra ve
-- nil va wave do khong sinh duoc con nao -- im lang, va chi lo ra o
-- canh gioi 14 sau bon muoi phut choi. Do o giay dau thi biet ngay.
--
-- VA KIEM BAY. Chu du an yeu cau khong co quai bay: quai bay thi hero
-- danh gan khong cham toi, duong di khong theo dia hinh, va Chan Dia
-- cua boss thanh vo nghia. Ban truoc coi Than dung Frost Wyrm va no
-- bay -- khong ai bat duoc vi khong co cho nao kiem.
--
-- Tao o goc ban do roi RemoveUnit ngay. Mot con hien ra nua giay o goc
-- thi khong ai thay; mot wave rong thi ai cung thay.
local function probeMobUnits()
  if CreateUnit == nil or CFG.MOB_UNIT == nil then return end
  local bad, flying = {}, {}
  for r = 1, #CFG.REALMS do
    local uid = CFG.MOB_UNIT[r]
    if uid == nil then
      bad[#bad + 1] = r
    else
      local u = CreateUnit(S.enemy, uid, 0.0, 0.0, 0.0)
      if u == nil then
        bad[#bad + 1] = r .. ":" .. API.idToStr(uid)
      else
        if IsUnitType ~= nil and _G["UNIT_TYPE_FLYING"] ~= nil
           and IsUnitType(u, UNIT_TYPE_FLYING) then
          flying[#flying + 1] = r .. ":" .. API.idToStr(uid)
        end
        RemoveUnit(u)
      end
    end
  end

  if #bad > 0 then
    API.warn(nil, "CFG.MOB_UNIT sai ma o canh gioi: " ..
             table.concat(bad, " ") .. " -- lui ve " ..
             API.idToStr(CFG.MOB_UNIT_FALLBACK or 0))
  end
  if #flying > 0 then
    API.warn(nil, "CFG.MOB_UNIT co quai BAY o canh gioi: " ..
             table.concat(flying, " ") .. " -- hero danh gan khong cham toi")
  end
  API.trace("wave: do " .. #CFG.REALMS .. " mau linh -- " .. #bad ..
            " ma sai, " .. #flying .. " con bay")
end

local function startWaves()
  probeMobUnits()
  S.stage = 0
  S.mobs  = {}
  S.mobStage = {}
  S.alive = 0
  S.wave  = { players = 1, spawnFail = 0 }

  -- Dong ho nay KHONG con dem nguoc gi. No chi duoc waveNow() hen 0.02
  -- giay mot lan de hoan viec sinh quai ra khoi su kien dang chay.
  -- Khong co TimerDialog: khong con con so nao chay tren man hinh.
  S.waveTimer = CreateTimer()
  API.msg(nil, CFG.C_GOLD .. API.t("wave_waiting") .. CFG.C_END)

  S.tickTimer = CreateTimer()
  TimerStart(S.tickTimer, CFG.WAVE_TICK, true, tick)

  -- Luoi do: xem chu thich recount().
  S.recountTimer = CreateTimer()
  TimerStart(S.recountTimer, CFG.WAVE_RECOUNT, true, recount)

  API.trace("wave: khoi dong, " .. totalStages() .. " stage")
end

local function stopWaves()
  if S.waveTimer ~= nil then PauseTimer(S.waveTimer) end
  if S.tickTimer ~= nil then PauseTimer(S.tickTimer) end
  if S.recountTimer ~= nil then PauseTimer(S.recountTimer) end
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
API.waveCallState  = callState
API.onMobDeath     = onMobDeath
API.waveRescaleHouse = rescaleNow
API.startWaves     = startWaves
API.stopWaves      = stopWaves
API.jumpToStage    = jumpTo
