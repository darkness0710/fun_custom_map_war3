-- ============================================================
--  07d_linhcan.lua  --  Linh Can (tu vi cua nguoi choi)
--
--  Nguon suc manh LON NHAT: x20 trong hop dong x967
--  (docs/03-du-lieu/duong-cong-suc-manh.md). 20 bac, dung chung thang
--  ten voi 20 canh gioi cua phe dich.
--
--  File nay KHONG ve bang. No dang ky mot the vao bang nhan vat
--  (07e_panel.lua) va chi lo phan noi dung. Nho vay bon he dung chung
--  mot khung, khong the lech nhau ve giao dien.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local ROWS_AHEAD = 5    -- so bac ke tiep hien trong thang
local ROWS_BACK  = 1    -- so bac da qua hien trong thang

-- ---------- Toan ----------

local function maxRank() return #CFG.REALMS end

local function rankName(r)
  local e = CFG.REALMS[r]
  if e == nil then return "?" end
  return e.ten
end

local function powerAt(r) return CFG.LINHCAN_STEP ^ (r - 1) end

-- GIAI NGUOC, khong nhan thang. Sat thuong hero = sat thuong nen + chi
-- so, nen nhan thang chi so len x1.17 moi bac chi cho x10.4 sat thuong
-- sau 20 bac -- thieu mot nua. Cong thuc nay bu lai phan nen.
local function statAt(r)
  local b = CFG.LINHCAN_DMG_BASE
  return (b + CFG.LINHCAN_STAT_BASE) * powerAt(r) - b
end

local function costOf(r)
  return math.floor(CFG.LINHCAN_COST_BASE * CFG.LINHCAN_COST_STEP ^ (r - 1) + 0.5)
end

-- Cong PHAN CHENH giua hai bac, khong dat lai tu dau -- SetHeroStr cong
-- don, dat lai tu dau se de len bonus cua trang bi sau nay.
--
-- Xem CFG.LINHCAN_STAT_MODE ve danh doi giua "all" va "primary".
local function applyRank(hero, fromR, toR)
  if hero == nil then return end
  local d = math.floor(statAt(toR) - statAt(fromR) + 0.5)
  if d == 0 then return end

  local str = GetHeroStr(hero, false)
  local agi = GetHeroAgi(hero, false)
  local int = GetHeroInt(hero, false)

  if CFG.LINHCAN_STAT_MODE == "primary" then
    -- Cong vao chi so dang cao nhat. Cung quy uoc voi cach skill an
    -- chi so, nen hero khong bao gio doi chi so chinh giua van.
    if str >= agi and str >= int then
      SetHeroStr(hero, str + d, true)
    elseif agi >= int then
      SetHeroAgi(hero, agi + d, true)
    else
      SetHeroInt(hero, int + d, true)
    end
  else
    SetHeroStr(hero, str + d, true)
    SetHeroAgi(hero, agi + d, true)
    SetHeroInt(hero, int + d, true)
  end
end

-- ---------- Noi dung the ----------

local function rowText(pid, r, cur)
  local name = rankName(r)
  local pw   = string.format("x%.2f", powerAt(r))

  if r < cur then
    return CFG.C_GREY .. "   " .. r .. "  " .. name .. "   " .. pw ..
           "   da qua" .. CFG.C_END
  elseif r == cur then
    return CFG.C_GOLD .. " > " .. r .. "  " .. name .. "   " .. pw ..
           "   dang o day" .. CFG.C_END
  end

  -- Bac tuong lai: hien gia CONG DON tu bac hien tai toi bac do.
  local sum = 0
  for k = cur, r - 1 do sum = sum + costOf(k) end
  local co = (API.getLinhKhi(pid) >= sum) and CFG.C_JADE or CFG.C_GREY
  return "   " .. r .. "  " .. name .. "   " .. pw ..
         "   " .. co .. API.num(sum) .. CFG.C_END
end

