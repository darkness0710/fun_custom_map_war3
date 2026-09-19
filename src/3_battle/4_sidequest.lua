-- ============================================================
--  3_battle/4_sidequest.lua -- Bon Thanh Thu: boss pho ban
--
--  KHAC boss thuong o ba diem, va ca ba deu keo theo he qua:
--
--    dung san tu luc vao map  -> khong do doi duoc (luc do ca doi con
--                                o Pham Nhan), nen chi so suy tu CHINH
--                                CANH GIOI CUA
--    nguoi choi tim toi no    -> no khong duoc phep di dau ca
--    ha xong thu phuc         -> chet la doi pet va dua nguoi choi ve
--
--  VI SAO ENGINE RIENG, khong dung chung voi 3_boss.lua:
--
--  3_boss.lua bam vao S.boss -- MOT bien, sau cho doc thang. O day co
--  BON con dung cung luc, cong boss dot la nam. Doi S.boss thanh danh
--  sach la sua vao trai tim cua he dang ganh 20 boss chinh cua ca van:
--  onDamage phai duyet N con o cho nong nhat, co casting phai tach theo
--  tung con, va dong trace "CHET sau ...s" dung de do BOSS_SKILL_SHARE
--  se mat.
--
--  Doi lai: sua mot co che thi phai sua hai cho. Chap nhan, it nhat cho
--  toi khi Thanh Thu choi thu xong va biet giu lai bo co che nao.
--
--  Ba ham THUAN TUY thi van dung chung (API.bossForEachEnemy,
--  bossSlamRing, bossMechNum) -- chung khong doc trang thai nao.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function mechNum(name, field)
  return API.bossMechNum(name, field)
end

local function hasMech(b, name)
  return b ~= nil and b.mech ~= nil and b.mech[name] == true
end

local function strike(b, tgt, dmg)
  UnitDamageTarget(b.u, tgt, dmg, true, false,
                   ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
end

local function enrageMult(b)
  return b.enraged and mechNum("enrage", "dmg") or 1.0
end

-- ---------- Chi so: DO DOI, luc NGUOI CHOI BUOC VAO ----------
--
-- LOI DA SHIP: ban dau suy tu canh gioi cua. Do duoc tu file vet (canh
-- gioi 16, mot hero): chi so that 30.105, phan tu canh gioi chi 511 --
-- tuc 1,7%. Trang bi va ky nang chiem 98,3%, gap 59 lan. Ket qua: con
-- dau qua dai, ba con sau vo trong mot nhip.
--
-- Gio dung CHINH measureParty() cua boss thuong, nhung goi LUC BUOC
-- VAO: luc sinh (vao map) ca doi con o canh gioi 1 va phep do vo nghia.
local function armStats(q)
  local dps, ehpAvg, n = API.bossMeasureParty()
  if n == 0 then return nil, nil, 0 end

  local hp = dps * (q.seconds or CFG.SIDE_QUEST_SECONDS or 60.0)
  -- ehpAvg la mau HIEU DUNG -- da chia cho (1 - giam tu giap). Khong
  -- chia thi cuoi van hero co 8.070 giap (giam 99,79%) va don cua boss
  -- cham toi chi con 4 mau.
  local dmg = ehpAvg / (q.hits or CFG.SIDE_QUEST_HITS or 14.0)
  if hp < 1.0 then hp = 1.0 end
  if dmg < 1.0 then dmg = 1.0 end
  return math.floor(hp + 0.5), math.floor(dmg + 0.5), n
end

-- ---------- Co che ----------

local function groundSlam(b)
  local x, y = GetUnitX(b.u), GetUnitY(b.u)
  local r    = mechNum("slam", "radius")
  local cast = mechNum("slam", "cast")
  if cast <= 0.0 then cast = 0.1 end

  b.casting = true
  PauseUnit(b.u, true)
  API.fx(CFG.FX_HIT_BUFF, x, y)
  API.bossSlamRing(x, y, r)
  API.msg(nil, CFG.C_RED .. API.t("boss_slam_cast") .. CFG.C_END)

  -- Ve lai vong tron vai lan: hieu ung WC3 dien mot lan roi tat, ve mot
  -- lan thi nguoi choi chi thay mot cai chop chu khong thay VONG.
  for i = 1, 2 do
    API.after(cast * i / 3.0, function()
      if b.casting then API.bossSlamRing(x, y, r) end
    end)
  end

  API.after(cast, function()
    b.casting = false
    -- Bo khoa TRUOC khi kiem con song: xac dang bi PauseUnit thi khong
    -- ruc ra duoc, va con boss chet giua luc cast la truong hop thuong.
    if b.u ~= nil then PauseUnit(b.u, false) end
    if b.u == nil or not API.alive(b.u) then return end
    local dmg = b.dmg * mechNum("slam", "factor")
    API.fx(CFG.FX_SLAM_HIT, x, y)
    API.bossForEachEnemy(x, y, r, function(t) strike(b, t, dmg) end)
  end)
end

-- Lao toi hero XA NHAT trong hang. Khac boss dot: chi tinh hero DANG O
-- TRONG PHO BAN -- lao toi mot nguoi dang o nha chinh thi con boss bay
-- nua ban do va pho ban tu giai tan.
local function charge(b)
  local bx, by = GetUnitX(b.u), GetUnitY(b.u)
  local reach = (CFG.SIDE_QUEST_LEASH or 1400.0)
  local far, dmax = nil, -1.0
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h) then
      local dist = API.distXY(bx, by, GetUnitX(h), GetUnitY(h))
      if dist <= reach and dist > dmax then far, dmax = h, dist end
    end
  end
  if far == nil then return end
  SetUnitPosition(b.u, GetUnitX(far), GetUnitY(far))
  API.fx(CFG.FX_HIT_LINE, GetUnitX(far), GetUnitY(far))
  API.msg(nil, CFG.C_RED .. API.t("boss_charge") .. CFG.C_END)
  strike(b, far, b.dmg * mechNum("charge", "factor") * enrageMult(b))
