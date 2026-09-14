# 0002 — Gọi chéo module qua bảng `API`

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

`build.py` nối chín file `src/*.lua` thành **một** khối `do ... end` trong
`war3map.lua`. Ý định ban đầu: cùng một khối thì `local S`, `local CFG` khai báo
ở file đầu sẽ nhìn thấy được từ mọi file sau.

Điều đó đúng, nhưng chỉ đúng một chiều. Lua bắt upvalue **lúc định nghĩa hàm**,
không phải lúc gọi. Nên một hàm trong `05_wave.lua` viết:

```lua
refreshBoard()   -- khai báo là local ở 07_ui.lua, tức là SAU
```

sẽ không gọi local đó. Lúc `05` được nạp, cái tên ấy chưa tồn tại, nên Lua hiểu
là biến toàn cục — và nó bằng `nil`. Lỗi chỉ nổ lúc chạy, không phải lúc build.

## Quyết định

`02_state.lua` khai báo `local API = {}`. Mỗi module gắn hàm dùng chung của mình
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
