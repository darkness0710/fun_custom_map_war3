# Import model & texture bằng script

> **Trạng thái:** Đã chạy — Uther đã vào map cho `H001`
> **Cập nhật:** 2026-09-16
> **Công cụ:** [w3import.py](../../w3import.py)

```
python w3import.py list
python w3import.py add models/heroes/UtherV2.mdx war3mapImported/UtherV2.mdx
python w3import.py add models/heroes/Uther.blp  "units/HotS/Uther/Uther.blp"
python w3import.py rm  war3mapImported/UtherV2.mdx
```

Map dạng **folder** thì "import" chỉ là hai việc: đặt file đúng đường dẫn tương
đối bên trong thư mục map, và ghi tên nó vào `war3map.imp`.

Đổi model của unit thì thêm một bước: đặt trường `umdl` (*Art - Model File*) trong
`war3map.w3u` — làm bằng [w3obj.py](../../w3obj.py).

## Đường dẫn texture nằm cứng trong file `.mdx`

Đây là chỗ sai thường gặp nhất, và nó **hỏng im lặng** — model ra màu xanh lá,
không có lỗi nào.

File `.mdx` có chunk `TEXS` liệt kê đúng đường dẫn nó sẽ đi tìm. Mỗi mục 268 byte:
một `int replaceableId`, rồi 260 byte đường dẫn kết thúc bằng byte 0. Đọc nó
**trước** khi import.

`UtherV2.mdx` đọc ra:

| | Đường dẫn | Phải làm gì |
|---|---|---|
| [0] | `units\HotS\Uther\Uther.blp` | **import đúng đường dẫn này** |
| [1] | `Textures\RibbonBlur1.blp` | có sẵn trong Warcraft, bỏ qua |
| [2] | *(rỗng)* `replaceableId=2` | màu đội, engine tự lo |

Import `Uther.blp` vào `war3mapImported\Uther.blp` như mặc định của World Editor
là model không tìm thấy texture.

## Cũng nên đọc chunk `SEQS`

Danh sách hoạt ảnh của model. `UtherV2.mdx` có 22 cái, trong đó có `Stand`,
`Walk`, `Attack - 1`, `Attack - 2`, `Death`, `Dissipate`, `Spell`, `Portrait - 1`.

Thiếu `Decay` — **không sao, vì hero dùng `Dissipate` chứ không dùng `Decay`.**
Nếu gắn model này cho quái thường thì thiếu `Decay` là xác nằm mãi không tan.

Có sẵn `Portrait - 1` bên trong nên không cần file `UtherV2_Portrait.mdx` riêng.

## Định dạng `war3map.imp` — cờ là **21** (0x15)

```
int   phiên bản = 1
int   số mục
  mỗi mục:
    byte  cờ
    chuỗi kết thúc bằng byte 0
```

Đo từ file World Editor tự tạo, không phải đoán:

```
01 00 00 00                            phiên bản = 1
02 00 00 00                            số mục   = 2
15   units\HotS\Uther\Uther.blp    00
15   war3mapImported\UtherV2.mdx   00
```

World Editor ghi **21 cho cả hai** — đường dẫn mặc định lẫn đường dẫn tự đặt.

### Đoán sai số này là mất cả code

Trước đó `w3import.py` ghi **13**. Hậu quả không phải "Import Manager hiển thị
sai" như tôi tưởng, mà là: **World Editor bỏ qua luôn `war3map.lua` khi đóng
gói.** Vào game không có dòng code nào chạy, không lỗi nào báo, không có cả file
vết.

Mất gần một buổi đi tìm lỗi trong code — trong khi code hoàn toàn đúng.

### Cách đo ra

| Bước | Kết quả |
|---|---|
| `luaparser` phân tích `war3map.lua` | cú pháp hợp lệ → loại trừ lỗi biên dịch |
| Chèn `DarknessBoot.txt` ghi ngay dòng đầu chunk | **không có file** → chunk không nạp một dòng |
| Thử A/B: gỡ import ra, build lại | code chạy lại ngay → thủ phạm là khâu import |
| Để World Editor tự import rồi đọc `war3map.imp` | cờ = 21, không phải 13 |

**Bài học:** đã đo `war3map.w3a` và `war3map.w3u` bằng mẫu thật rồi, nhưng lại
đoán `war3map.imp` vì nghĩ "nó chỉ để liệt kê". **Không có trường nào trong một
định dạng nhị phân là "chỉ để hiển thị".**

### Thư mục `units/` thì không sao

World Editor cũng tự tạo `test2.w3x/units/HotS/Uther/` khi import — đúng chỗ
script đặt. Nghi can này loại trừ.

## Bẫy quy trình

**World Editor giữ bản map trong bộ nhớ nó.** Script ghi file từ bên ngoài xong
mà Ctrl+F9 ngay thì nó đóng gói bản cũ. Phải **đóng map rồi mở lại**.

`build.py` dò `tasklist` và báo to nếu World Editor đang chạy.

**World Editor ghi đè `war3map.lua` mỗi lần Save.** Import xong Save là mất code,
phải chạy lại `build.py`.

Thứ tự đúng khi vừa import vừa sửa code:

```
World Editor: import, Save
python build.py                  ←  LUÔN sau Save
đóng map trong World Editor, mở lại
Ctrl+F9
```
