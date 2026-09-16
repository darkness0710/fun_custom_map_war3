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
  if level <= 0 then return CFG.SKILL_GO_UNLOCK end
  if level >= (aid and maxOf(aid) or CFG.SKILL_MAX_LEVEL) then return nil end
  return CFG.SKILL_GO_UP
end

-- ---------- Suc manh theo bac ----------
-- Ngan sach ca he nang cap la x2, va x2 do la TICH cua moi nut chinh.
-- Chu dong: he so x1.33 va hoi chieu x0.667 (tan suat x1.5) = x2.
-- Bi dong khong co hoi chieu nen an tron x2.

local function heSoAt(sk, level)
  return (sk.heSo or 0) * CFG.SKILL_DMG_STEP ^ (level - 1)
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
local function giapAt(sk, level)
  return (sk.giap or 0) * CFG.SKILL_PASSIVE_STEP ^ (level - 1)
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
local function skillDamage(u, heSo)
  return heSo * (CFG.LINHCAN_DMG_BASE + topStat(u))
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
  local tran = maxOf(sk.id)

  -- TAT hieu ung GOC. Xem CFG.SKILL_TAT_GOC.
  --
  -- Dat cho MOI bac, cung ly do voi mana/hoi chieu ben duoi. Hang so nao
  -- khong co trong ban nay thi GHI VET chu khong lang le bo qua -- mot
  -- cai ten go sai tra ve nil va khong lam gi ca (ADR 0012).
  local ab = (BlzGetUnitAbility ~= nil) and BlzGetUnitAbility(d.hero, sk.id) or nil

  local function tat(bang, dat)
    local zero = bang and bang[sk.id] or nil
    if zero == nil or ab == nil or dat == nil then return end
    for k = 1, #zero do
      local F = _G[zero[k]]
      if F == nil then
        API.trace("skill: KHONG co hang so " .. zero[k] ..
                  " -- hieu ung goc VAN CHAY")
      else
        for lv = 1, tran do dat(ab, F, lv - 1, 0) end
      end
    end
  end

  tat(CFG.SKILL_TAT_GOC,     BlzSetAbilityRealLevelField)
  tat(CFG.SKILL_TAT_GOC_INT, BlzSetAbilityIntegerLevelField)

  for lv = 1, tran do
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
  local tran = maxOf(sk.id)
  local gia = costOf(pid, cur, sk.id)
  if gia == nil then
    if tran < CFG.SKILL_MAX_LEVEL then
      -- Khong tru tien. Bao dung cho phai sua, dung de nguoi choi doan.
      API.msg(pid, CFG.C_RED ..
        API.t("skill_oemissing", API.pick(sk), tran) .. CFG.C_END ..
        API.t("skill_oefix", CFG.SKILL_MAX_LEVEL, CFG.SKILL_MAX_LEVEL,
              API.idToStr(sk.id)))
    else
      API.msg(pid, CFG.C_GREY .. API.t("skill_atmax", API.pick(sk)) .. CFG.C_END)
    end
    return
  end
  if not API.spendGo(pid, gia) then
    API.msg(pid, CFG.C_RED .. API.t("no_go") .. CFG.C_END ..
      API.t("need_have", API.num(gia), API.num(API.getGo(pid))) ..
      CFG.C_GREY .. " " .. API.t("ngo_note") .. CFG.C_END)
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
      API.msg(pid, CFG.C_RED .. "Khong gan duoc " .. API.idToStr(sk.id) ..
        CFG.C_END)
    end
    API.msg(nil, API.t("skill_unlocked",
      CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
      CFG.C_JADE .. API.pick(sk) .. CFG.C_END))
    API.panelRefresh(pid)
    return
  end

  applyLevel(pid, sk, cur + 1)
  API.skillFxRecompute(pid)   -- bi dong "stat"/"aura" tinh lai theo bac moi

  -- Doc lai bac THAT tren unit. Neu no khong bang bac vua mua thi bang
  -- dang noi doi, va tha nguoi choi biet ngay con hon phat hien sau
  -- muoi lan nang nua.
  local that = (d.hero ~= nil) and GetUnitAbilityLevel(d.hero, sk.id) or (cur + 1)
  if that ~= cur + 1 then
    API.msg(pid, CFG.C_RED ..
      API.t("skill_warn", API.pick(sk), that, cur + 1) .. CFG.C_END)
  end
  API.msg(pid, API.t("skill_up", CFG.C_JADE .. API.pick(sk) .. CFG.C_END,
                     cur + 1, tran))
  API.panelRefresh(pid)
end

-- ---------- The "Ky Nang" trong bang phim E ----------

