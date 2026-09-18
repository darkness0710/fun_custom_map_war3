# Trang Bị — bảy món tiến hoá 100 bậc

> **Trạng thái:** **Đã cài** — khung, chỉ số và giao diện đều đã chạy
> **Cập nhật:** 2026-09-18
> **Khoá CFG:** `GEAR` `GEAR_CAP` `GEAR_ODDS` `GEAR_PRICE` `GEAR_DISMANTLE`
> `GEAR_STAT_BASE` `GEAR_DMG_MAX` `GEAR_MITIG_MAX` `GEAR_MITIG_CAP`
> `GEAR_SLOTS` `GEAR_SILHOUETTE` `OP_GEAR_UP` `OP_GEAR_DISMANTLE`
> **Mã:** [5_gear.lua](../../src/2_player/5_gear.lua) *(số liệu)* ·
> [1_panel.lua](../../src/4_ui/1_panel.lua) *(giao diện, `kind = "grid"`)*

**Bảy món** — Mũ · Dây Chuyền · Áo · Kiếm · Khiên · Nhẫn · Giày — mỗi món leo
**100 bậc**, và trần của tất cả là **Tu Vi của chính người chơi**.

**Không món nào trùng vai món nào:**

| Món | Cộng gì | Loại | Ở bậc 100 |
|---|---|---|---|
| Mũ | Int | cộng điểm | +4 726 Int |
| Dây Chuyền | cả Str · Agi · Int | cộng điểm | +1 575 mỗi chỉ số |
| Áo | Str | cộng điểm | +4 726 Str |
| Giày | Agi | cộng điểm | +4 726 Agi |
| Kiếm | % sát thương **gây ra** *(đòn thường, phép, và hồi máu)* | nhân | +20% |
| Khiên | % **đòn đánh** nhận vào | nhân | −25% |
| Nhẫn | % **sát thương phép** nhận vào | nhân | −25% |

Bảy vai này thay bản cũ sáu món chỉ khác nhau **tên và icon** —
[ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md).

## Thang

```
20 canh gioi  x  5 cap  =  100 bac / mon

  (0,0)  "Kiem"                       <- tho, chua luyen
    LUYEN  1 da, 100%
  (1,1)  "Kiem Pham Nhan - So Cap"
    LUYEN  1 da, 75% / 50% / 25% / 15%
  (1,5)  "Kiem Pham Nhan - Hoan Hao"
    TIEN GIAI  10 da, 100%, doi Tu Vi >= canh gioi 2
  (2,1)  "Kiem Luyen Khi - So Cap"
    ...
  (20,5) "Kiem Sang The Than - Hoan Hao"    <- het
```

Tên cảnh giới lấy từ `CFG.REALMS` — **bảng đã có**, đã đủ hai thứ tiếng, và đang
được hệ đợt quái dùng. Năm tên cấp là một bảng mới, cùng hình dạng với
`CFG.TIER_NAMES` đang chạy.

Món mặc định **không có chỉ số gì** cho tới khi luyện lần đầu.

## Tiến Giai

Tới **Hoàn Hảo** thì không luyện tiếp được; phải **Tiến Giai** để sang cảnh
giới sau. Tốn **10 đá**, và **chắc chắn 100%** — nó là một **cửa**, không phải
một canh bạc chồng lên canh bạc.

Tiến Giai đưa thẳng tới **Sơ Cấp** của cảnh giới mới: gói luôn lần lên Sơ Cấp
(vốn 100%) vào đó, để không có một cú bấm chắc chắn thừa.

**Điều kiện:** Tu Vi của người chơi phải **đã tới** cảnh giới đích. Đây là chỗ
duy nhất cái trần thực sự có hiệu lực — và khi chưa đủ, thẻ nói rõ *"Tu Vi
chưa tới Luyện Khí"* thay vì chỉ ẩn nút đi.

## Bốn luật, và cả bốn đều đã chốt

**1. Mỗi lần thử tốn 1 Đá Huyền Thiết.** Phẳng, mọi bậc như nhau.

