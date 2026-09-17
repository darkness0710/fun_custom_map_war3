-- ============================================================
--  10_quay.lua  --  The VI: Quay thuong
--
--  Giet tinh anh 1 luot, boss 3 luot. Moi luot mo BA the, chon MOT.
--
--    the 1  10 da Huyen Thiet, phang
--    the 2  +V vao MOT chi so ngau nhien trong ba
--    the 3  vang, PHANG, ngau nhien QUAY_VANG_MIN..MAX
--
--  V = CFG.QUAY_GIA_TRI x LINHCAN_STAT_STEP^(bac-1), ngau nhien +-30%.
--  CHI the 2 dung V. Dung CHINH buoc cua Tu Vi nen no tu bam theo --
--  doi duong cong Tu Vi thi the 2 tu co theo.
--
--  The 1 va the 3 KHONG dung V: chung la TIEN, ma tien thi phang. Xem
--  chu thich CFG.QUAY_VANG_MIN ve vi sao the 3 tung leo va vi sao bo.
--
--  BA THE SINH O DAU, va vi sao cho do.
--
--  GetRandomInt cua Warcraft da dong bo san giua cac may, VOI DIEU KIEN
--  moi may goi cung so lan va cung thu tu. Goi no trong mot nhanh
--  GetLocalPlayer() la moi may tieu mot so khac nhau tu chuoi ngau
--  nhien, va tu giay do MOI so ngau nhien cua ca van deu lech.
--
--  Nen the duoc sinh trong themLuot() -- ham do chay tu su kien quai
--  chet, tuc chay tren MOI may. Mo bang la UI thuan, khong sinh gi ca.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Gia tri mot the o bac hien tai, da nhan he so ngau nhien.
local function giaTri(pid)
  local bac = (API.linhCanRank ~= nil) and API.linhCanRank(pid) or 1
  local v = CFG.QUAY_GIA_TRI * CFG.LINHCAN_STAT_STEP ^ (bac - 1)
  local lo = math.floor(v * CFG.QUAY_DAI_MIN * 100.0 + 0.5)
  local hi = math.floor(v * CFG.QUAY_DAI_MAX * 100.0 + 0.5)
  if hi < lo then hi = lo end
  return GetRandomInt(lo, hi) / 100.0
end

