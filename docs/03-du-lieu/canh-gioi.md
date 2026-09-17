# Hai mươi cảnh giới

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-16
> **Code:** [2_wave.lua](../../src/3_tran_dau/2_wave.lua) — `decode()`, `tierLabel()`
> **Khoá CFG:** `REALMS` `TIERS_PER_REALM`

Bảng tra. Đây là dữ liệu tham chiếu, không phải luật — luật nằm ở
[02-he-thong/dot-quai.md](../02-he-thong/dot-quai.md).



## Đột phá cộng bao nhiêu chỉ số

Mỗi lần đột phá **cộng thêm** một cục, và cục đó **gấp đôi** mỗi bậc
(`LINHCAN_STAT_GAIN = 50`, `LINHCAN_STAT_STEP = 2.0`):

| Bậc | Cộng lần này | Cộng dồn | Hệ số | Chưởng bậc 10 | EHP quái đầu cảnh giới | Phát |
|---|---|---|---|---|---|---|
| 1 | — | 0 | ×1.00 | 47 | 120 | 2.5 |
| 2 | +50 | 50 | ×2.85 | 135 | 249 | 1.8 |
| 3 | +100 | 150 | ×6.56 | 311 | 518 | 1.7 |
| 4 | +200 | 350 | ×13.96 | 662 | 1,076 | 1.6 |
| 5 | +400 | 750 | ×28.78 | 1,364 | 2,234 | 1.6 |
| 10 | +12,800 | 25,550 | ×947 | 44,905 | 86,420 | 1.9 |
| 15 | +409,600 | 819,150 | ×30,340 | 1,438,223 | 3,342,536 | 2.3 |
| 20 | +13,107,200 | **26,214,350** | ×970,903 | 46,024,403 | 129,282,152 | 2.8 |

Cột cuối là thứ giữ cả bảng lại với nhau: **một con quái luôn tốn 1.6–2.8 phát
Chưởng**, từ wave 1 tới stage 100. Con số tuyệt đối phình ra hàng chục triệu
nhưng *cảm giác chơi* đứng yên.

**Cộng thêm, không phải nhân.** Bản trước nhân chỉ số lên `1.17^(bậc−1)` rồi giải
ngược để bù phần sát thương nền. Bỏ vì một lý do giao diện chứ không phải toán:
người chơi không đọc được "×1.17", họ đọc được "**+50 chỉ số**" — con số nhìn
thấy ngay trên bảng hero sau khi bấm.

> **26 triệu là hệ quả của việc gấp đôi 19 lần, không phải lỗi.** Đổi
> `LINHCAN_STAT_STEP` là đổi cả họ: `2.0` → 26,214,350 · `1.7` → 1,707,589 ·
> `1.5` → 221,584. Đổi nó thì **phải** tính lại `CFG.MOB_EHP_REALM_STEP` theo
> (`1.7` ứng với `1.65`), nếu không quái và hero rời nhau ngay.

`powerAt()` giờ **suy ra từ** chỉ số chứ không còn là một đường cong riêng — sát
thương `= hệ số × (DMG_BASE + chỉ số)`, nên hệ số hiện ra đúng bằng tỉ lệ sát
thương thật. Trước đây nó là hằng số riêng và có thể nói khác chỉ số thật.

## Bốn tầng trong một cảnh giới

`CFG.TIER_NAMES` — tầng có **tên**, không đánh số:

| # | Tiếng Việt | Tiếng Anh |
|---|---|---|
| 1 | Sơ Kì | Early |
| 2 | Trung Kì | Middle |
| 3 | Hậu Kì | Late |
| 4 | Viên Mãn | Perfection |

Tên quái ghép từ cảnh giới + tầng: *Trúc Cơ Trung Kì - Tán Tu*. Đọc ra nghĩa
ngay, khác "Trúc Cơ Tầng 3" vốn bắt phải nhớ tầng 3 trên tổng bao nhiêu.

Boss không có tầng — nó là lần độ kiếp **duy nhất** của cảnh giới đó.

> Số phần tử phải bằng `CFG.TIERS_PER_REALM`. Thiếu thì `tierLabel()` lui về
> đánh số, nên đổi `TIERS_PER_REALM` mà quên thêm tên thì vẫn chạy, chỉ là tên
> xấu — không nổ lỗi.

## Đếm cho đúng trước khi code

Danh sách có **20 cảnh giới**, không phải 23. Mỗi cảnh giới 4 tầng, cuối mỗi
cảnh giới một boss:

```
20 cảnh giới × 4 tầng           =  80 wave thường
20 cảnh giới × 1 boss           =  20 wave boss
                                  ───────────────
                                   100 stage
```

Con số 230/23 là đếm nhầm. Sửa ở đây một lần rồi mọi chỗ khác dùng 100.

## Chỉ số hoá: một con số chạy suốt

Đừng giữ hai biến `realm` và `tier` song song — chúng sẽ lệch nhau. Giữ **một**
biến `stage` ∈ [1, 100], suy ra hai cái kia:

```lua
local realm = math.floor((stage - 1) / 11) + 1   -- 1..20
local k     = ((stage - 1) % 11) + 1             -- 1..11
local isBoss = (k == 11)
local tier   = isBoss and 10 or k                -- 1..10
```

Số **11** ở đây là `TIERS_PER_REALM + 1`, không phải hằng số ma thuật. Boss
chiếm đúng một stage, nên một cảnh giới là 5 stage.