**2. Xác suất giảm dần trong mỗi cảnh giới:**

| Lên cấp | Xác suất | Kỳ vọng số lần thử |
|---|---|---|
| → Sơ Cấp | **100%** | 1.00 |
| → Trung Cấp | **75%** | 1.33 |
| → Cao Cấp | **50%** | 2.00 |
| → Thượng Cấp | **25%** | 4.00 |
| → Hoàn Hảo | **15%** | 6.67 |
| | | **15.0 / cảnh giới** |
| **Tiến Giai** | **100%** | 10 đá |

**3. Không bỏ bậc.** Phải đi qua đủ 5 cấp của cảnh giới này mới sang cảnh giới
sau. Tu Vi **chỉ là trần**, không phải đường tắt.

**4. Đột phá Tu Vi không đụng vào kiếm.** Nó chỉ **nới trần**. Kiếm đang ở
Phàm Nhân – Thượng Cấp thì vẫn ở đó, rồi leo tiếp Hoàn Hảo → Luyện Khí – Sơ Cấp.
**Không có gì mất đi bao giờ.**

**Thất bại không mất gì** ngoài viên đá đã tiêu. Không tụt cấp, không vỡ kiếm.

## Vì sao cái trần Tu Vi là ý quan trọng nhất ở đây

Từ [ADR 0020](../05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md), máu quái
**định nghĩa bằng** hệ số Tu Vi. Tu Vi triệt tiêu với quái; **mọi nguồn khác là
phần vượt lên thuần, và phần vượt lên đó không có cận trên**.

Đó chính là lý do hệ sáu ô cũ phải khoá: nó cộng ×8.3 sát thương mà không có gì
chặn.

Khoá theo cảnh giới thì **phần vượt lên có cận trên, và cận đó bám đúng biến mà
quái cũng bám**. Món đồ không bao giờ vượt quá "một cảnh giới sức mạnh" ở bất
kỳ thời điểm nào.

Đây là an toàn **về cấu trúc**, không phải nhờ chọn số khéo — cùng loại an toàn
mà ADR 0020 đã đạt được một lần.

## Hai trạng thái, và hệ chỉ vui khi qua lại giữa chúng

```
kiem DANG CHO tran    da du, leo het 5 cap, ngoi doi dot pha
                      -> TRAN chan.  Xac suat vo nghia.

kiem DANG DUOI tran   chua leo het, van con cap de danh bac
                      -> DA/MAY chan.  Tran vo nghia.
```

Đá quá rẻ → luôn dính trần → bấm rồi chờ. Đá quá đắt → luôn tụt sau → cái trần
chưa bao giờ có hiệu lực thật.

**Cả hai luật chỉ cùng có nghĩa ở dải giữa**, và **giá đá trong shop** là nút
chỉnh dải đó — kể từ khi thẻ đá bị bỏ khỏi Cơ Duyên
([ADR 0025](../05-quyet-dinh/0025-co-duyen-con-hai-the.md)), vàng là đường ra đá
duy nhất, nên một con số điều được cả nhịp. Đây là số đáng đo nhất ở lần chơi
thử đầu.

## Ba điều kỹ thuật phải làm đúng

**1. Tung xúc xắc phải nằm trong hàm nhận từ kênh đồng bộ**, không nằm ở chỗ bấm
nút. Bấm frame chỉ nổ trên máy người bấm; gọi `GetRandomInt` ở đó là mỗi máy
tiêu một số khác nhau từ chuỗi ngẫu nhiên, và **từ giây đó mọi số ngẫu nhiên của
cả ván đều lệch** — kể cả thẻ Cơ Duyên. Đúng bài học đầu
[10_fortune.lua](../../src/2_player/10_fortune.lua).

**2. Cấp là state trong `S.p[pid]`** — `d.gear[i] = { tier = 0..20, level = 0..5 }`.
Không gắn vào item, không gắn vào ability handle. `tier = 0` nghĩa là chưa luyện
lần nào.

