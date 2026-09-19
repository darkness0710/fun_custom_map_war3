-- ============================================================
--  6_relic.lua  --  Mua MOT lan, khong co cap
--
--  BANG DANG RONG (CFG.RELIC = {}) -- 2026-09-16. Nam mon cu da xoa:
--  chung mua bang Tinh Thach, mot dong tien gio da xoa han. He nay
--  tra bang GO.
--
--  NGAN SACH DANH SAN: ca van kiem 260 Go, ky nang tieu 70, nen con
--  190 diem cho day. Do la rang buoc khi thiet ke lai.
--
--  Code chay duoc voi bang rong: the hien mot dong "chua co gi", khong
--  mua duoc gi, va moi hieu ung tra ve false -- nen 2_wave.lua goi
--  API.relicHas / relicAnyHas / relicOnClear van an toan.
--
--  KHI THEM MON MOI. Moi mon phai DOC-LUC-DUNG: khong dang ky trigger
--  rieng, ma cho can biet thi hoi API.relicHas. Mot mon can bo bat su
--  kien rieng la mot mon co the hong am tham, ma ca van chi mua duoc
--  vai lan. Them mon la them dong vao CFG.RELIC VA viet cho doc 'ma'
--  cua no -- khong co bang dieu phoi tu dong nao ca.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Nguoi nay co mon do khong.
local function has(pid, code)
  local d = S.p[pid]
  return (d ~= nil) and (d.relic ~= nil) and (d.relic[code] == true)
end

-- CO AI trong doi co mon do khong.
--
-- Dung cho hai mon cong vao NHA CHINH: nha la cua chung, nen mot nguoi
-- mua la ca doi duoc huong. Do cung la ly do hai mon do dat hon hai mon
-- ca nhan.
local function anyHas(code)
  for i = 1, #S.pids do
    if has(S.pids[i], code) then return true end
  end
  return false
end

-- So cua mot mon, hoac 0 neu nguoi do chua mua.
--
-- Cho nao can thi goi cai nay, khong ai dang ky trigger rieng -- xem
-- luat "doc-luc-dung" o dau file. Tra 0 chu khong nil de ben goi khong
-- phai chot nil moi cho.
local function valOf(pid, code, field)
  local d = S.p[pid]
  if d == nil or d.relic == nil or not d.relic[code] then return 0.0 end
  for i = 1, #CFG.RELIC do
    local r = CFG.RELIC[i]
    if r.code == code then return r[field] or 0.0 end
  end
  return 0.0
end

local function defOf(code)
  for i = 1, #CFG.RELIC do
    if CFG.RELIC[i].code == code then return CFG.RELIC[i] end
  end
  return nil
end

-- ---------- Mua ----------
-- Chay tren MOI may, tu kenh dong bo.

local function buy(pid, i)
  local item = CFG.RELIC[i]
  if item == nil then return end

  local d = S.p[pid]
  if d == nil then return end
  if d.relic == nil then d.relic = {} end
  if d.relic[item.code] then return end

  if CFG.RELIC_LOCKED then return end
  if not API.spendLumber(pid, item.price) then
    API.msg(pid, CFG.C_RED .. API.t("no_lumber") .. CFG.C_END ..
      API.t("need_have", API.num(item.price), API.num(API.getLumber(pid))) ..
      CFG.C_GREY .. " " .. API.t("lumber_note") .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  d.relic[item.code] = true
  API.msg(nil, API.t("relic_bought",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. API.pick(item) .. CFG.C_END))

  if d.hero ~= nil then
    API.fx([[Abilities\Spells\Items\AIem\AIemTarget.mdl]],
           GetUnitX(d.hero), GetUnitY(d.hero))
  end
  API.panelRefresh(pid)
end

-- ---------- Hieu ung "mana": don sach mot dot thi ca doi hoi day ----------
--
-- Goi tu onMobDeath luc con cuoi cung chet. Mot nguoi mua thi ca doi
-- duoc -- cung nguyen tac voi hai mon cong vao nha.
local function onClear()
  if not anyHas("mana") then return end
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    if d ~= nil and d.hero ~= nil and API.alive(d.hero) then
      SetUnitState(d.hero, UNIT_STATE_MANA,
                   GetUnitState(d.hero, UNIT_STATE_MAX_MANA))
    end
  end
end

-- ---------- The trong bang phim E ----------

local function descOf(item)
  if API.lang() == "en" then return item.desc_en or item.desc end
  return item.desc or item.desc_en
end

local function tabItems(pid)
  -- KHOA TAM THOI: khong ban gi ca. Tra ve rong de bang hien dong
  -- "chua co gi" + ly do, thay vi hien mon mua khong duoc.
  if CFG.RELIC_LOCKED then return {} end
  local lumber = API.getLumber(pid)
  local out = {}
  for i = 1, #CFG.RELIC do
    local item = CFG.RELIC[i]
    local it  = { icon = item.icon, name = API.pick(item), desc = descOf(item) }

    if has(pid, item.code) then
      it.status = CFG.C_JADE .. API.t("st_owned") .. CFG.C_END
    else
      it.status = CFG.C_GREY .. API.num(item.price) .. CFG.C_END
      -- GO: buy() goi API.spendLumber. Nhan sai tien tren nut la noi doi voi
      -- nguoi choi ve thu ho dang de danh.
      it.btn       = API.t("btn_buy") .. "  " .. API.num(item.price) .. " " .. API.t("cur_lumber")
      it.btnOn    = (lumber >= item.price)
    end
    out[i] = it
  end
  return out
end

local function tabItemAction(pid, i)
  if CFG.RELIC[i] == nil then return end
  API.syncSend(pid, CFG.OP_RELIC_BUY, i)
end

local function startRelic()
  API.panelAddTab({
    name        = API.t("panel_relic"),
    kind       = "list",
    rows      = #CFG.RELIC,
    items      = tabItems,
    itemAction = tabItemAction,
    empty      = CFG.RELIC_LOCKED and API.t("relic_locked") or API.t("relic_empty"),
  })
  API.syncOn(CFG.OP_RELIC_BUY, buy)
  API.trace("relic: " .. #CFG.RELIC .. " mon, the san sang")
end

API.relicVal      = valOf
API.relicHas      = has
API.relicAnyHas    = anyHas
API.relicDef     = defOf
API.relicOnClear = onClear
API.startRelic   = startRelic
