# Thiết kế hero

> **Trạng thái:** Hart **đã chốt, vỏ đã sinh**. Hvwd và Hkal ⏸ **trống — chờ thiết kế lại**
> **Cập nhật:** 2026-09-19
> **Code:** [4_skill.lua](../../src/2_player/4_skill.lua) ·
> [7_effect.lua](../../src/2_player/7_effect.lua) ·
> [w3skill.py](../../w3skill.py)
> **Số liệu:** [nâng cấp kỹ năng](../03-du-lieu/nang-cap-ky-nang.md) ·
> [kinh-te.md](kinh-te.md)
> **Liên quan:** [chon-hero.md](chon-hero.md), [ky-nang.md](ky-nang.md)

Trang này ghi **cái đang có trong map**, không ghi đề xuất.

---

## Ba class, nói thẳng

| Hero | ID | Vai | Kỹ năng | Chơi được |
|---|---|---|---|---|
| **Hart** | `H001` | Warrior — Tanker | **7, đủ vỏ và ruột** | ✅ đầy đủ |
| **Hvwd** | `H002` | Shooter — Carry | **0** | Chọn được, **không có nút nào** |
| **Hkal** | `H003` | Mage — Support | **0** | Chọn được, **không có nút nào** |

Chọn Hvwd hoặc Hkal thì thẻ Kỹ Năng trong bảng phím R hiện đúng một dòng:
*"Chưa có hero, hoặc hero này chưa khai báo kỹ năng."* Hero vẫn đánh thường được.

> **Bộ 21 kỹ năng từng thiết kế cho cả ba hero đã bị xoá khỏi trang này**
> (2026-09-16), theo yêu cầu — chủ dự án cần nghĩ lại từ đầu về bản sắc hình ảnh
> trước khi thiết kế tiếp. Bản cũ còn trong lịch sử git nếu cần tra.

---

# Hart — Tanker

**Đã chốt.** Bộ này là bộ chính thức, không phải bản nháp.

| Ô | Kỹ năng | Loại | Bậc 1 | Bậc 10 |
|---|---|---|---|---|
| **(1,1)** | **Chưởng** *(Palm Strike)* | chủ động · đường thẳng | ×1.32 · 8.0s · 25 mana | ×1.76 · 5.3s · 38 mana |
| **(2,1)** | **Hộ Thể** *(Guarding Light)* | chủ động · hồi máu | ×2.20 · 10.0s · 30 mana | ×2.93 · 6.7s · 46 mana |
| **(3,1)** | **Bất Hoại** *(Indestructible)* | chủ động · tự buff | **+30 giáp**, 12 giây · 60.0s · 60 mana | 40.0s · 93 mana |
| **(0,2)** | **Chém Lan** *(Cleaving Blow)* | bị động · trên mỗi đòn | 20% văng sang bên | **40%** |
| **(1,2)** | **Hiệu Lệnh** *(Rallying Order)* | bị động · aura đồng đội | **+5% tốc đánh, +5% tốc chạy** · bán kính 850 | **+50%** cả hai · bán kính 1350 |
| **(2,2)** | **Luyện Thể** *(Body Forging)* | bị động · chỉ số | **+4 phẳng** cả ba chỉ số *(×bậc Tu Vi)* | **+8** |
| **(3,2)** | **Da Sắt** *(Ironhide)* | bị động · **hồi sinh** | chết thì tự sống lại · hồi chiêu **270s** | hồi chiêu **45s** |

**Không cái nào phát sẵn** *(`CFG.SKILL_START_COUNT = 0`)*, nhưng hero **cầm sẵn
2 Ngộ Tính** *(`CFG.LUMBER_START = 2`)* — vừa đủ mở **một** kỹ năng sát thương
**và** Luyện Thể ngay giây đầu.
Mở khoá 1 điểm, đôn một bậc 1 điểm, thứ tự nào cũng được; trọn bảy cái là
`7 × (1 + 9) = 70` điểm trên 300 kiếm được cả ván.

## Hai kỹ năng đổi bản chất *(2026-09-19)*

`A003` và `A006` không còn là bản sao tự tính nữa. Chúng là **bản sao ability
gốc của Warcraft**, và **World Editor giữ toàn bộ bảng 10 bậc**:

