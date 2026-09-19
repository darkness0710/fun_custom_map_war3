# Hệ thống: Nâng cấp Nhà Chính — thẻ VI, trả bằng vàng

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-19
> **Code:** [12_houseup.lua](../../src/2_player/12_houseup.lua) ·
> [2_wave.lua](../../src/3_battle/2_wave.lua) *(rescaleHouse)*
> **Khoá CFG:** `HOUSE_UP` `HOUSE_UP_MAX` `HOUSE_UP_PRICE0` `HOUSE_UP_STEP` `OP_HOUSE_UP`
> **Liên quan:** [nha-chinh.md](nha-chinh.md), [kinh-te.md](kinh-te.md)

## Nó là gì

Mở bảng bằng phím `ESC` rồi chọn thẻ **VI** — **một** đường nâng cấp, mua bằng
**vàng**, 10 cấp.

| Đường | Mỗi cấp | Tối đa |
|---|---|---|
| **Kiên Cố** | **+40 Sức Mạnh** cho Nhà Chính *(ở cảnh giới 1)* | +400 |

Giá cấp `n` = `HOUSE_UP_PRICE0 × HOUSE_UP_STEP^(n−1)` = `80 × 1.25^(n−1)`.

| Cấp | 1 | 2 | 4 | 6 | 8 | 10 |
|---|---|---|---|---|---|---|
| Giá | 80 | 100 | 156 | 244 | 381 | 596 |
| Cộng dồn | 80 | 180 | 461 | 901 | 1 587 | **2 660** |

### Hạ giá 2026-09-19 — từ `300 × 1.45ⁿ` xuống `80 × 1.25ⁿ`

Bản đầu đòi **26 723 vàng** cho trọn đường. Đó là một lỗi đo, không phải một
lựa chọn cân bằng:

