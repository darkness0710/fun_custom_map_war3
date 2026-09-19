-- ============================================================
--  8_shop.lua  --  The V: Shop
--
--  He DUY NHAT tieu VANG, va he duy nhat ban do TIEU HAO. Ba the kia
--  ban thu vinh vien; the nay ban mot lan dung.
--
--  Mua la HANH DONG -> phai qua kenh dong bo, khong duoc lam cuc bo.
--  Chi viec mo bang va doi the moi la UI thuan.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

-- Cung khuon voi 6_relic.lua: API.pick lo phan TEN, mo ta thi tung he
-- tu lay vi ten truong khac nhau.
local function descOf(item)
  if API.lang() == "en" then return item.desc_en or item.desc end
  return item.desc or item.desc_en
end

-- Con o trong tui khong? Warcraft cho 6 o; mua khi day tui thi item roi
-- xuong dat ngay duoi chan hero, va nguoi choi mat vang vi mot cai o ma
-- khong hieu tai sao.
-- Tim o dang giu item CUNG LOAI va con cho gop. Tra ve chinh item do.
local function stackSlot(u, itemId)
  if u == nil or UnitInventorySize == nil or UnitItemInSlot == nil then return nil end
  if GetItemTypeId == nil or GetItemCharges == nil then return nil end
  local stackMax = CFG.SHOP_STACK_MAX or 1
  if stackMax <= 1 then return nil end
  local n = UnitInventorySize(u)
  for i = 0, (n or 0) - 1 do
    local it = UnitItemInSlot(u, i)
    if it ~= nil and GetItemTypeId(it) == itemId then
      local c = GetItemCharges(it)
      -- 0 luot = item khong dung he luot. Gop vao la dem duoc nhung con
      -- so hien ra co the khong dung voi so lan dung duoc -- nen bo qua,
      -- de no chiem o rieng cho that.
      if c ~= nil and c >= 1 and c < stackMax then return it end
    end
  end
  return nil
end

-- Con cho de NHAN them mot lo khong: hoac con o trong, hoac co mot o
-- cung loai chua day luot.
-- Mon cong thang vao bo dem (da Huyen Thiet) thay vi bo item vao tui.
local function isIronItem(item)
  return (item ~= nil) and (item.iron ~= nil) and (item.iron > 0)
end

local function hasRoom(u, itemId)
  -- maItem = nil nghia la mon nay khong dung tui do -- luon con cho.
  if itemId == nil then return true end
  if not CFG.SHOP_CHECK_BAG then return true end
  if u == nil then return false end
  if stackSlot(u, itemId) ~= nil then return true end
  if UnitInventorySize == nil or UnitItemInSlot == nil then return true end

  -- KHONG CO TUI = KHONG CO CHO, chu khong phai "khong biet nen cho qua".
  --
  -- Ban truoc tra ve true o day, va do la mot loi im lang dat dung cho
  -- te nhat: UnitAddItemById tren mot unit khong co tui van tra ve
  -- HANDLE ITEM -- no tao item roi tha xuong DAT duoi chan. Nen
  -- give() dem "phat 10/10 thanh cong" trong khi ca 20 lo nam duoi
  -- san, va UnitItemInSlot() thi bao o trong.
  --
  -- Unit muon cam do phai co ability "Inventory (Hero)" (AInv) trong
  -- Object Editor. Xem CFG.HERO_COMMON_ABILITIES.
  local n = UnitInventorySize(u)
  if n == nil or n <= 0 then return false end

  for i = 0, n - 1 do
    if UnitItemInSlot(u, i) == nil then return true end
  end
  return false
end

