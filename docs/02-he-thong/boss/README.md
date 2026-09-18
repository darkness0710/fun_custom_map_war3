# Hai mươi boss

Mỗi cảnh giới một con, xuất hiện ở stage `(cảnh giới − 1) × 5 + 5`.

Khai báo ở `CFG.BOSSES`, con số cơ chế ở `CFG.BOSS_MECH`, mã ở
[3_boss.lua](../../../src/3_battle/3_boss.lua).

| # | Boss | Cảnh giới | Unit | Cơ chế |
|---|---|---|---|---|
| 1 | [Thi Giải Lão Tổ](01-thi-giai-lao-to.md) | Phàm Nhân | `Hmkg` | `slam` |
| 2 | [Đan Khí Chân Nhân](02-dan-khi-chan-nhan.md) | Luyện Khí | `Hpal` | `slam` · `shield` |
| 3 | [Trúc Cơ Thạch Linh](03-truc-co-thach-linh.md) | Trúc Cơ | `Ucrl` | `slam` · `reflect` |
| 4 | [Kim Đan Ma Quân](04-kim-dan-ma-quan.md) | Kim Đan | `Obla` | `charge` · `enrage` |
| 5 | [Nguyên Anh Quỷ Mẫu](05-nguyen-anh-quy-mau.md) | Nguyên Anh | `Udre` | `lifesteal` · `summon` |
| 6 | [Hoá Thần Vô Tướng](06-hoa-than-vo-tuong.md) | Hoá Thần | `Ewar` | `charge` · `shred` |
| 7 | [Luyện Hư Đạo Nhân](07-luyen-hu-dao-nhan.md) | Luyện Hư | `Hamg` | `shield` · `summon` |
| 8 | [Hợp Thể Cuồng Ma](08-hop-the-cuong-ma.md) | Hợp Thể | `Otch` | `slam` · `enrage` |
| 9 | [Đại Thừa Tôn Giả](09-dai-thua-ton-gia.md) | Đại Thừa | `Ekee` | `summon` · `reflect` |
| 10 | [Độ Kiếp Lôi Chủ](10-do-kiep-loi-chu.md) | Độ Kiếp | `Ofar` | `slam` · `charge` · `enrage` |
| 11 | [Chân Tiên Kiếm Khách](11-chan-tien-kiem-khach.md) | Chân Tiên | `Edem` | `charge` · `lifesteal` |
| 12 | [Thiên Tiên Tinh Quân](12-thien-tien-tinh-quan.md) | Thiên Tiên | `Emoo` | `shield` · `shred` |
| 13 | [Kim Tiên Bất Hoại](13-kim-tien-bat-hoai.md) | Kim Tiên | `Hpal` | `reflect` · `shield` |
| 14 | [Thái Ất Cửu Chuyển](14-thai-at-cuu-chuyen.md) | Thái Ất | `Ulic` | `summon` · `slam` |
| 15 | [Đại La Thiên Ma](15-dai-la-thien-ma.md) | Đại La | `Udea` | `lifesteal` · `enrage` · `shred` |
| 16 | [Tiên Đế Kim Thân](16-tien-de-kim-than.md) | Tiên Đế | `Hblm` | `slam` · `shield` · `enrage` |
| 17 | [Thánh Nhân Vô Ngã](17-thanh-nhan-vo-nga.md) | Thánh Nhân | `Oshd` | `reflect` · `lifesteal` |
| 18 | [Đạo Tổ Huyền Vi](18-dao-to-huyen-vi.md) | Đạo Tổ | `Nbrn` | `shred` · `summon` · `charge` |
| 19 | [Hỗn Độn Thần Ma](19-hon-don-than-ma.md) | Hỗn Độn Thần | `Nfir` | `slam` · `reflect` · `enrage` |
| 20 | [Sáng Thế Thần](20-sang-the-than.md) | Sáng Thế Thần | `Npbm` | `slam` · `charge` · `shred` · `enrage` |

## Tám cơ chế

| Cơ chế | Làm gì |
|---|---|
| **Chấn Địa** `slam` | Mỗi **9s**: đứng yên **2s**, vòng tròn bán kính **600** hiện ra tại chỗ, rồi nổ `10×` một đòn thường. Chạy ra là thoát. |
| **Hút Máu** `lifesteal` | Hồi lại **25%** sát thương nó gây ra. |
| **Phát Cuồng** `enrage` | Dưới **30%** máu, sát thương `×1.6` vĩnh viễn. |
| **Xé Giáp** `shred` | Mỗi đòn trúng cộng dồn **+2%** sát thương nhận vào **của riêng hero đó**. |
| **Triệu Hồi** `summon` | Mỗi **20s** gọi **4** thuộc hạ quanh mình. |
| **Lao Kích** `charge` | Mỗi **11s** dịch chuyển tới hero **XA NHẤT** và gây `3×` một đòn. |
| **Hộ Thể** `shield` | Mỗi **15s** tạo khiên hấp thụ bằng **12%** máu tối đa. |
| **Phản Đòn** `reflect` | Phản lại **15%** sát thương nhận vào, thẳng vào người đánh. |

Mỗi cơ chế một hàm trong [3_boss.lua](../../../src/3_battle/3_boss.lua);
con số đi kèm nằm trong `CFG.BOSS_MECH` để đọc một chỗ là thấy hết.

← [Thiết kế chung](../boss.md)
