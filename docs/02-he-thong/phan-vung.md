# Hệ thống: Phân vùng 25 block

> ⛔ **Số trong tài liệu này tính theo `WAVE_TIME`, khoá đã xoá ngày 2026-09-18.**
> Nhịp cả ván giờ do người chơi gọi, nên **thời lượng ván không tính trước được
> nữa** — chỉ đo sau trận chơi thử. Lập luận giữ nguyên; con số là lịch sử.
> [ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md)

> **Trạng thái:** Bản đồ đã chốt — **chưa cài lối chơi nào**
> **Cập nhật:** 2026-09-16
> **Code:** [1_config.lua](../../src/1_core/1_config.lua) (`CFG.BLOCKS`),
> [4_geometry.lua](../../src/1_core/4_geometry.lua) (tra cứu),
> [w3region.py](../../w3region.py) (sinh vùng)
> **Khoá CFG:** `BLOCKS` `BLOCK_ROLE` `BLOCK_RGN_PREFIX`
> **Xem kèm:** [ADR 0014](../05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md) ·
> [kinh-te.md](kinh-te.md) · [luoi-25-o.md](../04-map/luoi-25-o.md)

## Nó là gì

Lưới 25 block trước đây chỉ tồn tại dưới dạng **toạ độ** tính lúc chạy. World
Editor không nhìn thấy chúng, nên không cách nào cầm chuột mà sửa.

Giờ có hai thứ:

1. **25 vùng thật** trong `war3map.w3r`, tên `Blk01`…`Blk25`. Mở World Editor →
   phím **R** → thấy đủ, kéo thả và đổi kích thước được.
2. **Một bảng vai trò** trong `CFG.BLOCKS` — block nào định làm gì.

**Chưa hệ nào gắn vào block.** Trang này là *bản đồ*, không phải *lối chơi*. Nó
tồn tại để khi bắt tay vào làm thì không phải quyết lại từ đầu.

## Tên vùng là VỊ TRÍ, vai trò nằm trong CFG

`Blk13` đời đời là `Blk13`. "Đây là đấu đài" sống trong `CFG.BLOCKS[13]`.

Tách như vậy vì hai thứ đổi với nhịp rất khác nhau: vị trí thì gần như không bao
giờ đổi, còn vai trò thì sẽ đổi nhiều lần trước khi chốt. Nếu đặt tên vùng theo
vai trò thì mỗi lần đổi ý là sửa file nhị phân, mở lại World Editor, và làm gãy
mọi tham chiếu `gg_rct_<Tên>` đang có.

## Bản đồ

```
       c1          c2          c3          c4          c5
 r5   21 NHÀ       22  ·       23  ·       24  ·       25  ·
 r4   16 CỬA       17 MẠCH     18  ·       19  ·       20  ·
 r3   11  ·        12  ·       13 TAM THỂ  14  ·       15  ·
 r2    6  ·         7  ·        8  ·        9  ·       10  ·
 r1    1  ·         2  ·        3 TAM ĐẠO   4  ·        5 TRẤN MA
```

**Bốn vùng, bốn cơ chế khác nhau. 19 block để rỗng.**
[ADR 0019](../05-quyet-dinh/0019-moi-vung-mot-co-che-co-op.md)

| Động từ | Vùng | Block | Cơ chế buộc ba người | Cho |
|---|---|---|---|---|
| **chia ra rồi đồng bộ** | Tam Thể Trận | 13 | Boss chia ba thân ở ba góc. Thân chết lẻ thì hai thân kia hồi sinh nó — phải hạ **cả ba trong một cửa sổ thời gian** | Tinh Thạch |
| **ba chỗ, giữ liên tục** | Linh Mạch | 17 | Ba trụ dẫn khí. Mạch chỉ chảy khi **cả ba** trụ có người đứng; quái liên tục ra để đẩy người khỏi trụ | Linh Khí |
| **mỗi người một vai** | Tam Đạo Môn | 3 | Ba cửa, mỗi cửa chỉ một **vai** qua được: Kim cần người chịu đòn, Mộc cần người giải, Hoả cần người phá nhanh | Ngộ Tính |
| **một người bị khoá** | Trấn Ma Tháp | 5 | Một người đứng yên dẫn pháp — không đánh, không chạy. Hai người còn lại gồng cả trận, đổi phiên khi người đang dẫn sắp gục | Tinh Thạch |
| — | Tông Môn | 21 | nhà chính | — |
| — | Ma Môn | 16 | cửa quái | — |
| — | Hoang Địa | 19 block | *(chưa có ý tưởng — để rỗng)* | — |

