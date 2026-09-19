-- ============================================================
--  5_modifier.lua  --  Tu chinh: moi stage thuong mot sua doi
--
--  Khong co he nay thi bon tang cua mot canh gioi chi cach nhau
--  x1.054 chi so -- nguoi choi bam dung ngan ay nut, bon lan, hai
--  muoi canh gioi. Xem docs/02-he-thong/dot-quai.md.
--
--  BON DIEU PHAI NHO KHI SUA FILE NAY:
--
--  1. BOC O DAU LA MOT RANG BUOC DONG BO. GetRandomInt phai chay tren
--     MOI MAY cung thu tu, neu khong hai ban game lech nhau. pick()
--     goi tu spawnStage() -- duong da dong bo. TUYET DOI khong boc
--     trong callback cua frame (ADR 0012).
--
--  2. KHONG dung giap de giam sat thuong. ADR 0010: duong cong sinh ra
--     EHP, mau that suy nguoc ra TU GIAP. So vao giap la lang le doi ca
--     duong cong do kho cua map. Hai tu chinh "giam 50%" vi the nhan o
--     SU KIEN SAT THUONG.
--
--  3. MA ABILITY THI DO, KHONG GO. UnitAddAbility tra false khi ma sai
--     va ham IM LANG khong lam gi -- dung cai bay CLAUDE.md canh bao.
--     probeAbility() thu lan luot roi TRACE ket qua.
--
--  4. Tu chinh ma nguoi choi khong biet thi khong phai co che, no la
--     do kho VO HINH -- va do kho vo hinh chi gay uc che. Moi stage
--     phai bao ten VA bao phai lam gi.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- ---------- Boc ----------

local function cur()
  return S.waveMod
end

-- Ma ability hut mau THAT SU dung duoc o ban nay.
--
-- Do mot lan tren con quai dau tien: gan thu, ai nhan thi giu ma do.
-- Khong ma nao nhan thi lui ve duong su kien sat thuong -- va BAO RA.
local function probeAbility(u, list)
  if UnitAddAbility == nil or list == nil then return nil end
  for i = 1, #list do
    local code = FourCC(list[i])
    if UnitAddAbility(u, code) then
      API.trace("modifier: hut mau dung ability '" .. list[i] .. "'")
      return code
    end
  end
  API.trace("modifier: KHONG ma ability hut mau nao gan duoc (" ..
            table.concat(list, " ") .. ") -- lui ve su kien sat thuong")
  return false
end

-- ---------- Thoi tiet ----------
--
-- Lop bao thu BA, canh dong chu (troi di) va mau quai (phai nhin vao
-- quai). Troi thi thay ma khong can nhin dau ca.
--
-- TAO MOT LAN LUC VAO MAP roi bat/tat, khong tao lai moi stage:
-- AddWeatherEffect moi lan la mot handle moi, va handle Warcraft thi
-- khong tu don. Mot ban do 100 stage se ro ri 100 cai.
--
-- Tat ca gan vao CUNG mot rect (bj_mapInitialPlayableArea -- da dung o
-- ba cho khac trong map nay). Nhieu hieu ung tren mot rect la binh
-- thuong; chi mot cai duoc BAT tai mot luc.
--
-- MA THOI TIET THI DO, KHONG GO. AddWeatherEffect tra nil khi ma sai
-- roi im lang -- thu lan luot danh sach ung vien, giu cai nao dung
-- duoc, va GHI VET ca hai truong hop.
local function makeWeather(m)
  if AddWeatherEffect == nil or m.weather == nil then return nil end
  local r = bj_mapInitialPlayableArea
  if r == nil then
    API.trace("modifier: khong co bj_mapInitialPlayableArea -- bo thoi tiet")
    return nil
  end
  for i = 1, #m.weather do
    local w = AddWeatherEffect(r, FourCC(m.weather[i]))
    if w ~= nil then
      if EnableWeatherEffect ~= nil then EnableWeatherEffect(w, false) end
      API.trace("modifier: thoi tiet " .. m.code .. " = '" .. m.weather[i] .. "'")
      return w
    end
  end
  API.trace("modifier: KHONG ma thoi tiet nao dung duoc cho " .. m.code ..
            " (" .. table.concat(m.weather, " ") .. ")")
  return nil
end

