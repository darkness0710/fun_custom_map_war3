# 0021 — Trang bị là MỘT món tiến hoá theo cảnh giới, không phải nhiều ô nâng cấp

> **Trạng thái:** Đã chốt — luật xong, chỉ số chưa
> **Ngày:** 2026-09-17
> **Thay thế:** `CFG.TRANGBI` sáu ô *(đang `TRANGBI_LOCKED`)*

## Bối cảnh

Sáu ô trang bị cũ có hai vấn đề, và cái thứ hai mới là cái giết nó.

**Một:** cả sáu ô **cùng một tác dụng** (+4% sát thương). Chủ dự án đã bác kiểu
trùng lặp này ba lần ở ba hệ khác nhau.

**Hai — nặng hơn:** giá của nó suy từ thu nhập **mũ** cũ (`1 880 187` Linh Khí cả
ván). Với thu nhập phẳng `10 000` hiện tại:

```
tron 60 lan nang  =  974,606 Linh Khi   (gap 97 lan so kiem duoc)
lan nang thu 54   =  115,295 Linh Khi   (mot lan)
10,000 mua duoc   =   18/60 lan
500 du sau Tu Vi  =    2/60 lan
```

Và sau [ADR 0020](0020-duong-cong-quai-bam-theo-tu-vi.md), lý lẽ *"cả sáu phải
giống nhau vì ngân sách Trang Bị là ×8 sát thương"* **mất nền** — không còn tích
bốn hệ nào phải đạt tới. Nhưng đồng thời ×8.3 trở thành **phần vượt lên thuần
không có cận trên**, nên mở khoá nó cũng không được.

Hệ này không sửa được bằng cách chỉnh số.

## Quyết định

**Một món duy nhất — Kiếm — leo 100 bậc (20 cảnh giới × 5 cấp), và trần của nó
là cảnh giới Tu Vi của chính người chơi.**

| | |
|---|---|
| Mỗi lần thử | 1 Đá Huyền Thiết |
| Xác suất | 100 / 75 / 50 / 25 / 15 % |
| Bỏ bậc | không — phải đi đủ 5 cấp mỗi cảnh giới |
| Đột phá Tu Vi | chỉ **nới trần**, không reset, không mất gì |
| Thất bại | mất viên đá, không mất cấp |
| Dạng | **không phải item trong túi** |

Luật đầy đủ: [trang-bi-kiem.md](../02-he-thong/trang-bi-kiem.md).

**Lý do chính không phải là nó đơn giản hơn, mà là cái trần.** Sau ADR 0020 mọi
nguồn ngoài Tu Vi là phần vượt lên **không có cận trên**. Khoá theo cảnh giới cho
phần vượt lên một cận trên, và cận đó bám **đúng biến mà quái cũng bám** — nên
kiếm không bao giờ vượt quá một cảnh giới sức mạnh. An toàn về **cấu trúc**, cùng
loại với chính ADR 0020.

## Phương án đã loại

**Sáu ô, sáu chỉ số khác nhau** *(HP, mana, tốc chạy, tốc đánh, giáp, sát
thương)*. Bỏ vì hai thứ đo được: bản 1.31.1 **không phơi ra trường nào cộng máu
tối đa** (`-nat ilf`), và tốc chạy gần như vô nghĩa trong map thủ trận nơi hero
đứng cạnh nhà. Còn lại ba ô thật thì không đủ gọi là "sáu ô".

**Bốn ô, bốn câu hỏi khác nhau** *(sát thương / giáp / hồi phục / giảm hồi
chiêu)*. Gần được, nhưng nó hỏi **một câu duy nhất — "ô nào đáng nâng nhất" —
rồi hỏi lại 36 lần**. Sau chừng 5 lần người chơi đã giải xong; 31 lần còn lại là
bấm nút. Và không ô nào có cận trên.

**Khảm châu vào ô** *(socket, châu có loại + phẩm chất, bộ ba mở hiệu ứng)*. Nhịp
tốt — ~140 quyết định nhỏ, khớp đúng nhịp giết tinh anh. Bỏ vì nó thêm **một hệ
khái niệm mới phải dạy** (3 loại châu × 4 bậc phẩm chất × luật hợp hệ × bộ ba),
trong khi thang cảnh giới thì người chơi **đã biết rồi**. Và nó vẫn không có cận
trên.

**Ghép đồ theo công thức** *(2 món bậc 1 + đá → 1 món bậc 2, ba bậc)*. Cảm giác
mạnh nhất, món đồ là vật thật trong túi. Bỏ vì chỉ cho **~6 quyết định cả ván** —
quá thưa cho 100 stage — và cần cây công thức phải **vẽ** mới đọc được, cộng một
buổi đo mã trường `.w3t`.

**Item thật trong túi** *(cho mọi phương án trên)*. Bỏ theo quyết định của chủ dự
án, và nó gỡ luôn một loạt: không phải đo mã trường `.w3t`, không cần biết
`BlzSetItemName` có tồn tại không, không có chuyện ném đồ đi hay đưa cho đồng
đội, và **xung đột túi-đầy với Ankh 500 vàng biến mất**.

## Hệ quả

**`CFG.QUAY_DA` từ giờ bám theo số món trang bị:** `≈ 2.5 × số món`. Một món → 3.
Bốn món → 10. Cách ra: một món đi trọn thang tốn ~300 đá (kỳ vọng 15 lần thử ×
20 cảnh giới), cả ván có 140 lượt quay.

> **Thêm món mà quên sửa số này là hệ xác suất chết.** Đá thừa thì bấm mãi cũng
> trúng, và 100/75/50/25/15 không còn nghĩa gì.

**Shop bán đá 25 vàng/viên** — đối thủ đầu tiên của Vàng ngoài lọ thuốc, và là
đường **gỡ khi đen** chứ không phải đường leo chính.

**Chỉ số kiếm chưa chốt**, nên hệ **chưa cài được**. `CFG.TRANGBI` sáu ô vẫn nằm
đó với `TRANGBI_LOCKED = true` cho tới khi kiếm thay được nó.

**Còn nợ:** chưa ai chơi thử. Con số đáng đo nhất là `CFG.QUAY_DA` — nó quyết
định kiếm *dính trần* hay *tụt sau trần*, mà hệ chỉ vui khi qua lại giữa hai
trạng thái đó.
