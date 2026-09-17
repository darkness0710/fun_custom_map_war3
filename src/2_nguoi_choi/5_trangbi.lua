-- ============================================================
--  5_trangbi.lua  --  Sau mon, moi mon tien hoa 100 bac
--
--  Moi mon di 20 canh gioi x 5 cap. TRAN la TU VI cua nguoi choi.
--  Luat day du: docs/02-he-thong/trang-bi-kiem.md  ·  ADR 0021
--
--    (0,0)  "Kiem"                      <- tho, chua luyen
--      LUYEN  1 da, 100%
--    (1,1)  "Kiem Pham Nhan - So Cap"
--      LUYEN  1 da, 75% / 50% / 25% / 15%
--    (1,5)  "Kiem Pham Nhan - Hoan Hao"
--      TIEN GIAI  10 da, 100%, doi Tu Vi >= canh gioi 2
--    (2,1)  "Kiem Luyen Khi - So Cap"
--      ...
--
--  CHI SO CON RONG -- 2026-09-17. Khung chay day du nhung chua mon nao
--  cong gi. Cho do chi so se nam la API.trangBiMult / trangBiChiSo ben
--  duoi; chung dang tra ve 1.0 va 0.
--
--  NGAU NHIEN PHAI NAM TRONG HAM NHAN TU KENH DONG BO. Bam frame chi no
--  tren may nguoi bam; goi GetRandomInt o do la moi may tieu mot so khac
--  nhau tu chuoi ngau nhien, va TU GIAY DO moi so ngau nhien cua ca van
--  deu lech -- ke ca the Co Duyen. Xem dau 10_quay.lua.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function monCount() return #CFG.TRANGBI end
local function capMax()   return #CFG.TRANGBI_CAP end
local function canhMax()  return #CFG.REALMS end

-- Trang thai mot mon: { canh = 0..20, cap = 0..5 }.
-- canh = 0 nghia la chua luyen lan nao.
local function stOf(pid, i)
  local d = S.p[pid]
  if d == nil then return nil end
  if d.tb == nil then d.tb = {} end
  if d.tb[i] == nil then d.tb[i] = { canh = 0, cap = 0 } end
  return d.tb[i]
end

-- ---------- Ten ----------

local function capName(c)
  local t = CFG.TRANGBI_CAP[c]
  return (t ~= nil) and API.pick(t) or tostring(c)
end

local function canhName(r)
  local t = CFG.REALMS[r]
  return (t ~= nil) and API.pick(t) or tostring(r)
end

-- "Kiem"  hoac  "Kiem Pham Nhan - So Cap"
local function tenDayDu(pid, i)
  local mon = CFG.TRANGBI[i]
  if mon == nil then return "?" end
  local base = API.pick(mon)
  local st = stOf(pid, i)
  if st == nil or st.canh <= 0 then return base end
  return base .. " " .. canhName(st.canh) .. " - " .. capName(st.cap)
end

-- ---------- Hoi trang thai ----------

-- Luyen duoc khong: chua toi Hoan Hao la duoc.
local function coTheLuyen(pid, i)
  local st = stOf(pid, i)
  return (st ~= nil) and (st.cap < capMax())
end

-- Tien Giai duoc khong. BA dieu kien, va dieu kien thu ba la cho cai
-- tran Tu Vi thuc su co hieu luc.
local function coTheTien(pid, i)
  local st = stOf(pid, i)
  if st == nil then return false end
  if st.cap < capMax() then return false end          -- chua Hoan Hao
  if st.canh >= canhMax() then return false end       -- da het canh gioi
  local bac = (API.linhCanRank ~= nil) and API.linhCanRank(pid) or 1
  return bac >= st.canh + 1                            -- Tu Vi da toi chua
end

-- Xac suat cua lan luyen KE TIEP, dang 0..1.
local function xsTiep(pid, i)
  local st = stOf(pid, i)
  if st == nil then return 0.0 end
  return CFG.TRANGBI_XS[st.cap + 1] or 0.0
