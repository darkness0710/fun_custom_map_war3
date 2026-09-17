-- ============================================================
--  10_quay.lua  --  The VI: Quay thuong
--
--  Giet tinh anh 1 luot, boss 3 luot. Moi luot mo BA the, chon MOT.
--
--    the 1  10 da Huyen Thiet, phang
--    the 2  +V vao MOT chi so ngau nhien trong ba
--    the 3  vang, V x CFG.QUAY_VANG_MOI_DIEM
--
--  V = CFG.QUAY_GIA_TRI x LINHCAN_STAT_STEP^(bac-1), ngau nhien +-30%.
--  Dung CHINH buoc cua Tu Vi nen quay tu bam theo -- doi duong cong Tu
--  Vi thi quay tu co theo.
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
    { loai = "vang", so = math.floor(v * CFG.QUAY_VANG_MOI_DIEM + 0.5) },
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

local ICON = {
  da    = [[ReplaceableTextures\CommandButtons\BTNStaffOfSanctuary.blp]],
  chiso = [[ReplaceableTextures\CommandButtons\BTNStrength.blp]],
  vang  = [[ReplaceableTextures\CommandButtons\BTNGoldmine.blp]],
}

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
