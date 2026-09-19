-- ============================================================
--  5_natives.lua  --  Ban 1.31.1 nay co nhung gi
--
--  Moi lan doan xem mot native co ton tai hay khong, du an nay deu doan
--  sai. Lan dat nhat: doan "1.31.1 khong co dong bo" trong khi chi la
--  viet thieu tien to Blz -- ba bang giao dien am tham lui ve che do mot
--  nguoi choi suot may ngay ma khong ai biet (ADR 0012).
--
--  Nen: khong doan nua. Do mot lan luc vao map, ghi vao file vet, va cho
--  xem lai bang lenh -nat.
--
--  Goi mot ten toan cuc chua dinh nghia trong Lua tra ve nil chu khong
--  no loi -- nen chi can so sanh voi nil la do duoc.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Moi muc: { ten hien thi, gia tri, giai thich neu THIEU }
local function groups()
  return {
    { name = "Su kien sat thuong", entries = {
      { "EVENT_PLAYER_UNIT_DAMAGED",  EVENT_PLAYER_UNIT_DAMAGED,
        "khong co chu bay, khong lam duoc gi theo sat thuong" },
      { "EVENT_PLAYER_UNIT_DAMAGING", EVENT_PLAYER_UNIT_DAMAGING,
        "khong chan duoc sat thuong TRUOC khi no vao mau" },
      { "BlzSetEventDamage",          BlzSetEventDamage,
        "khong sua duoc so sat thuong -- ne don phai hoi mau bu" },
      { "BlzGetEventDamageTarget",    BlzGetEventDamageTarget, "" },
      { "BlzGetEventAttackType",      BlzGetEventAttackType, "" },
      { "BlzGetEventDamageType",      BlzGetEventDamageType, "" },
      { "UnitDamageTarget",           UnitDamageTarget,
        "khong tu gay sat thuong duoc -- moi skill tu viet deu hong" },
    }},

    -- Cau hoi dang cho: pet Tu Thanh Thu can 4 unit hay 1?
    --
    -- Model nam TRONG dinh nghia unit, nen bon thu = bon unit... TRU KHI
    -- doi duoc "da" luc chay. Neu BlzSetUnitSkin co that thi mot unit pet
    -- duy nhat la du: thu phuc con nao thi doi da sang con do.
    --
    -- Khong doan -- do. UnitRemoveAbility di kem vi bo da hero cung phai
    -- go luon vang sang, va do la nua con lai cua cau hoi.
    { name = "Doi da unit luc CHAY (pet Tu Thanh Thu)", entries = {
      { "BlzSetUnitSkin", BlzSetUnitSkin,
        "moi thu mot unit rieng -- 4 unit chu khong 1" },
      { "BlzGetUnitSkin", BlzGetUnitSkin, "" },
      { "UnitRemoveAbility", UnitRemoveAbility, "" },
    }},

    { name = "Sua so lieu ability luc CHAY", entries = {
      { "BlzGetUnitAbility",            BlzGetUnitAbility, "" },
      { "BlzGetUnitAbilityByIndex",     BlzGetUnitAbilityByIndex, "" },
      { "BlzSetAbilityRealLevelField",  BlzSetAbilityRealLevelField,
        "moi con so phai nam san trong war3map.w3a" },
      { "BlzSetAbilityIntegerLevelField", BlzSetAbilityIntegerLevelField, "" },
      { "BlzSetAbilityStringLevelField",  BlzSetAbilityStringLevelField, "" },
      { "BlzGetAbilityRealLevelField",    BlzGetAbilityRealLevelField, "" },
      { "ABILITY_RLF_DAMAGE_HCA1",        ABILITY_RLF_DAMAGE_HCA1, "" },
      { "BlzSetUnitAbilityCooldown",      BlzSetUnitAbilityCooldown, "" },
      { "BlzSetUnitAbilityManaCost",      BlzSetUnitAbilityManaCost, "" },
    }},

    { name = "Ky nang tu viet", entries = {
      { "EVENT_PLAYER_UNIT_SPELL_EFFECT", EVENT_PLAYER_UNIT_SPELL_EFFECT,
        "khong biet luc nao nguoi choi bam skill" },
      { "GetSpellAbilityId",     GetSpellAbilityId, "" },
      { "GetSpellTargetUnit",    GetSpellTargetUnit, "" },
      { "GetUnitAbilityLevel",   GetUnitAbilityLevel,
        "khong doc duoc level -- khong tra bang so lieu duoc" },
      { "BlzGetAbilityIcon",     BlzGetAbilityIcon, "" },
      { "BlzFrameSetEnable",     BlzFrameSetEnable,
        "chu tren nut se nuot cu bam -- bam dung chu thi khong an" },
    }},

    { name = "Chi so & ten unit", entries = {
      { "BlzSetUnitName",           BlzSetUnitName,
        "quai giu ten goc cua mau linh (Footman, Ghoul...) -- nhin vao" ..
        " con quai khong biet no thuoc canh gioi nao, tang may" },
      { "BlzGetUnitBaseDamage",     BlzGetUnitBaseDamage, "" },
      { "BlzSetUnitBaseDamage",     BlzSetUnitBaseDamage, "" },
      { "BlzGetUnitArmor",          BlzGetUnitArmor, "" },
      { "BlzSetUnitArmor",          BlzSetUnitArmor, "" },
      { "BlzSetUnitMaxHP",          BlzSetUnitMaxHP, "" },
    }},
  }