local function tabRows(pid)
  local d = S.p[pid]
  if d == nil then return { "?" } end

  local cur = d.linhCan
  local out = {}
  out[1] = "Suc manh " .. CFG.C_JADE .. string.format("x%.2f", powerAt(cur)) ..
           CFG.C_END .. "   chi so +" .. API.num(statAt(cur) - CFG.LINHCAN_STAT_BASE)

  local first = cur - ROWS_BACK
  if first < 1 then first = 1 end
  for i = 1, ROWS_AHEAD + ROWS_BACK + 1 do
    local r = first + i - 1
    if r > maxRank() then break end
    out[#out + 1] = rowText(pid, r, cur)
  end
  return out
end

local function tabActionLabel(pid)
  local d = S.p[pid]
  if d == nil or d.linhCan >= maxRank() then return nil end
  return "Dot pha " .. API.num(costOf(d.linhCan))
end

-- ---------- Dot pha ----------
-- setRank/breakthrough chay tren MOI may, tu su kien dong bo.

local function setRank(pid, newR, dev)
  local d = S.p[pid]
  if d == nil then return end
  if newR < 1 then newR = 1 end
  if newR > maxRank() then newR = maxRank() end

  local old = d.linhCan
  if newR == old then return end

  d.linhCan = newR
  applyRank(d.hero, old, newR)
  API.panelRefresh(pid)

  if dev then
    API.msg(pid, CFG.C_GREY .. "[dev] Linh Can -> " .. rankName(newR) ..
      " (bac " .. newR .. ", x" .. string.format("%.2f", powerAt(newR)) .. ")" .. CFG.C_END)
  end
end

local function breakthrough(pid)
  local d = S.p[pid]
  if d == nil then return end

  local r = d.linhCan
  if r >= maxRank() then
    API.msg(pid, CFG.C_GREY .. "Da toi dinh cua thang tu vi." .. CFG.C_END)
    return
  end

  local c = costOf(r)
  if not API.spendLinhKhi(pid, c) then
    API.msg(pid, CFG.C_RED .. "Khong du linh khi." .. CFG.C_END ..
      " Can " .. API.num(c) .. ", dang co " .. API.num(API.getLinhKhi(pid)) .. ".")
    API.panelRefresh(pid)
    return
  end

  setRank(pid, r + 1, false)
  API.msg(nil, CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END ..
    " dot pha len " .. CFG.C_JADE .. rankName(r + 1) .. CFG.C_END ..
    " (x" .. string.format("%.2f", powerAt(r + 1)) .. ")")

  if d.hero ~= nil then
    API.fx([[Abilities\Spells\Human\Resurrect\ResurrectTarget.mdl]],
           GetUnitX(d.hero), GetUnitY(d.hero))
  end
end

-- Nut "Dot pha" tren bang: KHONG doi trang thai o day. Su kien bam frame
-- chi no tren may nguoi bam, nen chi gui mot tin -- 02b_sync lo phan con
-- lai. breakthrough() ben duoi chay tren MOI may, cung mot nhip.
local function tabAction(pid)
  API.syncSend(pid, CFG.OP_LC_UP, 0)
end

-- "-lc" mo the Linh Can · "-lc up" dot pha · "-lc <so>" nhay bac (dev)
--
-- Lenh chat KHONG can di qua 02b_sync: su kien chat von da no tren moi
-- may cung luc. Goi thang la dung, va do la ly do lenh chat luon chay
-- duoc ke ca khi khong con duong dong bo nao.
local function onChat(pid, raw)
  if raw ~= nil and raw:match("^%s*%-lc%s+up") then
    breakthrough(pid)
    return
  end

  if raw ~= nil then
    local n = tonumber(raw:match("^%s*%-lc%s+(%d+)"))
    if n ~= nil then
      if not CFG.DEV_COMMANDS then
        API.msg(pid, CFG.C_RED .. "Lenh dev dang tat (CFG.DEV_COMMANDS)." .. CFG.C_END)
        return
      end
      setRank(pid, n, true)
      return
    end
  end

  API.panelOpenTab(pid, S.lcTabIndex or 1)
end

local function startLinhCan()
  S.lcTabIndex = API.panelAddTab({
    ten         = "Linh Can",
    rows        = tabRows,
    actionLabel = tabActionLabel,
    action      = tabAction,
  })

  API.syncOn(CFG.OP_LC_UP,  function(pid) breakthrough(pid) end)
  API.syncOn(CFG.OP_LC_SET, function(pid, arg) setRank(pid, arg, true) end)

  API.trace("linhcan: the so " .. S.lcTabIndex .. ", dong bo=" .. API.syncMode())
end

-- Goi khi hero vua duoc tao: ap lai bac hien tai, de doi hero khong mat tu vi.
local function applyToHero(pid, hero)
  local d = S.p[pid]
  if d == nil or hero == nil then return end
  applyRank(hero, 1, d.linhCan)
end

API.linhCanRank   = function(pid) return S.p[pid] and S.p[pid].linhCan or 1 end
API.linhCanPower  = function(pid) return powerAt(API.linhCanRank(pid)) end
API.linhCanCost   = costOf
API.linhCanStatAt = statAt
API.linhCanChat   = onChat
API.linhCanApply  = applyToHero
API.startLinhCan  = startLinhCan
