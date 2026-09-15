-- ============================================================
--  4_geometry.lua  --  Luoi 25 o va cac dong song ngan cach
--
--  Mot truc (vd truc X, 5 cot) duoc chia nhu sau:
--
--    |<-le->|block|song|block|song|block|song|block|song|block|<-le->|
--
--  Kich thuoc block suy ra tu vung choi duoc that su cua map luc chay,
--  khong hard-code. Phan du sau khi chia deu duoc day ra hai bien lam
--  le, nen luoi luon nam chinh giua vung choi duoc.
--
--  Module nay chi tinh TOA DO. No khong ve dia hinh -- Lua cua WC3
--  khong tao duoc nuoc luc chay. Xem docs/04-map/luoi-25-o.md.
-- ============================================================

-- ---------- Toa do co ban ----------

local function polarX(x, dist, angDeg) return x + dist * Cos(angDeg * bj_DEGTORAD) end
local function polarY(y, dist, angDeg) return y + dist * Sin(angDeg * bj_DEGTORAD) end

local function angleXY(x1, y1, x2, y2)
  return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end

local function distXY(x1, y1, x2, y2)
  local dx, dy = x2 - x1, y2 - y1
  return SquareRoot(dx * dx + dy * dy)
end

local function playableRect()
  local r = bj_mapInitialPlayableArea
  return GetRectMinX(r), GetRectMinY(r), GetRectMaxX(r), GetRectMaxY(r)
end

-- Chia totalTiles thanh n block ngan cach boi (n-1) con song.
-- Tra ve: so o moi block, so o le moi ben.
local function splitAxis(totalTiles, n, riverTiles)
  local block = CFG.BLOCK_TILES_OVERRIDE
  if block <= 0 then
    block = math.floor((totalTiles - (n - 1) * riverTiles) / n)
  end
  if block < 1 then block = 1 end
  local used = n * block + (n - 1) * riverTiles
  -- Lam tron xuong: goc luoi phai roi dung ranh gioi o dia hinh, neu
  -- khong thi khong con dem o trong World Editor duoc. Nua o du neu co
  -- bi day sang bien phai/tren.
  local margin = math.floor((totalTiles - used) / 2)
  return block, margin
end

local function buildGrid()
  local minX, minY, maxX, maxY = playableRect()
  local T     = CFG.TILE
  local cols  = CFG.GRID_COLS
  local rows  = CFG.GRID_ROWS
  local river = CFG.RIVER_TILES

  local tilesW = API.round((maxX - minX) / T)
  local tilesH = API.round((maxY - minY) / T)

  local bw, marginX = splitAxis(tilesW, cols, river)
  local bh, marginY = splitAxis(tilesH, rows, river)

  S.grid = {
    cols = cols, rows = rows,

    -- don vi the gioi
    blockW  = bw * T,
    blockH  = bh * T,
    river   = river * T,
    originX = minX + marginX * T,
    originY = minY + marginY * T,

    -- don vi o dia hinh, de doi chieu voi World Editor
    tilesW = tilesW, tilesH = tilesH,
    blockTilesW = bw, blockTilesH = bh,
    riverTiles = river,
    marginTilesX = marginX, marginTilesY = marginY,

    playMinX = minX, playMinY = minY, playMaxX = maxX, playMaxY = maxY,
  }

  -- pitch = tu mep trai block nay toi mep trai block ke tiep
  S.grid.pitchX = S.grid.blockW + S.grid.river
  S.grid.pitchY = S.grid.blockH + S.grid.river
  S.grid.spanX  = cols * S.grid.blockW + (cols - 1) * S.grid.river
  S.grid.spanY  = rows * S.grid.blockH + (rows - 1) * S.grid.river

  return S.grid
end

-- Keo mot diem ve trong vung choi duoc cua map.
local function clampToMap(x, y)
  local r = bj_mapInitialPlayableArea
  if r == nil then return x, y end
  local pad = 256.0
  return API.clamp(x, GetRectMinX(r) + pad, GetRectMaxX(r) - pad),
         API.clamp(y, GetRectMinY(r) + pad, GetRectMaxY(r) - pad)
end

-- Block dem tu 1, goc duoi-trai la (1,1) -- cung chieu voi toa do WC3.
local function blockIndex(col, row)
  return (row - 1) * S.grid.cols + col
end

local function blockBounds(col, row)
  local g = S.grid
  local x0 = g.originX + (col - 1) * g.pitchX
  local y0 = g.originY + (row - 1) * g.pitchY
  return x0, y0, x0 + g.blockW, y0 + g.blockH
end

local function blockCenter(col, row)
  local x0, y0, x1, y1 = blockBounds(col, row)
  return (x0 + x1) * 0.5, (y0 + y1) * 0.5
end

