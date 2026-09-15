# Lưới 25 ô và các dòng sông

> **Trạng thái:** Toạ độ `Đã cài` — địa hình vẽ tay ([ADR 0004](../05-quyet-dinh/0004-song-ve-tay.md))
> **Cập nhật:** 2026-09-14
> **Code:** [4_geometry.lua](../../src/1_nen/4_geometry.lua)
> **Khoá CFG:** `GRID_COLS` `GRID_ROWS` `RIVER_TILES` `BLOCK_TILES_OVERRIDE` `TILE`

## Hình dạng

Vùng chơi được chia thành lưới 5×5 = 25 block, giữa hai block liền kề là một
dòng sông. Trên một trục:

```
|<-lề->|block|sông|block|sông|block|sông|block|sông|block|<-lề->|
```

Block đánh số từ 1, **góc dưới–trái là (1,1)** — cùng chiều với trục toạ độ WC3,
để khỏi phải lật dấu ở mọi phép tính. Chỉ số chạy 1…25 theo hàng, từ dưới lên.

## Kích thước không hard-code

`API.buildGrid()` đo vùng chơi được thật lúc chạy (`bj_mapInitialPlayableArea`)
rồi chia:

```
block = floor( (tổng số ô - (n-1) × RIVER_TILES) / n )
lề    = floor( (tổng số ô - dùng thật) / 2 )
```

Phần dư sau khi chia đều bị đẩy ra hai biên làm lề, nên lưới **luôn nằm chính
giữa** vùng chơi được. Lề làm tròn xuống để góc lưới rơi đúng ranh giới ô —
nếu không thì không đếm ô trong World Editor được; nửa ô dư nếu có bị đẩy sang
biên phải/trên. Đổi map size trong World Editor không phải sửa gì trong
code.

### Số liệu ở map hiện tại (224×224, chơi được 212×212 ô)

| | Ô địa hình | Đơn vị |
|---|---|---|
| Vùng chơi được | 212 × 212 | 27 136 |
| Mỗi block | 36 × 36 | 4 608 |
| Lòng sông | 8 | 1 024 |
| Lề mỗi bên | 0 | 0 |

Kiểm: `5×36 + 4×8 = 212` — **khít, không dư ô nào** ✔

Đây là lý do `RIVER_TILES = 8` chứ không phải 10: trong dải 4…20, chỉ 8 và 18
chia hết 212. Lề bằng 0 nghĩa là mọi mép block và mép sông đều rơi đúng ranh
giới ô, đếm ô trong World Editor là ra.

Góc lưới (1,1) trùng góc vùng chơi được, `(-13568, -13824)`. Block giữa (#13) có
tâm `(0, -256)` — đúng tâm vùng chơi được.

Toàn bộ toạ độ để vẽ: [toa-do-ve-song.md](toa-do-ve-song.md).

## API

| Hàm | Trả về |
|---|---|
| `API.buildGrid()` | Dựng `S.grid`, gọi một lần lúc khởi động |
| `API.blockBounds(col, row)` | `x0, y0, x1, y1` |
| `API.blockCenter(col, row)` | `x, y` |
| `API.blockIndex(col, row)` | 1…25 |
| `API.blockAt(x, y)` | `col, row` — hoặc **`nil` nếu điểm nằm dưới sông** |
| `API.inRiver(x, y)` | `true` nếu trong lòng sông (và trong phạm vi lưới) |
| `API.riverColumns()` | 4 lòng sông dọc, `{x0, x1}` |
| `API.riverRows()` | 4 lòng sông ngang, `{y0, y1}` |
| `API.forEachBlock(f)` | Duyệt 25 block |
| `API.worldToTile(x, y)` | Đổi sang chỉ số ô của World Editor |

`blockAt` trả `nil` cho **cả hai** trường hợp: dưới sông, và ngoài lưới. Chỗ nào
cần phân biệt thì hỏi thêm `API.inRiver`.

## Điều phải biết trước khi làm tiếp

**Lua của WC3 không tạo được nước lúc chạy.** Nước là thuộc tính từng ô, nướng
sẵn trong `war3map.w3e`; không có native nào đổi được mực nước hay bật cờ nước
khi game đã chạy. `SetTerrainType` chỉ đổi *hình nền* mặt đất, `TerrainDeform*`
chỉ bóp méo hình học — cả hai đều không sinh ra mặt nước.

Nên module này cố ý **chỉ giữ toạ độ** — tầng logic. Con sông thật sự là địa
hình vẽ tay trong World Editor — tầng hình ảnh.

**Hai tầng không buộc phải trùng nhau từng ô.** Lòng sông 1 024 đơn vị là tim
đường để vẽ trong đó, không phải khuôn để tô theo; `blockAt` vẫn trả đúng dù sông
uốn cong. Lý do chọn vẽ tay thay vì sinh `war3map.w3e` bằng code:
[ADR 0004](../05-quyet-dinh/0004-song-ve-tay.md).

## Chưa làm

- Cầu hoặc chỗ lội qua sông. Hiện sông chỉ là toạ độ, chưa chặn đường ai cả.
- Chặn đường (pathing blocker) dọc lòng sông.
- Gán vùng (region) cho từng block để bắt sự kiện ra/vào.
- Khái niệm block kề nhau, dùng cho lan truyền hay tìm đường.
- Block nào là của ai — chưa có chủ sở hữu.
