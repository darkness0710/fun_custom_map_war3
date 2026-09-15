-- ============================================================
--  02_state.lua  --  Trang thai chay & tien ich dung chung
--
--  S   : moi thu thay doi trong luc choi.
--  API : ban dang ky ham dung chung giua cac module.
--        Goi cheo module PHAI di qua API -- Lua bat upvalue luc dinh
--        nghia ham, nen local cua file sau khong nhin thay duoc tu
--        file truoc. Xem docs/05-quyet-dinh/0002.
-- ============================================================

local S = {}

S.running = false
S.grid    = nil     -- so do luoi, do 03_geometry dung
S.p       = {}      -- [pid] = { active = true }
S.pids    = {}      -- danh sach pid dang choi, theo thu tu
S.enemy   = nil     -- player phe dich

-- Nha chinh & vung, do 06_core dung
S.house      = nil  -- unit nha chinh
S.houseX     = nil
S.houseY     = nil
S.houseHpSet    = false  -- dat duoc HP khong (can patch 1.31+)
S.houseSightVia = nil    -- dat tam nhin bang cach nao
S.houseNoAttack = false  -- tat duoc don danh khong
S.houseOwner    = nil    -- player so huu nha chinh
S.houseRgnName  = nil    -- ten vung thuc su khop duoc
S.enemyRgnName  = nil

-- Chon hero, do 07_heropick dung
S.heroTaken   = {}     -- [unit type id] = true khi da co nguoi lay
S.pick        = {}     -- [pid] = { dlg = dialog, map = { [button] = uid } }
S.pickTrigger = nil
S.skillPick   = {}     -- [pid] = { dlg, map, slot }
S.skillTrigger= nil
S.sframe      = {}     -- giao dien ky nang, do 07b_skillframe dung
S.hframe      = {}     -- the chon hero,   do 07c_heroframe dung
S.xpTimer     = nil    -- bo quet khoa hero

-- Dot quai, do 05_wave dung
S.stage      = 0       -- 1..220, MOT bien duy nhat
S.lives      = 0       -- linh khi con lai cua nha chinh (ADR 0011)
S.mobs       = {}      -- [unit] = "mob" | "elite" | "boss"
S.alive      = 0
S.wave       = {}      -- { players, spawnFail } cua wave hien tai
S.waveTimer  = nil
S.waveDlg    = nil
S.tickTimer  = nil
S.dumped      = {}     -- [unit] = true, da do danh sach ability chua
S.spReported  = {}     -- [unit] = true, da bao so diem ky nang chua
S.abilReported= {}     -- [unit] = true, da bao ket qua go ability chua

local API = {}

-- ---------- Tien ich ----------

local function msg(pid, text)
  if pid == nil then
    for i = 0, bj_MAX_PLAYERS - 1 do
      DisplayTimedTextToPlayer(Player(i), 0, 0, CFG.MSG_TIME, text)
    end
  else
    DisplayTimedTextToPlayer(Player(pid), 0, 0, CFG.MSG_TIME, text)
  end
end

local function dbg(text)
  if CFG.DEBUG then msg(nil, CFG.C_GREY .. "[dbg] " .. text .. CFG.C_END) end
end

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function round(v)
  return math.floor(v + 0.5)
end

-- 12345 -> "12,345"
local function num(n)
  local s = tostring(math.floor(n))
  local out, neg = "", false
  if s:sub(1, 1) == "-" then neg = true; s = s:sub(2) end
  while #s > 3 do
    out = "," .. s:sub(-3) .. out
    s = s:sub(1, -4)
  end
  out = s .. out
  if neg then out = "-" .. out end
  return out
end

-- UnitAlive la native 1.31+; lui ve nguong 0.405 cua Warcraft III.
local function alive(u)
  if u == nil then return false end
  if UnitAlive ~= nil then return UnitAlive(u) end
  return GetUnitState(u, UNIT_STATE_LIFE) > 0.405
end

-- Chay f sau delay giay (mot lan).
local function after(delay, f)
  local t = CreateTimer()
  TimerStart(t, delay, false, function()
    local d = GetExpiredTimer()
    f()
    DestroyTimer(d)
  end)
  return t
end

-- ---------- Vet khoi dong ----------
-- PreloadGenEnd ghi mot file text vao Documents\Warcraft III\. Moi
-- buoc ta ghi lai TOAN BO danh sach, nen sau khi game sap, dong cuoi
-- trong file chinh la buoc cuoi cung da chay xong.
local traceSteps = {}

local function trace(step)
  if not CFG.TRACE then return end
  traceSteps[#traceSteps + 1] = step
  PreloadGenClear()
  PreloadGenStart()
  for i = 1, #traceSteps do
    Preload(traceSteps[i])
  end
  PreloadGenEnd(CFG.TRACE_FILE)
end

-- Doi mot unit/ability id tro lai chuoi bon ky tu. Dung phep chia chu
-- khong dung toan tu bit -- khong phai ban Lua nao cua WC3 cung co.
local function idToStr(v)
  if type(v) ~= "number" then return "?" end
  local a = math.floor(v / 16777216) % 256
  local b = math.floor(v / 65536) % 256
  local c = math.floor(v / 256) % 256
  local d = v % 256
  return string.char(a, b, c, d)
end

API.idToStr = idToStr
API.trace = trace
API.msg   = msg
API.dbg   = dbg
API.alive = alive
API.clamp = clamp
API.round = round
API.num   = num
API.after = after