-- Tra ve col, row neu diem nam trong mot block.
-- Tra ve nil neu diem nam duoi song hoac ngoai luoi.
local function blockAt(x, y)
  local g = S.grid
  local dx, dy = x - g.originX, y - g.originY
  if dx < 0 or dy < 0 or dx >= g.spanX or dy >= g.spanY then return nil end

  local col = math.floor(dx / g.pitchX) + 1
  local row = math.floor(dy / g.pitchY) + 1
  if col > g.cols then col = g.cols end
  if row > g.rows then row = g.rows end

  -- Phan du sau mep phai block chinh la long song.
  if dx - (col - 1) * g.pitchX > g.blockW then return nil end
  if dy - (row - 1) * g.pitchY > g.blockH then return nil end
  return col, row
end

local function inRiver(x, y)
  local g = S.grid
  local dx, dy = x - g.originX, y - g.originY
  if dx < 0 or dy < 0 or dx >= g.spanX or dy >= g.spanY then return false end
  return blockAt(x, y) == nil
end

-- Cac long song doc: { {x0, x1}, ... }, tu trai sang phai.
local function riverColumns()
  local g, out = S.grid, {}
  for i = 1, g.cols - 1 do
    local x0 = g.originX + (i - 1) * g.pitchX + g.blockW
    out[#out + 1] = { x0 = x0, x1 = x0 + g.river }
  end
  return out
end

-- Cac long song ngang: { {y0, y1}, ... }, tu duoi len tren.
local function riverRows()
  local g, out = S.grid, {}
  for i = 1, g.rows - 1 do
    local y0 = g.originY + (i - 1) * g.pitchY + g.blockH
    out[#out + 1] = { y0 = y0, y1 = y0 + g.river }
  end
  return out
end

local function forEachBlock(f)
  for row = 1, S.grid.rows do
    for col = 1, S.grid.cols do
      local x0, y0, x1, y1 = blockBounds(col, row)
      f(col, row, blockIndex(col, row), x0, y0, x1, y1)
    end
  end
end

-- Doi toa do the gioi sang chi so o dia hinh cua World Editor.
-- Tien khi can go toa do vao WE de ve song cho khop.
local function worldToTile(x, y)
  local g = S.grid
  return API.round((x - g.playMinX) / CFG.TILE), API.round((y - g.playMinY) / CFG.TILE)
end

-- ---------- Vung tao trong World Editor ----------
-- WE sinh moi vung thanh mot bien toan cuc ten gg_rct_<Ten>, tao trong
-- CreateRegions() do main() goi. Bootstrap chay sau khi main() xong nen
-- luc do chung da ton tai.

local function region(name)
  return _G["gg_rct_" .. name]
end

local function regionCenter(r)
  if r == nil then return nil, nil end
  return GetRectCenterX(r), GetRectCenterY(r)
end

-- Liet ke moi vung WE nhin thay duoc. Dung khi ten trong CFG khong khop.
local function listRegions()
  local out = {}
  for k, _ in pairs(_G) do
    if type(k) == "string" and k:sub(1, 7) == "gg_rct_" then
      out[#out + 1] = k:sub(8)
    end
  end
  table.sort(out)
  return out
end

-- Ten vung: mot chuoi, hoac mot danh sach ung vien thu lan luot.
local function regionNames(names)
  if type(names) == "string" then return { names } end
  return names
end

-- Nhan mot ten hoac danh sach ten. Thu khop chinh xac truoc, roi moi
-- khop khong phan biet hoa thuong.
local function findRegion(names)
  local list = regionNames(names)

  for i = 1, #list do
    local r = region(list[i])
    if r ~= nil then return r, list[i] end
  end

  local have = listRegions()
  for i = 1, #list do
    local lower = list[i]:lower()
    for j = 1, #have do
      if have[j]:lower() == lower then return region(have[j]), have[j] end
    end
  end
  return nil, nil
end

-- Ten de hien trong thong bao.
local function regionLabel(names)
  return table.concat(regionNames(names), " / ")
end

-- Bao khong tim thay vung, KEM danh sach vung World Editor that su co.
-- Khong phu thuoc CFG.DEBUG: go sai ten vung la loi rat kho doan neu
-- chi bao "khong thay".
local function regionMissing(cfgKey, name)
  API.msg(nil, CFG.C_RED .. "Khong tim thay vung " .. name ..
    "  (" .. cfgKey .. ")" .. CFG.C_END)
  local rgns = listRegions()
  if #rgns == 0 then
    API.msg(nil, "  World Editor chua co vung nao. Tao vung, Save, roi chay lai build.py.")
  else
    API.msg(nil, "  Vung dang co: " .. table.concat(rgns, ", "))
  end
end

API.regionNames   = regionNames
API.regionLabel   = regionLabel
API.regionMissing = regionMissing
API.region       = region
API.regionCenter = regionCenter
API.listRegions  = listRegions
API.findRegion   = findRegion

API.polarX       = polarX
API.polarY       = polarY
API.angleXY      = angleXY
API.distXY       = distXY
API.clampToMap   = clampToMap
API.playableRect = playableRect
API.buildGrid    = buildGrid
API.blockIndex   = blockIndex
API.blockBounds  = blockBounds
API.blockCenter  = blockCenter
API.blockAt      = blockAt
API.inRiver      = inRiver
API.riverColumns = riverColumns
API.riverRows    = riverRows
API.forEachBlock = forEachBlock
API.worldToTile  = worldToTile
