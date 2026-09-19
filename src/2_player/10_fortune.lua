-- ============================================================
--  10_fortune.lua  --  The VI: Quay thuong
--
--  Giet tinh anh 1 luot, boss 3 luot. Moi luot mo CFG.FORTUNE_KINDS
--  the, chon MOT.
--
--    "gold"    vang, PHANG, ngau nhien FORTUNE_GOLD_MIN..MAX
--    "stat"    +V vao MOT chi so ngau nhien trong ba
--    "lumber"  Go, PHANG va CO DINH -- xem CFG.FORTUNE_LUMBER
--
--  V = CFG.FORTUNE_VALUE x CULT_STAT_STEP^(bac-1), ngau nhien +-30%.
--  CHI the "stat" dung V. Dung CHINH buoc cua Tu Vi nen no tu bam theo
--  -- doi duong cong Tu Vi thi the nay tu co theo.
--
--  The "gold" KHONG dung V: no la TIEN, ma tien thi phang. Nhung no van
--  song song voi the "stat", vi thu no mua (bac Trang Bi) moi la thu
--  leo -- xem chu thich CFG.FORTUNE_KINDS.
--
--  SO THE DOC TU CFG, khong go cung. Them mot the la them mot dong vao
--  CFG.FORTUNE_KINDS va mot nhanh trong take(); khung tu co theo.
--
--  THE SINH O DAU, va vi sao cho do.
--
--  GetRandomInt cua Warcraft da dong bo san giua cac may, VOI DIEU KIEN
--  moi may goi cung so lan va cung thu tu. Goi no trong mot nhanh
--  GetLocalPlayer() la moi may tieu mot so khac nhau tu chuoi ngau
--  nhien, va tu giay do MOI so ngau nhien cua ca van deu lech.
--
--  Nen the duoc sinh trong addRolls() -- ham do chay tu su kien quai
--  chet, tuc chay tren MOI may. Mo bang la UI thuan, khong sinh gi ca.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Gia tri mot the o bac hien tai, da nhan he so ngau nhien.
local function rollValue(pid)
  local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
  local v = CFG.FORTUNE_VALUE * CFG.CULT_STAT_STEP ^ (rank - 1)
  local lo = math.floor(v * CFG.FORTUNE_RANGE_MIN * 100.0 + 0.5)
  local hi = math.floor(v * CFG.FORTUNE_RANGE_MAX * 100.0 + 0.5)
  if hi < lo then hi = lo end
  return GetRandomInt(lo, hi) / 100.0
end

