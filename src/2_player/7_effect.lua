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
--  MUOI MOT LOAI HIEU UNG, khai bao bang truong 'fx':
--    line chain nova           chu dong, sat thuong
--    heal hot wave buff        chu dong, hoi mau / tu buff
--    cleave burn reduce        bi dong, bat qua su kien sat thuong
--    stat                      bi dong, tinh lai khi bac ky nang doi
--
--  'heal' hoi MOT CUC ngay; 'hot' rai deu trong thoi luong cua chinh
--  ability. Hai cai khac nhau that, va A010 tung dung nham 'heal' --
--  nguoi lam map dat 6 giay trong World Editor ma trong game no hoi
--  tuc thi, nhin ra nhu loi.
--
--  ('aura' KHONG con la hieu ung o day -- con so cua no nam trong chinh
--  ability va Warcraft tu cong. No chi con la nhan de bang phim R loc.)
--
--  Moi hero moi thuong keo theo vai loai moi, roi tu do hero sau dung
--  lai duoc: Hvwd (2026-09-19) them 'chain' va 'burn', Hkal cung ngay
--  them 'nova' va 'wave'. Den hero thu tu thi kha nang chi con khai
--  bao them dong trong CFG.SKILLS.
--
--  VI SAO 'burn' TINH THEO % DON DANH, KHONG PHAI % MAU MUC TIEU
--
--  Ban thao dau la "+1% mau toi da cua muc tieu". Khong dung duoc: mau
--  moi thu trong map nay DINH NGHIA theo DPS nguoi choi (ADR 0020, va
--  armStats() dat mau Thanh Thu = dps x seconds). Nen "% mau dich" that
--  ra la "% TRAN DAU" -- 1% thanh dung 100 mui ten giet MOI thu, va bo
--  so 45/85/150/240 giay cua bon Thanh Thu mat sach y nghia.
--
--  Do lai con nguoc: cung 100 mui do voi Chu Tuoc (thiet ke 45 giay) la
--  CHAM hon danh thuong, con voi Thanh Long (240 giay) la nhanh gap 3,6
--  lan. Con de nhat khong doi gi, con kho nhat boc hoi.
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
local hotWarned     = false

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

-- Hoi mau, chan o tran. MOT cho duy nhat lam viec nay -- ba duong
-- (heal, hot, wave) deu goi vao day chu khong ai tu viet lai phep kep.
local function healUnit(t, amount)
  if t == nil or amount <= 0.0 or not API.alive(t) then return end
  local hp = GetUnitState(t, UNIT_STATE_LIFE) + amount
  local mx = GetUnitState(t, UNIT_STATE_MAX_LIFE)
  SetUnitState(t, UNIT_STATE_LIFE, (hp > mx) and mx or hp)
end

-- "heal": hoi mau mot muc tieu. Khong co muc tieu thi hoi chinh minh.
local function fxHeal(pid, u, sk, lv)
  local t = (GetSpellTargetUnit ~= nil) and GetSpellTargetUnit() or nil
  if t == nil then t = u end
  healUnit(t, API.skillDamage(u, API.skillFactor(sk, lv)))
  API.fx(CFG.FX_HIT_HEAL, GetUnitX(t), GetUnitY(t))
end

-- "nova": no mot vong quanh MUC TIEU, khong phai quanh minh (A013).
--
-- Frost Nova goc nham vao mot unit roi van ra; giu dung kieu do. Khong
-- co muc tieu thi lay diem nham -- ban sao co the duoc dat lai thanh
-- nham diem trong Object Editor, va luc do ham nay van chay.
local function fxNova(pid, u, sk, lv)
  local tx, ty
  local t = (GetSpellTargetUnit ~= nil) and GetSpellTargetUnit() or nil
  if t ~= nil then
    tx, ty = GetUnitX(t), GetUnitY(t)
  elseif GetSpellTargetX ~= nil then
    tx, ty = GetSpellTargetX(), GetSpellTargetY()
  end
  if tx == nil then return end

  local dmg = API.skillDamage(u, API.skillFactor(sk, lv))
  enemiesNear(tx, ty, CFG.FX_NOVA_AOE or 300.0, function(e)
    hit(u, e, dmg, CFG.FX_HIT_NOVA)
  end)
