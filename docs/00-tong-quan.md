# Tổng quan

> **Trạng thái:** Đang dựng — lõi lối chơi đã chạy, chưa chơi thử
> **Cập nhật:** 2026-09-18

## Map này là gì

Ba người chơi giữ một **Nhà Chính**. Phe địch tu tiên qua **20 cảnh giới**, mỗi
cảnh giới 4 tầng rồi một lần độ kiếp — tổng **100 đợt**. Nhà chết là thua; hạ
được boss đợt 100 là thắng.

Hero **không lên cấp**. Toàn bộ sức mạnh người chơi tăng lên trong 100 đợt phải
đến từ bốn hệ nâng cấp mua bằng hai đồng tiền. Đó là ràng buộc trung tâm của cả
thiết kế, và là chỗ mọi con số quy về —
[duong-cong-suc-manh.md](03-du-lieu/duong-cong-suc-manh.md).

## Đã chạy được

| Hệ | Code | Ghi chú |
|---|---|---|
| Quy trình build `src/` → `war3map.lua` | [build.py](../build.py) | Chạy lại nhiều lần vẫn ra một kết quả. `--pack` `--run` bỏ qua hẳn World Editor |
| Đăng ký người chơi, quan hệ đồng minh | [1_player.lua](../src/2_player/1_player.lua) | Slot trống bị bỏ qua, nên chơi một mình vẫn vào được |
| Kênh đồng bộ nhiều người | [3_sync.lua](../src/1_core/3_sync.lua) | blz → cache → local, tự dò |
| Hai thứ tiếng | [6_i18n.lua](../src/1_core/6_i18n.lua) | `build.py --lang en\|vi` |
| Nhà chính, chết là thua | [1_house.lua](../src/3_battle/1_house.lua) | Máu tính lại mỗi đợt theo `HOUSE_HP_HITS` |
| Chọn hero lúc vào map | [2_heropick.lua](../src/2_player/2_heropick.lua) | 3 hero, mỗi người 1, không ai trùng |
| Khoá kinh nghiệm & điểm kỹ năng | [1_player.lua](../src/2_player/1_player.lua) | Quét lại toàn map mỗi `HERO_XP_SWEEP` giây |
| **100 đợt quái** | [2_wave.lua](../src/3_battle/2_wave.lua) | Đường cong chỉ số, tinh anh, boss, tiền thưởng |
| **Tu Vi** — tu vi người chơi | [3_cultivation.lua](../src/2_player/3_cultivation.lua) | 20 bậc, ×19.7 — mua bằng **Linh Khí** |
| **Bảy kỹ năng, 10 bậc** | [4_skill.lua](../src/2_player/4_skill.lua) · [7_effect.lua](../src/2_player/7_effect.lua) | Mua bằng **Gỗ**, 1 điểm mỗi lần. Sát thương **đã ăn theo chỉ số thật** |
| **Cửa hàng** | [8_shop.lua](../src/2_player/8_shop.lua) | Hệ duy nhất tiêu **Vàng**, và duy nhất bán đồ tiêu hao. Gộp lọ cùng loại vào một ô |
| **Cơ Duyên** | [10_fortune.lua](../src/2_player/10_fortune.lua) · [5_fortuneframe.lua](../src/4_ui/5_fortuneframe.lua) | Khung riêng, mở ngay khi tinh anh/boss chết. **Hai thẻ** — vàng hoặc chỉ số |
| **Dùng đồ bằng hàng số trên** | [9_useitem.lua](../src/2_player/9_useitem.lua) | Thêm vào numpad sẵn có, không thay |
| **Trang Bị** | [5_gear.lua](../src/2_player/5_gear.lua) | **7 món × 100 bậc**, trần là Tu Vi. Mỗi món một vai, chỉ số đã chạy. Lưới ô kiểu hình nhân vật — [trang-bi-kiem.md](02-he-thong/trang-bi-kiem.md) |
| **Pháp Khí** | [6_relic.lua](../src/2_player/6_relic.lua) | ⏸ **đang khoá** (`RELIC_LOCKED`) — thẻ vẫn hiện để người chơi biết hệ tồn tại |
| Bảng nhân vật (phím **ESC**) | [1_panel.lua](../src/4_ui/1_panel.lua) | 5 thẻ, **ba** kiểu thân bảng: `list` · `focus` · `grid` |
| **Bảng trận đấu (phím R)** | [6_gameframe.lua](../src/4_ui/6_gameframe.lua) | Tổng Quan + Nhiệm Vụ Phụ. **Nút gọi đợt** thay hẳn đồng hồ — [ADR 0026](05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md) |
| Chữ bay | [4_fct.lua](../src/4_ui/4_fct.lua) | Cộng dồn sát thương trước khi vẽ |
| Lưới 25 block, 4+4 dòng sông | [4_geometry.lua](../src/1_core/4_geometry.lua) | Có vùng thật `Blk01..Blk25` trong World Editor; địa hình chưa vẽ |