-- Sinh mot the theo LOAI. Tach rieng de them loai moi la them mot
-- nhanh, khong phai sua vong lap.
--
-- Moi nhanh goi GetRandomInt DUNG SO LAN NHU NHAU tren moi may -- do la
-- dieu kien duy nhat de chuoi ngau nhien khong lech (xem dau file).
local function makeCard(pid, kind, v)
  if kind == "gold" then
    return { kind = kind,
             amount = GetRandomInt(CFG.FORTUNE_GOLD_MIN, CFG.FORTUNE_GOLD_MAX) }
  elseif kind == "stat" then
    return { kind = kind, amount = math.floor(v + 0.5),
             stat = CFG.FORTUNE_STATS[GetRandomInt(1, #CFG.FORTUNE_STATS)] }
  elseif kind == "lumber" then
    -- CO DINH, khong goi GetRandomInt. Xem CFG.FORTUNE_LUMBER.
    return { kind = kind, amount = CFG.FORTUNE_LUMBER or 1 }
  elseif kind == "iron" then
    -- The da da bo khoi CFG.FORTUNE_KINDS, nhanh nay giu de bat lai
    -- bang mot dong CFG neu can. Khong co CFG.FORTUNE_IRON nua thi coi
    -- nhu 0 chu khong sap.
    return { kind = kind, amount = CFG.FORTUNE_IRON or 0 }
  end
  API.trace("fortune: khong biet loai the '" .. tostring(kind) .. "'")
  return nil
end

-- Rut mot luot the moi. Chay tren MOI may -- xem chu thich dau file.
--
-- RUT CFG.FORTUNE_DRAW TRONG SO CFG.FORTUNE_KINDS. Mo ca ba the thi
-- no thanh "chon cai to nhat", ma cai to nhat thi tinh ra duoc -- tuc
-- khong con la lua chon. Rut hai trong ba thi moi luot la mot cau hoi
-- khac: Go/Chi So, Go/Vang, hay Chi So/Vang.
--
-- DONG BO: ham nay chay tu addRolls(), tuc tu su kien quai chet, tuc
-- tren MOI may. Moi may boc cung thu tu tu cung chuoi ngau nhien nen
-- ra cung bo the. Tuyet doi khong goi tu callback frame (ADR 0012).
--
-- Boc kieu "rut khong hoan lai": sao chep danh sach roi nhat ra, de
-- khong bao gio ra hai the trung loai.
local function drawCards(pid)
  local d = S.p[pid]
  if d == nil then return end
  local v = rollValue(pid)

  local pool = {}
  for i = 1, #CFG.FORTUNE_KINDS do pool[i] = CFG.FORTUNE_KINDS[i] end

  local want = CFG.FORTUNE_DRAW or #pool
  if want > #pool then want = #pool end

  local out = {}
  for _ = 1, want do
    local k = GetRandomInt(1, #pool)
    local kind = pool[k]
    table.remove(pool, k)
    out[#out + 1] = makeCard(pid, kind, v)
  end
  d.cards = out
end

-- Goi tu 2_wave.lua khi ha tinh anh / boss. Chay tren MOI may.
local function addRolls(pid, n)
  local d = S.p[pid]
  if d == nil or n == nil or n <= 0 then return end
  d.rolls = (d.rolls or 0) + n
  -- Chua co the nao thi rut ngay. RUT o day chu khong o cho mo khung:
  -- ham nay chay tren moi may, con mo khung la UI thuan (ADR 0012).
  if d.cards == nil then drawCards(pid) end

  -- KHONG MO KHUNG O DAY NUA -- 2026-09-20.
  --
  -- LOI DA SHIP: khung bat len NGAY luc tinh anh chet, ma tinh anh chet
  -- GIUA WAVE -- con 49 con dang go nguoi choi. Ba hau qua:
  --
  --   1. Phai chon the trong luc dang bi danh. Ca he Co Duyen dung de
  --      nguoi choi CAN NHAC, ma khoanh khac can nhac lai dat dung vao
  --      luc khong ai can nhac duoc -- no thanh mot thu phai gat di.
  --   2. Khung goi panelHide(), tuc DONG BANG ESC cua nguoi choi. Dang
  --      mua trang bi thi mat cho dang dung.
  --   3. Do duoc: 168 luot mot van. Van 90 phut la MOT LAN MOI 32 GIAY,
  --      va sau Thanh Long la 12 lan lien tiep.
  --
  -- Gio chi bao mot dong. Khung bat khi DON SACH WAVE -- cho nhip da
  -- dung san (ADR 0026) -- va gom ca wave vao mot lan.
  API.msg(pid, CFG.C_GOLD .. API.t("fortune_pending", d.rolls) .. CFG.C_END)
end

-- Goi tu 2_wave.lua luc don sach wave, va tu phim R.
--
-- Tra ve true neu co mo khung -- ben goi dung no de biet co nen lam
-- viec khac hay khong.
local function showIfPending(pid)
  local d = S.p[pid]
  if d == nil or (d.rolls or 0) <= 0 then return false end
  if d.cards == nil then drawCards(pid) end
  if API.fortuneFrameShow == nil then return false end
  API.fortuneFrameShow(pid)
  return true
end

-- ---------- Nhan the ----------
-- Chay tren MOI may, tu kenh dong bo.

local function take(pid, i)
  local d = S.p[pid]
  if d == nil or d.cards == nil then return end
  if (d.rolls or 0) <= 0 then return end
  local card = d.cards[i]
  if card == nil then return end

  if card.kind == "iron" then
    d.iron = (d.iron or 0) + card.amount

  elseif card.kind == "stat" then
    -- Cong vao bang CONG DON rieng, khong dat thang chi so hero:
    -- heroRecompute la cho DUY NHAT duoc ghi chi so, va no ghi de moi
    -- lan chay. Dat thang o day la lan sau recompute xoa mat.
    d.rollStats = d.rollStats or { str = 0, agi = 0, int = 0 }
    d.rollStats[card.stat] = (d.rollStats[card.stat] or 0) + card.amount
    if API.heroRecompute ~= nil then API.heroRecompute(pid) end

  elseif card.kind == "gold" then
    API.addGold(pid, card.amount)

  elseif card.kind == "lumber" then
    -- Di qua addLumber chu khong SetPlayerState: do la mot trong HAI
    -- duong ghi hop le, va no cap nhat so cai cua canh cheat.
    API.addLumber(pid, card.amount)
  end

  API.msg(pid, API.t("fortune_took", CFG.C_JADE .. API.fortuneLabel(card) .. CFG.C_END))

  d.rolls = d.rolls - 1
  if d.rolls > 0 then
    drawCards(pid)
    if API.fortuneFrameRefresh ~= nil then API.fortuneFrameRefresh(pid) end
  else
    d.cards = nil
    if API.fortuneFrameHide ~= nil then API.fortuneFrameHide(pid) end
  end
  API.panelRefresh(pid)
end

-- ---------- Chu cho tung the ----------

local function labelOf(card)
  if card == nil then return "" end
  if card.kind == "iron" then
    return API.num(card.amount) .. " " .. API.t("cur_iron")
  elseif card.kind == "stat" then
    return "+" .. API.num(card.amount) .. " " .. API.t("stat_" .. card.stat)
  elseif card.kind == "lumber" then
    return "+" .. API.num(card.amount) .. " " .. API.t("cur_lumber")
  end
  return "+" .. API.num(card.amount) .. " " .. API.t("cur_gold")
end

-- Icon KHONG go duong dan tay nua.
--
-- Da doan sai ba lan: BTNRingViolet (o xanh la), BTNStrength (o xanh
-- la), BTNGoldmine (ra cai NHA chu khong phai dong tien). Duong dan
-- texture khong liet ke duoc tu ngoai -- game dong goi bang CASC.
--
-- Nen DOC tu chinh doi tuong cua game, giong cach 8_shop.lua lam:
--   BlzGetAbilityIcon(id)  icon that cua mot ability
--   BlzGetItemIconPath(it) icon that cua mot item vua tao
--
-- Gia tri ban dau chi la duong LUI: chung deu la duong dan DA CHUNG
-- MINH la ve ra hinh (dang dung o the Trang Bi), nen sai lam thi ra
-- icon khong hop nghia chu KHONG BAO GIO ra o xanh la nua.
local ICON = {
  iron    = [[ReplaceableTextures\CommandButtons\BTNStaffOfSanctuary.blp]],
  stat = [[ReplaceableTextures\CommandButtons\BTNSteelMelee.blp]],
  gold  = [[ReplaceableTextures\CommandButtons\BTNTalisman.blp]],
  -- Duong LUI da chung minh ve ra hinh (the Trang Bi dang dung).
  lumber = [[ReplaceableTextures\CommandButtons\BTNSteelArmor.blp]],
}

-- Do icon that luc vao map. Moi muc: { khoa, ma item de thu, ability
-- de lui ve }.
local function probeIcons()
  -- 1. Chi so: lay tu chinh ability Luyen The (A004). Chac chan co --
  --    no dang ve ra hinh o the Ky Nang.
  if BlzGetAbilityIcon ~= nil then
    local p = BlzGetAbilityIcon(FourCC("A004"))
    if p ~= nil and p ~= "" then ICON.stat = p end
  end

  -- 2. Vang va da: thu tao item roi doc icon that cua no.
  --    CreateItem tra nil khi ma khong ton tai -> giu duong lui va GHI
  --    VET, khong nuot im.
  if CreateItem ~= nil and BlzGetItemIconPath ~= nil then
    local probes = { { "gold", "gold" }, { "iron", "ingt" },
                     { "lumber", "lmbr" } }
    for i = 1, #probes do
      local field, code = probes[i][1], probes[i][2]
      local it = CreateItem(FourCC(code), 0.0, 0.0)
      if it == nil then
        API.trace("fortune: khong co item '" .. code .. "', giu icon lui cho " .. field)
      else
        local p = BlzGetItemIconPath(it)
        if p ~= nil and p ~= "" then ICON[field] = p end
        RemoveItem(it)
      end
    end
  end

  for k, v in pairs(ICON) do
    API.trace("fortune: icon " .. k .. " = " .. tostring(v))
  end
end

-- ---------- Giao dien ----------
--
-- KHONG con la mot the trong bang. Khung rieng, ba cot doc, mo NGAY khi
-- tinh anh/boss chet -- xem 4_ui/5_fortuneframe.lua.

local function hasRolls(pid)
  local d = S.p[pid]
  return d ~= nil and (d.rolls or 0) > 0 and d.cards ~= nil
end

local function cardsOf(pid)
  local d = S.p[pid]
  return (d ~= nil) and d.cards or nil
end

local function rollCount(pid)
  local d = S.p[pid]
  return (d ~= nil) and (d.rolls or 0) or 0
end

local function startFortune()
  probeIcons()
  API.syncOn(CFG.OP_FORTUNE, take)
  API.trace("fortune: san sang")
end

API.fortuneAddRolls = addRolls
API.fortuneShowPending = showIfPending
API.fortuneLabel     = labelOf
API.fortuneTake     = take
API.fortuneHasRolls  = hasRolls
API.fortuneCards      = cardsOf
API.fortuneRolls   = rollCount
API.fortuneIcon     = function(kind) return ICON[kind] end
API.startFortune    = startFortune
