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

local function levelOf(pid, aid)
  local d = S.p[pid]
  if d == nil or d.skill == nil then return 1 end
  return d.skill[aid] or 1
end

local function costOf(level, aid)
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
  local tran = maxOf(sk.id)
  local gia = costOf(cur, sk.id)
  if gia == nil then
    if tran < CFG.SKILL_MAX_LEVEL then
      -- Khong tru tien. Bao dung cho phai sua, dung de nguoi choi doan.
      API.msg(pid, CFG.C_RED .. sk.ten .. " chi co " .. tran ..
        " bac trong Object Editor" .. CFG.C_END .. " (thiet ke can " ..
        CFG.SKILL_MAX_LEVEL .. "). Mo Object Editor, dat " ..
        CFG.C_GOLD .. "Stats - Levels = " .. CFG.SKILL_MAX_LEVEL .. CFG.C_END ..
        " cho " .. API.idToStr(sk.id) .. ".")
    else
      API.msg(pid, CFG.C_GREY .. sk.ten .. " da o bac cao nhat." .. CFG.C_END)
    end
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

  -- Doc lai bac THAT tren unit. Neu no khong bang bac vua mua thi bang
  -- dang noi doi, va tha nguoi choi biet ngay con hon phat hien sau
  -- muoi lan nang nua.
  local that = (d.hero ~= nil) and GetUnitAbilityLevel(d.hero, sk.id) or (cur + 1)
  if that ~= cur + 1 then
    API.msg(pid, CFG.C_RED .. "Canh bao: " .. sk.ten .. " tren unit moi o bac " ..
      that .. ", khong phai " .. (cur + 1) .. CFG.C_END ..
      " -- Object Editor chua du bac.")
  end
  API.msg(pid, CFG.C_JADE .. sk.ten .. CFG.C_END .. " len bac " .. (cur + 1) ..
    "/" .. tran .. ".")
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
    local tran = maxOf(sk.id)
    local gia = costOf(lv, sk.id)

    -- Hien TRAN THAT, khong hien tran thiet ke. Bang bao 10/10 trong khi
    -- unit chi len duoc bac 3 la bang noi doi.
    local bac = "  bac " .. lv .. "/" .. tran
    if tran < CFG.SKILL_MAX_LEVEL then
      bac = CFG.C_RED .. bac .. " (OE thieu bac)" .. CFG.C_END
    end

    local dong = CFG.C_GOLD .. sk.ten .. CFG.C_END .. bac ..
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

  -- Mot dong su that o cuoi: con so mau ngoc o tren la THIET KE, chua
  -- phai thu dang chay. Chung chi thanh that khi bo sinh ghi so vao
  -- war3map.w3a va cac skill bi dong duoc viet bang Lua.
  if not CFG.SKILL_DATA_LIVE then
    out[#out + 1] = ""
    out[#out + 1] = CFG.C_RED .. "So lieu tren la THIET KE, chua co hieu luc." ..
      CFG.C_END .. CFG.C_GREY ..
      " Trong game van la so goc cua Warcraft." .. CFG.C_END
  end
  return out
end

-- Nut [+] cua tung dong. Nil = dong do khong co nut.
local function tabRowLabel(pid, i)
  local sk = listOf(pid)[i]
  if sk == nil then return nil end
  if costOf(levelOf(pid, sk.id), sk.id) == nil then return nil end
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
  local d = S.p[pid]
  local list = listOf(pid)
  local thieu = {}

  for i = 1, #list do
    local sk = list[i]
    if d ~= nil and d.hero ~= nil then
      local m = probeMax(d.hero, sk.id)
      S.skillMax[sk.id] = m
      if m > 0 and m < CFG.SKILL_MAX_LEVEL then
        thieu[#thieu + 1] = API.idToStr(sk.id) .. "=" .. m
      end
    end
    applyLevel(pid, sk, levelOf(pid, sk.id))
  end

  if #thieu > 0 then
    API.trace("skill: OE thieu bac -- " .. table.concat(thieu, " "))
    API.msg(pid, CFG.C_RED .. #thieu .. "/" .. #list ..
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
API.skillTopStat = topStat
API.skillApply   = applyToHero
API.startSkills  = startSkills
