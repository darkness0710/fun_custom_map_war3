-- ============================================================
--  3_linhcan.lua  --  Linh Can (tu vi cua nguoi choi)
--
--  Nguon suc manh LON NHAT: x20 trong hop dong x967
--  (docs/03-du-lieu/duong-cong-suc-manh.md). 20 bac, dung chung thang
--  ten voi 20 canh gioi cua phe dich.
--
--  File nay KHONG ve bang. No dang ky mot the vao bang nhan vat
--  (1_panel.lua) va chi lo phan noi dung. Nho vay bon he dung chung
--  mot khung, khong the lech nhau ve giao dien.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- The nay dung kieu "focus" cua bang: MOT the lon, MOT hanh dong.
--
-- Truoc day no la mot cai thang 7 dong. Nhung trong 7 dong do chi co
-- DUNG MOT dong bam duoc -- bac ke tiep. Sau dong con lai la thong tin
-- tham khao chen cho dung mot viec lam duoc, va nguoi choi phai do mat
-- tim xem dong nao moi la dong cua minh.
--
-- Bang 20 bac van con, nhung no thuoc ve tai lieu
-- (docs/03-du-lieu/canh-gioi.md) chu khong phai giao dien.

-- ---------- Toan ----------

local function maxRank() return #CFG.REALMS end

local function rankName(r)
  return API.pick(CFG.REALMS[r])
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

-- Linh Can KHONG tu ghi chi so nua. No chi tra loi mot cau: "tu vi cong
-- them bao nhieu diem so voi bac 1?"
--
-- API.heroRecompute trong 7_hieuung.lua la cho DUY NHAT ghi chi so hero
-- -- no cong nen + so nay, roi nhan % cua bi dong, roi ghi mot lan. Truoc
-- day moi he tu cong vao, va hai he cung ghi mot thuoc tinh thi lech.
--
-- CFG.LINHCAN_STAT_MODE quyet dinh cong vao chi so nao; phan do do
-- recompute lo.
local function statBonus(pid)
  local d = S.p[pid]
  if d == nil then return 0 end
  return math.floor(statAt(d.linhCan) - statAt(1) + 0.5)
end

-- ---------- Noi dung the ----------
--
-- Cai nguoi choi can biet la TRUOC -> SAU va GIA. Khong phai ca bang.
local function tabInfo(pid)
  local d = S.p[pid]
  if d == nil then return {} end

  local cur = d.linhCan
  local top = maxRank()
  local out = {
    tieuDe = API.t("lc_rank", cur, top),
    phu    = rankName(cur),
    tienDo = cur / top,
  }

  if cur >= top then
    out.dong = {
      { API.t("lc_power"), string.format("x%.2f", powerAt(cur)), "" },
      { API.t("lc_stat"),
        "+" .. API.num(statAt(cur) - CFG.LINHCAN_STAT_BASE), "" },
    }
    out.ghiChu = API.t("lc_peak")
    return out
  end

  local gia = costOf(cur)
  out.dong = {
    { API.t("lc_power"),
      string.format("x%.2f", powerAt(cur)),
      string.format("x%.2f", powerAt(cur + 1)) },
    { API.t("lc_stat"),
      "+" .. API.num(statAt(cur)     - CFG.LINHCAN_STAT_BASE),
      "+" .. API.num(statAt(cur + 1) - CFG.LINHCAN_STAT_BASE) },
    { API.t("col_realm"), rankName(cur), rankName(cur + 1) },
  }
  out.nut    = API.t("lc_next", rankName(cur + 1)) .. "      " .. API.num(gia)
  out.batNut = (API.getLinhKhi(pid) >= gia)
  out.ghiChu = API.t("lc_have", API.num(API.getLinhKhi(pid)))
  return out
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
  API.heroRecompute(pid)
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
    API.msg(pid, CFG.C_GREY .. API.t("lc_peak") .. CFG.C_END)
    return
  end

  local c = costOf(r)
  if not API.spendLinhKhi(pid, c) then
    API.msg(pid, CFG.C_RED .. API.t("no_qi") .. CFG.C_END ..
      API.t("need_have", API.num(c), API.num(API.getLinhKhi(pid))))
    API.panelRefresh(pid)
    return
  end

  setRank(pid, r + 1, false)
  API.msg(nil, API.t("lc_broke",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. rankName(r + 1) .. CFG.C_END) ..
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
    ten    = API.t("panel_root"),
    kind   = "focus",
    info   = tabInfo,
    action = tabAction,
  })

  API.syncOn(CFG.OP_LC_UP,  function(pid) breakthrough(pid) end)
  API.syncOn(CFG.OP_LC_SET, function(pid, arg) setRank(pid, arg, true) end)

  API.trace("linhcan: the so " .. S.lcTabIndex .. ", dong bo=" .. API.syncMode())
end

-- Goi khi hero vua duoc tao. Khong con lam gi rieng: recompute doc
-- statBonus roi tu ap. Giu ten de cho goi cu khong gay.
local function applyToHero(pid, hero)
  API.heroRecompute(pid)
end

API.linhCanRank   = function(pid) return S.p[pid] and S.p[pid].linhCan or 1 end
API.linhCanPower  = function(pid) return powerAt(API.linhCanRank(pid)) end
API.linhCanCost   = costOf
API.linhCanStatAt = statAt
API.linhCanStatBonus = statBonus
API.linhCanChat   = onChat
API.linhCanApply  = applyToHero
API.startLinhCan  = startLinhCan
