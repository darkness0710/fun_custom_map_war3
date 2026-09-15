-- ============================================================
--  02b_sync.lua  --  Kenh dong bo: mot may bam, moi may cung lam
--
--  VAN DE. Su kien bam frame chi no tren may nguoi bam. Warcraft III
--  chay lockstep: moi may mo phong cung mot van co, cung mot nhip. Doi
--  trang thai game ngay trong su kien do thi may day di truoc hai may
--  kia -- lech nhip la bi da ra khoi tran.
--
--  Nen: bam KHONG doi gi. No gui mot con so. Moi may nhan duoc con so
--  do cung mot nhip roi MOI doi trang thai.
--
--  BA DUONG GUI, chon bang CFG.SYNC_MODE:
--
--  "blz"   -- BlzSendSyncData + BlzTriggerRegisterPlayerSyncEvent.
--             Co tu 1.31. La su kien, khong phai quet, nen khong co khe
--             thoi gian nao mo ho. Duong tot nhat neu ban nay co.
--
--  "cache" -- StoreInteger + SyncStoredInteger tren game cache. Co tu
--             ban 1.00 nen chac chan ton tai. Khong co su kien bao tin
--             den, phai quet bang timer.
--
--  "local" -- khong dong bo, chay thang. CHI DUNG KHI CHOI MOT MINH.
--
--  "auto" (mac dinh) uu tien blz, roi cache, roi local.
--
--  Duong nao dang chay ghi ro trong file vet, va xem duoc trong game
--  bang lenh -sync.
--
--  KHUON TIN. Moi tin la MOT so nguyen 32 bit:
--
--      packed = op * 10^7  +  seq * 10^5  +  arg
--               op  1..200      seq 0..99     arg 0..99999
--
--  seq co mat chi de phan biet hai tin GIONG HET NHAU gui lien tiep
--  (bam "Dot pha" hai lan). Khong co no thi duong cache -- von so sanh
--  gia tri cu voi moi -- se nuot tin thu hai.
--
--  arg chi 5 chu so, nen KHONG gui duoc id kieu FourCC (H001 la hon 1,2
--  ti). Gui SO THU TU trong bang tinh (CFG.HEROES, danh sach choices)
--  roi tra nguoc ra id o dau ben kia.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local OP_MUL  = 10000000
local SEQ_MUL = 100000
local ARG_MAX = 99999
local OP_MAX  = 200
local MISSION = "d"
local PREFIX  = "DTT"

S.sync = {
  mode     = "local",
  handlers = {},      -- [op] = f(pid, arg)
  seen     = {},      -- [pid] = so doc duoc lan cuoi (duong cache)
  seq      = 0,       -- CUC BO: moi may dem rieng, khong phai trang thai game
  cache    = nil,
  timer    = nil,
  trig     = nil,
  pingSeen = {},
  native   = {},
}

local function keyOf(pid) return "p" .. pid end

local function pack(op, seq, arg)
  return op * OP_MUL + (seq % 100) * SEQ_MUL + arg
end

local function unpackMsg(v)
  local op   = math.floor(v / OP_MUL)
  local rest = v - op * OP_MUL
  local seq  = math.floor(rest / SEQ_MUL)
  return op, seq, rest - seq * SEQ_MUL
end

-- ---------- Do xem ban nay co gi ----------

local function probe()
  local t = {}
  t.blzSend = (BlzSendSyncData ~= nil)
  t.blzData = (BlzGetTriggerSyncData ~= nil)
  -- HAI ten. Ban 1.31 dat ten native la BlzTriggerRegisterPlayerSyncEvent;
  -- tai lieu tren mang hay viet thieu tien to Blz. Do ca hai roi hay ket
  -- luan la ban nay khong co dong bo.
  t.blzRegBlz = (BlzTriggerRegisterPlayerSyncEvent ~= nil)
  t.blzRegOld = (TriggerRegisterPlayerSyncEvent ~= nil)
  t.gc = (InitGameCache ~= nil and StoreInteger ~= nil
      and SyncStoredInteger ~= nil and GetStoredInteger ~= nil
      and HaveStoredInteger ~= nil and FlushGameCache ~= nil
      and FlushStoredInteger ~= nil)
  return t
end

local function blzUsable(t)
  return t.blzSend and t.blzData and (t.blzRegBlz or t.blzRegOld)
end

local function chooseMode(t)
  local m = CFG.SYNC_MODE
  if m == "local" then return "local" end
  if m == "blz"   then return blzUsable(t) and "blz" or "local" end
  if m == "cache" then return t.gc and "cache" or "local" end
  if blzUsable(t) then return "blz" end
  if t.gc         then return "cache" end
  return "local"
end

-- ---------- Nhan tin ----------

