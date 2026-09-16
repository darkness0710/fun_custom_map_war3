-- ============================================================
--  9_dungdo.lua  --  Dung do trong tui bang HANG SO TREN (canh Esc)
--
--  Warcraft chi gan san san tui do vao numpad (7/8/4/5/1/2). May
--  khong co numpad, va tay phai roi chuot de voi sang numpad, nen
--  gan them hang so 1..6 o tren.
--
--  Day la THEM, khong phai thay: numpad van chay nhu cu.
--
--  VI SAO PHAI QUA KENH DONG BO.
--
--  Su kien phim la DAU VAO CUC BO -- no chi no tren may cua nguoi bam.
--  Bang phim R goi UnitUseItem thang o day thi may do dung mot lo thuoc
--  ma hai may kia khong biet -> lech ban game. Bang chi bat/tat khung
--  hinh nen lam cuc bo duoc; dung do thi doi TRANG THAI, nen phai di
--  qua API.syncSend nhu moi hanh dong khac (ADR 0012).
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Chay tren MOI may, tu kenh dong bo. o = 0..5.
local function dung(pid, o)
  local d = S.p[pid]
  if d == nil or d.hero == nil then return end
  if UnitItemInSlot == nil or UnitUseItem == nil then return end

  local it = UnitItemInSlot(d.hero, o)
  if it == nil then return end
  UnitUseItem(d.hero, it)
end

local function startDungDo()
  if CFG.ITEM_KEYS == nil or #CFG.ITEM_KEYS == 0 then return end
  if BlzTriggerRegisterPlayerKeyEvent == nil then
    API.trace("dungdo: KHONG co BlzTriggerRegisterPlayerKeyEvent")
    return
  end

  API.syncOn(CFG.OP_ITEM, dung)

  local thieu, xong = {}, 0
  for k = 1, #CFG.ITEM_KEYS do
    local ten = CFG.ITEM_KEYS[k]
    local key = _G["OSKEY_" .. ten]
    if key == nil then
      -- Go sai ten hang la tra ve nil roi im lang khong lam gi ca --
      -- ghi ra chu khong nuot (ADR 0012). "-nat oskey" liet ke ten that.
      thieu[#thieu + 1] = "OSKEY_" .. ten
    else
      local t = CreateTrigger()
      for i = 1, #S.pids do
        BlzTriggerRegisterPlayerKeyEvent(t, Player(S.pids[i]), key, 0, true)
      end
      -- Bien k cua vong for so hoc la RIENG cho tung vong trong Lua,
      -- nen moi closure bat dung o cua no.
      TriggerAddAction(t, function()
        API.syncSend(GetPlayerId(GetTriggerPlayer()), CFG.OP_ITEM, k - 1)
      end)
      xong = xong + 1
    end
  end

  if #thieu > 0 then
    API.trace("dungdo: THIEU hang so " .. table.concat(thieu, " ") ..
              " -- go '-nat oskey' de tim ten dung")
  end
  API.trace("dungdo: gan " .. xong .. "/" .. #CFG.ITEM_KEYS .. " phim")
end

API.dungDo      = dung
API.startDungDo = startDungDo
