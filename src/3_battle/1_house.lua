-- ============================================================
--  1_house.lua  --  Nha chinh & phan giai vung
--
--  Dung nha chinh giua CFG.RGN_HOUSE, va phan giai san vung
--  CFG.RGN_ENEMY de sau nay cho quai ra. Chua sinh quai nao ca.
--
--  Nha chinh la HERO (Mountain King), khong phai cong trinh. Khac biet
--  phai xu ly: mau tinh theo suc manh nen phai khoa kinh nghiem, va
--  hero mac dinh co don danh nen phai tat di.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Nha chinh dung mot slot rieng, khong thuoc ve rieng nguoi choi nao.
-- Quan he dong minh dat o 04_player.
local function houseOwner()
  return Player(CFG.HOUSE_SLOT)
end

-- Voi hero, mau toi da duoc suy ra tu suc manh. Dat thang bang
-- BlzSetUnitMaxHP van duoc, nhung se bi tinh lai neu hero len cap hoac
-- doi chi so -- vi vay CFG.HOUSE_SUSPEND_XP mac dinh bat.
local function setHouseHP(value)
  if S.house == nil or BlzSetUnitMaxHP == nil then return false end
  BlzSetUnitMaxHP(S.house, math.floor(value))
  SetUnitState(S.house, UNIT_STATE_LIFE, GetUnitState(S.house, UNIT_STATE_MAX_LIFE))
  return true
end

-- Tam nhin bang fog modifier, KHONG sua truong cua unit.
--
-- Truoc day dung BlzSetUnitRealField(UNIT_RF_SIGHT_RADIUS). Da bo:
-- kiem tra hang so ~= nil khong chan duoc truong hop hang so ton tai
-- nhung SAI KIEU -- goi setter real len mot truong integer la ghi sai
-- bo nho, ACCESS_VIOLATION. Nha chinh dung yen nen mot vung sang co
-- dinh la tuong duong hoan toan, va chi dung native cu chac chan.
local function setHouseSight(radius)
  for i = 1, #S.pids do
    local fm = CreateFogModifierRadius(Player(S.pids[i]), FOG_OF_WAR_VISIBLE,
                                       S.houseX, S.houseY, radius, true, false)
    FogModifierStart(fm)
  end
  return "fog modifier"
end

-- Khong cho nha chinh tu tim muc tieu.
--
-- Truoc day dung BlzSetUnitIntegerField(UNIT_IF_ATTACKS_ENABLED, 0) --
-- da bo vi cung ly do o tren. SetUnitAcquireRange la native cu, co tu
-- doi dau: ban kinh 0 thi unit khong bao gio tu nham ai. No van danh
-- neu bi RA LENH danh, nhung slot so huu nha khong co nguoi dieu khien
-- nen khong bao gio co lenh do.
local function disableAttacks()
  SetUnitAcquireRange(S.house, 0.0)
  return true
end