end

local function summonAdds(b)
  local n = math.floor(mechNum("summon", "count"))
  if n <= 0 or API.waveSpawnAt == nil then return end
  -- waveSpawnAt(stage, realm, x, y) -- BON tham so. Goi qua he wave de
  -- thuoc ha cung duong cong, cung tien thuong, va cung duoc dem vao
  -- S.alive; neu khong, don sach wave xong ma con thuoc ha thi dong ho
  -- wave treo.
  --
  -- Thanh Thu khong co "stage" cua rieng no. Suy tu canh gioi cua bang
  -- API.stagesPerRealm() chu khong go hang so -- doi so dot moi canh
  -- gioi thi cho nay tu theo.
  local realm = b.def.rank
  local per   = (API.stagesPerRealm ~= nil) and API.stagesPerRealm() or 5
  local stage = realm * per
  local x, y = GetUnitX(b.u), GetUnitY(b.u)
  for i = 1, n do
    local a = 360.0 * i / n
    API.waveSpawnAt(stage, realm,
                    API.polarX(x, 220.0, a), API.polarY(y, 220.0, a))
  end
  API.msg(nil, CFG.C_GREY .. API.t("boss_summon") .. CFG.C_END)
end

local function shieldUp(b)
  b.shield = b.shield + b.maxHp * mechNum("shield", "ratio")
  API.fx(CFG.FX_HIT_BUFF, GetUnitX(b.u), GetUnitY(b.u))
  API.msg(nil, CFG.C_GREY .. API.t("boss_shield") .. CFG.C_END)
end

-- ---------- Tiet luu dau hieu ----------
-- Cung ly do voi boss dot: ba co che lifesteal/reflect/shred chi co so,
-- khong ve gi -- nguoi choi khong the biet la no dang co.
local function beat1s(b, key)
  local t = b.age or 0.0
  if (b[key] or -99.0) + 1.0 > t then return false end
  b[key] = t
  return true
end

