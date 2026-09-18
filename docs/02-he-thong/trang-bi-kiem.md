# Trang Bị — tám món tiến hoá 100 bậc

> **Trạng thái:** **Đã cài** — khung, chỉ số và giao diện đều đã chạy
> **Cập nhật:** 2026-09-18
> **Khoá CFG:** `GEAR` `GEAR_CAP` `GEAR_ODDS` `GEAR_PRICE` `GEAR_DISMANTLE`
> `GEAR_STAT_BASE` `GEAR_DMG_MAX` `GEAR_MITIG_MAX` `GEAR_MITIG_CAP`
> `GEAR_LIFESTEAL_MAX` `GEAR_SLOTS` `GEAR_PET_SLOT` `GEAR_DOLL_COL`
> `GEAR_ICON_PATH` `GEAR_ICON_MAX` `OP_GEAR_UP` `OP_GEAR_DISMANTLE`
> **Mã:** [5_gear.lua](../../src/2_player/5_gear.lua) *(số liệu)* ·
> [1_panel.lua](../../src/4_ui/1_panel.lua) *(giao diện, `kind = "grid"`)*

**Tám món** — Mũ · Dây Chuyền · Áo Giáp · Kiếm · Khiên · Áo Choàng · Giày ·
Nhẫn — mỗi món leo **100 bậc**, và trần của tất cả là **Tu Vi của chính người
chơi**.

**Không món nào trùng vai món nào:**

| Món | Cộng gì | Loại | Ở bậc 100 |
|---|---|---|---|
| Mũ | Int | cộng điểm | +4 726 Int |
| Dây Chuyền | cả Str · Agi · Int | cộng điểm | +1 575 mỗi chỉ số |
| Áo Giáp | Str | cộng điểm | +4 726 Str |
| Giày | Agi | cộng điểm | +4 726 Agi |
| Kiếm | % sát thương **gây ra** *(đòn thường, phép, và hồi máu)* | nhân | +20% |
| Khiên | % **đòn đánh** nhận vào | nhân | −25% |
| Áo Choàng | % **sát thương phép** nhận vào | nhân | −25% |
| Nhẫn | % sát thương gây ra **hồi thành máu** | nhân | +20% |

Tám vai này thay bản cũ sáu món chỉ khác nhau **tên và icon** —
[ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md).

### Nhẫn nhân với Kiếm, không cộng

Kiếm cộng 20% sát thương, rồi Nhẫn hút 20% của **con số đã cộng**. Thứ tự đó
nằm trong `onDamaged`: khối hút máu đặt **sau** khối `gearDmgPct`. Đó là chỗ
hai món đi với nhau chứ không giẫm nhau.

Hút máu ăn ở **cả hai đường đánh** — đòn thường (`onDamaged`) và sát thương kỹ
năng (`hit`). Đường thứ hai dễ quên: `hit()` bật cờ `busy` làm `onDamaged`
thoát ngay dòng đầu, không gọi riêng thì hero đánh phép sẽ không hồi máu mà
chẳng có gì báo.

Và nó **không cứu được đòn chết ngay** — Chấn Địa của boss ăn 83% máu một phát.
Mạnh ở trận kéo dài, yếu ở đòn sấm sét: bù qua bù lại với Khiên/Áo Choàng.

## Thang

```
20 canh gioi  x  5 cap  =  100 bac / mon

  (0,0)  "Kiem"                       <- tho, chua luyen
    LUYEN Hoan Hao  ~15      MOT cu bam: quay 100/75/50/25/15
  (1,5)  "Kiem Pham Nhan - Hoan Hao"    cho toi khi Hoan Hao hoac het da
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

Tám món **không nằm trong túi đồ**. Quyết định này bỏ được cả loạt vấn đề:

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
 (LUYEN ~15) |        |  (LUYEN ~15)        Mu 3-2        +11 Int
             |  hinh  |                     Day Chuyen 1-5  +2.5
   [Ao]      |  bong  |   [Khien]           Ao 2-1        +9.4 Str
 (LUYEN ~15) |        |  ( TIEN GIAI )      Kiem 1-3      +0.6%
             |        |                     Khien --
   [Kiem]    +--------+   [AoChoang]        Ao Choang --
 (LUYEN ~15)              (LUYEN ~15)       Giay - So Cap   +1.5 Agi

             [Giay]
          (LUYEN ~15)
```

