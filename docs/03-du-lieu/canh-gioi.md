# Hai mươi cảnh giới

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-16
> **Code:** [2_wave.lua](../../src/3_tran_dau/2_wave.lua) — `decode()`, `tierLabel()`
> **Khoá CFG:** `REALMS` `TIERS_PER_REALM`

Bảng tra. Đây là dữ liệu tham chiếu, không phải luật — luật nằm ở
[02-he-thong/dot-quai.md](../02-he-thong/dot-quai.md).


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
