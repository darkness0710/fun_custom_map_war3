# 0002 — Gọi chéo module qua bảng `API`

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

`build.py` nối chín file `src/*.lua` thành **một** khối `do ... end` trong
`war3map.lua`. Ý định ban đầu: cùng một khối thì `local S`, `local CFG` khai báo
ở file đầu sẽ nhìn thấy được từ mọi file sau.

Điều đó đúng, nhưng chỉ đúng một chiều. Lua bắt upvalue **lúc định nghĩa hàm**,
không phải lúc gọi. Nên một hàm trong `2_wave.lua` viết:

```lua
refreshBoard()   -- khai báo là local ở 07_ui.lua, tức là SAU
```

sẽ không gọi local đó. Lúc `05` được nạp, cái tên ấy chưa tồn tại, nên Lua hiểu
là biến toàn cục — và nó bằng `nil`. Lỗi chỉ nổ lúc chạy, không phải lúc build.

## Quyết định

`2_state.lua` khai báo `local API = {}`. Mỗi module gắn hàm dùng chung của mình
vào bảng đó ở cuối file:

```lua
API.blockCenter = blockCenter
```

Mọi lời gọi **chéo file** đi qua bảng: `API.blockCenter(3, 3)`. Tra cứu xảy ra
lúc chạy, khi mọi file đã nạp xong, nên thứ tự file không còn quan trọng.

Hàm chỉ dùng trong một file vẫn để `local` thuần — không phải cái gì cũng lên
bảng `API`.

## Phương án đã loại

**Khai báo trước (forward declaration) toàn bộ tên ở file đầu.** Đúng về mặt kỹ
thuật, nhưng phải giữ một danh sách tên song song với code; quên thêm một tên là
lại gặp đúng lỗi `nil` cũ, chỉ khác chỗ.

**Cho mỗi file một khối `do...end` riêng.** Hỏng luôn ý tưởng chia sẻ `S` và
`CFG` — lúc đó phải đẩy chúng thành biến toàn cục, làm bẩn không gian tên chung
với Blizzard.

## Hệ quả

Ba cái tên `S`, `CFG`, `API` là giao ước chung của cả chín file. `build.py` chỉ
bảo đảm **thứ tự nối**, không bảo đảm gì về tên — nên có một phép kiểm chéo riêng
(quét mọi `API.x` được gọi mà không chỗ nào gán) chạy được bất cứ lúc nào.

---

## Cập nhật 2026-09-15 — quy ước này cứu dự án một lần nữa

Map sập không mở được, `War3Log.txt` báo:

```
error: too many local variables (limit is 200) in main function
```

**Lua chỉ cho 200 biến local sống cùng lúc trong một hàm**, và cả bản build là một
hàm. 14 file gộp trong một khối `do...end` là **494 local** — gấp 2,5 lần giới hạn.

Cách sửa: `build.py` bọc **mỗi file trong một khối `do...end` riêng**, và khai báo
`CFG`, `S`, `API` ở phần đầu. Local của mỗi file được giải phóng khi hết khối, nên
mỗi file có hạn mức 200 của riêng nó. Sau khi sửa: **1 local** ở khối ngoài cùng.

**Sửa được trong một lượt là nhờ quyết định này.** Vì mọi lời gọi chéo file đã đi
qua `API` từ đầu, không file nào gọi thẳng local của file khác — kiểm lại xác nhận
**0 vi phạm**. Nếu trước đây cứ để các file gọi thẳng nhau (chúng *sẽ* chạy, vì
cùng một khối), thì bây giờ phải sửa hàng trăm chỗ.

Từ giờ quy ước này không còn là lựa chọn phong cách mà là **bắt buộc kỹ thuật**:
local của file A không còn nhìn thấy được từ file B. `build.py` kiểm và **chặn ghi
file** nếu phát hiện gọi chéo.
