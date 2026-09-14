# Các bước thực hiện

> **Cập nhật:** 2026-09-14

Làm từng bước một. Mỗi bước phải **chạy được và kiểm được** trước khi sang bước
sau — không dựng ba tầng rồi mới bật game lên xem.

---

## ✅ Bước 1 — Nền: kích thước, người chơi, lưới

**Xong.**

| Việc | Ở đâu |
|---|---|
| Đo map size thật từ `war3map.w3e` | [04-map/kich-thuoc.md](04-map/kich-thuoc.md) |
| 3 người chơi + 1 phe địch, quan hệ đồng minh | [04_player.lua](../src/04_player.lua) |
| Lưới 5×5 tự chia theo vùng chơi được | [03_geometry.lua](../src/03_geometry.lua) |
| Gỡ sạch nội dung game cũ, để rỗng `05`–`08` | — |

**Cách kiểm:** chạy `python build.py`, vào map bằng Ctrl+F9. Với `CFG.DEBUG = true`
sẽ thấy:

- Bảng số lưới in ra chat — đối chiếu với bảng trong
  [04-map/luoi-25-o.md](04-map/luoi-25-o.md).
- 25 chấm vàng ping trên minimap, đúng tâm 25 block, giãn cách đều nhau.

Nếu 25 chấm không đều hoặc lệch ra mép, lưới sai — đọc số `[dbg]` trước khi sửa.

---

## 🔨 Bước 2 — Vẽ sông trong World Editor

**Đang làm — vẽ tay.** Quyết định và lý do: [ADR 0004](05-quyet-dinh/0004-song-ve-tay.md).

Bảng toạ độ: [04-map/toa-do-ve-song.md](04-map/toa-do-ve-song.md).

Thứ tự:

1. **Một ngã tư trước**, quanh `(−2 816, −3 072)`. Chừng 10 phút.
2. **Vào game đi bộ quanh đó.** Sông 1 024 đơn vị là cản trở thật hay chỉ là
   vạch kẻ? Block 4 608 đơn vị đi hết mất bao lâu?
3. **Trả lời xong mới vẽ nốt 7 con còn lại.**

Vẽ cả 8 con trước khi biết cảm giác là vẽ mù.

**Cách kiểm:** 25 ping minimap phải rơi vào giữa 25 khoảng đất, không chấm nào
nằm dưới nước. Lệch thì sửa bên nào cũng được — vẽ lại sông, hoặc đổi
`CFG.RIVER_TILES` rồi build lại.

---

## 🔨 Bước 2b — Nhà chính & vùng địch

**Code xong — chờ bạn tạo vùng trong World Editor.**

Chi tiết: [02-he-thong/nha-chinh.md](02-he-thong/nha-chinh.md).

1. Region Palette (phím **R**), vẽ `MyHouseRegion` và `MyEmenyRegion`.
2. Save → `python build.py` → Ctrl+F9.

**Cách kiểm:** đọc khối `=== Vung & nha chinh ===` lúc vào map. Nó in danh sách
vùng WE nhìn thấy, toạ độ nhà, nhà rơi vào block nào, máu đặt được chưa.

Quái **chưa** ra — cố ý hoãn.

Chọn hero cũng chạy ở bước này — popup lúc vào map, xem
[02-he-thong/chon-hero.md](02-he-thong/chon-hero.md).

Vùng `MyTarvenRegion` không còn dùng tới; xoá trong World Editor lúc nào cũng được.

Còn treo: giá hero mới là "miễn phí giả" (phát tiền rồi hoàn lại). Giá 0 thật
sự cần Object Editor.

---

## ⬜ Bước 3 — Chặn đường và chỗ qua sông

Sông có nước rồi thì chưa chắc đã chặn được đường — WC3 cho đi qua nước nông.
Cần chốt: sông chặn hoàn toàn, hay lội qua được nhưng chậm?

Và nếu chặn thì qua sông bằng gì — cầu, cổng, hay phải phá?

---

## ⬜ Bước 4 — Vùng cho từng block

Gán region cho 25 block để bắt sự kiện vào/ra. Mở đường cho mọi lối chơi gắn với
"đang đứng ở block nào".

---

## ⬜ Bước 5 — Lối chơi

Chưa quyết gì cả. 25 block hiện là cấu trúc trống, chưa có mục đích.

Đừng bắt đầu bước này trước khi bước 2 xong — hình dạng địa hình quyết định lối
chơi nào khả thi.

---

## Quy trình mỗi lần test

```
sửa địa hình trong World Editor  →  Save
sửa code trong src/
python build.py                  ←  luôn là bước cuối
Ctrl+F9
```

World Editor **ghi đè `war3map.lua` mỗi lần Save**. Save sau khi build là mất
sạch code. Nếu vào map mà không thấy dòng `[dbg]` nào, gần như chắc chắn là quên
chạy build.
