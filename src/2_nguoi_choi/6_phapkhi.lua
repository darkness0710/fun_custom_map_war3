-- ============================================================
--  6_phapkhi.lua  --  Mua MOT lan, khong co cap
--
--  BANG DANG RONG (CFG.PHAPKHI = {}) -- 2026-09-16. Nam mon cu da xoa:
--  chung mua bang Tinh Thach, con he nay gio tra bang NGO TINH.
--
--  NGAN SACH DANH SAN: ca van kiem 300 Ngo Tinh, ky nang tieu 70, nen
--  con 230 diem cho day. Do la rang buoc khi thiet ke lai.
--
--  Code chay duoc voi bang rong: the hien mot dong "chua co gi", khong
--  mua duoc gi, va moi hieu ung tra ve false -- nen 2_wave.lua goi
--  API.phapKhiCo / phapKhiAiCo / phapKhiOnClear van an toan.
--
--  KHI THEM MON MOI. Moi mon phai DOC-LUC-DUNG: khong dang ky trigger
--  rieng, ma cho can biet thi hoi API.phapKhiCo. Mot mon can bo bat su
--  kien rieng la mot mon co the hong am tham, ma ca van chi mua duoc
--  vai lan. Them mon la them dong vao CFG.PHAPKHI VA viet cho doc 'ma'
--  cua no -- khong co bang dieu phoi tu dong nao ca.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Nguoi nay co mon do khong.
local function co(pid, ma)
  local d = S.p[pid]
  return (d ~= nil) and (d.pk ~= nil) and (d.pk[ma] == true)
end

-- CO AI trong doi co mon do khong.
--
-- Dung cho hai mon cong vao NHA CHINH: nha la cua chung, nen mot nguoi
-- mua la ca doi duoc huong. Do cung la ly do hai mon do dat hon hai mon
-- ca nhan.
local function aiCo(ma)
  for i = 1, #S.pids do
    if co(S.pids[i], ma) then return true end
  end
  return false
end

local function defOf(ma)
  for i = 1, #CFG.PHAPKHI do
    if CFG.PHAPKHI[i].ma == ma then return CFG.PHAPKHI[i] end
  end
  return nil
end

-- ---------- Mua ----------
-- Chay tren MOI may, tu kenh dong bo.

local function buy(pid, i)
  local mon = CFG.PHAPKHI[i]
  if mon == nil then return end

  local d = S.p[pid]
  if d == nil then return end
  if d.pk == nil then d.pk = {} end
  if d.pk[mon.ma] then return end

  if CFG.PHAPKHI_LOCKED then return end
  if not API.spendGo(pid, mon.gia) then
    API.msg(pid, CFG.C_RED .. API.t("no_go") .. CFG.C_END ..
      API.t("need_have", API.num(mon.gia), API.num(API.getGo(pid))) ..
      CFG.C_GREY .. " " .. API.t("ngo_note") .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  d.pk[mon.ma] = true
  API.msg(nil, API.t("pk_bought",
    CFG.C_GOLD .. GetPlayerName(Player(pid)) .. CFG.C_END,
    CFG.C_JADE .. API.pick(mon) .. CFG.C_END))

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
  if not aiCo("mana") then return end
  for i = 1, #S.pids do
    local d = S.p[S.pids[i]]
    if d ~= nil and d.hero ~= nil and API.alive(d.hero) then
      SetUnitState(d.hero, UNIT_STATE_MANA,
                   GetUnitState(d.hero, UNIT_STATE_MAX_MANA))
    end
  end
end

-- ---------- The trong bang phim E ----------

local function motaOf(mon)
  if API.lang() == "en" then return mon.mota_en or mon.mota end
  return mon.mota or mon.mota_en
end

local function tabItems(pid)
  -- KHOA TAM THOI: khong ban gi ca. Tra ve rong de bang hien dong
  -- "chua co gi" + ly do, thay vi hien mon mua khong duoc.
  if CFG.PHAPKHI_LOCKED then return {} end
  local ngo = API.getGo(pid)
  local out = {}
  for i = 1, #CFG.PHAPKHI do
    local mon = CFG.PHAPKHI[i]
    local it  = { icon = mon.icon, ten = API.pick(mon), mota = motaOf(mon) }

    if co(pid, mon.ma) then
      it.trangThai = CFG.C_JADE .. API.t("st_owned") .. CFG.C_END
    else
      it.trangThai = CFG.C_GREY .. API.num(mon.gia) .. CFG.C_END
      -- GO: buy() goi API.spendGo. Nhan sai tien tren nut la noi doi voi
      -- nguoi choi ve thu ho dang de danh.
      it.nut       = API.t("btn_buy") .. "  " .. API.num(mon.gia) .. " " .. API.t("cur_go")
      it.batNut    = (ngo >= mon.gia)
    end
    out[i] = it
  end
  return out
end

local function tabItemAction(pid, i)
  if CFG.PHAPKHI[i] == nil then return end
  API.syncSend(pid, CFG.OP_PK_BUY, i)
end

local function startPhapKhi()
  API.panelAddTab({
    ten        = API.t("panel_treasure"),
    kind       = "list",
    soMuc      = #CFG.PHAPKHI,
    items      = tabItems,
    itemAction = tabItemAction,
    trong      = CFG.PHAPKHI_LOCKED and API.t("pk_locked") or API.t("pk_empty"),
  })
  API.syncOn(CFG.OP_PK_BUY, buy)
  API.trace("phapkhi: " .. #CFG.PHAPKHI .. " mon, the san sang")
end

API.phapKhiCo      = co
API.phapKhiAiCo    = aiCo
API.phapKhiDef     = defOf
API.phapKhiOnClear = onClear
API.startPhapKhi   = startPhapKhi
