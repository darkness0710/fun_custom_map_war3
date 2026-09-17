# Trang Bị — sáu món tiến hoá 100 bậc

> **Trạng thái:** **Đã cài** — khung chạy đủ, **chỉ số còn rỗng**
> **Cập nhật:** 2026-09-17
> **Khoá CFG:** `TRANGBI` `TRANGBI_CAP` `TRANGBI_XS` `TRANGBI_GIA`
> `TRANGBI_TIEN_GIAI` `OP_TB_UP` `OP_TB_TIEN`
> **Mã:** [5_trangbi.lua](../../src/2_nguoi_choi/5_trangbi.lua)

**Sáu món** — Kiếm · Giáp · Khiên · Giày · Dây Chuyền · Nhẫn — mỗi món leo
**100 bậc**, và trần của tất cả là **Tu Vi của chính người chơi**.

> **Chỉ số còn rỗng có chủ ý.** Khung tiến hoá chạy đầy đủ (tên, cấp, xác
> suất, Tiến Giai, trần Tu Vi) nhưng **chưa món nào cộng gì cả**. Chỗ chỉ số
> sẽ nằm là `API.trangBiMult` / `API.trangBiChiSo`, hiện trả về `1.0` và `0`.

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

**Cả hai luật chỉ cùng có nghĩa ở dải giữa**, và `CFG.QUAY_DA` là nút chỉnh dải
đó. Đây là con số đáng đo nhất ở lần chơi thử đầu.

## Ba điều kỹ thuật phải làm đúng

**1. Tung xúc xắc phải nằm trong hàm nhận từ kênh đồng bộ**, không nằm ở chỗ bấm
nút. Bấm frame chỉ nổ trên máy người bấm; gọi `GetRandomInt` ở đó là mỗi máy
tiêu một số khác nhau từ chuỗi ngẫu nhiên, và **từ giây đó mọi số ngẫu nhiên của
cả ván đều lệch** — kể cả thẻ Cơ Duyên. Đúng bài học đầu
[10_quay.lua](../../src/2_nguoi_choi/10_quay.lua).

**2. Cấp là state trong `S.p[pid]`** — `d.tb[i] = { canh = 0..20, cap = 0..5 }`.
Không gắn vào item, không gắn vào ability handle. `canh = 0` nghĩa là chưa luyện
lần nào.

**3. Chỉ số phải đi qua vật mang**, không ghi thẳng lên unit. `BlzSetUnitArmor`
và `BlzSetUnitBaseDamage` đều đã bị gỡ khỏi `heroRecompute` vì chúng đóng băng
phần chỉ số — xem [ability-ban-sao.md](../03-du-lieu/ability-ban-sao.md).

## Không dùng item thật

Sáu món **không nằm trong túi đồ**. Quyết định này bỏ được cả loạt vấn đề:

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

Thẻ **III**, `kind = "list"` — **một dòng mỗi món**, sáu dòng
([ADR 0016](../05-quyet-dinh/0016-bang-phim-e-hai-kieu-than.md)). Bản thiết kế
đầu định dùng `kind = "focus"` như Tu Vi; đổi vì focus chỉ hiện **một** thứ, mà
đây có sáu món phải so với nhau.

**Một nút, hai việc:** chưa tới Hoàn Hảo thì nút là `LUYEN  1`, tới rồi thì
thành `TIEN GIAI  10`. Quyết định gửi op nào là **cục bộ** nhưng an toàn, vì
trạng thái dựa vào đã đồng bộ sẵn — và cả hai nhánh đều **kiểm lại điều kiện ở
bên nhận**.

Khi Hoàn Hảo mà Tu Vi chưa tới, dòng đó **không có nút** nhưng nói rõ *"Tu Vi
chưa tới Luyện Khí"*. Không có nút mà không giải thích thì người chơi tưởng giao
diện hỏng.

## Còn thiếu — chỉ số

**Mỗi cấp cho gì, bao nhiêu.** Chưa chốt, **hoãn có chủ ý**. Khung đã chạy nên
nó không còn chặn gì; chỗ điền là hai hàm `multOf` / `chiSoOf` trong
[5_trangbi.lua](../../src/2_nguoi_choi/5_trangbi.lua), đang trả về `1.0` và `0`.

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
| `TRANGBI` | 6 món `{ ten, en, icon }` |
| `TRANGBI_CAP` | 5 tên cấp — cùng dạng `TIER_NAMES` |
| `TRANGBI_XS` | `{ 1.00, 0.75, 0.50, 0.25, 0.15 }` |
| `TRANGBI_GIA` | `1` đá mỗi lần luyện |
| `TRANGBI_TIEN_GIAI` | `10` đá |
| `OP_TB_UP` `OP_TB_TIEN` | `7` `12` |

> **Icon Khiên đang mượn tạm của Talisman.** Trong sáu đường dẫn đã chứng minh
> vẽ ra hình thì không có cái nào là khiên, mà đoán một đường dẫn sai thì ra ô
> **xanh lá** (lỗi `BTNRingViolet` đã dính). Sửa bằng cách mở World Editor →
> Object Editor → một item bất kỳ → `Art - Icon`, chép đường dẫn thật vào
> `CFG.TRANGBI`.

### Ngân sách đá — **chưa cân**

Sáu món, mỗi món 20 cảnh giới:

```
1 mon  = 20 x (15 lan luyen + 10 Tien Giai)  =  500 da
6 mon                                        = 3,000 da
Co Duyen the 1 (QUAY_DA = 3) ca van          =   420 da
```

Thiếu **~7 lần**. Chủ dự án đã biết và **để sau** — nguồn đá sẽ bổ sung. Ghi
ra đây để lúc cân không phải tính lại.
