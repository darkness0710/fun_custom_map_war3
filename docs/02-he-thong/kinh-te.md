# Kinh tế & bốn hệ nâng cấp

> ## Viết lại toàn bộ — 2026-09-16
>
> Bản trước: ba đồng tiền *(Linh Khí, Ngộ Tính, Tinh Thạch)*, thu nhập là đường
> cong mũ `60 × 1.0319^(stage−1)` cho tổng `1,880,187` Linh Khí. Bỏ hết.
>
> **Thu nhập giờ phẳng — một con một đồng:**
>
> | Loại quái | Rơi ra | Số con cả ván | Tổng |
> |---|---|---|---|
> | lính thường | 1 Linh Khí + 1 Vàng | 4,000 | 4,000 LK + 4,000 vàng |
> | tinh anh | **50 Linh Khí** + 2 Gỗ | 80 | 4,000 LK + 160 Gỗ |
> | boss | **100 Linh Khí** + 5 Gỗ | 20 | 2,000 LK + 100 Gỗ |
>
> **Số Linh Khí chọn để một cảnh giới kiếm đúng một lần đột phá:**
>
> ```
> 1 wave      = 50 quái ×1 + 1 tinh anh ×50 = 100
> 1 cảnh giới = 4 wave (400) + boss (100)   = 500
> 1 đột phá                                 = 500   <- phẳng
> ```
>
> Dọn sạch một cảnh giới = lên được một bậc, không hơn không kém. Người chơi
> không phải tính gì: hết cảnh giới thì bấm đột phá.
>
> **Ba đồng tiền, ba hệ, ba nhịp:**
>
> | Tiền | Ở đâu | Nhịp | Tiêu vào | Ngân sách |
> |---|---|---|---|---|
> | **Linh Khí** | biến riêng, hiện ở bảng | cảnh giới | Tu Vi | 9,500 / 10,000 = **95%** |
> | **Vàng** | thanh tài nguyên | giây | Shop | 4,000 |
> | **Gỗ** | thanh tài nguyên | wave / cảnh giới | Kỹ Năng | 70 / 260 |
>
> Linh Khí rời thanh tài nguyên vì thanh đó chỉ có **hai** ô mà giờ có **ba**
> đồng tiền. Vàng và Gỗ được ưu tiên vì chúng là thứ tiêu liên tục; Linh Khí
> chỉ tiêu ở đúng một chỗ nên nằm trong bảng là đủ.
>
> **Hai hệ tạm khoá:** Trang Bị *(`TRANGBI_LOCKED`)* hiện đủ sáu ô ghi `0/0`
> không có nút; Pháp Khí *(`PHAPKHI_LOCKED`)* hiện dòng "tạm khoá". Hiện thẻ đầy
> đủ rồi khoá thì người chơi biết hệ đó tồn tại và đang đóng — để thẻ trống thì
> họ tưởng giao diện hỏng.
>
> **Tinh Thạch xoá hẳn.** Sau khi Pháp Khí khoá thì không hệ nào tiêu nó, mà một
> con số chỉ tăng chứ không bao giờ dùng được thì tệ hơn là không có.
>
> Giá suy ngược từ thu nhập phẳng:
> - **Tu Vi** **phẳng 500 mỗi lần**, 19 lần = `9,500`. Số cũ `439 × 1.412` cho
>   tổng `747,839` — tính cho thu nhập mũ, với thu nhập phẳng thì bậc cuối
>   `218,519` là không bao giờ với tới.
> - **Kỹ Năng** `3` Gỗ mỗi lần *(mở khoá và đôn bậc như nhau)*, trọn bảy =
>   `210`. Giá `1` thì chỉ tốn `70/300`: max hết quanh wave 70 rồi 150 wave sau
>   Gỗ thành vô nghĩa.
> - **Shop** lọ máu `40`, lọ mana `30` vàng. Thu 50 vàng/wave nên giá đặt quanh
>   mức **một lọ một wave** — mỗi wave là một lựa chọn nhỏ thay vì một phép cộng
>   dồn.


