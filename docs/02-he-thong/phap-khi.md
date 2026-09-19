# Hệ thống: Pháp Khí — thẻ IV, mua một lần

> **Trạng thái:** Đã cài — mở khoá 2026-09-19
> **Code:** [6_relic.lua](../../src/2_player/6_relic.lua)
> **Khoá CFG:** `RELIC` `RELIC_LOCKED` `OP_RELIC_BUY`
> **Liên quan:** [kinh-te.md](kinh-te.md) · [trang-bi-kiem.md](trang-bi-kiem.md)

## Nó là gì

Bốn món, **mua một lần, không có cấp**, trả bằng **Gỗ** *(Ngộ Tính)*.

| # | Món | Hiệu ứng | Giá | Mở khoá bằng |
|---|---|---|---|---|
| 1 | **Hoả Vũ Linh Châu** | +25% sát thương gây ra | 70 | Chu Tước |
| 2 | **Huyền Quy Giáp** | −20% sát thương nhận, cả hai loại | 70 | Huyền Vũ |
| 3 | **Bất Động Minh Vương** | Nổ Tan **và** Xé Giáp của boss đều còn **một nửa** | 55 | Bạch Hổ |
| 4 | **Lưỡng Nghi Châu** | Chắn Phép / Dày Da chỉ còn cắt **một nửa** | 55 | Thanh Long |

Bảng xếp **đúng thứ tự hạ thú**, nên `unlock[i] == i` — thẻ IV đọc như một
thanh tiến độ: cột trên mở trước, cột dưới mở sau.

Tổng **250 Gỗ**. Ngân sách khả dụng **~222** *(cả ván ~292, kỹ năng ăn 70)*.

## Vì sao không đủ tiền mua hết — và đó là điểm

**Trang Bị là cái thang.** Ai cũng leo cùng một thang, chỉ khác leo cao bao
nhiêu. Hai người chơi hết ván sẽ có bộ đồ giống hệt nhau, chỉ khác cấp.

**Pháp Khí là ngã rẽ.** 250 > 222 nghĩa là mua được **đúng ba món, phải bỏ
một** — và đó là chỗ duy nhất trong map người chơi phải *chọn* thay vì *tích*.
Nếu hạ giá cho mua đủ bốn thì nó lại thành một cái thang nữa, chỉ đổi tên.

Cũng vì thế **hiệu ứng để to** (+25% chứ không +8%): một món mua-một-lần-không-
có-cấp phải cảm thấy được **như một sự kiện**. Mua xong mà không thấy gì đổi thì
70 Gỗ đó là tiền vứt đi.

## Mỗi món trả lời một áp lực cụ thể

Đây là nguyên tắc thiết kế, không phải cách xếp bảng cho đẹp. Map đã có những
áp lực **phân biệt được**, và mỗi Pháp Khí là câu trả lời cho một cái:

| Áp lực | Món trả lời |
|---|---|
| Không đủ sát thương | Hoả Vũ |
| Chết quá nhanh | Huyền Quy |
| Tu chính Chắn Phép / Dày Da ép đổi cách đánh | Lưỡng Nghi |
| Nổ Tan phạt đứng chụm · boss xé giáp | Bất Động |

Hai món đầu ai cũng muốn nên **đắt hơn**. Hai món sau chỉ ăn ở một số đợt nên
rẻ hơn — nhưng đúng đợt thì chúng đổi hẳn trận đánh.

## Bốn chỗ móc, và lý do đặt đúng ở đó

Không món nào đăng ký trigger riêng. Chỗ nào cần thì hỏi `API.relicVal(pid,
code, field)` — luật **đọc-lúc-dùng** mà `6_relic.lua` tự đặt ở đầu file:

> *Một món cần bộ bắt sự kiện riêng là một món có thể hỏng âm thầm, mà cả ván
> chỉ mua được vài lần.*

| Món | Móc vào | Chi tiết bắt buộc làm đúng |
|---|---|---|
| Hoả Vũ | [7_effect.lua](../../src/2_player/7_effect.lua) | **Cộng vào cùng một `pct` với Kiếm rồi nhân một lần.** Nhân hai lần nối tiếp thì Kiếm và Pháp Khí tự khuếch đại nhau |
| Huyền Quy | `7_effect.lua`, biến `keep` | **Nhân** chứ không trừ thẳng — hai nguồn giảm cộng lại sẽ vượt trần và biến hero thành bất tử |
| Lưỡng Nghi | [5_modifier.lua](../../src/3_battle/5_modifier.lua) | Lọc theo **người gây sát thương**, không theo mục tiêu |
| Bất Động | `5_modifier.lua` + [3_boss.lua](../../src/3_battle/3_boss.lua) | Xé Giáp giảm lúc **cộng dồn**, không lúc đọc ra |

