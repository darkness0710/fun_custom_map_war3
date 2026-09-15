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

local function levelOf(pid, aid)
  local d = S.p[pid]
  if d == nil or d.skill == nil then return 1 end
  return d.skill[aid] or 1
end

local function costOf(level)
  if level >= CFG.SKILL_MAX_LEVEL then return nil end
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

-- Chi so cao nhat cua hero. Dung CHUNG cho moi skill, nen doi hero hay
-- doi trang bi deu khong lam skill nao bi bo lai.
local function topStat(u)
  if u == nil then return 0 end
  local s, a, i = GetHeroStr(u, true), GetHeroAgi(u, true), GetHeroInt(u, true)
  if s >= a and s >= i then return s end
  if a >= i then return a end
  return i
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
  if GetUnitAbilityLevel(d.hero, sk.id) > 0 then
    SetUnitAbilityLevel(d.hero, sk.id, level)
  end
end

local function upgrade(pid, index)
  local list = listOf(pid)
  local sk = list[index]
  if sk == nil then return end

  local d = S.p[pid]
  if d.skill == nil then d.skill = {} end

  local cur = levelOf(pid, sk.id)
  local gia = costOf(cur)
  if gia == nil then
    API.msg(pid, CFG.C_GREY .. sk.ten .. " da o bac cao nhat." .. CFG.C_END)
    return
  end
  if not API.spendLinhKhi(pid, gia) then
    API.msg(pid, CFG.C_RED .. "Khong du linh khi." .. CFG.C_END .. " Can " ..
      API.num(gia) .. ", dang co " .. API.num(API.getLinhKhi(pid)) .. ".")
    API.panelRefresh(pid)
    return
  end

  d.skill[sk.id] = cur + 1
  applyLevel(pid, sk, cur + 1)
  API.msg(pid, CFG.C_JADE .. sk.ten .. CFG.C_END .. " len bac " .. (cur + 1) ..
    "/" .. CFG.SKILL_MAX_LEVEL .. ".")
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
    return { CFG.C_GREY .. "Chua co hero, hoac hero nay chua khai bao ky nang."
             .. CFG.C_END }
  end

  local out = {}
  for i = 1, #list do
    local sk = list[i]
    local lv = levelOf(pid, sk.id)
    local gia = costOf(lv)

    local dong = CFG.C_GOLD .. sk.ten .. CFG.C_END ..
                 "  bac " .. lv .. "/" .. CFG.SKILL_MAX_LEVEL ..
                 "   " .. CFG.C_JADE .. fmt(sk, lv) .. CFG.C_END
    if sk.cd ~= nil and sk.cd > 0 then
      dong = dong .. CFG.C_GREY .. string.format("  hoi %.1fs", cdAt(sk, lv)) .. CFG.C_END
    end
    if gia == nil then
      dong = dong .. CFG.C_GREY .. "   toi da" .. CFG.C_END
    else
      local co = (API.getLinhKhi(pid) >= gia) and CFG.C_JADE or CFG.C_GREY
      dong = dong .. "   " .. co .. API.num(gia) .. CFG.C_END
    end
    out[i] = dong
  end
  return out
end

-- Nut [+] cua tung dong. Nil = dong do khong co nut.
local function tabRowLabel(pid, i)
  local sk = listOf(pid)[i]
  if sk == nil then return nil end
  if costOf(levelOf(pid, sk.id)) == nil then return nil end
  return "+"
end

local function tabRowAction(pid, i)
  if listOf(pid)[i] == nil then return end
  API.syncSend(pid, CFG.OP_SKILL_UP, i)
end

local function startSkills()
  API.panelAddTab({
    ten         = "Ky Nang",
    rows        = tabRows,
    rowLabel    = tabRowLabel,
    rowAction   = tabRowAction,
    actionLabel = function() return nil end,
    action      = function() end,
  })
  API.syncOn(CFG.OP_SKILL_UP, upgrade)
  API.trace("skill: the Ky Nang san sang")
end

-- Goi khi hero vua duoc tao: dat lai bac cho dung voi bang da mua.
local function applyToHero(pid)
  local list = listOf(pid)
  for i = 1, #list do applyLevel(pid, list[i], levelOf(pid, list[i].id)) end
end

API.skillList    = listOf
API.skillLevel   = levelOf
API.skillCost    = costOf
API.skillDamage  = skillDamage
API.skillHeSo    = heSoAt
API.skillCd      = cdAt
API.skillPct     = pctAt
API.skillTopStat = topStat
API.skillApply   = applyToHero
API.startSkills  = startSkills
