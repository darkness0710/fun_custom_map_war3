# 0015 — Ba đồng tiền, mỗi đồng gắn một loại quái

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-16

## Bối cảnh

Bốn hệ nâng cấp, mà **ba hệ cùng rút một cái ví**: Tu Vi, Kỹ Năng và Trang Bị
đều mua bằng Linh Khí. Tinh Thạch chỉ dùng cho Pháp Khí — hệ duy nhất chưa cài.

Hệ quả: người chơi chỉ phải trả lời **đúng một câu hỏi** suốt cả ván — "đã gom đủ
tiền chưa". Ba hệ khác nhau về mặt hiển thị nhưng giống hệt nhau về mặt quyết
định, vì chúng cạnh tranh trên cùng một trục và không gì phân biệt chúng ngoài
giá.

Cùng lúc, ba loại quái đã có sẵn ba **nhịp** hoàn toàn khác nhau mà chưa hệ nào
dùng tới:

| Loại | Số con cả ván | Nhịp |
|---|---|---|
| Lính thường | ~11 000 | giây |
| Tinh anh | 200 | wave |
| Boss | 20 | cảnh giới |

## Quyết định

**Ba đồng tiền, mỗi đồng một loại quái, mỗi đồng một nhịp.**

| Đồng tiền | Rơi từ | Cả ván | Mua | Hiện ở |
|---|---|---|---|---|
| **Linh Khí** | lính thường | ~1 880 000 | Tu Vi, Trang Bị | thanh vàng |
| **Ngộ Tính** | **tinh anh** | 300 | Kỹ Năng | bảng phím R |
| **Tinh Thạch** | boss | 1 150 | Pháp Khí | thanh gỗ |

Mỗi hệ nâng cấp giờ trả lời được bằng **một câu**:

- Tu Vi, Trang Bị — *"giết quái, gom tiền"*
- Kỹ Năng — *"giết tinh anh"*
- Pháp Khí — *"hạ boss"*

**Tu Vi và Trang Bị cố ý dùng chung ví.** Đó không phải thiếu sót — đó là lựa
chọn chính của mỗi wave: đột phá, hay nâng đồ? Hai hệ kia không tranh ví đó;
chúng bị chặn bởi **nội dung** chứ không bởi tiền, nên không thể cày tiền để bỏ
qua chúng.

### Ngộ Tính là điểm, không phải tiền

Không có đường cong mũ, không bám theo thu nhập. Cả ván kiếm **260** Gỗ
(80 tinh anh × 2 + 20 boss × 5), tiêu **70** nếu mở và nâng trọn bảy kỹ năng.

> **Cập nhật 2026-09-17.** Con số cũ *(300 điểm, tiêu 283)* tính cho 220 stage
> và giá bậc thang `{1,2,2,3,3,4,4,5,5}`. Giờ là **100 stage** và giá **phẳng 1
> điểm**, nên trọn bảy kỹ năng max hết ở **stage 27** — phần dư 190 Gỗ dành cho
> Pháp Khí. Đồng tiền cũng đã đổi tên: *Ngộ Tính* → **Gỗ**, và *Tinh Thạch* xoá hẳn.

Nhờ vậy **bỏ hẳn được một đường cong phải cân bằng** (`SKILL_COST_BASE`/`STEP`).
Đổi lại là mất tính chất "nâng cả 7 skill ≈ một lần đột phá" — xem phần dưới.

### Ngân sách sức mạnh chuyển sang bản bốn nguồn

`CFG.LINHCAN_STEP` đổi **1.215 → 1.17**, và `CFG.TRANGBI_COST_BASE` là 147 chứ
không phải 86.

| | Tu Vi | Trang Bị | Kỹ Năng | Pháp Khí | Tích |
|---|---|---|---|---|---|
| Bản cũ (3 nguồn) | ×40.5 | ×12 | ×2 | — | ×971 |
| **Bản này (4 nguồn)** | **×19.7** | **×8** | **×2.4** | **×2.5** | **×985** |

> **Cập nhật 2026-09-16.** Pháp Khí đã bị xoá sạch nội dung để thiết kế lại, và
> khi quay lại nó sẽ tiêu **Ngộ Tính** chứ không tiêu Tinh Thạch. Quyết định gốc
> của ADR này — *ba đồng tiền gắn ba loại quái* — vì thế **đã bị thu hẹp**:
> Tinh Thạch hiện không có chỗ tiêu nào. Xem
> [kinh-te.md](../02-he-thong/kinh-te.md).
>
> Ngân sách hiện thực tế là **×392**, không phải ×985.
| Nếu trộn hai bản | ×40.5 | ×8 | ×2.4 | ×2.5 | ×1942 ✘ |

Hai bản đều tự nhất quán; cái sai là **trộn**. Trước quyết định này code đang chạy
bản 3 nguồn trong khi `kinh-te.md` mô tả bản 4 nguồn, nên xây Trang Bị theo tài
liệu sẽ cho ×1942 — người chơi mạnh gấp đôi mức đường cong địch đòi.

Chia Linh Khí sau khi Kỹ Năng rời khỏi ví: **Tu Vi 40%, Trang Bị 52%, dư 8%.**

## Phương án đã loại

**Giữ một đồng tiền cho tất cả.** Đơn giản nhất, và thanh vàng của Warcraft lo
luôn phần hiển thị. Loại vì đó chính là vấn đề: bốn hệ mà một trục quyết định thì
ba hệ là trang trí.

**Bốn đồng tiền, mỗi hệ một đồng.** Đối xứng đẹp, nhưng không có loại quái thứ tư
để gắn vào — phải bịa ra một cơ chế rơi mới, và Warcraft cũng hết chỗ hiển thị.
Quan trọng hơn: nó **xoá mất sự cạnh tranh**. Tu Vi và Trang Bị dùng chung ví
là thứ duy nhất tạo ra một lựa chọn thật mỗi wave.

**Kỹ Năng trả bằng Linh Khí *và* Ngộ Tính.** Giữ được đường cong giá cũ (và tính
chất "7 skill ≈ 1 đột phá"), đồng thời vẫn gắn với tinh anh. Loại vì giá hai
thành phần thì người chơi không nhẩm nổi còn thiếu gì, và câu trả lời "cần gì để
nâng" dài ra thành hai vế. Ưu tiên *một câu* cho mỗi hệ.

**Ngộ Tính có đường cong mũ như Linh Khí.** Loại vì nó sẽ phải bám theo một
đường thu nhập cố định (1 con/wave), tức chỉ là Linh Khí đổi tên. Điểm thì cho
một kiểu quyết định khác hẳn: không để dành được nhiều, không lạm phát.

## Cái mất

**Mất tính chất "nâng cả 7 kỹ năng một bậc ≈ một lần đột phá Tu Vi".** Nó đến
từ `SKILL_COST_STEP = 1.99 ≈ 1.412²` và là một thiết kế có chủ ý, đọc được.

Chấp nhận mất, vì tính chất đó chỉ có nghĩa khi hai hệ tiêu **cùng một đồng
tiền** — so sánh 89 Linh Khí với 439 Linh Khí thì được, so sánh 2 Ngộ Tính với
439 Linh Khí thì không. Đổi lại được một thứ lớn hơn: hai hệ không còn tranh nhau.

**Pháp Khí đang trả ×2.5 bằng đường vòng.** Năm món hiện có không món nào cộng
thẳng sát thương — chúng cộng vào kinh tế và vào sức chịu của nhà chính. Chưa đo
được đường vòng đó có bằng ×2.5 thật không. Đây là chỗ đầu tiên phải kiểm khi
chơi thử, không phải chỗ để sửa số.
