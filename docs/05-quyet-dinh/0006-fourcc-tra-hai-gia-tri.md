# 0006 — `FourCC` trả về hai giá trị: luôn dùng `id()`

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

Map sập `ACCESS_VIOLATION` ngay khi khởi tạo, ba lần liên tiếp. Hai lần đầu tôi
đoán sai nguyên nhân (thao tác quầy hàng trong sự kiện, rồi tên trường Blz API).
Lần thứ ba mới có dữ liệu thật, nhờ ghi vết ra file bằng `PreloadGenEnd`:

```
tavern: RemoveUnitFromStock mac dinh #1 … #9      ← bảng chỉ có 8 phần tử
tavern: AddUnitToStock hero #1 … #4               ← bảng chỉ có 3 phần tử
tavern: grantBuyingPower                          ← dòng cuối, chết ở đây
```

Cả hai bảng chạy **dư đúng một vòng**. Đó là manh mối quyết định.

## Nguyên nhân

`FourCC` của Warcraft III trả về **hai** giá trị, không phải một — nó được cài
bằng `string.unpack`, hàm này trả về `(giá trị, vị trí kế tiếp)`.

Trong Lua, lời gọi hàm ở **vị trí cuối** của một table constructor nở ra thành
*tất cả* giá trị nó trả về. Các vị trí khác bị cắt còn một.

```lua
CFG.TAVERN_HEROES = {
  FourCC('Emoo'),   -- cắt còn 1 giá trị
  FourCC('Hpal'),   -- cắt còn 1 giá trị
  FourCC('Hblm'),   -- Ở CUỐI: nở thành 2 giá trị
}
-- #CFG.TAVERN_HEROES == 4, phần tử thứ 4 là một số rác
```

Rồi `grantBuyingPower` gọi `GetUnitGoldCost(rác)`. Native này **không trả về
lỗi** với id không hợp lệ — nó đọc bậy bộ nhớ và làm sập game.

## Quyết định

**Không gọi `FourCC` trần trong `src/`.** Dùng `id()` ở
[1_config.lua](../../src/1_core/1_config.lua):

```lua
local function id(fourcc)
  return (FourCC(fourcc))   -- cặp ngoặc đơn cắt về đúng một giá trị
end
```

Cặp ngoặc đơn bao quanh một lời gọi hàm là cú pháp Lua để ép về một giá trị. Bọc
ở chỗ *định nghĩa* thì mọi chỗ dùng đều an toàn, không phải nhớ gì nữa.

## Hai hàng rào đi kèm

**Ở tầng build.** `build.py` cảnh báo khi thấy `FourCC` gọi trần (không được bọc
ngoặc). Cảnh báo chứ không chặn build — `FourCC` trần trong phép gán đơn vẫn an
toàn, vì phép gán tự cắt còn một giá trị.

**Ở tầng chạy.** `07_tavern.lua` kiểm mọi unit id trước khi đưa vào engine:

```lua
local function validId(uid)
  return type(uid) == "number" and uid >= 0x20202020
end
```

Một FourCC hợp lệ luôn ≥ `0x20202020` (bốn ký tự in được). Id không đạt thì bỏ
qua và báo ra, thay vì để nó đi sâu vào engine.

Hàng rào này cần thiết vì **không bắt lỗi sau được**: `GetUnitGoldCost` với id
rác không ném lỗi, nó sập. Phải chặn trước khi gọi.

## Phương án đã loại

**Nhớ bọc ngoặc ở từng chỗ dùng** — `{ (FourCC('a')), (FourCC('b')) }`. Đúng về
kỹ thuật nhưng quên một chỗ là sập lại, và triệu chứng thì ở cách đó rất xa.

**Chỉ dựa vào `validId`** mà không sửa gốc. Chặn được crash nhưng bảng vẫn thừa
phần tử, và `#bảng` vẫn sai ở mọi nơi khác dùng nó.

## Bài học rộng hơn

**Đoán trượt hai lần vì suy luận từ triệu chứng thay vì từ dữ liệu.** Lần đầu
tôi kết luận "crash lúc mua hero" từ một ảnh chụp màn hình; log cho thấy game
chỉ sống được 7 giây, không đủ để đi tới Tavern.

Thứ phá được thế bế tắc là **ghi vết ra file**. Chat mất khi game sập, nhưng
`PreloadGenEnd` viết được file text ra `Documents\Warcraft III\CustomMapData\`.
Ghi lại toàn bộ danh sách ở mỗi bước, nên dòng cuối cùng chính là bước cuối đã
chạy xong.

Giữ `CFG.TRACE` lại. Lần sau có lỗi im lặng thì bật lên trước, đừng đoán.

## Nơi khác có thể dính

Luật "lời gọi hàm ở vị trí cuối nở ra nhiều giá trị" áp cho cả **đối số hàm**,
không riêng table constructor:

```lua
CreateUnit(p, FourCC('Hmkg'), x, y, face)   -- an toàn: không ở cuối
SomeFunc(a, FourCC('Hmkg'))                 -- Ở CUỐI: truyền dư một đối số
```

Hiện chưa có chỗ nào dính, nhưng nhớ khi thêm code mới.