## Cấu hình đã chốt

| | Giá trị | Ở đâu |
|---|---|---|
| Người chơi | 3 — slot 0, 1, 2 | `CFG.PLAYER_SLOTS` |
| Phe địch | 1 — slot 11, do máy giữ | `CFG.ENEMY_SLOT` |
| Nhà chính | slot riêng, không thuộc về ai | `CFG.HOUSE_SLOT` |
| Lưới | 5 × 5 = 25 block | `CFG.GRID_COLS/ROWS` |
| Ngăn cách | Sông rộng 8 ô (chia hết 212) | `CFG.RIVER_TILES` |
| Map size | 224 × 224 ô | [04-map/kich-thuoc.md](04-map/kich-thuoc.md) |
| Địa hình sông | Vẽ tay trong World Editor | [ADR 0004](05-quyet-dinh/0004-song-ve-tay.md) |
| Tổng đợt | 20 cảnh giới × (4 tầng + 1 boss) = 100 | `CFG.REALMS` `CFG.TIERS_PER_REALM` |
| Thành phần một đợt | 50 lính + 1 tinh anh, **cố định** | [ADR 0009](05-quyet-dinh/0009-so-luong-linh-co-dinh.md) |
| Thua | Nhà chính chết. Không đếm mạng | [ADR 0011](05-quyet-dinh/0011-nha-chinh-dem-mang.md) — đã bị lật |
| Thưởng | Chia đều cho mọi người, không theo ai kết liễu | [ADR 0013](05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md) |
| Ba đồng tiền | Linh Khí (Tu Vi) · Vàng (Shop) · Gỗ (Kỹ Năng) | [ADR 0015](05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md) |

Ba người chơi là đồng minh, chung tầm nhìn.

**Lưới 25 block đã có bản đồ vai trò** — phó bản, thí luyện, linh mạch, đấu đài
([phan-vung.md](02-he-thong/phan-vung.md)). Nhưng **chưa loại nào có một dòng
code**: lối chơi vẫn hoãn có chủ ý,
[ADR 0014](05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md).

> **Đo được: bản đồ đang thừa 80%.** Nhà (block 21) và cửa quái (block 16) kề
> nhau, quái đi đúng 5 361 trên 27 136 đơn vị. Và ở cõi 1, quãng đường đó ngốn
> **19.9s của đồng hồ 20s** — người chơi không có giây nào đứng ở nhà mà đánh.
> Ba cách sửa ở [phan-vung.md](02-he-thong/phan-vung.md), quyết sau khi chơi thử.

## Không còn ngân sách sức mạnh

**Đường cong quái giờ *là* đường cong Tu Vi** (`MOB_EHP_FOLLOW_CULT`). Hai vế
có chung thừa số nên nó triệt tiêu: tỉ lệ "mấy phát một con" phẳng theo định
nghĩa, không nhờ cân bằng khéo —
[ADR 0020](05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md).

