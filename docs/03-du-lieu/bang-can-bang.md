# Bảng khoá cấu hình

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-16
> **Nguồn sự thật:** [1_config.lua](../../src/1_nen/1_config.lua)

> Khoá nào ở đây mà `CFG` không có thì ghi rõ **`(chưa có)`**. Một tên khoá không
> tồn tại đọc y hệt một tên khoá tồn tại, và đó là kiểu sai khó thấy nhất trong
> cả tập tài liệu này.

Trang này **không chứa giá trị**. Giá trị sống trong `CFG`. Ở đây là ý nghĩa của
từng khoá và ràng buộc nó phải tuân — thứ đọc code không suy ra được.

Muốn xem số hiện tại: mở [1_config.lua](../../src/1_nen/1_config.lua).

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
| `BLOCK_ROLE` | Bảng vai trò → `{ ten, en, mau, tien, coop }` | **`coop` là ô bắt buộc**: một câu mô tả cơ chế buộc ba người phối hợp. Vai trò nào không điền được ô đó thì chưa nên có. `mau` dùng cho ping minimap của `-vung` |
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
| `HEROES` | Danh sách `{ id, name, role, icon, mota, mota_en, abilities, skills }` | Không được rỗng. `mota` đúng **3 gạch**, gạch thứ ba luôn là điểm yếu. Mỗi gạch tối đa 3–4 từ: frame chữ của WC3 không tự xuống dòng, dòng dài tràn sang thẻ bên cạnh |
| `PICK_TITLE` | Tiêu đề bảng chọn | **(đã bỏ)** — chuyển sang khoá `pick_title` ở [6_lang.lua](../../src/1_nen/6_lang.lua) |
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
| `REALMS` | Bảng 20 cảnh giới `{ ten, en, coi }` | Đúng 20 dòng, đúng thứ tự. `ten` (vi) **không dấu** — font WC3 thiếu glyph tiếng Việt. `coi` 1–4 quyết định mẫu lính và `WAVE_TIME` |
| `TIERS_PER_REALM` | Tầng mỗi cảnh giới | `10`. Tổng stage = `20 × (TIERS_PER_REALM + 1)` = 220. Không hard-code số 11 ở đâu cả |
| `WAVE_MOB_COUNT` `WAVE_ELITE_COUNT` | Lính / tinh anh mỗi wave | **Không** nhân theo số người chơi — [ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md) |
| `WAVE_TIME` | Giây mỗi wave, tra theo **cõi** | **Ràng buộc cứng: `> quãng đường/tốc độ + thời gian dọn một đợt`.** Thiếu là map không bao giờ sạch và cả `WAVE_AUTO_NEXT` lẫn `-next` chết. Bị chặn dưới bởi **tốc độ mẫu lính**, nên cõi dễ có thể cần nhiều giây hơn cõi khó |
| `WAVE_REST` | Dừng hẳn đồng hồ sau tầng 10 và sau boss | `true`. Hai cửa sổ nghỉ mỗi cảnh giới — chỗ duy nhất mua sắm mà không phải đứng chịu đòn. [ADR 0018](../05-quyet-dinh/0018-nghi-giua-hai-canh-gioi.md) |
| `WAVE_FIRST_DELAY` | Giây trước đợt đầu | Chỉ dùng khi `WAVE_WAIT_FIRST` tắt |
| `WAVE_WAIT_FIRST` | Đợt 1 chờ gọi `-next` | `true`. Tắt nó đi thì đợt 1 tự ra sau `WAVE_FIRST_DELAY`, và người chơi vào trận trước khi kịp mở bảng |
| `WAVE_AUTO_NEXT` `WAVE_CLEAR_DELAY` | Dọn sạch thì vào đợt sau ngay | Đồng hồ **vẫn chạy song song** — hai cơ chế không thay thế nhau |
| `WAVE_MAX_ALIVE` | Trần quái sống | Hoãn việc **sinh**, không hoãn đồng hồ. Chạm thường xuyên = đường cong sai |
| `WAVE_TICK` | Giây giữa hai lần phát lại lệnh đi | Quái bị đánh lạc hướng đứng mãi nếu không có |
| `SPAWN_JITTER` | Bán kính xê dịch điểm sinh | Đủ rộng để `WAVE_MOB_COUNT` con không chồng một chỗ |
| `MOB_UNIT` | Mẫu lính mỗi cõi, tra theo `REALMS[r].coi` | **Placeholder** — 4 unit gốc WC3. Thiết kế cần 4 cõi × 6 mẫu = 24 |
| `ELITE_EHP` `ELITE_DMG` `ELITE_SCALE` | Tinh anh | `ELITE_DMG` phải thấp hơn nhiều `ELITE_EHP` — nhân 10 cả hai là giết hero một đòn |
| `BOSS_EHP` `BOSS_DMG` `BOSS_SCALE` | Boss | Xem [boss.md](../02-he-thong/boss.md) |
| `TINHTHACH_BOSS_BASE` `TINHTHACH_BOSS_STEP` | Tinh Thạch rơi ra ở cảnh giới `r` | `BASE + STEP × (r−1)`. Nguồn Tinh Thạch duy nhất của cả ván |
| `MOB_ARCHETYPES` | 6 mẫu lính | **(chưa có)** `Σ(tỉ lệ)` = 1.0 và `Σ(tỉ lệ × EHP mult)` ∈ [0.95, 1.05] |
| `MODIFIERS` `TIER_MODIFIERS` | Tu chính, và tầng nào bật mấy cái | **(chưa có)** Cố định theo stage, **không random**. Thiếu nó thì 10 tầng của một cảnh giới giống hệt nhau |
| `WAVE_BOSS_TIME_MULT` | Stage boss dài gấp mấy lần | **(chưa có)** Boss cần ~1.33 × `WAVE_TIME` |
| `WAVE_SPAWN_BATCH` `WAVE_SPAWN_TICK` | Sinh rải thế nào | **(chưa có)** Hiện sinh cả 50 con trong một lượt |
| `BOSS_CC_RESIST` `BOSS_PHASES` `BOSS_ENRAGE_*` `BOSS_ARMOR_BONUS` `BOSSES` | Thân boss | **(chưa có)** — [boss.md](../02-he-thong/boss.md) |
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
| `SCALE_BOSS_EHP_PER_PLAYER` | Riêng boss | Cao hơn lính — boss một thân, đông người tập trung hạ hiệu quả hơn |
| `SCALE_RECOUNT_EACH_WAVE` | Tính lại số người mỗi wave | `true`. Đọc `#S.pids`, **không** đọc `CFG.PLAYER_SLOTS` |

