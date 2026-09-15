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

## ⬜ Bước 5 — Đợt quái

**Đã thiết kế xong, chưa viết một dòng code nào.**

| Tài liệu | Nội dung |
|---|---|
| [02-he-thong/dot-quai.md](02-he-thong/dot-quai.md) | Luật: 220 stage, thành phần wave, nhịp, tu chính |
| [02-he-thong/boss.md](02-he-thong/boss.md) | 20 boss cuối cảnh giới |
| [03-du-lieu/canh-gioi.md](03-du-lieu/canh-gioi.md) | Bảng 20 cảnh giới, cách chỉ số hoá stage |
| [03-du-lieu/duong-cong-suc-manh.md](03-du-lieu/duong-cong-suc-manh.md) | Công thức chỉ số + bảng tra |

**Hai thứ phải chốt trước khi gõ code:**

1. **Nhà chính đếm máu hay đếm mạng** —
   [ADR 0011](05-quyet-dinh/0011-nha-chinh-dem-mang.md). Quyết sau là phải gỡ code
   đã chạy được.
2. **Sức mạnh người chơi tăng bằng gì.** Hero không lên cấp mà địch mạnh lên ×967
   trong 220 wave. Không có câu trả lời thì đường cong địch thành bức tường ở
   khoảng cảnh giới 4, và mọi con số trong bảng tra vô nghĩa.

Thứ tự cài, mỗi bước chạy được và kiểm được:

1. Bộ đếm `stage` + đồng hồ wave. Chưa sinh con nào — chỉ in ra "Pham Nhan tang 3"
   đúng nhịp. Kèm lệnh dev `-wave <stage>` ngay từ đầu; không có nó thì không ai
   kiểm được wave 180.
2. Sinh `WAVE_MOB_COUNT` lính một mẫu duy nhất, chỉ số cố định, đi tới nhà.
   Kiểm pathing và `WAVE_REORDER_TICK` trước khi thêm bất cứ gì.
3. Áp đường cong chỉ số. In `EHP / máu thật / giáp / dmg` và đối chiếu bảng tra.
   Lệch là **công thức sai**, đừng chỉnh số để che.
4. Tinh anh, rồi 6 mẫu lính, rồi tu chính.
5. Boss cảnh giới 1. Đánh thử. **Rồi mới** làm 19 con còn lại.

**Cách kiểm:** đo thời gian hạ wave thật ở stage 1, 55, 110, 165, 220 rồi so với
`WAVE_TIME`. Đây mới là cân bằng — ba bước trên chỉ là kiểm công thức.

> **Bước này chặn bởi Bước 3.** Chưa biết sông có chặn đường không thì chưa biết
> quái đi bộ tới nhà mất bao lâu, mà `WAVE_TIME` phải lớn hơn con số đó.

---

## ⬜ Bước 6 — 25 block dùng để làm gì

Vẫn chưa quyết. Đợt quái **không** trả lời câu này: quái đi từ block #16 tới nhà,
23 block còn lại không có vai trò nào.

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
