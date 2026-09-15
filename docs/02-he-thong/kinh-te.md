# Kinh tế & bốn hệ nâng cấp

> **Trạng thái:** Nháp — công thức đã chốt, chưa cài
> **Cập nhật:** 2026-09-15
> **Xem kèm:** [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) ·
> [bang-nhan-vat.md](bang-nhan-vat.md) · [dot-quai.md](dot-quai.md)

Trang này trả lời câu hỏi mà
[duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) để ngỏ: **×967 sức
mạnh người chơi đến từ đâu, và mua bằng gì.**

## Hai đồng tiền, và chỉ hai

| | Nguồn | Mua gì | Nhịp |
|---|---|---|---|
| **Linh Khí** *(vàng)* | Mọi quái | Linh Căn, Trang Bị, Kỹ Năng | Chảy đều, tiêu liên tục |
| **Tinh Thạch** *(gỗ)* | **Chỉ boss** — 20 lần cả ván | Pháp Khí | Hiếm, theo mốc |

Hai đồng tiền chỉ tạo chiều sâu khi **khác nguồn** và **khác chỗ tiêu**. Ở đây
khác cả hai: Linh Khí là thu nhập đều để nâng dần, Tinh Thạch là phần thưởng cột
mốc để mua thứ đổi cách chơi. Nếu cả hai cùng rơi từ quái và cùng dùng nâng cấp
thì đó không phải lựa chọn, chỉ là làm phép cộng ở hai chỗ.

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
| **Linh Căn** — tu vi của người chơi | **×20** | 20 bậc, mỗi bậc ×1.17 |
| **Trang Bị** | **×8** | 6 ô, mỗi ô 10 cấp, mỗi cấp +4% |
| **Kỹ Năng** | **×2.4** | 7 kỹ năng × 10 cấp, mỗi cấp +10% |
| **Pháp Khí** | **×2.5** | 5 món, mỗi món ×1.2 |
| | **×960** | ≈ ×967 ✔ |

**Đây là ràng buộc cứng.** Bốn con số này **nhân** với nhau, không cộng. Chỉnh một
cái là phải kiểm lại tích. Lệch 20% ở một nguồn nghe nhỏ, nhưng lệch 20% ở cả bốn
là tích lệch hơn gấp đôi.

> Bản trước của [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) chia
> ba nguồn (tu vi ×40, trang bị ×12, kỹ năng ×2 = ×960). Bảng trên là **cùng ngân
> sách đó tách làm bốn** để khớp bốn thẻ của [bảng nhân vật](bang-nhan-vat.md).
> Linh Căn nhận phần lớn nhất vì nó chính là hệ tu vi — nó giữ đúng vai trò cũ,
> chỉ đổi tên và tách bớt một phần sang Pháp Khí.

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
| 220 | 58 019 |

**Tổng cả ván: ~1 875 000 Linh Khí.** Đây là ngân sách. Mọi giá trong map chia
nhau con số này.

Chia trong wave: 50 lính chia 60%, tinh anh 40%. Tinh anh đáng giá gấp ~13 lần một
con lính — đủ để đáng đi giết riêng, không đủ để bỏ mặc đám đông.

### Chia ngân sách

| Hệ | Tỉ lệ | Linh Khí |
|---|---|---|
| Linh Căn | 40% | ~750 000 |
| Trang Bị | 30% | ~563 000 |
| Kỹ Năng | 22% | ~413 000 |
| Không tiêu hết | 8% | ~150 000 |

Phần không tiêu hết **cố ý có**. Người chơi không nên mua được sạch mọi thứ trong
một ván — nếu tiêu hết mà vẫn thắng thì lần chơi sau không còn gì để làm khác đi.

## Bảng giá

Cả ba hệ dùng một nguyên tắc: **giá bám theo thu nhập**. Giá tăng cùng nhịp với
Linh Khí rơi ra, nên "một lần nâng cấp đáng mấy wave" là **hằng số suốt 220 stage**.

Đây là tính chất quan trọng nhất của bảng giá. Không có nó thì hoặc đầu game nghèo
kiết xác, hoặc cuối game tiền thừa mứa không biết tiêu.

### Linh Căn — 19 lần đột phá

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
thu nhập của 11 stage (một cảnh giới). Đột phá mỗi cảnh giới một lần, và lúc nào
cũng phải để dành ~7 wave.

### Trang Bị — 6 ô × 9 lần nâng

```
gia(lan thu k) = 86 × 1.134^(k-1)
```

| Lần nâng | Giá |
|---|---|
| 1 | 85 |
| 18 | 723 |
| 36 | 6 936 |
| 54 | 66 471 |

Mỗi cấp +4% sát thương. Sáu ô đầy cấp 10 = `(1.04⁹)⁶ ≈ ×8.3`.

### Kỹ Năng — 7 kỹ năng × 9 lần nâng

```
gia(lan thu k) = 56 × 1.113^(k-1)
```

| Lần nâng | Giá |
|---|---|
| 1 | 55 |
| 21 | 472 |
| 42 | 4 446 |
| 63 | 41 821 |

Mỗi cấp +10% hiệu lực. Một kỹ năng cấp 10 = `1.10⁹ ≈ ×2.36`.

> Giá tính theo **tổng số lần đã nâng**, không theo cấp của riêng kỹ năng đó. Nên
> dồn hết vào một kỹ năng không rẻ hơn rải đều — người chơi chọn theo lối chơi chứ
> không theo phép tính.

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
- Linh Căn lên bằng gì: tự động theo cảnh giới địch, hay phải gom Linh Khí đột
  phá. Bảng giá ở trên giả định **phải gom** — chọn tự động thì bỏ 40% ngân sách
  và ba hệ kia phải gánh lại.
- Chết có mất Linh Khí không.
- Có cho hoàn điểm đổi build không.
- Nội dung 5 Pháp Khí — chưa nghĩ món nào.
