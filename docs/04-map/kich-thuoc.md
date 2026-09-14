# Kích thước map

> **Trạng thái:** Đã chốt — 224 × 224
> **Cập nhật:** 2026-09-14
> **Nguồn:** `test2.w3x/war3map.w3e`, `war3map.lua`

## Số đo thật, đọc từ file

Đọc trực tiếp header của `war3map.w3e` (không phải nghe World Editor nói):

| | Giá trị |
|---|---|
| Lưới đỉnh | 225 × 225 |
| **Ô địa hình** | **224 × 224** |
| Thế giới | 28 672 × 28 672 đơn vị |
| Toạ độ | −14 336 … +14 336 (cả hai trục) |
| Tileset | `L` — Lordaeron Summer |

Vùng chơi được, lấy từ `SetCameraBounds` trong `war3map.lua`:

| | Giá trị |
|---|---|
| **Ô** | **212 × 212** |
| Đơn vị | 27 136 × 27 136 |
| X | −13 568 … +13 568 |
| Y | −13 824 … +13 312 |

Viền không chơi được là 6 ô mỗi bên: `224 − 2×6 = 212` ✔

## Kích thước đã chốt

**224 × 224 ô.** Xác nhận ngày 2026-09-14, không đổi nữa.

Con số 252 xuất hiện lúc đầu là nhầm — file luôn ghi 224. Chốt sớm là đúng: từ
giờ có địa hình vẽ tay gắn vào toạ độ, resize là vẽ lại từ đầu.

Code vẫn không hard-code con số này — lưới đo vùng chơi được lúc chạy. Nhưng
bảng toạ độ ở [toa-do-ve-song.md](toa-do-ve-song.md) thì tính sẵn theo 224.

## Trục Y lệch 2 ô

Vùng chơi được không đối xứng qua gốc toạ độ: Y chạy từ −13 824 tới +13 312,
tức tâm ở **−256** chứ không phải 0.

Hệ quả: **đừng dùng `(0, 0)` làm tâm map.** Tâm thật là `(0, −256)`. Chỗ nào cần
tâm thì hỏi `API.blockCenter(3, 3)` thay vì viết số.

## Đổi map size thì làm gì

1. World Editor → Scenario → Map Size and Camera Bounds.
2. Save map.
3. Chạy `python build.py` — WE vừa ghi đè `war3map.lua`, phải build lại.
4. Vào map, đọc dòng `[dbg]` để xem lưới tự chia lại ra sao.

Không cần sửa `CFG` gì cả trừ khi muốn đổi độ rộng sông.
