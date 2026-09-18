-- ============================================================
--  3_boss.lua  --  Boss: hero di bo, do theo suc manh THAT cua doi
--
--  KHAC HAN QUAI THUONG. Quai thuong bam theo duong cong Tu Vi (xem
--  CFG.MOB_EHP_FOLLOW_CULT). Boss thi DO doi ngay luc no xuat hien --
--  chi so, sat thuong, giap, mau -- roi suy ra mau va don danh cua no.
--
--  Vi sao phai do chu khong dung duong cong: duong cong gia dinh nguoi
--  choi len dung mot bac moi canh gioi. Ai cay them, ai bo lo, ai don
--  het the chi so o Co Duyen -- duong cong khong biet. Boss thi phai
--  biet, neu khong no hoac la bia thit hoac la buc tuong.
--
--  VA MOT LOI DO DUOC: 1 Agi = 1/3 giap, ma Tu Vi cong deu ca ba chi
--  so. Cuoi van hero co 8,070 giap -> giam 99.79% sat thuong. Dat sat
--  thuong boss bang mot con so tuyet doi thi no danh 2,036 chi con 4
--  mau. Nen boss tinh theo MAU HIEU DUNG: mau / (1 - giam).
--
--  Hai muoi con, moi canh gioi mot con, moi con mot file mo ta rieng:
--  docs/02-he-thong/boss/
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function damageReduction(armor)
  local k = CFG.ARMOR_DR_PER_POINT * armor
  if k <= 0 then return 0.0 end
  return k / (1.0 + k)
end

local function hasMech(b, name)
  return b ~= nil and b.mech ~= nil and b.mech[name] == true
end

local function mechNum(name, field)
  local t = CFG.BOSS_MECH and CFG.BOSS_MECH[name] or nil
  return (t ~= nil) and t[field] or 0.0
end

-- ---------- Do suc manh doi ----------
-- Tra ve: tong dps uoc luong, mau hieu dung TRUNG BINH mot hero, so hero

local function measureParty()
  local dps, ehpAvg, n = 0.0, 0.0, 0
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h) then
      n = n + 1
      local top = API.skillTopStat and API.skillTopStat(h) or 0
      dps = dps + CFG.BOSS_DPS_FACTOR * (CFG.CULT_DMG_BASE + top)

      local cut = damageReduction((BlzGetUnitArmor ~= nil) and BlzGetUnitArmor(h) or 0.0)
      -- Mau hieu dung: bao nhieu sat thuong THO moi ha duoc hero nay.
      ehpAvg = ehpAvg + GetUnitState(h, UNIT_STATE_MAX_LIFE) / (1.0 - cut)
    end
  end
  if n == 0 then return 0.0, 0.0, 0 end
  return dps, ehpAvg / n, n
end

-- ---------- Tra ban thiet ke ----------

local function def(realm)
  if CFG.BOSSES ~= nil then
    for i = 1, #CFG.BOSSES do
      if CFG.BOSSES[i].r == realm then return CFG.BOSSES[i] end
    end
  end
  return nil
end

-- ---------- Sinh boss ----------

local function spawn(stage, realm, x, y, face)
  local d = def(realm)
  local uid = (d ~= nil) and d.unit
              or CFG.BOSS_UNIT[API.realmWorld and API.realmWorld(realm) or 1]
  if uid == nil then return nil end

  local u = CreateUnit(S.enemy, uid, x, y, face)
  if u == nil then return nil end

  local dps, ehpAvg, n = measureParty()

  -- MAU: song duoc BOSS_SECONDS duoi hoa luc ca doi.
  -- Khong nhan them theo so nguoi choi -- dps o tren DA la tong cua ca
  -- doi. Nhan hai lan la phat nguoi choi vi ru duoc ban.
  local hp = dps * CFG.BOSS_SECONDS
  if hp < 1.0 then hp = 1.0 end

  -- SAT THUONG: ha mot hero dung yen trong BOSS_HITS_TO_KILL don. Con so nay
  -- la sat thuong THO -- nhin rat to, nhung sau giap no dung bang
  -- mau_that / BOSS_HITS_TO_KILL.
  local dmg = ehpAvg / CFG.BOSS_HITS_TO_KILL
  if dmg < 1.0 then dmg = 1.0 end

  if BlzSetUnitMaxHP ~= nil then
    BlzSetUnitMaxHP(u, math.floor(hp + 0.5))
    SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
  end
  if BlzSetUnitBaseDamage ~= nil then
    BlzSetUnitBaseDamage(u, math.floor(dmg + 0.5), 0)
  end
  -- Boss KHONG co giap: mau vua tinh DA la mau that can de tru.
  if BlzSetUnitArmor ~= nil then BlzSetUnitArmor(u, 0.0) end

  SetUnitScale(u, CFG.BOSS_SCALE, CFG.BOSS_SCALE, CFG.BOSS_SCALE)
  SetUnitVertexColor(u, 255, 120, 120, 255)
  -- Hero thi co kinh nghiem. Khoa lai, khong thi boss len cap giua tran
  -- va moi con so vua tinh o tren truot het.
  if SuspendHeroXP ~= nil then SuspendHeroXP(u, true) end
  if BlzSetUnitName ~= nil and d ~= nil then BlzSetUnitName(u, API.pick(d)) end

  local mechSet = {}
  if d ~= nil and d.mech ~= nil then
    for i = 1, #d.mech do mechSet[d.mech[i]] = true end
  end

  S.boss = {
    u = u, stage = stage, realm = realm, def = d, mech = mechSet,
    dmg = dmg, maxHp = hp, enraged = false,
    cdSlam = mechNum("slam", "cd"), cdCharge = mechNum("charge", "cd"),
    cdSummon = mechNum("summon", "cd"), cdShield = mechNum("shield", "cd"),
    shield = 0.0,
  }

  if d ~= nil then
    API.msg(nil, CFG.C_RED .. API.t("boss_arrived", API.pick(d)) .. CFG.C_END)
  end
  API.trace("boss: r" .. realm .. " " .. API.idToStr(uid) .. " -- " .. n ..
            " hero, dps " .. math.floor(dps) .. " -> mau " .. math.floor(hp) ..
            ", don " .. math.floor(dmg))
  return u
