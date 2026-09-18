-- ============================================================
--  7_effect.lua  --  Ky nang co hieu luc that
--
--  Truoc file nay, bay ky nang cua Hart la bay ability GOC cua Warcraft
--  duoc nhan ban: Shockwave, Holy Light, Devotion Aura, Avatar... Chung
--  gay dung so sat thuong ma Blizzard dat, va KHONG an theo bat cu thu
--  gi nguoi choi mua. Linh Can bac 20 cong +1075 moi chi so; Chuong van
--  gay dung ngan ay sat thuong nhu wave 1.
--
--  Do la ly do CFG.SKILL_DATA_LIVE ton tai, va vi sao no tung la false.
--
--  VI SAO KHONG SUA TRUONG TRONG war3map.w3a
--
--  Cach "chinh thong" la ghi so vao truong Data cua Shockwave. Khong lam
--  duoc: ma truong cua AOsh / AHhb / AHad CHUA AI DO
--  (docs/06-object-editor/sua-va-clone-ability.md), ma du an nay co luat
--  khong doan -- doan sai mot ma truong bon ky tu la file hong am tham,
--  kieu te nhat.
--
--  Nen file nay bat su kien va TU gay sat thuong. Khong can biet ma
--  truong nao ca. Sat thuong goc cua Warcraft van con, nhung o bac 10
--  voi Linh Can bac 20 thi no la sai so lam tron.
--
--  BAY LOAI HIEU UNG, khai bao bang truong 'fx' trong CFG.SKILLS:
--    line heal buff        chu dong, bat qua su kien cast
--    cleave reduce         bi dong, bat qua su kien sat thuong
--    stat aura             bi dong, tinh lai khi bac ky nang doi
--
--  Bay loai nay dung lai duoc cho Hvwd va Hkal -- them hero moi la khai
--  bao them dong trong CFG.SKILLS, khong phai viet them code o day.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Chan de quy: sat thuong do CHINH file nay gay ra cung ban su kien
-- EVENT_PLAYER_UNIT_DAMAGED. Khong chan thi Chem Lan van lan nhau vo han
-- va game treo ngay wave dau.
local busy = false

-- Bao THIEU BlzGetEventDamageType dung mot lan, khong phai moi don --
-- mot dong moi cu danh la file vet khong con doc duoc.
local dmgTypeWarned = false

-- ---------- Tra cuu ----------

-- Tra ve (sk, bac) cua mot ability tren hero cua nguoi nay. Bac 0 hoac
-- khong tim thay thi tra nil -- goi ben ngoai chi can kiem mot lan.
local function skillOf(pid, abilId)
  local list = API.skillList(pid)
  for i = 1, #list do
    if list[i].id == abilId then
      local lv = API.skillLevel(pid, abilId, i)
      if lv > 0 then return list[i], lv end
      return nil
    end
  end
  return nil
end

-- Tim ky nang theo LOAI hieu ung. Dung cho bi dong: luc bi danh thi ta
-- khong biet ability nao, chi biet "nguoi nay co Da Sat khong".
local function skillByFx(pid, fx)
  local list = API.skillList(pid)
  for i = 1, #list do
    if list[i].fx == fx then
      local lv = API.skillLevel(pid, list[i].id, i)
      if lv > 0 then return list[i], lv end
      return nil
    end
  end
  return nil
end

local function heroPid(u)
  if u == nil then return nil end
  local pid = GetPlayerId(GetOwningPlayer(u))
  local d = S.p[pid]
  if d == nil or d.hero ~= u then return nil end
  return pid
end

-- ---------- Nhat muc tieu ----------

local function enemiesNear(x, y, radius, f)
  local g = CreateGroup()
  GroupEnumUnitsInRange(g, x, y, radius, nil)
  local u = FirstOfGroup(g)
  while u ~= nil do
    GroupRemoveUnit(g, u)
    -- Chi quai cua phe dich. Khong dung IsUnitEnemy: no hoi "dich voi
    -- AI", ma o day ta luon muon dung mot phe duy nhat.
    if API.alive(u) and GetOwningPlayer(u) == S.enemy then f(u) end
    u = FirstOfGroup(g)
  end
  DestroyGroup(g)
end