**Vàng cả ván một người kiếm được là 4 000 – 14 140**
([kinh-te.md](kinh-te.md#vàng-cả-ván-một-người-kiếm-được-đo-2026-09-19)) — tức
giá cũ đòi **gần 2 lần tổng thu nhập tối đa**. Ngay cả khi lượt quay nào cũng
chọn vàng và không mua một viên đá nào thì vẫn không tới nổi cấp 9 (cộng dồn
18 223).

**Nặng hơn: vàng không phải đồng tiền thừa.** Nó mua **Đá Huyền Thiết**
(10 vàng/viên), mà trọn bộ Trang Bị ăn 4 000 viên = **40 000 vàng** — gấp 3 lần
tổng thu nhập. Vàng là đồng tiền *chật nhất* trong ván
([chi tiết](kinh-te.md#vàng-không-phải-đồng-tiền-chết-nó-là-đồng-tiền-chật-nhất)).

Nên thẻ VI phải là một món **bảo hiểm nhỏ**, không phải một nhánh tiến trình thứ
hai. 2 660 vàng = **29% thu nhập thực tế**, và bằng 266 viên đá tức **6,7% bộ
trang bị**. Đủ để là một lựa chọn thật mà không cướp hệ chính.

**Cấp 1 cố ý rẻ (80 vàng)** — phải mua được ngay cảnh giới đầu, lúc nhà yếu nhất
và người chơi chưa có gì khác để tiêu.

> **Con số đầu, chưa đo trận thật.** Đọc dòng `houseup:` trong
> `DarknessTrace.txt` — nó ghi tổng điểm, cảnh giới đang lấy làm mốc, và **máu
> mỗi điểm đo được**. Rồi chỉnh. Đừng đoán.

### Ba đường → một đường *(2026-09-19)*

Bản đầu có ba đường; đã bỏ hai và đổi đường còn lại:

| Đường cũ | Vì sao bỏ |
|---|---|
| **+12% máu tối đa** *(→ đổi thành Sức Mạnh)* | Nghe to mà cảm giác không thấy gì: ở cảnh giới 1 nó là **288 máu trên 2 400**, tức 48 đòn lính. Sức Mạnh thì ra một con số **nhìn thấy được** trên bảng chỉ số của nhà |
| **Hồi Phục** *(+4% hồi mỗi wave)* | Trùng việc với `HOUSE_REGEN_PER_WAVE` đã có sẵn |
| **Phản Sát** *(phản % máu tối đa)* | Thêm một trigger sát thương **toàn cục** cho một hiệu ứng nhỏ — không đáng |

### Số điểm leo theo cảnh giới

```
Sức Mạnh = cấp × HOUSE_UP[1].str × CULT_STAT_STEP^(cảnh giới cao nhất − 1)
```

Đây là [ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md): **cộng
thì leo, nhân thì phẳng.** Một con số điểm *phẳng* sẽ vô nghĩa ở cảnh giới 10 vì
máu nhà lúc đó bám theo đường cong quái. Nhân với `CULT_STAT_STEP^(bậc−1)` y hệt
cách Trang Bị cộng điểm.

**Lấy cảnh giới CAO NHẤT trong đội, không lấy trung bình.** Trung bình thì thêm
một người mới vào là nhà **yếu đi** — một luật không ai đoán được.

## Vì sao có hệ này — hai lý do đo được

**1. ~~Vàng gần như là đồng tiền chết.~~** — **SAI, đã bác bỏ 2026-09-19.**
Vàng mua **Đá Huyền Thiết** (10 vàng/viên) ở shop, và trọn bộ Trang Bị ăn 4 000
viên = **40 000 vàng**, trong khi cả ván kiếm tối đa 14 140. Vàng là đồng tiền
*chật nhất*, không phải thừa.

Lý do này sinh ra từ một cú `grep` thấy vàng chỉ tiêu ở shop rồi kết luận luôn —
mà không đọc xem **trong shop có gì**. Hệ vẫn giữ, nhưng nó đứng trên lý do thứ
hai chứ không phải lý do này, và giá đã hạ theo.

**2. Độ bền nhà chính là MỘT hằng số cho cả ván.** `HOUSE_HP_HITS = 400`, và
người chơi không có cách nào can thiệp — thứ duy nhất họ làm được là không để
quái lọt.

## Nhà chính **không** vỡ trong một hít — đây là số thật

Máu nhà tính lại **mỗi wave** trong `rescaleHouse()`:

```
máu tối đa = HOUSE_HP_HITS × sát thương một con lính ở stage đó
           = 400 × dmgOf(stage, realm)
```

Ở cảnh giới 1: `MOB_DMG_BASE = 6.0` → nhà có **2 400 máu**, tức **400 đòn** của
một con lính. Cộng `HOUSE_REGEN_PER_WAVE = 0.20` mỗi wave.

Vấn đề không phải một hít, mà là **số lượng**:

| Số con lọt | Nhà cầm được |
|---|---|
| 3 con | 133 giây |
| 50 con *(trọn một wave)* | **8 giây** |

`WAVE_MOB_COUNT = 50`. Cả wave lọt thì nhà chịu 8 giây, và **cộng thêm máu chỉ
kéo nó thành 12 giây** — đó là lý do hệ này không thể chỉ có Kiên Cố.

**Phản Sát mới là đường trả lời đúng câu hỏi:** càng nhiều con đánh thì càng
giết được nhiều, nên nó đánh thẳng vào *số lượng*, là cái thật sự giết nhà chính.

## Ba điều kỹ thuật phải làm đúng

### 1. Không được gọi `BlzSetUnitMaxHP` ngoài `rescaleHouse()`

`rescaleHouse()` chạy lại **mỗi wave** và tính `newMax` từ đầu. Bất cứ ai đặt
máu ngoài công thức đó đều bị xoá ở wave sau — và xoá **im lặng**.

Đường duy nhất đúng là để `rescaleHouse()` hỏi ngược qua `API.houseUpStr()`:

```lua
if API.houseUpStr ~= nil then
  local str = API.houseUpStr()
  if str > 0 then
    SetHeroStr(S.house, base + str, true)       -- cho NGƯỜI CHƠI thấy
    newMax = newMax + str * API.houseUpStrHp()  -- cho CÔNG THỨC quyết
  end
end
newMax = math.floor(newMax + 0.5)
BlzSetUnitMaxHP(S.house, newMax)                -- gọi SAU cùng
```

**Đặt Sức Mạnh thật lên unit rồi mới đặt max.** Người chơi bấm vào nhà thấy con
số đó trên bảng chỉ số, chứ không phải một con số chỉ tồn tại trong đầu ta. Nhưng
max thì vẫn do **công thức này** quyết định — `BlzSetUnitMaxHP` gọi sau cùng nên
nó thắng, dù Warcraft có tự tính lại max theo Sức Mạnh hay không. Một nguồn duy
nhất, không tranh chấp.

**Máu mỗi điểm Sức Mạnh thì ĐO, không gõ.** `probeHpPerStr()` chạy lúc vào map
trên chính con nhà chính: đọc gốc → đẩy lên 100 điểm → đọc lại → đặt về. Nhà đã
đi qua `BlzSetUnitMaxHP` lúc tạo nên không có gì bảo đảm Warcraft còn cho Sức
Mạnh đổi max — đo một lần thì biết chắc. Đo không được thì lùi về
`CFG.HOUSE_UP_STR_HP = 25.0` và **báo ra** trong file vết, không nuốt.

Riêng lúc **mua** thì gọi `API.waveRescaleHouse()` để máu đổi **ngay**: mua giữa
một wave đang bị dồn mà phải chờ hết wave mới thấy gì là mua trong bóng tối — và
đúng lúc đó thì người chơi cần nó ngay. Hàm đó giữ nguyên **tỉ lệ máu** đang có
nên nó không biến thành một nút hồi máu.

### 2. Cấp là **của chung**, không phải của từng người

Nhà chính chỉ có **một**, nên `S.houseUp` là một bảng duy nhất chứ không nằm
trong `S.p[pid]`. Một người mua, cả đội hưởng — cùng lý do với hai Pháp Khí cộng
vào nhà.

Lưu cấp vào `S.p[pid]` thì hai người cùng mua sẽ thành hai bộ cấp riêng, mà nhà
thì chỉ có một — cái nào thắng là tuỳ thứ tự gọi. Lỗi im lặng, kinh điển.

### 3. Bấm nút là **cục bộ**

Bấm frame chỉ chạy trên máy người bấm, nên **mua** phải đi qua `API.syncSend`
([ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md)) — nếu không máy
này trừ vàng và lên cấp còn máy kia thì không.

**Đã thử rồi bỏ: bấm chuột vào Nhà Chính để mở thẻ VI.** Một phím `ESC` đã đủ,
và một cửa vào nữa là thêm một hằng số (`EVENT_PLAYER_UNIT_SELECTED`) có thể
vắng mặt ở 1.31.1 cho không được gì. Cần làm lại thì xem `git log` của
[12_houseup.lua](../../src/2_player/12_houseup.lua).

## Một quyết định nhỏ, và lý do

**Mô tả nói GIÁ TRỊ ĐANG CÓ, không nói "mỗi cấp +40 điểm".** Người chơi cần biết
mình đang được bao nhiêu, chứ không phải tự nhân trong đầu. Cấp 0 hiện `0.0%` —
vẫn là một câu trả lời.

## Chưa làm

- **Chưa đo trận thật.** Giá và `per` là con số đầu.
- **Không có đường nào cho tầm nhìn hay tháp.** `HOUSE_CAN_ATTACK = false` và
  `HOUSE_FROZEN = true` — biến nhà thành đơn vị đánh được là một thay đổi lớn
  hơn nhiều, chưa đụng.
- **Một đường thì thẻ hơi trống.** Chấp nhận: thà một dòng nói đúng một việc còn
  hơn ba dòng mà hai dòng trùng việc với hệ khác.
- **Chồng lấn với Pháp Khí.** Hai mã `nhahp` (+30% máu) và `nharegen` (+15% hồi)
  vẫn nằm trong `rescaleHouse()` nhưng `CFG.RELIC` đang rỗng nên chúng luôn trả
  `false`. Khi thiết kế lại Pháp Khí phải quyết: giữ cả hai hệ, hay để thẻ VI
  thay hẳn.

← [Nhà chính & vùng địch](nha-chinh.md) · [Kinh tế](kinh-te.md)
