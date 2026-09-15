-- ============================================================
--  1_events.lua  --  Trigger
--
--  Hai viec: nha chinh chet, va chan nguoi choi chon nha chinh.
--  Su kien popup chon hero do 07_heropick tu dang ky lay.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function onAnyDeath()
  local u = GetTriggerUnit()
  if u == nil then return end
  if u == S.house then
    API.onHouseDeath()
    return
  end
  API.onMobDeath(u, GetKillingUnit())
end

-- Nha chinh la muc tieu phai giu, khong phai quan de dieu khien. Lot
-- vao Ctrl+A roi lo ra lenh cho no la hong ca van.
--
-- Warcraft III khong co cach danh dau mot unit la "khong chon duoc" ma
-- van cho ke dich danh -- ability Locust lam no vo hinh voi ca hai phia,
-- ma nha chet la thua nen khong dung duoc. Nen phai bo chon thu cong.
local function onSelect()
  if CFG.HOUSE_SELECTABLE then return end
  if S.house == nil or GetTriggerUnit() ~= S.house then return end

  local p = GetTriggerPlayer()
  -- Hoan sang tick sau: doi trang thai ngay trong su kien cua engine la
  -- cong thuc gay loi, xem ADR 0005.
  API.after(0.0, function()
    if S.house ~= nil then SelectUnitRemoveForPlayer(S.house, p) end
  end)
end

-- Lenh thu: "-sp" phat mot diem ky nang cho hero cua nguoi go.
--
-- Tra loi TRONG MOI TRUONG HOP. Lenh thu im lang la thu vo dung nhat:
-- khong biet no that bai hay khong duoc dang ky.
local function onChat()
  local pid = GetPlayerId(GetTriggerPlayer())
  local d = S.p[pid]

  if d == nil then
    API.msg(pid, CFG.C_RED .. "-sp: ban khong nam trong danh sach nguoi choi." .. CFG.C_END)
    return
  end
  if d.hero == nil then
    API.msg(pid, CFG.C_RED .. "-sp: ban chua chon hero." .. CFG.C_END)
    return
  end
  if CFG.SKILL_MODE == "learn" then
    if API.grantSkillPoints(d.hero, 1) then
      API.msg(pid, CFG.C_GOLD .. "-sp: +1 diem ky nang." .. CFG.C_END ..
        " Bam nut + tren hero de chon.")
      API.msg(pid, CFG.C_GREY .. "Khong thay nut + nghia la Techtree - Hero" ..
        " Abilities cua hero con rong." .. CFG.C_END)
    else
      API.msg(pid, CFG.C_RED .. "-sp: UnitModifySkillPoints tu choi." .. CFG.C_END)
    end

  elseif CFG.SKILL_MODE == "pick" then
    API.showSkillPicker(pid)

  elseif CFG.SKILL_MODE == "frame" then
    API.showSkillFrame(pid)

  else
    API.msg(pid, CFG.C_RED .. "-sp: SKILL_MODE dang la \"" ..
      tostring(CFG.SKILL_MODE) .. "\" -- doi sang \"learn\", \"pick\" hoac \"frame\"."
      .. CFG.C_END)
  end
end

-- Lenh dev "-wave N": nhay thang toi stage N.
-- Khong co no thi khong ai kiem duoc stage 180 -- doi 2 tieng de xem
-- mot con so khong phai la cach lam viec.
local function onWaveCmd()
  local pid = GetPlayerId(GetTriggerPlayer())
  local raw = GetEventPlayerChatString()
  if raw == nil then return end

  local n = tonumber(raw:match("^%s*%-wave%s+(%d+)"))
  if n == nil then
    API.msg(pid, CFG.C_RED .. "Dung: -wave <so tu 1 den " ..
      API.totalStages() .. ">" .. CFG.C_END)
    return
  end
  API.jumpToStage(n)
  API.msg(pid, CFG.C_GOLD .. "Nhay toi stage " .. n .. "." .. CFG.C_END)
end

-- "-lc" mo bang Linh Can, "-lc up" dot pha thang khong can bang.
local function onLinhCanCmd()
  API.linhCanChat(GetPlayerId(GetTriggerPlayer()), GetEventPlayerChatString())
end

