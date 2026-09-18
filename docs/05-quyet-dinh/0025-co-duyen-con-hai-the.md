# 0025 — Cơ Duyên bỏ thẻ đá, còn hai thẻ

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-18

## Bối cảnh

Cơ Duyên mở ba thẻ, chọn một:

| Thẻ | Cho gì |
|---|---|
| 1 | `FORTUNE_IRON` Đá Huyền Thiết, phẳng |
| 2 | `+V` vào một chỉ số ngẫu nhiên, leo ×1.30 |
| 3 | 30–90 vàng, phẳng |

Ba thẻ nằm trong **ba đại lượng không so được với nhau**, nên mỗi lần chỉnh một
con số là phải đoán xem hai thẻ kia có còn đáng chọn không.

Hai chuyện xảy ra cùng lúc buộc phải quyết:

**1. `FORTUNE_IRON` đã cũ mà không ai biết.** Chú thích của chính nó viết
*"`FORTUNE_IRON ≈ 2.5 × số món` … Hiện mới có MỘT món (Kiếm) nên để 3. **THÊM MÓN
LÀ PHẢI SỬA SỐ NÀY**"*. Số món đã lên 7, con số vẫn là 3. Cả ván quay được 420 đá
trong khi một món đi trọn đã tốn 471 — **quay cả 140 lượt, hy sinh sạch hai thẻ
kia, vẫn không đi hết nổi một món**.

**2. Hai nguồn đá đánh nhau.** Đá vào từ hai cửa: thẻ 1 và shop. Chỉnh giá shop
để nới nhịp Trang Bị thì thẻ 1 lệch; chỉnh thẻ 1 thì giá shop lệch. Không có núm
nào điều được nhịp mà không phá cái kia.

## Quyết định

**Bỏ thẻ đá. Cơ Duyên còn hai thẻ: vàng và chỉ số.**

```lua
CFG.FORTUNE_KINDS = { "gold", "stat" }
```

Lý do không phải thẻ đá yếu, mà nó **trùng**: vàng mua được đá ở shop, lại mua
được cả lọ và Ankh. Thẻ đá là **tập con** của thẻ vàng, kém đúng một thứ là linh
hoạt. Hai thẻ mà một cái bao trùm cái kia thì đó không còn là lựa chọn.

**Số thẻ đọc từ CFG, không gõ cứng.** `5_fortuneframe.lua` chia bề ngang theo
`#CFG.FORTUNE_KINDS`; thêm hay bớt một thẻ sau này không phải sửa giao diện.

### Hai thẻ còn lại song song, và đó là điểm chính

[ADR 0022](0022-tien-thi-phang-suc-manh-thi-leo.md) đã ghi: hai đường khác độ dốc
thì sớm muộn cũng cắt nhau. Nên phải kiểm.

```
the vang    60 vang tb -> 6 da (gia 10) -> 1.875 x 1.30^(r-1) diem
the chi so                                   2.2 x 1.30^(r-1) diem
```

**Cùng thừa số `1.30^(r-1)`** nên tỉ lệ đứng nguyên **1.17** ở cả 20 cảnh giới —
song song vĩnh viễn, không nhờ cân bằng khéo mà theo định nghĩa. Cùng thủ thuật
triệt tiêu thừa số của [ADR 0020](0020-duong-cong-quai-bam-theo-tu-vi.md).

Thẻ vàng phẳng về *danh nghĩa*, nhưng thứ nó mua — bậc Trang Bị — thì leo theo
`CULT_STAT_STEP` ([ADR 0024](0024-cong-thi-leo-nhan-thi-phang.md)), nên về *sức
mạnh* nó leo y hệt. Thẻ chỉ số hơn 17%, đúng phần nó xứng: nó trả ngay, không
qua xác suất, không qua trần Tu Vi.

## Phương án đã loại

**Nâng `FORTUNE_IRON` lên 15 theo đúng quy tắc `2.5 × số món`.** Đây là việc mà
chú thích trong code đang yêu cầu, và là phương án tốn ít công nhất. Bỏ vì nó
giữ nguyên bệnh gốc — vẫn ba đại lượng không so được, vẫn hai nguồn đá đánh nhau
— và làm thẻ đá thành lựa chọn hiển nhiên ở mọi lượt.

**Rút xuống còn MỘT thẻ (vàng).** Đề xuất trong lúc bàn, vì "dễ cân bằng hơn".
Bỏ vì một thẻ thì **không còn là chọn nữa** — nó thành drop. Cả khung ba cột,
luật ESC riêng, kiểu chọn lõi TFT đều là để phục vụ một quyết định mà phương án
này xoá mất. Và mất thẻ chỉ số là mất 40% sức mạnh cả ván, một lỗ phải bù chỗ
khác.

**Giữ ba thẻ nhưng quy cả ba về một đơn vị.** Cân được, nhưng ba thẻ cùng đơn vị
thì khác nhau ở mỗi con số — vẫn không phải ba lựa chọn khác *loại*.

## Hệ quả

- **Giá đá trong shop là núm duy nhất điều nhịp Trang Bị.** Vàng → shop → đá là
  đường ra đá duy nhất còn lại. Đổi `price` của mục `iron` trong `CFG.SHOP` là
  đổi toàn bộ tốc độ lên đồ. Đặt `10`, suy ra từ: thu nhập vàng cả ván 12 400,
  một món đi trọn 471 đá → mua được ~2.6 trong 8 món.
- **Thẻ Trang Bị thành một lựa chọn, không phải thanh tiến độ.** Tám món bày ra,
  tiền luôn chỉ đủ khoảng ba — và tỉ lệ đó đứng yên ~2.6 suốt ván, nên áp lực
  chọn không dồn về đầu hay cuối.
- **`CFG.FORTUNE_IRON` đã xoá.** Nhánh `"iron"` trong `makeCard()` vẫn còn để bật
  lại bằng một dòng CFG nếu cần; nó đọc `CFG.FORTUNE_IRON or 0` nên thiếu khoá
  thì trả 0 chứ không sập.
- **Thêm thẻ mới sau này = thêm một dòng vào `FORTUNE_KINDS` + một nhánh trong
  `makeCard()` và `take()`.** Giao diện không phải sửa. Nhưng thẻ mới phải kiểm
  lại tính song song ở trên, nếu không ADR 0022 sẽ lặp lại lần thứ ba.
