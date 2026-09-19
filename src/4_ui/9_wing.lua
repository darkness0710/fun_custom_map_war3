-- ============================================================
--  9_wing.lua  --  Canh: huy hieu canh gioi, deo tren lung hero
--
--  Moi bo mo o mot moc canh gioi (CFG.WINGS[i].rank). Khong co chi so,
--  khong doi can bang -- no chi de NGUOI KHAC NHIN THAY anh da di toi
--  dau. Truoc do canh gioi chi doc duoc trong bang phim ESC.
--
--  BON DIEU PHAI NHO:
--
--  1. PHAI GAN TREN MOI MAY. Day la khac biet voi camera:
--     SetCameraField chi doi may dang chay nen goi cuc bo la dung, con
--     AddSpecialEffectTarget tao ra mot EFFECT THAT. Goi tren mot may
--     thi chi may do thay canh -- ma ca gia tri cua canh nam o cho
--     nguoi khac nhin thay. wear() vi the phai di tu duong da dong bo
--     (dot pha, hoac syncOn cua nut doi canh), KHONG tu callback frame.
--
--  2. DOI HERO LA RO RI. Effect bam vao unit. Hero bi xoa ma khong
--     DestroyEffect thi handle treo lai. Phai go o CHO DOI HERO, khong
--     chi o cho deo bo moi.
--
--  3. PHAI QUET LAI, KHONG CHI BAT SU KIEN. Nguoi choi co the nhay
--     canh gioi bang "-lc 15", hoac dot pha nhieu bac trong mot lan.
--     check() quet ca bang moi lan goi thay vi chi so voi bac vua qua.
--
--  4. DIEM GAN LA THUOC TINH CUA MODEL. Xem models/wings/note.txt:
--     goi Ethereal phai gan "origin", goi khac gan "chest" thi vot len
--     tren dau. Tung bo khai rieng truong 'attach'.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function defAt(i)
  return (CFG.WINGS or {})[i]
end

local function rankOf(pid)
  return (API.cultRank ~= nil) and API.cultRank(pid) or 1
end

-- Bo canh CAO NHAT ma canh gioi nay voi toi. nil = chua co bo nao.
--
-- Duyet xuoi va giu cai cuoi cung dat: bang xep theo do choi tang dan
-- nen cai sau luon "xin" hon cai truoc.
local function bestFor(pid)
  local r, best = rankOf(pid), nil
  for i = 1, #(CFG.WINGS or {}) do
    if r >= (CFG.WINGS[i].rank or 99) then best = i end
  end
  return best
end

local function owns(pid, i)
  local w = defAt(i)
  return w ~= nil and rankOf(pid) >= (w.rank or 99)
end

-- ---------- Deo / go ----------

local function clear(pid)
  local d = S.p[pid]
  if d == nil or d.wingFx == nil then return end
  if DestroyEffect ~= nil then DestroyEffect(d.wingFx) end
  -- Gan TACH ra chu khong "d.a, d.b = nil, nil": fieldpair.py chi nhan
  -- ra dang gan mot bien. Mot canh bao gia lam ca bo kiem mat tin.
  d.wingFx   = nil
  d.wingWorn = nil
end

-- point = nil thi lay 'attach' cua bo do, roi moi den mac dinh chung.
local function wear(pid, i, point)
  local w = defAt(i)
  local d = S.p[pid]
  if w == nil or d == nil or d.hero == nil then return false end
  if AddSpecialEffectTarget == nil then
    API.trace("wing: khong co AddSpecialEffectTarget")
    return false
  end

  clear(pid)

  local at = point or w.attach or CFG.WING_ATTACH or "origin"
  local fx = AddSpecialEffectTarget(w.path, d.hero, at)
  if fx == nil then
    API.trace("wing: AddSpecialEffectTarget tra nil -- '" .. w.path ..
              "' @ '" .. at .. "'")
    return false
  end
  if CFG.WING_SCALE ~= nil and BlzSetSpecialEffectScale ~= nil then
    BlzSetSpecialEffectScale(fx, CFG.WING_SCALE)
  end

  d.wingFx   = fx
  d.wingWorn = i
  API.trace("wing: pid " .. pid .. " deo #" .. i .. " '" .. w.code ..
            "' @ '" .. at .. "'")
  return true
end