-- Lenh dev cho tien: "-lk 50000" them linh khi, "-tt 300" them tinh thach.
-- Khong co no thi muon thu bac Linh Can 15 phai cay 155 wave.
local function onMoneyCmd()
  local pid = GetPlayerId(GetTriggerPlayer())
  local raw = GetEventPlayerChatString()
  if raw == nil then return end

  local n = tonumber(raw:match("^%s*%-lk%s+(%d+)"))
  if n ~= nil then
    API.addLinhKhi(pid, n)
    API.msg(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " linh khi -> " ..
      API.num(API.getLinhKhi(pid)) .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  n = tonumber(raw:match("^%s*%-tt%s+(%d+)"))
  if n ~= nil then
    API.addTinhThach(pid, n)
    API.msg(pid, CFG.C_GREY .. "[dev] +" .. API.num(n) .. " tinh thach -> " ..
      API.num(API.getTinhThach(pid)) .. CFG.C_END)
    return
  end

  API.msg(pid, CFG.C_RED .. "Dung: -lk <so>  hoac  -tt <so>" .. CFG.C_END)
end

local function registerEvents()
  local tDeath = CreateTrigger()
  TriggerRegisterAnyUnitEventBJ(tDeath, EVENT_PLAYER_UNIT_DEATH)
  TriggerAddAction(tDeath, onAnyDeath)

  if not CFG.HOUSE_SELECTABLE then
    local tSelect = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerUnitEvent(tSelect, Player(S.pids[i]),
                                     EVENT_PLAYER_UNIT_SELECTED, nil)
    end
    TriggerAddAction(tSelect, onSelect)
  end

  if CFG.DEV_COMMANDS then
    local tChat = CreateTrigger()
    for i = 1, #S.pids do
      -- exactMatch = false: "-sp " thua dau cach van an
      TriggerRegisterPlayerChatEvent(tChat, Player(S.pids[i]), "-sp", false)
    end
    TriggerAddAction(tChat, onChat)

    local tWave = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tWave, Player(S.pids[i]), "-wave", false)
    end
    TriggerAddAction(tWave, onWaveCmd)
  end

  if CFG.DEV_COMMANDS then
    local tMoney = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-lk", false)
      TriggerRegisterPlayerChatEvent(tMoney, Player(S.pids[i]), "-tt", false)
    end
    TriggerAddAction(tMoney, onMoneyCmd)
  end

  -- Loi choi, khong phai lenh dev -- luon dang ky.
  local tLC = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tLC, Player(S.pids[i]), "-lc", false)
  end
  TriggerAddAction(tLC, onLinhCanCmd)

  -- "-next" keo dot quai ke tiep ve ngay. Lenh dev: no doi nhip choi,
  -- va nhip choi la thu ca bang can bang dua vao.
  if CFG.DEV_COMMANDS then
    local tNext = CreateTrigger()
    for i = 1, #S.pids do
      TriggerRegisterPlayerChatEvent(tNext, Player(S.pids[i]), "-next", true)
    end
    TriggerAddAction(tNext, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      -- Chi goi som duoc khi da don sach. Cho phep goi som luc con quai
      -- la cho nguoi choi bo qua phan kho cua wave nay va nhan tien cua
      -- wave sau -- pha dung cai duong cong dang giu ca van.
      if S.alive > 0 then
        API.msg(pid, CFG.C_RED .. API.t("wave_notclear", S.alive) .. CFG.C_END)
        return
      end
      if API.waveNow() then
        API.msg(nil, CFG.C_GREY .. "[dev] " .. GetPlayerName(Player(pid)) ..
          " goi dot ke tiep." .. CFG.C_END)
      end
    end)
  end

  -- "-sync" bao duong dong bo nao dang chay va ping co ve khong. Luon
  -- dang ky: khi bang khong an thi day la cho dau tien phai nhin.
  local tSync = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tSync, Player(S.pids[i]), "-sync", true)
  end
  TriggerAddAction(tSync, function()
    API.syncChat(GetPlayerId(GetTriggerPlayer()))
  end)

  -- "-nat" liet ke native ban nay co. Luon dang ky: khi mot he im lang
  -- khong chay, day la cho thu hai phai nhin sau file vet.
  local tNat = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tNat, Player(S.pids[i]), "-nat", true)
  end
  TriggerAddAction(tNat, function()
    API.nativeChat(GetPlayerId(GetTriggerPlayer()))
  end)

  -- "-c" mo bang nhan vat, duong lui neu phim E khong gan duoc.
  local tPanel = CreateTrigger()
  for i = 1, #S.pids do
    TriggerRegisterPlayerChatEvent(tPanel, Player(S.pids[i]), "-c", true)
  end
  TriggerAddAction(tPanel, function()
    API.panelToggle(GetPlayerId(GetTriggerPlayer()))
  end)

  API.dbg("Trigger da dang ky.")
end

API.registerEvents = registerEvents
