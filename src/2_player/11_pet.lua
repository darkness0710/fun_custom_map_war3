-- ============================================================
--  2_player/11_pet.lua -- Pet di theo hero
--
--  BAN DAU: thuan trang tri. Khong danh, khong an don, khong chi so.
--  O Pet trong the Trang Bi (CFG.GEAR_PET_SLOT) da de san cho no tu
--  truoc; day moi la con vat that ngoai map.
--
--  BA THU PHAI CO, va deu co ly do:
--    Locust (Aloc)  khong chon duoc, khong bi nham muc tieu, khong va
--                   cham -- pet di xuyen qua quan chu khong chen duong
--    bat tu         Locust da chan phan lon, nhung don DIEN RONG (Chan
--                   Dia cua boss) van cham toi; chet mot cai la pet bien
--                   mat giua tran ma khong ai hieu vi sao
--    SuspendHeroXP  Hmkg la unit HERO. Khong khoa thi pet len cap, hien
--                   bang chon chieu, va an mat kinh nghiem cua nguoi choi
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- ---------- Tao ----------

local function remove(pid)
  local d = S.p[pid]
  if d == nil or d.pet == nil then return end
  RemoveUnit(d.pet)
  d.pet = nil
end

local function spawn(pid)
  local cfg = CFG.PET
  if cfg == nil then return nil end

  local d = S.p[pid]
  if d == nil or d.hero == nil then return nil end

  -- Con da THU PHUC de len con mac dinh. Ha Thanh Thu nao thi pet thanh
  -- con do, va ghi de con dang co -- moi luc mot pet.
  local uid = d.petUnit or cfg.unit
  if uid == nil then
    -- Chua thu phuc con nao. Khong phai loi -- chi la chua co pet.
    return nil
  end

  -- Doi hero thi bo con cu di, neu khong moi lan doi la them mot con.
  remove(pid)

  local hx, hy = GetUnitX(d.hero), GetUnitY(d.hero)
  local x = API.polarX(hx, cfg.spawnOffset or 120.0, 225.0)
  local y = API.polarY(hy, cfg.spawnOffset or 120.0, 225.0)
  x, y = API.clampToMap(x, y)

  -- Chu so huu trung lap: xem chu thich CFG.PET.neutral. bj_PLAYER_-
  -- NEUTRAL_EXTRA la slot ma chinh du an nay da dung cho model hero o
  -- bang chon tuong -- duong da di roi, khong phai doan.
  local owner = Player(pid)
  if cfg.neutral then
    local slot = _G["bj_PLAYER_NEUTRAL_EXTRA"]
    if slot ~= nil then
      owner = Player(slot)
    else
      API.trace("pet: khong co bj_PLAYER_NEUTRAL_EXTRA -- pet se hien o " ..
                "thanh hero cua nguoi choi")
    end
  end

  local u = CreateUnit(owner, uid, x, y, GetUnitFacing(d.hero))
  if u == nil then
    API.trace("pet: CreateUnit tra ve nil -- kiem id trong CFG.PET")
    return nil
  end

  -- Locust: them NGAY sau khi tao. Them muon hon thi unit da kip nam
  -- trong danh sach chon duoc cua nguoi choi va Locust khong go ra.
  local locustId = cfg.locust
  if locustId ~= nil and UnitAddAbility ~= nil then
    if not UnitAddAbility(u, locustId) then
      API.trace("pet: KHONG them duoc Locust (" .. API.idToStr(locustId) ..
                ") -- pet se chon duoc")
    end
    -- Khoa lai de khong ai go ra duoc, va de no khong hien o bang chieu.
    if UnitMakeAbilityPermanent ~= nil then
      UnitMakeAbilityPermanent(u, true, locustId)
    end
  else
    API.trace("pet: thieu CFG.PET.locust hoac UnitAddAbility")
  end

  if SetUnitInvulnerable ~= nil then SetUnitInvulnerable(u, true) end
  if SuspendHeroXP ~= nil then SuspendHeroXP(u, true) end

  SetUnitScale(u, cfg.scale, cfg.scale, cfg.scale)

  -- Tra lai mau cua nguoi choi. Doi chu sang trung lap thi pet mang mau
  -- trung lap, va ba nguoi choi se co ba con pet giong het nhau -- khong
  -- ai biet con nao cua minh.
  if cfg.neutral and SetUnitColor ~= nil and GetPlayerColor ~= nil then
    SetUnitColor(u, GetPlayerColor(Player(pid)))
  end

  -- Khong cho no tu di danh: pet ban dau la trang tri, ma mot con tu
  -- lao vao quai thi nguoi choi se tuong no co tham gia danh.
  if SetUnitAcquireRange ~= nil then SetUnitAcquireRange(u, 0.0) end

  d.pet = u
  API.trace("pet: pid " .. pid .. " -> " .. API.idToStr(uid) ..
            " (scale " .. cfg.scale .. ")")
  return u