### Vì sao Lưỡng Nghi lọc theo nguồn chứ không theo mục tiêu

Mục tiêu là **con quái**, mà món đồ là của **hero**. Lọc theo mục tiêu thì không
có chỗ nào để hỏi. Lọc theo nguồn còn được thêm một tính chất đúng: ai không mua
thì vẫn ăn đủ 50%, nên **hai người trong một đội đánh khác nhau** — đúng tinh
thần "ngã rẽ".

### Vì sao Bất Động giảm lúc cộng dồn

`d.bossShred` vừa là con số **tính sát thương** vừa là con số **báo cho người
chơi** (`boss_shred`, báo theo mốc 25%). Giảm lúc đọc ra thì hai con số lệch
nhau — người chơi đọc 50% mà thực nhận 25%.

## Icon: dùng chân dung bốn Thánh Thú

`avatar\B001..B004.blp` — bốn ảnh **đã import thật**, xác nhận bằng
`python w3import.py list test2.w3x`.

Ban đầu định gõ `BTNLavaSpawn.blp`, `BTNThoriumArmor.blp`… theo trí nhớ. Đó là
đoán, và đường dẫn texture sai thì ra **ô xanh lá** chứ không báo lỗi — đúng kiểu
bẫy im lặng của map này. Tiện thể chân dung nói luôn ý đồ: món này mở khoá bằng
con thú nào.

## Mở khoá bằng Thánh Thú

Hạ con thú thứ `i` → mở món thứ `i`. Cờ `S.sideDone[i]` đặt trong `onDeath()`
của [4_sidequest.lua](../../src/3_battle/4_sidequest.lua).

**Cờ là của CHUNG, không nằm trong `S.p[pid]`** — con thú chỉ có một, hạ rồi là
cả đội hạ rồi. Cùng lý do với cấp nâng cấp nhà chính.

**Con thú là cái CỔNG, Gỗ là cái BỂ TIÊU.** Tặng thẳng món đồ thì 222 Gỗ lại
rơi vào cảnh không có gì để mua — đúng cái lỗ cũ, chỉ dời chỗ. Mở khoá xong vẫn
phải trả đủ giá.

Và đây mới là **lý do đi giết bốn con thú**. Trước đó chúng chỉ cho lượt quay,
tức là tiền — mà tiền thì farm quái cũng có.

### Ô khoá có nút, không bỏ trống

Chưa mở thì dòng đó vẫn có nút, nhưng khoá và ghi **tên con thú phải hạ**:

```
[##] Huyen Quy Giap          KHOA        [ PHAI HA Huyen Vu ]
```

Ô trống thì người chơi tưởng giao diện hỏng. Có nút khoá kèm tên con thú thì nó
thành một **cái đích**.

Lúc con thú ngã, báo cho cả bàn đồ:

```
[He Thong] Mo khoa Phap Khi: Huyen Quy Giap -- 70 Go o the IV.
```

**Kiểm lại ở bên nhận** (`buy()`), không tin cú bấm — bên gửi là cục bộ.

## Chưa làm

- **Chưa đo trận thật.** Giá và % là con số đầu.
- **Bốn món là ít.** Mua ba trong bốn thì chỉ có 4 tổ hợp. Sáu món mua ba sẽ
  cho 20 — thêm món là thêm một dòng `CFG.RELIC` **và** viết chỗ đọc mã của nó.

## Hai món đã bỏ khỏi thiết kế

**Trấn Thiên Bi** *(nhà +30% máu)* và **Hồi Xuân Trận** *(nhà +15% hồi mỗi
wave)* — bỏ vì **trùng việc với thẻ VI**
([nang-cap-nha-chinh.md](nang-cap-nha-chinh.md)). Hai hệ cùng sửa một con số là
hai nơi cùng khai một thứ, và hai nơi thì sớm muộn lệch.

Hai mã `nhahp` / `nharegen` **vẫn còn** trong `rescaleHouse()` và luôn trả
`false` vì bảng không có chúng. Giữ lại vô hại, và là chỗ nối sẵn nếu sau này
đổi ý.

← [Kinh tế](kinh-te.md) · [Trang Bị](trang-bi-kiem.md)
