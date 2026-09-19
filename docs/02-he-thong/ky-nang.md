# Hệ thống: Kỹ năng hero

> **Trạng thái:** cả ba hero **đủ vỏ và ruột**
> **Cập nhật:** 2026-09-19

> **Hvwd — xạ thủ — xong ngày 2026-09-19.** Bảy kỹ năng, mở khoá ra bảng chọn,
> đủ 10 bậc + tên + tooltip + ô + phím tắt trong `war3map.w3a`.
> Xem [Bảy kỹ năng của Hvwd](#bảy-kỹ-năng-của-hvwd-xạ-thủ) bên dưới — phần đáng
> đọc không phải bảng số mà là **ai giữ con số**.

> **Hart đã hoàn chỉnh.** Bảy kỹ năng, đủ 10 bậc, hiệu ứng chạy thật, và từ
> 2026-09-16 có cả **tên riêng, vị trí ô, tooltip 10 bậc** sinh bằng
> [w3skill.py](../../w3skill.py). Trước đó 6/7 ability hiện nguyên tên Blizzard.
>
> **Hkal xong 2026-09-19** — `CFG.SKILLS` có đủ `H001` `H002` `H003`, và không
> hero nào còn `locked`. `HERO_UNIQUE` từ giờ mới có nghĩa thật: ba người, ba
> con, không ai lấy trùng.
>
> **Hai kỹ năng của Hart đổi bản chất 2026-09-19** — `A003` Hiệu Lệnh thành bản
> sao **Endurance Aura**, `A006` Da Sắt thành bản sao **Reincarnation**. Bảng số
> 10 bậc nằm trong World Editor, code **đọc** chứ không tính lại.
>
> **Mọi chỉ số hero đi qua một cửa duy nhất** — `API.heroRecompute`. Mỗi hệ chỉ
> khai báo nó đóng góp bao nhiêu; không hệ nào tự ghi lên unit. Xem
> [thiet-ke-hero.md](thiet-ke-hero.md#một-chỗ-duy-nhất-được-ghi-chỉ-số-hero).
> **Code:** [4_skill.lua](../../src/2_player/4_skill.lua) (bậc, giá),
> [7_effect.lua](../../src/2_player/7_effect.lua) (hiệu ứng thật)

> **Hai thứ vừa xong, và chúng gỡ đúng hai chỗ chặn cũ.**
>
> **1. Cả bảy ability giờ có 10 bậc thật.** Trước đó chỉ `A004` đặt
> `Stats - Levels = 10`; sáu cái còn lại giữ số bậc gốc của Blizzard (1–3), nên
> nâng quá bậc đó thì `SetUnitAbilityLevel` **kẹp xuống im lặng**. Sửa bằng
> `python w3obj.py levels test2.w3x/war3map.w3a 10` —
> [sửa & clone ability](../06-object-editor/sua-va-clone-ability.md).
>
> **2. `CFG.SKILL_DATA_LIVE = true`.** Sát thương kỹ năng giờ ăn theo chỉ số
> thật. Cách làm: **không** sửa trường sát thương trong `war3map.w3a` — mã
> trường của `AOsh`/`AHhb`/`AHad` chưa ai đo, mà dự án cấm đoán. Thay vào đó
> [7_effect.lua](../../src/2_player/7_effect.lua) bắt sự kiện cast và **tự
> gây sát thương**, không cần biết mã trường nào.
>
> `probeMax()` vẫn giữ: nếu sau này thêm ability mà quên đặt bậc, bảng hiện
> `3/3!` đỏ thay vì nói dối 10/10.
> **Code:** [2_heropick.lua](../../src/2_player/2_heropick.lua), [1_player.lua](../../src/2_player/1_player.lua)
> **Khoá CFG:** `SKILL_MODE` `SKILL_POINTS_START` `HEROES[i].abilities` `HERO_COMMON_ABILITIES`

## Ba chế độ

| `SKILL_MODE` | Người chơi thấy gì | Icon & tooltip |
|---|---|---|
| `"none"` | Không học được gì | — |
| `"learn"` | Nút **+** → lưới icon của Warcraft III | **Có, đầy đủ** |
| `"pick"` | Popup của ta, chọn theo slot | **Không, chỉ chữ** |

Kỹ năng cố định (`CFG.HEROES[i].abilities`) gắn thẳng lên hero ở **cả ba** chế
độ — chúng độc lập với phần học được.

### Khuyến nghị: `"learn"`

Nút **+** không chỉ là nút. Bấm vào là ra **lưới icon kèm tooltip đầy đủ** — tên
kỹ năng, mô tả, hiệu ứng từng cấp. Đó chính là "danh sách kỹ năng trực quan" mà
một map cần, và nó có sẵn, không phải viết dòng UI nào.

`"pick"` dùng dialog của Warcraft III, mà dialog **chỉ hiển thị chữ**. Người chơi
đọc "Chem manh" thì không biết nó làm gì. Chỉ chọn `"pick"` khi bắt buộc phải
nhóm lựa chọn theo slot và chấp nhận đánh đổi đó.

### "Chọn M trong N" bằng chế độ `"learn"`

Đây là cách làm hệ thống lựa chọn mà vẫn giữ được icon:

1. Cho hero **N** ability học được trong `Techtree - Hero Abilities`.
2. Đặt `Stats - Levels = 1` trên mỗi ability — để không dồn hết điểm vào một cái.
3. Chỉ phát **M** điểm (`SKILL_POINTS_START`, hoặc `API.grantSkillPoints`).

Người chơi mở lưới icon, đọc tooltip, chọn M trong N. Không cần slot, không cần
popup riêng, không cần code.

## Không viết giao diện nào cả

Warcraft III đã có sẵn đúng giao diện nâng cấp kỹ năng mà một map cần: nút **+**,
lưới icon, tooltip mô tả từng cấp, chấm đánh dấu cấp đã học. Viết lại bằng
`BlzCreateFrame` sẽ tốn nhiều lần công sức để ra thứ xấu hơn.

Thứ duy nhất trước đây cản đường là hero không lên cấp nên không có điểm kỹ năng.

**Cách gỡ:** phát điểm bằng tay. `UnitModifySkillPoints` chạy được — đã đo, xem
[ADR 0008](../05-quyet-dinh/0008-ky-nang-hero-phai-sua-o-object-editor.md). Nên
hero vẫn đứng ở cấp 1, còn điểm thì code phát theo bất kỳ điều kiện nào: lúc sinh
ra, dọn sạch đợt quái, mốc thời gian, mua bằng tài nguyên.

Nghĩa là **tiến độ tách khỏi cấp độ**. Đây là tự do thiết kế, không phải cách lách.

## Ba việc trong Object Editor

Thiếu bất kỳ việc nào là kỹ năng không bao giờ học được.

**1. Đưa ability vào danh sách học.**
Units → từng hero → `Techtree - Hero Abilities` → thêm các ability.

**2. Đặt `Stats - Required Level` = 1** trên mọi ability.
Hero đứng yên ở cấp 1. Ability nào đòi cấp cao hơn thì vĩnh viễn không đủ điều
kiện, dù có bao nhiêu điểm.

**3. Đặt `Levels - Level Skip Requirement` = 0.**
Mặc định Warcraft III bắt cách nhau vài cấp giữa hai lần nâng cùng một kỹ năng.
Hero không lên cấp nên điều kiện đó không bao giờ thoả.

**4. Đặt `Stats - Levels` = 1** nếu muốn "chọn M trong N".
Nhiều cấp thì người chơi dồn hết điểm vào một kỹ năng được, và lựa chọn mất ý
nghĩa.

> Ability ở đây phải là **hero ability**, ngược với kỹ năng cố định trong
> `CFG.HEROES[i].abilities` — chỗ đó phải dùng ability **thường**.

> Hero ability gắn thẳng bằng `UnitAddAbility` (chế độ `"pick"`) ra ở **cấp 0**,
> nút hiện nhưng bấm không được. Code tự gọi `SetUnitAbilityLevel(u, id, 1)` ngay
> sau đó. Triệu chứng "nút có mà bấm không được" rất khó đoán nếu không biết.

## Vị trí nút trong command card

Do chính ability quyết định, ở `Art - Button Position (X)` và `(Y)`. Không phải
code.

| | X=0 | X=1 | X=2 | X=3 |
|---|---|---|---|---|
| **Y=0** | Move | Stop | Hold | Attack |
| **Y=1** | Patrol | trống | trống | trống |
| **Y=2** | trống | trống | trống | trống |

Bảy ô trống. Hai ability trùng vị trí thì **đè lên nhau**, một cái bấm không được,
và không có cảnh báo nào. Ô `(3,2)` là chỗ nút Cancel xuất hiện khi mở submenu —
tránh ra nếu sau này hero có spellbook.

> ⚠ **Bảy ô trống, và mỗi hero có đúng bảy kỹ năng — vừa khít, không dư ô nào.**

**Ô nút là thuộc tính của ABILITY, không phải của hero** — và đó là chỗ
`w3skill.py` từng sai. Nó hard-code `parse_skills(cfg, "H001")`, nên mở khoá
Hvwd xong chạy `gen` thì **năm ability mới bị bỏ qua lặng lẽ**: lệnh chạy xong,
không báo lỗi gì, và `A008`–`A012` không có tên lẫn phím tắt.

Sửa 2026-09-19: `parse_heroes()` quét mọi `CFG.SKILLS[id('HNNN')]`, rồi
`assign_slots()` chia ô **theo từng hero nhưng nhớ xuyên hero**. `A004`/`A006`
nằm trong cả hai bảng; ghi hai lần hai chỗ thì lần sau đè lần trước và một
trong hai hero có hai nút chồng nhau — không lỗi, không báo, chỉ là một nút bấm
không được.

Kết quả (`python w3skill.py show`):

| ô | Hart | Hvwd | Hkal |
|---|---|---|---|
| `(0,2)` | Chưởng `Q` | Lôi Vân `Q` | Hàn Băng `Q` |
| `(1,2)` | Hộ Thể `W` | Hồi Xuân `W` | Cam Lộ `W` |
| `(2,2)` | Bất Hoại `E` | Thiêu Thiên `E` | Linh Khiên `E` |
| `(3,2)` | Chém Lan | **Nguyệt Nhận** | **Nguyệt Nhận** *(cùng ô)* |
| `(1,1)` | Hiệu Lệnh | Thần Xạ | Linh Tuyền |
| `(2,1)` | **Luyện Thể** | **Luyện Thể** | **Luyện Thể** *(cùng ô)* |
| `(3,1)` | **Da Sắt** | **Da Sắt** | **Da Sắt** *(cùng ô)* |

Vị trí lặp **giữa** các hero là đúng — mỗi hero chỉ mang bảy cái của nó. Trùng
**trong cùng một hero** thì `assign_slots()` dừng hẳn và nói tên hai cái.

Phím tắt cũng kiểm cùng chỗ: trùng trong một hero là lỗi *(Warcraft không báo,
bấm ra cái nào là tuỳ thứ tự card)*; trùng giữa các hero thì không sao — `E` là
Bất Hoại ở Hart, Thiêu Thiên ở Hvwd, Linh Khiên ở Hkal.

## Bảy kỹ năng của Hvwd (xạ thủ)

Cài 2026-09-19. Phần đáng đọc không phải bảng số, mà là **ai giữ con số** —
đó là thứ quyết định kỹ năng nào còn sống ở cảnh giới 20.

| | Ability gốc | Tên | Ai giữ số |
|---|---|---|---|
| `A011` | `AHfa` Searing Arrows | **Thiêu Thiên** | **Lua** — `pct` của đòn đánh |
| `A008` | `AOcl` Chain Lightning | **Lôi Vân** | **Lua** — `factor` × chỉ số |
| `A010` | `ACr2` Rejuvenation | **Hồi Xuân** | **Lua** — `factor` × chỉ số |
| `A009` | `AEar` Trueshot Aura | **Thần Xạ** | **WE** — `fromField` |
| `A012` | `Amgl` Moon Glaive | **Nguyệt Nhận** | **WE** — engine lo hết |
| `A004` | `Aamk` Attribute Bonus | **Luyện Thể** | cả hai |
| `A006` | `AOre` Reincarnation | **Da Sắt** | **WE** — hồi chiêu |

### Luật phân nhóm: chỉ phần trăm mới được để World Editor giữ

Một con số **phẳng** đặt trong Object Editor sẽ teo thành không —
[ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md). Đo được: ở cảnh
giới 16 chỉ số thật của hero là **30 105**. Một cú `+40 sát thương mỗi mũi tên`
lúc đó là **làm tròn số**.

Nên `A009` Trueshot và `A012` Moon Glaive được phép để WE giữ — cả hai vốn *là*
phần trăm, nên tự bám theo hero. Ba cái kia thì Lua phải giữ.

**`A012` là kỹ năng duy nhất trong cả map không cần một dòng Lua nào.** Engine tự
nảy đòn đánh sang mục tiêu kế, mỗi lần nảy một phần trăm của chính đòn đó.

### Searing Arrows: vì sao KHÔNG phải "% máu tối đa của mục tiêu"

Bản thảo đầu là `+1% máu tối đa, tối đa 2.5%`. Không dùng được, và lý do nằm ở
[4_sidequest.lua:60](../../src/3_battle/4_sidequest.lua#L60):

```lua
local hp = dps * (q.seconds or CFG.SIDE_QUEST_SECONDS or 60.0)
```

Máu Thánh Thú **không phải con số cố định** — nó là `DPS cả đội × số giây`. Nên:

> **1% máu tối đa ⇒ đúng 100 mũi tên giết mọi thứ. 2.5% ⇒ 40 mũi.**

Con số `seconds` (45 / 85 / 150 / 240) — **cả cái núm chỉnh độ khó của Thánh
Thú** — biến mất khỏi phương trình. Và nó **ngược**: so với thiết kế, cùng 100
mũi đó là *chậm hơn* đánh thường ở Chu Tước (45 giây) nhưng *nhanh gấp 3,6 lần*
ở Thanh Long (240 giây). Con dễ nhất không đổi gì, con khó nhất bốc hơi.

Gốc rễ: trong map này **máu mọi thứ đều định nghĩa theo DPS người chơi**
([ADR 0020](../05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md)). Nên
*"% máu địch"* thực chất là *"% trận đấu"* — con số phải nằm trong tay người
thiết kế, không phải trong tay một kỹ năng.

Bản đang chạy tính theo **% đòn đánh thật**, y hệt Chém Lan: `pct` của `amount`
sau khi Kiếm và Pháp Khí đã nhân. Nó không có con số riêng nào để bị bỏ lại.

### Nút bật/tắt của Thiêu Thiên

`A011` là bản sao của một ability **autocast** — có nút bật/tắt thật trên phím
`E`. Nếu Lua cứ đốt bất kể nút đó thì tắt đi là vừa khỏi tốn mana vừa giữ nguyên
sát thương: **nút thành cái bẫy**.

Warcraft 1.31.1 không phơi ra native nào hỏi *"autocast đang bật không"*. Nhưng
**lệnh** thì bắt được, và `OrderId()` trả `0` cho tên sai — nên đây là **đo
được**, không phải đoán. `probeBurnOrder()` thử lần lượt vài tên, cái nào cả hai
chiều đều khác `0` thì lấy, và ghi vết kết quả.

Đo không ra thì **luôn bật**, không phải luôn tắt: một kỹ năng im lặng không làm
gì là kiểu hỏng tệ nhất ([ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md)).

## Bảy kỹ năng của Hkal (pháp sư / hỗ trợ)

| | Ability gốc | Tên | Ai giữ số |
|---|---|---|---|
| `A013` | `AUfn` Frost Nova | **Hàn Băng** `Q` | **Lua** — `factor` × chỉ số |
| `A014` | `AOhw` Healing Wave | **Cam Lộ** `W` | **Lua** — `factor` × chỉ số |
| `A015` | `ACmf` Mana Shield | **Linh Khiên** `E` | **WE** |
| `A016` | `AHab` Brilliance Aura | **Linh Tuyền** | **WE** — `fromField` |
| `A012` | `Amgl` Moon Glaive | **Nguyệt Nhận** | engine |
| `A004` | `Aamk` Attribute Bonus | **Luyện Thể** | cả hai |
| `A006` | `AOre` Reincarnation | **Da Sắt** | **WE** — hồi chiêu |

**`A015` để World Editor giữ là đúng.** Mana Shield đổi sát thương lấy mana theo
một **tỉ lệ**, mà bộ mana thì leo theo Trí Tuệ — tức sức chịu của khiên tự leo.
Tỉ lệ thì không teo
([ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md)).

> ⚠ **`A016` thì chưa chắc.** Nếu trường của Brilliance Aura là **phần trăm** tốc
> hồi mana thì nó tự scale; nếu là một số mana/giây **phẳng** thì nó teo dần.
> Chưa đo được — `-nat spell` sẽ nói.
>
> Dù sao nó cũng là kỹ năng **đầu ván** theo thiết kế: `SKILL_MANA_STEP` (×1.55
> sau 10 bậc) **cố ý** tăng chậm hơn bộ mana, nên cuối ván mana không còn là ràng
> buộc.

> **`A012` trên một pháp sư là chưa hợp lý** — chủ dự án biết và chấp nhận tạm.
> Giữ ở đó để bộ bảy cái đủ chỗ; đổi một kỹ năng thứ thế thì thay một dòng.

### `wave` chọn người thiếu máu nhất, `chain` chọn người gần nhất

Hai vòng lặp nhìn giống hệt nhau nhưng tiêu chí chọn mục tiêu **ngược nhau**, và
đó là khác biệt thật:

| | Chọn ai | Vì sao |
|---|---|---|
| `chain` *(sát thương)* | **gần nhất** | mục tiêu nào cũng ăn đủ |
| `wave` *(hồi máu)* | **thiếu máu nhất** | hồi sang người đầy máu là vứt đi một nhịp, mà số nhịp thì có hạn |

### `heal` và `hot` là hai thứ khác nhau — A010 từng dùng nhầm

| `fx` | Hồi thế nào | Dùng ở |
|---|---|---|
| `heal` | **một cục ngay** | A002 Hộ Thể *(Hart)* |
| `hot` | **rải đều** trong thời lượng của chính ability | A010 Hồi Xuân |

**Lỗi đã ship:** A010 ban đầu dùng `heal` cho tiện vì `fxHeal()` có sẵn. Người
làm map đặt **6 giây** trong World Editor, trong game nó hồi tức thì — nhìn ra
như lỗi, và con số 6 giây thành vô nghĩa.

`fxHot()` **đọc thời lượng từ chính ability**, trường `adur`, chứ không khai một
`CFG.FX_HOT_TIME` cố định. World Editor giữ con số đó, một nơi duy nhất; khoá
`CFG` chỉ là đường lui và khi phải dùng tới thì nó ghi vết.

Dòng `durField = "adur"` khai tường minh trong `CFG.SKILLS` dù `"adur"` đã là
mặc định — đọc một dòng đó là biết ngay 6 giây đến từ đâu.

### Đã đo bằng `-nat spell` — và hai kết quả là khớp giả

| gốc | Hằng số | |
|---|---|---|
| `AOcl` | `ABILITY_RLF_DAMAGE_PER_TARGET_OCL1` | ✅ thật |
| `AHfa` | `ABILITY_RLF_DAMAGE_BONUS_HFA1` | ✅ thật |
| `ACr2` | `ABILITY_RLF_DAMAGE_MULTIPLIER_**OCR2**` | ❌ khớp giả |
| `AEar` | `ABILITY_*_RE**SEAR**CH_*` | ❌ khớp giả |
| `Amgl` | — | không có |

Trước đó tôi **suy** tên từ quy luật `AOsh → Osh1 → ABILITY_RLF_<TÊN>_OSH1` và
sai hết: viết `ABILITY_RLF_DAMAGE_OCL1` trong khi thật là
`..._DAMAGE_PER_TARGET_OCL1`, và bịa hẳn `..._HIT_POINTS_GAINED_CR21`.

**Hai khớp giả suýt lừa tiếp.** `spells()` bỏ chữ cái đầu rồi tìm **chuỗi con**,
nên `ACr2 → "CR2"` trúng `..._OCR2` — mà `OCR2` là hậu tố của `AOcr`
*(Critical Strike)*, một ability khác hẳn. Và `AEar → "EAR"` trúng `RESEARCH`,
vì `RESEARCH` có chứa `EAR`.

Đã sửa `spells()`: tách **khớp mạnh** *(tên kết thúc bằng `<hậu tố><số>`)* khỏi
**nghi ngờ**, và in nghi ngờ bằng màu xám có dấu `?`. Khớp yếu vẫn in ra — đôi
khi hậu tố thật không có số ở cuối, và lúc đó nó là manh mối duy nhất.

> Một cái tên **sai** trong `SKILL_ZERO_BASE` thì `zeroField()` ghi vết rồi hiệu
> ứng gốc vẫn chạy — im lặng, và không ai đọc lại dòng vết đó.

**`A011` trước đây không có dòng nào ở đây** — thiếu sót thật, và là cái đắt
nhất: `ABILITY_RLF_DAMAGE_BONUS_HFA1` chính là con số **phẳng** cộng vào mỗi mũi
tên, tức đúng thứ mà cả thiết kế `burn` dựng ra để thay thế.

**Còn lại `A010`:** không có hằng số nào — *đã đo*, không phải chưa tìm. Nên lớp
hồi máu gốc 6 giây vẫn chạy chồng lên `fxHot()`. Nó phẳng nên teo dần: rõ ở wave
đầu, vô nghĩa từ cảnh giới 5. Muốn tắt hẳn thì cần **mã trường 4 ký tự** của
`Data - Hit Points Gained` — đặt trường đó một giá trị bất kỳ trong World Editor,
lưu, rồi `python w3obj.py dump` sẽ in ra mã.

### Hai thứ còn phải đo

- **Mã trường thật** cho `A008`/`A010` *(xem mục trên — ba hằng số đã đo và
  không tồn tại)* và `fromAbil`/`fromField` của `A009`. Đo bằng `-nat spell`.
- **Hai đường dẫn model** `FX_HIT_BURN` / `FX_HIT_CHAIN` đang mượn lại model của
  `line`/`cleave`. Trông không đúng lắm, nhưng một đường dẫn **sai** thì không vẽ
  ra gì mà vẫn "thành công" — cùng lớp lỗi với `AddWeatherEffect`. Đổi sang model
  đúng nghĩa thì phải thử trong game trước.

## Phát điểm ở chỗ khác

```lua
API.grantSkillPoints(S.p[pid].hero, 1)
```

Gọi từ bất cứ đâu. Hàm này cảnh báo nếu `STRIP_SKILL_POINTS` còn bật — bộ quét 5
giây sẽ ăn mất điểm vừa phát, và đó là kiểu hỏng rất khó lần ra nếu không được báo.

## Cách kiểm

1. `CFG.SKILL_MODE = "learn"`, chạy `python build.py`.
2. Vào map, chọn hero. Phải thấy nút **+** với đúng số điểm đã phát.
3. Bấm **+**, phải thấy icon và tooltip của ability tự tạo.
4. Với `CFG.DEBUG = true`, gõ `-sp` để phát thêm một điểm mà không phải chờ.

Không thấy nút **+** thì gần như chắc chắn là `Techtree - Hero Abilities` còn
rỗng. Thấy nút nhưng ability bị mờ thì là `Required Level` hoặc
`Level Skip Requirement`.

## Chưa làm

- Chưa quyết điểm kỹ năng đến từ đâu ngoài lúc sinh hero. Đây là câu hỏi thiết kế
  chính còn lại: thưởng theo đợt quái, theo thời gian, hay mua bằng tài nguyên.
- Chưa có cách hoàn điểm hoặc đổi kỹ năng.
- `SKILL_POINTS_START` áp cho mọi hero như nhau, không phân biệt vai.

---

## Sát thương skill ăn theo chỉ số cao nhất

> **Trạng thái:** Đã chốt hướng, chưa cài. Ghi lại vì nó đổi cách dựng cả 21 kỹ năng.

### Vì sao bắt buộc, không phải tuỳ chọn

Lý do hiển nhiên: skill số cứng thì tới cảnh giới 10 thành vô dụng, vì quái dày
lên ×2 176 còn skill đứng yên.

Lý do ít hiển nhiên hơn, và nặng hơn: **ngân sách ×967 chỉ đúng khi bốn nguồn cùng
chạm vào tổng sát thương.**

| Cách | Tổng |
|---|---|
| Bốn nguồn đều tác động lên toàn bộ sát thương | **×960** ✔ |
| Trang Bị chỉ buff đòn đánh, Kỹ Năng chỉ buff skill | **×260** — thiếu 73% |

Chia kênh thì bốn nguồn thành **trung bình cộng**, không phải **tích**. Đòn đánh
riêng lẻ ×400, skill riêng lẻ ×120 — cả hai đều xa ×967.

Cho skill ăn theo chỉ số là cách kéo Tu Vi (×20) vào kênh skill. Trang Bị cũng
phải cộng chỉ số hoặc cộng % sát thương toàn cục chứ đừng chỉ cộng sát thương đòn
đánh.

### Warcraft III không tự làm việc này

Ability gốc có sát thương **cố định theo cấp**, đặt trong Object Editor. Chúng
**không đọc chỉ số hero**. Không có ô nào để điền "×1.5 chỉ số chính".

Nên ability trong Object Editor chỉ còn là **cái cò**: nó lo hiệu ứng hình ảnh,
tầm, hồi chiêu, mana. Sát thương thật do code tính:

```lua
-- Bat EVENT_PLAYER_UNIT_SPELL_EFFECT, roi:
local dmg = API.skillDamage(caster, HE_SO, capKyNang)
UnitDamageTarget(caster, target, dmg, true, false,
                 ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
```

Đặt sát thương ability trong Object Editor về **0** — nếu không thì cộng hai lần.

### Một hàm cho cả 21 kỹ năng

Đừng viết 21 công thức. Một hàm, mỗi kỹ năng một hệ số:

```lua
-- Chi so cao nhat: dung native cu, khong can Blz.
local function topStat(u)
  local s, a, i = GetHeroStr(u, true), GetHeroAgi(u, true), GetHeroInt(u, true)
  return math.max(s, a, i)
end

-- factor : do manh rieng cua tung ky nang (vi du 1.5 = 150% chi so)
-- cap  : 1..10, moi cap +10%
function API.skillDamage(u, factor, cap)
  return topStat(u) * factor * (1.10 ^ (cap - 1))
end
```

`GetHeroStr(u, true)` lấy **cả bonus**, nên nó tự bao gồm Tu Vi và Trang Bị —
đó chính là chỗ tích số được khôi phục.

**Dùng "cao nhất" chứ không dùng chỉ số chính** là lựa chọn đúng cho map này:
Tu Vi cộng đều cả ba chỉ số, nên "cao nhất" luôn là chỉ số hero khởi đầu mạnh
nhất. Nó ổn định, và nếu sau này Trang Bị cộng lệch một chỉ số thì người chơi có
thêm một quyết định xây dựng.

### Hệ quả phải nhớ

| | |
|---|---|
| Sát thương trong Object Editor | Đặt **0**, nếu không là cộng hai lần |
| Mỗi kỹ năng cần một trigger | 21 trigger, nhưng dùng chung một hàm |
| Kỹ năng buff/heal | Cũng nên ăn chỉ số, cùng lý do |
| Kỹ năng bị động (aura, chí mạng) | Không qua đường này — chúng là dữ liệu Object Editor thuần |
| `CFG.CULT_DMG_BASE` | Chỉ ảnh hưởng đòn đánh, không ảnh hưởng skill nữa |
