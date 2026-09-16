# 0019 — Mỗi vùng một cơ chế co-op riêng; cạn ý tưởng thì để rỗng

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-16
> **Thay thế bảng vai trò trong** [ADR 0014](0014-25-block-de-danh-cho-noi-dung-sau.md)
> (quyết định gốc của 0014 — hoãn lối chơi — **không đổi**)

## Bối cảnh

Bản phân vùng đầu tiên chia 25 block thành: 4 Phó Bản, 4 Thí Luyện, 4 Linh Mạch,
1 Đấu Đài, 10 Hoang Địa.

Nhìn vào bản đồ thì đầy đặn. Nhưng đọc kỹ thì đó là **ba ý tưởng chép bốn lần**:

```
21 Tong Mon   22 Pho Ban    23 Thi Luyen  24 Hoang Dia  25 Pho Ban
16 Ma Mon     17 Linh Mach  18 Hoang Dia  19 Linh Mach  20 Hoang Dia
11 Thi Luyen  12 Hoang Dia  13 Dau Dai    14 Hoang Dia  15 Thi Luyen
 6 Hoang Dia   7 Linh Mach   8 Hoang Dia   9 Linh Mach  10 Hoang Dia
 1 Pho Ban     2 Hoang Dia   3 Thi Luyen   4 Hoang Dia   5 Pho Ban
```

Bốn Phó Bản khác nhau ở **quãng đường phải chạy** và ở con số thưởng — không khác
gì ở *việc người chơi phải làm*. Làm xong cái đầu là biết hết ba cái sau. Mười hai
block, ba trải nghiệm.

Cách bào chữa lúc đó là "khoá theo cõi, khó dần". Nhưng độ khó tăng dần đã là việc
của đường cong chỉ số rồi — nó không biến một bản sao thành một vùng mới.

## Quyết định

**Mỗi vùng phải buộc cả ba người cùng làm, và mỗi vùng buộc theo một kiểu khác
nhau. Không nghĩ ra cơ chế mới thì để rỗng.**

Bốn vùng, bốn động từ:

| Động từ | Vùng | Block | Cơ chế |
|---|---|---|---|
| **chia ra rồi đồng bộ** | Tam Thể Trận | 13 | Boss chia ba thân ở ba góc. Thân chết lẻ thì hai thân kia hồi sinh nó — phải hạ cả ba trong một cửa sổ thời gian |
| **ba chỗ, giữ liên tục** | Linh Mạch | 17 | Ba trụ dẫn khí. Mạch chỉ chảy khi **cả ba** trụ có người đứng. Quái liên tục ra để đẩy người khỏi trụ |
| **mỗi người một vai** | Tam Đạo Môn | 3 | Ba cửa, mỗi cửa chỉ một **vai** qua được: Kim cần người chịu đòn, Mộc cần người giải, Hoả cần người phá nhanh |
| **một người bị khoá** | Trấn Ma Tháp | 5 | Một người phải đứng yên dẫn pháp — không đánh, không chạy. Hai người còn lại gồng cả trận, đổi phiên khi người đang dẫn sắp gục |

**19 block để rỗng.**

```
21 NHA       22  .       23  .       24  .       25  .
16 CUA       17 MACH     18  .       19  .       20  .
11  .        12  .       13 TAM THE  14  .       15  .
 6  .         7  .        8  .        9  .       10  .
 1  .         2  .        3 TAM DAO   4  .        5 TRAN MA
```

Xa nhà dần = khó dần. Nhà ở block 21: `17` cách 1 sông ngang + 1 dọc (vùng làm
thường xuyên nhất), `13` cách 2+2, `3` cách 2+4, `5` cách 4+4 — xa nhất, khó nhất.

### Ba cửa của Tam Đạo Môn dùng đúng ba hero đang có

`CFG.HEROES` đã có Hart (Warrior–Tanker), Hvwd (Shooter–Carry), Hkal
(Mage–Support). Tam Đạo Môn không phải bịa ra vai mới — nó **dùng cái đã có**, và
nhờ vậy nó cũng là lý do đầu tiên khiến việc ba người chọn ba hero khác nhau có
hậu quả thật.

## Phương án đã loại

**Giữ 12 vùng, làm chúng khác nhau bằng độ khó và phần thưởng.** Loại vì độ khó
đã là việc của đường cong chỉ số. Nhân bản một cơ chế rồi dán nhãn "khó hơn" chỉ
kéo dài thời gian, không thêm gì để nghĩ.

**Điền nốt 19 block bằng nội dung nhẹ** — bãi săn, rương, quái lang thang. Loại vì
đó vẫn là điền cho đầy. Một block hoang **không tốn gì**; một block chép lại tốn
đúng cái cảm giác mới mẻ của người chơi, và đó là thứ không mua lại được.

**Bỏ luôn 19 block đó, thu nhỏ bản đồ.** Đã loại ở
[ADR 0014](0014-25-block-de-danh-cho-noi-dung-sau.md) và lý do không đổi: giữ đất
trống rẻ hơn giành lại đất đã bỏ.

## Hệ quả

`CFG.BLOCK_ROLE[..].coop` — mỗi vai trò phải điền được **một câu** mô tả cơ chế
buộc ba người phối hợp. Vai trò nào không điền được ô đó thì chưa nên có.

Vai trò `hoang` cũng có `coop`, và nội dung của nó là *"Chưa có ý tưởng. Để rỗng
cho tới khi có."* — để người đọc code sau này biết đó là quyết định, không phải
chỗ chưa làm xong.

Thêm vùng mới sau này: viết cơ chế vào `coop` **trước**, rồi mới gán block. Nếu
câu đó đọc giống câu của một vùng đã có thì đó là dấu hiệu chưa nên thêm.
