# 04. Thanh Long — *Azure Dragon*

> **Phó bản — mốc Tu Vi 16** *(Tiên Đế)* · unit `B004` · model `Yu'lon` *(Rồng)*

> **Trạng thái:** cơ chế và chỉ số **đã vào `CFG.SIDE_QUESTS`**.
> Phần sinh boss và dịch chuyển **chưa thi hành** — còn chờ vùng
> `Quest4Arrive` / `Quest4Lair` được vẽ trong World Editor.

Bài thi cuối. Gom cả ba bài trước lại: phải né, phải chịu được đòn dội, phải kết liễu nhanh — cùng lúc.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Chấn Địa** `slam` | Mỗi **9s**: đứng yên **2s**, vòng tròn bán kính **600** hiện ra, rồi nổ `10×` một đòn thường lên mọi hero còn trong vòng. | Chia vai chứ không cùng chạy — tanker ở lại, carry và support chạy. Tâm nổ chốt lúc bắt đầu niệm nên chạy là thoát thật. [ADR 0023](../../../05-quyet-dinh/0023-chan-dia-khong-noi-cast-tanker-o-lai-chiu.md) |
| **Triệu Hồi** `summon` | Mỗi **20s**: gọi **4** thuộc hạ. | Thuộc hạ không tự hết. Bỏ mặc thì tới phút thứ ba trong phòng có mười mấy con, và lúc đó Chấn Địa mới là thứ giết người. |
| **Hút Máu** `lifesteal` | Hồi **25%** sát thương nó gây ra. | Ép ra một ngưỡng sát thương tối thiểu: dưới ngưỡng đó thì nó hồi nhanh hơn mình trừ, và trận kéo dài vô hạn. |
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
