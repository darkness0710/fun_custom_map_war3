-- ============================================================
--  LECH TEN, CO Y: file/bien ten "linhcan", nhan hien ra "Tu Vi".
--
--  "Linh Can" la TU CHAT bam sinh -- thu khong doi duoc. He nay thi
--  nguoc lai: no la bac tu luyen, len tung nac theo canh gioi. Dung tu
--  "Tu Vi" moi dung nghia, nen NHAN da doi (T.panel_root).
--
--  Dinh danh trong code van la linhCan / LINHCAN_* / 3_linhcan.lua:
--  doi ca ho la sua ~50 cho o 7 file ma khong doi mot hanh vi nao. Doi
--  rieng nhan thi re, va cho lech duy nhat nam o day, co ghi lai.
-- ============================================================
--  3_linhcan.lua  --  Linh Can (tu vi cua nguoi choi)
--
--  Nguon suc manh CHINH: EHP quai bam theo chinh he so cua no
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

-- CONG THEM, khong nhan. Moi lan dot pha cong mot cuc chi so, va cuc do
-- gap doi moi bac: +50, +100, +200, ...
--
-- Ban truoc nhan ca chi so len LINHCAN_STEP^(r-1) roi giai nguoc de bu
-- phan sat thuong nen. Bo vi mot ly do giao dien chu khong phai toan:
-- nguoi choi khong doc duoc "x1.17", ho doc duoc "+50 chi so". Con so
-- cong them la thu nhin thay ngay tren bang hero sau khi bam.
--
-- statBonusAt(r) = tong cong don sau (r-1) lan dot pha
--                = GAIN x (STEP^(r-1) - 1) / (STEP - 1)
local function statBonusAt(r)
  local g, s = CFG.LINHCAN_STAT_GAIN, CFG.LINHCAN_STAT_STEP
  if r <= 1 then return 0.0 end
  if s == 1.0 then return g * (r - 1) end     -- tranh chia cho 0
  return g * (s ^ (r - 1) - 1) / (s - 1)
end

local function statAt(r)
  return CFG.LINHCAN_STAT_BASE + statBonusAt(r)
end

-- He so suc manh HIEN RA cho nguoi choi. Suy TU chi so chu khong phai
-- mot duong cong rieng: sat thuong = heSo x (DMG_BASE + chi so), nen
-- day dung la ti le sat thuong giua bac r va bac 1. Ban truoc no la mot
-- hang so rieng (LINHCAN_STEP) va co the noi khac voi chi so that.
local function powerAt(r)
  local b = CFG.LINHCAN_DMG_BASE
  return (b + statAt(r)) / (b + statAt(1))
end

-- He so suy ra thanh chu. "x2.85" doc duoc, nhung bac 20 la
-- x970,903 -- in no bang %.2f ra "x970903.00", dai va thua hai chu so
-- le khong ai can.
local function powerStr(r)
  local p = powerAt(r)
  if p < 1000.0 then return string.format("x%.2f", p) end
  return "x" .. API.num(math.floor(p + 0.5))
end

-- PHANG: CFG.LINHCAN_COST_STEP = 1.0 nen moi bac deu 500. Van giu cong
-- thuc mu de doi lai duong cong chi bang mot so.
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
  return math.floor(statBonusAt(d.linhCan) + 0.5)
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
      { API.t("lc_power"), powerStr(cur), "" },
      { API.t("lc_stat"),
        "+" .. API.num(statAt(cur) - CFG.LINHCAN_STAT_BASE), "" },
    }
    out.ghiChu = API.t("lc_peak")
    return out
  end

  local gia = costOf(cur)
  out.dong = {
    { API.t("lc_power"),
      powerStr(cur), powerStr(cur + 1) },
    { API.t("lc_stat"),
      "+" .. API.num(statAt(cur)     - CFG.LINHCAN_STAT_BASE),
      "+" .. API.num(statAt(cur + 1) - CFG.LINHCAN_STAT_BASE) },
    { API.t("col_realm"), rankName(cur), rankName(cur + 1) },
  }
  out.nut    = API.t("lc_next", rankName(cur + 1)) .. "     " ..
               API.num(gia) .. " " .. API.t("cur_lk")
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
      " (bac " .. newR .. ", " .. powerStr(newR) .. ")" .. CFG.C_END)
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
    " (" .. powerStr(r + 1) .. ")")

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
