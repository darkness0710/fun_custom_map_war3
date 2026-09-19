-- ============================================================
--  3_cultivation.lua  --  Tu Vi (bac tu luyen cua nguoi choi)
--
--  Ten cu la "Linh Can". Doi vi sai nghia: "Linh Can" la TU CHAT bam
--  sinh, thu khong doi duoc; he nay thi nguoc lai, no len tung nac
--  theo canh gioi. Nhan doi truoc (T.panel_cult), dinh danh doi sau
--  (cultRank / CFG.CULT_*) nen gio khong con cho nao lech nhau.
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
-- Ban truoc nhan ca chi so len CULT_STEP^(r-1) roi giai nguoc de bu
-- phan sat thuong nen. Bo vi mot ly do giao dien chu khong phai toan:
-- nguoi choi khong doc duoc "x1.17", ho doc duoc "+50 chi so". Con so
-- cong them la thu nhin thay ngay tren bang hero sau khi bam.
--
-- statBonusAt(r) = tong cong don sau (r-1) lan dot pha
--                = GAIN x (STEP^(r-1) - 1) / (STEP - 1)
local function statBonusAt(r)
  local g, s = CFG.CULT_STAT_GAIN, CFG.CULT_STAT_STEP
  if r <= 1 then return 0.0 end
  if s == 1.0 then return g * (r - 1) end     -- tranh chia cho 0
  return g * (s ^ (r - 1) - 1) / (s - 1)
end

local function statAt(r)
  return CFG.CULT_STAT_BASE + statBonusAt(r)
end

-- He so suc manh HIEN RA cho nguoi choi. Suy TU chi so chu khong phai
-- mot duong cong rieng: sat thuong = factor x (DMG_BASE + chi so), nen
-- day dung la ti le sat thuong giua bac r va bac 1. Ban truoc no la mot
-- hang so rieng (CULT_STEP) va co the noi khac voi chi so that.
local function powerAt(r)
  local b = CFG.CULT_DMG_BASE
  return (b + statAt(r)) / (b + statAt(1))
end

-- He so suy ra thanh chu. "x2.85" doc duoc, nhung bac 20 la
-- x970,903 -- in no bang %.2f ra "x970903.00", dai va thua hai chu so
-- le khong ai can.
local function powerText(r)
  local p = powerAt(r)
  if p < 1000.0 then return string.format("x%.2f", p) end
  return "x" .. API.num(math.floor(p + 0.5))
end

-- PHANG: CFG.CULT_COST_STEP = 1.0 nen moi bac deu 500. Van giu cong
-- thuc mu de doi lai duong cong chi bang mot so.
local function costOf(r)
  return math.floor(CFG.CULT_COST_BASE * CFG.CULT_COST_STEP ^ (r - 1) + 0.5)
end

-- Linh Can KHONG tu ghi chi so nua. No chi tra loi mot cau: "tu vi cong
-- them bao nhieu diem so voi bac 1?"
--
-- API.heroRecompute trong 7_effect.lua la cho DUY NHAT ghi chi so hero
-- -- no cong nen + so nay, roi nhan % cua bi dong, roi ghi mot lan. Truoc
-- day moi he tu cong vao, va hai he cung ghi mot thuoc tinh thi lech.
--
-- CFG.CULT_STAT_MODE quyet dinh cong vao chi so nao; phan do do
-- recompute lo.
local function statBonus(pid)
  local d = S.p[pid]
  if d == nil then return 0 end
  return math.floor(statBonusAt(d.cultRank) + 0.5)
end

-- ---------- Noi dung the ----------
--
-- Cai nguoi choi can biet la TRUOC -> SAU va GIA. Khong phai ca bang.
-- Duong dan anh cua mot canh gioi. Chua ve toi thi dung anh CAO NHAT
-- da co -- cung cach iconFor() cua 5_gear.lua, va cung ly do: thieu anh
-- thi ra o trong, ma o trong nhin nhu giao dien hong.
local function realmIcon(r)
  if CFG.REALM_ICON_PATH == nil or r == nil then return nil end
  local mx = CFG.REALM_ICON_MAX or 0
  if r > mx then r = mx end
  if r < 1 then return nil end
  return string.format(CFG.REALM_ICON_PATH, r)
end