end

-- Duyet HERO CUA NGUOI CHOI trong ban kinh. Doi cua enemiesNear.
--
-- Khong dung GroupEnumUnitsInRange roi loc theo phe: pet va thap canh
-- cung thuoc ve nguoi choi, ma hoi mau cho mot cai thap thi vo nghia.
-- Duyet thang S.pids la chac chan lay dung hero.
local function heroesNear(x, y, radius, f)
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h)
       and API.distXY(x, y, GetUnitX(h), GetUnitY(h)) <= radius then
      f(h)
    end
  end
end

-- "wave": hoi mau nay qua dong doi, moi lan nhay yeu di (A014).
--
-- CHON NGUOI THIEU MAU NHAT, khong phai nguoi gan nhat. Day la khac
-- biet that: hoi mau nay sang mot nguoi day mau la vut di mot nhip,
-- ma so nhip thi co han. Sat thuong thi nguoc lai -- "gan nhat" moi
-- dung, vi muc tieu nao cung an du.
local function fxWave(pid, u, sk, lv)
  local t = (GetSpellTargetUnit ~= nil) and GetSpellTargetUnit() or nil
  if t == nil then t = u end

  local amount = API.skillDamage(u, API.skillFactor(sk, lv))
  local hops  = CFG.FX_WAVE_MAX or 3
  local fall  = CFG.FX_WAVE_FALLOFF or 0.75
  local reach = CFG.FX_WAVE_HOP or 500.0

  local seen, cur = {}, t
  for _ = 1, hops do
    if cur == nil or amount < 1.0 then break end
    seen[GetHandleId(cur)] = true
    local cx, cy = GetUnitX(cur), GetUnitY(cur)
    healUnit(cur, amount)
    API.fx(CFG.FX_HIT_HEAL, cx, cy)
    amount = amount * fall

    local best, worst = nil, nil
    heroesNear(cx, cy, reach, function(h)
      if seen[GetHandleId(h)] then return end
      local frac = GetUnitState(h, UNIT_STATE_LIFE)
                 / GetUnitState(h, UNIT_STATE_MAX_LIFE)
      if worst == nil or frac < worst then best, worst = h, frac end
    end)
    cur = best
  end
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

-- "chain": nay tu muc tieu sang con gan nhat chua bi danh (A008, Hvwd).
--
-- Warcraft CO san co che nay, nhung sat thuong cua no la so PHANG trong
-- Object Editor -- tuc teo thanh khong o canh gioi cao (ADR 0024). Nen
-- ta muon cai VO (icon, tia set, hoi chieu, mana, tam) va tu tinh sat
-- thuong bang skillDamage() nhu moi ky nang khac.
--
-- Tia set GOC van ve ra, va no chon muc tieu theo bang so cua WE chu
-- khong theo vong lap nay. Hai ben co the lech mot con -- FX_HIT_CHAIN
-- danh dau nhung con LUA that su danh, de nhin ra do lech neu co.
local function fxChain(pid, u, sk, lv)
  local t = (GetSpellTargetUnit ~= nil) and GetSpellTargetUnit() or nil
  if t == nil then return end

  local dmg  = API.skillDamage(u, API.skillFactor(sk, lv))
  local hops = CFG.FX_CHAIN_MAX or 4
  local fall = CFG.FX_CHAIN_FALLOFF or 0.80
  local reach = CFG.FX_CHAIN_HOP or 400.0

  -- 'seen' chan tia set quay lai con vua danh. Khong co no thi hai con
  -- dung canh nhau se chuyen qua chuyen lai va an tron ca bon lan nhay.
  local seen, cur = {}, t
  for _ = 1, hops do
    if cur == nil or dmg < 1.0 then break end
    seen[GetHandleId(cur)] = true
    -- Nho toa do TRUOC khi danh: hit() co the giet no, va enemiesNear
    -- loc theo API.alive nen tu bo qua xac.
    local cx, cy = GetUnitX(cur), GetUnitY(cur)
    hit(u, cur, dmg, CFG.FX_HIT_CHAIN)
    dmg = dmg * fall

    local best, bestD = nil, nil
    enemiesNear(cx, cy, reach, function(e)
      if seen[GetHandleId(e)] then return end
      local dd = API.distXY(cx, cy, GetUnitX(e), GetUnitY(e))
      if bestD == nil or dd < bestD then best, bestD = e, dd end
    end)
    cur = best
  end