-- Rut ba the moi. Chay tren MOI may -- xem chu thich dau file.
local function rutThe(pid)
  local d = S.p[pid]
  if d == nil then return end
  local v = giaTri(pid)
  d.quay = {
    { loai = "da",    so = CFG.QUAY_DA },
    { loai = "chiso", so = math.floor(v + 0.5),
      chi = CFG.QUAY_CHISO[GetRandomInt(1, #CFG.QUAY_CHISO)] },
    { loai = "vang", so = GetRandomInt(CFG.QUAY_VANG_MIN, CFG.QUAY_VANG_MAX) },
  }
end

-- Goi tu 2_wave.lua khi ha tinh anh / boss. Chay tren MOI may.
local function themLuot(pid, n)
  local d = S.p[pid]
  if d == nil or n == nil or n <= 0 then return end
  d.luotQuay = (d.luotQuay or 0) + n
  -- Chua co the nao thi rut ngay.
  if d.quay == nil then rutThe(pid) end
  -- Mo khung NGAY. Day la cho duy nhat khung tu bat len.
  if API.quayFrameShow ~= nil then API.quayFrameShow(pid) end
end

-- ---------- Nhan the ----------
-- Chay tren MOI may, tu kenh dong bo.

local function nhan(pid, i)
  local d = S.p[pid]
  if d == nil or d.quay == nil then return end
  if (d.luotQuay or 0) <= 0 then return end
  local the = d.quay[i]
  if the == nil then return end

  if the.loai == "da" then
    d.da = (d.da or 0) + the.so

  elseif the.loai == "chiso" then
    -- Cong vao bang CONG DON rieng, khong dat thang chi so hero:
    -- heroRecompute la cho DUY NHAT duoc ghi chi so, va no ghi de moi
    -- lan chay. Dat thang o day la lan sau recompute xoa mat.
    d.quayChiSo = d.quayChiSo or { str = 0, agi = 0, int = 0 }
    d.quayChiSo[the.chi] = (d.quayChiSo[the.chi] or 0) + the.so
    if API.heroRecompute ~= nil then API.heroRecompute(pid) end

  elseif the.loai == "vang" then
    API.addVang(pid, the.so)
  end

  API.msg(pid, API.t("quay_nhan", CFG.C_JADE .. API.quayMoTa(the) .. CFG.C_END))

  d.luotQuay = d.luotQuay - 1
  if d.luotQuay > 0 then
    rutThe(pid)
    if API.quayFrameRefresh ~= nil then API.quayFrameRefresh(pid) end
  else
    d.quay = nil
    if API.quayFrameHide ~= nil then API.quayFrameHide(pid) end
  end
  API.panelRefresh(pid)
end

-- ---------- Chu cho tung the ----------

local function moTa(the)
  if the == nil then return "" end
  if the.loai == "da" then
    return API.num(the.so) .. " " .. API.t("cur_da")
  elseif the.loai == "chiso" then
    return "+" .. API.num(the.so) .. " " .. API.t("stat_" .. the.chi)
  end
  return "+" .. API.num(the.so) .. " " .. API.t("cur_vang")
end

-- Icon KHONG go duong dan tay nua.
--
-- Da doan sai ba lan: BTNRingViolet (o xanh la), BTNStrength (o xanh
-- la), BTNGoldmine (ra cai NHA chu khong phai dong tien). Duong dan
-- texture khong liet ke duoc tu ngoai -- game dong goi bang CASC.
--
-- Nen DOC tu chinh doi tuong cua game, giong cach 8_shop.lua lam:
--   BlzGetAbilityIcon(id)  icon that cua mot ability
--   BlzGetItemIconPath(it) icon that cua mot item vua tao
--
-- Gia tri ban dau chi la duong LUI: chung deu la duong dan DA CHUNG
-- MINH la ve ra hinh (dang dung o the Trang Bi), nen sai lam thi ra
-- icon khong hop nghia chu KHONG BAO GIO ra o xanh la nua.
local ICON = {
  da    = [[ReplaceableTextures\CommandButtons\BTNStaffOfSanctuary.blp]],
  chiso = [[ReplaceableTextures\CommandButtons\BTNSteelMelee.blp]],
  vang  = [[ReplaceableTextures\CommandButtons\BTNTalisman.blp]],
}

-- Do icon that luc vao map. Moi muc: { khoa, ma item de thu, ability
-- de lui ve }.
local function probeIcons()
  -- 1. Chi so: lay tu chinh ability Luyen The (A004). Chac chan co --
  --    no dang ve ra hinh o the Ky Nang.
  if BlzGetAbilityIcon ~= nil then
    local p = BlzGetAbilityIcon(FourCC("A004"))
    if p ~= nil and p ~= "" then ICON.chiso = p end
  end

  -- 2. Vang va da: thu tao item roi doc icon that cua no.
  --    CreateItem tra nil khi ma khong ton tai -> giu duong lui va GHI
  --    VET, khong nuot im.
  if CreateItem ~= nil and BlzGetItemIconPath ~= nil then
    local thu = { { "vang", "gold" }, { "da", "ingt" } }
    for i = 1, #thu do
      local khoa, ma = thu[i][1], thu[i][2]
      local it = CreateItem(FourCC(ma), 0.0, 0.0)
      if it == nil then
        API.trace("quay: khong co item '" .. ma .. "', giu icon lui cho " .. khoa)
      else
        local p = BlzGetItemIconPath(it)
        if p ~= nil and p ~= "" then ICON[khoa] = p end
        RemoveItem(it)
      end
    end
  end

  for k, v in pairs(ICON) do
    API.trace("quay: icon " .. k .. " = " .. tostring(v))
  end
end

-- ---------- Giao dien ----------
--
-- KHONG con la mot the trong bang. Khung rieng, ba cot doc, mo NGAY khi
-- tinh anh/boss chet -- xem 4_giao_dien/5_quayframe.lua.

local function conLuot(pid)
  local d = S.p[pid]
  return d ~= nil and (d.luotQuay or 0) > 0 and d.quay ~= nil
end

local function theCua(pid)
  local d = S.p[pid]
  return (d ~= nil) and d.quay or nil
end

local function soLuot(pid)
  local d = S.p[pid]
  return (d ~= nil) and (d.luotQuay or 0) or 0
end

local function startQuay()
  probeIcons()
  API.syncOn(CFG.OP_QUAY, nhan)
  API.trace("quay: san sang")
end

API.quayThemLuot = themLuot
API.quayMoTa     = moTa
API.quayNhan     = nhan
API.quayConLuot  = conLuot
API.quayThe      = theCua
API.quaySoLuot   = soLuot
API.quayIcon     = function(loai) return ICON[loai] end
API.startQuay    = startQuay
