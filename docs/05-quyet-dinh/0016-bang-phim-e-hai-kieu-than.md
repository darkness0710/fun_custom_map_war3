# 0016 — Bảng phím E có hai kiểu thân, không phải một

> **Phím đã đổi E → R** (2026-09-16). E trở thành phím tắt của Bất Hoại, kỹ
> năng chủ động thứ ba, và một phím không thể vừa bấm skill vừa mở bảng. Tiêu
> đề và tên file giữ nguyên để không gãy liên kết; phím thật nằm ở
> `CFG.PANEL_KEY`.

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-16

## Bối cảnh

`1_panel.lua` chỉ biết vẽ **một** kiểu thân bảng: hàng × ô, mỗi thẻ tự khai báo
cột của nó, và một nút `+` rộng `0.028` ở mép phải.

Đo ở 1080p:

| | Kích thước | Pixel |
|---|---|---|
| Khung bảng | `0.46 × 0.394` | 828 × 709 |
| Một dòng | `ROW_H = 0.024` | 43 |
| Icon | `ICON = 0.018` | **32** |
| Nút | `0.028 × 0.020` | **50 × 36** |

Khung không hề nhỏ — nó chiếm 66% chiều cao màn hình. Thứ nhỏ là **mọi thứ bên
trong nó**. Và `1_panel.lua` không gọi `BlzFrameSetScale` lần nào, nên tiêu đề,
tên và chú thích cùng một cỡ chữ.

Thẻ Kỹ Năng chia 680 px cho **5 cột** → cột "Bậc" còn 81 px. Text frame không đặt
kích thước nên chữ dài tràn sang cột bên; code đã biết chuyện này và chữa bằng
cách cho chữ click-through, tức chữa phần *bấm* chứ không chữa phần *nhìn*.

Nhưng gốc rễ không phải kích thước. Bốn hệ không cùng hình dạng:

- **Tu Vi** là một cái thang có **đúng một hành động**. Bảng tính hiện 7 dòng
  mà 6 dòng không bấm được.
- **Kỹ Năng, Trang Bị, Pháp Khí** là danh sách 7 / 6 / 5 món độc lập.

## Quyết định

**Hai kiểu thân bảng. Thẻ khai báo dữ liệu, bảng lo bố cục.**

```lua
-- kind = "list"   ->  Ky Nang, Trang Bi, Phap Khi  (3/4 the)
{ ten, kind = "list", rows,
  items      = function(pid) -> { {icon, ten, mota, status, nut, btnOn} }
  itemAction = function(pid, i) }

-- kind = "focus"  ->  Linh Can  (1/4 the)
{ ten, kind = "focus",
  info   = function(pid) -> { titleF, phu, dong, progress, note, nut, btnOn }
  action = function(pid) }
```

Đảo ngược quan hệ cũ: trước đây thẻ phải tự biết bề ngang từng cột, giờ nó chỉ
trả về một danh sách mục. Thêm một hệ mới không phải đo cột, không phải dựng
thêm bảng.

Kích thước đi kèm:

| | Trước | Sau | 1080p |
|---|---|---|---|
| `PANEL_W` | 0.46 | 0.56 | 828 → 1008 px |
| Dòng | 0.024 | 0.048 | 43 → 86 px |
| Icon | 0.018 | 0.036 | 32 → **65 px** |
| Nút | 0.028 | 0.105 | 50 → **189 px** |
| Cỡ chữ | một cỡ | ba cấp | `API.frameScale` |
| Nền | `TeamColor27` (ô màu đặc) | template FDF có viền | `API.backdrop` |

Nút rộng 189 px để chứa **chữ *và* giá** (`NANG   178`), thay cho một dấu `+` cô
độc không nói được nó tốn bao nhiêu.

**Nút thiếu tiền thì mờ đi, không ẩn.** Ẩn nút là giấu mất giá, mà giá chính là
thứ người chơi cần để biết phải để dành bao nhiêu.

## Phương án đã loại

**Chỉ chỉnh cỡ, giữ bảng tính.** Rẻ và ít rủi ro. Loại vì nó không chạm tới
nguyên nhân: Tu Vi vẫn hiện 6 dòng không bấm được, và Kỹ Năng vẫn là 5 cột
chật. Phóng to một bố cục sai thì được một bố cục sai lớn hơn.

**Mỗi thẻ tự vẽ thân của mình.** Linh hoạt nhất. Loại vì bốn thẻ sẽ lệch nhau về
canh lề, cỡ chữ và vị trí nút — đúng cái mà khung chung sinh ra để ngăn. Và ba
trong bốn thẻ có cùng hình dạng, nên đó là ba bản sao của một đoạn code.

**Thêm thanh cuộn.** Loại vì không cần: thẻ dài nhất có 8 mục, và bảng cao 0.504
trên màn hình 0.6 chứa vừa. Thanh cuộn trong `BlzFrameSetSize` phải tự viết.

## Hệ quả

`CFG.PANEL_H` vẫn không tồn tại — chiều cao **suy ra** từ số mục của thẻ dài
nhất, tính lúc `startPanel()`. Thêm một hệ 9 mục thì bảng tự rộng ra.

`API.backdrop` và `API.frameScale` nằm ở [2_state.lua](../../src/1_core/2_state.lua),
dùng chung với bảng chọn hero. Bảng chọn kỹ năng
([3_skillframe.lua](../../src/4_ui/3_skillframe.lua)) **vẫn dùng ô màu
phẳng** — đổi sang `API.backdrop` là một dòng, chưa làm.