| Ô | Kỹ năng | Ability gốc | Code đọc số bằng |
|---|---|---|---|
| (1,2) | Hiệu Lệnh | `AOae` Endurance Aura | `BlzGetUnitAbility` + `BlzGetAbilityRealLevelField` |
| (3,2) | Da Sắt | `AOre` Reincarnation | `BlzGetAbilityCooldown` |

Code **không** tự tính lại. Tự tính là có **hai nơi** cùng khai một con số, và
hai nơi thì sớm muộn lệch — người chơi đọc một đằng, đánh ra một nẻo. Xem
[nang-cap-ky-nang.md](../03-du-lieu/nang-cap-ky-nang.md).

### Bảng thật, đọc từ `war3map.w3a`

**Hiệu Lệnh** — `Oae2` tốc đánh, `Oae1` tốc chạy, `aare` bán kính:

| Bậc | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| tốc đánh `Oae2` | *5%* | *10%* | *15%* | 20% | 25% | 30% | 35% | **50%** ⚠ | 45% | 50% |
| tốc chạy `Oae1` | 5% | 10% | 15% | 20% | 25% | 31% | 35% | 40% | 45% | 50% |
| bán kính `aare` | 850 | 950 | 1000 | 1050 | 1100 | 1150 | 1200 | 1250 | 1300 | 1350 |

**Da Sắt** — `acdn` hồi chiêu; `Ore1` phẳng 5.0 và `acas` phẳng 3.0 ở mọi bậc:

| Bậc | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| hồi chiêu | 270s | 250s | 210s | 180s | 150s | 120s | 90s | 75s | 60s | 45s |

### Một ô lệch — cần sửa trong World Editor

**Tốc đánh bậc 8 = 50%** trong khi bậc 7 = 35% và bậc 9 = 45%. Dãy đang đi lên
thì bậc 8 nhảy vọt **qua** bậc 9 rồi tụt lại — gần như chắc là gõ nhầm `0.40`
thành `0.50`.

Đây là số **trong Object Editor**, không sửa bằng Lua được — xem
[ADR 0008](../05-quyet-dinh/0008-ky-nang-hero-phai-sua-o-object-editor.md). Đọc lại
sau khi sửa: `python w3obj.py dump test2.w3x/war3map.w3a`.

### Ô in nghiêng = không nằm trong map

Ba ô *5% / 10% / 15%* của tốc đánh bậc 1–3 **không có entry trong
`war3map.w3a`**. World Editor vẫn hiện số cho chúng, vì giá trị rơi về ability
**gốc** `AOae` — WE chỉ ghi vào map những ô anh đặt **khác** gốc.

Nên "ô trống trong dump" *không* có nghĩa là hỏng. Cách duy nhất để ghim một giá
trị vào map là đặt nó **khác** gốc; đặt đúng bằng gốc thì WE không lưu, và bậc
đó sẽ đi theo ability gốc nếu Blizzard đổi.

### Hai trường này giống hệt nhau trừ hai bậc — nên có một phép thử

Tốc đánh và tốc chạy trùng số ở 8/10 bậc. Chúng chỉ khác ở:

| Bậc | tốc đánh `Oae2` | tốc chạy `Oae1` |
|---|---|---|
| 6 | 30% | **31%** |
| 8 | **50%** | 40% |

Hai bậc lệch nhau này là cái **phân biệt được hai trường**, và nhờ đó phát hiện
ra tên hằng số của Blizzard đặt ngược.

`CFG.SKILLS` khai `fromAbil = "ABILITY_RLF_ATTACK_SPEED_INCREASE_OAE1"` — theo
tên thì `Oae1` là tốc đánh. **Sai.** Đối chiếu Object Editor với dump
`war3map.w3a`: bậc 8 tốc đánh = 0.50, tốc chạy = 0.40; file ghi `Oae2` = 0.5,
`Oae1` = 0.4. Tooltip gốc nói cùng một điều — `DataA` là *movement*, `DataB` là
*attack*. Vậy **`Oae2` = tốc đánh**.

### Hằng số đó không tồn tại ở 1.31.1 — đã đo

Dòng `-nat` trong file vết:

