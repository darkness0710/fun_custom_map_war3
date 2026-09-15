# Hệ thống: Kỹ năng hero

> **Trạng thái:** Cơ chế đã cài — **chờ ability trong Object Editor**
> **Cập nhật:** 2026-09-15
> **Code:** [2_heropick.lua](../../src/2_nguoi_choi/2_heropick.lua), [1_player.lua](../../src/2_nguoi_choi/1_player.lua)
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

Cho skill ăn theo chỉ số là cách kéo Linh Căn (×20) vào kênh skill. Trang Bị cũng
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

-- heSo : do manh rieng cua tung ky nang (vi du 1.5 = 150% chi so)
-- cap  : 1..10, moi cap +10%
function API.skillDamage(u, heSo, cap)
  return topStat(u) * heSo * (1.10 ^ (cap - 1))
end
```

`GetHeroStr(u, true)` lấy **cả bonus**, nên nó tự bao gồm Linh Căn và Trang Bị —
đó chính là chỗ tích số được khôi phục.

**Dùng "cao nhất" chứ không dùng chỉ số chính** là lựa chọn đúng cho map này:
Linh Căn cộng đều cả ba chỉ số, nên "cao nhất" luôn là chỉ số hero khởi đầu mạnh
nhất. Nó ổn định, và nếu sau này Trang Bị cộng lệch một chỉ số thì người chơi có
thêm một quyết định xây dựng.

### Hệ quả phải nhớ

| | |
|---|---|
| Sát thương trong Object Editor | Đặt **0**, nếu không là cộng hai lần |
| Mỗi kỹ năng cần một trigger | 21 trigger, nhưng dùng chung một hàm |
| Kỹ năng buff/heal | Cũng nên ăn chỉ số, cùng lý do |
| Kỹ năng bị động (aura, chí mạng) | Không qua đường này — chúng là dữ liệu Object Editor thuần |
| `CFG.LINHCAN_DMG_BASE` | Chỉ ảnh hưởng đòn đánh, không ảnh hưởng skill nữa |
