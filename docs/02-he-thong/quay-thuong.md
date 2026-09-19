# Cơ Duyên — mỗi thẻ một cột

> **Trạng thái:** **Đã cài** — hai thẻ
> **Cập nhật:** 2026-09-18
> **Khoá CFG:** `FORTUNE_ELITE` `FORTUNE_BOSS` `FORTUNE_VALUE` `FORTUNE_RANGE_MIN/MAX`
> `FORTUNE_KINDS` `FORTUNE_GOLD_MIN/MAX` `FORTUNE_STATS` `FORTUNE_X/Y`
> **Mã:** [10_fortune.lua](../../src/2_player/10_fortune.lua) *(số liệu)* ·
> [5_fortuneframe.lua](../../src/4_ui/5_fortuneframe.lua) *(giao diện)*

**Không phải một thẻ trong bảng.** Khung riêng, **mỗi thẻ một cột dọc**, mở
**ngay** khi tinh anh hoặc boss chết — kiểu chọn lõi của TFT. Cả cột là một nút:
bấm đâu trong cột cũng được.

**Số cột đọc từ `CFG.FORTUNE_KINDS`**, không gõ cứng. Thêm hay bớt một thẻ là
thêm một dòng vào bảng đó cộng một nhánh trong `take()`; khung tự chia lại bề
ngang.

**ESC không đóng khung này.** Phải chọn một thẻ mới đi tiếp. `bindEsc()` trong
[1_panel.lua](../../src/4_ui/1_panel.lua) hỏi `API.fortuneFrameShown(pid)`
trước khi làm gì — khung đang mở thì ESC vừa không đóng nó, vừa không mở bảng
nhân vật đè lên.

Khung `0.46 × 0.261`, tâm `(0.40, 0.36)` → trải từ `y=0.229` đến `0.490`, thoát
cả thanh giao diện đáy (~0.12) lẫn mép trên.

> Khung **không sinh ngẫu nhiên**. Thẻ đã được rút ở `10_fortune.lua`, từ sự kiện
> quái chết, trên **mọi** máy; ở đây chỉ vẽ lại thứ đã có. Xem mục cuối tài liệu
> này về lý do.

Mỗi lượt mở **hai thẻ**, chọn **một**. Ba nguồn cho lượt quay:

| Nguồn | Lượt | Khoá `CFG` |
|---|---|---|
| Hạ **tinh anh** | 1 | `FORTUNE_ELITE` |
| Hạ **boss** | 3 | `FORTUNE_BOSS` |
| Hạ **Thánh Thú** | 3 · 5 · 8 · 12 | `SIDE_QUESTS[i].rolls` |

**Cả ba nguồn đều là phần thưởng cho việc đi đánh** — và từ 2026-09-19 đó là
điều kiện duy nhất.

> **Quà ở cổng đã bỏ *(2026-09-19)*.** `CFG.GATE_ROLL = 0`. Trước đó qua cổng
> `HeroMoveRegion` lần đầu được **1 lượt** làm quà làm quen.
>
> Lý do bỏ: một lượt quay miễn phí ngay giây đầu dạy người chơi rằng **quay là
> thứ tự đến**. Cả hệ Cơ Duyên được dựng để *thưởng* cho việc hạ tinh anh và
> boss; mở màn bằng một lượt không phải trả gì là nói ngược lại chính nó ngay
> trước khi người chơi kịp hiểu nó là gì.
>
> Khoá vẫn còn và `0` là tắt — bật lại chỉ là đổi một số.

### Khung tự đóng bảng ESC *(2026-09-19)*

**Lỗi đã ship:** đang mở `ESC` mà tinh anh hoặc boss chết thì khung Cơ Duyên bật
lên **đè lên bảng** — hai khung cùng neo vào `ORIGIN_FRAME_GAME_UI`, không cái
nào biết cái nào. Người chơi thấy chữ chồng chít và không bấm được gì cho ra hồn.

`showFrame()` gọi `API.panelHide(pid)` trước khi hiện. **Khung Cơ Duyên là cái
bật lên không xin phép** (từ sự kiện quái chết), nên nó là bên phải nhường đường
— chứ không phải bắt bảng đi kiểm xem có khung nào sắp bật hay không.

### Hiệu ứng chia bài — đã làm rồi đã tắt *(2026-09-19)*

> **Đang TẮT.** `CFG.FORTUNE_DEAL_STEP = 0.0`. Code vẫn còn nguyên và bật lại
> chỉ là đổi một số — phần dưới giữ lại vì nó ghi một bài học.

Đổi thẻ giữa hai lượt trước đây là một cú **nhảy**: chữ và icon đổi tại chỗ
trong cùng một khung hình, không có gì báo là vừa sang lượt mới. Có 12 lượt liên
tiếp (Thanh Long) thì nó thành một cái bảng nhảy loạn.

`dealIn()` chia **từng cột một**, cách nhau `CFG.FORTUNE_DEAL_STEP` giây.

