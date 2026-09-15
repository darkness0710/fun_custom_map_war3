# Kinh tế: Linh Khí, vàng, gỗ

> **Trạng thái:** Nháp — chưa cài
> **Cập nhật:** 2026-09-15
> **Liên quan:** [dot-quai.md](dot-quai.md), [ky-nang.md](ky-nang.md)

## Có nên dùng vàng và gỗ không

**Không, ít nhất là chưa.** Dùng **một** đồng tiền: Linh Khí.

Hai đồng tiền chỉ tạo ra chiều sâu khi chúng **đến từ nguồn khác nhau** và **mua thứ
khác nhau**. Nếu cả hai cùng rơi ra từ quái và cùng dùng để nâng cấp, người chơi không
phải *lựa chọn* gì — chỉ phải làm phép cộng ở hai chỗ. Đó là thêm việc, không thêm
quyết định.

Thử hỏi: "khi nào người chơi có nhiều vàng nhưng thiếu gỗ?" Nếu không trả lời được
bằng một tình huống cụ thể thì đồng tiền thứ hai chưa có lý do tồn tại.

### Nhưng nên để Linh Khí **là** vàng

Đây là mẹo thực dụng, không phải thoả hiệp.

Thanh tài nguyên của Warcraft III luôn hiện sẵn trên đầu màn hình. Dùng nó làm Linh
Khí thì được miễn phí:

- Chỗ hiển thị, không phải vẽ frame
- Cập nhật tức thì, không phải code làm mới
- `GetPlayerState` / `SetPlayerState` để cộng trừ
- Người chơi đã quen nhìn chỗ đó

Đổi lại: biểu tượng là đồng tiền vàng chứ không phải chữ "Linh Khí". Trong mọi thông
báo và giao diện ta vẫn gọi nó là Linh Khí, và sau vài phút không ai để ý nữa.

> Không giấu được thanh **gỗ** và **lương thực**. Đặt chúng về 0 và không bao giờ dùng
> tới — người chơi sẽ bỏ qua. Đừng cho chúng một công dụng nửa vời chỉ vì chúng có mặt.

### Khi nào thì thêm đồng tiền thứ hai

Khi có một nguồn thật sự khác biệt. Ví dụ đáng cân nhắc:

| Đồng tiền | Nguồn | Mua gì | Vì sao tách ra |
|---|---|---|---|
| **Linh Khí** (vàng) | Mọi quái | Nâng kỹ năng | Dòng chảy đều, tiêu liên tục |
| **Tinh Thạch** (gỗ) | **Chỉ boss** | Pháp Khí | Hiếm, theo mốc — mỗi lần nhận là một quyết định lớn |

Cấu trúc đó có lý do rõ ràng: Linh Khí là thu nhập đều để nâng dần, Tinh Thạch là phần
thưởng theo cột mốc để mua thứ đổi cách chơi. Hai nhịp khác nhau.

**Nhưng đừng làm ngay.** Làm Linh Khí chạy đã, chơi thử, rồi mới biết Pháp Khí có cần
đồng tiền riêng không.

## Linh Khí rơi ra bao nhiêu

Gọi `r` = cảnh giới (1…20).

| Nguồn | Linh Khí |
|---|---|
| Lính thường | `5 × r` |
| Tinh anh | `50 × r` |
| Boss | `500 × r` |

Thu nhập một wave ở cảnh giới `r`: `50×5r + 50r = 300r`.

**Vì sao nhân với cảnh giới:** sức mạnh quái tăng ~1,45× mỗi cảnh giới. Nếu Linh Khí
rơi ra cố định thì tới cảnh giới 10 người chơi giết cả wave chỉ được vài đồng, trong
khi giá nâng cấp đã lên trời. Cho thu nhập tăng theo cảnh giới thì hai bên tự đi cùng
nhau, không cần bảng riêng cho từng wave.

### Tổng thu nhập cả ván (phương án A: 20 cảnh giới × 3 tầng)

```
Wave thường : 3 wave × 300r, với r = 1..20  =  900 × 210    = 189 000
Boss        : 500r,          với r = 1..20  =  500 × 210    = 105 000
                                                     TỔNG   ≈ 294 000
```

Đây là **ngân sách**. Mọi giá trong map phải chia nhau con số này.

## Chia ngân sách

| Hệ thống | Tỉ lệ | Linh Khí |
|---|---|---|
| Nâng kỹ năng | 55% | ~162 000 |
| Trang bị | 20% | ~59 000 |
| Linh Căn | 15% | ~44 000 |
| Dự phòng / không tiêu hết | 10% | ~29 000 |

Phần dự phòng cố ý có: người chơi **không nên** mua được hết mọi thứ trong một ván.
Nếu tiêu hết sạch mà vẫn thắng thì lần chơi sau không còn gì để làm khác đi.

## Bảng nâng kỹ năng

7 kỹ năng × 10 cấp = 70 lần nâng, ngân sách ~162 000.

Công thức đề xuất:

```
gia(cap) = 45 × cap²
```

| Cấp | Giá | Cộng dồn |
|---|---|---|
| 2 | 180 | 180 |
| 3 | 405 | 585 |
| 4 | 720 | 1 305 |
| 5 | 1 125 | 2 430 |
| 6 | 1 620 | 4 050 |
| 7 | 2 205 | 6 255 |
| 8 | 2 880 | 9 135 |
| 9 | 3 645 | 12 780 |
| 10 | 4 500 | **17 280** |

Max một kỹ năng: 17 280. Max cả 7: **120 960** — nằm gọn trong 162 000, còn dư cho
người chơi rải đều thay vì dồn hết vào một cái.

**Vì sao bậc hai chứ không nhân đôi mỗi cấp.** Nhân đôi (100, 200, 400…) thì cấp 10
đắt gấp 512 lần cấp 2 — người chơi chỉ nâng được một kỹ năng lên cao và bỏ mặc sáu
cái kia. Bậc hai giữ cấp cuối đắt gấp 25 lần, đủ để phải cân nhắc mà không khoá cứng
lựa chọn.

### Mỗi cấp cho thêm bao nhiêu

Sát thương/hiệu lực **+12% mỗi cấp, cộng dồn nhân**. Cấp 10 = `1,12⁹ ≈ 2,77×`.

Đây là chỗ then chốt: quái mạnh lên **1 164×** qua 20 cảnh giới, mà kỹ năng chỉ cho
2,77×. Phần còn lại phải đến từ **trang bị và Linh Căn**. Nếu không, tới cảnh giới 8
là người chơi không giết nổi gì nữa.

> **Đây là ràng buộc lớn nhất của toàn bộ thiết kế.** Ba nguồn sức mạnh nhân với nhau
> phải đạt ~1 000×:
> `kỹ năng 2,8× × trang bị ~20× × linh căn ~20× ≈ 1 100×`
> Số cụ thể sẽ đổi, nhưng **tích của ba nguồn** phải bám theo đường cong quái. Mỗi lần
> chỉnh một nguồn phải kiểm lại tích.

## Chưa quyết

- Nâng kỹ năng có cần hero còn sống không, hay nâng được cả lúc đang chết.
- Có cho hoàn Linh Khí để đổi build không.
- Linh Khí là của riêng từng người hay quỹ chung của cả đội. Riêng thì mỗi người tự
  quyết build; chung thì buộc phải bàn nhau — hai cảm giác chơi rất khác.
- Chết có mất Linh Khí không.