**3. Không ghi thẳng giáp hay sát thương lên unit.** `BlzSetUnitArmor` và
`BlzSetUnitBaseDamage` đều đã bị gỡ khỏi `heroRecompute` vì chúng đóng băng phần
chỉ số — xem [ability-ban-sao.md](../03-du-lieu/ability-ban-sao.md).

Đó là lý do ba món "nhân" cộng **%** chứ không cộng điểm: % nhân được ngay trong
`onDamaged` và `skillDamage`, **không cần vật mang nào cả**. Bản thiết kế trước
định cho Khiên cộng điểm giáp và phải mượn trường của một ability — bỏ, vì đo ra
Khiên chỉ được cộng **2.8 điểm giáp cả ván** mới vừa ngân sách, tức 0.03 mỗi bậc,
một con số không hiển thị nổi.

## Không dùng item thật

Bảy món **không nằm trong túi đồ**. Quyết định này bỏ được cả loạt vấn đề:

| | |
|---|---|
| Đo mã trường `.w3t` | không cần |
| `BlzSetItemName` / `BlzSetItemIconPath` có tồn tại không | không cần biết |
| `Can Be Dropped`, `Droppable on Death` | không còn chuyện |
| Ném đồ đi, đưa cho đồng đội | không xảy ra được |
| Túi 6 ô, xung đột với Ankh 500 vàng | **biến mất** |

Đổi lại là mất **tính cầm nắm** — không nhìn thấy nó trong túi. Bù bằng ba thứ
đã có sẵn: lưới ô hình nhân vật ở thẻ III, `API.msg(nil, ...)` báo cho **cả ba
người** khi luyện thành cấp cao, và `API.fx` trên hero lúc thăng cấp.

Với một hệ có xác suất, việc cả đội nhìn thấy bạn trượt 15% lần thứ tư còn đáng
nhớ hơn một cái icon.

## Giao diện — kiểu thân bảng thứ ba

Thẻ **III**, `kind = "grid"`. Đây là kiểu thân thứ ba của bảng phím E, thêm vào
`"list"` và `"focus"` của
[ADR 0016](../05-quyet-dinh/0016-bang-phim-e-hai-kieu-than.md).

```
   [Mu]      +--------+   [Day Chuyen]      Dang cong
 ( LUYEN )   |        |   ( LUYEN )         Mu 3-2        +11 Int
             |  hinh  |                     Day Chuyen 1-5  +2.5
   [Ao]      |  bong  |   [Khien]           Ao 2-1        +9.4 Str
 ( LUYEN )   |        |   ( TIEN GIAI )     Kiem 1-3      +0.6%
             |        |                     Khien --
   [Kiem]    +--------+   [Nhan]            Nhan --
 ( LUYEN )                ( LUYEN )         Giay 1-1      +1.5 Agi

             [Giay]
           ( LUYEN )
```

Hai nửa, **cùng một nguồn dữ liệu** (`tab.items`) nên không thể lệch nhau: lưới ô
bên trái, bảng thống kê bên phải.

**Bố cục ô là dữ liệu, không phải code.** `CFG.GEAR_SLOTS` cho mỗi món một cặp
`{cột, dòng}`; bảng đọc bảng đó rồi tự suy ra lưới mấy cột mấy dòng. Đổi chỗ hai
món là sửa một dòng CFG, không đụng `1_panel.lua`. Lệch số ô và số món thì
`API.trace` báo ngay lúc vào map, không để nó ve thiếu trong im lặng.

**Cột giữa để trống cho hình bóng người.** `CFG.GEAR_SILHOUETTE = nil` nên hiện
vẽ ô màu nền. Có file `.blp` thì import bằng
[w3import.py](../../w3import.py) rồi điền đường dẫn vào đúng khoá đó — gõ một
đường dẫn **chưa import** sẽ ra ô **xanh lá**, không phải ô trống.

