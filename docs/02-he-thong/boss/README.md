# Hai mươi boss

Mỗi cảnh giới một con, xuất hiện ở stage `(cảnh giới − 1) × 5 + 5`.

Khai báo ở `CFG.BOSSES`, con số cơ chế ở `CFG.BOSS_CO`, mã ở
[3_boss.lua](../../../src/3_tran_dau/3_boss.lua).

| # | Boss | Cảnh giới | Unit | Cơ chế |
|---|---|---|---|---|
| 1 | [Thi Giải Lão Tổ](01-thi-giai-lao-to.md) | Phàm Nhân | `Hmkg` | `chandia` |
| 2 | [Đan Khí Chân Nhân](02-dan-khi-chan-nhan.md) | Luyện Khí | `Hpal` | `chandia` · `khien` |
| 3 | [Trúc Cơ Thạch Linh](03-truc-co-thach-linh.md) | Trúc Cơ | `Ucrl` | `chandia` · `phandon` |
| 4 | [Kim Đan Ma Quân](04-kim-dan-ma-quan.md) | Kim Đan | `Obla` | `lao` · `cuong` |
| 5 | [Nguyên Anh Quỷ Mẫu](05-nguyen-anh-quy-mau.md) | Nguyên Anh | `Udre` | `hutmau` · `trieuhoi` |
| 6 | [Hoá Thần Vô Tướng](06-hoa-than-vo-tuong.md) | Hoá Thần | `Ewar` | `lao` · `xegiap` |
| 7 | [Luyện Hư Đạo Nhân](07-luyen-hu-dao-nhan.md) | Luyện Hư | `Hamg` | `khien` · `trieuhoi` |
| 8 | [Hợp Thể Cuồng Ma](08-hop-the-cuong-ma.md) | Hợp Thể | `Otch` | `chandia` · `cuong` |
| 9 | [Đại Thừa Tôn Giả](09-dai-thua-ton-gia.md) | Đại Thừa | `Ekee` | `trieuhoi` · `phandon` |
| 10 | [Độ Kiếp Lôi Chủ](10-do-kiep-loi-chu.md) | Độ Kiếp | `Ofar` | `chandia` · `lao` · `cuong` |
| 11 | [Chân Tiên Kiếm Khách](11-chan-tien-kiem-khach.md) | Chân Tiên | `Edem` | `lao` · `hutmau` |
| 12 | [Thiên Tiên Tinh Quân](12-thien-tien-tinh-quan.md) | Thiên Tiên | `Emoo` | `khien` · `xegiap` |
| 13 | [Kim Tiên Bất Hoại](13-kim-tien-bat-hoai.md) | Kim Tiên | `Hpal` | `phandon` · `khien` |
| 14 | [Thái Ất Cửu Chuyển](14-thai-at-cuu-chuyen.md) | Thái Ất | `Ulic` | `trieuhoi` · `chandia` |
| 15 | [Đại La Thiên Ma](15-dai-la-thien-ma.md) | Đại La | `Udea` | `hutmau` · `cuong` · `xegiap` |
| 16 | [Tiên Đế Kim Thân](16-tien-de-kim-than.md) | Tiên Đế | `Hblm` | `chandia` · `khien` · `cuong` |
| 17 | [Thánh Nhân Vô Ngã](17-thanh-nhan-vo-nga.md) | Thánh Nhân | `Oshd` | `phandon` · `hutmau` |
| 18 | [Đạo Tổ Huyền Vi](18-dao-to-huyen-vi.md) | Đạo Tổ | `Nbrn` | `xegiap` · `trieuhoi` · `lao` |
| 19 | [Hỗn Độn Thần Ma](19-hon-don-than-ma.md) | Hỗn Độn Thần | `Nfir` | `chandia` · `phandon` · `cuong` |
| 20 | [Sáng Thế Thần](20-sang-the-than.md) | Sáng Thế Thần | `Npbm` | `chandia` · `lao` · `xegiap` · `cuong` |

## Tám cơ chế

| Cơ chế | Làm gì |
|---|---|
| **Chấn Địa** `chandia` | Mỗi **9s** gây `2.5×` một đòn thường lên mọi hero trong bán kính **420**. |
| **Hút Máu** `hutmau` | Hồi lại **25%** sát thương nó gây ra. |
| **Phát Cuồng** `cuong` | Dưới **30%** máu, sát thương `×1.6` vĩnh viễn. |
| **Xé Giáp** `xegiap` | Mỗi đòn trúng cộng dồn **+2%** sát thương nhận vào **của riêng hero đó**. |
| **Triệu Hồi** `trieuhoi` | Mỗi **20s** gọi **4** thuộc hạ quanh mình. |
| **Lao Kích** `lao` | Mỗi **11s** dịch chuyển tới hero **XA NHẤT** và gây `3×` một đòn. |
| **Hộ Thể** `khien` | Mỗi **15s** tạo khiên hấp thụ bằng **12%** máu tối đa. |
| **Phản Đòn** `phandon` | Phản lại **15%** sát thương nhận vào, thẳng vào người đánh. |

Mỗi cơ chế một hàm trong [3_boss.lua](../../../src/3_tran_dau/3_boss.lua);
con số đi kèm nằm trong `CFG.BOSS_CO` để đọc một chỗ là thấy hết.

← [Thiết kế chung](../boss.md)
