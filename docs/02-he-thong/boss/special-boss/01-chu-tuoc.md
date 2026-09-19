# 01. Chu Tước — *Vermilion Bird*

> **Phó bản — mốc Tu Vi 1** *(Phàm Nhân)* · unit `B001` · model `Chi-Ji` *(Hạc)*

> **Trạng thái:** cơ chế và chỉ số **đã vào `CFG.SIDE_QUESTS`**.
> Phần sinh boss và dịch chuyển **chưa thi hành** — còn chờ vùng
> `Quest1Arrive` / `Quest1Lair` được vẽ trong World Editor.

Con dạy bài của phó bản. Một đòn lao, một ngưỡng phát cuồng — đủ để dạy rằng phó bản không phải đợt quái đứng yên cho đánh.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Lao Tới** `charge` | Mỗi **11s**: lao thẳng vào hero **xa nhất**, gây `3×` một đòn thường. | Đừng tách đàn. Nó chọn người ở xa, nên hero đứng lẻ là hero bị chọn. Hệ số phát cuồng **có** nhân vào đòn này. |
| **Phát Cuồng** `enrage` | Máu xuống dưới **30%**: sát thương `×1.60` vĩnh viễn, boss chuyển đỏ và báo cả đội. | Ngưỡng này biến 30% máu cuối thành đoạn nguy hiểm nhất. Vào được 30% mà không kết liễu nổi thì nên rút — đòn của nó đã khác trước. |

## Chỉ số

**Đo đội, đúng lúc người chơi bước vào** — không phải lúc sinh ra.

```
mau = dps_ca_doi x %d giay
don = mau_hieu_dung_trung_binh / %d don
```

Bản đầu suy chỉ số từ **cảnh giới cửa**, nghĩ rằng đường cong Tu Vi sẽ tự lo
phần thứ tự. Sai hẳn — đo từ file vết, cảnh giới 16, một hero:

| | |
|---|---|
| chỉ số **thật** của hero | 30 105 |
| phần đến từ cảnh giới 16 | **511** — 1,7% |
| phần từ trang bị + kỹ năng | 29 594 — **gấp 59 lần** |

Cảnh giới gần như **không phải** sức mạnh của người chơi; trang bị và kỹ năng
mới là. Nên con đầu (cảnh giới 1, chưa trang bị) thì quá dài, ba con sau (đã full
trang bị) thì vỡ trong một nhịp.

Đo lúc **sinh** cũng không được: lúc vào map cả đội còn ở Phàm Nhân. Nên phép đo
chạy khi người chơi bấm *Tiến Hành* — và chỉ nạp lại khi con boss **đang đầy
máu**, nếu không người thứ hai bước vào giữa trận sẽ hồi đầy máu nó.

Thứ tự bị chặn bằng **nút khoá theo cảnh giới**, không bằng chỉ số.


## Thu phục

Hạ xong thì con này thành **pet** và **ghi đè** con đang có —
mỗi lúc chỉ một pet. Pet hiện **thuần trang trí**: đi theo hero,
không đánh, không chỉ số. Xem pet khi có.

Hạ xong cũng **tự đưa về nhà chính** — phần thưởng cho việc thắng,
và không phải vẽ thêm vùng nào.

← [Bốn Thánh Thú](README.md) · [20 boss thường](../normal-boss/README.md) · [Thiết kế chung](../../boss.md)
