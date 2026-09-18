# Cơ Duyên — khung ba cột

> **Khoá CFG:** `FORTUNE_ELITE` `FORTUNE_BOSS` `FORTUNE_VALUE` `FORTUNE_RANGE_MIN/MAX`
> `FORTUNE_IRON` `FORTUNE_GOLD_MIN/MAX` `FORTUNE_STATS` `FORTUNE_X/Y`
> **Mã:** [10_fortune.lua](../../src/2_player/10_fortune.lua) *(số liệu)* ·
> [5_fortuneframe.lua](../../src/4_ui/5_fortuneframe.lua) *(giao diện)*

**Không phải một thẻ trong bảng.** Khung riêng, **ba cột dọc**, mở **ngay** khi
tinh anh hoặc boss chết — kiểu chọn lõi của TFT. Cả cột là một nút: bấm đâu trong
cột cũng được.

**ESC không đóng khung này.** Phải chọn một thẻ mới đi tiếp. `bindEsc()` trong
[1_panel.lua](../../src/4_ui/1_panel.lua) hỏi `API.fortuneFrameShown(pid)`
trước khi làm gì — khung đang mở thì ESC vừa không đóng nó, vừa không mở bảng
nhân vật đè lên.

Khung `0.46 × 0.261`, tâm `(0.40, 0.36)` → trải từ `y=0.229` đến `0.490`, thoát
cả thanh giao diện đáy (~0.12) lẫn mép trên.

> Khung **không sinh ngẫu nhiên**. Thẻ đã được rút ở `10_fortune.lua`, từ sự kiện
> quái chết, trên **mọi** máy; ở đây chỉ vẽ lại thứ đã có. Xem mục cuối tài liệu
> này về lý do.

Hạ **tinh anh** được 1 lượt, **boss** được 3 lượt. Mỗi lượt mở **ba thẻ**, chọn
**một**.

| Thẻ | Nhận được | Phẳng hay leo |
|---|---|---|
| 1 | **3 Đá Huyền Thiết** | **phẳng** — tiền |
| 2 | **+V** vào **một** chỉ số ngẫu nhiên trong Str/Agi/Int | **leo ×1.30** — sức mạnh |
| 3 | **30–90 vàng**, ngẫu nhiên | **phẳng** — tiền |

```
V(bậc) = CFG.FORTUNE_VALUE × CULT_STAT_STEP^(bậc−1)      ± 30%
       = 2.2 × 1.30^(bậc−1)          <- CHI the 2 dung V
```

> ## Tiền thì phẳng, sức mạnh thì leo — 2026-09-17
>
> Bản trước thẻ 3 là `V × 12`, tức **nhân theo bậc**. Đo được hậu quả:
>
> | Cảnh giới | Thẻ 3 | = mấy đá *(giá 25)* | Thẻ 1 | Ai hơn |
> |---|---|---|---|---|
> | 1 | 26 | 1.1 | 3 | thẻ 1 ×2.8 |
> | 10 | 280 | 11.2 | 3 | **thẻ 3 ×3.7** |
> | 20 | 3 859 | **154** | 3 | **thẻ 3 ×51** |
>
> Từ khoảng cảnh giới 5–10 trở đi, chọn thẻ 3 rồi mang vàng đi mua đá **luôn
> luôn** lợi hơn chọn thẻ 1 — thẻ 1 thành **thẻ chết** đúng nửa sau ván.
>
> Nguyên nhân không phải con số 12, mà là **một thẻ leo ×180 trong khi thẻ kia
> đứng yên**. Hai đường khác độ dốc thì sớm muộn cũng cắt nhau.
>
> **Luật rút ra:** thẻ 1 và thẻ 3 cho **tiền** → phẳng. Thẻ 2 cho **sức mạnh**
> → leo. Đúng hướng cả nền kinh tế đã đi (thu nhập phẳng, Tu Vi phẳng 500, kỹ
> năng phẳng 1 Gỗ); thẻ 3 là thứ cuối cùng còn sót lại của thời thu nhập mũ.

### Vì sao thẻ 3 là **dải** chứ không phải một số cố định

Số cố định thì phép so sánh ba thẻ **giải đúng một lần rồi lặp lại 140 lần** —
người chơi bấm theo quán tính. Có dải thì thỉnh thoảng nó đảo ngược, nên mỗi
lượt phải nhìn thật.

Dải đặt theo thẻ 1 quy ra vàng (giá đá `25`):

| Lượt rơi | = mấy đá | Nên chọn |
|---|---|---|
| 30 | 1.2 | thẻ 1 |
| 60 *(trung bình)* | 2.4 | ngang ngửa |
| 90 | 3.6 | thẻ 3 |

Thẻ 1 cho 3 đá = **75 vàng**, nhưng **khoá** — chỉ mua được trang bị. Trung
bình thẻ 3 thấp hơn 75 một chút vì vàng **linh hoạt hơn**: nó đổi ngược lại
thành đá lúc nào cũng được, còn đá thì không đổi ngược thành vàng.

**Đỉnh dải phải vượt 75**, nếu không thẻ 3 thua mọi lượt và lại chết.

Đối chiếu với tiền quái: quái cho **200 vàng** một cảnh giới, còn 7 lượt thẻ 3
cho **~420** — gấp đôi, đủ để nó là lựa chọn thật.

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

> ⚠ **Trang Bị đang khoá** (`CFG.GEAR_LOCKED`), nên từ giờ đến lúc mở lại, đá
> chỉ tăng chứ không tiêu được — đúng cái bẫy đã giết Tinh Thạch. Mở Trang Bị
> càng sớm càng tốt.

## Ba thẻ sinh ở đâu, và vì sao chỗ đó

`GetRandomInt` của Warcraft **đã đồng bộ sẵn** giữa các máy, với điều kiện mỗi máy
gọi **cùng số lần, cùng thứ tự**. Gọi nó trong một nhánh `GetLocalPlayer()` là
mỗi máy tiêu một số khác nhau từ chuỗi ngẫu nhiên, và từ giây đó **mọi** số ngẫu
nhiên của cả ván đều lệch.

Nên thẻ được rút trong `addRolls()` — hàm đó chạy từ sự kiện quái chết, tức chạy
trên **mọi** máy. Mở bảng là UI thuần, **không sinh gì cả**.

Mỗi người rút **riêng**: ba người cùng ba thẻ giống nhau thì cả ba cùng chọn thẻ
tốt nhất, và hệ này không tạo ra khác biệt nào giữa ba hero. 140 lượt khác nhau
thì tích luỹ thành ba build khác nhau.

Chọn thẻ đi qua `API.syncSend(CFG.OP_FORTUNE, i)` như mọi hành động khác.

## Chỉ số từ quay đi qua đâu

`10_fortune.lua` **không** tự đặt chỉ số. Nó cộng vào `d.rollStats` rồi gọi
`heroRecompute` — hàm đó vẫn là **chỗ duy nhất** được ghi chỉ số hero. Đặt thẳng
là lần recompute sau xoá mất, đúng lỗi đã dính với giáp.

Cộng vào **nền** rồi mới nhân `%` của bị động Luyện Thể: một công thức duy nhất,
không phải nhớ thứ tự.