> **Trạng thái:** Đã cài — **chưa chơi thử**
> **Cập nhật:** 2026-09-16
> **Code:** [1_player.lua](../../src/2_nguoi_choi/1_player.lua) (ví tiền),
> [2_wave.lua](../../src/3_tran_dau/2_wave.lua) (thu nhập),
> [3_linhcan.lua](../../src/2_nguoi_choi/3_linhcan.lua),
> [4_skill.lua](../../src/2_nguoi_choi/4_skill.lua),
> [5_trangbi.lua](../../src/2_nguoi_choi/5_trangbi.lua),
> [6_phapkhi.lua](../../src/2_nguoi_choi/6_phapkhi.lua) (chỗ tiêu)

> **Ba hệ chạy, một hệ rỗng.** Pháp Khí đã bị xoá sạch nội dung (2026-09-16) và
> sẽ thiết kế lại để tiêu **Ngộ Tính**, không tiêu Tinh Thạch.
>
> ⚠ **Hai hệ quả phải biết:**
>
> **1. Ngân sách sức mạnh tụt còn ×392 trên ×967.** Pháp Khí gánh ×2.5; bỏ nó ra
> thì `19.7 × 8.3 × 2.4 = 392`, tức **41%** mức hợp đồng. 230 điểm Ngộ Tính dư
> phải trả lại chỗ đó khi thiết kế lại.
>
> **2. Tinh Thạch không còn chỗ tiêu nào.** Boss vẫn rơi 1 150 điểm cả ván, nhưng
> không mua được gì — một đồng tiền chỉ vào không ra. Xem mục cuối trang.
> **Xem kèm:** [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) ·
> [bang-nhan-vat.md](bang-nhan-vat.md) · [dot-quai.md](dot-quai.md)

Trang này trả lời câu hỏi mà
[duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) để ngỏ: **×967 sức
mạnh người chơi đến từ đâu, và mua bằng gì.**


## Thẻ VI — Quay thưởng

Nguồn thứ hai của **Vàng** và nguồn duy nhất của **Đá Huyền Thiết**. Chi tiết ở
[quay-thuong.md](quay-thuong.md).

| | |
|---|---|
| Lượt | tinh anh 1, boss 3 → 7/cảnh giới, 140 cả ván |
| Vàng từ quay | cảnh giới 1: 185 *(quái cho 200)*; cảnh giới 20: 27,016 |
| Đá | 10/lượt phẳng, cả ván tối đa 1,400 |

Vàng từ quay **bám theo bậc**, vàng từ quái thì **phẳng** — nên nửa sau ván quay
áp đảo. Thêm món vào shop thì giá phải leo theo bậc.

## Thẻ V — Shop

Hệ **duy nhất** tiêu Vàng, và hệ duy nhất bán đồ **tiêu hao**. Ba thẻ kia bán thứ
vĩnh viễn; thẻ này bán một lần dùng.

| Món | Giá | Item gốc |
|---|---|---|
| Lọ hồi máu | 10 vàng | `phea` |
| Lọ hồi mana | 10 vàng | `pman` |
| Ankh hồi sinh | 500 vàng | `ankh` |

**Gộp lượt vào một ô**, tối đa `CFG.SHOP_STACK_MAX = 10`. Gộp **bằng tay** chứ
không trông chờ Warcraft tự gộp: tự gộp hay không là thuộc tính của từng item
trong Object Editor, mà đây là item có sẵn của game nên ta không nắm quyền đó.

**Đã đo trong game (2026-09-17): gộp 10 lượt vào một ô, dùng một lần trừ đúng
một lượt.** Lọ mượn của game (`phea`/`pman`) vẫn tôn trọng số lượt ta nạp, nên
không cần tự tạo item riêng.

Mã item và icon **đo lúc vào map**: `startShop()` tạo thử từng món rồi xoá.
`CreateItem` trả `nil` là báo đỏ ngay, không đợi tới lúc ai đó bỏ 500 vàng ra mới
biết. Icon đọc được thì ghi đè lên đường dẫn trong config.