local function dispatch(pid, packed)
  local op, _, arg = unpackMsg(packed)
  local f = S.sync.handlers[op]
  if f == nil then
    API.trace("sync: tin la op=" .. op .. " tu pid " .. pid)
    return
  end
  f(pid, arg)
end

-- ---------- Duong blz ----------

local function blzStart()
  local reg = BlzTriggerRegisterPlayerSyncEvent or TriggerRegisterPlayerSyncEvent
  S.sync.trig = CreateTrigger()
  for i = 1, #S.pids do
    reg(S.sync.trig, Player(S.pids[i]), PREFIX, false)
  end
  TriggerAddAction(S.sync.trig, function()
    local v = tonumber(BlzGetTriggerSyncData())
    if v == nil then return end
    dispatch(GetPlayerId(GetTriggerPlayer()), v)
  end)
  return true
end

local function blzSendRaw(packed)
  BlzSendSyncData(PREFIX, tostring(packed))
end

-- ---------- Duong cache ----------

local function cachePoll()
  local sy = S.sync
  if sy.cache == nil then return end
  for i = 1, #S.pids do
    local pid = S.pids[i]
    local k = keyOf(pid)
    if HaveStoredInteger(sy.cache, MISSION, k) then
      local v = GetStoredInteger(sy.cache, MISSION, k)
      if v > 0 and v ~= sy.seen[pid] then
        sy.seen[pid] = v
        dispatch(pid, v)
      end
    end
  end
end

local function cacheStart()
  local c = InitGameCache(CFG.SYNC_CACHE)
  if c == nil then return false end

  -- Game cache SONG QUA nhieu van trong cung mot phien Warcraft III, va
  -- no nam tren dia TUNG MAY. Khong xoa thi vao van moi may nay con tin
  -- cu cua van truoc, may kia thi khong -- lech ngay tu giay dau.
  FlushGameCache(c)
  c = InitGameCache(CFG.SYNC_CACHE)
  if c == nil then return false end

  S.sync.cache = c
  for i = 1, #S.pids do S.sync.seen[S.pids[i]] = 0 end

  S.sync.timer = CreateTimer()
  TimerStart(S.sync.timer, CFG.SYNC_POLL, true, cachePoll)
  return true
end

local function cacheSendRaw(pid, packed)
  local sy = S.sync
  if sy.cache == nil then return end
  local k = keyOf(pid)
  StoreInteger(sy.cache, MISSION, k, packed)
  SyncStoredInteger(sy.cache, MISSION, k)

  -- XOA BAN CUC BO NGAY SAU KHI GUI.
  -- StoreInteger ghi thang vao cache cua may nay. Neu de nguyen, bo quet
  -- cua chinh may nguoi gui thay tin o nhip ke tiep (0.1 giay), trong khi
  -- hai may kia phai doi goi tin qua mang. Nguoi gui lam truoc mot nhip
  -- -- lech tran. Xoa di thi may nguoi gui cung phai doi goi tin quay ve
  -- nhu moi nguoi.
  --
  -- Dua tren mot gia dinh CHUA DO DUOC TREN 1.31.1: SyncStoredInteger
  -- dong goi gia tri ngay luc goi, nen xoa sau khong huy duoc no. Neu
  -- gia dinh sai thi tin khong bao gio ve -- nut chet, KHONG lech tran.
  -- Hong kieu do thay duoc ngay khi test; lech tran thi khong. Bo tu
  -- kiem ben duoi do dung viec nay va ghi ket qua vao file vet.
  FlushStoredInteger(sy.cache, MISSION, k)
end

-- ---------- Gui ----------

-- CHI may cua chinh nguoi choi do moi gui. Goi duoc tu su kien cuc bo
-- (bam frame) lan su kien dong bo (chat) deu an toan.
local function send(pid, op, arg)
  arg = math.floor(arg or 0)
  if op < 1 or op > OP_MAX then
    API.trace("sync: op ngoai khoang: " .. tostring(op))
    return
  end
  if arg < 0 or arg > ARG_MAX then
    API.trace("sync: arg ngoai khoang: " .. tostring(arg))
    return
  end
  if GetLocalPlayer() ~= Player(pid) then return end

  local sy = S.sync
  sy.seq = (sy.seq + 1) % 100
  local packed = pack(op, sy.seq, arg)

  if sy.mode == "blz" then
    blzSendRaw(packed)
  elseif sy.mode == "cache" then
    cacheSendRaw(pid, packed)
  else
    dispatch(pid, packed)   -- mot nguoi choi
  end
end

local function on(op, f)
  S.sync.handlers[op] = f
end

-- ---------- Tu kiem ----------
-- Moi nguoi gui mot tin PING luc vao map. Tin ve duoc nghia la duong
-- dang chon that su chay. Ket qua vao file vet, khong lam phien ai.

