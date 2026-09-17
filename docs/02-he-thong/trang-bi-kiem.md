# Trang Bị — Kiếm tiến hoá 100 bậc

> **Trạng thái:** Đã chốt luật — **chưa cài**, và chưa thể cài
> **Cập nhật:** 2026-09-17
> **Khoá CFG:** chưa có *(xem "Khoá sẽ cần" ở cuối)*
> **Thay cho:** `CFG.TRANGBI` sáu ô hiện đang `TRANGBI_LOCKED`

Một món duy nhất — **Kiếm** — leo **100 bậc**, và trần của nó là **Tu Vi của
chính người chơi**.

## Thang

```
20 canh gioi  x  5 cap  =  100 bac

  Kiem Pham Nhan - So Cap
  Kiem Pham Nhan - Trung Cap
  Kiem Pham Nhan - Cao Cap
  Kiem Pham Nhan - Thuong Cap
  Kiem Pham Nhan - Hoan Hao
  Kiem Luyen Khi - So Cap
  ...
  Kiem Sang The Than - Hoan Hao        <- bac 100
```

Tên cảnh giới lấy từ `CFG.REALMS` — **bảng đã có**, đã đủ hai thứ tiếng, và đang
được hệ đợt quái dùng. Năm tên cấp là một bảng mới, cùng hình dạng với
`CFG.TIER_NAMES` đang chạy.

Kiếm mặc định **không có chỉ số gì** cho tới khi mở khoá bậc 1.

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

Đó chính là lý do `TRANGBI_LOCKED` còn bật: sáu ô cũ cộng ×8.3 sát thương mà
không có gì chặn.

Kiếm bị khoá theo cảnh giới thì **phần vượt lên có cận trên, và cận đó bám đúng
biến mà quái cũng bám**. Kiếm không bao giờ vượt quá "một cảnh giới sức mạnh" ở
bất kỳ thời điểm nào.

Đây là an toàn **về cấu trúc**, không phải nhờ chọn số khéo — cùng loại an toàn
mà ADR 0020 đã đạt được một lần.

## Ngân sách đá

```
ky vong mot canh gioi   =  15 da
ca van (20 canh gioi)   = 300 da     <- NHU CAU

Co Duyen the 1  = 3 da x 140 luot  =  420 da    <- CUNG, neu LUON chon the 1
```

Cung hơi dư so với cầu, nhưng **không ai luôn chọn thẻ 1** — còn hai thẻ kia
tranh. Thực tế người chơi sẽ thiếu, và chỗ thiếu đó là việc của **Vàng**: shop
bán đá `25` vàng/viên.

> **`CFG.QUAY_DA` bám theo số món trang bị.** Quy tắc: `≈ 2.5 × số món`.
> Hiện một món → `3`. Thêm khiên → `5`. Đủ bốn món → `10`.
> **Thêm món mà quên sửa số này là hệ xác suất chết** — đá thừa thì bấm mãi cũng
> trúng.

## Hai trạng thái, và hệ chỉ vui khi qua lại giữa chúng

```
kiem DANG CHO tran    da du, leo het 5 cap, ngoi doi dot pha
                      -> TRAN chan.  Xac suat vo nghia.

kiem DANG DUOI tran   chua leo het, van con cap de danh bac
                      -> DA/MAY chan.  Tran vo nghia.
```

Đá quá rẻ → luôn dính trần → bấm rồi chờ. Đá quá đắt → luôn tụt sau → cái trần
chưa bao giờ có hiệu lực thật.

**Cả hai luật chỉ cùng có nghĩa ở dải giữa**, và `CFG.QUAY_DA` là nút chỉnh dải
đó. Đây là con số đáng đo nhất ở lần chơi thử đầu.

## Ba điều kỹ thuật phải làm đúng

**1. Tung xúc xắc phải nằm trong hàm nhận từ kênh đồng bộ**, không nằm ở chỗ bấm
nút. Bấm frame chỉ nổ trên máy người bấm; gọi `GetRandomInt` ở đó là mỗi máy
tiêu một số khác nhau từ chuỗi ngẫu nhiên, và **từ giây đó mọi số ngẫu nhiên của
cả ván đều lệch** — kể cả thẻ Cơ Duyên. Đúng bài học đầu
[10_quay.lua](../../src/2_nguoi_choi/10_quay.lua).

**2. Cấp kiếm là state trong `S.p[pid]`**, một số nguyên `0..100`. Không gắn vào
item, không gắn vào ability handle.

**3. Chỉ số phải đi qua vật mang**, không ghi thẳng lên unit. `BlzSetUnitArmor`
và `BlzSetUnitBaseDamage` đều đã bị gỡ khỏi `heroRecompute` vì chúng đóng băng
phần chỉ số — xem [ability-ban-sao.md](../03-du-lieu/ability-ban-sao.md).

## Không dùng item thật

Kiếm **không nằm trong túi đồ**. Quyết định này bỏ được cả loạt vấn đề:

| | |
|---|---|
| Đo mã trường `.w3t` | không cần |
| `BlzSetItemName` / `BlzSetItemIconPath` có tồn tại không | không cần biết |
| `Can Be Dropped`, `Droppable on Death` | không còn chuyện |
| Ném đồ đi, đưa cho đồng đội | không xảy ra được |
| Túi 6 ô, xung đột với Ankh 500 vàng | **biến mất** |

Đổi lại là mất **tính cầm nắm** — không nhìn thấy nó trong túi. Bù bằng ba thứ
đã có sẵn: tên đầy đủ hiện ở thẻ `focus`, `API.msg(nil, ...)` báo cho **cả ba
người** khi luyện thành cấp cao, và `API.fx` trên hero lúc thăng cấp.

Với một hệ có xác suất, việc cả đội nhìn thấy bạn trượt 15% lần thứ tư còn đáng
nhớ hơn một cái icon.

## Giao diện

Thẻ **III** đổi từ `kind = "list"` sang `kind = "focus"` — **cùng kiểu thân với
Tu Vi** ([ADR 0016](../05-quyet-dinh/0016-bang-phim-e-hai-kieu-than.md)).

Hai thang tiến hoá, hai thẻ focus, một cái khoá cái kia. Người chơi học một lần,
hiểu cả hai.

## Còn thiếu — và đây là thứ chặn việc cài

**Chỉ số mỗi cấp cho gì, bao nhiêu.** Chưa chốt, **hoãn có chủ ý**.

Ràng buộc đã biết khi thiết kế phần đó:

- Sức mạnh phải bám **cảnh giới**, không bám số bậc tuyệt đối — nếu không thì
  cái trần Tu Vi mất tác dụng bảo vệ.
- Một bậc ở cảnh giới 20 phải đáng hơn một bậc ở cảnh giới 1. Nhờ vậy thẻ 1 phẳng
  (3 đá) vẫn cân được với thẻ 2 leo ×180 — **đá phẳng, nhưng thứ đá mua được thì
  leo**.
- Cấp Hoàn Hảo ngốn 6.67 lần thử trong tổng 15 của cả cảnh giới, tức **gần một
  nửa ngân sách cho riêng một cấp**. Nó phải đáng.

### Khoá CFG sẽ cần

| Khoá | Ý nghĩa |
|---|---|
| `KIEM_CAP` | 5 tên cấp, `{ ten, en }` — cùng dạng `TIER_NAMES` |
| `KIEM_XS` | `{ 1.00, 0.75, 0.50, 0.25, 0.15 }` |
| `KIEM_GIA` | đá mỗi lần thử — `1` |
| `OP_KIEM` | opcode kênh đồng bộ |
| *(chỉ số)* | **chưa chốt** |
