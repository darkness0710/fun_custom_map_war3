# Bảng khoá cấu hình

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-14
> **Nguồn sự thật:** [1_config.lua](../../src/1_nen/1_config.lua)

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

## Vùng & nhà chính

Chi tiết: [02-he-thong/nha-chinh.md](../02-he-thong/nha-chinh.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `RGN_HOUSE` `RGN_ENEMY` | Tên vùng vẽ trong World Editor | Nhận **một tên hoặc danh sách tên**, thử lần lượt. Sai hết thì in ra danh sách vùng thật — dòng này hiện kể cả khi `DEBUG` tắt |
| `HOUSE_UNIT` | Unit làm nhà chính | **Placeholder** `htow`. Không có unit Zeus trong WC3 gốc |
| `HOUSE_HP` | Máu tối đa | Cần patch 1.31+ (`BlzSetUnitMaxHP`) |
| `HOUSE_INVULNERABLE` | Bất tử | `false`, vì chết là thua |
| `HOUSE_SELECTABLE` | Người chơi chọn được nhà không | `false` — tránh lọt vào Ctrl+A |
| `HOUSE_NAME` `HOUSE_FACE` `HOUSE_SCALE` | Tên hiện, hướng quay, cỡ | |

## Chọn hero

Chi tiết: [02-he-thong/chon-hero.md](../02-he-thong/chon-hero.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `HEROES` | Danh sách `{ id, name }` | Không được rỗng. `name` là chữ hiện trên nút popup |
| `PICK_TITLE` | Tiêu đề bảng chọn | |
| `HERO_PICK_MODE` | `"frame"` (thẻ có icon) hoặc `"dialog"` (popup chữ) | |
| `HEROES[i].icon` `role` | Icon và vai hiện trên thẻ | Chỉ dùng ở `"frame"` |
| `CARD_*` | Kích thước và vị trí thẻ | Toạ độ màn hình: X 0.0–0.8, Y 0.0–0.6 |
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
| `SKILL_MODE` | `"none"` hoặc `"learn"` | Xem [ky-nang.md](../02-he-thong/ky-nang.md) |
| `SKILL_POINTS_START` | Điểm phát lúc hero sinh ra | Chỉ có nghĩa ở `"learn"` |
| `STRIP_SKILL_POINTS` | Rút sạch điểm kỹ năng | **Suy ra từ `SKILL_MODE`** — đừng sửa tay |
| `HERO_REMOVE_ABILITIES` | Gỡ hẳn ability khỏi danh sách học | Rỗng — thường không cần |
| `HERO_XP_SWEEP` | Giây giữa hai lần quét toàn map | `0` = chỉ khoá lúc tạo |

## Đợt quái

Chi tiết: [02-he-thong/dot-quai.md](../02-he-thong/dot-quai.md) ·
[canh-gioi.md](canh-gioi.md).

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `REALMS` | Bảng 20 cảnh giới `{ ten, tenGame, coi }` | Đúng 20 dòng, đúng thứ tự. `tenGame` **không dấu** — font WC3 thiếu glyph tiếng Việt |
| `TIERS_PER_REALM` | Tầng mỗi cảnh giới | `10`. Tổng stage = `20 × (TIERS_PER_REALM + 1)` = 220. Không hard-code số 11 ở đâu cả |
| `WAVE_MOB_COUNT` `WAVE_ELITE_COUNT` `WAVE_ELITE_COUNT_FULL` | Lính / tinh anh mỗi wave | **Không** nhân theo số người chơi — [ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md) |
| `WAVE_TIME` | Giây mỗi wave, tra theo cảnh giới | Quyết định thời lượng cả ván (~129 phút) *và* DPS mà người chơi cần. Hai thứ dính nhau |
| `WAVE_BOSS_TIME_MULT` | Stage boss dài gấp mấy lần | Boss cần ~1.33 × `WAVE_TIME` |
| `WAVE_SPAWN_BATCH` `WAVE_SPAWN_TICK` | Sinh rải thế nào | `COUNT / BATCH × TICK` phải nhỏ hơn hẳn `WAVE_TIME` |
| `WAVE_MAX_ALIVE` | Trần quái sống | Hoãn việc **sinh**, không hoãn đồng hồ. Chạm thường xuyên = đường cong sai |
| `WAVE_REORDER_TICK` | Giây giữa hai lần phát lại lệnh đi | Quái kẹt pathing đứng mãi nếu không có |
| `WAVE_CALL_EARLY` `WAVE_CALL_EARLY_BONUS` | Gọi wave sớm, và thưởng | Thứ duy nhất cắt 129 phút xuống dưới 100 |
| `MOB_ARCHETYPES` | 6 mẫu lính | `Σ(tỉ lệ)` = 1.0 và `Σ(tỉ lệ × EHP mult)` ∈ [0.95, 1.05] |
| `MODIFIERS` `TIER_MODIFIERS` | Tu chính, và tầng nào bật mấy cái | Cố định theo stage, **không random** |
| `ELITE_*` | Tinh anh | `ELITE_DMG_MULT` phải thấp hơn nhiều `ELITE_EHP_MULT` — nhân 10 cả hai là giết hero một đòn |
| `BOSS_*` | Boss | `BOSS_CC_RESIST` < 1.0 — miễn nhiễm hoàn toàn giết cả nhánh kỹ năng khống chế |
| `LEAK_COST_MOB` `LEAK_COST_ELITE` `HOUSE_LIVES` | Lọt một con thì mất mấy mạng | **Chưa chốt** — [ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md) |

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

## Trình bày

| Khoá | Ý nghĩa |
|---|---|
| `C_GOLD` `C_JADE` `C_RED` `C_GREY` `C_END` | Mã màu; mọi chuỗi tô màu phải đóng bằng `C_END` |
| `MSG_TIME` | Giây hiện một dòng thông báo |
| `DEBUG` | Bật dòng `[dbg]`, bảng số lưới, ping minimap, báo cáo chi tiết. **Đang tắt.** Lỗi thật (thiếu vùng, tạo unit hỏng) vẫn hiện dù tắt |
| `VERSION` | Số hiệu bản dựng |

> **Mọi đường dẫn phải viết bằng `[[...]]`**, không dùng nháy kép — xem
> [ADR 0003](../05-quyet-dinh/0003-duong-dan-dung-chuoi-tho.md).

## Chưa có khoá nào cho

**Kinh tế.** Quái chết rơi cái gì, mua bằng cái gì. Không có nó thì
[hợp đồng sức mạnh](duong-cong-suc-manh.md) không ai thực hiện được.

**Tu vi người chơi.** Hero không lên cấp (`LOCK_HERO_XP`) mà địch mạnh lên ×967 —
khoảng trống đó chưa có hệ nào lấp.

**Object data** (unit, ability, doodad). Hệ đợt quái cần 24 unit type lính +
20 boss. Khi thêm, tạo `docs/03-du-lieu/object-data.md` và ghi rõ ID nào là
placeholder.