Xa nhà dần = khó dần. Nhà ở block 21: `17` cách 1 sông ngang + 1 dọc (vùng làm
thường xuyên nhất), `13` cách 2+2, `3` cách 2+4, `5` cách 4+4 — xa nhất.

## Vì sao chỉ bốn vùng, và vì sao 19 block để rỗng

Bản đầu tiên có 4 Phó Bản + 4 Thí Luyện + 4 Linh Mạch. Nhìn thì đầy đặn, nhưng đó
là **ba ý tưởng chép bốn lần**: bốn Phó Bản chỉ khác nhau ở quãng đường phải chạy
và ở con số thưởng, không khác ở *việc người chơi phải làm*. Mười hai block, ba
trải nghiệm.

Luật thay thế:

> **Mỗi vùng phải buộc cả ba người cùng làm, và buộc theo một kiểu khác nhau.
> Không nghĩ ra cơ chế mới thì để rỗng.**

Một block hoang không tốn gì. Một block chép lại tốn đúng cái cảm giác mới mẻ của
người chơi — thứ không mua lại được.

### Tam Đạo Môn dùng đúng ba hero đang có

`CFG.HEROES` đã có Hart (Warrior–Tanker), Hvwd (Shooter–Carry), Hkal
(Mage–Support). Ba cửa không phải bịa ra vai mới — chúng **dùng cái đã có**, và
nhờ vậy đây là lý do đầu tiên khiến việc ba người chọn ba hero khác nhau có hậu
quả thật.

### Ba đồng tiền vẫn được cấp thêm nguồn

| Đồng tiền | Kiếm cả ván | Tiêu hết | Dư | Vòi thứ hai |
|---|---|---|---|---|
| Linh Khí | ~1 880 000 | 92% | 8% | **Linh Mạch** |
| Ngộ Tính | 300 | 283 | **6%** | **Tam Đạo Môn** |
| Tinh Thạch | 1 150 | 1 050 | **9%** | **Tam Thể Trận · Trấn Ma Tháp** |

Hụt một boss ở cảnh giới 7 là **vĩnh viễn** không mua nổi Pháp Khí thứ năm — hiện
không có cách nào gỡ. Hai vùng trả Tinh Thạch là cách gỡ.

## Luật

**L1. Mỗi loại vùng phải trả lời được "tại sao tôi rời nhà?"**
Đợt quái không dừng khi người chơi đi. Rời nhà là rủi ro thật, nên phần thưởng
phải thắng được "ở lại thủ". Vùng nào không trả lời được câu này thì đừng làm.

**L2. Mỗi vai trò phải điền được ô `coop`.**
Một câu mô tả cơ chế buộc ba người phối hợp. Vai trò nào không điền được ô đó thì
chưa nên có. Nếu câu đó đọc giống câu của một vùng đã có — đó là dấu hiệu đang
chép, không phải đang thêm.

Vai trò `hoang` cũng có `coop`, nội dung là *"chưa có ý tưởng, để rỗng"* — để
người đọc code sau biết đó là quyết định, không phải chỗ chưa làm xong.

**L3. Block không khai báo trong `CFG.BLOCKS` là "hoang".**
`API.blockRole()` trả `"hoang"` chứ không trả `nil` — gọi bên ngoài không phải
kiểm `nil` trước mỗi lần dùng.

