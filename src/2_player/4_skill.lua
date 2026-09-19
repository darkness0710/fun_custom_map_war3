-- ============================================================
--  4_skill.lua  --  Bay ky nang: bac, gia nang, suc manh moi bac
--
--  MOI so lieu ky nang o day, khong o Object Editor. war3map.w3a chi
--  giu VO: ten, icon, o nut, so bac. Nho vay chinh can bang khong phai
--  build lai file nhi phan nao -- va so lieu voi tooltip ra tu cung mot
--  bang nen khong the lech nhau.
--
--  HAI QUY TAC, ca hai deu tu do ma ra:
--
--  1. Sat thuong an theo CHI SO CAO NHAT cua hero, khong phai so co dinh.
--     Linh Can cong +1075 moi chi so o bac 20; skill gay so co dinh thi
--     cuoi game thanh vo nghia.
--
--  2. Ky nang bi dong tinh theo PHAN TRAM. Cung ly do: cong thang +20
--     chi so nghe to luc dau (+100%) nhung chi con +5% o Linh Can bac 20.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function listOf(pid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return {} end
  return CFG.SKILLS[GetUnitTypeId(d.hero)] or {}
end

-- ---------- So bac THAT cua ability ----------
--
-- Object Editor moi la nguoi quyet dinh mot ability co bao nhieu bac.
-- Ability hero mac dinh 3 bac, ability unit thuong 1 bac. Goi
-- SetUnitAbilityLevel(u, aid, 10) len mot ability 3 bac thi no KEP
-- xuong 3 va KHONG bao loi gi.
--
-- Da can mot lan: nang skill len bac 10, tra du tien, bang bao 10/10,
-- ma trong game chi len bac 3. Nen gio do that roi moi cho nang.
local function probeMax(u, aid)
  local cur = GetUnitAbilityLevel(u, aid)
  if cur == 0 then return 0 end
  SetUnitAbilityLevel(u, aid, CFG.SKILL_MAX_LEVEL)
  local hi = GetUnitAbilityLevel(u, aid)
  SetUnitAbilityLevel(u, aid, cur)
  return hi
end

-- Tran that: nho hon giua "thiet ke muon" va "Object Editor cho".
local function maxOf(aid)
  local m = S.skillMax[aid]
  if m == nil or m <= 0 then return CFG.SKILL_MAX_LEVEL end
  if m < CFG.SKILL_MAX_LEVEL then return m end
  return CFG.SKILL_MAX_LEVEL
end

-- Bac 0 = CHUA MO KHOA. Bac 1..10 = da co.
local function levelOf(pid, aid, index)
  local d = S.p[pid]
  if d ~= nil and d.skill ~= nil and d.skill[aid] ~= nil then
    return d.skill[aid]
  end
  -- Chua mua gi: nhung cai dau tien co san, con lai khoa.
  if index ~= nil and index <= CFG.SKILL_START_COUNT then return 1 end
  return 0
end

-- Gia mo khoa theo SO CAI DA MO, khong theo cai nao. Thich mo cai nao
-- truoc thi mo -- ep thu tu la lay mat mot lua chon ma chang duoc gi.
-- Gia tinh bang NGO TINH, va la MOT diem cho moi lan.
--
-- Ky nang bi chan boi "da giet du tinh anh chua", khong phai "da gom du
-- tien chua" -- ma tien thi Linh Can va Trang Bi da tranh nhau roi.
-- Xem docs/02-he-thong/kinh-te.md
--
-- Gia phang nen khong con ham unlockCost: mo khoa cai thu nhat hay cai
-- thu bay deu 1 diem. Nguoi choi khong phai tinh toan gi, chi phai chon
-- THU TU -- mo cai nao truoc, don bac cai nao.
local function costOf(pid, level, aid)
  if level <= 0 then return CFG.SKILL_LUMBER_UNLOCK end
  if level >= (aid and maxOf(aid) or CFG.SKILL_MAX_LEVEL) then return nil end
  return CFG.SKILL_LUMBER_UP
end

-- ---------- Suc manh theo bac ----------
-- Ngan sach ca he nang cap la x2, va x2 do la TICH cua moi nut chinh.
-- Chu dong: he so x1.33 va hoi chieu x0.667 (tan suat x1.5) = x2.
-- Bi dong khong co hoi chieu nen an tron x2.

local function factorAt(sk, level)
  return (sk.factor or 0) * CFG.SKILL_DMG_STEP ^ (level - 1)
end

local function cdAt(sk, level)
  return (sk.cd or 0) * CFG.SKILL_CD_STEP ^ (level - 1)
end

local function pctAt(sk, level)
  return (sk.pct or 0) * CFG.SKILL_PASSIVE_STEP ^ (level - 1)
end

-- Giap PHANG cua aura. Dung buoc bi dong nhu pct: 3.0 -> 6.0 sau 9 lan.
--
-- Rieng mot ham chu khong dung pctAt vi day la GIAP, khong phai phan
-- tram. Warcraft dung giap phang; "+15% giap" tren hero co 3 giap la
-- +0.45 -- gan nhu bang khong.
local function armorAt(sk, level)
  return (sk.armor or 0) * CFG.SKILL_PASSIVE_STEP ^ (level - 1)
end

-- Chi so PHANG cua bi dong "stat" (Luyen The). Bam theo CA hai truc:
-- bac ky nang va bac Tu Vi. Xem chu thich o CFG.SKILLS A004.
local function statAt(sk, level, rank)
  if sk == nil or sk.statVal == nil then return 0.0 end
  return sk.statVal * CFG.SKILL_PASSIVE_STEP ^ (level - 1)
                  * CFG.CULT_STAT_STEP ^ ((rank or 1) - 1)
end

local function manaAt(sk, level)
  if sk.mana == nil or sk.mana <= 0 then return 0 end
  return math.floor(sk.mana * CFG.SKILL_MANA_STEP ^ (level - 1) + 0.5)
end

-- Chi so cao nhat cua hero. Dung CHUNG cho moi skill, nen doi hero hay
-- doi trang bi deu khong lam skill nao bi bo lai.
local function topStat(u)
  if u == nil then return 0 end
  local s, a, i = GetHeroStr(u, true), GetHeroAgi(u, true), GetHeroInt(u, true)
  if s >= a and s >= i then return s, "str" end
  if a >= i then return a, "agi" end
  return i, "int"
end

-- Sat thuong/hoi mau cua mot skill. Day la ham ma cac skill se goi khi
-- co hieu ung that.
-- Sat thuong PHEP, va luong HOI MAU cua ky nang.
--
-- %Kiem nhan O DAY chu khong o cho khac: ca fxLine lan fxHeal deu di qua
-- ham nay, nen mot cho la du cho "phep + hoi mau". Don THUONG thi khong
-- di qua day -- no duoc nhan trong onDamaged.
--
-- Hai cho KHONG chong nhau: sat thuong ky nang ban ra bang hit(), ma
-- hit() bat co 'busy' nen onDamaged return ngay dong dau.
local function skillDamage(u, factor)
  local base = factor * (CFG.CULT_DMG_BASE + topStat(u))
  local pid  = (API.heroPidOf ~= nil) and API.heroPidOf(u) or nil
  if pid ~= nil and API.gearDmgPct ~= nil then
    base = base * (1.0 + API.gearDmgPct(pid))
  end
  return base
end

-- ---------- Nang bac ----------
-- Chay tren MOI may, tu kenh dong bo.

local function applyLevel(pid, sk, level)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  if GetUnitAbilityLevel(d.hero, sk.id) <= 0 then return end

  SetUnitAbilityLevel(d.hero, sk.id, level)

  -- Mana va hoi chieu dat TU LUA, de o Object Editor thi chinh can bang
  -- phai mo World Editor. Ca hai native nay deu co tren 1.31.1 (-nat).
  -- Dat cho MOI bac, khong chi bac hien tai: unit nho bac nao thi doc
  -- bac do, va ta khong biet no se nhay len bac nao truoc khi ta kip
  -- goi lai.
  local ceil = maxOf(sk.id)

  -- TAT hieu ung GOC. Xem CFG.SKILL_ZERO_BASE.
  --
  -- Dat cho MOI bac, cung ly do voi mana/hoi chieu ben duoi. Hang so nao
  -- khong co trong ban nay thi GHI VET chu khong lang le bo qua -- mot
  -- cai ten go sai tra ve nil va khong lam gi ca (ADR 0012).
  local ab = (BlzGetUnitAbility ~= nil) and BlzGetUnitAbility(d.hero, sk.id) or nil

  local function zeroField(fields, setter)
    local zero = fields and fields[sk.id] or nil
    if zero == nil or ab == nil or setter == nil then return end
    for k = 1, #zero do
      local F = _G[zero[k]]
      if F == nil then
        API.trace("skill: KHONG co hang so " .. zero[k] ..
                  " -- hieu ung goc VAN CHAY")
      else
        for lv = 1, ceil do setter(ab, F, lv - 1, 0) end
      end
    end
  end

  zeroField(CFG.SKILL_ZERO_BASE,     BlzSetAbilityRealLevelField)
  zeroField(CFG.SKILL_ZERO_BASE_INT, BlzSetAbilityIntegerLevelField)

  -- GHI so can bang vao truong goc, de Warcraft tu cong. Xem
  -- CFG.SKILL_CARRY_BASE -- day la duong thay cho BlzSetUnitArmor, thu da
  -- dong bang phan chi so vao giap.
  local carry = CFG.SKILL_CARRY_BASE and CFG.SKILL_CARRY_BASE[sk.id] or nil
  if carry ~= nil and ab ~= nil and BlzSetAbilityRealLevelField ~= nil then
    local F = _G[carry.field]
    if F == nil then
      API.trace("skill: KHONG co hang so " .. carry.field ..
                " -- " .. API.idToStr(sk.id) .. " khong cong duoc giap")
    else
      for lv = 1, ceil do
        local v = 0.0
        if carry.source == "armor" then
          v = armorAt(sk, lv)
        elseif carry.source == "buffarmor" then
          v = CFG.FX_BUFF_ARMOR * (1 + 0.1 * (lv - 1))
        end
        BlzSetAbilityRealLevelField(ab, F, lv - 1, v)
      end
    end
  end

  for lv = 1, ceil do
    if BlzSetUnitAbilityManaCost ~= nil and sk.mana ~= nil then
      BlzSetUnitAbilityManaCost(d.hero, sk.id, lv - 1, manaAt(sk, lv))
    end
    if BlzSetUnitAbilityCooldown ~= nil and sk.cd ~= nil and sk.cd > 0 then
      BlzSetUnitAbilityCooldown(d.hero, sk.id, lv - 1, cdAt(sk, lv))
    end
  end
end

local function upgrade(pid, index)
  local list = listOf(pid)
  local sk = list[index]
  if sk == nil then return end

  local d = S.p[pid]
  if d.skill == nil then d.skill = {} end

  local cur = levelOf(pid, sk.id, index)
  local ceil = maxOf(sk.id)
  local price = costOf(pid, cur, sk.id)
  if price == nil then
    if ceil < CFG.SKILL_MAX_LEVEL then
      -- Khong tru tien. Bao dung cho phai sua, dung de nguoi choi doan.
      API.msg(pid, CFG.C_RED ..
        API.t("skill_oemissing", API.pick(sk), ceil) .. CFG.C_END ..
        API.t("skill_oefix", CFG.SKILL_MAX_LEVEL, CFG.SKILL_MAX_LEVEL,
              API.idToStr(sk.id)))
    else
      API.msg(pid, CFG.C_GREY .. API.t("skill_atmax", API.pick(sk)) .. CFG.C_END)
    end
    return
  end
  if not API.spendLumber(pid, price) then
    API.msg(pid, CFG.C_RED .. API.t("no_lumber") .. CFG.C_END ..
      API.t("need_have", API.num(price), API.num(API.getLumber(pid))) ..
      CFG.C_GREY .. " " .. API.t("lumber_note") .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  d.skill[sk.id] = cur + 1

  -- Tu bac 0 len 1 la MO KHOA: phai gan ability vao unit truoc da.
  if cur == 0 then
    if UnitAddAbility(d.hero, sk.id) then
      SetUnitAbilityLevel(d.hero, sk.id, 1)
      S.skillMax[sk.id] = probeMax(d.hero, sk.id)
      SetUnitAbilityLevel(d.hero, sk.id, 1)
      -- PHAI goi applyLevel o day nua. Truoc day nhanh mo khoa return
      -- thang, nen mana va hoi chieu cua ability giu nguyen so cua
      -- Object Editor -- Chuong la ban sao cua Shockwave nen no doi 100
      -- mana trong khi bang ghi 25, va hero chi co 75 mana. Bang noi mot
      -- dang, game lam mot neo.
      applyLevel(pid, sk, 1)
      API.skillFxRecompute(pid)   -- vua mo khoa mot bi dong
    else
      API.info(pid, CFG.C_RED .. "Khong gan duoc " .. API.idToStr(sk.id) ..
        CFG.C_END)
    end
    API.say(pid, API.t("skill_unlocked",
      CFG.C_JADE .. API.pick(sk) .. CFG.C_END))
    API.panelRefresh(pid)
    return
  end

  applyLevel(pid, sk, cur + 1)
  API.skillFxRecompute(pid)   -- bi dong "stat"/"aura" tinh lai theo bac moi

  -- Doc lai bac THAT tren unit. Neu no khong bang bac vua mua thi bang
  -- dang noi doi, va tha nguoi choi biet ngay con hon phat hien sau
  -- muoi lan nang nua.
  local real = (d.hero ~= nil) and GetUnitAbilityLevel(d.hero, sk.id) or (cur + 1)
  if real ~= cur + 1 then
    API.msg(pid, CFG.C_RED ..
      API.t("skill_warn", API.pick(sk), real, cur + 1) .. CFG.C_END)
  end
  -- Tin CHUNG: ca ban do thay ai dang len tay. Cung ly do voi
  -- skill_unlocked o nhanh tren.
  API.say(pid, API.t("skill_up", CFG.C_JADE .. API.pick(sk) .. CFG.C_END,
                     cur + 1, ceil))
  API.panelRefresh(pid)
end

-- ---------- The "Ky Nang" trong bang phim E ----------

-- DOC so tu chinh ability, khong tu tinh.
--
-- Hai ky nang (A003 Endurance Aura, A006 Hoi Sinh) co bang so nam tron
-- trong war3map.w3a do World Editor dat. Tu tinh lai o day la co HAI
-- noi cung khai mot con so, va hai noi thi som muon lech -- nguoi choi
-- doc mot dang, danh ra mot dang.
--
-- Hang so co the vang mat o ban nay: TRACE roi lui ve hien bac, khong
-- nuot. Do ten that bang lenh "-nat oae".
local function fromAbility(pid, sk, level)
  if sk.fromCooldown then
    if BlzGetAbilityCooldown == nil then
      API.trace("skill: khong co BlzGetAbilityCooldown -- " ..
                API.idToStr(sk.id) .. " hien bac thay vi hoi chieu")
      return nil
    end
    return string.format("%.0fs", BlzGetAbilityCooldown(sk.id, level - 1))
  end

  if sk.fromAbil == nil then return nil end
  -- BlzGetAbilityRealLevelField nhan HANDLE ability, ma handle chi lay
  -- duoc tu mot unit dang mang no. Chua co hero thi chiu.
  local h = (S.p[pid] or {}).hero
  if h == nil or BlzGetUnitAbility == nil
     or BlzGetAbilityRealLevelField == nil then
    return nil
  end
  local F = _G[sk.fromAbil]

  -- DUONG VONG khi hang so vang mat.
  --
  -- Do duoc o 1.31.1 (dong "-nat" trong file vet): THIEU ca
  -- ABILITY_RLF_ATTACK_SPEED_INCREASE_OAE1 lan
  -- ABILITY_RLF_MOVEMENT_SPEED_INCREASE_OAE2 -- tuc bang ky nang cua
  -- A003 chi hien duoc "bac N". Rieng BlzGetAbilityRealLevelField thi
  -- CO, no chi thieu cai handle truong de dua vao.
  --
  -- ConvertAbilityRealLevelField dung ma truong 4 ky tu, nen dung duoc
  -- ma khong can hang so co ten. Co ban co ham nay, co ban khong --
  -- tra truoc khi goi, va van lui ve "bac N" neu khong co.
  if F == nil and sk.fromField ~= nil then
    local conv = _G["ConvertAbilityRealLevelField"]
    if conv ~= nil then F = conv(FourCC(sk.fromField)) end
  end

  if F == nil then
    API.trace("skill: khong co hang so " .. tostring(sk.fromAbil) ..
              " (va khong chuyen duoc tu ma truong " ..
              tostring(sk.fromField) .. ") -- " .. API.idToStr(sk.id) ..
              " hien bac thay vi so that")
    return nil
  end
  local ab = BlzGetUnitAbility(h, sk.id)
  if ab == nil then return nil end
  local v = BlzGetAbilityRealLevelField(ab, F, level - 1)
  if v == nil then return nil end
  return sk.fromPct and string.format("%.0f%%", v * 100.0)
                     or string.format("%.2f", v)
end

local function fmt(pid, sk, level, rank)
  local fromA = fromAbility(pid, sk, level)
  if fromA ~= nil then return fromA end
  -- Doc khong ra thi noi RO la bac may, chu khong bia mot con so.
  if sk.fromAbil ~= nil or sk.fromCooldown then
    return API.t("skill_rank_n", level)
  end
  if sk.statVal ~= nil then
    return "+" .. API.num(math.floor(statAt(sk, level, rank) + 0.5))
  end
  if sk.armor ~= nil then
    return "+" .. string.format("%.0f", armorAt(sk, level))
  end
  if sk.kind == "aura" or sk.kind == "passive" then
    return string.format("%.0f%%", pctAt(sk, level) * 100)
  end
  return "x" .. string.format("%.2f", factorAt(sk, level))
end

-- Icon lay THANG tu ability, khong go duong dan trong bang. Go tay thi
-- sai mot chu la hien o xanh la, ma khong ai biet sai o dau.
local function iconOf(sk)
  if sk.icon ~= nil then return sk.icon end
  if BlzGetAbilityIcon == nil then return nil end
  local p = BlzGetAbilityIcon(sk.id)
  if p == nil or p == "" then return nil end
  return p
end

-- Mot dong mo ta: hieu luc, roi hoi chieu / mana neu co.
local function subOf(pid, sk, lv)
  local s = fmt(pid, sk, lv, API.cultRank and API.cultRank(pid) or 1)
  if sk.factor ~= nil and sk.factor > 0 then
    -- Ghi ro dang an theo chi so nao. Cong thuc lay chi so CAO NHAT, ma
    -- nguoi choi khong co cach nao biet do la cai nao neu khong noi.
    local _, name = topStat(S.p[pid] and S.p[pid].hero)
    s = s .. " (" .. API.t("stat_" .. name) .. ")"
  end
  if sk.cd ~= nil and sk.cd > 0 then
    s = s .. "   " .. string.format("%.1fs", cdAt(sk, lv))
    if manaAt(sk, lv) > 0 then s = s .. " / " .. manaAt(sk, lv) .. " mana" end
  end
  return s
end

local function tabItems(pid)
  local list = listOf(pid)
  if #list == 0 then return {} end

  local lumber = API.getLumber(pid)
  local out = {}
  for i = 1, #list do
    local sk   = list[i]
    local lv   = levelOf(pid, sk.id, i)
    local ceil = maxOf(sk.id)
    local price  = costOf(pid, lv, sk.id)

    local it = { icon = iconOf(sk), name = API.pick(sk) }

    if lv <= 0 then
      -- Ky nang chua mo: KHONG hien so lieu cua no. Lo het thi chang
      -- con gi de mong khi bo tien ra mo.
      it.name       = CFG.C_GREY .. API.pick(sk) .. CFG.C_END
      it.status = CFG.C_GREY .. API.t("skill_locked") .. CFG.C_END
      it.desc      = ""
      if price ~= nil then
        it.btn    = API.t("btn_unlock") .. "  " .. price .. " " .. API.t("cur_lumber")
        it.btnOn = (lumber >= price)
        if not it.btnOn then
          it.btn = it.btn .. API.t("gear_btn_have", API.num(lumber))
        end
      end
    else
      -- Hien TRAN THAT, khong hien tran thiet ke. Bang bao 10/10 trong
      -- khi unit chi len duoc bac 3 la bang noi doi.
      local rank = lv .. "/" .. ceil
      if ceil < CFG.SKILL_MAX_LEVEL then
        rank = CFG.C_RED .. rank .. " !" .. CFG.C_END
      else
        rank = CFG.C_JADE .. rank .. CFG.C_END
      end
      it.status = rank
      it.desc      = subOf(pid, sk, lv)
      if price ~= nil then
        it.btn    = API.t("btn_up") .. "  " .. price .. " " .. API.t("cur_lumber")
        it.btnOn = (lumber >= price)
        if not it.btnOn then
          it.btn = it.btn .. API.t("gear_btn_have", API.num(lumber))
        end
      else
        it.status = CFG.C_GREY .. API.t("st_max") .. CFG.C_END
      end
    end
    out[i] = it
  end

  -- Mot dong su that o cuoi: con so mau ngoc o tren la THIET KE, chua
  -- phai thu dang chay. Chung chi thanh that khi bo sinh ghi so vao
  -- war3map.w3a va cac skill bi dong duoc viet bang Lua.
  --
  -- Giu lai sau khi doi bo cuc: bang ma hien so dep nhung sai thi te
  -- hon la khong hien gi.
  if not CFG.SKILL_DATA_LIVE then
    out[#out + 1] = {
      name  = CFG.C_RED .. API.t("skill_notlive") .. CFG.C_END,
      desc = API.t("skill_notlive2"),
    }
  end
  return out
end

local function tabItemAction(pid, i)
  if listOf(pid)[i] == nil then return end
  API.syncSend(pid, CFG.OP_SKILL_UP, i)
end

local function startSkills()
  API.panelAddTab({
    name        = API.t("panel_skill"),
    kind       = "list",
    -- Dong canh bao SKILL_DATA_LIVE chi hien khi co la false, nen chi
    -- dat cho no khi do. Mot hang thua = 0.048 chieu cao khung, ma
    -- chieu cao dang tranh nhau voi thanh giao dien duoi.
    rows      = 7 + (CFG.SKILL_DATA_LIVE and 0 or 1),
    items      = tabItems,
    itemAction = tabItemAction,
    empty      = API.t("skill_none"),
  })
  API.syncOn(CFG.OP_SKILL_UP, upgrade)
  API.trace("skill: the Ky Nang san sang (Go)")
end

-- Goi khi hero vua duoc tao: dat lai bac cho dung voi bang da mua.
local function applyToHero(pid)
  local d = S.p[pid]
  local list = listOf(pid)
  local missing = {}

  local have = 0
  for i = 1, #list do
    local sk = list[i]
    local lv = levelOf(pid, sk.id, i)

    -- Chi do va dat bac cho ky nang DA MO KHOA. Ky nang con khoa chua
    -- nam tren unit, do no chi tra ve 0 va lam ban bao cao.
    if lv > 0 and d ~= nil and d.hero ~= nil then
      have = have + 1
      local m = probeMax(d.hero, sk.id)
      S.skillMax[sk.id] = m
      if m > 0 and m < CFG.SKILL_MAX_LEVEL then
        missing[#missing + 1] = API.idToStr(sk.id) .. "=" .. m
      end
      applyLevel(pid, sk, lv)
    end
  end

  if #missing > 0 then
    API.trace("skill: OE thieu bac -- " .. table.concat(missing, " "))
    API.warn(pid, #missing .. "/" .. have ..
      " ky nang chua du " .. CFG.SKILL_MAX_LEVEL .. " bac trong Object Editor" ..
      CFG.C_END .. CFG.C_GREY .. " (" .. table.concat(missing, " ") ..
      "). Dat Stats - Levels = " .. CFG.SKILL_MAX_LEVEL .. ".")
  end
end

API.skillList    = listOf
API.skillLevel   = levelOf
API.skillCost    = costOf
API.skillDamage  = skillDamage
API.skillFactor    = factorAt
API.skillCd      = cdAt
API.skillPct     = pctAt
API.skillStat   = statAt
API.skillArmor    = armorAt
API.skillMana    = manaAt
API.skillTopStat = topStat
API.skillApply   = applyToHero
API.startSkills  = startSkills