-- ---------- Moc canh gioi ----------
--
-- Goi sau moi lan dot pha, VA sau khi pick hero (hero moi thi chua co
-- canh nao tren nguoi du canh gioi da cao).
local function check(pid)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end

  local best = bestFor(pid)
  if best == nil then return end

  -- BAO khi vua cham mot moc MOI. d.wingTop nho moc cao nhat da bao,
  -- de dot pha nhieu bac mot lan khong ra ba dong lien tiep.
  if (d.wingTop or 0) < best then
    d.wingTop = best
    local w = defAt(best)
    -- Tin CHUNG: ca gia tri cua canh la nguoi khac nhin thay. Bao rieng
    -- cho nguoi vua dot pha la vo nghia -- ho dang nhin thang vao no.
    API.msg(nil, CFG.C_GOLD ..
      API.t("wing_earned", GetPlayerName(Player(pid)), API.pick(w)) ..
      CFG.C_END)
  end

  -- Chua tu chon bo nao thi luon deo bo cao nhat. Da tu chon roi thi
  -- TON TRONG lua chon do -- tru khi bo dang deo khong con hop le.
  local want = d.wingPick
  if want == nil or not owns(pid, want) then want = best end
  if d.wingWorn ~= want then wear(pid, want) end
end

-- Doi sang bo KE TIEP trong so nhung bo da mo. Vong lai tu dau.
--
-- Chay tu syncOn nen co tren moi may -- nguoi khac thay canh doi theo.
local function cycle(pid)
  local d = S.p[pid]
  local n = #(CFG.WINGS or {})
  if d == nil or n == 0 then return end
  local from = d.wingWorn or 0
  for k = 1, n do
    local i = ((from - 1 + k) % n) + 1
    if owns(pid, i) then
      d.wingPick = i
      wear(pid, i)
      API.panelRefresh(pid)
      return
    end
  end
end

-- ---------- The Trang Bi hoi ----------

local function label(pid)
  local d = S.p[pid]
  local i = d and d.wingWorn or nil
  if i == nil then return nil end
  return API.pick(defAt(i))
end

-- Anh cua bo DANG DEO, cho o Canh o the Trang Bi.
--
-- nil = chua deo bo nao; cho goi tu quyet dinh duong lui
-- (CFG.GEAR_WING_ICON). Khong tra duong lui o day: o goi con phan biet
-- "chua mo bo nao" voi "da deo nhung thieu file anh".
local function iconOf(pid)
  local d = S.p[pid]
  local i = d and d.wingWorn or nil
  if i == nil then return nil end
  local w = defAt(i)
  return (w ~= nil) and w.icon or nil
end

local function nextRank(pid)
  local r = rankOf(pid)
  for i = 1, #(CFG.WINGS or {}) do
    local need = CFG.WINGS[i].rank or 99
    if r < need then return need end
  end
  return nil
end

local function ownedCount(pid)
  local n = 0
  for i = 1, #(CFG.WINGS or {}) do
    if owns(pid, i) then n = n + 1 end
  end
  return n
end

local function startWing()
  if CFG.WINGS == nil or #CFG.WINGS == 0 then
    API.trace("wing: bang rong")
    return
  end
  API.syncOn(CFG.OP_WING, function(pid) cycle(pid) end)

  if CFG.DEV_COMMANDS then
    local t = CreateTrigger()
    for i = 1, #S.pids do
      -- false = khop TIEN TO, de "-wing 3 origin" cung no.
      TriggerRegisterPlayerChatEvent(t, Player(S.pids[i]), "-wing", false)
    end
    TriggerAddAction(t, function()
      local pid = GetPlayerId(GetTriggerPlayer())
      local text = GetEventPlayerChatString()
      -- Lay TRON phan con lai lam ten diem, khong phai mot tu: nua so
      -- diem gan cua Warcraft co dau cach ("hand left", "foot right"),
      -- nen "%S*" lam nua bang khong go duoc va tuong la deu hong.
      local arg, pt = (text or ""):match("%-wing%s+(%S+)%s*(.*)")
      if pt ~= nil then pt = pt:gsub("^%s+", ""):gsub("%s+$", "") end
      if arg == "off" then clear(pid); API.info(pid, "-wing: da go"); return end
      local n = tonumber(arg)
      if n == nil or defAt(n) == nil then
        API.info(pid, "-wing N [diem] | -wing off")
        for i = 1, #CFG.WINGS do
          API.info(pid, "   " .. i .. ". " .. CFG.WINGS[i].code ..
                        "  canh gioi " .. (CFG.WINGS[i].rank or 0) ..
                        "  @" .. (CFG.WINGS[i].attach or "origin"))
        end
        return
      end
      if pt == "" then pt = nil end
      wear(pid, n, pt)
    end)
    S.wingTrig = t
  end

  API.trace("wing: " .. #CFG.WINGS .. " bo, moc canh gioi " ..
            table.concat((function()
              local t2 = {}
              for i = 1, #CFG.WINGS do t2[i] = CFG.WINGS[i].rank or 0 end
              return t2
            end)(), " "))
end

API.wingCheck   = check
API.wingClear   = clear
API.wingCycle   = cycle
API.wingIcon    = iconOf
API.wingLabel   = label
API.wingNext    = nextRank
API.wingOwned   = ownedCount
API.startWing   = startWing
