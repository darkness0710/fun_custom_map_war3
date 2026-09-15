# Đóng gói map: tự làm, không qua World Editor

> **Trạng thái:** Đã chạy — model tự import hiện đúng
> **Cập nhật:** 2026-09-16
> **Công cụ:** [w3mpq.py](../../w3mpq.py) · [build.py](../../build.py)

```
python build.py --run     # build code, đóng gói, chạy luôn
python build.py --pack    # chỉ đóng gói ra file .w3x
```

Thư mục map là định dạng làm việc của World Editor. **Warcraft chỉ chơi được file
`.w3x` đã đóng gói** — nên trước đây mọi lần test đều phải qua Ctrl+F9.

Giờ tự đóng gói. World Editor chỉ còn dùng để **sửa dữ liệu**, không còn dùng để
**test**.

## Vì sao bản tự đóng gói chạy mà Ctrl+F9 thì không

Hai khác biệt, cả hai đều đo được:

### 1. World Editor sinh lại `war3map.lua`

Mỗi lần Save, nó dựng lại file script từ dữ liệu Trigger Editor của nó — xoá sạch
khối code `build.py` vừa chèn. Vòng lặp *build → Save → mất → build lại* không bao
giờ kết thúc.

Bộ đóng gói này **chép thư mục nguyên trạng**, không đụng vào `war3map.lua`.

### 2. Tên file import được ghi bằng dấu gạch khác nhau

| | Tên trong archive |
|---|---|
| World Editor | `units/HotS/Uther/Uther.blp` — **gạch xuôi** |
| Bộ đóng gói này | `units\HotS\Uther\Uther.blp` — **gạch ngược** |

Đường dẫn texture nằm **cứng trong file `.mdx`** và dùng gạch ngược. MPQ **băm
chuỗi tên** để tra file — hai dạng cho hai mã băm khác nhau.

Đó là lý do model đen: World Editor luôn chuyển `\` thành `/` khi lưu, và không
có cách nào bắt nó giữ `\`.

> Điều lạ đã quan sát được: unit **đặt sẵn** trong World Editor vẫn hiện đúng màu
> ngay cả với bản Ctrl+F9, chỉ unit tạo bằng `CreateUnit` lúc chạy mới đen. Hai
> đường nạp model của Warcraft xử lý chuỗi khác nhau. Không đào tiếp vì bộ đóng
> gói riêng đã giải quyết cả hai.

## Định dạng MPQ, phần đủ dùng

```
char[4]  'MPQ' 0x1A
uint32   headerSize = 32
uint32   archiveSize
uint16   formatVersion = 0
uint16   blockSize = 3
uint32   hashTablePos
uint32   blockTablePos
uint32   hashTableSize      -- phải là luỹ thừa của 2
uint32   blockTableSize     -- = số file
```

Sau header là dữ liệu file nối đuôi nhau, rồi bảng băm và bảng khối — **cả hai
đều mã hoá**, khoá lấy từ chuỗi `"(hash table)"` và `"(block table)"`.

Mỗi ô bảng băm 16 byte: `hashA`, `hashB`, `locale`, `platform`, `chỉ số khối`. Ô
trống có chỉ số `0xFFFFFFFF`. Va chạm thì dò tuyến tính sang ô kế.

**Không nén file nào.** Cờ `0x80000000` (tồn tại), dữ liệu để nguyên. Map to hơn
— 3,79 MB so với 1,34 MB của World Editor — nhưng bỏ được toàn bộ phần nén/giải
nén, và kích thước không phải vấn đề ở đây.

## Tự kiểm sau khi đóng gói

`pack` đọc lại file vừa ghi **bằng chính bộ đọc của mình** và kiểm mọi file tìm
thấy được:

```
[ok] dong goi: 19 file, 3,790,383 byte
     doc lai: tim thay du 19/19 file
```

Không đủ thì báo lỗi ngay, không đợi vào game mới biết.

## Xem bên trong một map bất kỳ

```
python w3mpq.py info <file.w3x>
python w3mpq.py has  <file.w3x> "war3map.lua" "war3mapImported\model.mdx"
```

Đây là thứ đáng viết sớm hơn nhiều. Nó trả lời dứt điểm **"file có trong map
không, dưới tên nào"** — câu hỏi đã tốn cả buổi đoán tới đoán lui.

## Nạp trước tài nguyên tự import

`CFG.PRELOAD` liệt kê đường dẫn cần nạp trước, gọi lúc khởi động:

```lua
PreloadStart()
Preload([[war3mapImported\UtherV2.mdx]])
PreloadEnd(0.5)
```

> **Đừng lẫn với `PreloadGenStart` / `PreloadGenEnd`.** Cặp đó dùng để *sinh* file
> preload — lẫn vào trong đó thì `Preload()` chỉ ghi tên vào file chứ không nạp gì
> cả. Bộ ghi vết của dự án dùng đúng nhóm `PreloadGen*` cho việc khác.

Chưa tách được `Preload` hay bộ đóng gói riêng mới là thứ chữa được model đen —
hai thay đổi vào cùng lúc. Muốn biết thì tắt `CFG.PRELOAD` rồi đóng gói lại.