-- Bat dung mot cai, tat het phan con lai.
--
-- Tat TRUOC roi bat SAU: bat truoc thi co mot khung hinh hai kieu troi
-- chong nhau, va mua voi bao cat cung luc nhin ra loi ve.
local function setWeather(code)
  if S.modWeather == nil or EnableWeatherEffect == nil then return end
  for k, w in pairs(S.modWeather) do
    if k ~= code and w ~= nil then EnableWeatherEffect(w, false) end
  end
  local cw = (code ~= nil) and S.modWeather[code] or nil
  if cw ~= nil then EnableWeatherEffect(cw, true) end
end

-- Boc mot tu chinh cho stage. KHONG trung cai vua roi.
--
-- Hai stage lien tiep giong nhau thi nguoi choi tuong he hong -- va
-- voi bang 5 cai thi xac suat trung la 1/5, du cao de gap thuong xuyen.
local function pick(stage)
  local list = CFG.MODIFIERS
  if list == nil or #list == 0 then S.waveMod = nil; return end

  local prev = S.waveModCode
  local m
  if #list == 1 then
    m = list[1]
  else
    -- Boc lai toi khi khac cai truoc. Toi da vai vong vi #list >= 2.
    for _ = 1, 20 do
      m = list[GetRandomInt(1, #list)]
      if m.code ~= prev then break end
    end
  end

  S.waveMod     = m
  S.waveModCode = m.code
  S.waveModAbil = nil   -- do lai moi stage: ability chi gan cho stage nay
  setWeather(m.code)
end

-- Tat troi. Goi o stage boss: boss da co bang co che rieng, them mot
-- kieu troi nua la nguoi choi khong biet troi dang noi ve cai gi.
local function clear()
  S.waveMod, S.waveModCode = nil, nil
  setWeather(nil)
  -- Khung Tong Quan co mot dong doc tu day. Khong goi thi dong do giu
  -- ten tu chinh CU suot ca dot boss -- sai ma nhin rat that.
  if API.gameFrameRefresh ~= nil then API.gameFrameRefresh() end
end

-- ---------- Bao cho nguoi choi ----------
--
-- HAI kenh, vi chat troi con tu chinh keo dai ca dot:
--   dong chu  -> noi quai LAM GI va minh PHAI LAM GI
--   mau quai  -> nhin la biet, khong phai nho
local function announce()
  local m = cur()
  if m == nil then return end
  local en   = (API.lang() == "en")
  local desc = (en and m.desc_en) or m.desc_vi or ""
  local sky  = (en and m.sky_en) or m.sky_vi

  -- Goi TEN kieu troi ra, khong de nguoi choi tu doan.
  --
  -- Troi la lop bao thu ba, nhung mot so kieu (suong mu) rat mo nhat --
  -- neu khong noi thi nguoi choi khong biet co phai troi vua doi hay
  -- khong, va mot dau hieu khong chac chan thi khong dung duoc.
  local head = API.t("wave_mod", API.pick(m))
  if sky ~= nil then head = head .. API.t("wave_mod_sky", sky) end

  API.msg(nil, CFG.C_GOLD .. head .. CFG.C_END ..
               "  " .. CFG.C_GREY .. desc .. CFG.C_END)
  if API.gameFrameRefresh ~= nil then API.gameFrameRefresh() end
end

-- Tu chinh DANG chay, cho khung Tong Quan (phim R). Tra ve (ten, mo ta),
-- hoac nil khi dot nay khong co tu chinh nao.
--
-- VI SAO PHAI CO CHO TRA CUU, khong chi mot dong chat.
--
-- Dong chat bao dung mot lan, luc vao dot. Nhung TU CHINH KEO DAI CA
-- DOT, con dong chat thi troi mat sau vai giay. Nguoi choi vao giua
-- dot, hoac vua doc mot dong khac de len, thi khong con cho nao hoi --
-- va thu duy nhat con lai la mau quai voi kieu troi, ca hai deu phai
-- NHO moi doc duoc.
--
-- Do la lop thu tu, va la lop duy nhat TRA CUU DUOC:
--   dong chat  noi mot lan, roi mat
--   mau quai   luon o do, nhung phai nho no nghia gi
--   kieu troi  luon o do, nhung suong mu thi rat mo
--   dong nay   luon o do, va noi ro bang chu
local function labelNow()
  local m = cur()
  if m == nil then return nil end
  local en   = (API.lang() == "en")
  local sky  = (en and m.sky_en) or m.sky_vi
  local name = API.pick(m)
  if sky ~= nil then name = name .. " (" .. sky .. ")" end
  return name, (en and m.desc_en) or m.desc_vi or ""
end

-- Lenh dev "-sky N": bat MOT ma thoi tiet bat ky de NHIN.
--
-- Vi sao phai co lenh nay: khong co cach nao kiem ma thoi tiet bang
-- code. AddWeatherEffect nhan ca ma rac va tra ve handle binh thuong
-- -- 'WNcw' va 'WOlw' deu "dung duoc" theo phep do do, ma tren man
-- hinh khong hien gi. Phep do that la con mat.
--
-- Tao mot lan roi giu (S.skyProbe): goi nhieu lan ma tao moi lan thi
-- ro ri handle, va Warcraft khong tu don.
local function devSky(pid, text)
  local list = CFG.SKY_PROBE or {}
  local arg  = (text or ""):match("%-sky%s+(%S+)")

  if S.skyProbe == nil then S.skyProbe = {} end

  -- Tat het truoc, ke ca thoi tiet cua tu chinh: hai kieu troi chong
  -- nhau thi khong biet minh dang nhin cai nao.
  setWeather(nil)
  for _, w in pairs(S.skyProbe) do
    if w ~= nil and EnableWeatherEffect ~= nil then EnableWeatherEffect(w, false) end
  end
  if arg == "off" then
    API.info(pid, "-sky: tat het")
    return
  end

  local n = tonumber(arg)
  if n == nil or list[n] == nil then
    API.info(pid, "-sky N   (N = 1.." .. #list .. ")   |   -sky off")
    for i = 1, #list do
      API.info(pid, "   " .. i .. ". " .. list[i][1] .. "  " .. list[i][2])
    end
    return
  end

  local code = list[n][1]
  if S.skyProbe[code] == nil then
    local r = bj_mapInitialPlayableArea
    if AddWeatherEffect == nil or r == nil then
      API.info(pid, "-sky: khong co AddWeatherEffect")
      return
    end
    S.skyProbe[code] = AddWeatherEffect(r, FourCC(code))
  end
  local w = S.skyProbe[code]
  if w ~= nil and EnableWeatherEffect ~= nil then EnableWeatherEffect(w, true) end
  API.info(pid, "-sky " .. n .. " = '" .. code .. "'  " .. list[n][2])
  API.trace("sky: bat thu '" .. code .. "' (" .. list[n][2] .. ")")
end

-- Lenh dev "-mod N": ep tu chinh so N va bat troi cua no ngay.
--
-- Ly do co lenh nay: doi RNG boc trung mot tu chinh de xem kieu troi
-- cua no la cho mot minh trong may phut. Va khi mot kieu troi KHONG
-- hien ra, phai tra loi duoc cau "no khong chay, hay no chay ma mo qua"
-- -- lenh nay tra loi trong muoi giay.
local function devSet(pid, text)
  local n = tonumber((text or ""):match("%-mod%s+(%d+)"))
  local list = CFG.MODIFIERS or {}
  if n == nil or list[n] == nil then
    API.info(pid, "-mod N  (N = 1.." .. #list .. ")")
    for i = 1, #list do
      API.info(pid, "   " .. i .. ". " .. list[i].code ..
                    "  troi=" .. tostring((list[i].weather or {})[1]))
    end
    return
  end
  local m = list[n]
  S.waveMod, S.waveModCode, S.waveModAbil = m, m.code, nil
  setWeather(m.code)
  API.info(pid, "-mod " .. n .. " -> " .. m.code .. ", troi " ..
                tostring((m.weather or {})[1]))
end

-- ---------- Gan len mot con vua sinh ----------

local function apply(u)
  local m = cur()
  if m == nil or u == nil then return end

  local c = m.color
  if c ~= nil and SetUnitVertexColor ~= nil then
    SetUnitVertexColor(u, c[1], c[2], c[3], 255)
  end

  if m.kind == "ability" then
    -- Do MOT lan cho ca stage, roi dung ket qua do cho 49 con con lai.
    if S.waveModAbil == nil then
      S.waveModAbil = probeAbility(u, m.abils)
    elseif S.waveModAbil and UnitAddAbility ~= nil then
      UnitAddAbility(u, S.waveModAbil)
    end
  end
end

-- ---------- Giam sat thuong ----------
--
-- Chay o su kien sat thuong, KHONG o giap (xem dau file).
--
-- Phan biet phep/don danh y het cach Ao Choang lam trong 7_effect.lua:
-- moi ky nang hero deu danh ra DAMAGE_TYPE_MAGIC, don thuong thi
-- DAMAGE_TYPE_NORMAL. Thieu BlzGetEventDamageType thi coi la don danh
-- va GHI VET mot lan -- khong nuot.
local warnedType = false

local function onDamaged()
  local m = cur()
  if m == nil or m.kind ~= "damage" then return end
  if BlzSetEventDamage == nil then return end

  local tgt = GetTriggerUnit()
  if tgt == nil or S.mobs == nil or S.mobs[tgt] == nil then return end

  local dmg = GetEventDamage()
  if dmg <= 0.0 then return end

  local spell = false
  if BlzGetEventDamageType ~= nil then
    spell = (BlzGetEventDamageType() ~= DAMAGE_TYPE_NORMAL)
  elseif not warnedType then
    warnedType = true
    API.trace("modifier: THIEU BlzGetEventDamageType -- moi don deu tinh " ..
              "la don danh, tu chinh Chan Phep se khong an gi")
  end

  if spell ~= (m.spell == true) then return end

  -- Phap Khi "Luong Nghi Chau": tu chinh nay chi con cat mot nua.
  --
  -- Loc theo NGUOI GAY sat thuong, khong theo muc tieu: muc tieu la con
  -- quai, ma mon do la cua hero. Ai khong mua thi van an du 50%, nen
  -- hai nguoi trong mot doi co the danh khac nhau.
  local cut = m.cut or 0.0
  if API.relicVal ~= nil and API.heroPidOf ~= nil then
    local sp = API.heroPidOf(GetEventDamageSource())
    if sp ~= nil then
      local half = API.relicVal(sp, "luongnghi", "modCut")
      if half > 0.0 then cut = cut * (1.0 - half) end
    end
  end
  BlzSetEventDamage(dmg * (1.0 - cut))
end

-- ---------- Chet thi no ----------
--
-- Sat thuong tinh theo SAT THUONG CUA CHINH CON DO (BlzGetUnitBaseDamage)
-- chu khong phai mot con so phang: con so phang se thanh vo nghia o canh
-- gioi 15. Doc khong duoc thi bo qua chu khong bia.
local function onDeath()
  local m = cur()
  if m == nil or m.kind ~= "death" then return end

  local u = GetTriggerUnit()
  if u == nil or S.mobs == nil or S.mobs[u] == nil then return end
  if BlzGetUnitBaseDamage == nil or UnitDamageTarget == nil then return end

  local base = BlzGetUnitBaseDamage(u, 0)
  if base == nil or base <= 0 then return end
  local dmg = base * (m.factor or 1.0)
  local r   = m.radius or 300.0
  local x, y = GetUnitX(u), GetUnitY(u)

  if CFG.FX_SLAM_HIT ~= nil then API.fx(CFG.FX_SLAM_HIT, x, y) end

  -- Chi danh HERO nguoi choi. No lan sang chinh dong quai cua no thi
  -- tu chinh nay thanh mot mon qua cho nguoi choi.
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h)
       and API.distXY(x, y, GetUnitX(h), GetUnitY(h)) <= r then
      -- Phap Khi "Bat Dong Minh Vuong": vu no chi con mot nua.
      local one = dmg
      if API.relicVal ~= nil then
        local half = API.relicVal(S.pids[i], "batdong", "halve")
        if half > 0.0 then one = one * (1.0 - half) end
      end
      UnitDamageTarget(u, h, one, true, false,
                       ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    end
  end
end

-- ---------- Nhan thuong ----------

local function rewardMult()
  local m = cur()
  if m ~= nil and m.kind == "bounty" then return m.mult or 1.0 end
  return 1.0
end

-- ---------- Khoi dong ----------

local function startModifier()
  S.waveMod, S.waveModCode, S.waveModAbil = nil, nil, nil
  if CFG.MODIFIERS == nil or #CFG.MODIFIERS == 0 then
    API.trace("modifier: bang rong -- moi stage thuong se giong het nhau")
    return
  end

  S.modWeather = {}
  for i = 1, #CFG.MODIFIERS do
    local m = CFG.MODIFIERS[i]
    S.modWeather[m.code] = makeWeather(m)
  end

  local td = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(td, EVENT_PLAYER_UNIT_DAMAGED)
  TriggerAddAction(td, onDamaged)
  S.modDmgTrig = td

  local tk = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(tk, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddAction(tk, onDeath)
  S.modDeathTrig = tk

  API.trace("modifier: " .. #CFG.MODIFIERS .. " tu chinh, boc ngau nhien " ..
            "khong trung cai truoc")
end

API.modifierPick       = pick
API.modifierClear      = clear
API.modifierDevSet     = devSet
API.modifierDevSky     = devSky
API.modifierApply      = apply
API.modifierAnnounce   = announce
API.modifierLabel      = labelNow
API.modifierRewardMult = rewardMult
API.startModifier      = startModifier