```
native [Doc so cua Endurance Aura (A003)] co 2/4 -- THIEU
    ABILITY_RLF_ATTACK_SPEED_INCREASE_OAE1
    ABILITY_RLF_MOVEMENT_SPEED_INCREASE_OAE2
```

Hai **hằng số** vắng mặt; `BlzGetAbilityRealLevelField` thì **có** — nó chỉ
thiếu cái handle trường để đưa vào. Hệ quả cũ: bảng `R` hiện *"bậc N"* thay vì
`%` thật, tức toàn bộ bảng số anh gõ trong World Editor không hiện ra đâu cả.

**Đường vòng đã cài:** `ConvertAbilityRealLevelField(FourCC("Oae2"))` dựng handle
thẳng từ mã trường 4 ký tự, không cần hằng số có tên. Khoá mới
`CFG.SKILLS[..].fromField = "Oae2"`. Bản nào không có hàm chuyển thì vẫn lui về
*"bậc N"* và ghi `API.trace` — không nuốt.

`A006` không dính lỗi này: nó đọc bằng `BlzGetAbilityCooldown`, và native đó có
(2/4 còn lại chính là nó và `BlzGetAbilityRealLevelField`).

Chạy `-nat oae` một lần để xem `ConvertAbilityRealLevelField` có mặt không.

## Phím tắt

| Phím | Kỹ năng |
|---|---|
| **Q** | Chưởng *(Palm Strike)* |
| **W** | Hộ Thể *(Guarding Light)* |
| **E** | Bất Hoại *(Indestructible)* |
| **R** | mở bảng nhân vật *(`CFG.PANEL_KEY`)* |

Bốn kỹ năng bị động không có phím — không bấm được thì không cần phím.

Phím khai ở `phim = "Q"` trong `CFG.SKILLS`, và [w3skill.py](../../w3skill.py)
ghi nó vào `ahky` của `war3map.w3a`. Warcraft **không** tự in phím tắt ra
tooltip, nên `w3skill.py` cũng ghi `atp1` *(Tooltip - Normal)* thành
`Palm Strike [Q]`. Trước đó `atp1` chưa ai ghi nên nó thừa kế từ ability gốc:
rê chuột vào "Chưởng" thì game nói *Shockwave*.

## Bố cục command card

**Đã đo** bằng ảnh chụp trong game (2026-09-16), không còn là trí nhớ: lệnh cơ
bản chiếm trọn hàng `y=0` và ô `(0,1)`. Bảy ô còn lại vừa đúng bảy kỹ năng.

```
Y=0   Move   │  Hold  │ Attack │  Stop   │   ← lệnh cơ bản, 4 ô
Y=1  Patrol  │HiệuLệnh│LuyệnThể│ Da Sắt  │   ← lệnh cơ bản + 3 bị động
Y=2 Chưởng Q │Hộ Thể W│BấtHoại E│Chém Lan│   ← 3 chủ động + 1 bị động
```

Quy ước: **hàng `y=2` là hàng duy nhất đủ bốn ô liền nhau**, nên ba kỹ năng chủ
động Q W E nằm ở đó theo đúng thứ tự phím, rồi một bị động lấp chỗ thứ tư. Ba bị
động còn lại lên `y=1` — xếp sao cũng được, chúng không có phím tắt.

Giữ nguyên cho mọi hero sau này thì đổi hero không phải học lại vị trí tay.

> Ô khai ở `O_CHUDONG` / `O_BIDONG` trong [w3skill.py](../../w3skill.py), sửa
> xong chạy `python w3skill.py gen --lang en`. Muốn đo lại bất cứ lúc nào thì
> gõ **`-nat card`** trong game — nó đọc
> `ABILITY_IF_BUTTON_POSITION_NORMAL_X/Y` trên chính con hero đang cầm rồi báo
> ô nào bị hai kỹ năng cùng nhận.
>
> **Lệnh cơ bản không đọc được bằng trường này.** Đo được: `Amov` và `Aatk`
> đều trả về `(0,0)`, còn `Astp` / `Ahol` / `Apat` thì unit không hề có như một
> ability — vị trí thật của chúng do game quyết định. Nên `-nat card` in chúng
> ra màu xám kèm chữ *"game tự đặt, số này không tin được"* và **chỉ đếm trùng
> ô giữa bảy kỹ năng**. Bản đầu của lệnh đếm cả lệnh cơ bản và báo động giả.

