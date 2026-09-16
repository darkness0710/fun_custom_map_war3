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

-- Cung khuon voi 6_phapkhi.lua: API.pick lo phan TEN, mo ta thi tung he
-- tu lay vi ten truong khac nhau.
local function motaOf(mon)
  if API.lang() == "en" then return mon.mota_en or mon.mota end
  return mon.mota or mon.mota_en
end

-- Con o trong tui khong? Warcraft cho 6 o; mua khi day tui thi item roi
-- xuong dat ngay duoi chan hero, va nguoi choi mat vang vi mot cai o ma
-- khong hieu tai sao.
-- Tim o dang giu item CUNG LOAI va con cho gop. Tra ve chinh item do.
local function oGop(u, maItem)
  if u == nil or UnitInventorySize == nil or UnitItemInSlot == nil then return nil end
  if GetItemTypeId == nil or GetItemCharges == nil then return nil end
  local tran = CFG.SHOP_STACK_MAX or 1
  if tran <= 1 then return nil end
  local n = UnitInventorySize(u)
  for i = 0, (n or 0) - 1 do
    local it = UnitItemInSlot(u, i)
    if it ~= nil and GetItemTypeId(it) == maItem then
      local c = GetItemCharges(it)
      -- 0 luot = item khong dung he luot. Gop vao la dem duoc nhung con
      -- so hien ra co the khong dung voi so lan dung duoc -- nen bo qua,
      -- de no chiem o rieng cho that.
      if c ~= nil and c >= 1 and c < tran then return it end
    end
  end
  return nil
end

-- Con cho de NHAN them mot lo khong: hoac con o trong, hoac co mot o
-- cung loai chua day luot.
local function conCho(u, maItem)
  if not CFG.SHOP_CHECK_BAG then return true end
  if u == nil then return false end
  if oGop(u, maItem) ~= nil then return true end
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
local function buy(pid, i)
  local mon = CFG.SHOP[i]
  if mon == nil then return end

  local d = S.p[pid]
  if d == nil or d.hero == nil then return end

  if not conCho(d.hero, mon.item) then
    API.msg(pid, CFG.C_RED .. API.t("shop_full") .. CFG.C_END)
    return
  end

  if not API.spendVang(pid, mon.gia) then
    API.msg(pid, CFG.C_RED .. API.t("no_vang") .. CFG.C_END ..
      API.t("need_have", API.num(mon.gia), API.num(API.getVang(pid))))
    API.panelRefresh(pid)
    return
  end

  -- Da co mot o cung loai chua day: cong them mot luot, khong chiem o
  -- moi. Lam truoc khi tao item moi, neu khong thi lan nao cung ra o moi
  -- va gop thanh vo nghia.
  local cu = oGop(d.hero, mon.item)
  if cu ~= nil then
    local c = GetItemCharges(cu) + 1
    SetItemCharges(cu, c)
    API.msg(pid, API.t("shop_stack",
      CFG.C_JADE .. API.pick(mon) .. CFG.C_END, c, API.num(mon.gia)))
    API.panelRefresh(pid)
    return
  end

  -- UnitAddItemById tra ve nil khi ma item khong ton tai. Hoan tien va
  -- BAO RO -- mot ma sai ma nuot im la nguoi choi mat vang khong hieu vi
  -- sao, va ta khong biet minh go sai ma nao (ADR 0012).
  local it = UnitAddItemById(d.hero, mon.item)
  if it == nil then
    API.addVang(pid, mon.gia)
    API.msg(pid, CFG.C_RED .. "Khong tao duoc item " ..
      API.idToStr(mon.item) .. " -- da hoan " .. API.num(mon.gia) ..
      " vang. Kiem CFG.SHOP." .. CFG.C_END)
    API.panelRefresh(pid)
    return
  end

  API.msg(pid, API.t("shop_bought",
    CFG.C_JADE .. API.pick(mon) .. CFG.C_END, API.num(mon.gia)))
  API.panelRefresh(pid)
end