Kiểm nhanh: `stage 1` → Phàm Nhân tầng 1. `stage 10` → Phàm Nhân **viên mãn**.
`stage 11` → boss Phàm Nhân. `stage 12` → Luyện Khí tầng 1. `stage 100` → boss
Sáng Thế Thần, stage cuối.

## Tầng 10 gọi là Viên Mãn

Tầng 1…9 hiện là "Phàm Nhân tầng 3". Tầng 10 hiện là "Phàm Nhân **viên mãn**" —
đây là tên riêng của tầng cuối, không phải tầng 11.

## Bảng tên

Cột **Trong game** là bắt buộc, không phải tiện tay: font gốc của Warcraft III
thiếu glyph Latin Extended (U+1EA0…U+1EF9), chữ có dấu tiếng Việt hiện ra thành ô
vuông. Mọi chuỗi đi vào `DisplayTimedTextToPlayer` hay tên unit phải lấy từ cột
này. Chú ý `Đ` → `D`.

| # | Cảnh giới | Trong game | Stage | Cõi |
|---|---|---|---|---|
| 1 | Phàm Nhân | `Pham Nhan` | 1–11 | Phàm |
| 2 | Luyện Khí | `Luyen Khi` | 12–22 | Phàm |
| 3 | Trúc Cơ | `Truc Co` | 23–33 | Phàm |
| 4 | Kim Đan | `Kim Dan` | 34–44 | Phàm |
| 5 | Nguyên Anh | `Nguyen Anh` | 45–55 | Phàm |
| 6 | Hóa Thần | `Hoa Than` | 56–66 | Yêu |
| 7 | Luyện Hư | `Luyen Hu` | 67–77 | Yêu |
| 8 | Hợp Thể | `Hop The` | 78–88 | Yêu |
| 9 | Đại Thừa | `Dai Thua` | 89–99 | Yêu |
| 10 | Độ Kiếp | `Do Kiep` | 100–110 | Yêu |
| 11 | Chân Tiên | `Chan Tien` | 111–121 | Tiên |
| 12 | Thiên Tiên | `Thien Tien` | 122–132 | Tiên |
| 13 | Kim Tiên | `Kim Tien` | 133–143 | Tiên |
| 14 | Thái Ất | `Thai At` | 144–154 | Tiên |
| 15 | Đại La | `Dai La` | 155–165 | Tiên |
| 16 | Tiên Đế | `Tien De` | 166–176 | Thần |
| 17 | Thánh Nhân | `Thanh Nhan` | 177–187 | Thần |
| 18 | Đạo Tổ | `Dao To` | 188–198 | Thần |
| 19 | Hỗn Độn Thần | `Hon Don Than` | 199–209 | Thần |
| 20 | Sáng Thế Thần | `Sang The Than` | 210–100 | Thần |

## Bốn cõi — vì sao gom nhóm

Cột **Cõi** gom 20 cảnh giới thành 4 nhóm 5 cảnh giới. Lý do là kỹ thuật, không
phải văn vẻ: **Warcraft III không đổi được model của unit lúc chạy.** Muốn quái
nhìn khác nhau thì phải có sẵn ngần ấy unit type trong Object Editor.

Một unit type cho mỗi cảnh giới × mỗi mẫu lính = 20 × 6 = 120 unit. Không ai
ngồi làm nổi. Một unit type cho cả 20 cảnh giới thì wave 200 trông y hệt wave 1.

Bốn cõi là điểm giữa: **4 cõi × 6 mẫu lính = 24 unit type**. Trong một cõi, năm
cảnh giới dùng chung model, phân biệt bằng thứ *đổi được lúc chạy* —
`SetUnitScale` và `SetUnitVertexColor`.

| Cõi | Cảnh giới | Hướng model | Màu gợi ý |
|---|---|---|---|
| Phàm | 1–5 | Người, thổ phỉ, thú hoang (`Footman`, `Bandit`, `Rifleman`, `Kobold`) | trắng → nâu |
| Yêu | 6–10 | Undead, quái vật (`Ghoul`, `Abomination`, `Skeleton`, `Gargoyle`) | xanh tái |
| Tiên | 11–15 | Naga, satyr, quỷ (`Naga Myrmidon`, `Satyr`, `Felguard`) | tím → lam |
| Thần | 16–20 | Rồng, infernal, thiên binh (`Dragon`, `Infernal`, `Faerie Dragon`) | vàng kim |

Tinh anh **không cần unit type riêng**: nó là mẫu `Tốt` của cõi đó, phóng to bằng
`ELITE_SCALE` và đổi màu. Chỉ boss mới cần unit type riêng — xem
[02-he-thong/boss.md](../02-he-thong/boss.md).

Tổng việc Object Editor: **24 lính + 20 boss = 44 unit type.**

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `REALMS` | Bảng 20 dòng `{ ten, tenGame, coi }` | Phải đúng 20 dòng, đúng thứ tự. `tenGame` **không dấu** |
| `TIERS_PER_REALM` | Số tầng mỗi cảnh giới | `10`. Đổi số này là đổi tổng số stage — mọi công thức suy ra từ nó, không hard-code số 11 ở đâu cả |

## Chưa làm

- 20 tên boss. Chưa đặt — xem [boss.md](../02-he-thong/boss.md).
- Unit type thật trong Object Editor. Bảng model ở trên mới là gợi ý.
- Chưa có cơ chế lưu tiến độ. Chơi hết 100 stage là một mạch 2 tiếng.