local function sayOnce(b, key, msg)
  if b[key] then return end
  b[key] = true
  API.msg(nil, msg)
end
-- ---------- Nap chi so luc buoc vao ----------
--
-- Goi tu onSideQuest() ngay sau khi dich chuyen. CHI nap khi con do dang
-- DAY MAU -- neu khong, nguoi thu hai buoc vao giua tran se hoi day mau
-- con boss va xoa het cong danh cua nguoi dau.
local function arm(i)
  local b = (S.side or {})[i]
  if b == nil or b.u == nil or not API.alive(b.u) then return end
  if b.armed and GetUnitState(b.u, UNIT_STATE_LIFE)
                 < GetUnitState(b.u, UNIT_STATE_MAX_LIFE) then
    return
  end

  local hp, dmg, n = armStats(b.def)
  if hp == nil then return end

  if BlzSetUnitMaxHP ~= nil then
    BlzSetUnitMaxHP(b.u, hp)
    SetUnitState(b.u, UNIT_STATE_LIFE, GetUnitState(b.u, UNIT_STATE_MAX_LIFE))
  end
  if BlzSetUnitBaseDamage ~= nil then BlzSetUnitBaseDamage(b.u, dmg, 0) end
  local was = b.maxHp or 0
  b.maxHp, b.dmg, b.armed, b.age = hp, dmg, true, 0.0
  b.enraged, b.shield = false, 0.0
  SetUnitVertexColor(b.u, 255, 255, 255, 255)

  -- CHI ghi vet khi con so DOI DANG KE. Ham nay chay moi nhip khi hang
  -- trong -- 4 con x 1 giay, ghi moi lan thi file vet phinh vo han va
  -- nuot mat nhung dong that su dang doc.
  --
  -- Nguong 10%: doi duoi muc do la doi vat va (mot hero hoi mau), tren
  -- muc do la doi that (len canh gioi, mua trang bi, them nguoi choi).
  if was <= 0 or math.abs(hp - was) > was * 0.10 then
    API.trace(string.format(
      "sidequest: %d %s NAP -- %d hero, mau %d (%.0fs hoa luc), don %d (%.0f don)",
      i, API.pick(b.def), n, hp,
      b.def.seconds or CFG.SIDE_QUEST_SECONDS or 60.0,
      dmg, b.def.hits or CFG.SIDE_QUEST_HITS or 14.0))
  end
end


-- ---------- Nhip ----------
--
-- CHI chay con nao CO NGUOI trong hang. Bon con danh vao phong trong tu
-- phut dau van dau thi chat day dong bao va man hinh day hieu ung, cho
-- mot tran khong ai xem.
local function anyHeroNear(b)
  local reach = (CFG.SIDE_QUEST_LEASH or 1400.0)
  local bx, by = GetUnitX(b.u), GetUnitY(b.u)
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h)
       and API.distXY(bx, by, GetUnitX(h), GetUnitY(h)) <= reach then
      return true
    end
  end
  return false
end

local function tickOne(b, dt)
  if b.u == nil or not API.alive(b.u) then return end

  -- Day xich: keo ve hang neu di qua xa. Dung khoang cach chu khong
  -- dung vung -- vung la hinh chu nhat hep, ma danh nhau thi hai ben xe
  -- dich lien tuc.
  local dx, dy = GetUnitX(b.u) - b.hx, GetUnitY(b.u) - b.hy
  local far = (CFG.SIDE_QUEST_LEASH or 1400.0)
  if dx * dx + dy * dy > far * far then
    IssuePointOrder(b.u, "move", b.hx, b.hy)
    return
  end

  if not anyHeroNear(b) then return end
  b.age = (b.age or 0.0) + dt

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

  -- Dang cast Chan Dia thi khong lam gi khac: lao di giua chung thi no
  -- bien khoi vong tron vua ve ra, va loi hua "dung o day se an don"
  -- thanh noi doi.
  if b.casting then return end

  local function beat(field, name, f)
    if not hasMech(b, name) then return end
    b[field] = b[field] - dt
    if b[field] <= 0.0 then b[field] = mechNum(name, "cd"); f(b) end
  end
  beat("cdSlam",   "slam",   groundSlam)
  beat("cdCharge", "charge",      charge)
  beat("cdSummon", "summon", summonAdds)
  beat("cdShield", "shield",   shieldUp)
