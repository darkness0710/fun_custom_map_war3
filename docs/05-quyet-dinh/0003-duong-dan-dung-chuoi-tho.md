# 0003 — Đường dẫn viết bằng chuỗi thô `[[...]]`

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

Map không biên dịch được. Warcraft III hiện một hộp thoại **trống trơn** chỉ có
nút OK — không nói gì về nguyên nhân. Lý do thật nằm trong
`Documents\Warcraft III\Logs\War3Log.txt`:

```
Map contains invalid Jass scripts that couldn't be compiled by war3,
file: war3map.lua, error: invalid escape sequence near '"Abilities\S'
```

Đường dẫn model trong `CFG` bị viết thành:

```lua
CFG.FX_SPAWN = "Abilities\Spells\Undead\AnimateDead\AnimateDeadTarget.mdl"
```

Đường dẫn tài nguyên của WC3 ngăn cách bằng backslash. Trong chuỗi nháy kép của
Lua, `\S` `\N` `\T` `\U` `\D` `\H` `\A` đều **không phải** escape hợp lệ, và Lua
từ chối biên dịch cả file.

## Quyết định

Mọi đường dẫn trong `src/` viết bằng chuỗi thô:

```lua
CFG.FX_SPAWN = [[Abilities\Spells\Undead\AnimateDead\AnimateDeadTarget.mdl]]
```

Trong `[[...]]` Lua không xử lý escape, nên backslash là ký tự thường và không
có cách nào viết sai.

## Phương án đã loại

**Nhân đôi backslash** (`"Abilities\\Spells\\..."`) — đúng về mặt ngôn ngữ, cho
ra đúng một backslash. Loại vì hai lý do: khó đọc khi đối chiếu với đường dẫn
trong World Editor, và dễ mất một lớp khi đoạn code đi qua công cụ trung gian —
đó chính xác là cách lỗi này phát sinh.

## Hệ quả

`build.py` có thêm `check_escapes()` quét escape không hợp lệ trong mọi chuỗi
ngắn và **chặn ghi file** nếu thấy. Chuỗi `[[...]]` và comment được bỏ qua.

Việc thêm phép kiểm này là cần thiết vì phép kiểm cũ — đếm cân bằng `do`/`end` —
đã báo "ok" cho đúng file hỏng đó. Nó không nhìn vào bên trong chuỗi.

## Bài học rộng hơn

Hộp thoại trống của WC3 không phải là "không có thông tin". Thông tin nằm ở
`Logs\War3Log.txt`. Gặp lỗi im lặng thì mở file đó trước khi đoán bất cứ điều gì.