**L4. Trang này không đổi đường đi của quái.**
Quái vẫn ra ở `MyEmenyRegion` (block 16) và đi thẳng tới nhà (block 21). Phương án
B của [dot-quai.md](dot-quai.md#đường-đi) vẫn để ngỏ, độc lập với phân vùng.

## Cách kiểm

Lệnh **`-vung`** trong game (luôn đăng ký, không theo `DEV_COMMANDS`):

- In bản đồ 5×5 kèm vai trò, **từ hàng trên xuống** — đúng chiều nhìn bản đồ.
- Ping minimap tâm 25 block, màu theo vai trò (`CFG.BLOCK_ROLE[..].mau`).
- Báo đỏ nếu thiếu vùng `Blk..` trong World Editor, kèm lệnh phải chạy.

Đây là cách duy nhất nhìn thấy `CFG.BLOCKS` có đúng như định không — vì chưa hệ
nào gắn vào block, không có gì khác để mà quan sát.

## Sinh lại 25 vùng

```
python w3region.py list          # in các vùng đang có, kèm block chứa nó
python w3region.py gen --dry     # xem trước, không ghi
python w3region.py gen           # sinh/làm mới Blk01..Blk25
```

Chạy lại bao nhiêu lần cũng ra một kết quả: vùng `Blk*` bị sinh lại từ đầu, mọi
vùng khác giữ nguyên. Bản cũ chép vào `build/war3map.w3r.goc`.

Công cụ đọc ngược file sau khi ghi để chắc chắn đúng định dạng — `.w3r` sai là
World Editor có thể **lặng lẽ nuốt mất vùng**, kiểu hỏng tệ nhất vì không báo gì.

> **Đóng World Editor trước khi chạy.** Nó giữ bản map trong bộ nhớ; Save sau đó
> là ghi đè mất. Cùng cái bẫy mà `build.py` đã cảnh báo.

## Đo được: bản đồ đang thừa 80%

| | |
|---|---|
| Bản đồ rộng | 27 136 đơn vị |
| Quái đi từ cửa tới nhà | **5 361 đơn vị** |
| Tỉ lệ bản đồ thực sự dùng | **20% một trục, ở một góc** |

Nhà (block 21) và cửa quái (block 16) nằm **kề nhau**. 23 block còn lại chưa từng
có ai đặt chân tới.

### Và quãng đường đó từng ngắn tới mức làm hỏng một cơ chế

Phép đo này là thứ lôi ra [ADR 0018](../05-quyet-dinh/0018-nghi-giua-hai-canh-gioi.md).

| Cõi | Mẫu lính | Tốc | Đi hết vùng địch → nhà |
|---|---|---|---|
| 1 Phàm | Footman | 270 | **19.9s** |
| 2 Yêu | Ghoul | 350 | 15.3s |
| 3 Tiên | Abomination | 190 | **28.2s** |
| 4 Thần | Frost Wyrm | 200 | 26.8s |

> **Cột `WAVE_TIME` đã bỏ khỏi bảng này (2026-09-19).** Hệ đợt theo đồng hồ
> không còn — đợt chỉ ra khi người chơi bấm nút, và chỉ bấm được khi đã dọn
> sạch ([ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md)). Lỗi
> cũ mà phép đo này phát hiện — cõi 1 chỉ còn 0,1 giây để giết 50 con nên map
> không bao giờ sạch — **tự biến mất** khi bỏ đồng hồ.

**Nhưng quãng đường vẫn là con số đáng biết**, vì nó là sàn thời gian của một
đợt: không ai dọn xong trước khi con lính đầu tiên đi hết đường. Đổi
`CFG.MOB_UNIT` là phải đo lại bảng này.

> **Đính chính.** Bản trước của trang này khuyên "dời `MyEmenyRegion` **xa hơn**".
> Sai ngược: xa hơn là đi lâu hơn, càng ít thời gian đánh. Muốn có chỗ thở thì
> phải **gần hơn**, hoặc tăng `WAVE_TIME` — và đó là cách đã chọn.

Cái phải trả: ván dài thêm **16 phút** (118 → 134). Xem
[dot-quai.md](dot-quai.md#nhịp-do-người-chơi-bấm-không-có-đồng-hồ).

## Chưa làm

- **Toàn bộ lối chơi.** Bốn vùng mới có tên, vị trí và một câu cơ chế; không vùng
  nào có một dòng code.
- Cơ chế "đang đứng ở block nào" — bắt sự kiện vào/ra vùng.
- **19 block hoang.** Để rỗng có chủ ý cho tới khi có cơ chế co-op thứ năm —
  [ADR 0019](../05-quyet-dinh/0019-moi-vung-mot-co-che-co-op.md).
- `MyTarvenRegion` không còn dùng — nằm trong block 1, xoá lúc nào cũng được.

Khi bắt tay vào, làm **một vùng** rồi chơi thử. Linh Mạch là vùng rẻ nhất: ba trụ
là ba unit, "có người đứng không" là một phép đếm trong vùng, không cần Object
Editor.