end

-- Bo ghim khi LAN THU DA BO DO.
--
-- Ghim chi so la dung (xem armPin), nhung ghim VINH VIEN thi sai: cham
-- vao con thu mot cai luc vua mo khoa roi bo di se dong bang no o suc
-- manh cua doi luc do, va quay lai sau mot tieng van gap dung con so ay.
--
-- Chi bo hai co; arm() lo phan con lai -- no tu hoi day mau, tat cuong,
-- xoa khien va dat lai b.age. Viet lai o day la hai noi cung khai mot
-- viec, roi mot ngay chi sua mot noi.
local function release(b)
  b.pinned = false
  b.armed  = false
end

local function tick()
  local dt = CFG.SIDE_QUEST_TICK or 1.0
  for i = 1, #(S.side or {}) do
    local b = S.side[i]
    if b ~= nil then
      -- NAP CHI SO KHI KHONG CO AI TRONG HANG.
      --
      -- LOI DA SHIP: truoc day chi nap luc bam Tien Hanh, nen tu luc vao
      -- map toi luc ai do buoc vao, ca bon con van la ban goc Hmkg --
      -- GIONG HET NHAU. Nguoi choi nhin vao thay bon con y het, va
      -- tuong he chi so khong chay.
      --
      -- Nap o day thi chung khac nhau ngay khi doi co hero dau tien, va
      -- tu cap nhat khi doi manh len -- khong phai doi buoc vao moi dung.
      --
      -- arm() tu tu choi neu con do dang bi danh do (mau < toi da), nen
      -- goi moi nhip khong xoa cong nguoi dang danh. Nhung van chan them
      -- o day: co nguoi trong hang la KHONG nap, du mau con day.
      --
      -- b.pinned: da co nguoi bam "Tien Hanh" mot lan roi thi THOI theo
      -- doi. Xem armPin() ben duoi.
      --
      -- b.idle dem giay LIEN TUC khong co ai trong hang. Du lau thi coi
      -- nhu lan thu da bo do: bo ghim, va nhip ngay sau do arm() se do
      -- lai tu dau. Dem o day chu khong trong tickOne vi tickOne thoat
      -- som khi khong co ai gan -- dung cho ta can dem.
      if anyHeroNear(b) then
        b.idle = 0.0
      else
        b.idle = (b.idle or 0.0) + dt
        if b.pinned and b.idle >= (CFG.SIDE_QUEST_RESET or 20.0) then
          release(b)
          API.trace("sidequest: " .. i .. " BO GHIM -- bo hoang " ..
                    math.floor(b.idle) .. "s")
        end
        if not b.pinned then arm(i) end
      end
      tickOne(b, dt)
    end
  end
end

-- ---------- Su kien sat thuong ----------

local function bossOf(u)
  for i = 1, #(S.side or {}) do
    local b = S.side[i]
    if b ~= nil and b.u == u then return b end
  end
  return nil
end

