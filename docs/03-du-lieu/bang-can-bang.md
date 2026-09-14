# Bảng khoá cấu hình

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-14
> **Nguồn sự thật:** [01_config.lua](../../src/01_config.lua)

Trang này **không chứa giá trị**. Giá trị sống trong `CFG`. Ở đây là ý nghĩa của
từng khoá và ràng buộc nó phải tuân — thứ đọc code không suy ra được.

Muốn xem số hiện tại: mở [01_config.lua](../../src/01_config.lua).

## Người chơi

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `PLAYER_SLOTS` | Slot của người chơi | Phải khớp slot đã bật trong World Editor. Slot trống hoặc do máy giữ sẽ bị bỏ qua lúc chạy |
| `ENEMY_SLOT` | Slot phe địch | Phải do máy điều khiển, và **không** được nằm trong `PLAYER_SLOTS` |

## Lưới

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `GRID_COLS` `GRID_ROWS` | Số cột, số hàng | Tối thiểu 1. Đổi thành 5×5 thì có 25 block; công thức không giả định con số 5 ở đâu cả |
| `TILE` | Kích thước một ô địa hình | **Là hằng số của Warcraft III = 128.** Đừng đổi |
| `RIVER_TILES` | Bề rộng lòng sông, tính bằng ô | Nên chọn số **chia hết** vùng chơi được (với 212 ô: chỉ 8 hoặc 18) để lề bằng 0 và mọi mép rơi đúng ranh giới ô. **Đổi số này là phải vẽ lại sông** |
| `BLOCK_TILES_OVERRIDE` | Ép kích thước block | `0` = để code tự chia theo vùng chơi được. Đặt `> 0` thì lưới có thể tràn khỏi vùng chơi được — code không kiểm chuyện đó |

Quan hệ giữa chúng, trên mỗi trục:

```
tổng số ô  =  2 × lề  +  n × block  +  (n − 1) × RIVER_TILES
```

Hiện tại: `212 = 0 + 5 × 36 + 4 × 8` — khít, lề bằng 0.

`block` và `lề` do code suy ra; chỉ `RIVER_TILES` và số cột/hàng là do bạn đặt.

## Vùng & nhà chính

Chi tiết: [02-he-thong/nha-chinh.md](../02-he-thong/nha-chinh.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `RGN_HOUSE` `RGN_ENEMY` | Tên vùng vẽ trong World Editor | Nhận **một tên hoặc danh sách tên**, thử lần lượt. Sai hết thì in ra danh sách vùng thật — dòng này hiện kể cả khi `DEBUG` tắt |
| `HOUSE_UNIT` | Unit làm nhà chính | **Placeholder** `htow`. Không có unit Zeus trong WC3 gốc |
| `HOUSE_HP` | Máu tối đa | Cần patch 1.31+ (`BlzSetUnitMaxHP`) |
| `HOUSE_INVULNERABLE` | Bất tử | `false`, vì chết là thua |
| `HOUSE_SELECTABLE` | Người chơi chọn được nhà không | `false` — tránh lọt vào Ctrl+A |
| `HOUSE_NAME` `HOUSE_FACE` `HOUSE_SCALE` | Tên hiện, hướng quay, cỡ | |

## Chọn hero

Chi tiết: [02-he-thong/chon-hero.md](../02-he-thong/chon-hero.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `HEROES` | Danh sách `{ id, name }` | Không được rỗng. `name` là chữ hiện trên nút popup |
| `PICK_TITLE` | Tiêu đề popup | |
| `PICK_DELAY` | Giây trước khi hiện popup | Quá nhỏ thì bị màn hình chuyển cảnh nuốt |
| `HERO_MAX_PER_PLAYER` | Mỗi người tối đa | `0` = không giới hạn |
| `HERO_UNIQUE` | Không ai lấy trùng | |
| `HERO_SPAWN_OFFSET` | Hero sinh cách nhà chính bao xa | |

> Không còn khoá nào cho giá, lương thực, quầy hàng hay requirement. `CreateUnit`
> bỏ qua toàn bộ techtree nên chúng không còn nghĩa lý gì.

## Khoá kinh nghiệm hero

Chi tiết: [02-he-thong/khoa-hero.md](../02-he-thong/khoa-hero.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `LOCK_HERO_XP` | Không hero nào lên cấp | Áp cho mọi phe |
| `SKILL_MODE` | `"none"` hoặc `"learn"` | Xem [ky-nang.md](../02-he-thong/ky-nang.md) |
| `SKILL_POINTS_START` | Điểm phát lúc hero sinh ra | Chỉ có nghĩa ở `"learn"` |
| `STRIP_SKILL_POINTS` | Rút sạch điểm kỹ năng | **Suy ra từ `SKILL_MODE`** — đừng sửa tay |
| `HERO_REMOVE_ABILITIES` | Gỡ hẳn ability khỏi danh sách học | Rỗng — thường không cần |
| `HERO_XP_SWEEP` | Giây giữa hai lần quét toàn map | `0` = chỉ khoá lúc tạo |

## Trình bày

| Khoá | Ý nghĩa |
|---|---|
| `C_GOLD` `C_JADE` `C_RED` `C_GREY` `C_END` | Mã màu; mọi chuỗi tô màu phải đóng bằng `C_END` |
| `MSG_TIME` | Giây hiện một dòng thông báo |
| `DEBUG` | Bật dòng `[dbg]`, bảng số lưới, ping minimap, báo cáo chi tiết. **Đang tắt.** Lỗi thật (thiếu vùng, tạo unit hỏng) vẫn hiện dù tắt |
| `VERSION` | Số hiệu bản dựng |

> **Mọi đường dẫn phải viết bằng `[[...]]`**, không dùng nháy kép — xem
> [ADR 0003](../05-quyet-dinh/0003-duong-dan-dung-chuoi-tho.md).

## Chưa có khoá nào cho

Object data (unit, ability, doodad) — map chưa có gì. Khi thêm, tạo
`docs/03-du-lieu/object-data.md` và ghi rõ ID nào là placeholder.
