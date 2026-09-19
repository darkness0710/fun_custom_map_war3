# 02. Huyền Vũ — *Black Tortoise*

> **Phó bản — mốc Tu Vi 6** *(Hoá Thần)* · unit `B002` · model `Niuzao` *(Trâu)*

> **Trạng thái:** cơ chế và chỉ số **đã vào `CFG.SIDE_QUESTS`**.
> Phần sinh boss và dịch chuyển **chưa thi hành** — còn chờ vùng
> `Quest2Arrive` / `Quest2Lair` được vẽ trong World Editor.

Bức tường. Nó không giết nhanh — nó bắt người chơi bỏ thói quen “đánh mạnh hơn là xong”, vì ở đây đánh mạnh hơn là tự giết mình.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Hộ Thể** `shield` | Mỗi **15s**: tạo khiên hấp thụ bằng **12% máu tối đa** của chính nó. | Khiên hấp thụ **trước** khi máu bị trừ, nên sát thương nhỏ lẻ bị nuốt sạch. Dồn burst vào ngay sau khi khiên vỡ. |
| **Phản Đòn** `reflect` | Dội lại **15%** sát thương nó nhận, thẳng lên người vừa đánh. | Đây là chỗ “đánh mạnh hơn” phản tác dụng: đòn càng to, cú dội càng đau. Hero máu mỏng burst vào đây là tự sát. |

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
