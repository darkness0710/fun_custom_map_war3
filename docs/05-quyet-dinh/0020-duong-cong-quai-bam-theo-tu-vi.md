# 0020 — Đường cong quái định nghĩa bằng đường cong Tu Vi, bỏ ngân sách ×967

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-17
> **Thay thế phần ngân sách của** [0015](0015-ba-dong-tien-ba-loai-quai.md)

## Bối cảnh

Đến 2026-09-16, map chạy **hai đường cong dựng riêng** rồi cố dán vào nhau:

- **Quái**: `MOB_EHP_BASE × MOB_EHP_REALM_STEP^(r−1)` — đều đặn ×1.22 mỗi cảnh giới.
- **Người chơi**: tích của bốn hệ nâng cấp, phải ra ×967 thì mới theo kịp.

Cả hai đều là **phỏng đoán**, và chúng khác nhau không chỉ ở độ dốc mà ở **hình**:

| | Bậc 1→2 | Bậc 4→5 | Bậc 19→20 |
|---|---|---|---|
| Tu Vi (cộng thêm rồi ×1.30) | ×2.85 | ×1.55 | ×1.30 |
| Quái (bản cũ, phẳng) | ×1.22 | ×1.22 | ×1.22 |

Đo được hệ quả: hero vọt lên ở bậc 4–5 **giết lính một phát**, rồi tụt lại ở
cuối ván. Không hằng số nào sửa được — chọn `MOB_EHP_REALM_STEP` bằng bao nhiêu
cũng chỉ dời chỗ lệch chứ không xoá được nó.

Và cái ngân sách ×967 tự nó đã là một món nợ: mỗi lần thêm hoặc khoá một hệ là
phải **tính lại tích của cả bốn** rồi sửa `LINHCAN_STEP` cho khớp. Đã làm hai
lần (1.215 → 1.17), và cả hai lần đều đúng *với bản ngân sách lúc đó*.

## Quyết định

**EHP quái không có đường cong riêng nữa. Nó là hệ số Tu Vi.**

```lua
CFG.MOB_EHP_THEO_LINHCAN = true

-- src/3_tran_dau/2_wave.lua
ehp = CFG.MOB_EHP_BASE * lcPower(realm) * CFG.MOB_EHP_GROWTH ^ (tier - 1)
```

`lcPower(r)` là **đúng cái hàm** Tu Vi dùng để tính sức mạnh người chơi ở bậc
`r`. Hai vế có chung thừa số nên nó **triệt tiêu**: tỉ lệ "mấy phát một con"
phẳng **theo định nghĩa**, không phải nhờ cân bằng khéo.

Điều kiện duy nhất còn lại: người chơi lên **đúng một bậc mỗi cảnh giới**. Đó
chính là giao kèo `LINHCAN_COST_BASE = 500` phẳng + một cảnh giới kiếm đúng 500
Linh Khí.

Sát thương quái bám theo nhưng **dốc thoải hơn** (`MOB_DMG_THEO_MU = 0.85`), có
chủ ý: người chơi phải thấy mình dày lên chứ không giậm chân.

**Ngân sách ×967 bỏ hẳn.** Không còn con số nào mà tích bốn hệ phải đạt tới.

## Phương án đã loại

**Chọn lại `MOB_EHP_REALM_STEP` cho khớp.** Không được — hai đường khác *hình*
chứ không chỉ khác độ dốc. Một hằng số chỉ dời được chỗ lệch: khớp đầu ván thì
lệch cuối, khớp cuối thì lệch đầu.

**Làm đường cong Tu Vi phẳng cho giống quái** (mỗi bậc ×1.30 đều). Bỏ vì cảm
giác "đột phá" đến từ cú nhảy lớn ở những bậc đầu — `+50` trên nền `10` là ×2.85,
và đó là thứ khiến lần đột phá đầu tiên đáng nhớ. Làm phẳng nó là đổi một vấn đề
cân bằng lấy một map nhạt.

**Giữ ngân sách ×967 và tiếp tục chỉnh tay.** Đây là hiện trạng cũ. Bỏ vì chi
phí của nó không nằm ở lần tính đầu mà ở **mọi lần sau**: mỗi thay đổi hệ nào
cũng buộc tính lại cả bốn, mà không có cách nào *kiểm* được là đã tính đúng cho
tới khi chơi thử.

## Hệ quả

**Tu Vi một mình đã đủ bám quái.** Đây là hệ quả quan trọng nhất, và nó **đảo
ngược** cách đọc mọi tài liệu viết trước 2026-09-17.

Mọi nguồn sức mạnh **khác** Tu Vi giờ là phần **vượt lên thuần**, không phải
phần bù cho đủ:

| Nguồn | Đóng góp | Ghi chú |
|---|---|---|
| Tu Vi | ×1.00 so với quái | triệt tiêu theo định nghĩa |
| Cơ Duyên | **+40%** chỉ số cả ván | 140 lượt, nếu luôn chọn thẻ 2 |
| Kỹ Năng | bậc 1→10 | ×1.33 sát thương × 1.5 tần suất |
| Trang Bị | ×8.3 nếu mở lại | **đang khoá** |
| Pháp Khí | chưa có nội dung | **đang khoá** |

Nên câu hỏi cho hai hệ đang khoá **không còn là** "có đủ ×2.5 chưa" mà là **"cho
vượt lên bao nhiêu là vừa"**. Mở lại Trang Bị ở mức ×8.3 cũ là nhân thêm ×8 lên
phần đã vượt — xem cảnh báo ở `CFG.TRANGBI_COST_BASE`.

**Độ khó giờ chỉnh bằng đúng ba nút**, không phải bằng cách suy lại ngân sách:

| Khoá | Chỉnh cái gì |
|---|---|
| `MOB_EHP_BASE` | độ khó tổng thể — nút chính |
| `MOB_EHP_GROWTH` | chênh lệch giữa 4 tầng trong một cảnh giới |
| `MOB_DMG_THEO_MU` | người chơi dày lên nhanh hay chậm |

**Điều phải giữ:** nếu người chơi **không** đột phá mỗi cảnh giới thì hợp đồng
gãy — quái vẫn lên theo bậc *của họ*, nhưng chỉ số thì không. Giao kèo 500 Linh
Khí phẳng là thứ bảo vệ điều đó, nên **đổi `LINHCAN_COST_BASE` hay thu nhập là
phải kiểm lại cả ADR này**.

**Còn nợ:** `MOB_EHP_REALM_STEP` và ba khoá `MOB_DMG_*_STEP` vẫn nằm trong config
cho nhánh `MOB_EHP_THEO_LINHCAN = false`. Giữ để so sánh khi chơi thử; xoá khi
đã chắc.
