-- ============================================================
--  4_ui/7_quest.lua -- Trang huong dan o menu Nhiem Vu (F9)
--
--  F9 la cho DUY NHAT Warcraft cho minh dat mot trang chu ma khong
--  ton cho tren man hinh. Khong phai vao World Editor: CreateQuest va
--  ho hang cua no deu la native, goi luc vao map la xong.
--
--  Noi dung SUY TU CFG chu khong go tay. Doi CFG.GAME_KEY tu "R" sang
--  chu khac ma trang nay van ghi "R" thi no thanh mot trang noi doi --
--  te hon la khong co trang nao.
-- ============================================================

-- KHONG khai bao lai S/CFG/API o day.
--
-- build.py boc moi file trong mot khoi do...end RIENG, va dat
--     local CFG, S, API
-- o khoi NGOAI. Chung la LOCAL, khong phai bien toan cuc -- nen _G.API
-- la nil. Viet "local API = _G.API" thi che mat cai that bang nil, va
-- dong "API.startQuest = ..." o cuoi file se nem loi NGAY LUC CHUNK
-- NAP. Chunk chet luc nap = map khong khoi tao duoc, va Warcraft bao
-- "There was an error reading the map file" -- khong mot dau vet nao
-- chi vao Lua. Da mat mot buoi de tim ra.
--
-- Cu phap van hop le nen build.py khong bat duoc. Dung bang cach khong
-- khai bao gi ca, y het 27 file kia.

-- Ten phim mo bang nhan vat. CFG.PANEL_KEY = nil nghia la khong gan
-- phim chu nao, chi ESC bat/tat -- xem chu thich o 1_config.lua.
local function panelKeyName()
  return (CFG.PANEL_KEY ~= nil) and (CFG.PANEL_KEY .. " / ESC") or "ESC"
end

-- "1-6" chu khong phai "1, 2, 3, 4, 5, 6": bang nao lien mach thi viet
-- gon, dut doan thi liet ke du. Doc THANG tu CFG.ITEM_KEYS.
local function itemKeyName()
  local k = CFG.ITEM_KEYS
  if k == nil or #k == 0 then return nil end
  if #k == 1 then return k[1] end
  local run = true
  for i = 2, #k do
    if tonumber(k[i]) == nil or tonumber(k[i]) ~= tonumber(k[1]) + i - 1 then
      run = false
      break
    end
  end
  if run then return k[1] .. "-" .. k[#k] end
  return table.concat(k, " ")
end

local function describe()
  local L = {}
  local function add(s) L[#L + 1] = s end

  add(API.t("quest_intro"))
  add("")
  add(CFG.C_GOLD .. panelKeyName() .. CFG.C_END .. "  " ..
      API.t("quest_key_panel"))
  if CFG.GAME_KEY ~= nil then
    add(CFG.C_GOLD .. CFG.GAME_KEY .. CFG.C_END .. "  " ..
        API.t("quest_key_game"))
  end
  local ik = itemKeyName()
  if ik ~= nil then
    add(CFG.C_GOLD .. ik .. CFG.C_END .. "  " .. API.t("quest_key_item"))
  end
  add(CFG.C_GOLD .. "F9" .. CFG.C_END .. "  " .. API.t("quest_key_f9"))

  return table.concat(L, "\n")
end

-- ---------- Tao trang ----------
--
-- Moi native deu chot nil rieng. Thieu CreateQuest thi khong co gi de
-- lam, nhung thieu QuestSetIconPath thi van nen ra trang -- mat cai
-- icon con hon mat ca trang chu.
local function startQuest()
  if CreateQuest == nil then
    API.trace("quest: KHONG co CreateQuest -- bo qua trang F9")
    return
  end

  local q = CreateQuest()
  if q == nil then
    API.trace("quest: CreateQuest tra ve nil")
    return
  end

  local miss = {}
  local function call(name, ...)
    local fn = _G[name]
    if fn == nil then
      miss[#miss + 1] = name
      return
    end
    fn(...)
  end

  call("QuestSetTitle", q, API.t("quest_title"))
  call("QuestSetDescription", q, describe())
  -- required = true de no nam o muc tren cung. Day khong phai nhiem vu
  -- that, nhung no la thu dau tien nguoi choi can doc.
  call("QuestSetRequired", q, true)
  call("QuestSetDiscovered", q, true)
  call("QuestSetCompleted", q, false)
  -- KHONG dat icon. QuestSetIconPath doi mot duong dan texture, ma moi
  -- lan DOAN duong dan trong du an nay deu doan sai (xem BTNRingViolet).
  -- Trang khong icon van doc duoc; icon sai thi ra o xanh la.

  -- Nhap nut F9 mot cai luc vao map: khong nhap thi khong ai bam F9,
  -- va mot trang chu khong ai mo thi bang khong viet.
  call("FlashQuestDialogButton")

  S.quest = q
  if #miss > 0 then
    API.trace("quest: THIEU native " .. table.concat(miss, " "))
  else
    API.trace("quest: trang F9 da tao")
  end
end

API.startQuest = startQuest