## Vỏ ability: đã sinh bằng script

Trước 2026-09-16, **6 trong 7 ability không có tên, tooltip hay vị trí ô riêng** —
chúng hiện nguyên tên Blizzard. Rê chuột vào "Chưởng" thì game nói *Shockwave*, và
mô tả là mô tả Shockwave. Sáu cái cũng không đặt ô nên nằm ở vị trí mặc định của
ability cha, có nguy cơ đè lên nhau.

[w3skill.py](../../w3skill.py) sinh cả ba thứ đó:

```
python w3skill.py show          # xem trước, không ghi
python w3skill.py gen           # ghi vào war3map.wts + war3map.w3a
python w3skill.py gen --lang vi
```

**Nguồn sự thật là `CFG.SKILLS`.** Tên và mọi con số trong tooltip đều suy ra từ
bảng đó, nên **tooltip không thể nói khác bảng phím R** — cả hai ra từ một chỗ.
Đổi một hệ số trong `CFG` rồi chạy lại là tooltip tự khớp.

Tooltip sinh cho **cả 10 bậc**, ví dụ Chưởng:

```
[bậc 1]                            [bậc 10]
Deals x1.32 damage in a line.      Deals x1.76 damage in a line.

Level 1/10                         Level 10/10
Scales with your highest           Scales with your highest
attribute.                         attribute.
cd 8.0s   mana 25                  cd 5.3s   mana 38
```

### Chuỗi nằm trong `war3map.wts`, không nằm trong `.w3a`

World Editor không nhét chữ thẳng vào object data; nó ghi vào `war3map.wts` rồi để
lại tham chiếu `TRIGSTR_nnn`. `w3skill.py` làm y hệt — đo được từ chính `A006`,
object duy nhất đã có vỏ đầy đủ từ trước.

Chuỗi sinh ra chiếm **id từ 1000 trở lên**; mỗi lần chạy ghi đè đúng khối đó và
**không đụng tới chuỗi của World Editor bên dưới**. Chạy lại bao nhiêu lần cũng ra
một kết quả.

### Một hệ quả về ngôn ngữ

`war3map.w3a` chỉ giữ được **một** thứ tiếng. `build.py --lang vi` đổi được chữ
trong Lua, nhưng **không đổi được tooltip trong command card**.

Muốn bản tiếng Việt đầy đủ thì phải chạy `w3skill.py gen --lang vi` **trước khi**
đóng gói — tức hai bản map cần hai lần sinh. Xem [ngon-ngu.md](ngon-ngu.md).

### Icon thì chưa đụng

Sáu ability giữ icon của ability cha, `A006` có `BTNDefend` từ trước. Chúng **đã
khác nhau** vì mỗi cái nhân bản từ một ability khác nhau, nên không ô nào trùng
icon — chưa cần sửa.

Đặt icon riêng an toàn về kỹ thuật (`aart` là trường đã đo kiểu), nhưng **đường dẫn
sai là hiện ô xanh lá và không có lỗi nào báo**. Chọn icon xong phải vào game nhìn
một lần.

---

## Một chỗ duy nhất được ghi chỉ số hero

`API.heroRecompute(pid)` trong
[7_effect.lua](../../src/2_player/7_effect.lua) là **cửa duy nhất** ghi lên
hero. Mọi hệ chỉ **khai báo nó đóng góp bao nhiêu**; recompute cộng hết rồi ghi
một lần.

```
chỉ số      nền + Tu Vi, rồi nhân % của bị động "stat"
sát thương  nền × Trang Bị
giáp        nền + aura "Hiệu Lệnh" + buff "Bất Hoại"
```

Chỉ số **nền** đọc đúng một lần, ngay sau khi tạo hero
(`API.heroBaseCapture`), trước khi bất cứ hệ nào cộng vào.

### Lỗi mà luật này sinh ra để chặn

Trước 2026-09-16, Bất Hoại và Hiệu Lệnh **đều** ghi giáp kiểu *đọc–cộng–ghi lại*.
Nâng Hiệu Lệnh trong lúc Bất Hoại đang bật thì "giáp nền" bị đọc nhầm là giáp **đã
cộng buff**, nên lúc buff hết trừ ra không khớp:

