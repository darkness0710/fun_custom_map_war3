# Tổng quan

> **Trạng thái:** Đang dựng — lõi lối chơi đã chạy, chưa chơi thử
> **Cập nhật:** 2026-09-16

## Map này là gì

Ba người chơi giữ một **Nhà Chính**. Phe địch tu tiên qua **20 cảnh giới**, mỗi
cảnh giới 10 tầng rồi một lần độ kiếp — tổng **220 đợt**. Nhà chết là thua; hạ
được boss đợt 220 là thắng.

Hero **không lên cấp**. Toàn bộ sức mạnh người chơi tăng lên trong 220 đợt phải
đến từ bốn hệ nâng cấp mua bằng hai đồng tiền. Đó là ràng buộc trung tâm của cả
thiết kế, và là chỗ mọi con số quy về —
[duong-cong-suc-manh.md](03-du-lieu/duong-cong-suc-manh.md).

## Đã chạy được

| Hệ | Code | Ghi chú |
|---|---|---|
| Quy trình build `src/` → `war3map.lua` | [build.py](../build.py) | Chạy lại nhiều lần vẫn ra một kết quả. `--pack` `--run` bỏ qua hẳn World Editor |
| Đăng ký người chơi, quan hệ đồng minh | [1_player.lua](../src/2_nguoi_choi/1_player.lua) | Slot trống bị bỏ qua, nên chơi một mình vẫn vào được |
| Kênh đồng bộ nhiều người | [3_sync.lua](../src/1_nen/3_sync.lua) | blz → cache → local, tự dò |
| Hai thứ tiếng | [6_lang.lua](../src/1_nen/6_lang.lua) | `build.py --lang en\|vi` |
| Nhà chính, chết là thua | [1_house.lua](../src/3_tran_dau/1_house.lua) | Máu tính lại mỗi đợt theo `HOUSE_HP_HITS` |
| Chọn hero lúc vào map | [2_heropick.lua](../src/2_nguoi_choi/2_heropick.lua) | 3 hero, mỗi người 1, không ai trùng |
| Khoá kinh nghiệm & điểm kỹ năng | [1_player.lua](../src/2_nguoi_choi/1_player.lua) | Quét lại toàn map mỗi `HERO_XP_SWEEP` giây |
| **220 đợt quái** | [2_wave.lua](../src/3_tran_dau/2_wave.lua) | Đường cong chỉ số, tinh anh, boss, tiền thưởng |
| **Linh Căn** — tu vi người chơi | [3_linhcan.lua](../src/2_nguoi_choi/3_linhcan.lua) | 20 bậc, ×19.7 — mua bằng **Linh Khí** |
| **Bảy kỹ năng, 10 bậc** | [4_skill.lua](../src/2_nguoi_choi/4_skill.lua) · [7_hieuung.lua](../src/2_nguoi_choi/7_hieuung.lua) | ×2.4 — mua bằng **Ngộ Tính**. Sát thương **đã ăn theo chỉ số thật** |
| **Sáu ô trang bị** | [5_trangbi.lua](../src/2_nguoi_choi/5_trangbi.lua) | ×8.3 — mua bằng **Linh Khí** |
| **Năm pháp khí** | [6_phapkhi.lua](../src/2_nguoi_choi/6_phapkhi.lua) | ×2.5 — mua bằng **Tinh Thạch** (boss) |
| Bảng nhân vật (phím **E**) | [1_panel.lua](../src/4_giao_dien/1_panel.lua) | 4 thẻ, hai kiểu thân bảng |
| Chữ bay | [4_fct.lua](../src/4_giao_dien/4_fct.lua) | Cộng dồn sát thương trước khi vẽ |
| Lưới 25 block, 4+4 dòng sông | [4_geometry.lua](../src/1_nen/4_geometry.lua) | Có vùng thật `Blk01..Blk25` trong World Editor; địa hình chưa vẽ |

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
| Tổng đợt | 20 cảnh giới × (10 tầng + 1 boss) = 220 | `CFG.REALMS` `CFG.TIERS_PER_REALM` |
| Thành phần một đợt | 50 lính + 1 tinh anh, **cố định** | [ADR 0009](05-quyet-dinh/0009-so-luong-linh-co-dinh.md) |
| Thua | Nhà chính chết. Không đếm mạng | [ADR 0011](05-quyet-dinh/0011-nha-chinh-dem-mang.md) — đã bị lật |
| Thưởng | Chia đều cho mọi người, không theo ai kết liễu | [ADR 0013](05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md) |
| Ba đồng tiền | Linh Khí (lính) · Ngộ Tính (tinh anh) · Tinh Thạch (boss) | [ADR 0015](05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md) |

