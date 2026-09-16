-- ============================================================
--  5_trangbi.lua  --  Sau o trang bi, moi o 10 cap
--
--  Mua bang LINH KHI -- cung vi voi Linh Can, va do la co y. Hai he
--  nay tranh nhau mot cai vi nen moi wave nguoi choi phai tra loi mot
--  cau that: dot pha, hay nang do?
--
--  Hai he con lai khong tranh vi do. Ky Nang an Ngo Tinh (tinh anh),
--  Phap Khi an Tinh Thach (boss) -- chung bi chan boi NOI DUNG chu
--  khong boi tien. Xem docs/02-he-thong/kinh-te.md
--
--  O bat dau o CAP 1, nang 9 lan len cap 10. Sau o day cap:
--    (1.04^9)^6 = x8.3 sat thuong -- dung phan x8 cua ngan sach x967.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function slotCount() return #CFG.TRANGBI end

-- Cap cua mot o. Mac dinh 1, khong phai 0 -- sau o deu co san tu dau,
-- thu mua duoc la CAP chu khong phai mon do.
local function levelOf(pid, i)
  local d = S.p[pid]
  if d == nil or d.tb == nil then return 1 end
  return d.tb[i] or 1
end

-- Tong so lan da nang cua CA SAU o. Gia tra theo con so nay chu khong
-- theo cap cua rieng mot o -- don het vao mot o khong re hon rai deu,
-- nen nguoi choi chon theo loi choi chu khong theo phep tinh.
local function upsOf(pid)
  local d = S.p[pid]
  return (d ~= nil) and (d.tbUps or 0) or 0
end

local function costOf(pid, i)
  if levelOf(pid, i) >= CFG.TRANGBI_MAX_LEVEL then return nil end
  return math.floor(CFG.TRANGBI_COST_BASE
                    * CFG.TRANGBI_COST_STEP ^ upsOf(pid) + 0.5)
end

-- Nhan sat thuong tu ca sau o gop lai.
local function multOf(pid)
  local n = 0
  for i = 1, slotCount() do n = n + (levelOf(pid, i) - 1) end
  return (1 + CFG.TRANGBI_PCT) ^ n
end

-- ---------- Ap vao hero ----------
--
-- Trang Bi nhan vao SAT THUONG NEN, khong cong vao chi so.
--
-- Linh Can da cong chi so roi. Neu Trang Bi cung cong chi so thi hai he
-- chong len nhau va khong con tach duoc phan nao do he nao -- ma ngan
-- sach x967 thi doi tung phan phai do duoc rieng.
--
-- File nay KHONG tu ghi len unit. API.heroRecompute trong
-- 7_hieuung.lua la cho duy nhat ghi, va no doc multOf() qua
-- API.trangBiMult.

-- ---------- Nang cap ----------
-- Chay tren MOI may, tu kenh dong bo.

local function upgrade(pid, i)
  local slot = CFG.TRANGBI[i]
  if slot == nil then return end

  local d = S.p[pid]
  if d == nil then return end
  if d.tb == nil then d.tb = {} end

  local cur = levelOf(pid, i)
  if cur >= CFG.TRANGBI_MAX_LEVEL then
    API.msg(pid, CFG.C_GREY .. API.t("skill_atmax", API.pick(slot)) .. CFG.C_END)
    return
  end

  local gia = costOf(pid, i)
  if not API.spendLinhKhi(pid, gia) then
    API.msg(pid, CFG.C_RED .. API.t("no_qi") .. CFG.C_END ..
      API.t("need_have", API.num(gia), API.num(API.getLinhKhi(pid))))
    API.panelRefresh(pid)
    return
  end

  d.tb[i]  = cur + 1
  d.tbUps  = upsOf(pid) + 1
  API.heroRecompute(pid)

  API.msg(nil, API.t("tb_bought",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. API.pick(slot) .. CFG.C_END, cur + 1))
  API.panelRefresh(pid)
end

-- ---------- The trong bang phim E ----------

local function tabItems(pid)
  local lk  = API.getLinhKhi(pid)
  local out = {}
  for i = 1, slotCount() do
    local slot = CFG.TRANGBI[i]
    local lv   = levelOf(pid, i)
    local gia  = costOf(pid, i)

    local pct = string.format("%.0f%%",
      ((1 + CFG.TRANGBI_PCT) ^ (lv - 1) - 1) * 100)

    local it = {
      icon      = slot.icon,
      ten       = API.pick(slot),
      mota      = API.t("tb_effect", pct),
      trangThai = CFG.C_JADE .. lv .. "/" .. CFG.TRANGBI_MAX_LEVEL .. CFG.C_END,
    }
    if gia ~= nil then
      it.nut    = API.t("btn_up") .. "   " .. API.num(gia)
      it.batNut = (lk >= gia)
    else
      it.trangThai = CFG.C_GREY .. API.t("st_max") .. CFG.C_END
    end
    out[i] = it
  end
  return out
end

-- Bam nut KHONG doi trang thai -- no gui mot tin, va upgrade() ben duoi
-- chay tren moi may cung mot nhip. Xem ADR 0012.
local function tabItemAction(pid, i)
  if CFG.TRANGBI[i] == nil then return end
  API.syncSend(pid, CFG.OP_TB_UP, i)
end

local function startTrangBi()
  API.panelAddTab({
    ten        = API.t("panel_gear"),
    kind       = "list",
    soMuc      = slotCount(),
    items      = tabItems,
    itemAction = tabItemAction,
  })
  API.syncOn(CFG.OP_TB_UP, upgrade)
  API.trace("trangbi: " .. slotCount() .. " o, the san sang")
end

-- Goi khi hero vua duoc tao. Khong con lam gi rieng -- giu ten de cho
-- goi cu khong gay.
local function applyToHero(pid)
  API.heroRecompute(pid)
end

API.trangBiLevel = levelOf
API.trangBiMult  = multOf
API.trangBiApply = applyToHero
API.startTrangBi = startTrangBi