-- Chay tren MOI may, tu kenh dong bo.
-- Mua THANH CONG thi bao CA DOI ("[Ten] da mua ..."), that bai thi bao
-- RIENG. Loi la chuyen cua tui tien mot nguoi; con mon vua mua la thu
-- ca doi nen thay, vi no noi len doi phuong dang manh len theo huong
-- nao. Ham nay chay trong syncOn nen API.say hien o moi may.
local function buy(pid, i)
  local item = CFG.SHOP[i]
  if item == nil then return end
  -- Mon phat cung khong mua duoc, ke ca khi op toi bang duong khac.
  -- Ben NHAN kiem lai, khong tin cu bam: ben gui la cuc bo.
  if item.forSale == false then return end

  local d = S.p[pid]
  if d == nil then return end

  -- Phan hoi nam tren DONG VUA BAM. Mot dong chat thi troi di, ma nguoi
  -- choi luc do dang nhin vao bang chu khong nhin o chat.
  local function flash(kind)
    if API.panelFlash ~= nil then API.panelFlash(pid, i, kind) end
  end

  -- Da: khong dung tui do, nen khong can hero va khong can kiem o.
  if isIronItem(item) then
    if not API.spendGold(pid, item.price) then
      API.msg(pid, CFG.C_RED .. API.t("no_gold") .. CFG.C_END ..
        API.t("need_have", API.num(item.price), API.num(API.getGold(pid))))
      flash("fail")
      API.panelRefresh(pid)
      return
    end
    d.iron = (d.iron or 0) + item.iron
    API.say(pid, API.t("shop_bought",
      CFG.C_JADE .. API.pick(item) .. CFG.C_END, API.num(item.price)))
    flash("ok")
    API.panelRefresh(pid)
    return
  end

  if d.hero == nil then return end

  if not hasRoom(d.hero, item.item) then
    API.msg(pid, CFG.C_RED .. API.t("shop_full") .. CFG.C_END)
    flash("fail")
    return
  end

  if not API.spendGold(pid, item.price) then
    API.msg(pid, CFG.C_RED .. API.t("no_gold") .. CFG.C_END ..
      API.t("need_have", API.num(item.price), API.num(API.getGold(pid))))
    flash("fail")
    API.panelRefresh(pid)
    return
  end

  -- Da co mot o cung loai chua day: cong them mot luot, khong chiem o
  -- moi. Lam truoc khi tao item moi, neu khong thi lan nao cung ra o moi
  -- va gop thanh vo nghia.
  local old = stackSlot(d.hero, item.item)
  if old ~= nil then
    local c = GetItemCharges(old) + 1
    SetItemCharges(old, c)
    API.say(pid, API.t("shop_stack",
      CFG.C_JADE .. API.pick(item) .. CFG.C_END, c, API.num(item.price)))
    flash("ok")
    API.panelRefresh(pid)
    return
  end

  -- UnitAddItemById tra ve nil khi ma item khong ton tai. Hoan tien va
  -- BAO RO -- mot ma sai ma nuot im la nguoi choi mat vang khong hieu vi
  -- sao, va ta khong biet minh go sai ma nao (ADR 0012).
  local it = UnitAddItemById(d.hero, item.item)
  if it == nil then
    API.addGold(pid, item.price)
    API.warn(pid, "Khong tao duoc item " ..
      API.idToStr(item.item) .. " -- da hoan " .. API.num(item.price) ..
      " vang. Kiem CFG.SHOP.")
    flash("fail")
    API.panelRefresh(pid)
    return
  end

  API.say(pid, API.t("shop_bought",
    CFG.C_JADE .. API.pick(item) .. CFG.C_END, API.num(item.price)))
  flash("ok")
  API.panelRefresh(pid)
end

-- Phat item khong tinh tien. Dung cho qua khoi dau (CFG.START_ITEMS).
--
-- Di qua CUNG duong voi buy(): gop vao o cu neu co, khong thi tao o
-- moi. Nho vay qua khoi dau va do mua deu nam chung mot o, va luat gop
-- chi viet mot lan.
local function give(pid, code, count)
  local d = S.p[pid]
  if d == nil or d.hero == nil or count == nil or count <= 0 then return 0 end

  local item
  for i = 1, #CFG.SHOP do
    if CFG.SHOP[i].code == code then item = CFG.SHOP[i] end
  end
  if item == nil then
    API.warn(pid, "shopGive: khong co mon '" .. tostring(code) ..
      "' trong CFG.SHOP.")
    return 0
  end

  -- Bao RO khi unit khong co tui, thay vi tha do xuong dat roi bao
  -- thanh cong.
  if UnitInventorySize ~= nil then
    local n = UnitInventorySize(d.hero)
    if n == nil or n <= 0 then
      API.warn(nil, "Hero khong co tui do (thieu ability " ..
        "Inventory/AInv) -- khong phat duoc " .. tostring(code))
      API.trace("shop: hero KHONG CO TUI, bo qua " .. tostring(code))
      return 0
    end
  end

  local done = 0
  for _ = 1, count do
    local old = stackSlot(d.hero, item.item)
    if old ~= nil then
      SetItemCharges(old, GetItemCharges(old) + 1)
      done = done + 1
    elseif hasRoom(d.hero, item.item) then
      local it = UnitAddItemById(d.hero, item.item)
      if it == nil then break end
      done = done + 1
    else
      break   -- het cho, dung han chu khong lam roi item xuong dat
    end
  end

  API.trace("shop: phat " .. done .. "/" .. count .. " " .. code .. " cho pid " .. pid)
  return done
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local gold = API.getGold(pid)
  local hero = (S.p[pid] or {}).hero
  local out  = {}
  for i = 1, #CFG.SHOP do
    local item = CFG.SHOP[i]
    -- Mon phat cung (thap thu) khong bay ban.
    --
    -- BO TRONG o do chu KHONG don danh sach lai: buy(pid, i) tra
    -- CFG.SHOP[i] bang chinh chi so nay. Don lai thi chi so lech mot va
    -- moi cu bam mua nham mon ben canh -- kieu sai im lang, nguoi choi
    -- chi biet khi thay minh mua phai thu khac.
    --
    -- Than kieu "list" tu an dong nao out[i] == nil (xem refreshList).
    if item.forSale ~= false then
      local room = hasRoom(hero, item.item)
      -- Icon da: lay cai 10_fortune.lua DO DUOC luc vao map, khong go
      -- tay. Doc o day chu khong o startShop vi shop khoi dong TRUOC quay.
      local ic = item.icon
      if isIronItem(item) and API.fortuneIcon ~= nil then
        ic = API.fortuneIcon("iron") or ic
      end
      out[i] = {
        icon      = ic,
        name       = API.pick(item),
        desc      = descOf(item),
        -- Trang thai la CHO TRONG TUI, khong phai gia: gia da nam tren
        -- nut roi, in hai lan la thua.
        status = room and "" or (CFG.C_RED .. API.t("shop_full") .. CFG.C_END),
        btn       = API.t("btn_buy") .. "  " .. API.num(item.price) .. " " ..
                    API.t("cur_gold"),
        btnOn    = (gold >= item.price) and room,
      }
    end
  end
  return out