local function fmt(sk, level)
  if sk.giap ~= nil then
    return "+" .. string.format("%.0f", giapAt(sk, level))
  end
  if sk.loai == "aura" or sk.loai == "bidong" then
    return string.format("%.0f%%", pctAt(sk, level) * 100)
  end
  return "x" .. string.format("%.2f", heSoAt(sk, level))
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
  local s = fmt(sk, lv)
  if sk.heSo ~= nil and sk.heSo > 0 then
    -- Ghi ro dang an theo chi so nao. Cong thuc lay chi so CAO NHAT, ma
    -- nguoi choi khong co cach nao biet do la cai nao neu khong noi.
    local _, ten = topStat(S.p[pid] and S.p[pid].hero)
    s = s .. " (" .. API.t("stat_" .. ten) .. ")"
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

  local ngo = API.getGo(pid)
  local out = {}
  for i = 1, #list do
    local sk   = list[i]
    local lv   = levelOf(pid, sk.id, i)
    local tran = maxOf(sk.id)
    local gia  = costOf(pid, lv, sk.id)

    local it = { icon = iconOf(sk), ten = API.pick(sk) }

    if lv <= 0 then
      -- Ky nang chua mo: KHONG hien so lieu cua no. Lo het thi chang
      -- con gi de mong khi bo tien ra mo.
      it.ten       = CFG.C_GREY .. API.pick(sk) .. CFG.C_END
      it.trangThai = CFG.C_GREY .. API.t("skill_locked") .. CFG.C_END
      it.mota      = ""
      if gia ~= nil then
        it.nut    = API.t("btn_unlock") .. "  " .. gia .. " " .. API.t("cur_go")
        it.batNut = (ngo >= gia)
      end
    else
      -- Hien TRAN THAT, khong hien tran thiet ke. Bang bao 10/10 trong
      -- khi unit chi len duoc bac 3 la bang noi doi.
      local bac = lv .. "/" .. tran
      if tran < CFG.SKILL_MAX_LEVEL then
        bac = CFG.C_RED .. bac .. " !" .. CFG.C_END
      else
        bac = CFG.C_JADE .. bac .. CFG.C_END
      end
      it.trangThai = bac
      it.mota      = subOf(pid, sk, lv)
      if gia ~= nil then
        it.nut    = API.t("btn_up") .. "  " .. gia .. " " .. API.t("cur_go")
        it.batNut = (ngo >= gia)
      else
        it.trangThai = CFG.C_GREY .. API.t("st_max") .. CFG.C_END
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
      ten  = CFG.C_RED .. API.t("skill_notlive") .. CFG.C_END,
      mota = API.t("skill_notlive2"),
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
    ten        = API.t("panel_skill"),
    kind       = "list",
    -- Dong canh bao SKILL_DATA_LIVE chi hien khi co la false, nen chi
    -- dat cho no khi do. Mot hang thua = 0.048 chieu cao khung, ma
    -- chieu cao dang tranh nhau voi thanh giao dien duoi.
    soMuc      = 7 + (CFG.SKILL_DATA_LIVE and 0 or 1),
    items      = tabItems,
    itemAction = tabItemAction,
    trong      = API.t("skill_none"),
  })
  API.syncOn(CFG.OP_SKILL_UP, upgrade)
  API.trace("skill: the Ky Nang san sang (Ngo Tinh)")
end

-- Goi khi hero vua duoc tao: dat lai bac cho dung voi bang da mua.
local function applyToHero(pid)
  local d = S.p[pid]
  local list = listOf(pid)
  local thieu = {}

  local co = 0
  for i = 1, #list do
    local sk = list[i]
    local lv = levelOf(pid, sk.id, i)

    -- Chi do va dat bac cho ky nang DA MO KHOA. Ky nang con khoa chua
    -- nam tren unit, do no chi tra ve 0 va lam ban bao cao.
    if lv > 0 and d ~= nil and d.hero ~= nil then
      co = co + 1
      local m = probeMax(d.hero, sk.id)
      S.skillMax[sk.id] = m
      if m > 0 and m < CFG.SKILL_MAX_LEVEL then
        thieu[#thieu + 1] = API.idToStr(sk.id) .. "=" .. m
      end
      applyLevel(pid, sk, lv)
    end
  end

  if #thieu > 0 then
    API.trace("skill: OE thieu bac -- " .. table.concat(thieu, " "))
    API.msg(pid, CFG.C_RED .. #thieu .. "/" .. co ..
      " ky nang chua du " .. CFG.SKILL_MAX_LEVEL .. " bac trong Object Editor" ..
      CFG.C_END .. CFG.C_GREY .. " (" .. table.concat(thieu, " ") ..
      "). Dat Stats - Levels = " .. CFG.SKILL_MAX_LEVEL .. "." .. CFG.C_END)
  end
end

API.skillList    = listOf
API.skillLevel   = levelOf
API.skillCost    = costOf
API.skillDamage  = skillDamage
API.skillHeSo    = heSoAt
API.skillCd      = cdAt
API.skillPct     = pctAt
API.skillGiap    = giapAt
API.skillMana    = manaAt
API.skillTopStat = topStat
API.skillApply   = applyToHero
API.startSkills  = startSkills
