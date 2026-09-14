# Tổng quan

> **Trạng thái:** Nháp — map trắng, đang dựng nền
> **Cập nhật:** 2026-09-14

## Tình trạng hiện tại

Map trắng. Không có lối chơi, không có object data riêng, không có điều kiện
thắng thua. Phần đã dựng chỉ là **nền kỹ thuật**:

- Quy trình build: `src/*.lua` → `war3map.lua`, chạy lại nhiều lần vẫn ra một
  kết quả ([README](README.md)).
- Đăng ký người chơi và quan hệ đồng minh.
- Nhà chính và vùng địch, neo vào vùng vẽ trong World Editor.
- Popup chọn hero lúc vào map, mỗi người một con, không ai lấy trùng.
- Không hero nào lên cấp, và không hero nào nâng được kỹ năng gốc.
- Lưới 25 block với các dòng sông ngăn cách — mới ở mức **toạ độ**, chưa có
  địa hình.

Toàn bộ nội dung game của bản nháp trước (tu tiên, Lõi Tiên Đạo, đợt quái) đã bị
gỡ bỏ theo yêu cầu. Bốn module `05`–`08` để rỗng, giữ chỗ trong thứ tự nối.

## Cấu hình đã chốt

| | Giá trị | Ở đâu |
|---|---|---|
| Người chơi | 3 — slot 0, 1, 2 | `CFG.PLAYER_SLOTS` |
| Phe địch | 1 — slot 11, do máy giữ | `CFG.ENEMY_SLOT` |
| Lưới | 5 × 5 = 25 block | `CFG.GRID_COLS/ROWS` |
| Ngăn cách | Sông rộng 8 ô (chia hết 212) | `CFG.RIVER_TILES` |
| Map size | 224 × 224 ô — đã chốt | [04-map/kich-thuoc.md](04-map/kich-thuoc.md) |
| Địa hình sông | Vẽ tay trong World Editor | [ADR 0004](05-quyet-dinh/0004-song-ve-tay.md) |
| Nhà chính | Mountain King giữa `MyHouseRegion` — block #21 | [02-he-thong/nha-chinh.md](02-he-thong/nha-chinh.md) |
| Vùng địch | `MyEmenyRegion` — block #16, **chưa cho quái ra** | như trên |
| Chọn hero | Popup lúc vào map — 3 hero, mỗi người 1, không trùng | [02-he-thong/chon-hero.md](02-he-thong/chon-hero.md) |
| Debug | **Tắt** (`CFG.DEBUG = false`) | `01_config.lua` |

Ba người chơi là đồng minh, chung tầm nhìn. Slot trống hoặc do máy giữ bị bỏ
qua, nên chơi một mình vẫn vào map được.

## Chưa quyết

Những câu hỏi lớn còn treo. Quyết xong thì chuyển thành file trong
[05-quyet-dinh/](05-quyet-dinh/) và xoá khỏi đây.

1. **25 block dùng để làm gì?** Chưa có lối chơi nào gắn vào chúng. Lưới hiện
   là một cấu trúc trống — chiếm đất, phòng thủ, khu vực tài nguyên, hay gì khác.
   Đây là câu hỏi lớn nhất còn lại.
2. **Sông chặn hay lội qua được?** Nước sâu chặn đường bộ, nước nông thì không.
   Quyết định này đổi hẳn nhịp di chuyển của map.
3. **Qua sông bằng gì?** Cầu, cổng, hay phải phá. Chưa có gì.
4. **Ba người chơi quan hệ thế nào?** Hiện là đồng minh. Nếu sau này muốn tranh
   chấp block thì phải đổi.

## Bước kế tiếp

Xem [01-buoc-thuc-hien.md](01-buoc-thuc-hien.md).
