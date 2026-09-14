# 0001 — `src/` nằm ngoài thư mục map

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

Map lưu dạng thư mục (`test2.w3x/`) thay vì file nén, để code và địa hình cùng
nằm dưới quyền kiểm soát của công cụ dòng lệnh. Câu hỏi: file `.lua` nguồn để ở
đâu.

## Quyết định

`src/`, `build.py` và `docs/` nằm **ngang hàng** với thư mục map, không nằm trong
nó. Thứ duy nhất build ghi vào map là `test2.w3x/war3map.lua`.

```
DarknessCustomMap/
    src/          ← nguồn
    docs/         ← đặc tả
    build.py
    build/        ← backup bản trước
    test2.w3x/    ← map, chỉ war3map.lua bị ghi
```

## Phương án đã loại

**Để `src/` bên trong thư mục map.** Loại vì World Editor coi mọi file trong đó
là tài nguyên của map: nó sẽ đóng gói toàn bộ `.lua` nguồn vào `.w3x` khi export.
Hệ quả là map phình ra và lộ nguyên code, còn WE thì có thể ghi đè hoặc dọn dẹp
những file lạ nó không nhận ra.

## Hệ quả

**World Editor ghi đè `war3map.lua` mỗi lần Save.** Nên `build.py` phải là bước
cuối cùng trước khi test, luôn luôn:

```
sửa địa hình → Save → python build.py → Ctrl+F9
```

Build chèn code vào cuối `war3map.lua`, giữa hai dòng marker. Chạy lại thì nó cắt
khối cũ theo marker rồi chèn lại từ đầu, nên lặp bao nhiêu lần cũng ra một kết
quả. `python build.py --strip` trả file về đúng bản World Editor sinh ra.
