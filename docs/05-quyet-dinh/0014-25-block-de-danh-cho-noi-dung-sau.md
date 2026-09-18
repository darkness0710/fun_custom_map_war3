# 0014 — Giữ lưới 25 block, để dành cho nội dung sau

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-16

## Bối cảnh

Lưới 25 block và 8 dòng sông đã có toạ độ từ Bước 1
([4_geometry.lua](../../src/1_core/4_geometry.lua)), nhưng **không lối chơi nào
gắn vào chúng**. Hệ đợt quái không dùng tới: quái ra ở `MyEmenyRegion` và đi
thẳng tới nhà chính, nên 24 block còn lại là đất trống.

Câu hỏi này đứng trong mục "Chưa quyết" của
[00-tong-quan.md](../00-tong-quan.md) từ đầu, và nó là câu hỏi lớn nhất còn lại
của cả map. Nó được nêu lại khi rà soát: một map 224 × 224 mà lối chơi chỉ dùng
hai vùng thì hoặc lưới phải có việc, hoặc map phải nhỏ lại.

## Quyết định

**Giữ nguyên lưới 25 block. Chúng để dành cho phó bản, challenge và event —
làm sau, chưa có thời gian bây giờ.**

Nghĩa là trong giai đoạn hiện tại:

- Lưới **không** phải là nợ kỹ thuật cần dọn. Nó là chỗ đã cắm sẵn cho nội dung
  chưa viết.
- Hệ đợt quái tiếp tục chạy phương án A (đi thẳng tới nhà) và **không** phải
  gánh trách nhiệm làm lưới có ý nghĩa.
- Mục "25 block dùng để làm gì" **rời khỏi danh sách câu hỏi chặn**. Nó không
  còn chặn việc gì cả.

## Phương án đã loại

**Thu nhỏ map cho vừa lối chơi hiện có.** Một map chỉ dùng hai vùng thì 224 × 224
là thừa, và map nhỏ hơn thì quái đi bộ nhanh hơn, `WAVE_TIME` dễ chỉnh hơn, hiệu
năng nhẹ hơn.

Loại vì nó **đổi chiều không quay lại được**. Thu nhỏ map là vẽ lại địa hình,
tính lại lưới, dời vùng — và khi phó bản có thật thì lại phải phình ra, làm lại
từ đầu toàn bộ việc đó. Giữ đất trống rẻ hơn nhiều so với giành lại đất đã bỏ.

**Ép lưới vào hệ đợt quái ngay bây giờ** (phương án B: quái đi theo hành lang
giữa các block, sông chặn hai bên). Loại vì nó bắt lưới phục vụ sai mục đích:
lưới sinh ra để chia map thành khu vực, không phải để làm mê cung dẫn đường. Làm
vậy rồi thì sau này phó bản lại phải tranh chỗ với đường đi của quái.

Phương án B vẫn để ngỏ như một nâng cấp của hệ đợt quái, độc lập với quyết định
này — [dot-quai.md](../02-he-thong/dot-quai.md#đường-đi).

## Hệ quả

> **Cập nhật 2026-09-16.** Điều kiện "chỉ có nghĩa khi đã biết block dùng để làm
> gì" đã được đáp ứng: vai trò từng block đã chốt trong
> [phan-vung.md](../02-he-thong/phan-vung.md), và 25 vùng `Blk01..Blk25` đã có
> trong World Editor ([w3region.py](../../w3region.py)).
>
> Quyết định gốc **không đổi**: lối chơi vẫn hoãn. Thứ vừa làm là *bản đồ* và
> *chỗ đánh dấu*, không phải nội dung.

Ba thứ **chưa** phải làm, và đừng làm sớm:

- ~~Gán region cho 25 block.~~ Đã làm — xem khung trên.
- Vẽ 8 dòng sông. Vẫn nên vẽ, nhưng vì lý do khác (xem
  [ADR 0004](0004-song-ve-tay.md)), không phải vì lưới.
- Bất cứ cơ chế nào gắn với "đang đứng ở block nào".

Khi bắt tay vào phó bản/challenge/event, viết một file trong
[02-he-thong/](../02-he-thong/) trước, rồi mới đụng vào code — và lúc đó quay lại
sửa ADR này nếu lưới 5 × 5 không còn hợp.
