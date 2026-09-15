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
local function unlockCost(pid)
  local list = CFG.SKILLS[S.p[pid] and S.p[pid].hero
                          and GetUnitTypeId(S.p[pid].hero) or 0]
  if list == nil then return nil end

  local daMo = 0
  local d = S.p[pid]
  for i = 1, #list do
    local lv = (d.skill and d.skill[list[i].id])
               or (i <= CFG.SKILL_START_COUNT and 1 or 0)
    if lv > 0 then daMo = daMo + 1 end
  end

  local c = CFG.SKILL_UNLOCK[daMo + 1]
  if c == nil or c <= 0 then return nil end
  return c
end

local function costOf(pid, level, aid)
  if level <= 0 then return unlockCost(pid) end
  if level >= (aid and maxOf(aid) or CFG.SKILL_MAX_LEVEL) then return nil end
  return math.floor(CFG.SKILL_COST_BASE * CFG.SKILL_COST_STEP ^ (level - 1) + 0.5)
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
  if not API.spendLinhKhi(pid, gia) then
    API.msg(pid, CFG.C_RED .. API.t("no_qi") .. CFG.C_END ..
      API.t("need_have", API.num(gia), API.num(API.getLinhKhi(pid))))
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
  if sk.loai == "aura" or sk.loai == "bidong" then
    return string.format("%.0f%%", pctAt(sk, level) * 100)
  end
  return "x" .. string.format("%.2f", heSoAt(sk, level))
end

local function tabRows(pid)
  local list = listOf(pid)
  if #list == 0 then
    return { CFG.C_GREY .. API.t("skill_none") .. CFG.C_END }
  end

  local out = {}
  for i = 1, #list do
    local sk = list[i]
    local lv = levelOf(pid, sk.id, i)
    local tran = maxOf(sk.id)
    local gia = costOf(pid, lv, sk.id)

    -- Hien TRAN THAT, khong hien tran thiet ke. Bang bao 10/10 trong khi
    -- unit chi len duoc bac 3 la bang noi doi.
    -- Dong bi khoa: chi hien ten, chu "khoa" va gia mo. Hien luon ca so
    -- lieu cua no la lo het, chang con gi de mong.
    if lv <= 0 then
      local co = (gia ~= nil and API.getLinhKhi(pid) >= gia) and CFG.C_JADE or CFG.C_GREY
      out[i] = CFG.C_GREY .. API.pick(sk) .. "   " .. API.t("skill_locked") ..
               CFG.C_END .. "   " ..
               (gia and (co .. API.num(gia) .. CFG.C_END) or "")
    else

    local bac = "  " .. API.t("panel_level") .. " " .. lv .. "/" .. tran
    if tran < CFG.SKILL_MAX_LEVEL then
      bac = CFG.C_RED .. bac .. " (" .. API.t("skill_oeshort") .. ")" .. CFG.C_END
    end

    local dong = CFG.C_GOLD .. API.pick(sk) .. CFG.C_END .. bac ..
                 "   " .. CFG.C_JADE .. fmt(sk, lv) .. CFG.C_END
    if sk.heSo ~= nil and sk.heSo > 0 then
      -- Ghi ro dang an theo chi so nao. Cong thuc lay chi so CAO NHAT,
      -- ma nguoi choi khong co cach nao biet do la cai nao neu khong noi.
      local _, ten = topStat(S.p[pid] and S.p[pid].hero)
      dong = dong .. CFG.C_GREY .. " (" .. API.t("stat_" .. ten) .. ")" .. CFG.C_END
    end
    if sk.cd ~= nil and sk.cd > 0 then
      dong = dong .. CFG.C_GREY .. string.format("  %s %.1fs", API.t("panel_cd"), cdAt(sk, lv)) .. CFG.C_END
    end
    if manaAt(sk, lv) > 0 then
      dong = dong .. CFG.C_GREY .. "  " .. API.t("panel_mana") .. " " ..
             manaAt(sk, lv) .. CFG.C_END
    end
    if gia == nil then
      dong = dong .. CFG.C_GREY .. "   " .. API.t("panel_max") .. CFG.C_END
    else
      local co = (API.getLinhKhi(pid) >= gia) and CFG.C_JADE or CFG.C_GREY
      dong = dong .. "   " .. co .. API.num(gia) .. CFG.C_END
    end
    out[i] = dong
    end
  end

  -- Mot dong su that o cuoi: con so mau ngoc o tren la THIET KE, chua
  -- phai thu dang chay. Chung chi thanh that khi bo sinh ghi so vao
  -- war3map.w3a va cac skill bi dong duoc viet bang Lua.
  if not CFG.SKILL_DATA_LIVE then
    out[#out + 1] = ""
    out[#out + 1] = CFG.C_RED .. API.t("skill_notlive") .. CFG.C_END ..
                    CFG.C_GREY .. API.t("skill_notlive2") .. CFG.C_END
  end
  return out
end

-- Nut [+] cua tung dong. Nil = dong do khong co nut.
local function tabRowLabel(pid, i)
  local sk = listOf(pid)[i]
  if sk == nil then return nil end
  local lv = levelOf(pid, sk.id, i)
  if costOf(pid, lv, sk.id) == nil then return nil end
  if lv <= 0 then return API.t("skill_buy") end
  return "+"
end

-- Icon lay THANG tu ability, khong go duong dan trong bang. Go tay thi
-- sai mot chu la hien o xanh la, ma khong ai biet sai o dau.
local function tabRowIcon(pid, i)
  local sk = listOf(pid)[i]
  if sk == nil then return nil end
  if sk.icon ~= nil then return sk.icon end
  if BlzGetAbilityIcon == nil then return nil end
  local p = BlzGetAbilityIcon(sk.id)
  if p == nil or p == "" then return nil end
  return p
end

local function tabRowAction(pid, i)
  if listOf(pid)[i] == nil then return end
  API.syncSend(pid, CFG.OP_SKILL_UP, i)
end

local function startSkills()
  API.panelAddTab({
    ten         = API.t("panel_skill"),
    rows        = tabRows,
    rowLabel    = tabRowLabel,
    rowAction   = tabRowAction,
    rowIcon     = tabRowIcon,
    actionLabel = function() return nil end,
    action      = function() end,
  })
  API.syncOn(CFG.OP_SKILL_UP, upgrade)
  API.trace("skill: the Ky Nang san sang")
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
API.skillMana    = manaAt
API.skillTopStat = topStat
API.skillApply   = applyToHero
API.startSkills  = startSkills