**Vì sao tắt.** Lý lẽ đặt `0.10` là *"đủ để mắt thấy vừa sang lượt mới, chưa đủ
để thành chờ đợi"* — và đó là lý lẽ của người **nhìn một lượt**. Người chơi thật
thì quay 12 lượt liên tiếp sau Thanh Long, và ở đó mỗi lần chờ là một lần tay
phải dừng lại: 2,4 giây cộng dồn cho cả chuỗi, trả bằng nhịp bấm.

> Một hiệu ứng trang trí thừa ở lần thứ mười hai thì nó không còn là trang trí,
> nó là độ trễ.

Chỉ dùng `BlzFrameSetVisible` — **không** dùng alpha hay scale: hai thứ đó không
chắc có ở mọi bản, mà một hiệu ứng trang trí thì không đáng để làm hỏng khung.
Ẩn cả cột **lẫn nút**: để lại cái nút không thì nó lơ lửng một mình, nhìn ra lỗi
vẽ chứ không ra hiệu ứng. Và kiểm lại `st.shown` **lúc đến giờ** — người chơi có
thể đã đóng khung, bật lại một cái thẻ lẻ giữa màn hình là một lỗi nhìn thấy
được.

Không đồng bộ: nó không đổi một chút trạng thái nào, và mỗi máy có khung riêng.

### Thánh Thú — phần thưởng của bốn cái mốc *(2026-09-19)*

| Con | Mốc | Lượt |
|---|---|---|
| Chu Tước | Phàm Nhân (1) | **3** |
| Huyền Vũ | Hoá Thần (6) | **5** |
| Bạch Hổ | Chân Tiên (11) | **8** |
| Thanh Long | Tiên Đế (16) | **12** |
| | | **28** |

So với tinh anh 1 / boss 3 thì đây rõ ràng là hạng khác. 28 lượt trên 140 lượt
của cả ván — **+20%**, đáng kể mà không làm lệch nhịp.

**Vì sao là lượt quay chứ không phải vàng.** Trận Thanh Long dài 240 giây. Kết
thúc mà chỉ được một cục Linh Khí thì hụt: cả ván kiếm ~1,88 triệu Linh Khí, một
cục 50 000 chỉ là làm tròn số. Lượt quay thì **nổ ngay trên màn hình** — khung
Cơ Duyên tự bật, hai thẻ, chọn một. Phần thưởng của một cái mốc phải là thứ
*không farm được bằng cách khác*.

**Chỉ ai CÓ MẶT trong hang mới được.** Người đang ở nhà chính farm quái mà vẫn
ăn thưởng thì một người đánh cả đội cùng giàu — và trận 240 giây mất hết ý
nghĩa. Không đòi còn sống: **chết trong hang vẫn là đã đánh**, xác nằm ngay đó
nên phép đo khoảng cách vẫn đúng. Ai đứng ngoài nhận một dòng xám nói rõ vì sao
không có gì — im lặng thì người chơi tưởng hệ thưởng hỏng.

| Thẻ | Nhận được | Phẳng hay leo |
|---|---|---|
| vàng | **30–90 vàng**, ngẫu nhiên | **phẳng** — tiền |
| chỉ số | **+V** vào **một** chỉ số ngẫu nhiên trong Str/Agi/Int | **leo ×1.30** — sức mạnh |
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

### Vì sao thẻ vàng là **dải** chứ không phải một số cố định

Số cố định thì phép so sánh hai thẻ **giải đúng một lần rồi lặp lại 140 lần** —
người chơi bấm theo quán tính. Có dải thì thỉnh thoảng nó đảo ngược, nên mỗi
lượt phải nhìn thật.

Dải `30–90` quy ra đá (giá `10`) và ra điểm, để so với thẻ chỉ số:

| Lượt rơi | = mấy đá | = mấy điểm *(cảnh giới r)* | Nên chọn |
|---|---|---|---|
| 30 | 3.0 | `0.94 × 1.30^(r−1)` | thẻ chỉ số |
| 60 *(trung bình)* | 6.0 | `1.88 × 1.30^(r−1)` | ngang ngửa |
| 90 | 9.0 | `2.81 × 1.30^(r−1)` | thẻ vàng |

Thẻ chỉ số cho `2.2 × 1.30^(r−1)`, tức nằm **giữa** dải — đúng chỗ nó phải nằm
để mỗi lượt vẫn là một quyết định.

Đối chiếu với tiền quái: quái cho **200 vàng** một cảnh giới, còn 7 lượt thẻ vàng
cho **~420** — gấp đôi, đủ để nó là nguồn thu chính chứ không phải thêm nếm.

## Vì sao 1 lượt / 3 lượt, không phải 5 / 10

Với 5/10 thì cả ván **600 lượt**: khoảng **30 phút** ngồi chọn menu, và mỗi lượt
chỉ đáng `±1` chỉ số ở cảnh giới đầu, `±7` ở cảnh giới 10 — không ai cảm thấy gì.

Với 1/3 thì **140 lượt**, mỗi lượt đáng ~31% một lần đột phá ở **mọi** cảnh giới.
Ít mà đậm hơn nhiều mà nhạt.