local function selfTest()
  on(CFG.OP_PING, function(pid, arg)
    S.sync.pingSeen[pid] = true
    API.trace("sync: ping ve tu pid " .. pid .. " (arg " .. arg .. ")")
  end)

  for i = 1, #S.pids do
    send(S.pids[i], CFG.OP_PING, S.pids[i])
  end

  API.after(CFG.SYNC_TEST_WAIT, function()
    local ve, mat = {}, {}
    for i = 1, #S.pids do
      local pid = S.pids[i]
      if S.sync.pingSeen[pid] then ve[#ve + 1] = pid else mat[#mat + 1] = pid end
    end
    API.trace("sync: tu kiem [" .. S.sync.mode .. "] ping ve tu " ..
      #ve .. "/" .. #S.pids .. " nguoi" ..
      (#ve > 0 and (" (player " .. table.concat(ve, ",") .. ")") or "") ..
      (#mat > 0 and (" -- MAT player " .. table.concat(mat, ",")) or ""))
    -- KHONG tu doi duong o day. Neu hai may ket luan khac nhau thi moi
    -- may chay mot kieu -- dung cai muon tranh ngay tu dau. Bao ra roi
    -- de nguoi sua CFG.SYNC_MODE, build lai.
    if #mat > 0 and S.sync.mode ~= "local" then
      API.msg(nil, CFG.C_RED .. "Dong bo [" .. S.sync.mode ..
        "] khong nhan duoc tin cua player " .. table.concat(mat, ",") ..
        " -- nut trong bang se khong an." .. CFG.C_END)
      API.msg(nil, CFG.C_GOLD .. "Doi CFG.SYNC_MODE trong 01_config.lua sang " ..
        (S.sync.mode == "cache" and "\"blz\"" or "\"cache\"") ..
        " roi build lai. Go -sync de xem chi tiet." .. CFG.C_END)
    end
  end)
end

-- ---------- Bao cao ----------

local function statusLines()
  local t = S.sync.native
  local out = {}
  out[#out + 1] = "Duong dang chay: " .. CFG.C_GOLD .. S.sync.mode .. CFG.C_END ..
                  "   (CFG.SYNC_MODE = " .. tostring(CFG.SYNC_MODE) .. ")"
  out[#out + 1] = "BlzSendSyncData .................. " .. tostring(t.blzSend)
  out[#out + 1] = "BlzGetTriggerSyncData ............ " .. tostring(t.blzData)
  out[#out + 1] = "BlzTriggerRegisterPlayerSyncEvent  " .. tostring(t.blzRegBlz)
  out[#out + 1] = "TriggerRegisterPlayerSyncEvent ... " .. tostring(t.blzRegOld)
  out[#out + 1] = "Game cache (Store/Sync/Flush) .... " .. tostring(t.gc)

  -- Ghi ro tung nguoi mot. Truoc day gop thanh mot danh sach so, nen
  -- "Ping ve tu player: 0" doc ra hai nghia trai nguoc nhau: player so 0
  -- da ve, hay khong ai ve. Bang chan doan ma doc nham duoc thi te hon
  -- la khong co.
  for i = 1, #S.pids do
    local pid = S.pids[i]
    out[#out + 1] = "Ping player " .. pid .. ": " ..
      (S.sync.pingSeen[pid] and (CFG.C_JADE .. "da ve" .. CFG.C_END)
                            or (CFG.C_RED .. "CHUA VE" .. CFG.C_END))
  end
  return out
end

local function onChat(pid)
  local lines = statusLines()
  API.msg(pid, CFG.C_GOLD .. "=== Dong bo ===" .. CFG.C_END)
  for i = 1, #lines do API.msg(pid, lines[i]) end
  send(pid, CFG.OP_PING, pid)
  API.msg(pid, CFG.C_GREY ..
    "Da gui mot ping. Go -sync lai sau 1 giay de xem no ve chua." .. CFG.C_END)
end

local function startSync()
  local t = probe()
  S.sync.native = t
  S.sync.mode   = chooseMode(t)

  if S.sync.mode == "blz" then
    if not blzStart() then S.sync.mode = "local" end
  elseif S.sync.mode == "cache" then
    if not cacheStart() then S.sync.mode = "local" end
  end

  API.trace("sync: mode=" .. S.sync.mode ..
    " blzSend=" .. tostring(t.blzSend) ..
    " blzReg=" .. tostring(t.blzRegBlz) ..
    " regCu=" .. tostring(t.blzRegOld) ..
    " cache=" .. tostring(t.gc))

  if S.sync.mode == "local" then
    API.msg(nil, CFG.C_RED .. "Khong co kenh dong bo nao -- bang chi dung duoc " ..
      "khi choi MOT MINH. Go -sync de xem chi tiet." .. CFG.C_END)
  end

  selfTest()
end

API.syncSend   = send
API.syncOn     = on
API.syncMode   = function() return S.sync.mode end
API.syncChat   = onChat
API.syncStatus = statusLines
API.startSync  = startSync
