-- ============================================================
--  3_boss.lua  --  Boss: hero di bo, do theo suc manh THAT cua doi
--
--  KHAC HAN QUAI THUONG. Quai thuong bam theo duong cong Tu Vi (xem
--  CFG.MOB_EHP_THEO_LINHCAN). Boss thi DO doi ngay luc no xuat hien --
--  chi so, sat thuong, giap, mau -- roi suy ra mau va don danh cua no.
--
--  Vi sao phai do chu khong dung duong cong: duong cong gia dinh nguoi
--  choi len dung mot bac moi canh gioi. Ai cay them, ai bo lo, ai don
--  het the chi so o Co Duyen -- duong cong khong biet. Boss thi phai
--  biet, neu khong no hoac la bia thit hoac la buc tuong.
--
--  VA MOT LOI DO DUOC: 1 Agi = 1/3 giap, ma Tu Vi cong deu ca ba chi
--  so. Cuoi van hero co 8,070 giap -> giam 99.79% sat thuong. Dat sat
--  thuong boss bang mot con so tuyet doi thi no danh 2,036 chi con 4
--  mau. Nen boss tinh theo MAU HIEU DUNG: mau / (1 - giam).
--
--  Hai muoi con, moi canh gioi mot con, moi con mot file mo ta rieng:
--  docs/02-he-thong/boss/
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function giamSatThuong(giap)
  local k = CFG.ARMOR_DR_PER_POINT * giap
  if k <= 0 then return 0.0 end
  return k / (1.0 + k)
end

local function co(b, ten)
  return b ~= nil and b.co ~= nil and b.co[ten] == true
end

local function so(ten, khoa)
  local t = CFG.BOSS_CO and CFG.BOSS_CO[ten] or nil
  return (t ~= nil) and t[khoa] or 0.0
end

-- ---------- Do suc manh doi ----------
-- Tra ve: tong dps uoc luong, mau hieu dung TRUNG BINH mot hero, so hero

local function doDoi()
  local dps, mauHD, n = 0.0, 0.0, 0
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h) then
      n = n + 1
      local top = API.skillTopStat and API.skillTopStat(h) or 0
      dps = dps + CFG.BOSS_DPS_HE_SO * (CFG.LINHCAN_DMG_BASE + top)

      local giam = giamSatThuong((BlzGetUnitArmor ~= nil) and BlzGetUnitArmor(h) or 0.0)
      -- Mau hieu dung: bao nhieu sat thuong THO moi ha duoc hero nay.
      mauHD = mauHD + GetUnitState(h, UNIT_STATE_MAX_LIFE) / (1.0 - giam)
    end
  end
  if n == 0 then return 0.0, 0.0, 0 end
  return dps, mauHD / n, n
end

-- ---------- Tra ban thiet ke ----------

local function def(realm)
  if CFG.BOSSES ~= nil then
    for i = 1, #CFG.BOSSES do
      if CFG.BOSSES[i].r == realm then return CFG.BOSSES[i] end
    end
  end
  return nil
end

-- ---------- Sinh boss ----------

local function spawn(stage, realm, x, y, face)
  local d = def(realm)
  local uid = (d ~= nil) and d.unit
              or CFG.BOSS_UNIT[API.realmCoi and API.realmCoi(realm) or 1]
  if uid == nil then return nil end

  local u = CreateUnit(S.enemy, uid, x, y, face)
  if u == nil then return nil end

  local dps, mauHD, n = doDoi()

  -- MAU: song duoc BOSS_GIAY duoi hoa luc ca doi.
  -- Khong nhan them theo so nguoi choi -- dps o tren DA la tong cua ca
  -- doi. Nhan hai lan la phat nguoi choi vi ru duoc ban.
  local mau = dps * CFG.BOSS_GIAY
  if mau < 1.0 then mau = 1.0 end

  -- SAT THUONG: ha mot hero dung yen trong BOSS_SO_DON don. Con so nay
  -- la sat thuong THO -- nhin rat to, nhung sau giap no dung bang
  -- mau_that / BOSS_SO_DON.
  local dmg = mauHD / CFG.BOSS_SO_DON
  if dmg < 1.0 then dmg = 1.0 end

  if BlzSetUnitMaxHP ~= nil then
    BlzSetUnitMaxHP(u, math.floor(mau + 0.5))
    SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE))
  end
  if BlzSetUnitBaseDamage ~= nil then
    BlzSetUnitBaseDamage(u, math.floor(dmg + 0.5), 0)
  end
  -- Boss KHONG co giap: mau vua tinh DA la mau that can de tru.
  if BlzSetUnitArmor ~= nil then BlzSetUnitArmor(u, 0.0) end

  SetUnitScale(u, CFG.BOSS_SCALE, CFG.BOSS_SCALE, CFG.BOSS_SCALE)
  SetUnitVertexColor(u, 255, 120, 120, 255)
  -- Hero thi co kinh nghiem. Khoa lai, khong thi boss len cap giua tran
  -- va moi con so vua tinh o tren truot het.
  if SuspendHeroXP ~= nil then SuspendHeroXP(u, true) end
  if BlzSetUnitName ~= nil and d ~= nil then BlzSetUnitName(u, API.pick(d)) end

  local coBang = {}
  if d ~= nil and d.co ~= nil then
    for i = 1, #d.co do coBang[d.co[i]] = true end
  end

  S.boss = {
    u = u, stage = stage, realm = realm, def = d, co = coBang,
    dmg = dmg, mauToiDa = mau, cuong = false,
    cdChanDia = so("chandia", "cd"), cdLao = so("lao", "cd"),
    cdTrieu = so("trieuhoi", "cd"), cdKhien = so("khien", "cd"),
    khien = 0.0,
  }

  if d ~= nil then
    API.msg(nil, CFG.C_RED .. API.t("boss_toi", API.pick(d)) .. CFG.C_END)
  end
  API.trace("boss: r" .. realm .. " " .. API.idToStr(uid) .. " -- " .. n ..
            " hero, dps " .. math.floor(dps) .. " -> mau " .. math.floor(mau) ..
            ", don " .. math.floor(dmg))
  return u