**Bảng không cao thêm.** Lưới 4 dòng = 0.288, thẻ Kỹ Năng 7 dòng = 0.336;
`bodyH()` lấy max cả ba kiểu nên khung giữ nguyên kích thước. Bảng phải cao bằng
nhau ở mọi thẻ, nếu không đổi thẻ một cái là khung nhảy.

**Một nút, hai việc:** chưa tới Hoàn Hảo thì nút là `LUYEN  1`, tới rồi thì
thành `TIEN GIAI  10`. Quyết định gửi op nào là **cục bộ** nhưng an toàn, vì
trạng thái dựa vào đã đồng bộ sẵn — và cả hai nhánh đều **kiểm lại điều kiện ở
bên nhận**.

Khi Hoàn Hảo mà Tu Vi chưa tới, ô đó **không có nút** — và đúng chỗ nút vẫn có
một dòng chữ xám *"CHỜ TU VI"*; món đã đi hết 100 bậc thì ghi *"TRỌN VẸN"*.
Không có nút mà không giải thích thì người chơi tưởng giao diện hỏng.

Nút và dòng chữ dùng **chung một chỗ**, bật cái này là tắt cái kia — bật cả hai
là chúng đè lên nhau.

## Còn thiếu — chỉ số

**Mỗi cấp cho gì, bao nhiêu.** Chưa chốt, **hoãn có chủ ý**. Khung đã chạy nên
nó không còn chặn gì; chỗ điền là hai hàm `multOf` / `statOf` trong
[5_gear.lua](../../src/2_player/5_gear.lua), đang trả về `1.0` và `0`.

Ràng buộc đã biết khi thiết kế phần đó:

- Sức mạnh phải bám **cảnh giới**, không bám số bậc tuyệt đối — nếu không thì
  cái trần Tu Vi mất tác dụng bảo vệ.
- Một cấp ở cảnh giới 20 phải đáng hơn một cấp ở cảnh giới 1. Nhờ vậy thẻ 1 phẳng
  (3 đá) vẫn cân được với thẻ 2 leo ×180 — **đá phẳng, nhưng thứ đá mua được thì
  leo** ([ADR 0022](../05-quyet-dinh/0022-tien-thi-phang-suc-manh-thi-leo.md)).
- Cấp Hoàn Hảo ngốn 6.67 lần thử trong tổng 15 của cả cảnh giới, tức **gần một
  nửa ngân sách cho riêng một cấp**. Nó phải đáng.

### Khoá CFG — đã có

| Khoá | Giá trị |
|---|---|
| `GEAR` | 6 món `{ ten, en, icon }` |
| `GEAR_CAP` | 5 tên cấp — cùng dạng `TIER_NAMES` |
| `GEAR_ODDS` | `{ 1.00, 0.75, 0.50, 0.25, 0.15 }` |
| `GEAR_PRICE` | `1` đá mỗi lần luyện |
| `GEAR_DISMANTLE` | `10` đá |
| `OP_GEAR_UP` `OP_GEAR_DISMANTLE` | `7` `12` |

> **Icon Khiên đang mượn tạm của Talisman.** Trong sáu đường dẫn đã chứng minh
> vẽ ra hình thì không có cái nào là khiên, mà đoán một đường dẫn sai thì ra ô
> **xanh lá** (lỗi `BTNRingViolet` đã dính). Sửa bằng cách mở World Editor →
> Object Editor → một item bất kỳ → `Art - Icon`, chép đường dẫn thật vào
> `CFG.GEAR`.

### Ngân sách đá — **chưa cân**

Sáu món, mỗi món 20 cảnh giới:

```
1 mon  = 20 x (15 lan luyen + 10 Tien Giai)  =  500 da
6 mon                                        = 3,000 da
Co Duyen the 1 (FORTUNE_IRON = 3) ca van          =   420 da
```

Thiếu **~7 lần**. Chủ dự án đã biết và **để sau** — nguồn đá sẽ bổ sung. Ghi
ra đây để lúc cân không phải tính lại.