local function onDamage()
  local tgt = (BlzGetEventDamageTarget ~= nil) and BlzGetEventDamageTarget()
              or GetTriggerUnit()
  local src = GetEventDamageSource()
  local dmg = GetEventDamage()
  if dmg <= 0.0 then return end

  -- THANH THU AN DON
  local b = bossOf(tgt)
  if b ~= nil then
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
      if beat1s(b, "fxReflect") then
        API.fx(CFG.FX_HIT_CLEAVE, GetUnitX(src), GetUnitY(src))
      end
      sayOnce(b, "saidReflect", CFG.C_RED ..
        API.t("boss_reflect", math.floor(mechNum("reflect", "ratio") * 100 + 0.5))
        .. CFG.C_END)
    end
    return
  end

  -- THANH THU GAY DON
  b = bossOf(src)
  if b == nil then return end

  if hasMech(b, "lifesteal") then
    local hp = GetUnitState(b.u, UNIT_STATE_LIFE) + dmg * mechNum("lifesteal", "ratio")
    local mx = GetUnitState(b.u, UNIT_STATE_MAX_LIFE)
    SetUnitState(b.u, UNIT_STATE_LIFE, (hp > mx) and mx or hp)
    if beat1s(b, "fxSteal") then
      API.fx(CFG.FX_HIT_HEAL, GetUnitX(b.u), GetUnitY(b.u))
    end
    sayOnce(b, "saidSteal", CFG.C_RED ..
      API.t("boss_lifesteal", math.floor(mechNum("lifesteal", "ratio") * 100 + 0.5))
      .. CFG.C_END)
  end

  -- XE GIAP: KHONG sua giap that -- giap la cua engine tu luc
  -- heroRecompute thoi so huu no. Cong don mot he so KHUECH DAI len
  -- chinh hero do: cung ket qua "cang danh lau cang de vo".
  if hasMech(b, "shred") and API.heroPidOf ~= nil then
    local pid = API.heroPidOf(tgt)
    if pid ~= nil and S.p[pid] ~= nil then
      local d = S.p[pid]
      d.bossShred = (d.bossShred or 0.0) + mechNum("shred", "perHit")
      if BlzSetEventDamage ~= nil then
        BlzSetEventDamage(dmg * (1.0 + d.bossShred))
      end
      local step = math.floor(d.bossShred / 0.25)
      if step > (d.bossShredSaid or 0) then
        d.bossShredSaid = step
        API.msg(pid, CFG.C_RED ..
          API.t("boss_shred", math.floor(d.bossShred * 100 + 0.5)) .. CFG.C_END)
      end
      if beat1s(b, "fxShred") then
        API.fx(CFG.FX_HIT_CLEAVE, GetUnitX(tgt), GetUnitY(tgt))
      end
    end
  end
end

-- ---------- Sinh ----------

local function spawnOne(i)
  local q = CFG.SIDE_QUESTS[i]
  if q == nil then return nil end

  local r = API.findRegion(q.lair)
  if r == nil then
    API.trace("sidequest: thieu vung hang " .. API.regionLabel(q.lair) ..
              " -- khong sinh duoc " .. API.pick(q))
    return nil
  end

  local x, y = API.regionCenter(r)
  local u = CreateUnit(S.enemy, q.unit, x, y, 270.0)
  if u == nil then
    API.trace("sidequest: CreateUnit nil cho " .. API.idToStr(q.unit))
    return nil
  end

  -- CHUA dat mau/don o day. Luc nay ca doi con o canh gioi 1 va chua co
  -- trang bi -- do bay gio thi con boss se yeu gap hang chuc lan so voi
  -- luc nguoi choi thuc su buoc vao. Chi so nap trong arm().
  --
  -- Khong cho giap, cung ly do voi boss dot: mau tinh ra DA la mau hieu
  -- dung can de tru, cho them giap la tru hai lan.
  if BlzSetUnitArmor ~= nil then BlzSetUnitArmor(u, 0.0) end
  -- Hero thi co kinh nghiem. Khoa lai, khong thi no len cap trong luc
  -- dung khong va moi con so vua tinh truot het.
  if SuspendHeroXP ~= nil then SuspendHeroXP(u, true) end
  -- TAM SAN: du de danh ai buoc vao hang, khong du de duoi ra ngoai.
  -- Dat 0 la sai -- tam san 0 nghia la no khong tu chon muc tieu, va
  -- nhieu kha nang cung khong danh tra. Tam san binh thuong CONG day
  -- xich o tickOne() thi dung du tam san hanh xu the nao.
  if SetUnitAcquireRange ~= nil then
    SetUnitAcquireRange(u, CFG.SIDE_QUEST_AGGRO or 800.0)
  end
  SetUnitScale(u, CFG.SIDE_QUEST_SCALE or 1.6,
                  CFG.SIDE_QUEST_SCALE or 1.6,
                  CFG.SIDE_QUEST_SCALE or 1.6)

  local mech = {}
  for k = 1, #(q.mech or {}) do mech[q.mech[k]] = true end

  S.side[i] = {
    u = u, idx = i, def = q, mech = mech,
    dmg = 0, maxHp = 0, armed = false, hx = x, hy = y,
    enraged = false, casting = false, shield = 0.0, age = 0.0,
    cdSlam   = mechNum("slam",   "cd"), cdCharge = mechNum("charge", "cd"),
    cdSummon = mechNum("summon", "cd"), cdShield = mechNum("shield", "cd"),
  }
  API.trace(string.format(
    "sidequest: %d %s o %s -- co che [%s], moc canh gioi %d, chua nap chi so",
    i, API.pick(q), API.regionLabel(q.lair),
    table.concat(q.mech or {}, " "), q.rank))
  return u
