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
đối bên trong thư mục map, và ghi tên nó vào `war3map.imp`. Không cần mở Import
Manager.

Đổi model của unit thì thêm một bước: đặt trường `umdl` (*Art - Model File*) trong
`war3map.w3u` — làm bằng [w3obj.py](../../w3obj.py), xem
[sửa & clone ability](sua-va-clone-ability.md).

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
Nếu định gắn model này cho quái thường thì thiếu `Decay` là xác nằm mãi không tan.

Có sẵn `Portrait - 1` bên trong nên không cần file `UtherV2_Portrait.mdx` riêng.

## Byte "cờ" trong `war3map.imp` — chưa đo được

```
int   phiên bản = 1
int   số mục
  mỗi mục:
    byte  cờ
    chuỗi kết thúc bằng byte 0
```

Các tool khác ghi cờ 5, 8, 10 hoặc 13 tuỳ bản. Script ghi **13**. Chưa có mẫu do
World Editor tạo ra để đối chiếu — map này trước đó chưa import gì.

**Không quan trọng bằng vị trí file.** File đặt đúng chỗ mới là thứ làm model
hiện được; `war3map.imp` chỉ để Import Manager liệt kê. Nếu mở World Editor thấy
danh sách sai, chạy `list` sau khi World Editor lưu để đọc giá trị thật rồi sửa
hằng `CO_MAC_DINH` trong [w3import.py](../../w3import.py).

## Cái bẫy đã cắn ngay sau khi import

Vào game **không thấy bảng chọn hero nữa**. Không có lỗi Lua nào trong
`War3Log.txt`, và file vết **không được ghi mới** — tức code không chạy dòng nào.

Nguyên nhân không nằm trong code:

```
vết   : 00:40:52   <- lần chạy cũ
build : 00:44:47   <- file trên đĩa đã đúng
game  : 00:51:58   <- chạy mà không ghi vết nào
```

**World Editor đang mở và giữ bản map trong bộ nhớ nó.** Script ghi ba file từ
bên ngoài (`war3map.lua`, `war3map.w3u`, `war3map.imp`), nhưng Ctrl+F9 đóng gói
bản cũ trong bộ nhớ.

Càng nhiều file sinh từ bên ngoài thì bẫy này càng dễ cắn. Nên `build.py` giờ
**dò xem World Editor có đang chạy không** (`tasklist`) và báo to nếu có:

```
[!] WORLD EDITOR DANG MO -- DONG MAP ROI MO LAI TRUOC KHI Ctrl+F9.
```

> Thứ tự bắt buộc khi có file sinh từ ngoài: **đóng map trong World Editor** →
> chạy script → mở lại map → Ctrl+F9.