Ba người chơi là đồng minh, chung tầm nhìn.

**Lưới 25 block đã có bản đồ vai trò** — phó bản, thí luyện, linh mạch, đấu đài
([phan-vung.md](02-he-thong/phan-vung.md)). Nhưng **chưa loại nào có một dòng
code**: lối chơi vẫn hoãn có chủ ý,
[ADR 0014](05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md).

> **Đo được: bản đồ đang thừa 80%.** Nhà (block 21) và cửa quái (block 16) kề
> nhau, quái đi đúng 5 361 trên 27 136 đơn vị. Và ở cõi 1, quãng đường đó ngốn
> **19.9s của đồng hồ 20s** — người chơi không có giây nào đứng ở nhà mà đánh.
> Ba cách sửa ở [phan-vung.md](02-he-thong/phan-vung.md), quyết sau khi chơi thử.

## Ngân sách sức mạnh đã đủ — trên giấy

Đường cong địch đòi người chơi mạnh lên **×967** qua 220 đợt. Bốn hệ đã cài đủ:

| Nguồn | Nhân | Mua bằng | Trạng thái |
|---|---|---|---|
| Linh Căn | ×19.7 | Linh Khí | Đã cài |
| Trang Bị | ×8.3 | Linh Khí | Đã cài |
| Kỹ Năng | ×2.4 | Ngộ Tính | Đã cài và **đã có hiệu lực** |
| Pháp Khí | ×2.5 | **Ngộ Tính** | ⚠ **rỗng** — năm món cũ đã xoá 2026-09-16 |
| | **×392 / ×967** | | thiếu ×2.5 cho tới khi Pháp Khí có nội dung |

Một chỗ con số trên giấy chưa thành thật trong game:

- **Pháp Khí không cộng thẳng sát thương.** Năm món cộng vào kinh tế và sức chịu
  của nhà chính, tức ×2.5 đang trả bằng đường vòng. Chưa đo được đường vòng đó
  có bằng ×2.5 thật không.

`SKILL_DATA_LIVE` **đã bật** từ 2026-09-16: cả bảy ability có 10 bậc thật, và
sát thương ăn theo chỉ số qua [7_hieuung.lua](../src/2_nguoi_choi/7_hieuung.lua).

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
   `WAVE_TIME` cho đúng, vì chưa biết quái đi bộ tới nhà mất bao lâu.
2. **Qua sông bằng gì?** Cầu, cổng, hay phải phá. Chưa có gì.
3. **Ba người chơi quan hệ thế nào?** Hiện là đồng minh. Muốn tranh chấp block
   thì phải đổi.
4. **Tu chính** ([dot-quai.md](02-he-thong/dot-quai.md)) chưa cài, nên 10 tầng
   của một cảnh giới hiện giống hệt nhau — chỉ số chỉ nhích ×1.174 suốt 10 tầng.
   Tầng đáng ra phải đổi *cách chơi*; hiện nó chỉ đổi *cái tên*.

## Bước kế tiếp

Xem [01-buoc-thuc-hien.md](01-buoc-thuc-hien.md).