`UnitAddItemById` trên unit **không có túi** vẫn trả về handle — nó thả item
xuống **đất**. Nên `conCho()` coi `UnitInventorySize() <= 0` là **không có chỗ**;
bản trước cho qua, và hậu quả là "phát 10/10 thành công" trong khi cả 20 lọ nằm
dưới sàn.

## Quà khởi đầu

Phát **sau khi pick xong hero**, không phải lúc vào map — quà là của hero, mà lúc
vào map hero chưa tồn tại nên không có túi nào để bỏ vào. Chỉ phát cho lần pick
**đầu tiên**; đổi hero mà phát lại là một đường nhận quà vô hạn.

`CFG.GO_START = 1` + `CFG.START_ITEMS` (10 lọ mỗi loại). Danh sách quà dùng chung
mã với `CFG.SHOP`, không gõ lại mã item — hai chỗ cùng tạo một thứ thì sớm muộn
cũng lệch.

## Dùng đồ bằng hàng số trên

Warcraft chỉ gán sẵn túi đồ vào numpad. `CFG.ITEM_KEYS = { "1".."6" }` gán **thêm**
hàng số cạnh Esc; numpad vẫn chạy như cũ.

Phím **phải đi qua kênh đồng bộ**: sự kiện phím là đầu vào **cục bộ**, chỉ nổ trên
máy người bấm. Bảng nhân vật gọi `hide/toggle` thẳng được vì đó chỉ là bật/tắt
khung hình; `UnitUseItem` thì đổi trạng thái ván đấu, gọi thẳng là lệch bàn game.

> Đánh đổi biết trước: hàng số trên cũng là phím gọi **nhóm quân**. Bấm `1` vừa
> gọi nhóm 1 vừa dùng đồ ô 1. Đặt `nil` để tắt.

## Ba đồng tiền, ba loại quái, ba nhịp

[ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md)

| | Rơi từ | Cả ván | Mua gì | Nhịp | Hiện ở |
|---|---|---|---|---|---|
| **Linh Khí** *(vàng)* | lính thường | ~1 880 000 | Tu Vi, Trang Bị | giây | thanh vàng |
| **Ngộ Tính** | **tinh anh + boss** | 300 | **Kỹ Năng · Pháp Khí** | wave | bảng phím R |
| **Tinh Thạch** *(gỗ)* | boss | 1 150 | ⚠ **không gì cả** | cảnh giới | thanh gỗ |

Ba loại quái đã có sẵn ba **nhịp** khác hẳn nhau — 11 000 con lính, 200 tinh anh,
20 boss. Gắn mỗi đồng tiền vào một nhịp thì mỗi hệ nâng cấp trả lời được bằng
**một câu**:

| Hệ | Cần gì để nâng |
|---|---|
| Tu Vi | *giết quái, gom tiền* |
| Trang Bị | *giết quái, gom tiền* |
| Kỹ Năng | *giết tinh anh và boss* |
| Pháp Khí | *giết tinh anh và boss* — cùng ví với Kỹ Năng |

**Tu Vi và Trang Bị cố ý dùng chung ví.** Đó là lựa chọn chính của mỗi wave:
đột phá, hay nâng đồ? Hai hệ kia không tranh ví đó — chúng bị chặn bởi **nội
dung** chứ không bởi tiền, nên không cày tiền để bỏ qua được.

### Ngộ Tính là điểm, và giá là MỘT điểm

Không đường cong mũ, không bảng giá. **Mỗi lần trả đúng 1 điểm** — mở khoá một kỹ
năng: 1 điểm; nâng một bậc: 1 điểm.

| | Điểm |
|---|---|
| Kiếm cả ván | 200 tinh anh × 1 + 20 boss × 5 = **300** |
| Mở và max trọn 7 kỹ năng | 7 × (1 + 9) = **70** |
| **Dư cho Pháp Khí** | **230** |

Giá phẳng nên người chơi **không phải tính toán gì cả** — chỉ phải chọn **thứ
tự**: mở cái nào trước, dồn bậc cái nào.