Hai nửa, **cùng một nguồn dữ liệu** (`tab.items`) nên không thể lệch nhau: lưới ô
bên trái, bảng thống kê bên phải.

**Bố cục ô là dữ liệu, không phải code.** `CFG.GEAR_SLOTS` cho mỗi món một cặp
`{cột, dòng}`; bảng đọc bảng đó rồi tự suy ra lưới mấy cột mấy dòng. Đổi chỗ hai
món là sửa một dòng CFG, không đụng `1_panel.lua`. Lệch số ô và số món thì
`API.trace` báo ngay lúc vào map, không để nó ve thiếu trong im lặng.

### Bố cục paper-doll

```
        c1              c2               c3
  h1   Mũ         +-------------+   Dây Chuyền      đầu · cổ
  h2   Áo Giáp    |  icon hero  |   Áo Choàng       thân trước · sau
  h3   Kiếm       |    Hart     |   Khiên           tay phải · tay trái
                  |   Kim Đan   |
  h4   Nhẫn       |   < Pet >   |   Giày            ngón tay · bạn · chân
                  +-------------+
```

**Mỗi hàng một cặp có nghĩa**, đối xứng qua thân người. Hàng 3 đắt nhất: Kiếm
với Khiên nằm đúng hai tay, không phải xếp cho đủ chỗ.

**Cột giữa là lý lịch nhân vật, không phải bóng người.** Mỗi ô đã có icon thật
rồi — bóng người chỉ nói lại điều icon đã nói. Đổi lại, cột giữa **trả lời một
câu hỏi có thật**: điều kiện Tiến Hoá là `cultRank ≥ tier + 1`, nên muốn biết
*"vì sao Khiên chưa lên cảnh giới được"* thì phải nhớ Tu Vi mình ở đâu — trước
đây phải đổi sang thẻ I để xem.

Icon lấy từ `CFG.HEROES` của chính người chơi đó. Cỡ `0.090` (162px @1080p) chứ
không lấp đầy cột: lấp đầy là phóng 3,9 lần từ 64px và nhìn ra bệt.

**Ô Pet** ở `{2,4}` — chỗ dành sẵn, chưa hệ nào dùng. Vẽ **y hệt một ô thật**
(cùng ô vuông cỡ icon, cùng phép tính vị trí) nhưng **không có nút**. Đó là khác
biệt duy nhất.

**Bảng không cao thêm.** Lưới 4 dòng = 0.288, thẻ Kỹ Năng 7 dòng = 0.336;
`bodyH()` lấy max cả ba kiểu nên khung giữ nguyên kích thước. Bảng phải cao bằng
nhau ở mọi thẻ, nếu không đổi thẻ một cái là khung nhảy.

**Một nút, hai việc:** chưa tới Hoàn Hảo thì nút là `LUYEN Hoan Hao  ~15`, tới
rồi thì thành `TIEN GIAI  10`.

**Ô tích ở giữa (khe nút của ô Pet)** đổi nhãn cả tám nút cùng lúc:
`[X] LUYEN GOP` → `LUYEN Hoan Hao  ~15`, `[ ] LUYEN LE` → `LUYEN  1`. Mặc định
bật. Nó là trạng thái UI **cục bộ**, không đồng bộ — xem
[ADR 0027](../05-quyet-dinh/0027-luyen-trang-bi-gop-mot-cu-bam.md). Quyết định gửi op nào là **cục bộ** nhưng an toàn, vì
trạng thái dựa vào đã đồng bộ sẵn — và cả hai nhánh đều **kiểm lại điều kiện ở
bên nhận**.

### Nút — ba trạng thái, nhìn ra được

| | Ruột | Viền | Chữ | Nhãn |
|---|---|---|---|---|
| bấm được | đen | mỏng `1×` | trắng | `LUYEN Hoan Hao  ~15` |
| thiếu đá | **đỏ sẫm** | mỏng `1×` | xám | `LUYEN Hoan Hao  ~15   (có 0)` |
| chưa tới lượt | **xám tối** | không viền | vàng nhạt | `CHỜ Kim Đan` |