-- Gay sat thuong, co co chan de quy.
local function hit(src, tgt, amount, model)
  if amount <= 0 or not API.alive(tgt) then return end
  busy = true
  UnitDamageTarget(src, tgt, amount, true, false,
                   ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
  busy = false
  if model ~= nil then API.fx(model, GetUnitX(tgt), GetUnitY(tgt)) end

  -- NHAN an ca o duong ky nang. 'busy' lam onDamaged() return ngay dong
  -- dau, nen neu khong goi o day thi hut mau chi chay tren don thuong --
  -- kieu sai im lang, va hero danh phep thi khong hieu vi sao khong hoi.
  if API.gearLifesteal ~= nil and API.heroPidOf ~= nil then
    local sp = API.heroPidOf(src)
    if sp ~= nil then API.gearLifesteal(sp, amount) end
  end
end

-- ---------- Ky nang chu dong ----------

-- "line": danh tren mot duong thang truoc mat.
--
-- Khoang cach tu mot diem toi DUONG THANG, khong phai toi diem cuoi --
-- neu khong thi con dung sat ben canh hero se khong an don du no nam
-- ngay tren duong danh.
local function fxLine(pid, u, sk, lv)
  local x, y = GetUnitX(u), GetUnitY(u)
  local tx, ty = x, y
  if GetSpellTargetX ~= nil then tx, ty = GetSpellTargetX(), GetSpellTargetY() end
  if tx == x and ty == y then
    -- Khong co diem nham thi danh theo huong dang quay.
    tx = API.polarX(x, CFG.FX_LINE_LEN, GetUnitFacing(u))
    ty = API.polarY(y, CFG.FX_LINE_LEN, GetUnitFacing(u))
  end

  local ang = API.angleXY(x, y, tx, ty)
  local L   = CFG.FX_LINE_LEN
  local cx  = API.polarX(x, L * 0.5, ang)
  local cy  = API.polarY(y, L * 0.5, ang)
  local dmg = API.skillDamage(u, API.skillFactor(sk, lv))

  local ux, uy = Cos(ang * bj_DEGTORAD), Sin(ang * bj_DEGTORAD)
  enemiesNear(cx, cy, L * 0.5 + CFG.FX_LINE_WIDTH, function(e)
    local dx, dy = GetUnitX(e) - x, GetUnitY(e) - y
    local along = dx * ux + dy * uy                 -- chieu len duong danh
    if along < 0.0 or along > L then return end
    local perp = dx * (-uy) + dy * ux            -- khoang cach toi duong
    if perp < 0 then perp = -perp end
    if perp > CFG.FX_LINE_WIDTH then return end
    hit(u, e, dmg, CFG.FX_HIT_LINE)
  end)
end

-- "heal": hoi mau mot muc tieu. Khong co muc tieu thi hoi chinh minh.
local function fxHeal(pid, u, sk, lv)
  local t = (GetSpellTargetUnit ~= nil) and GetSpellTargetUnit() or nil
  if t == nil then t = u end
  local amount = API.skillDamage(u, API.skillFactor(sk, lv))
  local hp = GetUnitState(t, UNIT_STATE_LIFE) + amount
  local mx = GetUnitState(t, UNIT_STATE_MAX_LIFE)
  SetUnitState(t, UNIT_STATE_LIFE, (hp > mx) and mx or hp)
  API.fx(CFG.FX_HIT_HEAL, GetUnitX(t), GetUnitY(t))
end

-- "buff" KHONG con ham Lua nao.
--
-- Bat Hoai la ban sao cua Avatar, va Avatar tu co buff co thoi luong.
-- Giap cua no lay tu ABILITY_RLF_DEFENSE_BONUS_HAV1 -- truong ma
-- applyLevel() ghi so can bang cua ta vao (CFG.SKILL_CARRY_BASE). Nen
-- khong con gi de lam bang Lua: bam la Warcraft lo het.
--
-- Thoi luong gio la thoi luong goc cua Avatar, khong phai
-- CFG.FX_BUFF_TIME. Muon doi thi dat truong 'adur'/'ahdu' trong
-- war3map.w3a.
--
-- HAV2 (mau toi da) van chay: ban 1.31.1 khong phoi ra hang so nao cho
-- no nen khong tat duoc -- xem chu thich o CFG.SKILL_ZERO_BASE.

local FX_CAST = { line = fxLine, heal = fxHeal }

local function onSpell()
  local u = GetTriggerUnit()
  if u == nil then return end
  local pid = heroPid(u)
  if pid == nil then return end

  local sk, lv = skillOf(pid, GetSpellAbilityId())
  if sk == nil or sk.fx == nil then return end

  local f = FX_CAST[sk.fx]
  if f ~= nil then f(pid, u, sk, lv) end
end

-- ---------- Ky nang bi dong bat qua su kien sat thuong ----------

local function onDamaged()
  if busy then return end                -- sat thuong cua chinh ta

  local amount = GetEventDamage()
  if amount <= 0.0 then return end

  local tgt = (BlzGetEventDamageTarget ~= nil) and BlzGetEventDamageTarget()
              or GetTriggerUnit()
  local src = GetEventDamageSource()

  -- hero NHAN don. HAI nguon giam sat thuong: bi dong "reduce" va mon
  -- Khien (%chong chiu).
  --
  -- Chung NHAN voi nhau chu khong cong. Cong thi hai nguon du manh se
  -- cham 100% va hero thanh bat tu; nhan thi khong bao gio toi, va ti le
  -- moi nguon dong gop van doc ra duoc.
  --
  -- MOT lan ghi duy nhat, dung luat cua recompute ben duoi: gom het roi
  -- ghi, khong doc-cong-ghi-lai.
  local tp = heroPid(tgt)
  if tp ~= nil and BlzSetEventDamage ~= nil then
    local keep = 1.0

    local sk, lv = skillByFx(tp, "reduce")
    if sk ~= nil then
      local pct = API.skillPct(sk, lv)
      if pct > CFG.FX_REDUCE_CAP then pct = CFG.FX_REDUCE_CAP end
      keep = keep * (1.0 - pct)
    end

    -- Khien chan DON DANH, Ao Choang chan PHEP -- nen phai hoi engine day
    -- don loai gi.
    --
    -- Thieu BlzGetEventDamageType thi KHONG nuot im: coi la don danh
    -- (loai pho bien nhat) va GHI VET mot lan, de "Ao Choang khong an gi"
    -- khong bi tuong la loi can bang. ADR 0012.
    if API.gearMitigPct ~= nil then
      local spell = false
      if BlzGetEventDamageType ~= nil then
        spell = (BlzGetEventDamageType() ~= DAMAGE_TYPE_NORMAL)
      elseif not dmgTypeWarned then
        dmgTypeWarned = true
        API.trace("effect: THIEU BlzGetEventDamageType -- moi don deu tinh la " ..
                  "don danh, mon Ao Choang se khong an gi")
      end
      keep = keep * (1.0 - API.gearMitigPct(tp,
                       spell and "mitig_magic" or "mitig_phys"))
    end

    -- Tran cung mot lan nua, de mot lan chinh so tay khong bien hero
    -- thanh bat tu ma khong ai nhan ra.
    local least = 1.0 - (CFG.GEAR_MITIG_CAP or 1.0)
    if keep < least then keep = least end

    if keep < 1.0 then BlzSetEventDamage(amount * keep) end
  end

  local sp = heroPid(src)

  -- "Kiem": %sat thuong GAY RA -- phan DON THUONG.
  --
  -- Sat thuong ky nang khong toi day (hit() bat 'busy', ham nay da return
  -- o dong dau); no duoc nhan trong skillDamage(). Hai duong, hai cho,
  -- khong chong nhau.
  --
  -- Ghi de len 'amount' luon, de "cleave" ben duoi van % sang muc tieu
  -- canh theo con so DA nhan -- chem lan cua mot cu danh manh thi phan
  -- van sang cung phai manh theo.
  --
  -- Dieu kien 'tp == nil' de hai nhanh khong dam nhau: neu ca nguon lan
  -- muc tieu deu la hero (ban minh -- map nay dong minh nen khong xay ra,
  -- nhung dung de no am tham sai) thi nhanh nay se ghi de len con so da
  -- giam o tren.
  if sp ~= nil and tp == nil and BlzSetEventDamage ~= nil
     and API.gearDmgPct ~= nil then
    local pct = API.gearDmgPct(sp)
    if pct > 0.0 then
      amount = amount * (1.0 + pct)
      BlzSetEventDamage(amount)
    end
  end

  -- NHAN: hut mau theo con so CUOI CUNG, tuc sau khi Kiem da cong %.
  -- Dat sau khoi tren chu khong truoc: hai mon nhan voi nhau, va thu tu
  -- nay la cho quyet dinh dieu do.
  if sp ~= nil and tp == nil and API.gearLifesteal ~= nil then
    API.gearLifesteal(sp, amount)
  end

  -- "cleave": hero GAY don. Van % sat thuong sang muc tieu ben canh.
  if sp ~= nil and tgt ~= nil then
    local sk, lv = skillByFx(sp, "cleave")
    if sk ~= nil then
      local splash = amount * API.skillPct(sk, lv)
      if splash >= 1.0 then
        enemiesNear(GetUnitX(tgt), GetUnitY(tgt), CFG.FX_CLEAVE_AOE,
          function(e)
            if e ~= tgt then hit(src, e, splash, CFG.FX_HIT_CLEAVE) end
          end)
      end
    end
  end
end

-- ============================================================
--  MOT cho duy nhat ghi chi so hero
--
--  LUAT. Moi nguon chi KHAI BAO no dong gop bao nhieu; ham recompute
--  cong het lai roi ghi MOT lan. Khong cho nao duoc doc-cong-ghi-lai.
--
--  Vi sao phai co luat nay -- day la loi that da xay ra:
--
--    Bat Hoai va Hieu Lenh truoc day deu ghi giap kieu doc-cong-ghi.
--    Nang Hieu Lenh trong luc Bat Hoai dang bat thi "giap nen" bi doc
--    nham la giap DA CONG buff, nen luc buff het tru ra khong khop.
--    Lan vet voi giap nen 5: sau mot chu ky hero con 9.05 thay vi 5.81,
--    va no cong don moi lan lap.
--
--  Bon nguon hien co, va se con them khi Hvwd/Hkal co ky nang:
--    chi so       nen + Linh Can, roi nhan % cua bi dong "stat"
--    sat thuong   nen x Trang Bi
--    giap         nen + aura "Hieu Lenh" + buff "Bat Hoai"
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Doc chi so NEN cua hero. Goi DUNG MOT LAN, ngay sau khi tao hero va
-- truoc khi bat cu he nao cong vao.
--
-- Doc lai lan hai la nhan chong: lan do se doc ra con so da cong roi.
local function baseCapture(pid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  local h = d.hero
  d.base = {
    str   = GetHeroStr(h, false),
    agi   = GetHeroAgi(h, false),
    int   = GetHeroInt(h, false),
    dmg   = (BlzGetUnitBaseDamage ~= nil) and BlzGetUnitBaseDamage(h, 0) or 0,
    armor  = (BlzGetUnitArmor ~= nil) and BlzGetUnitArmor(h) or 0.0,
  }
end

-- Giap cua Hieu Lenh va Bat Hoai khong con tinh o file nay.
--
-- Hai ham cu -- auraGiap() va buffGiap() -- da xoa. Chung ton tai de
-- cong giap vao BlzSetUnitArmor, ma dong do chinh la thu dong bang phan
-- chi so. Gio giap nam trong truong cua chinh hai ability do
-- (CFG.SKILL_CARRY_BASE) va Warcraft cong.
--
-- DOI HANH VI: aura cua Warcraft co BAN KINH, ban Lua cu thi khong --
-- no cong cho ca doi du dung dau tren map. Map nay ba nguoi gan nhu
-- luon dung chung mot cho nen khac biet nho, nhung day la thu can nhin
-- lai neu doi hinh tach xa nhau.

local function recompute(pid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  local h = d.hero
  if d.base == nil then baseCapture(pid) end
  local n = d.base

  -- ---------- Chi so ----------
  -- nen + Linh Can, roi nhan % cua bi dong "stat" (Luyen The).
  local cultAdd = API.cultStatBonus(pid)
  -- Luyen The cong PHANG, khong nhan phan tram -- xem CFG.SKILLS A004.
  local sk, lv = skillByFx(pid, "stat")
  local bonus = 0.0
  if sk ~= nil and API.skillStat ~= nil then
    bonus = API.skillStat(sk, lv, API.cultRank and API.cultRank(pid) or 1)
  end

  -- Chi so tu QUAY cong vao truoc khi nhan %: mot cong thuc duy nhat,
  -- khong phai nho thu tu.
  local q = d.rollStats or {}
  local qStr, qAgi, qInt = q.str or 0, q.agi or 0, q.int or 0

  -- Trang Bi: bon mon cong diem (Ao/Giay/Mu/Nhan). MOT loi goi tra ve ba
  -- so -- khong cho nao doc chi so hien tai roi cong vao.
  local gStr, gAgi, gInt = 0.0, 0.0, 0.0
  if API.gearStat ~= nil then gStr, gAgi, gInt = API.gearStat(pid) end

  if CFG.CULT_STAT_MODE == "primary" then
    -- Cong vao chi so cao nhat cua NEN, khong phai cua hien tai -- chi
    -- so hien tai doi theo chinh phep cong nay thi no se nhay qua nhay
    -- lai giua hai chi so.
    local s, a, i = n.str + qStr + gStr + bonus,
                    n.agi + qAgi + gAgi + bonus,
                    n.int + qInt + gInt + bonus
    if s >= a and s >= i then s = s + cultAdd
    elseif a >= i then a = a + cultAdd
    else i = i + cultAdd end
    SetHeroStr(h, math.floor(s + 0.5), true)
    SetHeroAgi(h, math.floor(a + 0.5), true)
    SetHeroInt(h, math.floor(i + 0.5), true)
  else
    SetHeroStr(h, math.floor(n.str + qStr + gStr + cultAdd + bonus + 0.5), true)
    SetHeroAgi(h, math.floor(n.agi + qAgi + gAgi + cultAdd + bonus + 0.5), true)
    SetHeroInt(h, math.floor(n.int + qInt + gInt + cultAdd + bonus + 0.5), true)
  end

  -- ---------- Mau / mana toi da: KHONG dong vao ----------
  --
  -- The 3 cua he quay tung dinh cong mau/mana toi da. Bo, vi ban 1.31.1
  -- KHONG phoi ra truong nao cong THEM mau toi da ("-nat ilf": co
  -- STRENGTH_BONUS_ISTR, DEFENSE_BONUS_IDEF, nhung khong co MAX LIFE).
  -- Chi con BlzSetUnitMaxHP, ma ham do GHI DE -- dung cai da dong bang
  -- giap suot may ngay.
  --
  -- The 3 gio ra VANG. Mau/mana van hoan toan cua engine, suy tu Str va
  -- Int nhu Warcraft van lam.

  -- ---------- Sat thuong va giap: DE WARCRAFT TU TINH ----------
  --
  -- Ham nay KHONG con ghi BlzSetUnitBaseDamage hay BlzSetUnitArmor.
  --
  -- Ban truoc ghi ca hai, va do la ly do chi so len ma don thuong voi
  -- giap dung yen: n.giap la BlzGetUnitArmor() chup luc TAO HERO (giap
  -- tong hoi Agi con bang 5), nen moi lan tinh lai deu dong bang phan
  -- Agi vao con so do. Agi 511 ma giap van bang 2.
  --
  -- Phan cong them cua Hieu Lenh va Bat Hoai gio nam trong CHINH TRUONG
  -- cua hai ability do (CFG.SKILL_CARRY_BASE), nen Warcraft cong -- khong
  -- con ai phai so huu cong thuc giap nua.
  --
  -- Sat thuong cua Trang Bi KHONG can vat mang, va do la ly do mon Kiem
  -- cong % chu khong cong diem: % thi nhan duoc ngay trong onDamaged va
  -- skillDamage, khong phai muon truong cua mot ability nao ca.
  -- (API.gearMult da bo -- khong file nao doc no.)
end

-- Aura cham toi NGUOI KHAC, nen doi bac cua mot nguoi la ca doi phai
-- tinh lai.
local function recomputeAll()
  for i = 1, #S.pids do recompute(S.pids[i]) end
end

-- ---------- Khoi dong ----------

local function startSkillFx()
  local tSpell = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(tSpell, EVENT_PLAYER_UNIT_SPELL_EFFECT)
  TriggerAddAction(tSpell, onSpell)

  if EVENT_PLAYER_UNIT_DAMAGED ~= nil then
    local tDmg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(tDmg, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(tDmg, onDamaged)
  else
    API.msg(nil, CFG.C_RED .. "Khong co EVENT_PLAYER_UNIT_DAMAGED -- " ..
      "Chem Lan va Da Sat se khong chay." .. CFG.C_END)
  end

  API.trace("effect: san sang (cast + damage)")
end

API.heroBaseCapture  = baseCapture
API.heroPidOf       = heroPid
API.heroRecompute    = recompute
API.heroRecomputeAll = recomputeAll
API.skillFxRecompute = recomputeAll   -- ten cu, giu cho cho goi san co
API.startSkillFx     = startSkillFx