Nên **con số ×967 không còn là hợp đồng nào cả**. Tu Vi một mình đã bám đúng
quái; mọi nguồn khác là phần **vượt lên thuần**:

| Nguồn | Đóng góp | Mua bằng | Trạng thái |
|---|---|---|---|
| Tu Vi | ×1.00 so với quái | Linh Khí | Đã cài — triệt tiêu theo định nghĩa |
| Cơ Duyên | **+40%** chỉ số cả ván | *(rơi ra)* | Đã cài |
| Kỹ Năng | bậc 1→10 | Gỗ | Đã cài và **đã có hiệu lực** |
| Trang Bị | **+20% mỗi món** *(≈17% Tu Vi)* | Đá Huyền Thiết | Đã cài. Tiền chỉ đủ ~2.6 trong 7 món |
| Pháp Khí | chưa có nội dung | Gỗ | ⏸ **khoá** — 190 Gỗ dành sẵn |

Điều kiện duy nhất: người chơi phải lên **đúng một bậc mỗi cảnh giới**. Đó là
giao kèo `CULT_COST_BASE = 500` phẳng + một cảnh giới kiếm đúng 500 Linh Khí.

> ✅ **Hai chỗ tiền kẹt trước đây đã thông** — 2026-09-18.
>
> - **Đá Huyền Thiết** không còn rơi từ Cơ Duyên. Đường ra đá duy nhất giờ là
>   **vàng → shop** (giá `10`), nên một con số điều được cả nhịp Trang Bị —
>   [ADR 0025](05-quyet-dinh/0025-co-duyen-con-hai-the.md).
> - **Giá Trang Bị** không còn là đường cong mũ. Phẳng `1` đá mỗi lần luyện,
>   `10` mỗi lần Tiến Giai; một món đi trọn tốn **471 đá**, cả ván mua được
>   **1 240** — tức ~2.6 trong 7 món. Thẻ Trang Bị là một *lựa chọn*, không
>   phải một thanh tiến độ.

`SKILL_DATA_LIVE` **đã bật** từ 2026-09-16: cả bảy ability có 10 bậc thật, và
sát thương ăn theo chỉ số qua [7_effect.lua](../src/2_player/7_effect.lua).

> **Nhưng chỉ Hart có kỹ năng.** Ba người chọn ba hero thì hai người có **0 kỹ
> năng** — đây là khoảng trống lớn nhất còn lại.
>
> Hart thì đã hoàn chỉnh: 7 kỹ năng, 10 bậc, hiệu ứng thật, và tên/ô/tooltip sinh
> từ `CFG.SKILLS`. Hvwd và Hkal ⏸ **chờ thiết kế lại** —
> [thiet-ke-hero.md](02-he-thong/thiet-ke-hero.md).

## Chưa quyết

Quyết xong thì chuyển thành file trong [05-quyet-dinh/](05-quyet-dinh/) và xoá
khỏi đây.

1. **Sông chặn hay lội qua được?** Nước sâu chặn đường bộ, nước nông thì không.
   Quyết định này đổi hẳn nhịp di chuyển của map — và cũng chặn việc đo
   nhịp di chuyển cho đúng, vì chưa biết quái đi bộ tới nhà mất bao lâu.
2. **Qua sông bằng gì?** Cầu, cổng, hay phải phá. Chưa có gì.
3. **Ba người chơi quan hệ thế nào?** Hiện là đồng minh. Muốn tranh chấp block
   thì phải đổi.
4. **Tu chính** ([dot-quai.md](02-he-thong/dot-quai.md)) chưa cài, nên 4 tầng
   của một cảnh giới hiện giống hệt nhau — chỉ số chỉ nhích ×1.054 suốt 4 tầng.
   Tầng đáng ra phải đổi *cách chơi*; hiện nó chỉ đổi *cái tên*.

## Bước kế tiếp

Xem [01-buoc-thuc-hien.md](01-buoc-thuc-hien.md).