local function tabInfo(pid)
  local d = S.p[pid]
  if d == nil then return {} end

  local cur = d.cultRank
  local top = maxRank()
  local out = {
    title  = API.t("cult_rank", cur, top),
    sub    = rankName(cur),
    progress = cur / top,
  }

  if cur >= top then
    out.row = {
      { API.t("cult_power"), powerText(cur), "" },
      { API.t("cult_stat"),
        "+" .. API.num(statAt(cur) - CFG.CULT_STAT_BASE), "" },
    }
    out.note = API.t("cult_peak")
    -- Het thang: mot buc, khong mui ten -- khong con "sau" de tro toi.
    out.art = { { icon = realmIcon(cur), name = rankName(cur) } }
    -- Da o bac cao nhat: van ve mot nut, khoa. Khong co nut thi the
    -- Tu Vi bong dung trong rong o cuoi van, trong nhu bang hong.
    out.btn    = API.t("cult_btn_peak")
    out.btnOn  = false
    out.btnWhy = "locked" 
    return out
  end

  local price = costOf(cur)
  out.row = {
    { API.t("cult_power"),
      powerText(cur), powerText(cur + 1) },
    { API.t("cult_stat"),
      "+" .. API.num(statAt(cur)     - CFG.CULT_STAT_BASE),
      "+" .. API.num(statAt(cur + 1) - CFG.CULT_STAT_BASE) },
    { API.t("col_realm"), rankName(cur), rankName(cur + 1) },
  }
  -- Cung nhip voi ba dong tren: trai la DANG O, phai la SAU KHI DOT PHA.
  -- Buc phai mo di (dim) vi no chua thuoc ve nguoi choi.
  out.art = {
    { icon = realmIcon(cur),     name = rankName(cur) },
    { icon = realmIcon(cur + 1), name = rankName(cur + 1), dim = true },
  }

  out.btn    = API.t("cult_next", rankName(cur + 1)) .. "     " ..
               API.num(price) .. " " .. API.t("cur_qi")
  out.btnOn = (API.getQi(pid) >= price)
  if not out.btnOn then
    out.btn = out.btn .. API.t("gear_btn_have", API.num(API.getQi(pid)))
  end
  out.note = API.t("cult_have", API.num(API.getQi(pid)))
  return out
end

-- ---------- Dot pha ----------
-- setRank/breakthrough chay tren MOI may, tu su kien dong bo.

local function setRank(pid, newR, dev)
  local d = S.p[pid]
  if d == nil then return end
  if newR < 1 then newR = 1 end
  if newR > maxRank() then newR = maxRank() end

  local old = d.cultRank
  if newR == old then return end

  d.cultRank = newR
  API.heroRecompute(pid)
  API.panelRefresh(pid)

  if dev then
    API.info(pid, CFG.C_GREY .. "[dev] Linh Can -> " .. rankName(newR) ..
      " (bac " .. newR .. ", " .. powerText(newR) .. ")" .. CFG.C_END)
  end
end

local function breakthrough(pid)
  local d = S.p[pid]
  if d == nil then return end

  local r = d.cultRank
  if r >= maxRank() then
    API.msg(pid, CFG.C_GREY .. API.t("cult_peak") .. CFG.C_END)
    return
  end

  local c = costOf(r)
  if not API.spendQi(pid, c) then
    API.msg(pid, CFG.C_RED .. API.t("no_qi") .. CFG.C_END ..
      API.t("need_have", API.num(c), API.num(API.getQi(pid))))
    API.panelRefresh(pid)
    return
  end

  setRank(pid, r + 1, false)
  API.msg(nil, API.t("cult_broke",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. rankName(r + 1) .. CFG.C_END) ..
    " (" .. powerText(r + 1) .. ")")

  if d.hero ~= nil then
    API.fx([[Abilities\Spells\Human\Resurrect\ResurrectTarget.mdl]],
           GetUnitX(d.hero), GetUnitY(d.hero))
  end

  -- Canh gioi vua tang -- co the vua mo mot pho ban. Kiem o day chu
  -- khong bat nguoi choi tu nho moc nao la moc nao.
  if API.sideQuestCheck ~= nil then API.sideQuestCheck(pid) end
  -- Canh gioi vua tang -- co the vua cham mot moc canh.
  if API.wingCheck ~= nil then API.wingCheck(pid) end
end

-- Nut "Dot pha" tren bang: KHONG doi trang thai o day. Su kien bam frame
-- chi no tren may nguoi bam, nen chi gui mot tin -- 02b_sync lo phan con
-- lai. breakthrough() ben duoi chay tren MOI may, cung mot nhip.
local function tabAction(pid)
  API.syncSend(pid, CFG.OP_CULT_UP, 0)
end

-- "-lc" mo the Linh Can | "-lc up" dot pha | "-lc <so>" nhay bac (dev)
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
        API.warn(pid, "Lenh dev dang tat (CFG.DEV_COMMANDS).")
        return
      end
      setRank(pid, n, true)
      return
    end
  end

  API.panelOpenTab(pid, S.cultTabIndex or 1)
end

local function startCult()
  S.cultTabIndex = API.panelAddTab({
    name    = API.t("panel_cult"),
    kind   = "focus",
    info   = tabInfo,
    action = tabAction,
  })

  API.syncOn(CFG.OP_CULT_UP,  function(pid) breakthrough(pid) end)
  API.syncOn(CFG.OP_CULT_SET, function(pid, arg) setRank(pid, arg, true) end)

  API.trace("cult: the so " .. S.cultTabIndex .. ", dong bo=" .. API.syncMode())
end

-- Goi khi hero vua duoc tao. Khong con lam gi rieng: recompute doc
-- statBonus roi tu ap. Giu ten de cho goi cu khong gay.
local function applyToHero(pid, hero)
  API.heroRecompute(pid)
end

API.cultRank   = function(pid) return S.p[pid] and S.p[pid].cultRank or 1 end
API.cultPower  = function(pid) return powerAt(API.cultRank(pid)) end
API.cultCost   = costOf
API.cultStatAt = statAt
API.cultStatBonus = statBonus
API.cultChat   = onChat
API.cultApply  = applyToHero
API.startCult  = startCult
