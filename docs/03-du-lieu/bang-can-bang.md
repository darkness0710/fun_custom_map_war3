# Bảng khoá cấu hình

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-16
> **Nguồn sự thật:** [1_config.lua](../../src/1_core/1_config.lua)

> Khoá nào ở đây mà `CFG` không có thì ghi rõ **`(chưa có)`**. Một tên khoá không
> tồn tại đọc y hệt một tên khoá tồn tại, và đó là kiểu sai khó thấy nhất trong
> cả tập tài liệu này.

Trang này **không chứa giá trị**. Giá trị sống trong `CFG`. Ở đây là ý nghĩa của
từng khoá và ràng buộc nó phải tuân — thứ đọc code không suy ra được.

Muốn xem số hiện tại: mở [1_config.lua](../../src/1_core/1_config.lua).

## Người chơi

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `PLAYER_SLOTS` | Slot của người chơi | Phải khớp slot đã bật trong World Editor. Slot trống hoặc do máy giữ sẽ bị bỏ qua lúc chạy |
| `ENEMY_SLOT` | Slot phe địch | Phải do máy điều khiển, và **không** được nằm trong `PLAYER_SLOTS` |

## Lưới

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `GRID_COLS` `GRID_ROWS` | Số cột, số hàng | Tối thiểu 1. Đổi thành 5×5 thì có 25 block; công thức không giả định con số 5 ở đâu cả |
| `TILE` | Kích thước một ô địa hình | **Là hằng số của Warcraft III = 128.** Đừng đổi |
| `RIVER_TILES` | Bề rộng lòng sông, tính bằng ô | Nên chọn số **chia hết** vùng chơi được (với 212 ô: chỉ 8 hoặc 18) để lề bằng 0 và mọi mép rơi đúng ranh giới ô. **Đổi số này là phải vẽ lại sông** |
| `BLOCK_TILES_OVERRIDE` | Ép kích thước block | `0` = để code tự chia theo vùng chơi được. Đặt `> 0` thì lưới có thể tràn khỏi vùng chơi được — code không kiểm chuyện đó |

Quan hệ giữa chúng, trên mỗi trục:

```
tổng số ô  =  2 × lề  +  n × block  +  (n − 1) × RIVER_TILES
```

Hiện tại: `212 = 0 + 5 × 36 + 4 × 8` — khít, lề bằng 0.

`block` và `lề` do code suy ra; chỉ `RIVER_TILES` và số cột/hàng là do bạn đặt.

## Phân vùng 25 block

