-- ============================================================
--  2_heropick.lua  --  Chon hero bang popup
--
--  Thay cho Tavern. Ly do: CreateUnit bo qua toan bo techtree --
--  khong requirement Altar, khong gia vang/go, khong luong thuc,
--  khong quay hang, khong dong ho hoi hang. Ban Tavern phai chong do
--  ca nam thu do bang nam cho va tam; popup thi khong can cai nao.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Nhung hero chua ai lay.
local function available()
  local out = {}
  for i = 1, #CFG.HEROES do
    local h = CFG.HEROES[i]
    if not (CFG.HERO_UNIQUE and S.heroTaken[h.id]) then
      out[#out + 1] = h
    end
  end
  return out
end

local function heroDef(uid)
  for i = 1, #CFG.HEROES do
    if CFG.HEROES[i].id == uid then return CFG.HEROES[i] end
  end
  return nil
end

-- So thu tu trong CFG.HEROES. Kenh dong bo chi cho gui so duoi 100000,
-- ma id kieu FourCC thi hon mot ti -- nen gui so thu tu roi tra nguoc
-- ra id o dau ben kia. Xem src/1_nen/3_sync.lua.
local function heroIndex(uid)
  for i = 1, #CFG.HEROES do
    if CFG.HEROES[i].id == uid then return i end
  end
  return nil
end

-- Gan ky nang luc tao. Ghi lai id nao gan that bai -- UnitAddAbility
-- tra ve false khi id khong ton tai, va that bai im lang kieu do la
-- thu kho phat hien nhat.
local function giveAbilities(u, uid)
  local def = heroDef(uid)
  local list = {}

  for i = 1, #CFG.HERO_COMMON_ABILITIES do
    list[#list + 1] = CFG.HERO_COMMON_ABILITIES[i]
  end
  if def ~= nil and def.abilities ~= nil then
    for i = 1, #def.abilities do list[#list + 1] = def.abilities[i] end
  end

  -- Ky nang hero: CHI nhung cai da mo khoa. Khong hoc bang diem, mua
  -- bang Linh Khi trong bang phim E. Xem
  -- docs/03-du-lieu/nang-cap-ky-nang.md
  local sk = CFG.SKILLS[uid]
  if sk ~= nil then
    local n = CFG.SKILL_START_COUNT
    if n > #sk then n = #sk end
    for i = 1, n do list[#list + 1] = sk[i].id end
  end

  local bad = {}
  for i = 1, #list do
    if UnitAddAbility(u, list[i]) then
      -- Ability nhan ban tu HERO ability ra o cap 0: nut hien nhung bam
      -- khong duoc. Ability thuong von da cap 1, goi them la vo hai.
      SetUnitAbilityLevel(u, list[i], 1)
    else
      bad[#bad + 1] = API.idToStr(list[i])
    end
  end

  if #bad > 0 then
    API.msg(nil, CFG.C_RED .. "Khong gan duoc ability: " ..
      table.concat(bad, " ") .. CFG.C_END)
  end
  API.trace("abil gan cho " .. GetUnitName(u) .. ": " .. (#list - #bad) ..
            "/" .. #list)
end

local function heroNameOf(uid)
  for i = 1, #CFG.HEROES do
    if CFG.HEROES[i].id == uid then return CFG.HEROES[i].name end
  end
  return "?"
end

local function slotIndex(pid)
  for i = 1, #S.pids do
    if S.pids[i] == pid then return i end
  end
  return 1
end

-- Hero sinh quanh nha chinh, moi nguoi mot huong de khong chong len nhau.
local function spawnHero(pid, uid)
  local cx, cy = S.houseX, S.houseY
  if cx == nil then cx, cy = API.blockCenter(3, 3) end

  local n = #S.pids
  if n < 1 then n = 1 end
  local ang = (360.0 / n) * (slotIndex(pid) - 1)
  local x = API.polarX(cx, CFG.HERO_SPAWN_OFFSET, ang)
  local y = API.polarY(cy, CFG.HERO_SPAWN_OFFSET, ang)
  x, y = API.clampToMap(x, y)

  local u = CreateUnit(Player(pid), uid, x, y, ang + 180.0)
  if u ~= nil then
    API.lockHero(u)
    giveAbilities(u, uid)
    API.linhCanApply(pid, u)   -- giu tu vi khi doi hero
    API.skillApply(pid)        -- dat lai bac cho dung bang da mua
    API.waveReadyCheck()       -- du nguoi thi vao dot 1 ngay, khoi cho
    if CFG.SKILL_MODE == "learn" then
      API.grantSkillPoints(u, CFG.SKILL_POINTS_START)
    end
    SelectUnitAddForPlayer(u, Player(pid))
    PanCameraToTimedForPlayer(Player(pid), x, y, 0.0)
  end
  return u
end

local function hidePicker(pid)
  local slot = S.pick[pid]
  if slot ~= nil and slot.dlg ~= nil then
    DialogDisplay(Player(pid), slot.dlg, false)
  end
end

-- Dung lai popup cho mot nguoi. Goi lai moi khi danh sach doi -- nguoi
-- khac vua lay mat mot con thi con do phai bien khoi popup cua ta.
local function showPicker(pid)
  local d = S.p[pid]
  if d == nil or not d.active then return end
  if CFG.HERO_MAX_PER_PLAYER > 0 and d.heroCount >= CFG.HERO_MAX_PER_PLAYER then
    hidePicker(pid)
    return
  end

  local list = available()
  if #list == 0 then
    hidePicker(pid)
    API.msg(pid, CFG.C_RED .. "Khong con hero nao de chon." .. CFG.C_END)
    return
  end

  local slot = S.pick[pid]
  if slot == nil then
    slot = { dlg = DialogCreate(), map = {} }
    S.pick[pid] = slot
    TriggerRegisterDialogEvent(S.pickTrigger, slot.dlg)
  end

  -- DialogClear huy cac nut cu, nen bang anh xa phai dung lai tu dau.
  DialogClear(slot.dlg)
  slot.map = {}
  DialogSetMessage(slot.dlg, API.t("pick_title"))
  for i = 1, #list do
    local btn = DialogAddButton(slot.dlg, list[i].name, 0)
    slot.map[btn] = list[i].id
  end

  DialogDisplay(Player(pid), slot.dlg, true)
end

-- ---------- Dieu huong: popup chu hay giao dien card ----------
-- Hai duong cung dung mot logic chon hero ben duoi; chi khac cach ve.

local function pickerShow(pid)
  if CFG.HERO_PICK_MODE == "frame" and API.showHeroFrame ~= nil then
    return API.showHeroFrame(pid)
  end
  return showPicker(pid)
end

local function pickerHide(pid)
  if API.hideHeroFrame ~= nil then API.hideHeroFrame(pid) end
  hidePicker(pid)
end

-- Hien lai cho nhung nguoi chua chon, sau khi danh sach thay doi -- ai
-- do vua lay mat mot con thi con do phai bien khoi man hinh nguoi khac.
local function refreshOthers(exceptPid)
  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d = S.p[pid]
    if pid ~= exceptPid and d ~= nil and d.hero == nil then
      pickerShow(pid)
    end
  end
end

-- Ap dung mot lua chon hero.
--
-- Day la NOI DUY NHAT doi trang thai khi chon hero. Ca popup dialog lan
-- giao dien card deu goi vao day, nen luat "moi nguoi mot con, khong ai
-- lay trung" chi ton tai o mot cho.
--
-- Voi giao dien card, ham nay duoc goi tu su kien DONG BO nen no chay
-- tren moi may. Voi dialog thi su kien von da dong bo san.
local function applyHeroPick(pid, uid)
  local d = S.p[pid]
  if d == nil then return false end

  if CFG.HERO_MAX_PER_PLAYER > 0 and d.heroCount >= CFG.HERO_MAX_PER_PLAYER then
    pickerHide(pid)
    return false
  end

  -- Hai nguoi bam cung mot con: nguoi den sau roi vao day.
  if CFG.HERO_UNIQUE and S.heroTaken[uid] then
    API.msg(pid, CFG.C_RED .. heroNameOf(uid) .. " vua co nguoi lay mat." .. CFG.C_END)
    pickerShow(pid)
    return false
  end

  local u = spawnHero(pid, uid)
  if u == nil then
    API.msg(pid, CFG.C_RED .. "Khong tao duoc hero -- kiem tra id trong CFG.HEROES."
      .. CFG.C_END)
    pickerShow(pid)
    return false
  end

  d.hero = u
  d.heroCount = d.heroCount + 1
  if CFG.HERO_UNIQUE then S.heroTaken[uid] = true end
  pickerHide(pid)

  API.msg(nil, API.t("pick_done",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. heroNameOf(uid) .. CFG.C_END))

  refreshOthers(pid)
  return true
end

local function onPick()
  local pid  = GetPlayerId(GetTriggerPlayer())
  local slot = S.pick[pid]
  if slot == nil then return end

  local uid = slot.map[GetClickedButton()]
  if uid == nil then return end

  applyHeroPick(pid, uid)
end

local function startPicking()
  S.pickTrigger = CreateTrigger()
  TriggerAddAction(S.pickTrigger, onPick)

  API.after(CFG.PICK_DELAY, function()
    for i = 1, #S.pids do pickerShow(S.pids[i]) end
    API.trace("heropick: da hien bang chon cho " .. #S.pids .. " nguoi (che do " ..
              tostring(CFG.HERO_PICK_MODE) .. ")")
  end)
end


-- ============================================================
--  Chon ky nang theo slot
--
--  Moi slot la mot o trong command card. Nguoi choi chon mot ability
--  trong so ung vien cua slot do, va no duoc gan thang bang
--  UnitAddAbility -- khong ton diem ky nang, khong can Techtree.
--
--  Han che phai biet: nut popup cua Warcraft III chi hien CHU, khong
--  hien icon. Muon co icon thi phai dung nut + goc (Techtree - Hero
--  Abilities), va luc do slot do vi tri nut cua ability quyet dinh chu
--  khong phai nguoi choi chon.
-- ============================================================

-- Cay skill cua hero nguoi choi dang cam, lui ve cay chung neu hero do
-- khong khai bao rieng.
local function slotsFor(pid)
  local d = S.p[pid]
  if d ~= nil and d.hero ~= nil then
    local def = heroDef(GetUnitTypeId(d.hero))
    if def ~= nil and def.skills ~= nil and #def.skills > 0 then
      return def.skills
    end
  end
  return CFG.SKILL_SLOTS
end

local function slotDone(d, i)
  return d.slots ~= nil and d.slots[i] ~= nil
end

local function nextEmptySlot(d, slots)
  for i = 1, #slots do
    if not slotDone(d, i) then return i end
  end
  return nil
end

local function hideSkillPicker(pid)
  local sp = S.skillPick[pid]
  if sp ~= nil and sp.dlg ~= nil then
    DialogDisplay(Player(pid), sp.dlg, false)
  end
end

local function showSkillPicker(pid)
  local d = S.p[pid]
  if d == nil or not d.active then return false end

  if d.hero == nil then
    API.msg(pid, CFG.C_RED .. "Chua co hero de gan ky nang." .. CFG.C_END)
    return false
  end
  local slots = slotsFor(pid)
  if #slots == 0 then
    API.msg(pid, CFG.C_RED .. "Hero nay chua khai bao cay skill nao." .. CFG.C_END)
    return false
  end

  local si = nextEmptySlot(d, slots)
  if si == nil then
    hideSkillPicker(pid)
    API.msg(pid, CFG.C_GOLD .. "Da chon du " .. #slots .. " slot ky nang."
      .. CFG.C_END)
    return false
  end

  local slot = slots[si]
  local sp = S.skillPick[pid]
  if sp == nil then
    sp = { dlg = DialogCreate(), map = {}, slot = si }
    S.skillPick[pid] = sp
    TriggerRegisterDialogEvent(S.skillTrigger, sp.dlg)
  end
  sp.slot = si

  DialogClear(sp.dlg)
  sp.map = {}
  DialogSetMessage(sp.dlg, slot.name or ("Slot " .. si))
  for i = 1, #slot.choices do
    local c = slot.choices[i]
    local btn = DialogAddButton(sp.dlg, c.name, 0)
    sp.map[btn] = c.id
  end

  DialogDisplay(Player(pid), sp.dlg, true)
  return true
end

local function onSkillPick()
  local p   = GetTriggerPlayer()
  local pid = GetPlayerId(p)
  local sp  = S.skillPick[pid]
  if sp == nil then return end

  local aid = sp.map[GetClickedButton()]
  if aid == nil then return end

  local d = S.p[pid]
  if d == nil or d.hero == nil then return end

  if not UnitAddAbility(d.hero, aid) then
    API.msg(pid, CFG.C_RED .. "Khong gan duoc ability " .. API.idToStr(aid) ..
      " -- id sai, hoac unit khong nhan duoc ability nay." .. CFG.C_END)
    showSkillPicker(pid)
    return
  end

  -- HERO ability gan thang bang UnitAddAbility ra o CAP 0: nut hien
  -- nhung bam khong duoc. Phai nang len cap 1 moi dung duoc.
  -- Ability thuong von da o cap 1, goi them la vo hai.
  SetUnitAbilityLevel(d.hero, aid, 1)

  d.slots[sp.slot] = aid
  hideSkillPicker(pid)
  API.msg(pid, CFG.C_GOLD .. "Da hoc " .. CFG.C_JADE ..
    (slotsFor(pid)[sp.slot].name or "?") .. CFG.C_END .. ".")

  if CFG.SKILL_PICK_CHAIN then showSkillPicker(pid) end
end

local function startSkillPicking()
  S.skillTrigger = CreateTrigger()
  TriggerAddAction(S.skillTrigger, onSkillPick)
end

-- ---------- Nap truoc model hero ----------
--
-- Warcraft nap model cua nhung LOAI unit co mat tren map luc vao game.
-- Loai nao khong xuat hien o dau thi model nap theo yeu cau -- va model
-- tu import nap kieu do thi hong: unit hien ra den si, khong loi nao bao.
--
-- Do duoc: cung mot H001, con dat san trong World Editor thi co mau, con
-- tao bang CreateUnit luc chay thi den.
--
-- Cach chua: tao mot con moi loai luc khoi dong roi xoa ngay. Engine da
-- nap model roi thi lan tao sau khong con phai nap theo yeu cau nua.
local function preloadHeroes()
  local x, y = API.blockCenter(3, 3)
  local n = 0
  for i = 1, #CFG.HEROES do
    local u = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), CFG.HEROES[i].id,
                         x, y, 270.0)
    if u ~= nil then
      ShowUnit(u, false)
      RemoveUnit(u)
      n = n + 1
    end
  end
  API.trace("heropick: nap truoc model cho " .. n .. "/" .. #CFG.HEROES .. " hero")
end

API.preloadHeroes     = preloadHeroes
API.heroesAvailable   = available
API.heroNameOf        = heroNameOf
API.heroDef           = heroDef
API.heroIndex         = heroIndex
API.applyHeroPick     = applyHeroPick
API.pickerShow        = pickerShow
API.slotsFor          = slotsFor
API.showSkillPicker   = showSkillPicker
API.startSkillPicking = startSkillPicking

local function report()
  API.msg(nil, CFG.C_GOLD .. "=== Chon hero ===" .. CFG.C_END)
  API.msg(nil, #CFG.HEROES .. " hero  |  moi nguoi toi da " ..
    CFG.HERO_MAX_PER_PLAYER .. "  |  " ..
    (CFG.HERO_UNIQUE and "khong trung nhau" or "duoc trung nhau"))
  API.msg(nil, "Popup hien sau " .. CFG.PICK_DELAY .. "s, hero sinh cach nha chinh " ..
    API.num(CFG.HERO_SPAWN_OFFSET))
end

API.showPicker    = showPicker
API.startPicking  = startPicking
API.heroPickReport = report