end

-- ---------- Co che ----------

local function diThu(x, y, tam, f)
  local g = CreateGroup()
  GroupEnumUnitsInRange(g, x, y, tam, nil)
  local t = FirstOfGroup(g)
  while t ~= nil do
    GroupRemoveUnit(g, t)
    if API.alive(t) and IsUnitEnemy(t, S.enemy) then f(t) end
    t = FirstOfGroup(g)
  end
  DestroyGroup(g)
end

local function danh(b, tgt, sat)
  UnitDamageTarget(b.u, tgt, sat, true, false,
                   ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
end

local function heSoCuong(b)
  return b.cuong and so("cuong", "dmg") or 1.0
end

local function chanDia(b)
  local x, y = GetUnitX(b.u), GetUnitY(b.u)
  local sat = b.dmg * so("chandia", "heSo") * heSoCuong(b)
  API.fx(CFG.FX_HIT_BUFF, x, y)
  diThu(x, y, so("chandia", "tam"), function(t) danh(b, t, sat) end)
end

-- Lao toi hero XA NHAT, khong phai gan nhat: ep ke nup sau cung phai
-- tham gia. Dung gan thi da an don thuong roi.
local function lao(b)
  local bx, by = GetUnitX(b.u), GetUnitY(b.u)
  local xa, dmax = nil, -1.0
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    local h = d and d.hero or nil
    if h ~= nil and API.alive(h) then
      local kc = API.distXY(bx, by, GetUnitX(h), GetUnitY(h))
      if kc > dmax then xa, dmax = h, kc end
    end
  end
  if xa == nil then return end
  SetUnitPosition(b.u, GetUnitX(xa), GetUnitY(xa))
  API.fx(CFG.FX_HIT_LINE, GetUnitX(xa), GetUnitY(xa))
  danh(b, xa, b.dmg * so("lao", "heSo") * heSoCuong(b))
end

local function trieuHoi(b)
  local n = math.floor(so("trieuhoi", "so"))
  if n <= 0 or API.waveSpawnAt == nil then return end
  for i = 1, n do
    local a = 360.0 * i / n
    -- Goi qua he wave de thuoc ha cung duong cong, cung tien thuong, va
    -- cung duoc dem vao S.alive -- neu khong, don sach wave xong ma con
    -- thuoc ha thi dong ho wave treo.
    API.waveSpawnAt(b.stage, b.realm,
                    API.polarX(GetUnitX(b.u), 220.0, a),
                    API.polarY(GetUnitY(b.u), 220.0, a))
  end
  API.msg(nil, CFG.C_GREY .. API.t("boss_trieu") .. CFG.C_END)
end

local function khien(b)
  b.khien = b.khien + b.mauToiDa * so("khien", "ti")
  API.fx(CFG.FX_HIT_BUFF, GetUnitX(b.u), GetUnitY(b.u))
  API.msg(nil, CFG.C_GREY .. API.t("boss_khien") .. CFG.C_END)
end

-- ---------- Nhip 2 giay ----------

local function tick()
  local b = S.boss
  if b == nil or b.u == nil then return end
  if not API.alive(b.u) then S.boss = nil; return end

  if co(b, "cuong") and not b.cuong then
    if GetUnitState(b.u, UNIT_STATE_LIFE) / b.mauToiDa <= so("cuong", "nguong") then
      b.cuong = true
      if BlzSetUnitBaseDamage ~= nil then
        BlzSetUnitBaseDamage(b.u, math.floor(b.dmg * so("cuong", "dmg") + 0.5), 0)
      end
      SetUnitVertexColor(b.u, 255, 40, 40, 255)
      API.msg(nil, CFG.C_RED .. API.t("boss_cuong") .. CFG.C_END)
    end
  end

  local function nhip(khoa, ten, f)
    if not co(b, ten) then return end
    b[khoa] = b[khoa] - CFG.WAVE_TICK
    if b[khoa] <= 0.0 then b[khoa] = so(ten, "cd"); f(b) end
  end
  nhip("cdChanDia", "chandia",  chanDia)
  nhip("cdLao",     "lao",      lao)
  nhip("cdTrieu",   "trieuhoi", trieuHoi)
  nhip("cdKhien",   "khien",    khien)
end

-- ---------- Su kien sat thuong rieng cua boss ----------
--
-- Boss tu giu trigger cua no thay vi nho 7_hieuung.lua: bon co che duoi
-- day chi song trong mot tran boss, tron chung vao he bi dong cua hero
-- thi ca hai ben deu kho doc.

local function onDamage()
  local b = S.boss
  if b == nil or b.u == nil then return end

  local tgt = (BlzGetEventDamageTarget ~= nil) and BlzGetEventDamageTarget()
              or GetTriggerUnit()
  local src = GetEventDamageSource()
  local sat = GetEventDamage()
  if sat <= 0.0 then return end

  -- BOSS AN DON
  if tgt == b.u then
    if b.khien > 0.0 and BlzSetEventDamage ~= nil then
      local chan = (sat < b.khien) and sat or b.khien
      b.khien = b.khien - chan
      sat = sat - chan
      BlzSetEventDamage(sat)
    end
    if co(b, "phandon") and src ~= nil and src ~= b.u and sat > 0.0 then
      -- Phan lai NGUON. Cu phan nay lai ban su kien nay lan nua, nhung
      -- lan do src == boss nen khong vao nhanh phan don -- khong de quy.
      UnitDamageTarget(b.u, src, sat * so("phandon", "ti"), true, false,
                       ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    end
    return
  end

  -- BOSS GAY DON
  if src == b.u then
    if co(b, "hutmau") then
      local mau = GetUnitState(b.u, UNIT_STATE_LIFE) + sat * so("hutmau", "ti")
      local mx  = GetUnitState(b.u, UNIT_STATE_MAX_LIFE)
      SetUnitState(b.u, UNIT_STATE_LIFE, (mau > mx) and mx or mau)
    end
    -- XE GIAP: KHONG sua giap that. Giap la cua engine tu luc
    -- heroRecompute thoi so huu no (xem 7_hieuung.lua); gianh lai la
    -- lap lai dung cai loi da mat may ngay de go.
    --
    -- Thay vao do cong don mot he so KHUECH DAI sat thuong len chinh
    -- hero do: cung ket qua "cang danh lau cang de vo", ma khong ai
    -- phai so huu lai giap.
    if co(b, "xegiap") and API.heroPidCua ~= nil then
      local pid = API.heroPidCua(tgt)
      if pid ~= nil and S.p[pid] ~= nil then
        local d = S.p[pid]
        d.bossXe = (d.bossXe or 0.0) + so("xegiap", "moiDon")
        if BlzSetEventDamage ~= nil then
          BlzSetEventDamage(sat * (1.0 + d.bossXe))
        end
      end
    end
  end
end

-- ---------- Do luc vao map ----------

local function probe()
  if CreateUnit == nil or CFG.BOSSES == nil then return end
  local xau = {}
  for i = 1, #CFG.BOSSES do
    local d = CFG.BOSSES[i]
    local u = CreateUnit(S.enemy, d.unit, 0.0, 0.0, 0.0)
    local nhan = "r" .. d.r .. " " .. API.idToStr(d.unit)
    if u == nil then
      xau[#xau + 1] = nhan .. " KHONG CO"
    else
      local bay  = (IsUnitType ~= nil) and IsUnitType(u, UNIT_TYPE_FLYING) or false
      local hero = (IsUnitType ~= nil) and IsUnitType(u, UNIT_TYPE_HERO) or false
      if bay then xau[#xau + 1] = nhan .. " BIET BAY" end
      if not hero then xau[#xau + 1] = nhan .. " khong phai HERO" end
      RemoveUnit(u)
    end
  end
  if #xau > 0 then
    API.msg(nil, CFG.C_RED .. "BOSS SAI: " .. table.concat(xau, " | ") .. CFG.C_END)
    API.trace("boss: SAI -- " .. table.concat(xau, " | "))
  else
    API.trace("boss: " .. #CFG.BOSSES .. " ban thiet ke hop le (hero, khong bay)")
  end
end

local function startBoss()
  S.boss = nil
  probe()
  if BlzGetEventDamageTarget ~= nil then
    local t = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DAMAGED)
    TriggerAddAction(t, onDamage)
  end
  API.trace("boss: san sang")
end

API.bossSpawn = spawn
API.bossTick  = tick
API.startBoss = startBoss