end


-- ---------- Ha xong ----------
--
-- Chay tren MOI may: su kien unit chet ban dong bo san, khong phai di
-- qua syncSend.
local function onDeath()
  local u = GetTriggerUnit()
  if u == nil then return end
  local b = bossOf(u)
  if b == nil then return end

  local q = b.def

  -- Lay toa do TRUOC khi buong b: phan thuong chia theo ai dang dung
  -- trong hang, ma biet ai dung trong hang thi phai biet hang o dau.
  -- Doc toa do cua xac van duoc -- unit chua bi Remove.
  local bx, by = GetUnitX(b.u), GetUnitY(b.u)
  local reach  = (CFG.SIDE_QUEST_LEASH or 1400.0)

  -- CO DA HA -- co cua CHUNG, khong nam trong S.p[pid]: con thu chi co
  -- mot, ha roi la ca doi ha roi. Phap Khi doc co nay de mo khoa.
  if S.sideDone == nil then S.sideDone = {} end
  S.sideDone[b.idx] = true
  if API.relicUnlocked ~= nil then API.relicUnlocked(b.idx) end

  S.side[b.idx] = nil
  API.trace(string.format("sidequest: %d %s CHET sau %.1fs (thiet ke %.0fs)",
    b.idx, API.pick(q), b.age or 0.0, CFG.SIDE_QUEST_SECONDS or 60.0))
  API.msg(nil, CFG.C_GOLD .. API.t("sq_tamed", API.pick(q)) .. CFG.C_END)

  -- PHAN THUONG: luot Co Duyen, chia theo MOC.
  --
  -- Chi cho ai CO MAT trong hang. Nguoi dang o nha chinh farm quai ma
  -- van an thuong thi mot nguoi danh ca doi cung giau -- va tran 240
  -- giay cua Thanh Long mat het y nghia.
  --
  -- Khong doi con song: chet TRONG hang van la da danh. Xac nam ngay
  -- do, nen phep do khoang cach van dung.
  local rolls = q.rolls or 0

  -- Doi pet sang con vua ha, va dua nguoi choi ve. Dua ve la PHAN THUONG
  -- cho viec thang, va no cung tranh phai ve them mot vung cua ra.
  for k = 1, #S.pids do
    local pid = S.pids[k]
    local d = S.p[pid]
    if d ~= nil and d.hero ~= nil then
      local near = API.distXY(bx, by, GetUnitX(d.hero),
                              GetUnitY(d.hero)) <= reach
      if rolls > 0 then
        if near and API.fortuneAddRolls ~= nil then
          API.fortuneAddRolls(pid, rolls)
          API.msg(pid, CFG.C_GOLD ..
            API.t("sq_reward", API.pick(q), rolls) .. CFG.C_END)
        elseif not near then
          -- Noi RO vi sao khong co gi. Im lang thi nguoi choi tuong he
          -- thuong hong, va lan sau van dung ngoai.
          API.msg(pid, CFG.C_GREY ..
            API.t("sq_noreward", API.pick(q)) .. CFG.C_END)
        end
      end

      if API.alive(d.hero) then
        -- SUU TAM, khong ghi de. Truoc day "d.petUnit = q.unit" lam
        -- ha con thu thu hai la mat con thu nhat -- bon chien loi pham
        -- ma chi giu duoc mot.
        --
        -- Co la CUA CHUNG (S.sideDone) nhung con DANG DI THEO la cua
        -- rieng tung nguoi: hai nguoi trong mot doi chon hai con khac
        -- nhau duoc.
        if d.petOwn == nil then d.petOwn = {} end
        d.petOwn[b.idx] = true
        d.petUnit = q.unit
        if API.petSpawn ~= nil then API.petSpawn(pid) end
        if API.goHome ~= nil then API.goHome(pid) end
      end
    end
  end