end

-- ---------- "burn": lop thieu dot (A011, Hvwd) ----------
--
-- MOT bang va MOT dong ho cho ca map, khong phai mot dong ho moi lan
-- danh. Xa thu cuoi van danh rat nhanh, ma moi TimerStart la mot handle:
-- vai nghin cai trong mot wave thi Warcraft can handle va nhung he KHAC
-- bat dau hong -- kieu loi khong bao gio truy nguoc duoc ve day.
--
-- Nho 'pid' chu khong nho unit hero: doi hero thi handle cu treo lai, va
-- UnitDamageTarget voi mot nguon da bi xoa la vung khong xac dinh. Tra
-- lai S.p[pid].hero moi nhip thi luon la con dang song.
local function burnApply(pid, tgt, total)
  if total < 1.0 or tgt == nil or not API.alive(tgt) then return end
  if S.burn == nil then S.burn = {} end

  local time  = CFG.FX_BURN_TIME or 3.0
  local step  = CFG.FX_BURN_TICK or 0.5
  local ticks = math.floor(time / step + 0.5)
  if ticks < 1 then ticks = 1 end

  local k = GetHandleId(tgt)
  local b = S.burn[k]
  if b ~= nil and CFG.FX_BURN_STACK then
    b.per  = b.per + total / ticks
    b.left = time
    b.pid  = pid
  else
    -- LAM MOI chu khong cong don (CFG.FX_BURN_STACK = false). Cong don
    -- thi toc danh tu nhan voi chinh no.
    S.burn[k] = { u = tgt, pid = pid, per = total / ticks, left = time }
    API.fx(CFG.FX_HIT_BURN, GetUnitX(tgt), GetUnitY(tgt))
  end
end

-- ---------- "hot": hoi mau keo dai (A010, Hvwd) ----------
--
-- BANG RIENG voi burn chu khong chung mot bang. Khoa la GetHandleId
-- cua muc tieu; burn bam vao QUAI con hot bam vao HERO nen chung
-- "khong bao gio" dam nhau -- nhung do la mot gia dinh ve luat choi,
-- khong phai ve ma nguon. Hai bang thi khong ai phai nho gia dinh do.
--
-- Dung chung MOT dong ho voi burn, vi cung mot nhip.
local function hotApply(pid, tgt, total, secs)
  if total < 1.0 or tgt == nil or not API.alive(tgt) then return end
  if S.hot == nil then S.hot = {} end

  local step  = CFG.FX_BURN_TICK or 0.5
  local ticks = math.floor(secs / step + 0.5)
  if ticks < 1 then ticks = 1 end

  S.hot[GetHandleId(tgt)] = { u = tgt, per = total / ticks, left = secs }
  API.fx(CFG.FX_HIT_HEAL, GetUnitX(tgt), GetUnitY(tgt))
end