> **Bảy kỹ năng max xong vào khoảng stage 44 / 100** — mỗi cảnh giới kiếm 15 điểm,
> 70 điểm là gần 5 cảnh giới. Tức Kỹ Năng thôi là hệ tiến triển từ **23% ván đầu**.
> Đó chính là lý do 230 điểm còn lại phải có chỗ tiêu.

Ngộ Tính **không** lên thanh tài nguyên: Warcraft chỉ có vàng và gỗ, cả hai đã
dùng. Nó hiện trong bảng phím R.

### Dùng luôn thanh tài nguyên của Warcraft III

Linh Khí **là** vàng, Tinh Thạch **là** gỗ. Không vẽ lại.

Thanh tài nguyên luôn hiện sẵn trên đầu màn hình. Dùng nó thì được miễn phí: chỗ
hiển thị, cập nhật tức thì, `GetPlayerState`/`SetPlayerState` để cộng trừ, và
người chơi đã quen nhìn chỗ đó.

Đổi lại: biểu tượng là đồng vàng và khúc gỗ chứ không phải chữ Linh Khí. Trong mọi
thông báo ta vẫn gọi đúng tên, vài phút sau không ai để ý nữa.

> **Lương thực** thì không dùng. Đặt về 0 và bỏ qua. Đừng cho nó công dụng nửa vời
> chỉ vì nó có mặt trên màn hình.

## Ngân sách sức mạnh: bốn nguồn, tích phải bằng ×967

| Hệ | Nhân | Cấu trúc |
|---|---|---|
| **Tu Vi** — tu vi của người chơi | **×20** | 20 bậc, mỗi bậc ×1.17 |
| **Trang Bị** | **×8** | 6 ô, mỗi ô 10 cấp, mỗi cấp +4% |
| **Kỹ Năng** | **×2.4** | 7 kỹ năng × 10 cấp, mỗi cấp +10% |
| **Pháp Khí** | **×2.5** | 5 món, mỗi món ×1.2 |
| | **×960** | ≈ ×967 ✔ |

**Đây là ràng buộc cứng.** Bốn con số này **nhân** với nhau, không cộng. Chỉnh một
cái là phải kiểm lại tích. Lệch 20% ở một nguồn nghe nhỏ, nhưng lệch 20% ở cả bốn
là tích lệch hơn gấp đôi.

> **Đây là bản đang chạy trong code.** `CFG.LINHCAN_STEP = 1.17` (không phải
> 1.215) và `CFG.TRANGBI_COST_BASE = 147` (không phải 86) đều thuộc bản này.
>
> Bản cũ chia **ba** nguồn: tu vi ×40.5, trang bị ×12, kỹ năng ×2 = ×971. Cũng
> đúng — nhưng **không trộn được**. Trộn Tu Vi ×40.5 của bản cũ với Trang Bị
> ×8 của bản này cho ×1 942, gấp đôi hợp đồng.
> [ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md)

## Thu nhập

Linh Khí rơi ra phải bám **×967** (hợp đồng sức mạnh), **không** bám ×2 176 (đường
cong EHP địch). Bám nhầm đường là người chơi giàu dần tương đối và nửa sau game quá dễ.

```
LinhKhi(stage) = LINHKHI_BASE × LINHKHI_GROWTH^(stage-1)
LINHKHI_GROWTH = 967^(1/219) ≈ 1.0319
```

| Stage | Linh Khí / wave |
|---|---|
| 1 | 60 |
| 55 | 326 |
| 110 | 1 836 |
| 165 | 10 323 |
| 100 | 58 019 |

**Tổng cả ván: ~1 875 000 Linh Khí.** Đây là ngân sách. Mọi giá trong map chia
nhau con số này.

Chia trong wave: 50 lính chia 60%, tinh anh 40%. Tinh anh đáng giá gấp ~13 lần một
con lính — đủ để đáng đi giết riêng, không đủ để bỏ mặc đám đông.

### Chia ngân sách