end

local function countGroup(g)
  local have, missing = 0, {}
  for i = 1, #g.entries do
    if g.entries[i][2] ~= nil then have = have + 1
    else missing[#missing + 1] = g.entries[i][1] end
  end
  return have, missing
end

-- Mot dong moi nhom cho file vet: du ngan de doc luot, du chi tiet de
-- biet thieu cai nao.
local function traceAll()
  local gs = groups()
  for i = 1, #gs do
    local have, missing = countGroup(gs[i])
    local line = "native [" .. gs[i].name .. "] co " .. have .. "/" .. #gs[i].entries
    if #missing > 0 then line = line .. " -- THIEU " .. table.concat(missing, " ") end
    API.trace(line)
  end
end

local function has(name)
  local gs = groups()
  for i = 1, #gs do
    for j = 1, #gs[i].entries do
      if gs[i].entries[j][1] == name then return gs[i].entries[j][2] ~= nil end
    end
  end
  return false
end

-- Liet ke MOI hang so toan cuc co ten chua <loc>. Vi du: "-nat regen".
--
-- Can thiet vi ten hang so moi ban moi khac: ban 1.31.1 KHONG co
-- ABILITY_RLF_DAMAGE_HCA1 nhung cac ham Blz*AbilityField thi co du.
-- Doan ten hang la sai im lang, nen quet thang trong _G roi doc.
--
-- Truoc day ham nay chi quet tien to "ABILITY_", nen "-nat regen" tra
-- ve 0 ket qua va nguoi doc ket luan nham la ban nay khong co truong
-- hoi mau. Gio quet moi ten VIET HOA -- UNIT_RF_*, UNIT_IF_*,
-- ITEM_RF_*, ABILITY_* deu ra.
local function fields(pid, needle)
  needle = needle:upper()
  -- Chat bi cat o CFG.NAT_FIELD_MAX vi man hinh co han. FILE VET thi
  -- khong -- truoc day no ghi cung mot danh sach da cat, nen loc rong
  -- mot chut la mat luon cai minh can tim. Gio ghi DU.
  local hit, all, n = {}, {}, 0
  for k, _ in pairs(_G) do
    if type(k) == "string" and k == k:upper() and #k > 3
       and k:find(needle, 1, true) then
      n = n + 1
      all[#all + 1] = k
      if n <= CFG.NAT_FIELD_MAX then hit[#hit + 1] = k end
    end
  end
  table.sort(all)
  table.sort(hit)
  API.info(pid, CFG.C_GOLD .. "Hang so chua [" .. needle .. "]: " .. n ..
    CFG.C_END)
  for i = 1, #hit do API.msg(pid, "   " .. hit[i]) end
  if n > #hit then
    API.info(pid, CFG.C_GREY .. "   ... con " .. (n - #hit) ..
      " cai nua, loc hep hon di." .. CFG.C_END)
  end
  -- Preload() CAT chuoi dai (do duoc: dong ghi ra chi con 278 ky tu,
  -- 7 ten tren 414). Nen chia nho ra nhieu dong chu khong noi mot chuoi
  -- -- mot file vet bi cat lang le con te hon khong ghi gi, vi no trong
  -- nhu da ghi du.
  API.trace("nat fields [" .. needle .. "] = " .. n)
  local row, part = {}, 0
  for k = 1, #all do
    row[#row + 1] = all[k]
    if #row >= 6 or k == #all then
      part = part + 1
      API.trace("  [" .. needle .. " " .. part .. "] " .. table.concat(row, " "))
      row = {}
    end
  end
end

local function report(pid)
  local gs = groups()
  API.info(pid, CFG.C_GOLD .. "=== Ban " .. CFG.VERSION .. " co nhung gi ===" .. CFG.C_END)
  for i = 1, #gs do
    local have, missing = countGroup(gs[i])
    local color = (#missing == 0) and CFG.C_JADE or CFG.C_RED
    API.msg(pid, color .. gs[i].name .. ": " .. have .. "/" .. #gs[i].entries .. CFG.C_END)
    for k = 1, #missing do
      API.info(pid, "   " .. CFG.C_RED .. "thieu " .. missing[k] .. CFG.C_END)
    end
  end
end

-- ---------- O trong command card ----------
--
-- Command card la luoi 4x3. Moi ability chiem mot o do abpx/abpy trong
-- war3map.w3a quyet dinh, va HAI ability cung o thi de len nhau -- cai
-- sau che cai truoc, khong loi nao bao.
--
-- w3skill.py xep bay ky nang cua Hart vao bay o, dua tren mot cau ghi
-- trong chinh no: "lenh co ban chiem (0,0)-(3,0) va (0,1)". Cau do
-- KHONG DUOC DO bao gio. Neu that ra Move/Stop/Patrol/Hold nam o hang
-- DUOI (y=2) -- nhu tri nho cua moi nguoi ve Warcraft -- thi bon ky
-- nang bi dong dang nam dung cho bon lenh co ban.
--
-- Voi SKILL_START_COUNT = 0 thi khong ai thay: hero vao map tay khong.
-- Voi ca bay phat san thi no hien ra ngay. Nen do, dung doan.
local X_FIELD = "ABILITY_IF_BUTTON_POSITION_NORMAL_X"
local Y_FIELD = "ABILITY_IF_BUTTON_POSITION_NORMAL_Y"

local CO_BAN = {
  { "Amov", "Move" }, { "Astp", "Stop" }, { "Ahol", "Hold" },
  { "Apat", "Patrol" }, { "Aatk", "Attack" },
}

local function buttonSlotOf(u, aid)
  if BlzGetUnitAbility == nil or BlzGetAbilityIntegerField == nil then
    return nil, "thieu BlzGetUnitAbility / BlzGetAbilityIntegerField"
  end
  local fx, fy = _G[X_FIELD], _G[Y_FIELD]
  if fx == nil or fy == nil then
    return nil, "ban nay khong co " .. X_FIELD
  end
  local ab = BlzGetUnitAbility(u, aid)
  if ab == nil then return nil, "unit khong co ability nay" end
  return BlzGetAbilityIntegerField(ab, fx), nil,
         BlzGetAbilityIntegerField(ab, fy)
end

-- In o that cua ca lenh co ban lan bay ky nang, va bao o nao bi hai
-- ability cung nhan.
--
-- DA DO (2026-09-16): Warcraft KHONG dat lenh co ban bang truong nay.
-- Amov va Aatk deu tra ve (0,0), con Astp / Ahol / Apat thi unit khong
-- he co nhu mot ability. Vi tri that cua chung do game quyet dinh.
--
-- Nen chi dem trung o giua BAY KY NANG. Lan dau ham nay dem ca lenh co
-- ban va bao do "1 o bi hai ability cung nhan" -- bao dong gia, vi Move
-- va Attack deu doc ra (0,0). Mot cai thuoc bao sai con te hon khong co
-- thuoc: no lam nguoi ta di sua thu dang dung.
local function card(pid)
  local d = S.p[pid]
  local u = d and d.hero or nil
  if u == nil then
    API.warn(pid, "Chua co hero -- pick hero roi go lai.")
    return
  end

  API.info(pid, CFG.C_GOLD .. "=== O command card (4x3) ===" .. CFG.C_END)

  local taken = {}
  -- dem = true: o cua frame nay tinh vao viec do trung o.
  local function emit(name, aid, countOnly)
    local x, err, y = buttonSlotOf(u, aid)
    if x == nil then
      API.msg(pid, CFG.C_GREY .. "   " .. name .. ": " .. (err or "?") .. CFG.C_END)
      API.trace("card " .. name .. ": " .. (err or "?"))
      return
    end
    local o = x .. "," .. y
    if not countOnly then
      API.msg(pid, CFG.C_GREY .. "   (" .. o .. ") " .. name ..
              "  -- game tu dat, so nay khong tin duoc" .. CFG.C_END)
      API.trace("card [lenh] " .. name .. " = (" .. o .. ")")
      return
    end
    local old = taken[o]
    taken[o] = (old and (old .. " + " .. name)) or name
    local color = old and CFG.C_RED or CFG.C_JADE
    API.msg(pid, "   " .. color .. "(" .. o .. ")" .. CFG.C_END .. " " .. name ..
            (old and (CFG.C_RED .. "  DE LEN " .. old .. CFG.C_END) or ""))
    API.trace("card " .. name .. " = (" .. o .. ")")
  end

  for i = 1, #CO_BAN do emit(CO_BAN[i][2], FourCC(CO_BAN[i][1]), false) end

  local sk = CFG.SKILLS[GetUnitTypeId(u)]
  if sk ~= nil then
    for i = 1, #sk do emit(API.pick(sk[i]), sk[i].id, true) end
  end

  local n = 0
  for _, v in pairs(taken) do if v:find("+", 1, true) then n = n + 1 end end
  if n > 0 then
    API.warn(pid, n .. " o bi hai KY NANG cung nhan -- sua " ..
      "O_CHUDONG/O_BIDONG trong w3skill.py roi chay lai 'gen'.")
  else
    API.info(pid, CFG.C_JADE .. "Bay ky nang, bay o, khong o nao trung." .. CFG.C_END)
  end
end

-- ---------- Do hoi mau that cua hero ----------
--
-- Cau hoi: dat BlzSetUnitRealField(hero, <truong hoi mau>, x) co an
-- khong, va no co bi xoa khi chi so hero doi khong?
--
-- Doc lai truong bang BlzGetUnitRealField KHONG tra loi duoc: no cho
-- biet truong GHI gi, khong cho biet engine hoi bao nhieu mau. Nen do
-- mau that: ha mau xuong nua, cho N giay, xem len bao nhieu.
--
-- Do LUON HAI LAN, truoc va sau khi cong chi so, vi hai cau hoi khac
-- nhau tron trong cung mot phep do:
--   lan 1  truong co an khong
--   lan 2  cong Str co XOA mat khong, va mot diem Str dang gia bao nhieu
--
-- Cong Str lam TANG mau toi da VA mau hien tai cung mot luc, nen phai
-- ghi lai mau SAU khi cong roi moi bam gio lan hai -- khong thi phan
-- mau Str tang len bi tinh nham thanh hoi mau.
-- Mot khuon cho CA HAI: mau va mana. Hai phep do giong het nhau, chi
-- khac ten truong, o trang thai, va chi so nao cong vao.
--
-- Dung chung mot ham chu khong chep doi: neu chep thi sua mot ben quen
-- ben kia, va hai con so do bang hai doan code khac nhau thi khong con
-- so sanh duoc voi nhau.
local DO_LOAI = {
  hp = {
    name    = "mau",
    field = "UNIT_RF_HIT_POINTS_REGENERATION_RATE",
    cur    = function() return UNIT_STATE_LIFE end,
    max    = function() return UNIT_STATE_MAX_LIFE end,
    read    = function(u) return GetHeroStr(u, false), GetHeroStr(u, true) end,
    emit    = function(u, v) SetHeroStr(u, v, true) end,
    statProbe  = "Str",
  },
  mana = {
    name    = "mana",
    field = "UNIT_RF_MANA_REGENERATION",
    cur    = function() return UNIT_STATE_MANA end,
    max    = function() return UNIT_STATE_MAX_MANA end,
    read    = function(u) return GetHeroInt(u, false), GetHeroInt(u, true) end,
    emit    = function(u, v) SetHeroInt(u, v, true) end,
    statProbe  = "Int",
  },
}

local REG_TEST = 7.0
local REG_STEP = 10

local function regen(pid, secs, kind)
  secs = secs or 8.0
  local L = DO_LOAI[kind or "hp"]
  if L == nil then L = DO_LOAI.hp end

  local d = S.p[pid]
  local h = d and d.hero or nil
  if h == nil then
    API.warn(pid, "Chua co hero -- pick hero roi go lai.")
    return
  end

  local F = _G[L.field]
  API.info(pid, CFG.C_GOLD .. "=== Do hoi " .. L.name .. " (" .. secs ..
          "s x2) ===" .. CFG.C_END)
  API.info(pid, "   hang so " .. L.field .. ": " ..
          (F ~= nil and (CFG.C_JADE .. "CO" .. CFG.C_END)
                    or (CFG.C_RED .. "KHONG CO -- go '-nat regen'" .. CFG.C_END)))
  if F == nil or BlzGetUnitRealField == nil or BlzSetUnitRealField == nil then
    API.warn(pid, "   thieu native BlzGet/SetUnitRealField -- dung.")
    return
  end

  -- KIEU hoi mau, chi co ben mau. Neu hero la Night/Blight thi dat rate
  -- bao nhieu cung bang 0 ngoai dieu kien do, va phep do se ra 0 ma
  -- khong noi duoc TAI SAO.
  if kind ~= "mana" then
    local TF = _G["UNIT_IF_HIT_POINTS_REGENERATION_TYPE"]
    if TF ~= nil and BlzGetUnitIntegerField ~= nil then
      local v, name = BlzGetUnitIntegerField(h, TF), "?"
      local names = { "NONE", "ALWAYS", "DAY", "NIGHT", "BLIGHT" }
      for k = 1, #names do
        if _G["REGENERATION_TYPE_" .. names[k]] == v then name = names[k] end
      end
      local bad = (name == "NIGHT" or name == "BLIGHT" or name == "NONE")
      API.info(pid, "   kieu hoi mau (uhrt)        : " ..
              (bad and CFG.C_RED or CFG.C_JADE) .. name .. CFG.C_END)
    end
  end

  API.msg(pid, CFG.C_GREY ..
    "   Dung danh nhau luc do -- mot cu danh vao hero la so sai het." .. CFG.C_END)

  -- Ha xuong 10%, khong phai 50%.
  --
  -- Voi 50% thi be mana (75) day lai sau 5.4 giay, va phep do 15 giay
  -- chia cho ca 15 giay do -> ra 2.50 thay vi 7.00. So do KHONG sai mot
  -- chut nao, no la trung binh dung -- nhung no tra loi mot cau hoi
  -- khac voi cau minh hoi. Be mau (425) khong bao gio day kip nen ben
  -- mau khong lo, va do la ly do loi nay chi lo ra o ben mana.
  local maxV = GetUnitState(h, L.max())
  SetUnitState(h, L.cur(), maxV * 0.10)

  local before = BlzGetUnitRealField(h, F)
  BlzSetUnitRealField(h, F, REG_TEST)
  API.info(pid, "   truong truoc / sau khi dat : " ..
          string.format("%.3f", before) .. " -> " ..
          string.format("%.3f", BlzGetUnitRealField(h, F)))

  -- In CA HAI chi so. Neu goc va tong bang nhau thi phep do KHONG phan
  -- biet duoc "engine dung chi so goc" voi "dung chi so tong" -- noi
  -- thang ra thay vi de nguoi doc tu suy.
  local sBase, sTotal = L.read(h)
  API.info(pid, "   " .. L.statProbe .. " goc / tong" ..
          string.rep(" ", 16 - #L.statProbe) .. ": " .. sBase .. " / " .. sTotal ..
          (sBase ~= sTotal and (CFG.C_GOLD .. "  <- khac nhau, phan biet duoc" .. CFG.C_END)
                          or (CFG.C_GREY .. "  (bang nhau -- khong phan biet duoc)" .. CFG.C_END)))

  -- Cham tran thi so trung binh vo nghia -- phai BAO, dung de nguoi doc
  -- tuong day la toc do hoi that.
  local function report(pid2, tag, r, last)
    local full = (last >= maxV - 0.01)
    API.msg(pid2, (full and CFG.C_RED or CFG.C_JADE) ..
            "   hoi THAT " .. tag .. " : " .. string.format("%.2f", r) ..
            " " .. L.name .. "/giay" .. CFG.C_END ..
            (full and (CFG.C_RED .. "  -> DA DAY BINH, so nay VO NGHIA." ..
                      " Go '-reg " .. (kind == "mana" and "mana " or "") ..
                      "3' cho ngan lai." .. CFG.C_END) or ""))
    return full
  end

  local v0 = GetUnitState(h, L.cur())
  API.after(secs, function()
    local c1 = GetUnitState(h, L.cur())
    local r1 = (c1 - v0) / secs
    report(pid, "lan 1", r1, c1)

    L.emit(h, sBase + REG_STEP)
    local after = BlzGetUnitRealField(h, F)
    API.info(pid, "   truong sau +" .. REG_STEP .. " " .. L.statProbe .. " : " ..
            string.format("%.3f", after) ..
            (math.abs(after - REG_TEST) > 0.01
             and (CFG.C_RED .. "  -> DA BI TINH LAI" .. CFG.C_END)
             or  (CFG.C_JADE .. "  -> giu nguyen" .. CFG.C_END)))

    SetUnitState(h, L.cur(), maxV * 0.10)
    local v1 = GetUnitState(h, L.cur())
    API.after(secs, function()
      local c2 = GetUnitState(h, L.cur())
      local r2 = (c2 - v1) / secs
      local full = report(pid, "lan 2", r2, c2)
      API.msg(pid, (full and CFG.C_GREY or CFG.C_GOLD) ..
              "   => mot diem " .. L.statProbe .. " = " ..
              string.format("%.4f", (r2 - r1) / REG_STEP) .. " " ..
              L.name .. "/giay" .. CFG.C_END)
      L.emit(h, sBase)
      API.trace("reg[" .. L.name .. "]: r1=" .. r1 .. " r2=" .. r2 ..
                " truong_sau=" .. after)
    end)
  end)
end

-- Liet ke hang so ABILITY_* cua TUNG ky nang, tra theo ma ability GOC.
--
-- Vi sao can: mot ability nhan ban van GIU NGUYEN hieu ung cua ability
-- goc. Chuong la ban sao cua Shockwave nen no tu gay 110 sat thuong cua
-- Shockwave, roi fxLine cua du an cong them mot lan nua -- bang ghi 39.6
-- ma man hinh hien 111.
--
-- Muon tat hieu ung goc thi phai goi Blz*AbilityRealLevelField voi dung
-- ten hang so, ma ten hang so moi ban moi khac. Do, dung doan.
local function spells(pid)
  local d = S.p[pid]
  local u = d and d.hero or nil
  local sk = (u ~= nil) and CFG.SKILLS[GetUnitTypeId(u)] or nil
  if sk == nil then
    API.warn(pid, "Chua co hero -- pick hero roi go lai.")
    return
  end

  API.info(pid, CFG.C_GOLD .. "=== Hang so theo ability goc ===" .. CFG.C_END)
  for i = 1, #sk do
    local g = sk[i].baseAbil
    if g == nil then
      API.msg(pid, CFG.C_GREY .. "   " .. API.pick(sk[i]) ..
              ": chua ghi 'goc' trong CFG.SKILLS" .. CFG.C_END)
    else
      -- Bo chu cai dau (A/O/H/u...) de khop rong hon: "AOsh" -> "OSH".
      local needle = g:sub(2):upper()
      local hit = {}
      for k, _ in pairs(_G) do
        if type(k) == "string" and k:sub(1, 8) == "ABILITY_"
           and k:find(needle, 1, true) then
          hit[#hit + 1] = k
        end
      end
      table.sort(hit)
      API.msg(pid, CFG.C_JADE .. "   " .. API.pick(sk[i]) .. CFG.C_END ..
              "  goc " .. g .. "  -> " .. #hit .. " hang so")
      for k = 1, #hit do
        if k > 6 then break end
        API.msg(pid, "      " .. hit[k])
      end
      API.trace("spell " .. g .. ": " .. table.concat(hit, " "))
    end
  end
  API.msg(pid, CFG.C_GREY ..
    "   Day du nam trong DarknessTrace.txt." .. CFG.C_END)
end

-- ---------- Mot diem chi so doi ra bao nhieu ----------
--
-- Can cho he QUAY: the 2 cong chi so, the 3 cong mau/mana. Muon hai the
-- dang gia NGANG NHAU thi phai biet ti gia -- va ti gia do la hang so
-- gameplay cua Warcraft, khong nam trong map nay (khong co
-- war3mapMisc.txt nen dung mac dinh).
--
-- Tri nho noi 1 Str = 25 mau va 1 Int = 15 mana. Do di, dung tin --
-- cung ly do da phai do 0.05 hoi mau/Str bang "-reg".
--
-- Do TUC THI, khong can dong ho: cong 100 diem, doc lai, chia 100.
-- Cong 100 chu khong phai 1 de sai so lam tron khong nuot mat ket qua.
local DO_BUOC = 100

local function statProbe(pid)
  local d = S.p[pid]
  local h = d and d.hero or nil
  if h == nil then
    API.warn(pid, "Chua co hero -- pick hero roi go lai.")
    return
  end

  API.info(pid, CFG.C_GOLD .. "=== Mot diem chi so doi ra gi ===" .. CFG.C_END)

  local function measureOne(name, getf, setf, readf, unitName)
    if getf == nil or setf == nil then return end
    local baseAbil = getf(h, false)
    local v0  = readf(h)
    setf(h, baseAbil + DO_BUOC, true)
    local v1 = readf(h)
    setf(h, baseAbil, true)
    API.msg(pid, "   " .. name .. " +" .. DO_BUOC .. " -> " .. unitName .. " +" ..
            string.format("%.1f", v1 - v0) .. CFG.C_END ..
            CFG.C_GOLD .. "   => 1 " .. name .. " = " ..
            string.format("%.3f", (v1 - v0) / DO_BUOC) .. " " .. unitName .. CFG.C_END)
    API.trace("stat: 1 " .. name .. " = " .. ((v1 - v0) / DO_BUOC) .. " " .. unitName)
  end

  measureOne("Str", GetHeroStr, SetHeroStr,
      function(u) return GetUnitState(u, UNIT_STATE_MAX_LIFE) end, "mau")
  measureOne("Int", GetHeroInt, SetHeroInt,
      function(u) return GetUnitState(u, UNIT_STATE_MAX_MANA) end, "mana")
  if BlzGetUnitArmor ~= nil then
    measureOne("Agi", GetHeroAgi, SetHeroAgi,
        function(u) return BlzGetUnitArmor(u) end, "armor")
  end

  -- Tra chi so ve dung duong ma du an dung, khong tu dat lai bang tay:
  -- heroRecompute la CHO DUY NHAT duoc ghi chi so hero.
  if API.heroRecompute ~= nil then API.heroRecompute(pid) end
  API.info(pid, CFG.C_GREY .. "   Da tra chi so ve nhu cu." .. CFG.C_END)
end

local function onChat(pid, raw)
  -- "-nat card" -> in o command card that cua hero dang cam
  if raw ~= nil then
    if raw:match("^%s*%-nat%s+card%s*$") ~= nil then return card(pid) end
    if raw:match("^%s*%-nat%s+spell%s*$") ~= nil then return spells(pid) end
    if raw:match("^%s*%-nat%s+stat%s*$") ~= nil then return statProbe(pid) end
    -- "-nat dam" -> liet ke hang so ability co ten chua "dam"
    local needle = raw:match("^%s*%-nat%s+(%S+)")
    if needle ~= nil then return fields(pid, needle) end
  end
  return report(pid)
end

local function startNatives()
  traceAll()
end

API.nativeHas    = has
API.nativeChat   = onChat
API.nativeFields = fields
API.nativeCard   = card
API.nativeSpells = spells
API.nativeStat  = statProbe
API.nativeRegen  = regen
API.startNatives = startNatives