-- Doc mot truong REAL cua ability bang MA TRUONG 4 ky tu.
--
-- Ma truong chu khong ten hang so, va day la do chu khong phai so
-- thich: ban 1.31.1 THIEU rat nhieu ABILITY_RLF_* -- file vet ghi ro
-- OCL1, OCL2, CR21 deu khong co. ConvertAbilityRealLevelField nhan
-- FourCC nen di duong vong duoc; day cung la duong A003 da phai di.
local function abilReal(pid, abilId, code, level)
  local h = (S.p[pid] or {}).hero
  if h == nil or BlzGetUnitAbility == nil
     or BlzGetAbilityRealLevelField == nil then return nil end
  local conv = _G["ConvertAbilityRealLevelField"]
  if conv == nil then return nil end
  local ab = BlzGetUnitAbility(h, abilId)
  if ab == nil then return nil end
  return BlzGetAbilityRealLevelField(ab, conv(FourCC(code)), (level or 1) - 1)
end

-- "hot": hoi mau RAI DEU, khong phai mot cuc.
--
-- Thoi luong lay tu CHINH ability ('adur' -- doc duoc trong w3obj.py
-- dump, 6.0 cho A010). World Editor giu con so do; khai them mot
-- CFG.FX_HOT_TIME co dinh la hai noi cung khai mot thu, va mot ngay se
-- chi sua mot noi. CFG chi la duong lui khi doc khong ra.
local function fxHot(pid, u, sk, lv)
  local t = (GetSpellTargetUnit ~= nil) and GetSpellTargetUnit() or nil
  if t == nil then t = u end

  local secs = abilReal(pid, sk.id, sk.durField or "adur", lv)
  if secs == nil or secs <= 0.0 then
    secs = CFG.FX_HOT_TIME or 6.0
    if not hotWarned then
      hotWarned = true
      API.trace("effect: khong doc duoc thoi luong '" ..
                tostring(sk.durField or "adur") .. "' cua " ..
                API.idToStr(sk.id) .. " -- lui ve " .. secs .. "s")
    end
  end
  hotApply(pid, t, API.skillDamage(u, API.skillFactor(sk, lv)), secs)
end

-- Mot nhip cho CA HAI bang. Gan nil cho chinh khoa dang duyet la hop
-- le trong Lua; them khoa moi thi khong, va vong nay khong them.
local function overTick()
  local step = CFG.FX_BURN_TICK or 0.5

  if S.burn ~= nil then
    for k, b in pairs(S.burn) do
      local d   = S.p[b.pid]
      local src = d and d.hero or nil
      if b.u == nil or not API.alive(b.u) or b.left <= 0.0
         or src == nil or not API.alive(src) then
        S.burn[k] = nil
      else
        hit(src, b.u, b.per, nil)
        b.left = b.left - step
        if b.left <= 0.0 then S.burn[k] = nil end
      end
    end
  end

  if S.hot ~= nil then
    for k, b in pairs(S.hot) do
      if b.u == nil or not API.alive(b.u) or b.left <= 0.0 then
        S.hot[k] = nil
      else
        -- Khong di qua hit(): day la HOI MAU, va no phai dung o mau
        -- toi da chu khong tran qua.
        local hp = GetUnitState(b.u, UNIT_STATE_LIFE) + b.per
        local mx = GetUnitState(b.u, UNIT_STATE_MAX_LIFE)
        SetUnitState(b.u, UNIT_STATE_LIFE, (hp > mx) and mx or hp)
        b.left = b.left - step
        if b.left <= 0.0 then S.hot[k] = nil end
      end
    end
  end
end

-- ---------- Autocast cua Searing Arrows ----------
--
-- A011 la ban sao cua AHfa -- mot ability AUTOCAST, tuc co nut bat/tat
-- that tren command card (phim E). Neu Lua cu dot bat ke nut do thi tat
-- di la vua khoi ton mana vua giu nguyen sat thuong: nut thanh cai bay.
--
-- Warcraft 1.31.1 khong phoi ra native nao hoi "autocast dang bat
-- khong". Nhung LENH thi bat duoc, va OrderId() tra ve 0 cho ten sai --
-- nen day la do duoc, khong phai doan.
local BURN_ON, BURN_OFF = nil, nil

