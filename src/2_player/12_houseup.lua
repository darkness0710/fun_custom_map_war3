-- ============================================================
--  12_houseup.lua  --  Nang cap Nha Chinh, tra bang VANG
--
--  Mo bang bang phim ESC -> the VI -> Kien Co (cong Suc Manh).
--
--  DA THU rieng mot duong "bam chuot vao Nha Chinh thi mo the VI"
--  (EVENT_PLAYER_UNIT_SELECTED) roi BO: mot phim ESC da du, va mot cua
--  vao nua la them mot hang so co the vang mat o 1.31.1 cho khong duoc
--  gi. Cung dot do bo luon "Hoi Phuc" (trung viec voi
--  HOUSE_REGEN_PER_WAVE) va "Phan Sat" (mot trigger sat thuong toan cuc
--  cho mot hieu ung nho). Can lam lai thi xem git log file nay.
--
--  BA DIEU PHAI NHO KHI SUA FILE NAY:
--
--  1. CAP LA CUA CHUNG, khong phai cua tung nguoi. Nha chinh chi co
--     MOT, nen S.houseUp la mot bang duy nhat chu khong nam trong
--     S.p[pid]. Mot nguoi mua, ca doi huong -- cung ly do voi hai Phap
--     Khi "nhahp"/"nharegen".
--
--     Luu cap vao S.p[pid] thi hai nguoi cung mua se thanh hai bo cap
--     rieng, ma nha thi chi co mot -- cai nao thang la tuy thu tu goi.
--     Loi im lang, kinh dien.
--
--  2. KHONG tu dat mau nha. rescaleHouse() trong 2_wave.lua chay lai
--     MOI WAVE va tinh lai max tu dau. Goi BlzSetUnitMaxHP o day thi
--     wave sau xoa sach. Duong duy nhat dung la de rescaleHouse hoi
--     nguoc qua API.houseUpStr().
--
--  3. SO DIEM PHAI LEO THEO CANH GIOI (ADR 0024: cong thi leo, nhan
--     thi phang). Mau nha bam theo duong cong quai, nen mot con so diem
--     PHANG se thanh vo nghia o canh gioi 10. Nhan voi
--     CULT_STAT_STEP^(bac-1) y het cach Trang Bi cong diem.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Cap hien tai cua mot duong.
local function levelOf(code)
  if S.houseUp == nil then return 0 end
  return S.houseUp[code] or 0
end

-- Canh gioi CAO NHAT trong doi.
--
-- Nha la cua chung nen lay nguoi di xa nhat lam moc, khong lay trung
-- binh: trung binh thi them mot nguoi moi vao la nha YEU DI, va do la
-- mot luat khong ai doan duoc.
local function topRank()
  local r = 1
  if API.cultRank == nil then return r end
  for i = 1, #S.pids do
    local k = API.cultRank(S.pids[i]) or 1
    if k > r then r = k end
  end
  return r
end

-- Tong diem Suc Manh dang cong cho nha.
--
-- Doc-luc-dung: 2_wave.lua goi ham nay moi wave va luc mua, khong co
-- bang dieu phoi nao ca.
local function strTotal()
  local up = (CFG.HOUSE_UP or {})[1]
  if up == nil then return 0 end
  local lv = levelOf(up.code)
  if lv <= 0 then return 0 end
  local step = CFG.CULT_STAT_STEP or 1.30
  return math.floor(lv * (up.str or 0) * step ^ (topRank() - 1) + 0.5)
end

-- Gia de len cap TIEP THEO. Tra nil khi da kich tran -- nil o day co
-- nghia "khong mua duoc nua", khac han voi 0 ("mua duoc, mien phi").
local function priceOf(code)
  local lv = levelOf(code)
  if lv >= (CFG.HOUSE_UP_MAX or 10) then return nil end
  local p0 = CFG.HOUSE_UP_PRICE0 or 300
  local st = CFG.HOUSE_UP_STEP or 1.45
  return math.floor(p0 * st ^ lv + 0.5)
end

-- ---------- Bao nhieu mau mot diem Suc Manh ----------
--
-- DO tren chinh con nha chinh luc vao map, khong go hang so: nha da di
-- qua BlzSetUnitMaxHP luc tao, va khong co gi bao dam Warcraft con cho
-- Suc Manh doi max nua. Do mot lan thi biet chac.
--
-- Do xong TRA LAI nguyen trang. Thu tu: doc goc -> day len -> doc lai
-- -> dat ve. Neu max khong nhuc nhich thi khong do duoc, va luc do lui
-- ve CFG.HOUSE_UP_STR_HP -- co bao ra, khong nuot.
local function probeHpPerStr()
  if S.house == nil or GetHeroStr == nil or SetHeroStr == nil then return nil end
  local s0 = GetHeroStr(S.house, false)
  local h0 = GetUnitState(S.house, UNIT_STATE_MAX_LIFE)
  SetHeroStr(S.house, s0 + 100, true)
  local h1 = GetUnitState(S.house, UNIT_STATE_MAX_LIFE)
  SetHeroStr(S.house, s0, true)
  if h1 <= h0 then return nil end
  return (h1 - h0) / 100.0
end

local function hpPerStr()
  return S.houseStrHp or CFG.HOUSE_UP_STR_HP or 25.0
end