end

-- ---------- Luyen ----------
-- Chay tren MOI may, tu kenh dong bo.

local function luyen(pid, i)
  local mon = CFG.TRANGBI[i]
  if mon == nil then return end
  if not coTheLuyen(pid, i) then return end

  if not API.spendDa(pid, CFG.TRANGBI_GIA) then
    API.msg(pid, CFG.C_RED .. API.t("no_da") .. CFG.C_END ..
      API.t("need_have", API.num(CFG.TRANGBI_GIA), API.num(API.getDa(pid))))
    API.panelRefresh(pid)
    return
  end

  local st = stOf(pid, i)
  local pct = math.floor(xsTiep(pid, i) * 100.0 + 0.5)

  -- GetRandomInt o DAY moi dung: ham nay chay tren moi may, cung thu tu.
  if GetRandomInt(1, 100) <= pct then
    st.cap = st.cap + 1
    if st.canh <= 0 then st.canh = 1 end   -- lan dau: vao canh gioi 1

    local ten = CFG.C_JADE .. tenDayDu(pid, i) .. CFG.C_END
    local ai  = CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END
    -- Bao cho CA DOI khi cham hai cap cuoi: ba nguoi cung leo mot thang
    -- thi viec so nhau chinh la noi dung. Cap thap thi bao rieng, neu
    -- khong ca van se co 300 dong khoe cap So Cap.
    API.msg((st.cap >= capMax() - 1) and nil or pid,
            API.t("tb_thanh", ai, ten))

    if S.p[pid] ~= nil and S.p[pid].hero ~= nil then
      API.fx([[Abilities\Spells\Items\AIem\AIemTarget.mdl]],
             GetUnitX(S.p[pid].hero), GetUnitY(S.p[pid].hero))
    end
  else
    API.msg(pid, CFG.C_RED .. API.t("tb_truot", pct) .. CFG.C_END)
  end

  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.panelRefresh(pid)
end

-- ---------- Tien Giai ----------
-- Chay tren MOI may. KHONG co xac suat: no la mot CUA, khong phai canh
-- bac chong len canh bac. Va no bao gom luon lan len "So Cap" cua canh
-- gioi moi (von 100%), de khong co mot cu bam chac chan thua.

local function tienGiai(pid, i)
  local mon = CFG.TRANGBI[i]
  if mon == nil then return end
  if not coTheTien(pid, i) then return end

  if not API.spendDa(pid, CFG.TRANGBI_TIEN_GIAI) then
    API.msg(pid, CFG.C_RED .. API.t("no_da") .. CFG.C_END ..
      API.t("need_have", API.num(CFG.TRANGBI_TIEN_GIAI), API.num(API.getDa(pid))))
    API.panelRefresh(pid)
    return
  end

  local st = stOf(pid, i)
  st.canh = st.canh + 1
  st.cap  = 1

  API.msg(nil, API.t("tb_tien_xong",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. tenDayDu(pid, i) .. CFG.C_END))

  if S.p[pid] ~= nil and S.p[pid].hero ~= nil then
    API.fx([[Abilities\Spells\Human\Resurrect\ResurrectTarget.mdl]],
           GetUnitX(S.p[pid].hero), GetUnitY(S.p[pid].hero))
  end

  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.panelRefresh(pid)
end

-- ---------- CHO DAT CHI SO ----------
--
-- CON RONG CO Y. Ca hai ham duoi day la cho chi so se nam khi chot
-- xong. Giu chung ton tai ngay tu bay gio de noi goi san co (7_hieuung)
-- khong phai sua lai khi do.
--
-- RANG BUOC da biet khi thiet ke phan chi so:
--   1. Suc manh phai bam CANH GIOI, khong bam so bac tuyet doi -- neu
--      khong thi cai tran Tu Vi mat tac dung bao ve (ADR 0021).
--   2. Mot cap o canh gioi 20 phai dang hon mot cap o canh gioi 1. Nho
--      vay the 1 Co Duyen phang (3 da) van can duoc the 2 leo x1.30:
--      da phang, nhung thu da mua duoc thi leo.
--   3. Cap Hoan Hao ngon 6.67 trong tong 15 lan thu cua ca canh gioi --
--      gan mot nua ngan sach cho rieng mot cap. No phai dang.