local function createHouse()
  local r, realName = API.findRegion(CFG.RGN_HOUSE)
  if r == nil then
    API.regionMissing("CFG.RGN_HOUSE", API.regionLabel(CFG.RGN_HOUSE))
    return nil
  end
  S.houseRgnName = realName

  local x, y = API.regionCenter(r)
  API.trace("house: CreateUnit slot " .. CFG.HOUSE_SLOT)
  S.house = CreateUnit(houseOwner(), CFG.HOUSE_UNIT, x, y, CFG.HOUSE_FACE)
  if S.house == nil then
    API.warn(nil, "CreateUnit that bai -- kiem tra CFG.HOUSE_UNIT.")
    return nil
  end
  S.houseX, S.houseY = x, y

  if CFG.HOUSE_SCALE ~= 1.0 then
    SetUnitScale(S.house, CFG.HOUSE_SCALE, CFG.HOUSE_SCALE, CFG.HOUSE_SCALE)
  end
  if BlzSetUnitName ~= nil then BlzSetUnitName(S.house, CFG.HOUSE_NAME) end

  -- Khoa kinh nghiem TRUOC khi dat mau, neu khong len cap se pha moc.
  API.trace("house: SuspendHeroXP")
  if CFG.HOUSE_SUSPEND_XP then SuspendHeroXP(S.house, true) end

  API.trace("house: setHP (BlzSetUnitMaxHP)")
  S.houseHpSet    = setHouseHP(CFG.HOUSE_HP)

  API.trace("house: setSight (fog modifier)")
  S.houseSightVia = setHouseSight(CFG.HOUSE_SIGHT)

  API.trace("house: disableAttacks (SetUnitAcquireRange)")
  if not CFG.HOUSE_CAN_ATTACK then
    S.houseNoAttack = disableAttacks()
  end

  API.trace("house: SetUnitInvulnerable")
  SetUnitInvulnerable(S.house, CFG.HOUSE_INVULNERABLE)

  -- Chot nha chinh tai cho. BA lop, vi khong lop nao mot minh du chac:
  --   SetUnitMoveSpeed(0)  Warcraft ep ve toc do toi thieu chu khong ve
  --                        0 han, nen day chi la lop giam thiet hai.
  --   "stop"               huy lenh di chuyen dang co san trong hang doi.
  --   PauseUnit(true)      chot han: unit khong nhan lenh nao nua.
  --
  -- PauseUnit KHONG lam no bat tu: unit bi chot van an sat thuong, van
  -- chet, van ban su kien chet -- nen duong thua van chay.
  if CFG.HOUSE_FROZEN then
    API.trace("house: FROZEN (move 0 + stop + PauseUnit)")
    if SetUnitMoveSpeed ~= nil then SetUnitMoveSpeed(S.house, 0.0) end
    if IssueImmediateOrder ~= nil then IssueImmediateOrder(S.house, "stop") end
    if PauseUnit ~= nil then PauseUnit(S.house, true) end
  end

  -- Go tui do. Xem CFG.HOUSE_REMOVE_ABILITIES.
  if UnitRemoveAbility ~= nil and CFG.HOUSE_REMOVE_ABILITIES ~= nil then
    local got = {}
    for i = 1, #CFG.HOUSE_REMOVE_ABILITIES do
      local aid = CFG.HOUSE_REMOVE_ABILITIES[i]
      if UnitRemoveAbility(S.house, aid) then
        got[#got + 1] = API.idToStr(aid)
      end
    end
    API.trace("house: go ability -- " ..
              ((#got > 0) and table.concat(got, " ") or "KHONG id nao trung"))
  end

  API.trace("house: XONG")
  return S.house
end

-- ---------- Nha chinh khong nhan do ----------
--
-- Lop thu hai, va la lop CHAC: no khong phu thuoc vao viec doan dung ma
-- ability tui do. Nha chinh vua nhat duoc mon nao thi tra ngay ra dat.
--
-- Tra ra dat chu khong xoa: mon do la cua nguoi choi, ho bo tien mua.
-- Lam mat no thi cai gia cua mot cu keo nham nang hon han cai loi.
local function onHousePickup()
  if S.house == nil then return end
  if GetTriggerUnit() ~= S.house then return end

  local it = GetManipulatedItem()
  if it == nil then return end

  -- Dat lai tai cho nha chinh. UnitRemoveItem tra mon ra khoi tui roi
  -- tha xuong ngay duoi chan unit, nen chi can goi no.
  if UnitRemoveItem ~= nil then
    UnitRemoveItem(S.house, it)
  elseif SetItemPosition ~= nil then
    SetItemPosition(it, GetUnitX(S.house), GetUnitY(S.house))
  end

  API.msg(nil, CFG.C_GREY .. API.t("house_no_items") .. CFG.C_END)
  API.trace("house: tu choi mon " ..
            ((GetItemName ~= nil) and GetItemName(it) or "?"))
end

-- Goi tu 08_events khi nha chinh chet. Day la dieu kien thua DUY NHAT.
local function onHouseDeath()
  if not S.running then return end
  if not CFG.HOUSE_DEATH_ENDS_GAME then return end
  API.endGame(false, CFG.HOUSE_NAME .. " da bi pha huy.")
end

-- Chua cho quai ra. Buoc nay chi xac nhan vung ton tai va nho lai.
local function resolveEnemyRegion()
  local r, realName = API.findRegion(CFG.RGN_ENEMY)
  if r == nil then
    API.regionMissing("CFG.RGN_ENEMY", API.regionLabel(CFG.RGN_ENEMY))
    return nil
  end
  S.enemyRgnName = realName

  S.enemyRect = r
  S.enemyX, S.enemyY = API.regionCenter(r)
  return r
end

-- Diem nay roi vao block nao cua luoi 5x5 -- de doi chieu vung ve tay
-- trong World Editor voi luoi logic.
local function blockLabel(x, y)
  if x == nil then return "-" end
  local col, row = API.blockAt(x, y)
  if col == nil then
    if API.inRiver(x, y) then return "duoi song" end
    return "ngoai luoi"
  end
  return "block #" .. API.blockIndex(col, row) .. " (" .. col .. "," .. row .. ")"
end

local function report()
  local rgns = API.listRegions()
  API.info(nil, CFG.C_GOLD .. "=== Vung & nha chinh ===" .. CFG.C_END)
  API.info(nil, "Vung WE thay duoc (" .. #rgns .. "): " .. table.concat(rgns, ", "))

  if S.house ~= nil then
    API.info(nil, "Nha chinh : " .. API.num(S.houseX) .. ", " .. API.num(S.houseY) ..
      "  -- " .. blockLabel(S.houseX, S.houseY) ..
      CFG.C_GREY .. "  [vung " .. tostring(S.houseRgnName) .. "]" .. CFG.C_END)
    API.info(nil, "  chu     : slot " .. CFG.HOUSE_SLOT ..
      ", dong minh voi " .. #S.pids .. " nguoi choi")
    API.info(nil, "  mau     : " .. API.num(GetUnitState(S.house, UNIT_STATE_MAX_LIFE)) ..
      (S.houseHpSet and "" or CFG.C_RED .. " (dat that bai: can 1.31+)" .. CFG.C_END))
    API.info(nil, "  tam nhin: " .. API.num(CFG.HOUSE_SIGHT) ..
      " qua " .. tostring(S.houseSightVia))
    API.info(nil, "  don danh: " ..
      (CFG.HOUSE_CAN_ATTACK and "con" or "khong tu nham (acquire range 0)"))
    API.info(nil, "  chet     : " ..
      (CFG.HOUSE_INVULNERABLE and (CFG.C_GOLD .. "bat tu, khong chet duoc" .. CFG.C_END)
       or (CFG.HOUSE_DEATH_ENDS_GAME and "thua ngay" or "khong sao")))
  end

  if S.enemyRect ~= nil then
    API.info(nil, "Vung dich : " .. API.num(S.enemyX) .. ", " .. API.num(S.enemyY) ..
      "  -- " .. blockLabel(S.enemyX, S.enemyY) ..
      CFG.C_GREY .. "  [vung " .. tostring(S.enemyRgnName) ..
      "]  (chua cho quai ra)" .. CFG.C_END)
  end
end

-- ---------- Cong dich chuyen: HeroMoveRegion -> nha chinh ----------
--
-- MOT CHIEU. Vung dich la nha chinh chu khong phai chinh vung nay, nen
-- khong co vong lap "vao roi lai bi day ve".
--
-- Su kien vao vung ban tren MOI may cung luc, nen viec doi vi tri o day
-- la dong bo san -- khong phai di qua kenh syncSend. Rieng keo camera
-- moi la viec cuc bo, va PanCameraToTimedForPlayer da nhan pid san.
-- Bao nhieu mon 'code' trong qua khoi dau. De cau thong bao doc duoc
-- so THAT thay vi go cung mot con so roi de no cu.
local function startCount(code)
  if CFG.START_ITEMS == nil then return 0 end
  for k = 1, #CFG.START_ITEMS do
    if CFG.START_ITEMS[k].code == code then
      return CFG.START_ITEMS[k].count or 0
    end
  end
  return 0
end

local function startHeroGate()
  local rMove, moveName = API.findRegion(CFG.RGN_HERO_MOVE)
  if rMove == nil then
    API.regionMissing("CFG.RGN_HERO_MOVE", API.regionLabel(CFG.RGN_HERO_MOVE))
    return
  end
  local rHouse = API.findRegion(CFG.RGN_HOUSE)
  if rHouse == nil then
    API.regionMissing("CFG.RGN_HOUSE", API.regionLabel(CFG.RGN_HOUSE))
    return
  end
  local hx, hy = API.regionCenter(rHouse)

  -- TriggerRegisterEnterRegion doi mot 'region', khong phai 'rect'.
  -- Vung cua World Editor la rect, nen phai boc lai mot lop.
  if CreateRegion == nil or RegionAddRect == nil
     or TriggerRegisterEnterRegion == nil then
    API.trace("gate: thieu CreateRegion/RegionAddRect/" ..
              "TriggerRegisterEnterRegion -- khong dat duoc cong")
    return
  end

  local rgn = CreateRegion()
  RegionAddRect(rgn, rMove)
  local t = CreateTrigger()
  TriggerRegisterEnterRegion(t, rgn, nil)
  TriggerAddAction(t, function()
    local u = GetTriggerUnit()
    if u == nil then return end
    -- CHI hero cua nguoi choi. Quai, pet va nha chinh cung di qua day
    -- duoc, ma dich chuyen chung thi tran dau loan het.
    local pid = (API.heroPidOf ~= nil) and API.heroPidOf(u) or nil
    if pid == nil then return end

    local x, y = API.heroFanPoint(pid, hx, hy, CFG.HERO_SPAWN_OFFSET)
    SetUnitPosition(u, x, y)

    -- Keo pet theo. Khong keo thi no chay bo ca ban do, va con duong do
    -- di qua bai quai.
    local d = S.p[pid]
    if d ~= nil and d.pet ~= nil and SetUnitPosition ~= nil then
      SetUnitPosition(d.pet, x, y)
    end

    if PanCameraToTimedForPlayer ~= nil then
      PanCameraToTimedForPlayer(Player(pid), x, y, 0.0)
    end

    -- Qua khoi dau -- CHI LAN DAU moi nguoi.
    --
    -- Cong nay nam ngay duoi cho hero hien ra: di ra di vao mat ba
    -- giay. Phat moi lan la mot cai may in luot quay va binh thuoc vo
    -- han, va luc do he Co Duyen mat het y nghia. Mot co duy nhat
    -- (d.gateGift) canh ca hai phan qua.
    if d ~= nil and not d.gateGift then
      d.gateGift = true

      if CFG.LUMBER_START ~= nil and CFG.LUMBER_START > 0
         and API.addLumber ~= nil then
        API.addLumber(pid, CFG.LUMBER_START)
      end

      local iron = CFG.IRON_START or 0
      if iron > 0 and API.addIron ~= nil then API.addIron(pid, iron) end

      -- Vat pham truoc, luot quay sau: neu tui day thi shopGive bao
      -- ngay, con nguoi choi van thay dong thuong quay o duoi.
      if CFG.START_ITEMS ~= nil and API.shopGive ~= nil then
        for k = 1, #CFG.START_ITEMS do
          local q = CFG.START_ITEMS[k]
          API.shopGive(pid, q.code, q.count)
        end
        -- DOC lai so that tu CFG.START_ITEMS chu khong go vao cau chu.
        -- Go vao chu thi doi CFG.TOWER_START tu 2 len 3 la cau thong
        -- bao noi doi -- va no noi doi IM LANG, khong ai kiem duoc.
        API.msg(pid, CFG.C_JADE .. API.t("gate_gift",
          startCount("hp"), startCount("mp"),
          startCount("tower"), iron) .. CFG.C_END)
      end

      local n = CFG.GATE_ROLL or 0
      if n > 0 and API.fortuneAddRolls ~= nil then
        API.fortuneAddRolls(pid, n)
        API.msg(pid, CFG.C_GOLD .. API.t("gate_roll", n) .. CFG.C_END)
      end
    end

    API.trace("gate: pid " .. pid .. " tu " .. moveName .. " -> nha chinh")
  end)
  S.heroGate = t
  API.trace("gate: " .. moveName .. " -> " .. (S.houseRgnName or "nha chinh"))
end

API.startHeroGate      = startHeroGate
API.blockLabel         = blockLabel
API.createHouse        = createHouse
API.onHouseDeath       = onHouseDeath
API.onHousePickup      = onHousePickup
API.resolveEnemyRegion = resolveEnemyRegion
API.setHouseHP         = setHouseHP
API.report             = report