| | Cũ | Mới |
|---|---|---|
| Hiệu Lệnh bậc 1 | 5.75 | 8.00 |
| Bất Hoại bật | 25.75 | 38.00 |
| Nâng Hiệu Lệnh bậc 2 | 29.05 | 38.24 |
| Bất Hoại hết | **9.05** ✗ *(đúng ra 5.81)* | **8.24** ✓ |

Và nó **cộng dồn mỗi lần lặp** — chơi 100 đợt thì hero thành bất tử vì một lỗi số
học.

### Hai thay đổi đi kèm

**Hiệu Lệnh sang giáp phẳng.** Warcraft dùng giáp phẳng, không phải phần trăm —
`CFG.ARMOR_DR_PER_POINT = 0.06` xác nhận. "+15% giáp" trên hero có 3 giáp là
**+0.45 giáp** ≈ +2.6% máu hiệu dụng, gần như bằng không. Giờ **+3 → +6 giáp**,
tức **+18% → +36%** máu hiệu dụng.

**Bất Hoại bỏ phần cộng máu tối đa**, bù bằng giáp (20 → 30). Lý do: máu tối đa
của hero **suy ra từ Sức mạnh**, mà Tu Vi đổi Sức mạnh lúc nào cũng được —
cộng rồi trừ một con số tuyệt đối trên đại lượng tự nó thay đổi là sai chắc chắn.
Giáp thì suy ra được từ nền nên không bao giờ lệch.

---

# Hvwd và Hkal — chưa có gì, và đang khoá

Hai hero **có unit trong `war3map.w3u`**, có icon và vai trên thẻ chọn, nhưng
`CFG.SKILLS` không có khoá cho chúng và `war3map.w3a` không có ability nào.

**Từ 2026-09-19 chúng không ra bảng chọn nữa** — `locked = true` trong
`CFG.HEROES`. Cho chọn một con không có bộ kỹ năng riêng là cho chọn một con
dùng chung bộ của Hart: nó *chạy*, nên lỗi không lộ ra, chỉ lặng lẽ nhạt. Bỏ cờ
đi là mở lại. Chi tiết và cái bẫy `HERO_UNIQUE` đi kèm:
[chon-hero.md](chon-hero.md#hai-hero-đang-khoá-2026-09-19).

Khi thiết kế lại, ba điều đã học được từ Hart đáng mang theo:

| | |
|---|---|
| **Vỏ sinh được bằng script** | `w3skill.py` tự lo tên, ô, tooltip 10 bậc từ `CFG.SKILLS`. Việc còn lại chỉ là nhân bản ability trong Object Editor |
| **Cái gì không scale thì đừng bắt nó scale** | Làm chậm, choáng, thời lượng buff — để nguyên số gốc của Warcraft thì không cần mã trường chưa ai đo |
| **Hồi máu nên tính theo % máu đã mất** | Máu hero tăng ×279 qua 100 stage; hồi một số cố định là vô nghĩa ở cảnh giới 15 |

---

## Mỗi ability cần gì trong `war3map.w3a`

| Trường | Ai đặt | Ghi chú |
|---|---|---|
| `alev` = 10 | `w3obj.py levels` | Thiếu là `SetUnitAbilityLevel` **kẹp xuống im lặng** |
| `anam` | `w3skill.py` | Trỏ `TRIGSTR_` vào `war3map.wts` |
| `abpx` `abpy` | `w3skill.py` | Hai ability trùng ô thì đè nhau, một cái **bấm không được** |
| `aub1` × 10 bậc | `w3skill.py` | Sinh từ `CFG.SKILLS` |
| `aart` | *(tay)* | Đường dẫn sai → ô xanh lá, không báo lỗi |

## Hai điều kỹ thuật phải nhớ

**Ability nhân bản từ hero ra ở cấp 0.** Gắn bằng `UnitAddAbility` thì nút hiện
nhưng bấm không được. Code đã tự gọi `SetUnitAbilityLevel(u, id, 1)` ngay sau khi
gắn.

**Hai aura cùng loại không cộng dồn** — Warcraft chỉ lấy cái mạnh hơn. Đáng nhớ
khi Hvwd/Hkal có aura.