end

-- ---------- Co che ----------

local function forEachEnemy(x, y, radius, f)
  local g = CreateGroup()
  GroupEnumUnitsInRange(g, x, y, radius, nil)
  local t = FirstOfGroup(g)
  while t ~= nil do
    GroupRemoveUnit(g, t)
    if API.alive(t) and IsUnitEnemy(t, S.enemy) then f(t) end
    t = FirstOfGroup(g)
  end
  DestroyGroup(g)
end

local function strike(b, tgt, dmg)
  UnitDamageTarget(b.u, tgt, dmg, true, false,
                   ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
end

local function enrageMult(b)
  return b.enraged and mechNum("enrage", "dmg") or 1.0
end

local function groundSlam(b)
  local x, y = GetUnitX(b.u), GetUnitY(b.u)
  local dmg = b.dmg * mechNum("slam", "factor") * enrageMult(b)
  API.fx(CFG.FX_HIT_BUFF, x, y)
  forEachEnemy(x, y, mechNum("slam", "radius"), function(t) strike(b, t, dmg) end)
end

-- Lao toi hero XA NHAT, khong phai gan nhat: ep ke nup sau cung phai
-- tham gia. Dung gan thi da an don thuong roi.
local function charge(b)
  local bx, by = GetUnitX(b.u), GetUnitY(b.u)
  local far, dmax = nil, -1.0
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h) then
      local dist = API.distXY(bx, by, GetUnitX(h), GetUnitY(h))
      if dist > dmax then far, dmax = h, dist end
    end
  end
  if far == nil then return end
  SetUnitPosition(b.u, GetUnitX(far), GetUnitY(far))
  API.fx(CFG.FX_HIT_LINE, GetUnitX(far), GetUnitY(far))
  strike(b, far, b.dmg * mechNum("charge", "factor") * enrageMult(b))
end

local function summonAdds(b)
  local n = math.floor(mechNum("summon", "count"))
  if n <= 0 or API.waveSpawnAt == nil then return end
  for i = 1, n do
    local a = 360.0 * i / n
    -- Goi qua he wave de thuoc ha cung duong cong, cung tien thuong, va
    -- cung duoc dem vao S.alive -- neu khong, don sach wave xong ma con
    -- thuoc ha thi dong ho wave treo.
    API.waveSpawnAt(b.stage, b.realm,
                    API.polarX(GetUnitX(b.u), 220.0, a),
                    API.polarY(GetUnitY(b.u), 220.0, a))
  end
  API.msg(nil, CFG.C_GREY .. API.t("boss_summon") .. CFG.C_END)
end

local function shield(b)
  b.shield = b.shield + b.maxHp * mechNum("shield", "ratio")
  API.fx(CFG.FX_HIT_BUFF, GetUnitX(b.u), GetUnitY(b.u))
  API.msg(nil, CFG.C_GREY .. API.t("boss_shield") .. CFG.C_END)
end

-- ---------- Nhip 2 giay ----------

