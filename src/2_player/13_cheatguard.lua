-- ============================================================
--  13_cheatguard.lua  --  Bat cheat co san cua Warcraft III
--
--  KHONG CHAN DUOC, CHI PHAT HIEN DUOC. Cheat cua Warcraft
--  (greedisgood, whosyourdaddy...) do CHINH ENGINE xu ly, khong di qua
--  trigger nao cua map. Khong co native nao tat chung.
--
--  Nen he nay khong "chan" -- no DO HAU QUA. Hai duong do duoc:
--
--    1. SO CAI TIEN. Vang va Go song tren THANH TAI NGUYEN cua
--       Warcraft (PLAYER_STATE_RESOURCE_*), va greedisgood bom thang
--       vao do. Map thi chi ghi qua addGold/addLumber -- HAI cho duy
--       nhat goi SetPlayerState trong ca cay. Nen: moi lan map ghi,
--       ghi luon con so do vao so cai. Lech = co ke thu ba ghi vao.
--
--       Linh Khi va Da KHONG can canh: chung song trong S.p[pid],
--       cheat khong voi toi.
--
--    2. BAT TU. whosyourdaddy dat unit bat tu. Map khong bao gio dat
--       hero bat tu, nen hero bat tu = cheat.
--
--  KHONG BAO NHAM la yeu cau so mot. Lenh -debug day ca bon dong tien
--  len 999.999 -- nhung no goi API.addGold nen so cai tu khop. Bat cu
--  ai them mot duong cap tien MOI phai di qua addGold/addLumber, neu
--  khong he nay se to oan nguoi choi.
--
--  Phan ung mac dinh chi la BAO RA. Ket thuc van vi mot phep do co the
--  sai la cai gia qua dat -- xem CFG.CHEAT_ACTION.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Map vua ghi mot con so len thanh tai nguyen. Nho lai.
--
-- Goi tu addGold/addLumber trong 1_player.lua, NGAY SAU SetPlayerState.
-- Goi truoc thi so cai giu con so cu va lan kiem ngay sau se to oan.
local function note(pid, kind, value)
  if S.ledger == nil then S.ledger = {} end
  if S.ledger[pid] == nil then S.ledger[pid] = {} end
  S.ledger[pid][kind] = value
end

local function said(pid, kind)
  local d = S.p[pid]
  if d == nil then return true end
  if d.cheatSaid == nil then d.cheatSaid = {} end
  if d.cheatSaid[kind] then return true end
  d.cheatSaid[kind] = true
  return false
end

-- Bao mot lan cho moi KIEU cheat, khong bao moi nhip.
--
-- Mot nguoi go greedisgood roi de yen thi lech ton tai mai mai -- bao
-- moi 2 giay la bien phat hien thanh tieng on, va tieng on thi nguoi ta
-- tat di chu khong sua.
local function flag(pid, kind, detail)
  if said(pid, kind) then return end

  local d = S.p[pid]
  if d ~= nil then d.cheated = true end
  S.cheatSeen = true

  API.trace("cheat: pid " .. pid .. " -- " .. kind .. " -- " .. detail)

  local act = CFG.CHEAT_ACTION or "announce"
  if act == "off" then return end

  -- Bao cho CA BAN DO, khong bao rieng.
  --
  -- Mot minh nguoi go thi bao rieng la vo nghia -- ho biet ho vua go gi.
  -- Gia tri cua dong nay nam o cho NGUOI KHAC doc duoc.
  API.say(pid, CFG.C_RED .. API.t("cheat_seen") .. CFG.C_END)
end

-- ---------- Do ----------

local function checkOne(pid)
  local d = S.p[pid]
  if d == nil or not d.active then return end

  local led = (S.ledger or {})[pid]
  if led == nil then return end
  local slack = CFG.CHEAT_SLACK or 1

  -- Chi bat khi THUA ra. Thieu di thi khong phai cheat -- co the la mot
  -- duong tru tien nao do chua kip ghi so, va to oan vi thieu tien la
  -- kieu sai te nhat.
  local g = GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD)
  if led.gold ~= nil and g > led.gold + slack then
    flag(pid, "gold", "so cai " .. led.gold .. ", that " .. g)
    led.gold = g   -- nhan con so moi lam moc, de khong dem lai lech cu
  elseif led.gold ~= nil and g < led.gold then
    led.gold = g
  end

  local l = GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_LUMBER)
  if led.lumber ~= nil and l > led.lumber + slack then
    flag(pid, "lumber", "so cai " .. led.lumber .. ", that " .. l)
    led.lumber = l
  elseif led.lumber ~= nil and l < led.lumber then
    led.lumber = l
  end

  -- BAT TU: map khong bao gio dat hero bat tu, nen hero bat tu la
  -- whosyourdaddy. Nha chinh thi CO the bat tu (CFG.HOUSE_INVULNERABLE)
  -- nen khong dung no lam dau hieu.
  local h = d.hero
  if h ~= nil and API.alive(h) and BlzIsUnitInvulnerable ~= nil then
    if BlzIsUnitInvulnerable(h) then
      flag(pid, "invuln", "hero bat tu ma map khong dat")
    end
  end
end

local function tick()
  for i = 1, #S.pids do checkOne(S.pids[i]) end
end

-- Co the hoi tu cac he khac: "van nay da dinh cheat chua".
local function clean()
  return not S.cheatSeen
end

-- ---------- Khoi dong ----------

local function startCheatGuard()
  S.ledger, S.cheatSeen = {}, false
  if not CFG.CHEAT_WATCH then
    API.trace("cheat: CFG.CHEAT_WATCH = false -- khong canh")
    return
  end

  -- MOC DAU la con so DANG CO, khong phai 0.
  --
  -- Warcraft phat vang/go khoi dau theo thiet lap trong war3map.w3i,
  -- truoc khi mot dong Lua nao chay. Lay 0 lam moc thi ca doi bi to
  -- oan ngay giay dau.
  for i = 1, #S.pids do
    local pid = S.pids[i]
    note(pid, "gold",   GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD))
    note(pid, "lumber", GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_LUMBER))
  end

  S.cheatTimer = CreateTimer()
  TimerStart(S.cheatTimer, CFG.CHEAT_TICK or 2.0, true, tick)

  API.trace("cheat: canh so cai vang/go + bat tu, moi " ..
            (CFG.CHEAT_TICK or 2.0) .. "s, phan ung '" ..
            tostring(CFG.CHEAT_ACTION or "announce") .. "'")
end

API.cheatNote      = note
API.cheatClean     = clean
API.startCheatGuard = startCheatGuard
