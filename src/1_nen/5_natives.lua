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
    { ten = "Su kien sat thuong", muc = {
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

    { ten = "Sua so lieu ability luc CHAY", muc = {
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

    { ten = "Ky nang tu viet", muc = {
      { "EVENT_PLAYER_UNIT_SPELL_EFFECT", EVENT_PLAYER_UNIT_SPELL_EFFECT,
        "khong biet luc nao nguoi choi bam skill" },
      { "GetSpellAbilityId",     GetSpellAbilityId, "" },
      { "GetSpellTargetUnit",    GetSpellTargetUnit, "" },
      { "GetUnitAbilityLevel",   GetUnitAbilityLevel,
        "khong doc duoc level -- khong tra bang so lieu duoc" },
      { "BlzGetAbilityIcon",     BlzGetAbilityIcon, "" },
    }},

    { ten = "Chi so hero", muc = {
      { "BlzGetUnitBaseDamage",     BlzGetUnitBaseDamage, "" },
      { "BlzSetUnitBaseDamage",     BlzSetUnitBaseDamage, "" },
      { "BlzGetUnitArmor",          BlzGetUnitArmor, "" },
      { "BlzSetUnitArmor",          BlzSetUnitArmor, "" },
      { "BlzSetUnitMaxHP",          BlzSetUnitMaxHP, "" },
    }},
  }
end

local function countGroup(g)
  local co, thieu = 0, {}
  for i = 1, #g.muc do
    if g.muc[i][2] ~= nil then co = co + 1
    else thieu[#thieu + 1] = g.muc[i][1] end
  end
  return co, thieu
end

-- Mot dong moi nhom cho file vet: du ngan de doc luot, du chi tiet de
-- biet thieu cai nao.
local function traceAll()
  local gs = groups()
  for i = 1, #gs do
    local co, thieu = countGroup(gs[i])
    local line = "native [" .. gs[i].ten .. "] co " .. co .. "/" .. #gs[i].muc
    if #thieu > 0 then line = line .. " -- THIEU " .. table.concat(thieu, " ") end
    API.trace(line)
  end
end

local function has(name)
  local gs = groups()
  for i = 1, #gs do
    for j = 1, #gs[i].muc do
      if gs[i].muc[j][1] == name then return gs[i].muc[j][2] ~= nil end
    end
  end
  return false
end

local function onChat(pid)
  local gs = groups()
  API.msg(pid, CFG.C_GOLD .. "=== Ban " .. CFG.VERSION .. " co nhung gi ===" .. CFG.C_END)
  for i = 1, #gs do
    local co, thieu = countGroup(gs[i])
    local mau = (#thieu == 0) and CFG.C_JADE or CFG.C_RED
    API.msg(pid, mau .. gs[i].ten .. ": " .. co .. "/" .. #gs[i].muc .. CFG.C_END)
    for k = 1, #thieu do
      API.msg(pid, "   " .. CFG.C_RED .. "thieu " .. thieu[k] .. CFG.C_END)
    end
  end
end

local function startNatives()
  traceAll()
end

API.nativeHas    = has
API.nativeChat   = onChat
API.startNatives = startNatives