**Màu nền là tín hiệu chính.** Bề dày viền là tín hiệu *tương đối* — phải có cả
hai trạng thái cạnh nhau mới đọc được, mà lúc hết đá thì **cả tám nút đều
thiếu**, chẳng còn gì để so. Màu nền đọc được một mình.

Viền từng là tín hiệu *chính* và để dày `3×`. Thêm màu ruột xong quên hạ nó
xuống, thành hai tín hiệu cùng hét: `3 × 0.0016 = 8,6 px` mỗi bên trên nút cao
47 px — ăn 37% chiều cao, nhìn ra cái khung vàng chứ không ra cái nút. Giờ viền
chỉ còn phân biệt **có** với **không**: `locked` phẳng hẳn.

Hai texture đó **tự sinh** bằng [`w3blp.py`](../../w3blp.py) (8×8, 647 byte mỗi
cái) — nguồn ở `docs/01-tmp/ui/`. Trước đây không làm được vì phải đoán đường
dẫn texture; giờ đường dẫn do mình đặt.

`(có 0)` trả lời câu màu sắc không nói được: **còn thiếu bao nhiêu**. Áp cho cả
ba thẻ — Tu Vi, Kỹ Năng, Trang Bị, qua cùng một hàm `applyBtn()`.

**Tách "thiếu tiền" khỏi "chưa tới lượt"** vì hai cái bảo người chơi làm hai
việc trái ngược: thiếu đá thì đi cày, chưa tới lượt thì đi đột phá Tu Vi. Trạng
thái "chưa tới lượt" **vẫn có nút** (khoá) chứ không bỏ trống — ô trống trông
như bảng hỏng.
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

## Icon — tự vẽ, không mượn nữa

Trước đây mọi đường dẫn icon đều là **phỏng đoán** chọi lại nội dung CASC không
liệt kê được. Đó là lý do có `BTNRingViolet`, `BTNStrength`, `BTNGoldmine`, và
một cây trượng đội lốt cái mũ.

Giờ icon **do mình vẽ**, nên đường dẫn biết chắc theo cách dựng:

```
docs/01-tmp/<thư mục>/NN-*.png          ảnh nguồn
        │  python w3gear_icons.py
        ▼
test2.w3x/gear/<key>/NN.blp             trong map
        │  war3map.imp  (script tự ghi)
        ▼
CFG.GEAR_ICON_PATH = [[gear\%s\%02d.blp]]
```

`<key>` là trường `key` của từng món — **tiếng Anh**, vì nó thành đường dẫn thật
(`helm` `necklace` `armor` `sword` `shield` `cloak` `boots` `ring`).
`NN` là số **cảnh giới** 1–20, khớp `CFG.REALMS`.

**Thêm cảnh giới không phải sửa code:** thả ảnh vào `docs/01-tmp/<thư mục>/`,
chạy `python w3gear_icons.py`, nâng `CFG.GEAR_ICON_MAX`. Không một dòng Lua nào
đổi.

Icon đổi **theo cảnh giới món đó đang ở**. Chưa vẽ tới cảnh giới cao thì dùng
ảnh cao nhất đã có — món ở cảnh giới 7 mà mới vẽ tới 3 vẫn hiện ảnh 3, không bị
trống. Thiếu cả bảng đường dẫn thì lui về icon dò từ item thật lúc vào map.

Công cụ: [`w3blp.py`](../../w3blp.py) — đổi ảnh sang BLP1, và `check` để giải mã
ngược so với ảnh gốc. Định dạng **đo được từ chính file `.blp` trong map này**,
không tra tài liệu ngoài.

### Ngân sách đá — **chưa cân**

Tám món, mỗi món 20 cảnh giới:

```
1 mon  = 20 x (15 lan luyen + 10 Tien Giai)  =   500 da
8 mon                                        = 4,000 da
Co Duyen the 1 (FORTUNE_IRON = 3) ca van     =   420 da
```

Thiếu **~9,5 lần**. Chủ dự án đã biết và **để sau** — nguồn đá sẽ bổ sung. Ghi
ra đây để lúc cân không phải tính lại.
