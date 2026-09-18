# Hệ thống: Nhà chính & vùng địch

> **Trạng thái:** Đã cài — vùng đã có trong map
> **Cập nhật:** 2026-09-16
> **Code:** [1_house.lua](../../src/3_battle/1_house.lua), [4_geometry.lua](../../src/1_core/4_geometry.lua)
> **Khoá CFG:** `RGN_HOUSE` `RGN_ENEMY` `HOUSE_*`
> **Code thêm:** [1_events.lua](../../src/5_boot/1_events.lua), [1_player.lua](../../src/2_player/1_player.lua)

## Nó là gì

Hai mốc cố định trên bản đồ:

- **Nhà chính** — Mountain King dựng giữa vùng `MyHouseRegion`. Máu 1 000, tầm
  nhìn 1 500, không đánh được ai, **chết là thua**.
- **Vùng địch** — `MyEmenyRegion`, nơi quái ra. Đã nối vào hệ đợt quái:
  [2_wave.lua](../../src/3_battle/2_wave.lua) sinh quái quanh tâm vùng này.

> **Máu 1 000 chỉ đúng lúc mới dựng.** Từ đợt quái đầu tiên trở đi, máu nhà
> được **tính lại mỗi wave** theo `HOUSE_HP_HITS × sát thương một con lính ở
> stage đó` — `CFG.HOUSE_HP` chỉ còn là giá trị khởi tạo trước wave 1. Lý do và
> công thức: [dot-quai.md](dot-quai.md#thua).

## Bạn phải làm trước

Code **không tạo được vùng** — vùng là dữ liệu của World Editor. Chưa có vùng
thì vào map sẽ thấy dòng đỏ báo không tìm thấy.

1. World Editor → Region Palette (phím **R**).
2. Vẽ hai vùng: `MyHouseRegion` và `MyEmenyRegion`.
3. **Save map.**
4. `python build.py` — WE vừa ghi đè `war3map.lua`.
5. Ctrl+F9.

> **Đã vẽ rồi.** Tên thật trong map hiện là `MyHouseRegion` và **`MyEmenyRegion`**
> (thiếu chữ `n`). `CFG.RGN_ENEMY` nhận danh sách nên chạy được cả hai cách viết —
> sửa chính tả trong World Editor lúc nào cũng được, không phải đụng code.

`CFG.RGN_*` nhận **một tên hoặc một danh sách tên**, thử lần lượt: khớp chính xác
trước, rồi khớp không phân biệt hoa thường. Không tìm thấy thì vào map hiện dòng
đỏ liệt kê **mọi vùng World Editor thật sự có** — dòng này hiện kể cả khi
`CFG.DEBUG` tắt, vì gõ sai tên vùng là lỗi không thể đoán nếu chỉ báo "không thấy".

## Luật

**L1. Nhà dựng ở tâm vùng, không phải ở góc.**
`GetRectCenterX/Y`. Vùng to hay nhỏ không đổi vị trí nhà — chỉ tâm mới đổi.

**L2. Nhà đứng trên một slot riêng, không thuộc về ai.**
`CFG.HOUSE_SLOT = 3`. Nó là **đồng minh chung tầm nhìn** với cả ba người chơi, và
đối đầu với phe địch.

Slot riêng chứ không phải của người chơi 0, vì hai lý do: nhà là mục tiêu chung
nên không ai được "sở hữu" nó, và nếu chủ thoát game thì nhà sẽ thành vô chủ.

Chung tầm nhìn là **bắt buộc**, không phải trang trí — không có nó thì tầm nhìn
1 500 của nhà chẳng ai thấy được.

> Slot 3 không bật trong lobby của map. Unit vẫn dựng và hoạt động bình thường —
> đây đúng là cách các phe trung lập vận hành. Nếu muốn nó hiện thành một phe
> thật thì bật slot 3 làm Computer trong World Editor.

**L3. Nhà không đánh được ai.**
`CFG.HOUSE_CAN_ATTACK = false` → `UNIT_IF_ATTACKS_ENABLED = 0`. Mountain King mặc
định có đòn đánh cận chiến; không tắt thì nó tự lao vào đánh quái.

**L4. Nhà chết là cả ba người chơi thua ngay.**
`CFG.HOUSE_DEATH_ENDS_GAME`. Bắt bằng `EVENT_PLAYER_UNIT_DEATH` trong
[1_events.lua](../../src/5_boot/1_events.lua). Chờ 3 giây cho đọc được lý do rồi mới
hiện màn hình kết quả.

**L5. Người chơi không chọn được nhà chính.**
`CFG.HOUSE_SELECTABLE = false`. Nhà là mục tiêu phải giữ, không phải quân để điều
khiển — lọt vào Ctrl+A rồi lỡ ra lệnh cho nó là hỏng cả ván.

Chặn ở **hai tầng**, vì tầng thứ nhất đáng ra đã đủ mà thực tế vẫn lọt:

1. **Quyền điều khiển chung** — tắt tường minh bằng `SetPlayerAlliance` với
   `ALLIANCE_SHARED_CONTROL` và `ALLIANCE_SHARED_ADVANCED_CONTROL`.
   `bj_ALLIANCE_ALLIED_VISION` vốn đã tắt sẵn hai cờ này, nhưng đặt lại rõ ràng
   thì đọc code không phải tra xem hằng số BJ đó bật/tắt những gì.
2. **Bỏ chọn thủ công** — bắt `EVENT_PLAYER_UNIT_SELECTED`, thấy là nhà chính thì
   gỡ khỏi vùng chọn của người đó. Hoãn sang tick sau theo
   [ADR 0005](../05-quyet-dinh/0005-hoan-thao-tac-quay-hang.md).

> Warcraft III **không có** cách đánh dấu một unit là "không chọn được" mà vẫn cho
> kẻ địch đánh. Ability Locust làm nó vô hình với cả hai phía — mà nhà chết là
> thua, nên không dùng được. Bỏ chọn thủ công là đường duy nhất.
>
> Hệ quả nhìn thấy được: bấm trúng nhà thì nó **nhấp nháy chọn một khung hình**
> rồi bị bỏ. Không né được, vì phải đợi sự kiện chọn xảy ra mới biết mà gỡ.

**L6. Bất tử và "chết là thua" loại trừ nhau.**
`CFG.HOUSE_INVULNERABLE = false`. Bật `true` thì nhà không bao giờ chết, nên điều
kiện thua không bao giờ chạy — chỉ dùng khi cần test mà không sợ thua. Báo cáo
lúc vào map ghi rõ đang ở trạng thái nào.

## Nó là hero, không phải công trình

Mountain King (`Hmkg`) là **hero**. Ba khác biệt phải xử lý, nếu không sẽ hỏng
âm thầm:

**Máu hero suy ra từ Sức mạnh.** `BlzSetUnitMaxHP` đặt được 1 000, nhưng con số
đó **bị tính lại** mỗi khi hero lên cấp hoặc đổi chỉ số.

**Nên phải khoá kinh nghiệm.** `SuspendHeroXP(u, true)`, gọi **trước** khi đặt
máu. Đây là thứ giữ cho mốc 1 000 đứng yên. Bỏ `CFG.HOUSE_SUSPEND_XP` đi thì
nhà sẽ tự lên cấp khi quái chết gần nó, và máu trôi khỏi 1 000 lúc nào không hay.

**Hero có đòn đánh mặc định**, khác công trình. Xem L3.

## Tầm nhìn 1 500

Thử hai cách, theo thứ tự:

1. `BlzSetUnitRealField(u, UNIT_RF_SIGHT_RADIUS, 1500)` — sửa thẳng trường của
   unit. Cần patch 1.31+.
2. Không có thì dựng **fog modifier** bán kính 1 500 tại chỗ nhà đứng, cho từng
   người chơi. Nhà đứng yên nên một vùng sáng cố định là tương đương.

Báo cáo lúc vào map ghi rõ dùng cách nào (`qua truong unit` hoặc
`qua fog modifier`).

> Trường này chỉ đặt tầm nhìn ban ngày. Ban đêm Warcraft III dùng một trị số
> riêng — nếu ban đêm thấy hẹp hơn hẳn thì đó là lý do, chưa xử lý.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `RGN_HOUSE` `RGN_ENEMY` | Tên vùng trong WE | Phải khớp tên thật; sai thì xem danh sách in ra lúc vào map |
| `HOUSE_UNIT` | Unit làm nhà | `Hmkg` — Mountain King, là hero |
| `HOUSE_SLOT` | Slot sở hữu | **Không được** trùng `PLAYER_SLOTS` hay `ENEMY_SLOT`; code báo đỏ nếu trùng |
| `HOUSE_HP` | Máu tối đa | Cần 1.31+. Chỉ đứng yên khi đã khoá kinh nghiệm |
| `HOUSE_SIGHT` | Tầm nhìn | Ban ngày |
| `HOUSE_CAN_ATTACK` | Cho đánh không | `false`; cần 1.31+ để tắt |
| `HOUSE_SUSPEND_XP` | Khoá kinh nghiệm | `true` — giữ mốc máu |
| `HOUSE_INVULNERABLE` | Bất tử | `false`, vì chết là thua |
| `HOUSE_DEATH_ENDS_GAME` | Chết là thua | `true` |
| `HOUSE_SELECTABLE` | Người chơi chọn được không | `false` — chặn ở 2 tầng, xem L5 |
| `HOUSE_NAME` `HOUSE_FACE` `HOUSE_SCALE` | Tên hiện, hướng quay, cỡ | |

## Ràng buộc kỹ thuật

**Ba thứ cần patch 1.31+:** đặt máu (`BlzSetUnitMaxHP`), tắt đòn đánh
(`BlzSetUnitIntegerField`), đặt tầm nhìn (`BlzSetUnitRealField`). Code kiểm tra
tồn tại trước khi gọi, và **báo đỏ trong báo cáo** nếu thất bại. Riêng tầm nhìn
có đường lui bằng fog modifier nên luôn chạy được.

**Vùng WE là biến toàn cục `gg_rct_<Tên>`**, tạo trong `CreateRegions()` do
`main()` gọi. Bootstrap chạy sau khi `main()` xong nên lúc đó chúng đã tồn tại.
Đừng chuyển việc tra vùng lên sớm hơn.

**Nhà dựng sau khi có lưới**, để báo cáo được nó nằm ở block nào.

## Cách kiểm

Vào map với `CFG.DEBUG = true`, đọc khối `=== Vung & nha chinh ===`:

```
Vung WE thay duoc (2): MyEnemyRegion, MyHouseRegion
Nha chinh : -2,816, -3,072  -- block #7 (2,2)
  chu     : slot 3, dong minh voi 1 nguoi choi
  mau     : 1,000
  tam nhin: 1,500 qua truong unit
  don danh: da tat
  chet     : thua ngay
```

Dòng nào đỏ là thứ đó không chạy. Nếu nhà báo `duoi song` hoặc `ngoai luoi`,
vùng bạn vẽ đang nằm sai chỗ so với lưới — xem
[04-map/toa-do-ve-song.md](../04-map/toa-do-ve-song.md).

## Chưa làm

- Cho quái ra ở `MyEnemyRegion` — cố ý hoãn.
- Tầm nhìn ban đêm.
- Điều kiện **thắng**. Hiện chỉ có đường thua.
- Nhà không hồi máu, không sửa được.
