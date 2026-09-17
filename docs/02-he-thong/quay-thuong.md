# Quay thưởng — thẻ VI

> **Khoá CFG:** `QUAY_ELITE` `QUAY_BOSS` `QUAY_GIA_TRI` `QUAY_DAI_MIN/MAX`
> `QUAY_DA` `QUAY_VANG_MOI_DIEM` `QUAY_CHISO`
> **Mã:** [10_quay.lua](../../src/2_nguoi_choi/10_quay.lua)

Hạ **tinh anh** được 1 lượt, **boss** được 3 lượt. Mỗi lượt mở **ba thẻ**, chọn
**một**.

| Thẻ | Nhận được | Ghi chú |
|---|---|---|
| 1 | **10 Đá Huyền Thiết** | phẳng, không theo bậc |
| 2 | **+V** vào **một** chỉ số ngẫu nhiên trong Str/Agi/Int | canh bạc |
| 3 | **V × 12 vàng** | chắc chắn |

```
V(bậc) = CFG.QUAY_GIA_TRI × LINHCAN_STAT_STEP^(bậc−1)      ± 30%
       = 2.2 × 1.30^(bậc−1)
```

Dùng **chính** bước của Tu Vi, nên quay tự bám theo: đổi đường cong Tu Vi thì
quay tự co giãn, không phải chỉnh lại ở đây.

| Bậc | V | Thẻ 2 | Thẻ 3 (vàng) | 7 lượt = vàng | Quái cho |
|---|---|---|---|---|---|
| 1 | 2 | +2 | 26 | 185 | 200 |
| 5 | 6 | +6 | 75 | 528 | 200 |
| 10 | 23 | +23 | 280 | 1,960 | 200 |
| 20 | 322 | +322 | 3,859 | 27,016 | 200 |

## Vì sao 1 lượt / 3 lượt, không phải 5 / 10

Với 5/10 thì cả ván **600 lượt**: khoảng **30 phút** ngồi chọn menu, và mỗi lượt
chỉ đáng `±1` chỉ số ở cảnh giới đầu, `±7` ở cảnh giới 10 — không ai cảm thấy gì.

Với 1/3 thì **140 lượt**, mỗi lượt đáng ~31% một lần đột phá ở **mọi** cảnh giới.
Ít mà đậm hơn nhiều mà nhạt.

## Vì sao thẻ 3 là vàng, không phải máu/mana

Thẻ 3 ban đầu định cộng **máu/mana tối đa**. Bỏ vì một lý do kỹ thuật chắc chắn:

Bản 1.31.1 **không phơi ra trường nào cộng thêm máu tối đa**. Đo bằng `-nat ilf`
— có `ABILITY_ILF_STRENGTH_BONUS_ISTR`, `DEFENSE_BONUS_IDEF`, nhưng **không có**
cái nào cho max life. Chỉ còn `BlzSetUnitMaxHP`, mà hàm đó **ghi đè** — đúng cái
đã đóng băng giáp suốt mấy ngày *(xem [ability-ban-sao.md](../03-du-lieu/ability-ban-sao.md))*.

Vàng thì là bộ đếm cộng thuần, không ai sở hữu, và nó chảy thẳng vào shop.

> **Hệ quả phải nhớ khi thêm món vào shop:** giá món **phải leo theo bậc**. Vàng
> từ quay bám theo bậc còn vàng từ quái thì phẳng (1/con), nên nửa sau ván vàng
> từ quay áp đảo. Lọ thuốc 10 vàng là **cố ý** — nó là đồ tiêu hao vặt, không
> phải thứ để dành.

## Thẻ 2 chỉ tăng sát thương 1/3 số lần — có chủ đích

Sát thương kỹ năng ăn theo chỉ số **cao nhất**. Hart có Str cao nhất và Tu Vi
cộng đều cả ba, nên **Str luôn dẫn đầu**. Trúng Agi hay Int thì không tăng sát
thương kỹ năng, chỉ được:

| | Đo được trong game *(tooltip Hero Attributes, 2026-09-17)* |
|---|---|
| 1 Str | +1 sát thương, +25 máu, +hồi máu |
| 1 Agi | +1/3 giáp *(làm tròn xuống)*, +tốc đánh |
| 1 Int | +15 mana, +hồi mana |

Đã cân nhắc nhân `V` lên ×1.5 để bù tỉ lệ trúng 1/3, **không làm** — chủ dự án
chốt giữ nguyên, coi đó là canh bạc có chủ đích.

## Đá Huyền Thiết

Phẳng **10** mỗi lần, không theo bậc — vì giá nâng Trang Bị sẽ cố định theo lượng
đá. Cả ván nếu luôn chọn thẻ 1: **1,400 đá**, và đó là ngân sách tròn để thiết kế
Trang Bị quanh nó.

> ⚠ **Trang Bị đang khoá** (`CFG.TRANGBI_LOCKED`), nên từ giờ đến lúc mở lại, đá
> chỉ tăng chứ không tiêu được — đúng cái bẫy đã giết Tinh Thạch. Mở Trang Bị
> càng sớm càng tốt.

## Ba thẻ sinh ở đâu, và vì sao chỗ đó

`GetRandomInt` của Warcraft **đã đồng bộ sẵn** giữa các máy, với điều kiện mỗi máy
gọi **cùng số lần, cùng thứ tự**. Gọi nó trong một nhánh `GetLocalPlayer()` là
mỗi máy tiêu một số khác nhau từ chuỗi ngẫu nhiên, và từ giây đó **mọi** số ngẫu
nhiên của cả ván đều lệch.

Nên thẻ được rút trong `themLuot()` — hàm đó chạy từ sự kiện quái chết, tức chạy
trên **mọi** máy. Mở bảng là UI thuần, **không sinh gì cả**.

Mỗi người rút **riêng**: ba người cùng ba thẻ giống nhau thì cả ba cùng chọn thẻ
tốt nhất, và hệ này không tạo ra khác biệt nào giữa ba hero. 140 lượt khác nhau
thì tích luỹ thành ba build khác nhau.

Chọn thẻ đi qua `API.syncSend(CFG.OP_QUAY, i)` như mọi hành động khác.

## Chỉ số từ quay đi qua đâu

`10_quay.lua` **không** tự đặt chỉ số. Nó cộng vào `d.quayChiSo` rồi gọi
`heroRecompute` — hàm đó vẫn là **chỗ duy nhất** được ghi chỉ số hero. Đặt thẳng
là lần recompute sau xoá mất, đúng lỗi đã dính với giáp.

Cộng vào **nền** rồi mới nhân `%` của bị động Luyện Thể: một công thức duy nhất,
không phải nhớ thứ tự.
