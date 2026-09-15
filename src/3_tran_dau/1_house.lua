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
    API.msg(nil, CFG.C_RED .. "CreateUnit that bai -- kiem tra CFG.HOUSE_UNIT." .. CFG.C_END)
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

  API.trace("house: XONG")
  return S.house
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
  API.msg(nil, CFG.C_GOLD .. "=== Vung & nha chinh ===" .. CFG.C_END)
  API.msg(nil, "Vung WE thay duoc (" .. #rgns .. "): " .. table.concat(rgns, ", "))

  if S.house ~= nil then
    API.msg(nil, "Nha chinh : " .. API.num(S.houseX) .. ", " .. API.num(S.houseY) ..
      "  -- " .. blockLabel(S.houseX, S.houseY) ..
      CFG.C_GREY .. "  [vung " .. tostring(S.houseRgnName) .. "]" .. CFG.C_END)
    API.msg(nil, "  chu     : slot " .. CFG.HOUSE_SLOT ..
      ", dong minh voi " .. #S.pids .. " nguoi choi")
    API.msg(nil, "  mau     : " .. API.num(GetUnitState(S.house, UNIT_STATE_MAX_LIFE)) ..
      (S.houseHpSet and "" or CFG.C_RED .. " (dat that bai: can 1.31+)" .. CFG.C_END))
    API.msg(nil, "  tam nhin: " .. API.num(CFG.HOUSE_SIGHT) ..
      " qua " .. tostring(S.houseSightVia))
    API.msg(nil, "  don danh: " ..
      (CFG.HOUSE_CAN_ATTACK and "con" or "khong tu nham (acquire range 0)"))
    API.msg(nil, "  chet     : " ..
      (CFG.HOUSE_INVULNERABLE and (CFG.C_GOLD .. "bat tu, khong chet duoc" .. CFG.C_END)
       or (CFG.HOUSE_DEATH_ENDS_GAME and "thua ngay" or "khong sao")))
  end

  if S.enemyRect ~= nil then
    API.msg(nil, "Vung dich : " .. API.num(S.enemyX) .. ", " .. API.num(S.enemyY) ..
      "  -- " .. blockLabel(S.enemyX, S.enemyY) ..
      CFG.C_GREY .. "  [vung " .. tostring(S.enemyRgnName) ..
      "]  (chua cho quai ra)" .. CFG.C_END)
  end
end

API.blockLabel         = blockLabel
API.createHouse        = createHouse
API.onHouseDeath       = onHouseDeath
API.resolveEnemyRegion = resolveEnemyRegion
API.setHouseHP         = setHouseHP
API.report             = report