end

-- ---------- Di theo ----------
--
-- Ra lenh CHI KHI di qua xa. Ra lenh moi nhip thi lenh sau huy lenh
-- truoc, pet dung khong nhuc nhich -- loi kinh dien cua pet trong WC3.
local function follow()
  local cfg = CFG.PET
  if cfg == nil then return end
  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d = S.p[pid]
    if d ~= nil and d.pet ~= nil then
      if not API.alive(d.pet) or d.hero == nil or not API.alive(d.hero) then
        -- Hero chet thi pet dung yen cho, khong chay ve xac.
      else
        local px, py = GetUnitX(d.pet), GetUnitY(d.pet)
        local hx, hy = GetUnitX(d.hero), GetUnitY(d.hero)
        local dx, dy = hx - px, hy - py
        if dx * dx + dy * dy > cfg.near * cfg.near then
          -- Dung lai o RIA vong tron chu khong dam vao giua hero.
          local a = API.angleXY(hx, hy, px, py)
          IssuePointOrder(d.pet, "move",
                          API.polarX(hx, cfg.near * 0.6, a),
                          API.polarY(hy, cfg.near * 0.6, a))
        end
      end
    end
  end
end

-- ---------- Khoi dong ----------

-- Doi sang con KE TIEP trong so nhung con da thu phuc. Vong lai.
--
-- Chay tu syncOn nen co tren MOI may: pet la unit that, khong phai thu
-- cuc bo -- tao tren mot may thi chi may do thay.
local function cycle(pid)
  local d = S.p[pid]
  local list = CFG.SIDE_QUESTS or {}
  if d == nil or d.petOwn == nil or #list == 0 then return end

  -- Tu con DANG deo tro di, tim con tiep theo da thu phuc.
  local from = 0
  for i = 1, #list do
    if list[i].unit == d.petUnit then from = i end
  end
  for k = 1, #list do
    local i = ((from - 1 + k) % #list) + 1
    if d.petOwn[i] then
      d.petUnit = list[i].unit
      spawn(pid)
      API.panelRefresh(pid)
      return
    end
  end
end

-- Dong trong CFG.SIDE_QUESTS cua con DANG di theo. nil = chua co con nao.
--
-- Mot cho tra duy nhat cho ca ten lan chan dung. Truoc day chi co ten,
-- con chan dung thi the Trang Bi treo CFG.GEAR_PET_ICON co dinh -- nen
-- doi pet xong o van hien Chu Tuoc.
local function defOf(pid)
  local d = S.p[pid]
  if d == nil or d.petUnit == nil then return nil end
  for i = 1, #(CFG.SIDE_QUESTS or {}) do
    if CFG.SIDE_QUESTS[i].unit == d.petUnit then return CFG.SIDE_QUESTS[i] end
  end
  return nil
end

-- Ten con dang di theo, cho the Trang Bi. nil = chua co con nao.
local function label(pid)
  local q = defOf(pid)
  return (q ~= nil) and API.pick(q) or nil
end

-- Chan dung con dang di theo. nil = de cho goi tu quyet dinh duong lui
-- (CFG.GEAR_PET_ICON), chu KHONG tu tra duong lui o day: o goi con phan
-- biet "chua co pet" voi "co pet nhung thieu file anh".
local function iconOf(pid)
  local q = defOf(pid)
  return (q ~= nil) and q.icon or nil
end

local function ownedCount(pid)
  local d = S.p[pid]
  if d == nil or d.petOwn == nil then return 0 end
  local n = 0
  for i = 1, #(CFG.SIDE_QUESTS or {}) do
    if d.petOwn[i] then n = n + 1 end
  end
  return n
end

local function startPet()
  if CFG.PET == nil then
    API.trace("pet: CFG.PET khong co -- bo qua")
    return
  end

  -- LIEN MINH, dat mot lan luc khoi dong.
  --
  -- Pet thuoc ve mot phe trung lap de no khong hien o thanh hero cua
  -- nguoi choi. Nhung trung lap trong Warcraft KHONG mac dinh la than
  -- thien -- bj_PLAYER_NEUTRAL_EXTRA la phe THU DICH, va pet da danh
  -- nguoi choi that. Phai noi ro ra, ca hai chieu.
  local slot = _G["bj_PLAYER_NEUTRAL_EXTRA"]
  if CFG.PET.neutral and slot ~= nil and SetPlayerAllianceStateBJ ~= nil then
    local owner = Player(slot)
    for i = 1, #S.pids do
      local p = Player(S.pids[i])
      SetPlayerAllianceStateBJ(owner, p, bj_ALLIANCE_ALLIED_VISION)
      SetPlayerAllianceStateBJ(p, owner, bj_ALLIANCE_ALLIED_VISION)
    end

    -- VA VOI PHE DICH NUA -- day la cho thieu.
    --
    -- LOI DA SHIP: doan tren chi noi quan he voi NGUOI CHOI, nen pet va
    -- quai van la ke thu cua nhau. Hai hau qua, va ca hai deu nhin ra
    -- duoc ma khong ai doan duoc nguyen nhan:
    --
    --   quai NHAM VAO PET. Pet bat tu nen chung khong giet duoc, nhung
    --   chung dung lai va vung vao no -- pet thanh mot cai moc keo quai
    --   khong ai dinh dat o do.
    --
    --   pet DANH TRA. SetUnitAcquireRange(0) chan viec TU DI TIM muc
    --   tieu, no khong chan viec danh tra khi bi danh. Nen chi can mot
    --   con quai vung truoc la pet lao theo.
    --
    -- NEUTRAL chu khong ALLIED: hai phe thoi nham vao nhau, va khong
    -- ben nao chia tam nhin cho ben nao. Dung ALLIED_VISION o day thi
    -- nguoi choi -- von da lien minh-co-tam-nhin voi phe pet -- co the
    -- nhin xuyen sang ca ban do dich.
    local neutral = _G["bj_ALLIANCE_NEUTRAL"] or _G["bj_ALLIANCE_ALLIED"]
    if S.enemy ~= nil and neutral ~= nil then
      SetPlayerAllianceStateBJ(owner, S.enemy, neutral)
      SetPlayerAllianceStateBJ(S.enemy, owner, neutral)
    else
      API.trace("pet: KHONG dat duoc quan he voi phe dich -- pet se bi " ..
                "quai nham vao va se danh tra")
    end

    API.trace("pet: phe " .. slot .. " lien minh voi " .. #S.pids ..
              " nguoi choi, trung lap voi phe dich")
  end
  S.petTimer = CreateTimer()
  TimerStart(S.petTimer, CFG.PET.tick, true, follow)
  API.syncOn(CFG.OP_PET, function(pid) cycle(pid) end)
  API.trace("pet: san sang, nhip " .. CFG.PET.tick .. "s")
end

API.petCycle  = cycle
API.petLabel  = label
API.petIcon   = iconOf
API.petOwned  = ownedCount
API.petSpawn  = spawn
API.petRemove = remove
API.startPet  = startPet