Chi tiết: [02-he-thong/phan-vung.md](../02-he-thong/phan-vung.md) ·
[ADR 0017](../05-quyet-dinh/0017-ten-vung-la-vi-tri-vai-tro-o-cfg.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `BLOCKS` | `[chỉ số block] = { vai }` | Block **không** khai báo ở đây là `"hoang"`. Chỉ số 1–25, đếm từ góc dưới-trái theo `blockIndex(col,row)`. Hiện chỉ 6/25 có vai trò — [ADR 0019](../05-quyet-dinh/0019-moi-vung-mot-co-che-co-op.md) |
| `BLOCK_ROLE` | Bảng vai trò → `{ vi, en, color, currency, coop }` | **`coop` là ô bắt buộc**: một câu mô tả cơ chế buộc ba người phối hợp. Vai trò nào không điền được ô đó thì chưa nên có. `color` dùng cho ping minimap của `-vung` |
| `BLOCK_RGN_PREFIX` | Tiền tố tên vùng trong World Editor | `"Blk"` — phải khớp `w3region.py`. **Tên vùng là vị trí, vai trò ở `BLOCKS`** |

> Chưa hệ nào gắn vào block. Bảng này là *bản đồ*, không phải lối chơi —
> [ADR 0014](../05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md).

## Vùng & nhà chính

Chi tiết: [02-he-thong/nha-chinh.md](../02-he-thong/nha-chinh.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `RGN_HOUSE` `RGN_ENEMY` | Tên vùng vẽ trong World Editor | Nhận **một tên hoặc danh sách tên**, thử lần lượt. Sai hết thì in ra danh sách vùng thật — dòng này hiện kể cả khi `DEBUG` tắt |
| `HOUSE_UNIT` | Unit làm nhà chính | `Hmkg` (Mountain King). Là **hero**, không phải công trình — kéo theo `HOUSE_SUSPEND_XP` và `HOUSE_CAN_ATTACK` |
| `HOUSE_SLOT` | Slot sở hữu nhà | Riêng một slot. **Không** được trùng `PLAYER_SLOTS` hay `ENEMY_SLOT`, nếu không quan hệ đồng minh đá nhau |
| `HOUSE_HP` | Máu lúc khởi tạo | Cần patch 1.31+ (`BlzSetUnitMaxHP`). Chỉ đúng **trước wave 1** — từ đó máu tính lại mỗi wave theo `HOUSE_HP_HITS` |
| `HOUSE_HP_HITS` | Nhà chịu được mấy đòn của một con lính | **Một con số duy nhất chỉnh độ khoan dung của cả map.** Máu thật = `HITS × dmgOf(stage)`, tính lại mỗi wave — [ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md) |
| `HOUSE_REGEN_PER_WAVE` | Hồi mấy phần máu tối đa mỗi wave | Giữ nguyên **tỉ lệ** đang có rồi cộng thêm. Đặt lại đầy mỗi wave thì lọt bao nhiêu cũng không sao |
| `HOUSE_SUSPEND_XP` | Khoá kinh nghiệm nhà chính | Bắt buộc bật: hero lên cấp là tính lại máu, phá mốc vừa đặt |
| `HOUSE_CAN_ATTACK` | Nhà tự tìm mục tiêu | `false` — cài bằng `SetUnitAcquireRange(0)` |
| `HOUSE_INVULNERABLE` | Bất tử | `false`, vì chết là thua |
| `HOUSE_DEATH_ENDS_GAME` | Nhà chết là thua | `true`. **Điều kiện thua duy nhất** |
| `HOUSE_SELECTABLE` | Người chơi chọn được nhà không | `true` — để xem chỉ số. Quyền điều khiển đã bị chặn bằng quyền sở hữu, không cần bỏ chọn thủ công |
| `HOUSE_SIGHT` | Tầm nhìn | Cài bằng fog modifier, **không** sửa trường của unit |
| `HOUSE_NAME` `HOUSE_FACE` `HOUSE_SCALE` | Tên hiện, hướng quay, cỡ | `HOUSE_NAME` chưa dịch hai thứ tiếng |

## Chọn hero

Chi tiết: [02-he-thong/chon-hero.md](../02-he-thong/chon-hero.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `HEROES` | Danh sách `{ id, name, role, icon, desc_vi, desc_en, abilities, skills }` | Không được rỗng. `desc_vi` đúng **3 gạch**, gạch thứ ba luôn là điểm yếu. Mỗi gạch tối đa 3–4 từ: frame chữ của WC3 không tự xuống dòng, dòng dài tràn sang thẻ bên cạnh |
| `PICK_TITLE` | Tiêu đề bảng chọn | **(đã bỏ)** — chuyển sang khoá `pick_title` ở [6_i18n.lua](../../src/1_core/6_i18n.lua) |
| `HERO_PICK_MODE` | `"frame"` (thẻ có icon) hoặc `"dialog"` (popup chữ) | |
| `HEROES[i].icon` `role` | Icon và vai hiện trên thẻ | Chỉ dùng ở `"frame"` |
| `CARD_W` `CARD_GAP` `CARD_ICON` `CARD_PAD` `CARD_LINE` | Hình học một dòng hero | Toạ độ màn hình: X 0.0–0.8, Y 0.0–0.6. **Chiều cao một dòng suy ra** từ `CARD_ICON` và `CARD_LINE` — không có `CARD_H` |
| `CARD_X` `CARD_Y` | Tâm bảng | |
| `CARD_SCALE_TITLE` `_NAME` `_DESC` | Cỡ chữ ba cấp | `1.0` là cỡ mặc định. Một cỡ cho mọi dòng thì mất phân cấp, nhìn vào chỉ thấy một khối chữ |
| `CARD_BACKDROP` | Danh sách template FDF làm nền, thử lần lượt | Hết thì lùi về `FRAME_BG` — một ô màu **đặc**, không viền. Đường đã dùng ghi ở dòng `herocard: ... nen =` trong file vết |
| `CARD_BUTTON_TEMPLATE` | Template nút một dòng hero | Dòng rộng-và-thấp hợp với nút tab. Nút không ăn thì đổi sang `"ScriptDialogButton"` `"IconButtonTemplate"` `"StandardLightButtonTemplate"` |
| `PICK_DELAY` | Giây trước khi hiện popup | Quá nhỏ thì bị màn hình chuyển cảnh nuốt |
| `HERO_MAX_PER_PLAYER` | Mỗi người tối đa | `0` = không giới hạn |
| `HERO_UNIQUE` | Không ai lấy trùng | |
| `HERO_SPAWN_OFFSET` | Hero sinh cách nhà chính bao xa | |

> Không còn khoá nào cho giá, lương thực, quầy hàng hay requirement. `CreateUnit`
> bỏ qua toàn bộ techtree nên chúng không còn nghĩa lý gì.

## Khoá kinh nghiệm hero

Chi tiết: [02-he-thong/khoa-hero.md](../02-he-thong/khoa-hero.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `LOCK_HERO_XP` | Không hero nào lên cấp | Áp cho mọi phe |
| `SKILL_MODE` | `"none"` `"learn"` `"pick"` `"frame"` | Đang chạy `"frame"`. Xem [ky-nang.md](../02-he-thong/ky-nang.md) |
| `SKILL_POINTS_START` | Điểm phát lúc hero sinh ra | Chỉ có nghĩa ở `"learn"` |
| `STRIP_SKILL_POINTS` | Rút sạch điểm kỹ năng | **Suy ra từ `SKILL_MODE`** — đừng sửa tay |
| `HERO_REMOVE_ABILITIES` | Gỡ hẳn ability khỏi danh sách học | Rỗng — thường không cần |
| `HERO_XP_SWEEP` | Giây giữa hai lần quét toàn map | `0` = chỉ khoá lúc tạo |

## Đợt quái

Chi tiết: [02-he-thong/dot-quai.md](../02-he-thong/dot-quai.md) ·
[canh-gioi.md](canh-gioi.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `REALMS` | Bảng 20 cảnh giới `{ vi, en, world }` | Đúng 20 dòng, đúng thứ tự. `vi` **không dấu** — font WC3 thiếu glyph tiếng Việt. `world` 1–4 quyết định mẫu lính |
| `TIERS_PER_REALM` | Tầng mỗi cảnh giới | `4`, mỗi tầng một tên trong `TIER_NAMES` *(Sơ Kì → Viên Mãn)*. Tổng stage = `20 × (TIERS_PER_REALM + 1)` = 100. Không hard-code số 5 ở đâu cả |
| `WAVE_MOB_COUNT` `WAVE_ELITE_COUNT` | Lính / tinh anh mỗi wave | **Không** nhân theo số người chơi — [ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md) |
| `WAVE_REST` | Hai mốc nghỉ mỗi cảnh giới | `true`. Không còn là "dừng đồng hồ" — chúng là hai **nhãn** khác của nút gọi đợt: `TRIỆU BOSS` và `SANG <cảnh giới>`. [ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md) |
| `WAVE_RECOUNT` | Giây giữa hai lần **đo lại** số quái sống | `10`. Đếm qua `S.mobs`, **không** quét map theo chủ sở hữu — quái đặt sẵn ở vùng đất sau này sẽ làm `S.alive` không bao giờ về 0. Bắt buộc phải có: không còn đường thoát nào khác nếu con số kẹt |
| `WAVE_MAX_ALIVE` | Trần quái sống | Chặn **nút gọi đợt**. Chạm thường xuyên = đường cong sai |

> ⛔ **`WAVE_TIME` `WAVE_FIRST_DELAY` `WAVE_WAIT_FIRST` `WAVE_AUTO_NEXT`
> `WAVE_CLEAR_DELAY` đã xoá** — 2026-09-18. Nhịp cả ván giờ do nút `GỌI ĐỢT`
> trên bảng phím **R** quyết định, và chỉ nó.
> [ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md) · [bang-tran-dau.md](../02-he-thong/bang-tran-dau.md)
| `WAVE_TICK` | Giây giữa hai lần phát lại lệnh đi | Quái bị đánh lạc hướng đứng mãi nếu không có |
| `SPAWN_JITTER` | Bán kính xê dịch điểm sinh | Đủ rộng để `WAVE_MOB_COUNT` con không chồng một chỗ |
| `MOB_UNIT` | Mẫu lính mỗi cõi, tra theo `REALMS[r].world` | **Placeholder** — 4 unit gốc WC3. Thiết kế cần 4 cõi × 6 mẫu = 24 |
| `ELITE_EHP` `ELITE_DMG` `ELITE_SCALE` | Tinh anh | `ELITE_DMG` phải thấp hơn nhiều `ELITE_EHP` — nhân 10 cả hai là giết hero một đòn |
| `BOSS_SECONDS` `BOSS_HITS_TO_KILL` `BOSS_SCALE` | Boss | Chỉ số **đo từ đội**, không nhân từ lính. `BOSS_EHP`/`BOSS_DMG` đã bỏ — xem [boss.md](../02-he-thong/boss.md) |
| `MOB_ARCHETYPES` | 6 mẫu lính | **(chưa có)** `Σ(tỉ lệ)` = 1.0 và `Σ(tỉ lệ × EHP mult)` ∈ [0.95, 1.05] |
| `MODIFIERS` `TIER_MODIFIERS` | Tu chính, và tầng nào bật mấy cái | **(chưa có)** Cố định theo stage, **không random**. Thiếu nó thì 4 tầng của một cảnh giới giống hệt nhau |
| `WAVE_SPAWN_BATCH` `WAVE_SPAWN_TICK` | Sinh rải thế nào | **(chưa có)** Hiện sinh cả 50 con trong một lượt |
| `BOSS_CC_RESIST` `BOSS_PHASES` `BOSS_ARMOR_BONUS` | Kháng khống chế · đổi giai đoạn · giáp cộng | **(chưa có)** — [boss.md](../02-he-thong/boss.md). *(`BOSSES` và `BOSS_MECH` thì **đã có**; `BOSS_ENRAGE_*` đã bỏ vào `BOSS_MECH.enrage`.)* |
| `LEAK_COST_MOB` `LEAK_COST_ELITE` `HOUSE_LIVES` | Lọt một con thì mất mấy mạng | **(chưa từng có)** — đề xuất đã bị bác, [ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md). Thay bằng `HOUSE_HP_HITS` |

## Đường cong chỉ số

Chi tiết và bảng tra: [duong-cong-suc-manh.md](duong-cong-suc-manh.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `MOB_EHP_BASE` | EHP lính chuẩn ở stage 1 | Nút chỉnh độ khó tổng thể — dời cả đường cong, giữ nguyên hình dạng |
| `MOB_EHP_GROWTH` | Nhân mỗi stage | Mũ 219, **rất nhạy**: 1.018 → 1.020 là tổng nhảy từ ×2 176 lên ×3 351 |
| `MOB_EHP_REALM_STEP` | Nhân thêm mỗi cảnh giới | Mũ 19. Giữ `GROWTH^11 × REALM_STEP` cố định thì đổi **nhịp** mà không đổi tổng |
| `MOB_DMG_BASE` `MOB_DMG_GROWTH` `MOB_DMG_REALM_STEP` | Như trên, cho sát thương | Phải dốc **thoải hơn** EHP. Bằng nhau là cuối game thành xúc xắc |
| `MOB_ARMOR_BASE` `MOB_ARMOR_PER_REALM` | Giáp theo cảnh giới | Đổi nó **không** đổi độ khó: máu thật tự chia lại. [ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md) |
| `SCALE_EHP_PER_PLAYER` | Nhân EHP mỗi người thêm | Phải < 1.0 — bằng 1.0 là phạt người chơi vì rủ bạn |
| `SCALE_DMG_PER_PLAYER` | Nhân sát thương mỗi người thêm | Giữ nhỏ: sát thương đã tự loãng theo số mục tiêu |
| `SCALE_RECOUNT_EACH_WAVE` | Tính lại số người mỗi wave | `true`. Đọc `#S.pids`, **không** đọc `CFG.PLAYER_SLOTS` |

## Kinh tế

Chi tiết: [02-he-thong/kinh-te.md](../02-he-thong/kinh-te.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `REWARD_MOB_QI` `REWARD_MOB_GOLD` | Lính thường rơi ra | `1` + `1`. Cả ván 4 000 con |
| `REWARD_ELITE_QI` `REWARD_ELITE_LUMBER` | Tinh anh rơi ra | `50` + `2`. Cả ván 80 con |
| `REWARD_BOSS_QI` `REWARD_BOSS_LUMBER` | Boss rơi ra | `100` + `5`. Cả ván 20 con |

**Thu nhập phẳng — không còn đường cong mũ nào.** Sáu số trên chọn để **một
cảnh giới kiếm đúng một lần đột phá**: `4 wave × 100 + boss 100 = 500`, mà
`CULT_COST_BASE` cũng đúng `500`. Cả ván: **Linh Khí 10 000 · Vàng 4 000 ·
Gỗ 260**. Đổi một trong sáu số là gãy giao kèo đó — và giao kèo đó là thứ
[ADR 0020](../05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md) dựa vào.

> **Không có công tắc "chia theo người kết liễu".** Mọi phần thưởng chia đều cho
> mọi người chơi đang sống. Đã đo: chia theo kết liễu làm ba người chơi mỗi
> người thiếu 41 % số tiền cần — [ADR 0013](../05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md).

## Tu Vi (tu vi người chơi)

Chi tiết: [02-he-thong/kinh-te.md](../02-he-thong/kinh-te.md) ·
[duong-cong-suc-manh.md](duong-cong-suc-manh.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `CULT_STAT_GAIN` `CULT_STAT_STEP` | Chỉ số cộng thêm ở lần đột phá đầu, và nhân mỗi lần sau | `50 × 1.30`. Cộng dồn 19 bậc = **24 199** chỉ số. Chọn `1.30` chứ không phải `2.0` vì gấp đôi 19 lần ra 26 **triệu** chỉ số — số phải đọc được. `CULT_STEP` cũ đã bỏ cùng ngân sách ×967 |
| `CULT_COST_BASE` `CULT_COST_STEP` | Giá đột phá bậc `r` = `BASE × STEP^(r−1)` | `500 × 1.0` — **phẳng**. Không suy từ đường cong nào, nó là một giao kèo đơn: dọn sạch một cảnh giới = lên một bậc |
| `CULT_DMG_BASE` `CULT_STAT_BASE` | Hai số để **giải ngược** ra chỉ số cần đạt | Nhân thẳng chỉ số lên mỗi bậc là **sai**: sát thương hero = nền + chỉ số, phần nền làm loãng nhân số. Đổi hai số này cho khớp hero thật trong Object Editor |
| `CULT_STAT_MODE` | `"all"` hay `"primary"` | `"all"` phục vụ nhiều thứ cùng lúc (Str→máu, Int→mana) nhưng Agi cho **tốc đánh** — một nguồn DPS mà đường cong quái không hề biết. Đổi sang `"primary"` nếu đo thấy hero mạnh vượt đường cong |

## Nâng cấp kỹ năng

Chi tiết: [nang-cap-ky-nang.md](nang-cap-ky-nang.md) ·
[02-he-thong/ky-nang.md](../02-he-thong/ky-nang.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `SKILLS` | Bảy kỹ năng của mỗi hero, tra theo unit id | `factor` ăn theo **chỉ số cao nhất** của hero, không phải số cố định. Bị động tính theo **phần trăm** — cộng thẳng một lượng cố định thì cuối game vô nghĩa |
| `SKILL_MAX_LEVEL` | Trần thiết kế | Trần **thật** là `min(trần này, Stats - Levels trong Object Editor)`. Code đo bậc thật rồi mới cho nâng — bảng ghi 10/10 mà unit ở bậc 3 là bảng nói dối |
| `SKILL_LUMBER_UP` | Giá nâng một bậc, bằng **Gỗ** | `1`. Một con số phẳng, không bảng, không đường cong |
| `SKILL_LUMBER_UNLOCK` | Giá mở khoá một kỹ năng | `1`. Mở cái thứ nhất hay thứ bảy đều như nhau — người chơi chỉ chọn **thứ tự**, không phải tính toán |
| `SKILL_START_COUNT` | Bao nhiêu kỹ năng phát sẵn | `0` — command card trống khi vào map |
| `LUMBER_START` | Gỗ cầm sẵn lúc vào map | `2` — đủ mở **một** kỹ năng sát thương **và** Luyện Thể ngay giây đầu. Đó là quyết định đầu tiên của ván |
| `SKILL_DMG_STEP` `SKILL_CD_STEP` `SKILL_PASSIVE_STEP` | Sức mạnh mỗi bậc | Ngân sách cả hệ là ×2, và ×2 đó là **tích** của mọi nút chỉnh: chủ động ×1.33 sát thương × 1.5 tần suất; bị động ăn trọn ×2 vì không có hồi chiêu |
| `SKILL_MANA_STEP` | Mana mỗi bậc | Tăng **chậm hơn** bộ mana (Tu Vi cộng cả Int). Chủ ý: đầu ván mana là ràng buộc thật, cuối ván không còn |
| `SKILL_DATA_LIVE` | Số liệu đã có hiệu lực chưa | `true` từ 2026-09-16. Bảy ability có 10 bậc thật, và [7_effect.lua](../../src/2_player/7_effect.lua) tự gây sát thương theo đúng `CFG.SKILLS` |

## Trang Bị

Chi tiết: [02-he-thong/kinh-te.md](../02-he-thong/kinh-te.md) ·
[5_gear.lua](../../src/2_player/5_gear.lua).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `GEAR` | Tám món `{ key, vi, en, role, probe, icon }` | `role` là thứ code đọc để biết cộng gì. **Mỗi món một vai, không món nào trùng**. `key` là tên thư mục icon — **tiếng Anh**, vì nó thành đường dẫn thật trong map |
| `GEAR_CAP` | 5 tên cấp | Cùng dạng `TIER_NAMES`. Số phần tử **phải bằng** `#GEAR_ODDS` |
| `GEAR_ODDS` | `{1.00, .75, .50, .25, .15}` | Kỳ vọng 15 lần thử trọn một cảnh giới. Thất bại **chỉ mất viên đá**. Người chơi bấm **một** lần, code quay hết — [ADR 0027](../05-quyet-dinh/0027-luyen-trang-bi-gop-mot-cu-bam.md) |
| `GEAR_PRICE` `GEAR_DISMANTLE` | `1` `10` đá | Luyện phẳng; Tiến Giai là một **cửa** 100%, không phải canh bạc chồng canh bạc |
| `GEAR_STAT_BASE` | `1.5` | Điểm cho **một bậc ở cảnh giới 1**. Các cảnh giới sau nhân theo **chính** `CULT_STAT_STEP`. Chọn để một món đi trọn 100 bậc = **4 726 điểm = 19.5% Tu Vi** — [ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md) |
| `GEAR_DMG_MAX` | `0.20` | Kiếm ở bậc 100. **Tuyến tính**, không leo — % đã tự leo sẵn vì nó nhân với phần sức mạnh đang leo ×146 |
| `GEAR_MITIG_MAX` | `0.25` | Khiên (đòn đánh) và Áo Choàng (phép), mỗi món ở bậc 100. Cao hơn `DMG_MAX` vì mỗi món chỉ chạm **một phần** lượng sát thương vào. ⚠ Tỉ lệ 60/40 vật lý/phép là **giả định, chưa đo** |
| `GEAR_LIFESTEAL_MAX` | `0.20` | Nhẫn ở bậc 100: % sát thương gây ra hồi thành máu. Bằng đúng `DMG_MAX` — hai món cùng ăn theo sát thương gây ra nên chung một thang đo |
| `GEAR_ICON_PATH` | `gear\<key>\NN.blp` | Công thức dựng đường dẫn icon. Thêm cảnh giới = thả ảnh + chạy `w3gear_icons.py`, không sửa Lua |
| `GEAR_ICON_MAX` | `20` | Cảnh giới cao nhất **đã có ảnh**. Trên mức này thì dùng ảnh của mức này |
| `GEAR_MITIG_CAP` | `0.40` | Trần **cứng** cho tổng phần giảm sát thương. Khiên/Áo Choàng và bị động `reduce` **nhân** với nhau chứ không cộng, nên không bao giờ chạm 100% — trần này chặn thêm một lần nữa |
| `GEAR_SLOTS` | `{cột, dòng}` mỗi món | Bố cục lưới ô trong bảng. Bảng chỉ **đọc** — đổi chỗ hai món là sửa một dòng ở đây, không đụng `1_panel.lua`. Lệch số ô/số món thì `API.trace` báo lúc vào map |
| `GEAR_DOLL_COL` | `2` | Cột giữa lưới = lý lịch hero (icon + tên + cảnh giới). `nil` thì bỏ cột đó |
| `GEAR_DOLL_ICON` | `0.130` | Cạnh ô icon hero. Tăng từ `0.090` ngày 2026-09-18: ở cỡ cũ ô búp bê còn 75% là mảng đen |
| `GEAR_PET_SLOT` | `{2,4}` | Ô Pet: chỗ dành sẵn, vẽ như ô thật nhưng **không có nút**. `nil` thì bỏ |

Cộng vào **sát thương nền**, không cộng chỉ số — Tu Vi đã cộng chỉ số rồi, và
đổi một hệ thì phần của nó phải đo được riêng.

## Pháp Khí

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `RELIC_LOCKED` | Khoá tạm | `true`. Thẻ hiện dòng "hệ đang tạm khoá" |

## Cơ Duyên

Chi tiết: [02-he-thong/quay-thuong.md](../02-he-thong/quay-thuong.md) ·
[ADR 0022](../05-quyet-dinh/0022-tien-thi-phang-suc-manh-thi-leo.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `FORTUNE_ELITE` `FORTUNE_BOSS` | Lượt quay tinh anh / boss | `1` + `3` → **140 lượt** cả ván |
| `FORTUNE_KINDS` | `{ "gold", "stat" }` | **Hai** thẻ. Thứ tự ở đây là thứ tự cột **và** thứ tự gọi `GetRandomInt` — đổi thứ tự là đổi chuỗi ngẫu nhiên. Thẻ đá đã bỏ vì nó là **tập con** của thẻ vàng — [ADR 0025](../05-quyet-dinh/0025-co-duyen-con-hai-the.md) |
| `FORTUNE_VALUE` `FORTUNE_RANGE_MIN/MAX` | Thẻ chỉ số | `2.2 × 1.30^(bậc−1)`, ±30%. **Leo** — nó là sức mạnh, không phải tiền |
| `FORTUNE_GOLD_MIN` `FORTUNE_GOLD_MAX` | Thẻ vàng | `30..90`, **phẳng**. Quy ra đá (giá `10`) thì dải này = `0.94 … 2.81 × 1.30^(r−1)` điểm, **ôm quanh** `2.2` của thẻ chỉ số — nên mỗi lượt vẫn là một quyết định thật |
| `FORTUNE_STATS` | Ba chỉ số thẻ chỉ số rút trúng | `str agi int`. Trúng Agi/Int **không** tăng sát thương kỹ năng (nó ăn theo chỉ số cao nhất, mà Hart luôn dẫn bằng Str) — canh bạc có chủ đích |

> **Tiền thì phẳng, sức mạnh thì leo.** Thẻ 1 và 3 cho tiền → phẳng; thẻ 2 cho
> sức mạnh → leo. Một thẻ tiền leo còn thẻ kia đứng yên thì sớm muộn cũng cắt
> nhau, và thẻ thua sẽ chết hẳn —
> [ADR 0022](../05-quyet-dinh/0022-tien-thi-phang-suc-manh-thi-leo.md).

## Shop

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `SHOP` | Bốn món `{ code, vi, en, item/iron, price, icon, desc_vi }` | Món có `iron` thay cho `item` thì **không dùng túi đồ** — cộng thẳng vào bộ đếm |
| `SHOP_CHECK_BAG` | Chặn mua khi đầy túi | `true`. Không có nó thì item rơi xuống đất và người chơi mất vàng mà không hiểu vì sao |
| `SHOP_STACK_MAX` | Gộp mấy lượt vào một ô | `10`. Gộp bằng tay vì item có sẵn của game không do ta nắm thuộc tính tự gộp |
| `START_ITEMS` · `TOWER_START` · `IRON_START` | Quà phát khi qua cổng `HeroMoveRegion` lần đầu | Dùng **chung bảng** với `SHOP`, tra theo `code` — hai chỗ cùng tạo một thứ thì sớm muộn cũng lệch |

Giá định theo **tổng vàng cả ván ~12 400** *(quái 4 000 + Cơ Duyên ~8 400)*,
không theo bậc. Đá Huyền Thiết `25` là đối thủ đầu tiên của Vàng ngoài lọ thuốc.

## Trang Bị — Kiếm *(chưa cài)*

Luật: [02-he-thong/trang-bi-kiem.md](../02-he-thong/trang-bi-kiem.md) ·
[ADR 0021](../05-quyet-dinh/0021-trang-bi-la-mot-mon-tien-hoa.md).
**Chưa có khoá nào** — chặn bởi phần chỉ số chưa chốt.
| `RELIC` | **Đang rỗng** `{}` | Năm món cũ đã xoá (2026-09-16). Hệ này sẽ tiêu **Gỗ**, ngân sách dành sẵn **190 điểm** |

Mỗi món phải **đọc-lúc-dùng**, không món nào được đăng ký trigger riêng — một
món cần bộ bắt sự kiện riêng là một món có thể hỏng âm thầm, mà cả ván chỉ mua
được vài lần.

> **Không còn ngân sách nào phải cho đủ.** Câu "thiếu ×2.5 vì Pháp Khí rỗng"
> viết cho bản ngân sách ×967 và **đã sai kể từ**
> [ADR 0020](../05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md): quái bám
> đúng đường cong Tu Vi, nên hai hệ đang khoá là phần **vượt lên**, không phải
> phần thiếu.

> ✅ **Đá Huyền Thiết đã có chỗ tiêu, và chỉ còn một cửa vào** — 2026-09-18.
> Thẻ đá của Cơ Duyên đã bỏ; đá giờ chỉ mua bằng **vàng ở shop** (giá `10`), và
> chỉ tiêu vào Trang Bị — đã mở. Một cửa vào, một cửa ra, nên **giá đá là núm
> duy nhất điều nhịp lên đồ**:
> cả ván 12 400 vàng → 1 240 đá → **~2.6 trong 8 món**.
> [ADR 0025](../05-quyet-dinh/0025-co-duyen-con-hai-the.md)

## Đồng bộ nhiều người chơi

Chi tiết: [ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md) ·
[3_sync.lua](../../src/1_core/3_sync.lua).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `SYNC_MODE` | `"auto"` `"blz"` `"cache"` `"local"` | `"auto"` ưu tiên blz → cache → local. `"local"` **chỉ chơi một mình** |
| `SYNC_POLL` `SYNC_CACHE` `SYNC_TEST_WAIT` | Đường cache | Cache không có sự kiện báo tin đến, phải quét |
| `OP_*` | Mã lệnh của từng loại tin | `1..200`, **mỗi mã một việc, không trùng nhau**. `arg` chỉ 5 chữ số nên **không gửi được id FourCC** — gửi số thứ tự trong bảng rồi tra ngược. Hiện dùng 1–8 |

## Trình bày

| Khoá | Ý nghĩa |
|---|---|
| `C_GOLD` `C_JADE` `C_RED` `C_GREY` `C_END` | Mã màu; mọi chuỗi tô màu phải đóng bằng `C_END` |
| `MSG_TIME` | Giây hiện một dòng thông báo |
| `LANG` | `"en"` hoặc `"vi"`. `build.py --lang` ghi đè, **không** sửa file trên đĩa |
| `PANEL_X` `PANEL_Y` `PANEL_W` | Bảng phím R | Chiều cao **suy ra từ số mục của thẻ dài nhất** — không có `PANEL_H` |
| `PANEL_ROW` `PANEL_ICON` `PANEL_BTN_W` `PANEL_BTN_H` `PANEL_PAD` | Hình học một mục kiểu `list` | `PANEL_ROW` phải **lớn hơn** `PANEL_BTN_H`, nếu không nút hai dòng kề nhau chồng lên nhau và bấm dòng này ăn vào dòng kia |
| `PANEL_SCALE_HEAD` `_NAME` `_SUB` | Cỡ chữ ba cấp | Một cỡ cho mọi dòng thì mất phân cấp — nhìn vào chỉ thấy một khối chữ đều đều |
| `PANEL_BACKDROP` | Template FDF làm nền, thử lần lượt | Hết thì lùi về `FRAME_BG` (ô màu đặc, không viền) |
| `PANEL_BAR_BG` `PANEL_BAR_FILL` | Thanh tiến độ của thẻ `focus` | Ở đây ô màu đặc đúng là thứ cần |
| `PANEL_GRID` `PANEL_GRID_TEX` | Vạch kẻ xen kẽ | |
| `CARD_*` | Thẻ chọn hero | |
| `FRAME_*` | Bảng chọn kỹ năng | `FRAME_BUTTON_TEMPLATE` — nút không ăn thì đổi template |
| `FCT_*` | Chữ bay | WC3 chỉ cho ~100 text tag cùng lúc. Một wave 50 con mà vẽ mỗi đòn một chữ là vài giây sau **không còn chữ nào hiện nữa** — nên `FCT_FLUSH` cộng dồn trước khi vẽ, `FCT_MAX_TAGS` chặn trần |
| `VERSION` | Số hiệu bản dựng |

## Công tắc chế độ phát triển

Bốn cái, **tắt hết trước khi phát hành** — [lenh-debug.md](../04-map/lenh-debug.md).

| Khoá | Hiện tại | Tác dụng |
|---|---|---|
| `DEBUG` | `false` | Dòng `[dbg]`, bảng số lưới, ping minimap, báo cáo chi tiết. Lỗi thật (thiếu vùng, tạo unit hỏng) vẫn hiện dù tắt |
| `DEV_COMMANDS` | `true` | `-sp` `-wave` `-go` `-vang` `-spawn` `-icon`. Có **riêng** một cờ để tắt báo cáo mà vẫn gõ lệnh thử được |
| `DEBUG_MONEY` | `999999` | Lệnh `-debug` đẩy cả bốn đồng tiền lên số này. Chỉ có khi `CFG.DEBUG` bật |
| `TRACE` `TRACE_FILE` | `true` | Ghi vết khởi động ra file. Game sập thì mọi dòng chat đều mất — đây là cách duy nhất biết nó chết ở bước nào |
| `REVEAL_MAP` | `true` | Mở toàn bộ sương mù — **luật của map**, không phải công tắc dev |
| `REWARD_MOB_QI` `REWARD_MOB_GOLD` | `1` `1` | Lính thường rơi ra. **Phẳng**, không theo stage |
| `REWARD_ELITE_QI` `REWARD_BOSS_QI` | `50` `100` | Chọn để 1 cảnh giới kiếm **đúng 500** = 1 lần đột phá |
| `CULT_STAT_GAIN` `CULT_STAT_STEP` | `50` `1.30` | Đột phá cộng `+50`, cục sau ×1.30 cục trước. Cộng dồn 19 bậc = `24,209`. Gấp đôi (`2.0`) cho ra 26 **triệu** — vỡ map, và **không** mạnh hơn về cảm giác |
| `REWARD_ELITE_LUMBER` `REWARD_BOSS_LUMBER` | `2` `5` | Nguồn Gỗ duy nhất. Cả ván `80×2 + 20×5 = 260` |
| `SKILL_LUMBER_UNLOCK` `SKILL_LUMBER_UP` | `1` `1` | 70 giao dịch = 70 Gỗ trên 260 kiếm được |
| `LUMBER_START` | `2` | Đủ mở **một** kỹ năng sát thương **và** Luyện Thể ngay giây đầu |
| `RELIC_LOCKED` | `true` | Tạm khoá. Mở lại phải chọn lại đồng tiền — Linh Khí đã bị Tu Vi ăn 91%. *(`GEAR_LOCKED` đã bỏ — Trang Bị mở từ 2026-09-17)* |
| `MOB_EHP_BASE` | `120` | Đo từ "Chưởng phát đầu mất 1/3 máu ở wave 1": `1.32 × (17+13) × 3 = 119` |
| `MOB_EHP_FOLLOW_CULT` | `true` | Quái **bám theo** đường cong Tu Vi thay vì có đường cong riêng. Hệ số triệt tiêu ở cả hai vế nên tỉ lệ "mấy phát một con" phẳng theo định nghĩa — đổi `CULT_STAT_STEP` không phải chỉnh gì thêm |
| `MOB_DMG_FOLLOW_POW` | `0.85` | Mũ của hệ số dùng cho **sát thương** quái. `< 1` = quái độc chậm hơn hero khoẻ lên |
| `MOB_EHP_REALM_STEP` | `1.22` | Chỉ còn dùng khi `MOB_EHP_FOLLOW_CULT = false` |
| `PANEL_W` | `0.74` | **Sáu** thẻ. Ở `0.56` thì nhãn `IV. Treasures` tràn sang `V. Shop`; nới lên `0.74` khi thêm thẻ `VI. Nhà Chính` |
| `SKILL_ZERO_BASE` `_INT` | *(bảng)* | Tắt hiệu ứng gốc của ability bản sao. Xem [ability-ban-sao.md](ability-ban-sao.md) |
| `SKILL_CARRY_BASE` | *(bảng)* | Mượn trường gốc làm **vật mang** cho giáp, thay vì tắt rồi tự cộng |
| `FORTUNE_ELITE` `FORTUNE_BOSS` | `1` `3` | Lượt quay. 7/cảnh giới, 140 cả ván. `5`/`10` cho 600 lượt = 30 phút ngồi chọn menu |
| `FORTUNE_VALUE` | `2.2` | Giá trị một thẻ ở bậc 1. Nhân theo **chính** `CULT_STAT_STEP` nên quay tự bám Tu Vi |
| `FORTUNE_KINDS` | `{gold, stat}` | Hai thẻ. Số cột của khung đọc từ đây, không gõ cứng |
| `FORTUNE_GOLD_MIN/MAX` | `30` `90` | Thẻ vàng, **phẳng + ngẫu nhiên**. Bản cũ `V × 12` leo ×180 làm thẻ đá chết ở nửa sau ván — [ADR 0022](../05-quyet-dinh/0022-tien-thi-phang-suc-manh-thi-leo.md) |
| `PANEL_W` | `0.74` | Năm thẻ *(Cơ Duyên đã tách thành khung riêng)*. Thẻ thứ **bảy** sẽ phải rút ngắn nhãn — khung 0.74 giữa màn hình 0.8 chỉ còn tràn 0.03 |
| `FORTUNE_X` `FORTUNE_Y` | `0.40` `0.36` | Tâm khung Cơ Duyên. Cao hơn tâm màn hình để không đè thanh giao diện đáy |
| `HOUSE_FROZEN` | `true` | Chốt Nhà Chính tại chỗ. `HOUSE_UNIT` là `Hmkg` — unit hero **có chân** thuộc slot máy, nên AI mặc định của Warcraft cho nó đi lang thang |
| `WAVE_ONLY_WHEN_CLEAR` | `true` | Còn quái sống thì **nút gọi đợt xám**. Tắt thì gọi lúc nào cũng được, và ADR 0009 (50 lính cố định) mất nghĩa vì người chơi tự chọn số quái trên map |
| `WAVE_RECOUNT` | `10.0` | Giây giữa hai lần đo lại `S.alive`. Lưới đỡ duy nhất còn lại — xem [ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md) |
| `GAME_KEY` `GAME_X/Y` | `"R"` `0.40` `0.42` | Bảng trận đấu. Hai bảng **loại trừ nhau**: mở cái này đóng cái kia |

> `-next`, `-lc`, `-c`, `-sync`, `-nat` **không** theo `DEV_COMMANDS`: ba cái đầu
> là lối chơi, hai cái sau là chỗ phải nhìn đầu tiên khi một hệ im lặng không
> chạy. Riêng `-next` giữ lại làm **đường lui**: `framesAvailable()` có thể trả
> `false`, và lúc đó không vẽ được bảng nào để bấm nút gọi đợt.

> **Mọi đường dẫn phải viết bằng `[[...]]`**, không dùng nháy kép — xem
> [ADR 0003](../05-quyet-dinh/0003-duong-dan-dung-chuoi-tho.md).

## Chưa có khoá nào cho

**Tu chính (`MODIFIERS`).** Thiếu nó thì 4 tầng của một cảnh giới giống hệt
nhau, vì chỉ số chỉ nhích ×1.054 suốt 4 tầng.

**Object data** (unit, ability, doodad). Hệ đợt quái cần 24 unit type lính +
20 boss; hiện `MOB_UNIT` là 4 unit gốc WC3. Khi thêm, tạo
`docs/03-du-lieu/object-data.md` và ghi rõ ID nào là placeholder.

Ability thì **đã có** `A001`–`A007` trong `war3map.w3a`, nhưng sáu cái còn thiếu
`Stats - Levels = 10` — [ky-nang.md](../02-he-thong/ky-nang.md).
