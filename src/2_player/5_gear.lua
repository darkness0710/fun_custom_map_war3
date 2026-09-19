-- ============================================================
--  5_gear.lua  --  Sau mon, moi mon tien hoa 100 bac
--
--  Moi mon di 20 canh gioi x 5 cap. TRAN la TU VI cua nguoi choi.
--  Luat day du: docs/02-he-thong/trang-bi-kiem.md  |  ADR 0021
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
--  BAY MON, MOI MON MOT VAI -- 2026-09-18:
--    Mu    Int           Day Chuyen  ca ba      Ao   Str
--    Giay  Agi           Kiem  %sat thuong gay ra (ke ca hoi mau)
--    Khien %giam don danh nhan vao   Ao Choang %giam phep nhan vao
--  Bon mon cong diem thi LEO theo Tu Vi, ba mon nhan % thi PHANG.
--  Xem muc "CHI SO" ben duoi va CFG.GEAR_STAT_BASE.
--
--  NGAU NHIEN PHAI NAM TRONG HAM NHAN TU KENH DONG BO. Bam frame chi no
--  tren may nguoi bam; goi GetRandomInt o do la moi may tieu mot so khac
--  nhau tu chuoi ngau nhien, va TU GIAY DO moi so ngau nhien cua ca van
--  deu lech -- ke ca the Co Duyen. Xem dau 10_fortune.lua.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function itemCount() return #CFG.GEAR end
local function levelMax()   return #CFG.GEAR_CAP end
local function tierMax()  return #CFG.REALMS end

-- Trang thai mot mon: { canh = 0..20, cap = 0..5 }.
-- canh = 0 nghia la chua luyen lan nao.
local function stOf(pid, i)
  local d = S.p[pid]
  if d == nil then return nil end
  if d.gear == nil then d.gear = {} end
  if d.gear[i] == nil then d.gear[i] = { tier = 0, level = 0 } end
  return d.gear[i]
end

-- ---------- Ten ----------

local function levelNameOf(c)
  local t = CFG.GEAR_CAP[c]
  return (t ~= nil) and API.pick(t) or tostring(c)
end

-- Ten canh gioi, cho dong "can canh gioi X" cua o Canh.
local function realmNameOf(r)
  local t = CFG.REALMS[r]
  return (t ~= nil) and API.pick(t) or tostring(r)
end

local function tierNameOf(r)
  local t = CFG.REALMS[r]
  return (t ~= nil) and API.pick(t) or tostring(r)
end