-- Phat item khong tinh tien. Dung cho qua khoi dau (CFG.START_ITEMS).
--
-- Di qua CUNG duong voi buy(): gop vao o cu neu co, khong thi tao o
-- moi. Nho vay qua khoi dau va do mua deu nam chung mot o, va luat gop
-- chi viet mot lan.
local function give(pid, ma, so)
  local d = S.p[pid]
  if d == nil or d.hero == nil or so == nil or so <= 0 then return 0 end

  local mon
  for i = 1, #CFG.SHOP do
    if CFG.SHOP[i].ma == ma then mon = CFG.SHOP[i] end
  end
  if mon == nil then
    API.msg(pid, CFG.C_RED .. "shopGive: khong co mon '" .. tostring(ma) ..
      "' trong CFG.SHOP." .. CFG.C_END)
    return 0
  end

  -- Bao RO khi unit khong co tui, thay vi tha do xuong dat roi bao
  -- thanh cong.
  if UnitInventorySize ~= nil then
    local n = UnitInventorySize(d.hero)
    if n == nil or n <= 0 then
      API.msg(nil, CFG.C_RED .. "Hero khong co tui do (thieu ability " ..
        "Inventory/AInv) -- khong phat duoc " .. tostring(ma) .. CFG.C_END)
      API.trace("shop: hero KHONG CO TUI, bo qua " .. tostring(ma))
      return 0
    end
  end

  local xong = 0
  for _ = 1, so do
    local cu = oGop(d.hero, mon.item)
    if cu ~= nil then
      SetItemCharges(cu, GetItemCharges(cu) + 1)
      xong = xong + 1
    elseif conCho(d.hero, mon.item) then
      local it = UnitAddItemById(d.hero, mon.item)
      if it == nil then break end
      xong = xong + 1
    else
      break   -- het cho, dung han chu khong lam roi item xuong dat
    end
  end

  API.trace("shop: phat " .. xong .. "/" .. so .. " " .. ma .. " cho pid " .. pid)
  return xong
end

-- ---------- The trong bang ----------

local function tabItems(pid)
  local vang = API.getVang(pid)
  local hero = (S.p[pid] or {}).hero
  local out  = {}
  for i = 1, #CFG.SHOP do
    local mon = CFG.SHOP[i]
    local con = conCho(hero, mon.item)
    out[i] = {
      icon      = mon.icon,
      ten       = API.pick(mon),
      mota      = motaOf(mon),
      -- Trang thai la CHO TRONG TUI, khong phai gia: gia da nam tren
      -- nut roi, in hai lan la thua.
      trangThai = con and "" or (CFG.C_RED .. API.t("shop_full") .. CFG.C_END),
      nut       = API.t("btn_buy") .. "  " .. API.num(mon.gia) .. " " ..
                  API.t("cur_vang"),
      batNut    = (vang >= mon.gia) and con,
    }
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
    local mon = CFG.SHOP[i]
    local it = CreateItem(mon.item, 0.0, 0.0)
    if it == nil then
      bad[#bad + 1] = API.idToStr(mon.item)
    else
      if BlzGetItemIconPath ~= nil then
        local p = BlzGetItemIconPath(it)
        if p ~= nil and p ~= "" then mon.icon = p end
      end
      -- So luot GOC. Bang 0 nghia la item nay khong dung he luot, va
      -- luc do gop lo khong chay -- phai biet truoc chu khong doi toi
      -- luc nguoi choi mua cai thu hai moi phat hien.
      local c = (GetItemCharges ~= nil) and GetItemCharges(it) or -1
      API.trace("shop: " .. mon.ma .. " = " .. API.idToStr(mon.item) ..
                ", luot goc " .. c .. ", icon " .. tostring(mon.icon))
      if c == 0 then
        API.msg(nil, CFG.C_GREY .. "[shop] " .. API.pick(mon) ..
          " co 0 luot -- khong gop o duoc, moi lo se chiem mot o." .. CFG.C_END)
      end
      RemoveItem(it)
    end
  end
  if #bad > 0 then
    API.msg(nil, CFG.C_RED .. "Shop: khong co item " ..
      table.concat(bad, " ") .. " -- sua CFG.SHOP." .. CFG.C_END)
  end
end

local function startShop()
  probeItems()
  API.panelAddTab({
    ten        = API.t("panel_shop"),
    kind       = "list",
    soMuc      = #CFG.SHOP,
    items      = tabItems,
    itemAction = tabItemAction,
    trong      = API.t("shop_empty"),
  })
  API.syncOn(CFG.OP_SHOP, buy)
  API.trace("shop: " .. #CFG.SHOP .. " mon, the san sang")
end

API.shopBuy   = buy
API.shopGive  = give
API.startShop = startShop