local function multOf(pid)       -- nhan so sat thuong
  return 1.0
end

local function chiSoOf(pid)      -- cong them chi so
  return 0
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local da  = API.getDa(pid)
  local out = {}
  for i = 1, monCount() do
    local mon = CFG.TRANGBI[i]
    local st  = stOf(pid, i)
    local it  = { icon = mon.icon, ten = tenDayDu(pid, i) }

    if st.canh <= 0 then
      it.trangThai = CFG.C_GREY .. API.t("tb_chua_luyen") .. CFG.C_END
    else
      it.trangThai = CFG.C_GREY .. st.cap .. "/" .. capMax() .. CFG.C_END
    end

    if coTheLuyen(pid, i) then
      local pct = math.floor(xsTiep(pid, i) * 100.0 + 0.5)
      it.mota   = API.t("tb_len", capName(st.cap + 1), pct)
      it.nut    = API.t("tb_nut_nang") .. "  " .. API.num(CFG.TRANGBI_GIA)
      it.batNut = (da >= CFG.TRANGBI_GIA)

    elseif st.canh >= canhMax() then
      it.mota   = CFG.C_JADE .. API.t("tb_max") .. CFG.C_END

    elseif coTheTien(pid, i) then
      it.mota   = API.t("tb_can_tien")
      it.nut    = API.t("tb_nut_tien") .. "  " .. API.num(CFG.TRANGBI_TIEN_GIAI)
      it.batNut = (da >= CFG.TRANGBI_TIEN_GIAI)

    else
      -- Hoan Hao roi nhung Tu Vi chua toi. Day la luc cai TRAN hien ra,
      -- va no phai noi RO dang cho gi -- khong co nut ma khong giai
      -- thich thi nguoi choi tuong giao dien hong.
      it.mota = CFG.C_GREY .. API.t("tb_tran", canhName(st.canh + 1)) .. CFG.C_END
    end

    out[i] = it
  end
  return out
end

-- Mot nut, hai viec: truoc Hoan Hao thi Luyen, den Hoan Hao thi Tien
-- Giai. Quyet dinh o day la CUC BO nhung an toan, vi trang thai dua vao
-- (st.cap) da dong bo san -- va ca hai nhanh deu kiem lai dieu kien o
-- ben nhan.
local function tabItemAction(pid, i)
  if CFG.TRANGBI[i] == nil then return end
  if coTheLuyen(pid, i) then
    API.syncSend(pid, CFG.OP_TB_UP, i)
  elseif coTheTien(pid, i) then
    API.syncSend(pid, CFG.OP_TB_TIEN, i)
  end
end

local function startTrangBi()
  API.panelAddTab({
    ten        = API.t("panel_gear"),
    kind       = "list",
    soMuc      = monCount(),
    items      = tabItems,
    itemAction = tabItemAction,
  })
  API.syncOn(CFG.OP_TB_UP,   luyen)
  API.syncOn(CFG.OP_TB_TIEN, tienGiai)
  API.trace("trangbi: " .. monCount() .. " mon x " .. canhMax() .. " canh gioi x " ..
            capMax() .. " cap, the san sang (chi so con rong)")
end

API.trangBiTen     = tenDayDu
API.trangBiCanh    = function(pid, i) local st = stOf(pid, i); return st and st.canh or 0 end
API.trangBiCap     = function(pid, i) local st = stOf(pid, i); return st and st.cap  or 0 end
API.trangBiMult    = multOf
API.trangBiChiSo   = chiSoOf
API.startTrangBi   = startTrangBi