-- "Kiem"  hoac  "Kiem Pham Nhan - So Cap"
local function fullName(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return "?" end
  local base = API.pick(item)
  local st = stOf(pid, i)
  if st == nil or st.tier <= 0 then return base end
  -- CANH GIOI DUNG TRUOC: "Pham Nhan Kiem - So Cap", khong phai
  -- "Kiem Pham Nhan - So Cap". Tieng Viet dat dinh ngu canh gioi len
  -- dau moi ra ten do tu tien; ban tieng Anh cung dung the ("Mortal
  -- Sword - Basic").
  return tierNameOf(st.tier) .. " " .. base .. " - " .. levelNameOf(st.level)
end

-- ---------- Hoi trang thai ----------

-- Luyen duoc khong: chua toi Hoan Hao la duoc.
local function canRefine(pid, i)
  local st = stOf(pid, i)
  return (st ~= nil) and (st.level < levelMax())
end

-- Tien Giai duoc khong. BA dieu kien, va dieu kien thu ba la cho cai
-- tran Tu Vi thuc su co hieu luc.
local function canEvolve(pid, i)
  local st = stOf(pid, i)
  if st == nil then return false end
  if st.level < levelMax() then return false end          -- chua Hoan Hao
  if st.tier >= tierMax() then return false end       -- da het canh gioi
  local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
  return rank >= st.tier + 1                            -- Tu Vi da toi chua
end

-- Xac suat cua lan luyen KE TIEP, dang 0..1.
local function nextOdds(pid, i)
  local st = stOf(pid, i)
  if st == nil then return 0.0 end
  return CFG.GEAR_ODDS[st.level + 1] or 0.0
end

-- Chi phi KY VONG tu cap hien tai len Hoan Hao: tong 1/p cua cac cap
-- con lai. Ghi len nut de nguoi choi biet minh dat bao nhieu TRUOC khi
-- bam -- mot cu bam gio tieu nhieu vien chu khong mot vien.
local function expectedCost(pid, i)
  local st = stOf(pid, i)
  if st == nil then return 0 end
  local sum = 0.0
  for k = st.level + 1, levelMax() do
    local p = CFG.GEAR_ODDS[k]
    -- Odds thieu hoac bang 0 la CFG hong, khong phai "kho". Bao ra chu
    -- khong tra mot con so doan.
    if p == nil or p <= 0.0 then
      API.trace("gear: GEAR_ODDS[" .. k .. "] = " .. tostring(p) ..
                " -- khong tinh duoc chi phi ky vong")
      return 0
    end
    sum = sum + 1.0 / p
  end
  return math.floor(sum * CFG.GEAR_PRICE + 0.5)
end

-- ---------- O tich "luyen gop / luyen le" ----------
--
-- CUC BO, khong dong bo, va khong duoc phep dong bo: no chi doi (a) chu
-- tren nut o may nay va (b) op nao duoc gui di. Ca hai deu la viec cuc
-- bo -- click frame chi no o may nguoi bam, va ben NHAN op moi la cho
-- doi trang thai that.
--
-- Vi the no khong nam trong S.p: mot truong trong trang thai da dong bo
-- ma chi dung o mot may la cai bay cho nguoi doc sau.
local allIn = {}

-- BAT san. Nguoi choi bao moi tay truoc khi bao thieu da, nen gop phai
-- la mac dinh; tick la de TAT, khong phai de bat.
local function isAllIn(pid)
  return allIn[pid] ~= false
end

-- ---------- Luyen ----------
-- Chay tren MOI may, tu kenh dong bo.
--
-- MOT lan bam = luyen LIEN TIEP toi Hoan Hao, hoac toi khi het da.
--
-- Vi sao gop chu khong de bam le: bam le KHONG phai mot quyet dinh.
-- That bai khong phat gi ngoai vien da va ti le thi co dinh -- nen nhin
-- mot lan that bai khong cho nguoi choi thong tin nao de doi y. 15 lan
-- bam chi la 15 lan bam. Quyet dinh that la DON DA VAO MON NAO, va cho
-- do van con nguyen.
--
-- Dung o Hoan Hao vi do la ranh gioi CO SAN trong thiet ke: qua no phai
-- Tien Giai, mot cua 10 da gac boi Tu Vi. Tuc la dung dung cho nguoi
-- choi buoc phai quyet dinh lai.
--
-- Do duoc: 99% so lan bam ton <= 39 vien, trung binh 15 -- tren ngan
-- sach ~420 vien ca van thi mot cu bam xau nhat an 9%. Co tran, va tran
-- do la cai canh gioi chu khong phai cai kho da.
local function refine(pid, i, once)
  local item = CFG.GEAR[i]
  if item == nil then return end
  if not canRefine(pid, i) then return end

  local st = stOf(pid, i)

  -- Phan hoi nam tren CAI O VUA BAM, khong o con hero.
  --
  -- Ban truoc ve mot hieu ung duoi chan hero: luc bam LUYEN mat nguoi
  -- choi dang o bang, ma con hero thi dang bi chinh cai bang che -- ve
  -- o do la ve vao cho khong ai nhin.
  local function flash(kind)
    if API.panelGearFlash ~= nil then API.panelGearFlash(pid, i, kind) end
  end

  local from, tries, spent, poor = st.level, 0, 0, false
  local lastPct = 0

  -- Chan vong lap. Da la huu han nen vong nay tu het, nhung mot
  -- CFG.GEAR_ODDS go sai se bien no thanh cai bom hut sach kho da ma
  -- khong bao gi. Chan cung, va TRACE khi cham -- khong nuot.
  local GUARD = 1000

  while canRefine(pid, i) do
    if tries >= GUARD then
      API.trace("gear: refine cham tran " .. GUARD .. " lan (pid " .. pid ..
                ", mon " .. i .. ") -- kiem lai CFG.GEAR_ODDS")
      break
    end
    if not API.spendIron(pid, CFG.GEAR_PRICE) then
      poor = true
      break
    end
    spent = spent + CFG.GEAR_PRICE
    tries = tries + 1

    -- GetRandomInt o DAY moi dung: ham nay chay tren MOI may, va ca so
    -- da lan cap deu la trang thai da dong bo -- nen vong lap quay dung
    -- bay nhieu lan, dung thu tu, o moi may.
    local pct = math.floor(nextOdds(pid, i) * 100.0 + 0.5)
    lastPct = pct
    if GetRandomInt(1, 100) <= pct then
      st.level = st.level + 1
      if st.tier <= 0 then st.tier = 1 end   -- lan dau: vao canh gioi 1
    end

    if once then break end
  end

  local name = CFG.C_JADE .. fullName(pid, i) .. CFG.C_END

  if tries == 0 then
    API.msg(pid, CFG.C_RED .. API.t("no_iron") .. CFG.C_END ..
      API.t("need_have", API.num(CFG.GEAR_PRICE), API.num(API.getIron(pid))))
    flash("fail")
  else
    local up  = (st.level > from)
    local top = (st.level >= levelMax())
    if once then
      -- Bam le: bao y NHU CU -- mot lan quay, mot cau. Doi sang dong
      -- tong ket o day thi "Luyen 1 lan, ton 1 da" khong noi duoc rang
      -- no THAT BAI.
      if up then
        API.say(pid, API.t("gear_became", name))
      else
        API.msg(pid, CFG.C_RED .. API.t("gear_failed", lastPct) .. CFG.C_END)
      end
    else
      -- Bam gop: MOT dong tong ket thay cho 15 dong "that bai". Nguoi
      -- choi can biet CAI GIA da tra, khong can nhat ky tung lan quay.
      --
      -- Dong nay di CHUNG ca doi. Truoc day chi cham Hoan Hao moi bao
      -- chung, con lai bao rieng -- nhung mot van nhieu nguoi thi viec
      -- so nhau chinh la noi dung, va gear_batch da noi ket qua cuoi
      -- ("gio la %s") nen khong can them dong moc rieng nua.
      API.say(pid, API.t("gear_batch", tries, API.num(spent), name))
    end

    flash((not up) and "fail" or (top and "big" or "ok"))

    if poor then
      API.msg(pid, CFG.C_RED .. API.t("no_iron") .. CFG.C_END)
    end
  end

  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.panelRefresh(pid)
end

-- ---------- Tien Giai ----------
-- Chay tren MOI may. KHONG co xac suat: no la mot CUA, khong phai canh
-- bac chong len canh bac. Va no bao gom luon lan len "So Cap" cua canh
-- gioi moi (von 100%), de khong co mot cu bam chac chan thua.

local function dismantle(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return end
  if not canEvolve(pid, i) then return end

  if not API.spendIron(pid, CFG.GEAR_DISMANTLE) then
    API.msg(pid, CFG.C_RED .. API.t("no_iron") .. CFG.C_END ..
      API.t("need_have", API.num(CFG.GEAR_DISMANTLE), API.num(API.getIron(pid))))
    API.panelRefresh(pid)
    return
  end

  local st = stOf(pid, i)
  st.tier = st.tier + 1
  st.level  = 1

  API.say(pid, API.t("gear_dismantled",
    CFG.C_JADE .. fullName(pid, i) .. CFG.C_END))

  if S.p[pid] ~= nil and S.p[pid].hero ~= nil then
    API.fx([[Abilities\Spells\Human\Resurrect\ResurrectTarget.mdl]],
           GetUnitX(S.p[pid].hero), GetUnitY(S.p[pid].hero))
  end

  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.panelRefresh(pid)
end

-- ---------- CHI SO ----------
--
-- HAI LOAI VAI, va chung khac nhau ve BAN CHAT chu khong chi ve con so:
--
--   cong diem  (str/agi/int/all)      -- KHONG tu leo, phai nhan
--                                        CULT_STAT_STEP^(canh gioi-1)
--   nhan %     (dmgpct/mitig_phys/
--               mitig_magic)             -- TU leo san, nen phai de PHANG
--
-- Cho ca hai cung mot duong cong la hai mon nhan chay mat -- xem chu
-- thich CFG.GEAR_STAT_BASE. Day la ADR 0010 lap lai o tang nguoi choi.

-- Tong so bac da di cua mot mon: 0 .. tierMax x levelMax.
local function stepsOf(pid, i)
  local st = stOf(pid, i)
  if st == nil or st.tier <= 0 then return 0 end
  return (st.tier - 1) * levelMax() + st.level
end

local function stepsMax()
  return tierMax() * levelMax()
end

-- Diem chi so CONG DON cua mot mon "cong diem".
--
--   value(T,L) = BASE x [ N x (STEP^(T-1) - 1)/(STEP-1) + L x STEP^(T-1) ]
--                         \_ N canh gioi truoc, tron _/   \_ canh gioi nay _/
--
-- Dung CHINH CULT_STAT_STEP chu khong go 1.30: doi duong cong Tu Vi thi
-- trang bi tu di theo, giong cach the "stat" cua Co Duyen lam.
local function addPoints(pid, i)
  local st = stOf(pid, i)
  if st == nil or st.tier <= 0 then return 0.0 end
  local s, n, T = CFG.CULT_STAT_STEP, levelMax(), st.tier
  local prev
  if s == 1.0 then prev = n * (T - 1)
  else               prev = n * (s ^ (T - 1) - 1) / (s - 1) end
  return CFG.GEAR_STAT_BASE * (prev + st.level * s ^ (T - 1))
end

-- Phan tram cua mot mon "nhan": TUYEN TINH theo so bac, khong leo.
local function pctOf(pid, i, maxPct)
  local m = stepsMax()
  if m <= 0 then return 0.0 end
  return (maxPct or 0.0) * stepsOf(pid, i) / m
end

-- Tong chi so tu CA SAU mon. Tra ve BA so, dung thu tu str/agi/int --
-- 7_effect cong thang vao mot cong thuc duy nhat, khong doc-cong-ghi.
local function statOf(pid)
  local str, agi, int = 0.0, 0.0, 0.0
  for i = 1, itemCount() do
    local role = CFG.GEAR[i].role
    if role == "str" or role == "agi" or role == "int" or role == "all" then
      local v = addPoints(pid, i)
      if     role == "str" then str = str + v
      elseif role == "agi" then agi = agi + v
      elseif role == "int" then int = int + v
      else
        -- Nhan: chia deu ba phan. Tong bang dung mot mon don chi so --
        -- doi lai chia ba thi sat thuong ky nang chi an mot phan ba, vi
        -- no tra theo chi so CAO NHAT chu khong theo tong.
        local third = v / 3.0
        str, agi, int = str + third, agi + third, int + third
      end
    end
  end
  return str, agi, int
end

-- % sat thuong GAY RA. An vao don thuong, sat thuong phep va hoi mau.
local function dmgPctOf(pid)
  local out = 0.0
  for i = 1, itemCount() do
    if CFG.GEAR[i].role == "dmgpct" then
      out = out + pctOf(pid, i, CFG.GEAR_DMG_MAX)
    end
  end
  return out
end

-- % sat thuong NHAN VAO duoc giam, theo LOAI don:
--   Khien ("mitig_phys")  cham don danh
--   Ao Choang ("mitig_magic") cham phep
--
-- Nguoi goi noi ro dang hoi loai nao. Khong doan tu dau goi: onDamaged
-- co BlzGetEventDamageType de hoi that.
local function mitigPctOf(pid, role)
  local out = 0.0
  for i = 1, itemCount() do
    if CFG.GEAR[i].role == role then
      out = out + pctOf(pid, i, CFG.GEAR_MITIG_MAX)
    end
  end
  return out
end

-- Duong dan icon cua mot mon o canh gioi hien tai.
--
-- Dung san theo CFG.GEAR_ICON_PATH chu khong go tung cai: them mot canh
-- gioi la tha anh vao roi chay w3gear_icons.py, khong sua dong Lua nao.
--
-- Chua luyen (tier 0) thi coi nhu canh gioi 1 -- phai co hinh de nguoi
-- choi biet mon do la gi truoc khi bo da vao.
--
-- Vuot qua GEAR_ICON_MAX thi dung anh cua muc cao nhat DA CO. Khong ke
-- thua thi mon o canh gioi 7 se mat icon, va o trong giua luoi trong
-- nhu bang hong.
--
-- Thieu ca bang duong dan thi lui ve item.icon -- duong do tu item that
-- luc vao map (probeIcons), da chung minh ve ra hinh.
local function iconFor(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return nil end
  if item.key == nil or CFG.GEAR_ICON_PATH == nil then return item.icon end
  local st = stOf(pid, i)
  local t  = (st ~= nil and st.tier > 0) and st.tier or 1
  local mx = CFG.GEAR_ICON_MAX or 1
  if t > mx then t = mx end
  return string.format(CFG.GEAR_ICON_PATH, item.key, t)
end

-- Nhan: % sat thuong gay ra hoi thanh mau. Cung khuon voi dmgPctOf.
local function lifestealPctOf(pid)
  local out = 0.0
  for i = 1, itemCount() do
    if CFG.GEAR[i].role == "lifesteal" then
      out = out + pctOf(pid, i, CFG.GEAR_LIFESTEAL_MAX)
    end
  end
  return out
end

-- Hoi mau cho hero theo sat thuong VUA GAY RA. Goi tu hai duong danh:
-- don thuong (onDamaged) va sat thuong ky nang (hit). Khong co Nhan thi
-- tra ve ngay, khong dung toi GetUnitState.
local function lifestealHeal(pid, amount)
  if amount == nil or amount <= 0.0 then return end
  local pct = lifestealPctOf(pid)
  if pct <= 0.0 then return end
  local d = S.p[pid]
  local h = d and d.hero or nil
  if h == nil or not API.alive(h) then return end
  local hp = GetUnitState(h, UNIT_STATE_LIFE) + amount * pct
  local mx = GetUnitState(h, UNIT_STATE_MAX_LIFE)
  SetUnitState(h, UNIT_STATE_LIFE, (hp > mx) and mx or hp)
end

-- Chu mo ta phan mon nay DANG cong, de len the trong bang. Khong co no
-- thi nguoi choi bo da ma khong thay minh mua duoc gi.
local function bonusLabel(pid, i)
  local item = CFG.GEAR[i]
  if item == nil then return "" end
  local role = item.role
  -- API.num lam TRON XUONG, ma o bac dau % con duoi 1 -- no se hien
  -- "+0%" trong khi mon do that su co cong. Phan tram phai co mot chu so
  -- thap phan.
  if role == "dmgpct" then
    return API.t("gear_bonus_dmg",
      string.format("%.1f", pctOf(pid, i, CFG.GEAR_DMG_MAX) * 100.0))
  elseif role == "lifesteal" then
    return API.t("gear_bonus_lifesteal",
      string.format("%.1f", pctOf(pid, i, CFG.GEAR_LIFESTEAL_MAX) * 100.0))
  elseif role == "mitig_phys" or role == "mitig_magic" then
    local pct = string.format("%.1f", pctOf(pid, i, CFG.GEAR_MITIG_MAX) * 100.0)
    return API.t((role == "mitig_phys") and "gear_bonus_mitig_phys"
                                         or "gear_bonus_mitig_magic", pct)
  end
  local v = addPoints(pid, i)
  if role == "all" then
    return API.t("gear_bonus_all", API.num(v / 3.0))
  end
  return "+" .. API.num(v) .. " " .. API.t("stat_" .. role)
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local iron  = API.getIron(pid)
  local out = {}
  for i = 1, itemCount() do
    local item = CFG.GEAR[i]
    local st  = stOf(pid, i)
    local it  = { icon = iconFor(pid, i), name = fullName(pid, i) }

    -- 'short' + 'stat' la cua bang thong ke ben phai luoi; 'status' la
    -- cua kieu than "list" cu. Giu ca hai de doi kieu bay khong phai
    -- sua lai cho nay.
    -- NHAN tren icon (luoi). Xem chu thich o 1_panel.lua ve cho dat.
    --
    -- Ghi TONG BAC DA DI tren tong bac ("33/100"), khong ghi "3/5".
    -- Ba ly do:
    --   - "3/5" khong phan biet duoc Pham Nhan cap 3 voi Tien De cap 3,
    --     ma hai cai do cach nhau ca mot van choi.
    --   - Mot con so duy nhat thi TAM MON SO SANH DUOC VOI NHAU bang
    --     mot cai liec -- do dung la cau hoi "mon nao dang tut lai".
    --   - Ten cap ("Trung Cap" / "Exalted") khong vua be ngang icon
    --     0.036, va cot ten ben phai thi da chat san.
    local steps, smax = stepsOf(pid, i), stepsMax()
    it.tag = ((steps <= 0) and CFG.C_GREY
              or (steps >= smax) and CFG.C_GOLD or CFG.C_JADE) ..
             steps .. "/" .. smax .. CFG.C_END

    if st.tier <= 0 then
      it.status = CFG.C_GREY .. API.t("gear_not_refined") .. CFG.C_END
      it.short  = API.pick(item)
      it.stat   = CFG.C_GREY .. "--" .. CFG.C_END
    else
      -- Cap hien tai VA phan mon nay dang cong. Khong co ve sau thi
      -- nguoi choi bo mot van da ma khong bao gio thay minh mua duoc gi.
      it.status = CFG.C_GREY .. st.level .. "/" .. levelMax() .. CFG.C_END ..
                  "   " .. CFG.C_JADE .. bonusLabel(pid, i) .. CFG.C_END
      -- Bang thong ke ben phai luoi: cot hep nen KHONG nhet ca canh
      -- gioi vao. Ghi TEN CAP chu khong ghi "1-4" -- con so do khong
      -- noi len gi, ma nguoi choi thi doc "So Cap / Trung Cap".
      -- KHONG nhet canh gioi vao day. Da do: cot nay rong sw*0.58 va
      -- "Necklace - Exalted" da chiem 164px; them "Sang The Than " nua
      -- la tran sang cot chi so. Canh gioi doc o nhan icon (tong bac)
      -- va o nhan nut khi cham tran.
      it.short  = API.pick(item) .. " - " .. levelNameOf(st.level)
      it.stat   = CFG.C_JADE .. bonusLabel(pid, i) .. CFG.C_END
    end

    if canRefine(pid, i) then
      local pct = math.floor(nextOdds(pid, i) * 100.0 + 0.5)
      local exp = expectedCost(pid, i)
      it.desc   = API.t("gear_up", levelNameOf(levelMax()), pct, API.num(exp))
      -- O LUOI, 'note' chi hien KHI KHONG CO NUT (xem panel.lua:387) --
      -- nghia la chu giai thich bi chinh cai nut che. Nen NHAN NUT phai
      -- gom du ba y: lam gi, toi dau, het bao nhieu.
      --
      -- Nut rong 0.132 = 238 px, chu co mac dinh ~10,7 px/ky tu -> 22 ky
      -- tu. "LUYEN Hoan Hao  ~15" = 19. Vua, con du le.
      -- Nhan nut NOI RA che do dang bat. Do la thu bien o tich tu mot
      -- che do AN thanh mot che do NHIN THAY DUOC: bat len thi ca tam
      -- nut cung doi chu, khong phai nho cai tick be ti o giua.
      if isAllIn(pid) then
        -- KHONG dung "~". Font cua Warcraft ve dau nga NHAC CAO gan ngang
        -- dinh chu, nhin ra dau phu cua mot ky tu chu khong ra "khoang
        -- chung" -- da thu tren man hinh that. Con so dung mot minh, va
        -- "(co N)" ben canh da noi ro no dem DA.
        it.btn  = API.t("gear_btn_upto", levelNameOf(levelMax()))
                  .. "  " .. API.num(exp)
      else
        it.btn  = API.t("gear_btn_up") .. "  " .. API.num(CFG.GEAR_PRICE)
      end
      -- Chi can MOT vien la bam duoc: no se tieu het cho co roi dung.
      -- Khoa nut theo 'exp' la khoa theo mot con so DU DOAN -- nguoi
      -- choi con 8 vien van luyen duoc, khong co ly do chan.
      it.btnOn = (iron >= CFG.GEAR_PRICE)
      if not it.btnOn then
        it.btn = it.btn .. API.t("gear_btn_have", API.num(iron))
      end

    elseif st.tier >= tierMax() then
      it.desc   = CFG.C_JADE .. API.t("gear_max") .. CFG.C_END
      it.note   = API.t("gear_note_max")

    elseif canEvolve(pid, i) then
      it.desc   = API.t("gear_need_iron")
      it.btn    = API.t("gear_btn_dismantle") .. "  " .. API.num(CFG.GEAR_DISMANTLE)
      it.btnOn = (iron >= CFG.GEAR_DISMANTLE)
      if not it.btnOn then
        it.btn = it.btn .. API.t("gear_btn_have", API.num(iron))
      end

    else
      -- Hoan Hao roi nhung Tu Vi chua toi. Day la luc cai TRAN hien ra,
      -- va no phai noi RO dang cho gi -- khong co nut ma khong giai
      -- thich thi nguoi choi tuong giao dien hong.
      -- 'desc' la cau day du cho kieu than "list"; 'note' la ban ngan
      -- dat vua mot o cua luoi. Hai cho hien, mot y.
      it.desc = CFG.C_GREY .. API.t("gear_cap", tierNameOf(st.tier + 1)) .. CFG.C_END
      it.note = API.t("gear_note_cap")
      -- CO nut, nhung khoa. Truoc day cho nay khong co nut nao ca, nen
      -- no trong y HET o dang thieu da -- ma hai cai bao nguoi choi lam
      -- hai viec trai nguoc: thieu da thi di cay, cho Tu Vi thi di dot
      -- pha. btnWhy = "locked" cho bang ve no khac di.
      it.btn    = API.t("gear_btn_wait", tierNameOf(st.tier + 1))
      it.btnOn  = false
      it.btnWhy = "locked" 
    end

    out[i] = it
  end

  -- ----- HAI O KHONG PHAI TRANG BI, o cuoi danh sach -----
  --
  -- Di qua dung may moc o luoi (icon + nhan + nut) thay vi ve khung
  -- rieng. Chi so cua chung la #CFG.GEAR+1 va +2, khop voi hai o
  -- { 1, 5 } va { 3, 5 } them vao CFG.GEAR_SLOTS.
  --
  -- tabItemAction() dinh tuyen chung sang OP_WING / OP_PET.
  local n = itemCount()

  local wn = (API.wingOwned ~= nil) and API.wingOwned(pid) or 0
  local wl = (API.wingLabel ~= nil) and API.wingLabel(pid) or nil
  local wi = { icon = CFG.GEAR_WING_ICON, name = API.t("gear_wing") }
  if wn <= 0 then
    -- Chua co bo nao: noi RO can canh gioi may, khong de o trong.
    local need = (API.wingNext ~= nil) and API.wingNext(pid) or nil
    wi.status = CFG.C_GREY .. API.t("st_locked") .. CFG.C_END
    wi.desc   = (need ~= nil) and API.t("wing_need", realmNameOf(need)) or ""
    wi.btn    = API.t("wing_need_short")
    wi.btnOn  = false
    wi.btnWhy = "locked"
  else
    wi.status = CFG.C_GREY .. wn .. "/" .. #(CFG.WINGS or {}) .. CFG.C_END
    wi.desc   = CFG.C_JADE .. (wl or "--") .. CFG.C_END
    wi.btn    = API.t("btn_swap")
    wi.btnOn  = (wn > 1)
  end
  out[n + 1] = wi

  local pn = (API.petOwned ~= nil) and API.petOwned(pid) or 0
  local pl = (API.petLabel ~= nil) and API.petLabel(pid) or nil
  local pi = { icon = CFG.GEAR_PET_ICON, name = API.t("gear_pet") }
  if pn <= 0 then
    pi.status = CFG.C_GREY .. API.t("st_locked") .. CFG.C_END
    pi.desc   = API.t("pet_need")
    pi.btn    = API.t("pet_need_short")
    pi.btnOn  = false
    pi.btnWhy = "locked"
  else
    pi.status = CFG.C_GREY .. pn .. "/" .. #(CFG.SIDE_QUESTS or {}) .. CFG.C_END
    pi.desc   = CFG.C_JADE .. (pl or "--") .. CFG.C_END
    pi.btn    = API.t("btn_swap")
    pi.btnOn  = (pn > 1)
  end
  out[n + 2] = pi

  return out
end

-- Mot nut, hai viec: truoc Hoan Hao thi Luyen, den Hoan Hao thi Tien
-- Giai. Quyet dinh o day la CUC BO nhung an toan, vi trang thai dua vao
-- (st.cap) da dong bo san -- va ca hai nhanh deu kiem lai dieu kien o
-- ben nhan.
-- O tich chi doi CHO NAY: op nao duoc gui. Ben nhan van kiem lai du
-- dieu kien, nen mot may go trang thai tich cung khong lam gi duoc hon
-- ngoai viec tu luyen le.
local function tabToggleText(pid)
  return isAllIn(pid) and API.t("gear_allin_on") or API.t("gear_allin_off")
end

local function tabToggleAction(pid)
  allIn[pid] = not isAllIn(pid)
end

local function tabItemAction(pid, i)
  -- Hai o cuoi khong phai trang bi -- xem tabItems().
  local n = itemCount()
  if i == n + 1 then API.syncSend(pid, CFG.OP_WING, 0); return end
  if i == n + 2 then API.syncSend(pid, CFG.OP_PET,  0); return end

  if CFG.GEAR[i] == nil then return end
  if canRefine(pid, i) then
    API.syncSend(pid, isAllIn(pid) and CFG.OP_GEAR_UP
                                    or CFG.OP_GEAR_UP_ONE, i)
  elseif canEvolve(pid, i) then
    API.syncSend(pid, CFG.OP_GEAR_DISMANTLE, i)
  end
end

-- Doc icon THAT tu item cua game. Cung cach probeItems() cua 8_shop.lua
-- va probeIcons() cua 10_fortune.lua -- ba cho cung mot bai hoc.
local function probeIcons()
  if CreateItem == nil or BlzGetItemIconPath == nil then
    API.trace("gear: khong do duoc icon (thieu CreateItem/BlzGetItemIconPath)")
    return
  end
  for i = 1, #CFG.GEAR do
    local item = CFG.GEAR[i]
    local hit = nil
    if item.probe ~= nil then
      for k = 1, #item.probe do
        local code = item.probe[k]
        local it = CreateItem(FourCC(code), 0.0, 0.0)
        if it ~= nil then
          local path = BlzGetItemIconPath(it)
          if path ~= nil and path ~= "" then
            item.icon = path
            hit = code
          end
          RemoveItem(it)
        end
        if hit ~= nil then break end
      end
    end
    if hit ~= nil then
      API.trace("gear: " .. item.en .. " <- " .. hit .. " (icon " .. item.icon .. ")")
    else
      API.trace("gear: " .. item.en .. " GIU DUONG LUI (" .. tostring(item.icon) .. ")")
    end
  end
end

local function startGear()
  probeIcons()
  -- Kieu "grid": bay o xep quanh cho hinh nguoi, nut Upgrade ngay duoi
  -- moi o, bang thong ke ben phai. Bo cuc o nam trong CFG.GEAR_SLOTS --
  -- bang chi doc, no khong biet mon nao la mon nao.
  API.panelAddTab({
    name        = API.t("panel_gear"),
    kind       = "grid",
    slots      = CFG.GEAR_SLOTS,
    statHead   = API.t("gear_stat_head"),
    items      = tabItems,
    itemAction = tabItemAction,
    toggleSlot   = CFG.GEAR_TOGGLE_SLOT,
    toggleText   = tabToggleText,
    toggleAction = tabToggleAction,
  })
  -- Lech so o va so mon thi bang se VE THIEU mot mon ma khong bao gi --
  -- dung kieu sai im lang cua ADR 0012. Bat o day, luc vao map.
  -- +2 cho hai o Canh va Thanh Thu o hang 5 (xem tabItems).
  local nslot = (CFG.GEAR_SLOTS ~= nil) and #CFG.GEAR_SLOTS or 0
  if nslot ~= itemCount() + 2 then
    API.trace("gear: LECH -- " .. itemCount() .. " mon + 2 o rieng nhung " ..
              nslot .. " o trong CFG.GEAR_SLOTS; bang se ve thieu")
  end

  API.syncOn(CFG.OP_GEAR_UP,   refine)
  API.syncOn(CFG.OP_GEAR_UP_ONE,
             function(p2, i2) refine(p2, i2, true) end)
  API.syncOn(CFG.OP_GEAR_DISMANTLE, dismantle)
  API.trace("gear: " .. itemCount() .. " mon x " .. tierMax() .. " canh gioi x " ..
            levelMax() .. " cap, the san sang (chi so con rong)")
end

API.gearName     = fullName
API.gearTier    = function(pid, i) local st = stOf(pid, i); return st and st.tier or 0 end
API.gearLevel     = function(pid, i) local st = stOf(pid, i); return st and st.level  or 0 end
API.gearStat    = statOf      -- tra ve str, agi, int
API.gearDmgPct  = dmgPctOf
API.gearMitigPct = mitigPctOf  -- (pid, "mitig_phys" | "mitig_magic")
API.gearLifesteal    = lifestealHeal  -- (pid, sat thuong vua gay ra)
API.gearBonus   = bonusLabel
API.startGear   = startGear