local function probeBurnOrder()
  -- Da DO roi thi dung so do, khong tim nua. CFG.BURN_ORDER = { bat,
  -- tat } -- lay tu dong "order: pid N phat lenh X" trong file vet.
  local fixed = CFG.BURN_ORDER
  if fixed ~= nil and fixed[1] ~= nil and fixed[2] ~= nil then
    BURN_ON, BURN_OFF = fixed[1], fixed[2]
    API.trace("effect: burn autocast = CFG.BURN_ORDER " ..
              BURN_ON .. "/" .. BURN_OFF)
    return
  end

  if OrderId == nil then
    API.trace("effect: khong co OrderId -- burn coi nhu LUON BAT")
    return
  end
  -- OrderId KHAC 0 CHI CHUNG MINH "ten nay la mot lenh co that",
  -- KHONG chung minh "no la lenh cua ability nay".
  --
  -- LOI DA SHIP: danh sach dau co "blackarrow" o cuoi, va no trung --
  -- file vet ghi 'blackarrow' 852577/852579. Nhung blackarrow la lenh
  -- cua Black Arrow, mot ability khac han; nut E cua Thieu Thien khong
  -- bao gio phat lenh do, nen bo theo doi im lang khong chay.
  --
  -- Cung lop loi voi AddWeatherEffect nhan ma rac: ham tra ve mot gia
  -- tri "hop le" cho mot dau vao sai.
  --
  -- Gio chi giu hai ten CO LIEN QUAN toi AHfa. Trung thi dung; truot
  -- thi onOrder() ghi vet moi lenh la de nguoi choi bam E mot cai va
  -- doc ra so that -- do, khong doan.
  local cands = { "searingarrows", "flamingarrows" }
  for i = 1, #cands do
    local on  = OrderId(cands[i])
    local off = OrderId(cands[i] .. "off")
    if on ~= nil and on ~= 0 and off ~= nil and off ~= 0 then
      BURN_ON, BURN_OFF = on, off
      API.trace("effect: burn autocast = '" .. cands[i] .. "' " ..
                on .. "/" .. off)
      return
    end
  end
  -- Khong do duoc thi LUON BAT, khong phai luon tat: mot ky nang im
  -- lang khong lam gi la kieu hong te nhat (ADR 0012).
  API.trace("effect: KHONG do duoc lenh autocast cua Searing Arrows -- " ..
            "burn coi nhu LUON BAT")
end

-- Mac dinh BAT khi chua ai bam.
--
-- Nguoc voi mac dinh cua Object Editor (Searing Arrows goc tat san),
-- va do la co y: nguoi choi khong bam gi ma thay ky nang chay la hieu
-- duoc, con bo Go ra mo khoa roi khong thay gi thi tuong la hong.
local function burnOn(pid)
  if BURN_ON == nil then return true end
  local d = S.p[pid]
  return d == nil or d.burnOn ~= false
end

local function onOrder()
  local o = GetIssuedOrderId and GetIssuedOrderId() or nil
  if o == nil then return end
  local pid = heroPid(GetTriggerUnit())
  if pid == nil or S.p[pid] == nil then return end

  if BURN_ON ~= nil and (o == BURN_ON or o == BURN_OFF) then
    S.p[pid].burnOn = (o == BURN_ON)
    return
  end

  -- GHI VET LENH LA, mot lan moi ma.
  --
  -- Day la cach DO ra so that thay vi doan tiep mot cai ten: nguoi
  -- choi bam E mot cai, file vet in ra hai so, va ta ghi thang chung
  -- vao CFG.BURN_ORDER. Loc bo lenh di chuyen/danh thuong -- chung
  -- phat lien tuc va se lam ngap file vet.
  if not CFG.DEV_COMMANDS then return end
  if S.orderSeen == nil then S.orderSeen = {} end
  if S.orderSeen[o] then return end
  S.orderSeen[o] = true
  -- 851971..851999 la vung lenh co ban (move/stop/attack/hold/patrol).
  if o >= 851970 and o <= 851999 then return end
  API.trace("order: pid " .. pid .. " phat lenh " .. o)
