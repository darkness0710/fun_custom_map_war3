# 0022 — Tiền thì phẳng, sức mạnh thì leo

> **Trạng thái:** Đã chốt — đã cài
> **Ngày:** 2026-09-17

## Bối cảnh

Cơ Duyên có ba thẻ, chọn một. Hai thẻ cho **tiền**, một thẻ cho **sức mạnh** —
nhưng chỉ có thẻ 1 là phẳng, còn thẻ 3 thì nhân theo bậc:

```
the 1  10 da            PHANG
the 2  +V chi so        LEO  x1.30 moi canh gioi
the 3  V x 12 vang      LEO  x1.30 moi canh gioi
```

Sau khi shop bắt đầu bán Đá Huyền Thiết (25 vàng/viên), hai thẻ tiền trở thành
**so sánh được trực tiếp** — và số đo cho thấy chúng cắt nhau:

| Cảnh giới | Thẻ 3 | = mấy đá | Thẻ 1 | Ai hơn |
|---|---|---|---|---|
| 1 | 26 | 1.1 | 3 | thẻ 1 ×2.8 |
| 10 | 280 | 11.2 | 3 | **thẻ 3 ×3.7** |
| 20 | 3 859 | **154** | 3 | **thẻ 3 ×51** |

Từ khoảng cảnh giới 5–10, chọn thẻ 3 rồi mang vàng đi mua đá **luôn luôn** lợi
hơn chọn thẻ 1. Thẻ 1 thành **thẻ chết** đúng nửa sau ván — và một thẻ chết trong
bộ ba nghĩa là người chơi chỉ còn chọn hai.

Nguyên nhân không phải con số `12`. Nó là **một thẻ leo ×180 trong khi thẻ kia
đứng yên**: hai đường khác độ dốc thì sớm muộn cũng cắt nhau, và chọn hằng số nào
cũng chỉ dời chỗ cắt.

Chính `1_config.lua` đã ghi trước luật này rồi, chỉ là ghi cho hướng ngược lại:

> *"HE QUA phai nho khi them mon vao shop: **gia mon PHAI leo theo bac**, neu
> khong nua sau van vang thanh vo nghia."*

## Quyết định

**Phân loại theo thứ thẻ cho, không theo thẻ nào:**

| Thẻ | Cho gì | |
|---|---|---|
| 1 | Đá Huyền Thiết | **tiền → phẳng** |
| 3 | Vàng | **tiền → phẳng** |
| 2 | Chỉ số | **sức mạnh → leo ×1.30** |

```lua
CFG.QUAY_DA       = 3       -- phang
CFG.QUAY_VANG_MIN = 30      -- phang, ngau nhien trong dai
CFG.QUAY_VANG_MAX = 90
-- CFG.QUAY_VANG_MOI_DIEM da bo
```

Đúng hướng cả nền kinh tế đã đi: thu nhập phẳng, Tu Vi phẳng 500, kỹ năng phẳng
1 Gỗ. Thẻ 3 là **thứ cuối cùng còn sót lại của thời thu nhập mũ**, nên bỏ nó
không phải là vá mà là dọn nốt.

**Thẻ 3 là một DẢI, không phải một số cố định.** Số cố định thì phép so sánh ba
thẻ giải đúng một lần rồi lặp lại 140 lần — người chơi bấm theo quán tính. Có dải
thì thỉnh thoảng nó đảo ngược, nên mỗi lượt phải nhìn thật.

Dải đặt theo thẻ 1 quy ra vàng: thẻ 1 = 3 đá = **75 vàng** nhưng **khoá** (chỉ
mua được trang bị). Trung bình thẻ 3 là 60 — thấp hơn một chút vì vàng **linh
hoạt hơn**, nó đổi ngược thành đá lúc nào cũng được còn đá thì không. **Đỉnh dải
90 phải vượt 75**, nếu không thẻ 3 thua mọi lượt và lại chết.

## Phương án đã loại

**Cho giá đá ở shop leo theo bậc** (`25 × 1.30^(r−1)`). Cũng làm tỉ lệ đứng yên,
và đúng câu config đã viết. Bỏ vì nó **giữ lại một đường cong mũ nữa** phải cân,
trong khi cả nền kinh tế đang đi về phẳng — và con số trên nút ở cảnh giới 20 sẽ
là 4 512 vàng/viên, khó đọc.

**Cho thẻ 1 leo theo bậc** để hai thẻ cùng dốc. Bỏ vì nó kéo theo giá nâng trang
bị cũng phải leo, mất luôn tính chất "1 đá mỗi lần thử" — con số đơn giản nhất
của cả hệ kiếm.

**Thẻ 3 = 1–10 vàng phẳng** *(đề xuất đầu của chủ dự án)*. Đúng hướng — bỏ leo —
nhưng **nhỏ hơn cần thiết khoảng 9 lần**: thẻ 1 đáng 75 vàng, thẻ 3 trung bình
5.5 thì nó chết ngay từ cảnh giới 1, chỉ đổi "chết ở nửa sau" thành "chết ngay
từ đầu". Đối chiếu tiền quái cũng vậy: quái cho 200 vàng một cảnh giới, 7 lượt
thẻ 3 ở mức đó chỉ thêm 38 — **+19%**, không đáng chọn.

**Thẻ 3 cố định 50** *(đề xuất đầu của tôi)*. Xem phần Quyết định: số cố định
làm phép so sánh chỉ phải giải một lần.

## Hệ quả

**Mọi món thêm vào shop từ giờ định giá theo tổng vàng cả ván**, không theo bậc:

```
quai cho           4,000 vang
Co Duyen the 3   ~ 8,400 vang  (140 luot x 60, neu LUON chon the 3)
                  --------
                 ~12,400 vang
```

**Lọ thuốc 10 vàng giờ rẻ suốt ván thay vì chỉ rẻ ở nửa sau.** Trước đây vàng
leo ×180 nên lọ thuốc thành miễn phí từ cảnh giới 10 — config đã chấp nhận điều
đó có chủ ý. Giờ nó không xảy ra nữa, tức **lọ thuốc giữ được nghĩa cả 100
stage**. Đây là lợi ích phụ, không phải mục tiêu, nhưng đáng ghi.

**Ankh 500 vàng nặng hơn trước** — khoảng 8 lượt thẻ 3, thay vì "một lượt ở cảnh
giới 15". Chưa đo được nó có quá nặng không.

**Còn nợ:** `CFG.QUAY_GIA_TRI` (thẻ 2) vẫn leo ×1.30, và đó là **đúng** — nó là
sức mạnh. Nhưng chưa ai kiểm xem ở cảnh giới 20 thì `+322` chỉ số có đè bẹp 3 đá
và 60 vàng không. Lý thuyết thì không, vì **một bậc kiếm ở cảnh giới 20 cũng đáng
hơn một bậc ở cảnh giới 1** — đá phẳng nhưng thứ đá mua được thì leo. Phải chơi
thử mới biết.