## Kinh tế

Chi tiết: [02-he-thong/kinh-te.md](../02-he-thong/kinh-te.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `LINHKHI_BASE` | Linh Khí một wave trả ra ở stage 1 | Chia cho cả wave, không phải mỗi con |
| `NGOTINH_ELITE` `NGOTINH_BOSS` | Ngộ Tính rơi từ tinh anh / boss | Là **điểm**, không phải tiền — không đường cong mũ. Cả ván 300 điểm, tiêu 283. [ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md) |
| `LINHKHI_GROWTH` | Nhân mỗi stage | `1.0319 = 967^(1/219)`. Bám **hợp đồng ×967**, *không* bám đường cong EHP ×2 176 — bám nhầm là nửa sau game quá dễ |
| `LINHKHI_MOB_SHARE` | Phần thu nhập chia cho lính, phần còn lại cho tinh anh | Lính chết nhiều và đều, tinh anh là mốc |

> **Không có công tắc "chia theo người kết liễu".** Mọi phần thưởng chia đều cho
> mọi người chơi đang sống. Đã đo: chia theo kết liễu làm ba người chơi mỗi
> người thiếu 41 % số tiền cần — [ADR 0013](../05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md).

## Linh Căn (tu vi người chơi)

Chi tiết: [02-he-thong/kinh-te.md](../02-he-thong/kinh-te.md) ·
[duong-cong-suc-manh.md](duong-cong-suc-manh.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `LINHCAN_STEP` | Nhân sức mạnh mỗi bậc | `1.215`, **không** phải 1.17. Với 1.17 thì 19 bước chỉ cho ×19.7, nhân trang bị ×12 và kỹ năng ×2 là ×474 — bằng 49 % mức hợp đồng đòi |
| `LINHCAN_COST_BASE` `LINHCAN_COST_STEP` | Giá đột phá bậc `r` = `BASE × STEP^(r−1)` | `STEP = 1.412 = LINHKHI_GROWTH^11` = thu nhập trọn một cảnh giới, nên giá **luôn** đáng 7,1 wave ở mọi bậc |
| `LINHCAN_DMG_BASE` `LINHCAN_STAT_BASE` | Hai số để **giải ngược** ra chỉ số cần đạt | Nhân thẳng chỉ số lên mỗi bậc là **sai**: sát thương hero = nền + chỉ số, phần nền làm loãng nhân số. Đổi hai số này cho khớp hero thật trong Object Editor |
| `LINHCAN_STAT_MODE` | `"all"` hay `"primary"` | `"all"` phục vụ nhiều hợp đồng cùng lúc (Str→máu, Int→mana) nhưng Agi cho **tốc đánh** — đó là DPS ngoài ngân sách ×967. Đổi sang `"primary"` nếu đo thấy hero mạnh vượt đường cong |

## Nâng cấp kỹ năng

Chi tiết: [nang-cap-ky-nang.md](nang-cap-ky-nang.md) ·
[02-he-thong/ky-nang.md](../02-he-thong/ky-nang.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `SKILLS` | Bảy kỹ năng của mỗi hero, tra theo unit id | `heSo` ăn theo **chỉ số cao nhất** của hero, không phải số cố định. Bị động tính theo **phần trăm** — cộng thẳng một lượng cố định thì cuối game vô nghĩa |
| `SKILL_MAX_LEVEL` | Trần thiết kế | Trần **thật** là `min(trần này, Stats - Levels trong Object Editor)`. Code đo bậc thật rồi mới cho nâng — bảng ghi 10/10 mà unit ở bậc 3 là bảng nói dối |
| `SKILL_NGO_UP` | Giá nâng một bậc, bằng **Ngộ Tính** | `1`. Một con số phẳng, không bảng, không đường cong |
| `SKILL_NGO_UNLOCK` | Giá mở khoá một kỹ năng | `1`. Mở cái thứ nhất hay thứ bảy đều như nhau — người chơi chỉ chọn **thứ tự**, không phải tính toán |
| `SKILL_START_COUNT` | Bao nhiêu kỹ năng phát sẵn | `0` — command card trống khi vào map |
| `NGOTINH_START` | Ngộ Tính cầm sẵn lúc vào map | `1` — vừa đủ mở **một** kỹ năng ngay giây đầu. Đó là quyết định đầu tiên của ván |
| `SKILL_DMG_STEP` `SKILL_CD_STEP` `SKILL_PASSIVE_STEP` | Sức mạnh mỗi bậc | Ngân sách cả hệ là ×2, và ×2 đó là **tích** của mọi nút chỉnh: chủ động ×1.33 sát thương × 1.5 tần suất; bị động ăn trọn ×2 vì không có hồi chiêu |
| `SKILL_MANA_STEP` | Mana mỗi bậc | Tăng **chậm hơn** bộ mana (Linh Căn cộng cả Int). Chủ ý: đầu ván mana là ràng buộc thật, cuối ván không còn |
| `SKILL_DATA_LIVE` | Số liệu đã có hiệu lực chưa | `false` — bảng ghi rõ "đây là thiết kế". Hiện số dep mà sai; bật khi bộ sinh đã ghi vào `war3map.w3a` |

## Trang Bị

Chi tiết: [02-he-thong/kinh-te.md](../02-he-thong/kinh-te.md) ·
[5_trangbi.lua](../../src/2_nguoi_choi/5_trangbi.lua).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `TRANGBI` | Sáu ô `{ ten, en, icon }` | Tên chỉ là hương vị — **cả sáu có cùng tác dụng** |
| `TRANGBI_PCT` | Mỗi cấp cộng bao nhiêu | `+4%` sát thương. Sáu ô đầy cấp = `(1.04⁹)⁶ = ×8.3`, đúng phần ×8 của ngân sách. **Chia ba ô sang máu/giáp thì tích bốn hệ tụt đi hơn một nửa** — phải suy lại cả ngân sách trước |
| `TRANGBI_MAX_LEVEL` | `10` | Ô bắt đầu ở cấp **1**, nâng 9 lần |
| `TRANGBI_COST_BASE` `TRANGBI_COST_STEP` | Giá theo **tổng số lần đã nâng của cả sáu ô** | `STEP = 1.134 = LINHKHI_GROWTH^4.07`. 54 lần nâng trải đều 220 stage → mỗi lần cách 4,07 stage, nên "một lần nâng đáng mấy wave" là hằng số. `BASE = 147` vì Kỹ Năng đã rời khỏi ví Linh Khí |

Cộng vào **sát thương nền**, không cộng chỉ số — Linh Căn đã cộng chỉ số rồi, và
ngân sách ×967 đòi đo được riêng phần của từng hệ.

## Pháp Khí

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `PHAPKHI` | **Đang rỗng** `{}` | Năm món cũ đã xoá (2026-09-16). Hệ này sẽ tiêu **Ngộ Tính**, ngân sách dành sẵn **230 điểm** |
| `PHAPKHI_LIVE` | Hiệu ứng đã có tác dụng chưa | Mỗi món phải **đọc-lúc-dùng**, không món nào được đăng ký trigger riêng — một món cần bộ bắt sự kiện riêng là một món có thể hỏng âm thầm |

> ⚠ **Ngân sách sức mạnh đang thiếu ×2.5** vì Pháp Khí rỗng: `19.7 × 8.3 × 2.4 =
> ×392` trên hợp đồng ×967. 230 điểm Ngộ Tính dư phải trả lại chỗ đó.

> ⚠ **`TINHTHACH_BOSS_*` hiện không có chỗ tiêu.** Boss vẫn rơi 1 150 điểm cả ván
> nhưng không hệ nào dùng. Xem [kinh-te.md](../02-he-thong/kinh-te.md).

## Đồng bộ nhiều người chơi

Chi tiết: [ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md) ·
[3_sync.lua](../../src/1_nen/3_sync.lua).

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
| `DEV_COMMANDS` | `true` | `-sp` `-wave` `-lk` `-tt` `-spawn`. Có **riêng** một cờ để tắt báo cáo mà vẫn gõ lệnh thử được |
| `TRACE` `TRACE_FILE` | `true` | Ghi vết khởi động ra file. Game sập thì mọi dòng chat đều mất — đây là cách duy nhất biết nó chết ở bước nào |
| `REVEAL_MAP` | `true` | Mở toàn bộ sương mù — **luật của map**, không phải công tắc dev |
| `THUONG_MOB_LINHKHI` `THUONG_MOB_VANG` | `1` `1` | Lính thường rơi ra. **Phẳng**, không theo stage |
| `THUONG_ELITE_GO` `THUONG_BOSS_GO` | `1` `5` | Nguồn Gỗ duy nhất |
| `LINHCAN_COST_BASE` `_STEP` | `220` `1.08` | 19 lần = 9,118 = 91% của 10,000 Linh Khí |
| `SKILL_GO_UNLOCK` `SKILL_GO_UP` | `3` `3` | 70 giao dịch × 3 = 210 = 70% của 300 Gỗ |
| `GO_START` | `3` | Đủ mở **một** kỹ năng ngay giây đầu |
| `TRANGBI_LOCKED` `PHAPKHI_LOCKED` | `true` | Tạm khoá. Mở lại phải chọn lại đồng tiền — Linh Khí đã bị Linh Căn ăn 91% |
| `MOB_EHP_BASE` | `120` | Đo từ "Chưởng phát đầu mất 1/3 máu ở wave 1": `1.32 × (17+13) × 3 = 119` |
| `PANEL_W` | `0.68` | Năm thẻ. Ở `0.56` thì nhãn `IV. Treasures` tràn sang `V. Shop` |
| `HOUSE_FROZEN` | `true` | Chốt Nhà Chính tại chỗ. `HOUSE_UNIT` là `Hmkg` — unit hero **có chân** thuộc slot máy, nên AI mặc định của Warcraft cho nó đi lang thang |
| `WAVE_ONLY_WHEN_CLEAR` | `true` | Đợt mới chỉ ra khi đợt cũ đã dọn sạch. Tắt thì đồng hồ `WAVE_TIME` lại chồng đợt lên nhau |

> `-next`, `-lc`, `-c`, `-sync`, `-nat` **không** theo `DEV_COMMANDS`: ba cái đầu
> là lối chơi, hai cái sau là chỗ phải nhìn đầu tiên khi một hệ im lặng không
> chạy. Riêng `-next` mà tắt đi thì với `WAVE_WAIT_FIRST` sẽ không có cách nào
> khởi động ván.

> **Mọi đường dẫn phải viết bằng `[[...]]`**, không dùng nháy kép — xem
> [ADR 0003](../05-quyet-dinh/0003-duong-dan-dung-chuoi-tho.md).

## Chưa có khoá nào cho

**Tu chính (`MODIFIERS`).** Thiếu nó thì 10 tầng của một cảnh giới giống hệt
nhau, vì chỉ số chỉ nhích ×1.174 suốt 10 tầng.

**Object data** (unit, ability, doodad). Hệ đợt quái cần 24 unit type lính +
20 boss; hiện `MOB_UNIT` là 4 unit gốc WC3. Khi thêm, tạo
`docs/03-du-lieu/object-data.md` và ghi rõ ID nào là placeholder.

Ability thì **đã có** `A001`–`A007` trong `war3map.w3a`, nhưng sáu cái còn thiếu
`Stats - Levels = 10` — [ky-nang.md](../02-he-thong/ky-nang.md).