end

-- ---------- Nhac khi du dieu kien ----------
--
-- Bang nhiem vu nam sau mot phim va mot the -- nguoi choi khong mo no
-- moi phut de kiem. Khong nhac thi mot pho ban co the mo tu lau ma
-- khong ai biet.
--
-- Nho tung nguoi da duoc nhac con nao (d.sqSeen): nhac lai moi lan dot
-- pha thi tu dong vien thanh tieng on.
local function checkUnlock(pid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  if d.sqSeen == nil then d.sqSeen = {} end

  local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
  for i = 1, #(CFG.SIDE_QUESTS or {}) do
    local q = CFG.SIDE_QUESTS[i]
    if rank >= q.rank and not d.sqSeen[i] then
      d.sqSeen[i] = true
      API.msg(pid, CFG.C_GOLD .. API.t("sq_unlocked", i, API.pick(q)) ..
                   CFG.C_END)
    end
  end
end

-- ---------- Khoi dong ----------

local function startSideQuest()
  S.side = {}
  if CFG.SIDE_QUESTS == nil then return end

  local td = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(td, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddAction(td, onDeath)
  S.sideDeathTrig = td

  local tdm = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(tdm, EVENT_PLAYER_UNIT_DAMAGED)
  TriggerAddAction(tdm, onDamage)
  S.sideDmgTrig = tdm

  local n = 0
  for i = 1, #CFG.SIDE_QUESTS do
    if spawnOne(i) ~= nil then n = n + 1 end
  end

  S.sideTimer = CreateTimer()
  TimerStart(S.sideTimer, CFG.SIDE_QUEST_TICK or 1.0, true, tick)
  API.trace("sidequest: sinh " .. n .. "/" .. #CFG.SIDE_QUESTS ..
            " Thanh Thu, day xich " .. (CFG.SIDE_QUEST_LEASH or 1400.0))
end

-- NAP ROI GHIM -- goi dung mot lan, luc nguoi choi bam "Tien Hanh".
--
-- Truoc do tick() van nap lai moi nhip khi hang trong, de bon con khac
-- nhau ngay tu dau van va lon len theo doi. Nhung tu giay nguoi choi
-- buoc vao, con so phai DUNG LAI.
--
-- LOI DA SHIP: khong ghim thi rut lui la vo nghia. Danh khong lai, chay
-- ve nha mua trang bi, quay lai -- con thu vua nap lai theo suc moi cua
-- ta, manh len dung bay nhieu. Khong co duong nao thang mot con minh
-- chua du suc, tru viec danh mot mach.
--
-- Ghim xong thi moc canh gioi moi co nghia that: con thu duoc do theo
-- suc cua doi DUNG LUC CAM KET, va mo trang bi sau do la loi cua nguoi
-- choi chu khong bi he thong doi lai.
local function armPin(i)
  arm(i)
  local b = (S.side or {})[i]
  if b ~= nil and b.armed then
    b.pinned = true
    API.trace("sidequest: " .. i .. " GHIM chi so (mau " ..
              (b.maxHp or 0) .. ", don " .. (b.dmg or 0) .. ")")
  end
end

API.startSideQuest = startSideQuest
API.sideQuestArm   = armPin
API.sideQuestCheck = checkUnlock