end

local FX_CAST = { line = fxLine, chain = fxChain, nova = fxNova,
                  heal = fxHeal, hot = fxHot, wave = fxWave }

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

    -- Phap Khi "Huyen Quy Giap": -20% sat thuong nhan, CA HAI loai.
    --
    -- Nhan vao 'keep' chu khong tru thang: no phai chong len Khien/Ao
    -- Choang theo kieu NHAN, neu khong hai nguon giam cong lai se vuot
    -- tran va bien hero thanh bat tu.
    if API.relicVal ~= nil then
      local rv = API.relicVal(tp, "huyenquy", "mitig")
      if rv > 0.0 then keep = keep * (1.0 - rv) end
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
    -- Phap Khi "Hoa Vu Linh Chau": +25% sat thuong gay ra.
    --
    -- CONG vao cung mot 'pct' roi nhan MOT lan, khong nhan hai lan noi
    -- tiep: hai lan nhan thi Kiem va Phap Khi tu khuech dai nhau, va
    -- duong cong x967 khong con dung o cuoi van.
    if API.relicVal ~= nil then
      pct = pct + API.relicVal(sp, "hoavu", "dmgUp")
    end
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

  -- "bounce": don danh NAY sang muc tieu ben canh, moi lan yeu di.
  --
  -- VI SAO LAM BANG LUA CHU KHONG DE ENGINE LO. Ban dau A012 la ban
  -- sao Moon Glaive va KHONG co dong Lua nao -- de Warcraft tu nay.
  -- No khong nay. Do lai thi ro:
  --
  --   war3map.w3a  A012 khong co MOT truong du lieu nao -- so muc tieu
  --                va do hao deu thua ke tu Amgl goc, ma goc chi co 3
  --                bac trong khi ta vua dat alev = 10
  --   war3map.w3u  H002 khong khai 'ua1w' -- kieu vu khi thua ke tu
  --                unit goc, va Moon Glaive chi nay duoc khi vu khi la
  --                Missile (Bounce)
  --
  -- Sua o Object Editor thi phai dung ca hai cho, va cho thu hai la
  -- mot gia thuyet chua chung minh. Lam o day thi:
  --   chay voi MOI hero, khong phu thuoc unit goc
  --   la PHAN TRAM cua don danh that -> tu scale, khong teo
  --   dung lai dung bo may ma cleave da chay hang tram wave
  --
  -- Doi lai: mat hoat anh glaive bay vong cua Warcraft. Neu mai nay
  -- dat 'ua1w = mbounce' trong World Editor de lay lai hoat anh do thi
  -- PHAI bo 'fx = "bounce"' khoi CFG.SKILLS -- de ca hai la sat thuong
  -- nhan doi.
  if sp ~= nil and tgt ~= nil and tp == nil then
    local sk, lv = skillByFx(sp, "bounce")

    -- GHI VET MOT LAN cho moi nguoi, ngay don danh dau tien.
    --
    -- "Khong thay no nay" co HAI nguyen nhan rat khac nhau va nhin
    -- giong het nhau tu ngoai: ky nang CHUA MO KHOA (bac 0), hay da mo
    -- ma vong lap khong tim ra muc tieu nao trong tam. Mot dong vet
    -- tach duoc hai cai do; doan thi khong.
    local d = S.p[sp]
    if d ~= nil and not d.bounceLogged then
      d.bounceLogged = true
      if sk == nil then
        API.trace("bounce: pid " .. sp ..
                  " KHONG co ky nang 'bounce' dang mo -- chua mua Nguyet Nhan?")
      else
        API.trace("bounce: pid " .. sp .. " co Nguyet Nhan bac " .. lv ..
                  ", " .. string.format("%.0f%%", API.skillPct(sk, lv) * 100) ..
                  " moi cu nay, tam " .. (CFG.FX_BOUNCE_HOP or 350.0))
      end
    end

    if sk ~= nil then
      local share = amount * API.skillPct(sk, lv)
      local hops  = CFG.FX_BOUNCE_MAX or 3
      local fall  = CFG.FX_BOUNCE_FALLOFF or 0.70
      local reach = CFG.FX_BOUNCE_HOP or 350.0

      -- 'seen' phai chua CA muc tieu dau: khong thi cu nay dau tien
      -- quay nguoc lai chinh con vua an don thuong.
      local seen, cx, cy = { [GetHandleId(tgt)] = true }, GetUnitX(tgt), GetUnitY(tgt)
      local landed = 0
      for _ = 1, hops do
        if share < 1.0 then break end
        local best, bestD = nil, nil
        enemiesNear(cx, cy, reach, function(e)
          if seen[GetHandleId(e)] then return end
          local dd = API.distXY(cx, cy, GetUnitX(e), GetUnitY(e))
          if bestD == nil or dd < bestD then best, bestD = e, dd end
        end)
        if best == nil then break end
        seen[GetHandleId(best)] = true
        cx, cy = GetUnitX(best), GetUnitY(best)
        hit(src, best, share, CFG.FX_HIT_BOUNCE)
        share = share * fall
        landed = landed + 1
      end

      -- Lan dau NAY TRUNG duoc it nhat mot con thi ghi mot dong. Khong
      -- co dong nay thi "da mo khoa ma van khong thay" khong phan biet
      -- duoc voi "danh mot con dung mot minh" -- ma truong hop sau la
      -- binh thuong, khong phai loi.
      if landed > 0 and d ~= nil and not d.bounceHit then
        d.bounceHit = true
        API.trace("bounce: pid " .. sp .. " nay trung " .. landed .. " con")
      end
    end
  end

  -- "burn": hero GAY don. De lai mot lop dot tren chinh muc tieu do.
  --
  -- Tinh theo % DON DANH THAT ('amount' da qua Kiem va Phap Khi o tren),
  -- y het cleave. Do la ly do no khong bao gio teo: no khong co con so
  -- rieng nao de bi bo lai.
  --
  -- 'tp == nil' de khong dot dong doi neu mai nay map co sat thuong
  -- cheo phe. overTick() goi hit(), ma hit() bat 'busy' nen lop dot
  -- khong tu de ra lop dot moi.
  if sp ~= nil and tgt ~= nil and tp == nil and burnOn(sp) then
    local sk, lv = skillByFx(sp, "burn")
    if sk ~= nil then
      burnApply(sp, tgt, amount * API.skillPct(sk, lv))
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
    API.warn(nil, "Khong co EVENT_PLAYER_UNIT_DAMAGED -- " ..
      "Chem Lan, Thieu Thien va Da Sat se khong chay.")
  end

  -- Nut bat/tat cua Thieu Thien (A011). Do ten lenh TRUOC khi dang ky:
  -- khong do duoc thi khong can trigger nao, burn se luon bat.
  probeBurnOrder()
  -- Dang ky KE CA khi do khong ra: luc do onOrder() lam viec khac --
  -- ghi vet moi lenh la, de nguoi choi bam E mot cai la doc duoc so
  -- that. Do, khong doan tiep mot cai ten.
  if EVENT_PLAYER_UNIT_ISSUED_ORDER ~= nil then
    local tOrd = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(tOrd, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerAddAction(tOrd, onOrder)
  end

  -- MOT dong ho cho moi lop dot cua ca map -- xem burnApply().
  S.burn, S.hot = {}, {}
  S.burnTimer = CreateTimer()
  TimerStart(S.burnTimer, CFG.FX_BURN_TICK or 0.5, true, overTick)

  API.trace("effect: san sang (cast + damage + burn)")
end

API.heroBaseCapture  = baseCapture
API.heroPidOf       = heroPid
API.heroRecompute    = recompute
API.heroRecomputeAll = recomputeAll
API.skillFxRecompute = recomputeAll   -- ten cu, giu cho cho goi san co
API.startSkillFx     = startSkillFx