Chỉ **hai** hệ tiêu Linh Khí — Kỹ Năng và Pháp Khí đều tiêu Ngộ Tính, nên phần
Linh Khí còn lại dồn hết cho Tu Vi và Trang Bị.

| Hệ | Tỉ lệ | Linh Khí (đo được) |
|---|---|---|
| Tu Vi | 40% | 747 839 |
| Trang Bị | 52% | 974 605 |
| Không tiêu hết | 8% | 157 743 |

Phần không tiêu hết **cố ý có**. Người chơi không nên mua được sạch mọi thứ trong
một ván — nếu tiêu hết mà vẫn thắng thì lần chơi sau không còn gì để làm khác đi.
Cả ba đồng tiền đều giữ khoảng dư này: Ngộ Tính tiêu 94%, Tinh Thạch 91%.

## Bảng giá

Hai hệ tiêu Linh Khí dùng một nguyên tắc: **giá bám theo thu nhập**. Giá tăng cùng nhịp với
Linh Khí rơi ra, nên "một lần nâng cấp đáng mấy wave" là **hằng số suốt 100 stage**.

Đây là tính chất quan trọng nhất của bảng giá. Không có nó thì hoặc đầu game nghèo
kiết xác, hoặc cuối game tiền thừa mứa không biết tiêu.

### Tu Vi — 19 lần đột phá

```
gia(bac r) = 439 × 1.412^(r-1)
```

| Bậc | Giá | Bằng mấy wave thu nhập |
|---|---|---|
| 1 → 2 | 438 | 7,1 |
| 5 → 6 | 1 745 | 7,1 |
| 10 → 11 | 9 808 | 7,1 |
| 15 → 16 | 55 128 | 7,1 |
| 19 → 20 | 219 374 | 7,1 |

Hằng số 7,1 không phải trùng hợp — `1.412 = 1.0319^11`, tức giá tăng đúng bằng
thu nhập của 5 stage (một cảnh giới). Đột phá mỗi cảnh giới một lần, và lúc nào
cũng phải để dành ~7 wave.

### Trang Bị — 6 ô × 9 lần nâng

```
gia(lan thu k) = TRANGBI_COST_BASE × TRANGBI_COST_STEP^(k-1)
               = 147 × 1.134^(k-1)
```

| Lần nâng | Giá |
|---|---|
| 1 | 147 |
| 18 | 1 236 |
| 36 | 11 858 |
| 54 | 113 632 |

Mỗi cấp +4% sát thương. Sáu ô đầy cấp 10 = `(1.04⁹)⁶ ≈ ×8.3`.

`1.134 = 1.0319^4.07` — 54 lần nâng trải đều 100 stage thì mỗi lần cách nhau
4,07 stage, nên "một lần nâng đồ đáng mấy wave" là hằng số suốt ván. Cùng nguyên
tắc với 7,1 wave của Tu Vi.

> **Sáu ô có tác dụng giống hệt nhau (+4% sát thương).** Không phải quên làm cho
> đa dạng: ngân sách Trang Bị là ×8 **sát thương**, mà ×8 đó chính là
> `(1.04⁹)⁶`. Chia ba ô sang máu/giáp thì sát thương còn `(1.04⁹)³ = ×2.9` và
> tích bốn hệ tụt đi hơn một nửa. Muốn ô thủ/công khác nhau thì phải suy lại
> cả ngân sách trước.

### Kỹ Năng — 1 điểm mỗi lần

```
CFG.SKILL_NGO_UNLOCK  = 1   -- mo khoa mot ky nang
CFG.SKILL_NGO_UP      = 1   -- nang mot bac
CFG.SKILL_START_COUNT = 0   -- vao map tay khong
CFG.NGOTINH_START     = 1   -- nhung cam san mot diem
```

**Hero vào map tay không, nhưng cầm sẵn 1 Ngộ Tính** *(chốt 2026-09-16)*.

Một điểm đó là **quyết định đầu tiên của ván**, và là quyết định thật: mở cái nào
trước? Khác hẳn hai bản đã thử và bỏ:

| Bản | Vấn đề |
|---|---|
| Cả bảy phát sẵn | Giây đầu không còn gì để chọn — bảy ô đầy ngay là hết chuyện |
| Tay không, **0 điểm** | Giây đầu không chọn được gì cả — phải đánh đòn thường tới con tinh anh đầu tiên mới có cái để bấm |

Giá phẳng: mở cái thứ nhất hay thứ bảy đều 1 điểm, đôn một bậc cũng 1 điểm.
Trọn bảy cái là `7 × (1 mở + 9 đôn) = 70` điểm trên 300 kiếm được cả ván.

Đợt 1 đánh bằng đòn thường. Với `WAVE_WAIT_FIRST` bật thì người chơi có thời gian
nhìn bảng trước khi gõ `-next`, nên không ai bị ném vào trận mà chưa biết mình có gì.

| | Điểm |
|---|---|
| Mở khoá 7 kỹ năng | 7 |
| Nâng mỗi cái lên bậc 10 | 7 × 9 = 63 |
| **Tổng** | **70** trên 300 |

### Pháp Khí — rỗng, chờ thiết kế lại

`CFG.PHAPKHI = {}`. Năm món cũ đã xoá — chúng mua bằng Tinh Thạch.

**Ngân sách đã dành sẵn: 230 điểm Ngộ Tính**, và phần sức mạnh phải trả lại là
**×2.5** của hợp đồng ×967.

Code chạy được với bảng rỗng: thẻ hiện một dòng "chưa có gì", và mọi hiệu ứng trả
về `false` nên `2_wave.lua` gọi vẫn an toàn.

### ⚠ Tinh Thạch hiện không có chỗ tiêu

Boss vẫn rơi `TINHTHACH_BOSS_BASE + STEP × (r−1)`, tổng **1 150** cả ván. Nhưng
Pháp Khí đã chuyển sang Ngộ Tính, nên **không hệ nào tiêu Tinh Thạch nữa** —
`API.spendTinhThach` còn trong code nhưng không ai gọi.

Ba cách xử lý, chưa chọn:

| | Cách | Ghi chú |
|---|---|---|
| A | **Bỏ hẳn Tinh Thạch** | Còn hai đồng tiền. Gọn nhất, nhưng mất một mốc thưởng khi hạ boss |
| B | **Tìm việc mới cho nó** | Ví dụ: một hệ thứ năm, hoặc mở khoá phó bản |
| C | Giữ nguyên, để dành | Người chơi thấy một con số tăng mãi mà không dùng được — **tệ nhất** |

### Pháp Khí — Tinh Thạch

| | |
|---|---|
| Boss cảnh giới `r` rơi | `10 + 5×(r-1)` Tinh Thạch |
| Tổng cả ván (20 boss) | 1 150 |
| 5 Pháp Khí giá | 60 · 110 · 180 · 280 · 420 = **1 050** |

Mua được đủ 5 món nếu hạ hết 20 boss. Thua một boss là mất một món — đó là trọng
lượng thật của việc thua boss.

**Pháp Khí không nên là +% chỉ số.** Năm món, mỗi món **đổi cách chơi**: ví dụ
"kỹ năng vùng chạm thêm 50% bán kính", "hồi chiêu giảm một nửa khi dưới 30% máu".
Chỉ số thì đã có ba hệ kia lo rồi.

## Chưa quyết

- **Linh Khí riêng từng người hay quỹ chung.** Riêng thì mỗi người tự quyết build;
  chung thì buộc phải bàn nhau. Hai cảm giác chơi rất khác — và nó đổi cả cách
  thiết kế [bảng nhân vật](bang-nhan-vat.md).
- Tu Vi lên bằng gì: tự động theo cảnh giới địch, hay phải gom Linh Khí đột
  phá. Bảng giá ở trên giả định **phải gom** — chọn tự động thì bỏ 40% ngân sách
  và ba hệ kia phải gánh lại.
- Chết có mất Linh Khí không.
- Có cho hoàn điểm đổi build không.
- Nội dung 5 Pháp Khí — chưa nghĩ món nào.