end

local function tabItemAction(pid, i)
  if CFG.SHOP[i] == nil then return end
  API.syncSend(pid, CFG.OP_SHOP, i)
end

-- Do ma item va icon NGAY LUC VAO MAP, khong doi toi luc ai do bam mua.
--
-- Hai thu trong CFG.SHOP deu la phong doan: ma item ('phea', 'pman') va
-- duong dan icon. Doan sai ma thi nguoi choi bam mua moi biet; doan sai
-- icon thi o icon ra XANH LA -- dung loi ma BTNRingViolet da dinh.
--
-- CreateItem tra ve nil khi ma khong ton tai, nen tao thu mot cai roi
-- xoa ngay la do duoc ca hai: ma co that khong, va icon THAT cua no la
-- gi. Icon doc duoc thi ghi de len duong dan trong CFG -- lay so do
-- duoc thay cho so go tay.
local function probeItems()
  if CreateItem == nil then return end
  local bad = {}
  for i = 1, #CFG.SHOP do
    local item = CFG.SHOP[i]
    local it = (item.item ~= nil) and CreateItem(item.item, 0.0, 0.0) or nil
    if item.item == nil then
      -- Mon khong dung tui do (da Huyen Thiet): khong co gi de do.
    elseif it == nil then
      bad[#bad + 1] = API.idToStr(item.item)
    else
      if BlzGetItemIconPath ~= nil then
        local p = BlzGetItemIconPath(it)
        if p ~= nil and p ~= "" then item.icon = p end
      end
      -- So luot GOC. Bang 0 nghia la item nay khong dung he luot, va
      -- luc do gop lo khong chay -- phai biet truoc chu khong doi toi
      -- luc nguoi choi mua cai thu hai moi phat hien.
      local c = (GetItemCharges ~= nil) and GetItemCharges(it) or -1
      API.trace("shop: " .. item.code .. " = " .. API.idToStr(item.item) ..
                ", luot goc " .. c .. ", icon " .. tostring(item.icon))
      if c == 0 then
        API.info(nil, CFG.C_GREY .. "[shop] " .. API.pick(item) ..
          " co 0 luot -- khong gop o duoc, moi lo se chiem mot o." .. CFG.C_END)
      end
      RemoveItem(it)
    end
  end
  if #bad > 0 then
    API.warn(nil, "Shop: khong co item " ..
      table.concat(bad, " ") .. " -- sua CFG.SHOP.")
  end
end

local function startShop()
  probeItems()
  API.panelAddTab({
    name        = API.t("panel_shop"),
    kind       = "list",
    rows      = #CFG.SHOP,
    items      = tabItems,
    itemAction = tabItemAction,
    empty      = API.t("shop_empty"),
  })
  API.syncOn(CFG.OP_SHOP, buy)
  API.trace("shop: " .. #CFG.SHOP .. " mon, the san sang")
end

API.shopBuy   = buy
API.shopGive  = give
API.startShop = startShop