local function tick()
  local b = S.boss
  if b == nil or b.u == nil then return end
  if not API.alive(b.u) then S.boss = nil; return end

  if hasMech(b, "enrage") and not b.enraged then
    if GetUnitState(b.u, UNIT_STATE_LIFE) / b.maxHp <= mechNum("enrage", "at") then
      b.enraged = true
      if BlzSetUnitBaseDamage ~= nil then
        BlzSetUnitBaseDamage(b.u, math.floor(b.dmg * mechNum("enrage", "dmg") + 0.5), 0)
      end
      SetUnitVertexColor(b.u, 255, 40, 40, 255)
      API.msg(nil, CFG.C_RED .. API.t("boss_enraged") .. CFG.C_END)
    end
  end

  local function beat(field, name, f)
    if not hasMech(b, name) then return end
    b[field] = b[field] - CFG.WAVE_TICK
    if b[field] <= 0.0 then b[field] = mechNum(name, "cd"); f(b) end
  end
  beat("cdChanDia", "slam",  groundSlam)
  beat("cdLao",     "charge",      charge)
  beat("cdTrieu",   "summon", summonAdds)
  beat("cdKhien",   "shield",    shield)
end

-- ---------- Su kien sat thuong rieng cua boss ----------
--
-- Boss tu giu trigger cua no thay vi nho 7_effect.lua: bon co che duoi
-- day chi song trong mot tran boss, tron chung vao he bi dong cua hero
-- thi ca hai ben deu kho doc.

local function onDamage()
  local b = S.boss
  if b == nil or b.u == nil then return end

  local tgt = (BlzGetEventDamageTarget ~= nil) and BlzGetEventDamageTarget()
              or GetTriggerUnit()
  local src = GetEventDamageSource()
  local dmg = GetEventDamage()
  if dmg <= 0.0 then return end

  -- BOSS AN DON
  if tgt == b.u then
    if b.shield > 0.0 and BlzSetEventDamage ~= nil then
      local absorb = (dmg < b.shield) and dmg or b.shield
      b.shield = b.shield - absorb
      dmg = dmg - absorb
      BlzSetEventDamage(dmg)
    end
    if hasMech(b, "reflect") and src ~= nil and src ~= b.u and dmg > 0.0 then
      -- Phan lai NGUON. Cu phan nay lai ban su kien nay lan nua, nhung
      -- lan do src == boss nen khong vao nhanh phan don -- khong de quy.
      UnitDamageTarget(b.u, src, dmg * mechNum("reflect", "ratio"), true, false,
                       ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    end
    return
  end

  -- BOSS GAY DON
  if src == b.u then
    if hasMech(b, "lifesteal") then
      local hp = GetUnitState(b.u, UNIT_STATE_LIFE) + dmg * mechNum("lifesteal", "ratio")
      local mx  = GetUnitState(b.u, UNIT_STATE_MAX_LIFE)
      SetUnitState(b.u, UNIT_STATE_LIFE, (hp > mx) and mx or hp)
    end
    -- XE GIAP: KHONG sua giap that. Giap la cua engine tu luc
    -- heroRecompute thoi so huu no (xem 7_effect.lua); gianh lai la
    -- lap lai dung cai loi da mat may ngay de go.
    --
    -- Thay vao do cong don mot he so KHUECH DAI sat thuong len chinh
    -- hero do: cung ket qua "cang danh lau cang de vo", ma khong ai
    -- phai so huu lai giap.
    if hasMech(b, "shred") and API.heroPidOf ~= nil then
      local pid = API.heroPidOf(tgt)
      if pid ~= nil and S.p[pid] ~= nil then
        local d = S.p[pid]
        d.bossShred = (d.bossShred or 0.0) + mechNum("shred", "perHit")
        if BlzSetEventDamage ~= nil then
          BlzSetEventDamage(dmg * (1.0 + d.bossShred))
        end
      end
    end
  end
end

-- ---------- Do luc vao map ----------

local function probe()
  if CreateUnit == nil or CFG.BOSSES == nil then return end
  local bad = {}
  for i = 1, #CFG.BOSSES do
    local d = CFG.BOSSES[i]
    local u = CreateUnit(S.enemy, d.unit, 0.0, 0.0, 0.0)
    local tag = "r" .. d.r .. " " .. API.idToStr(d.unit)
    if u == nil then
      bad[#bad + 1] = tag .. " KHONG CO"
    else
      local flying  = (IsUnitType ~= nil) and IsUnitType(u, UNIT_TYPE_FLYING) or false
      local hero = (IsUnitType ~= nil) and IsUnitType(u, UNIT_TYPE_HERO) or false
      if flying then bad[#bad + 1] = tag .. " BIET BAY" end
      if not hero then bad[#bad + 1] = tag .. " khong phai HERO" end
      RemoveUnit(u)
    end
  end
  if #bad > 0 then
    API.msg(nil, CFG.C_RED .. "BOSS SAI: " .. table.concat(bad, " | ") .. CFG.C_END)
    API.trace("boss: SAI -- " .. table.concat(bad, " | "))
  else
    API.trace("boss: " .. #CFG.BOSSES .. " ban thiet ke hop le (hero, khong bay)")
  end
end

local function startBoss()
  S.boss = nil
  probe()
  if BlzGetEventDamageTarget ~= nil then
    local t = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(t, onDamage)
  end
  API.trace("boss: san sang")
end

API.bossSpawn = spawn
API.bossTick  = tick
API.startBoss = startBoss