-- ---------- Mua ----------
--
-- Chay tren MOI may qua syncOn. Kiem lai dieu kien o day chu khong tin
-- cu bam: ben gui la cuc bo.
local function buy(pid, i)
  local up = (CFG.HOUSE_UP or {})[i]
  if up == nil then return end

  local price = priceOf(up.code)
  if price == nil then
    API.msg(pid, CFG.C_GREY .. API.t("hu_max", API.pick(up)) .. CFG.C_END)
    return
  end
  if not API.spendGold(pid, price) then
    API.msg(pid, CFG.C_RED .. API.t("no_gold") .. CFG.C_END ..
      API.t("need_have", API.num(price), API.num(API.getGold(pid))))
    API.panelRefresh(pid)
    return
  end

  if S.houseUp == nil then S.houseUp = {} end
  S.houseUp[up.code] = levelOf(up.code) + 1

  -- Mau doi NGAY, khong doi wave sau.
  --
  -- Mua giua mot wave dang bi don ma phai cho het wave moi thay gi la
  -- mua trong bong toi -- va dung luc do thi nguoi choi can no ngay.
  if API.waveRescaleHouse ~= nil then API.waveRescaleHouse() end

  -- Tin CHUNG: nha la cua ca doi nen ca doi phai biet no vua day len
  -- bao nhieu, va biet ai tra tien.
  API.say(pid, API.t("hu_bought", CFG.C_JADE .. API.pick(up) .. CFG.C_END,
                     levelOf(up.code), CFG.HOUSE_UP_MAX or 10,
                     API.num(strTotal())))
  API.panelRefreshAll()
  API.trace("houseup: " .. up.code .. " -> cap " .. levelOf(up.code) ..
            ", tong " .. strTotal() .. " Str (canh gioi " .. topRank() ..
            ", " .. string.format("%.1f", hpPerStr()) .. " mau/diem)" ..
            " -- pid " .. pid .. " tra " .. price .. " vang")
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local gold = API.getGold(pid)
  local out  = {}
  for i = 1, #(CFG.HOUSE_UP or {}) do
    local up    = CFG.HOUSE_UP[i]
    local lv    = levelOf(up.code)
    local max   = CFG.HOUSE_UP_MAX or 10
    local price = priceOf(up.code)

    -- Mo ta NOI GIA TRI DANG CO, khong noi "moi cap +40 diem". Nguoi
    -- choi can biet minh dang duoc bao nhieu, chu khong phai tu nhan
    -- trong dau. Cap 0 thi hien 0 -- van la mot cau tra loi.
    local it = {
      icon   = up.icon,
      name   = API.pick(up),
      -- desc_vi/desc_en la DU LIEU trong bang, khong phai khoa i18n --
      -- cung quy uoc voi CFG.HEROES (xem 2_heroframe.lua:258).
      desc   = string.format(
                 (API.lang() == "en" and up.desc_en) or up.desc_vi or "%s",
                 CFG.C_JADE .. API.num(strTotal()) .. CFG.C_END),
      status = CFG.C_GREY .. lv .. "/" .. max .. CFG.C_END,
    }

    if price == nil then
      it.status = CFG.C_GOLD .. lv .. "/" .. max .. CFG.C_END
      -- Noi vao 'desc' chu KHONG vao 'note': than kieu "list" chi ve
      -- icon/name/status/desc/btn -- 'note' la cua kieu "focus" va
      -- kieu "grid". Dat vao note thi o kich tran se trong khong co nut
      -- lan khong co chu.
      it.desc = it.desc .. "   " .. CFG.C_GOLD ..
                API.t("hu_note_max") .. CFG.C_END
    else
      it.btn   = API.t("btn_upgrade") .. "  " .. API.num(price) ..
                 " " .. API.t("cur_gold")
      it.btnOn = (gold >= price)
    end
    out[i] = it
  end
  return out
end

local function tabItemAction(pid, i)
  API.syncSend(pid, CFG.OP_HOUSE_UP, i)
end

-- ---------- Khoi dong ----------

local function startHouseUp()
  S.houseUp = {}

  S.houseStrHp = probeHpPerStr()
  if S.houseStrHp == nil then
    API.trace("houseup: KHONG do duoc mau moi diem Str tren nha chinh " ..
              "(BlzSetUnitMaxHP co the da khoa max) -- lui ve " ..
              (CFG.HOUSE_UP_STR_HP or 25.0))
  end

  API.panelAddTab({
    name       = API.t("panel_house"),
    kind       = "list",
    rows       = #(CFG.HOUSE_UP or {}),
    items      = tabItems,
    itemAction = tabItemAction,
    empty      = API.t("hu_empty"),
  })

  API.syncOn(CFG.OP_HOUSE_UP, buy)

  API.trace("houseup: " .. #(CFG.HOUSE_UP or {}) .. " duong, tran cap " ..
            (CFG.HOUSE_UP_MAX or 10) .. ", gia dau " ..
            (CFG.HOUSE_UP_PRICE0 or 300) .. " x " ..
            (CFG.HOUSE_UP_STEP or 1.45) .. "^n, " ..
            string.format("%.1f", hpPerStr()) .. " mau/diem Str")
end

API.houseUpStr   = strTotal
API.houseUpStrHp = hpPerStr
API.houseUpLevel = levelOf
API.startHouseUp = startHouseUp