## Vì sao thẻ vàng là vàng, không phải máu/mana

Thẻ vàng ban đầu định cộng **máu/mana tối đa**. Bỏ vì một lý do kỹ thuật chắc chắn:

Bản 1.31.1 **không phơi ra trường nào cộng thêm máu tối đa**. Đo bằng `-nat ilf`
— có `ABILITY_ILF_STRENGTH_BONUS_ISTR`, `DEFENSE_BONUS_IDEF`, nhưng **không có**
cái nào cho max life. Chỉ còn `BlzSetUnitMaxHP`, mà hàm đó **ghi đè** — đúng cái
đã đóng băng giáp suốt mấy ngày *(xem [ability-ban-sao.md](../03-du-lieu/ability-ban-sao.md))*.

Vàng thì là bộ đếm cộng thuần, không ai sở hữu, và nó chảy thẳng vào shop.

> **Hệ quả phải nhớ khi thêm món vào shop:** giá món **phải leo theo bậc**. Vàng
> từ quay bám theo bậc còn vàng từ quái thì phẳng (1/con), nên nửa sau ván vàng
> từ quay áp đảo. Lọ thuốc 10 vàng là **cố ý** — nó là đồ tiêu hao vặt, không
> phải thứ để dành.

## Thẻ chỉ số chỉ tăng sát thương 1/3 số lần — có chủ đích

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

## Thẻ đá đã bỏ — 2026-09-18

Trước đây có thẻ thứ ba cho **Đá Huyền Thiết**. Bỏ vì nó **trùng**, không phải
vì nó yếu: vàng mua được đá ở shop, lại mua được cả lọ và Ankh. Thẻ đá là **tập
con** của thẻ vàng, kém đúng một thứ là linh hoạt — mà hai thẻ trùng nhau thì
không còn là lựa chọn.

Bỏ nó được thêm một thứ quan trọng hơn: cả ván chỉ còn **một** đường ra đá
(vàng → shop), nên **giá đá trong shop là núm duy nhất** điều nhịp Trang Bị.
Trước đó hai nguồn đá đánh nhau, chỉnh cái này là hỏng cái kia.
[ADR 0025](../05-quyet-dinh/0025-co-duyen-con-hai-the.md)

### Hai thẻ còn lại có song song không

Có — và đó là điểm chính, vì [ADR 0022](../05-quyet-dinh/0022-tien-thi-phang-suc-manh-thi-leo.md)
đã cho thấy hai đường khác độ dốc thì sớm muộn cũng cắt nhau.

```
the vang    60 vang tb -> 6 da (gia 10) -> 1.875 x 1.30^(r-1) diem
the chi so                                   2.2 x 1.30^(r-1) diem
```

**Cùng thừa số `1.30^(r-1)`** nên hai đường song song vĩnh viễn. Thẻ vàng phẳng
về *danh nghĩa*, nhưng thứ nó mua — bậc Trang Bị — thì leo, nên về *sức mạnh* nó
leo y hệt thẻ chỉ số. Cùng thủ thuật triệt tiêu thừa số của
[ADR 0020](../05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md).

Tỉ lệ đứng nguyên **1.17** ở mọi cảnh giới — thẻ chỉ số hơn 17%, đúng phần nó
xứng đáng: nó trả ngay, không qua xác suất, không qua trần Tu Vi.

## Thẻ sinh ở đâu, và vì sao chỗ đó

`GetRandomInt` của Warcraft **đã đồng bộ sẵn** giữa các máy, với điều kiện mỗi máy
gọi **cùng số lần, cùng thứ tự**. Gọi nó trong một nhánh `GetLocalPlayer()` là
mỗi máy tiêu một số khác nhau từ chuỗi ngẫu nhiên, và từ giây đó **mọi** số ngẫu
nhiên của cả ván đều lệch.

Nên thẻ được rút trong `addRolls()` — hàm đó chạy từ sự kiện quái chết, tức chạy
trên **mọi** máy. Mở bảng là UI thuần, **không sinh gì cả**.

Mỗi người rút **riêng**: ba người cùng thẻ giống nhau thì cả ba cùng chọn thẻ
tốt nhất, và hệ này không tạo ra khác biệt nào giữa ba hero. 140 lượt khác nhau
thì tích luỹ thành ba build khác nhau.

Chọn thẻ đi qua `API.syncSend(CFG.OP_FORTUNE, i)` như mọi hành động khác.

## Chỉ số từ quay đi qua đâu

`10_fortune.lua` **không** tự đặt chỉ số. Nó cộng vào `d.rollStats` rồi gọi
`heroRecompute` — hàm đó vẫn là **chỗ duy nhất** được ghi chỉ số hero. Đặt thẳng
là lần recompute sau xoá mất, đúng lỗi đã dính với giáp.

Cộng vào **nền** rồi mới nhân `%` của bị động Luyện Thể: một công thức duy nhất,
không phải nhớ thứ tự.
