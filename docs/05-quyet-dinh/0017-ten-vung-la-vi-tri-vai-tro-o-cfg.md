# 0017 — Tên vùng là vị trí, vai trò nằm trong CFG

> **Trạng thái:** ~~Đã chốt~~ — **phần lưới `Blk01`…`Blk25` đã bị thay thế**
> bởi [ADR 0028](0028-vung-ve-tay-thay-luoi-25-block.md) (2026-09-19).
> Nguyên tắc "vai trò sống trong CFG" thì vẫn còn hiệu lực.
> **Ngày:** 2026-09-16

## Bối cảnh

Lưới 25 block chỉ tồn tại dưới dạng **toạ độ tính lúc chạy**
([4_geometry.lua](../../src/1_core/4_geometry.lua)). World Editor không nhìn thấy
chúng, nên không cầm chuột sửa được — mà sửa bằng chuột chính là việc sẽ phải làm
nhiều lần khi dựng phó bản và thí luyện.

Cần đưa 25 block thành vùng thật trong `war3map.w3r`. Câu hỏi: **đặt tên chúng là
gì.**

## Quyết định

**Tên vùng mã hoá VỊ TRÍ: `Blk01`…`Blk25`. Vai trò sống trong `CFG.BLOCKS` bên Lua.**

```lua
CFG.BLOCKS = {
  [13] = { vai = "daudai" },
  [22] = { vai = "phoban", coi = 1 },
}
```

Vùng `Blk13` không bao giờ đổi tên. Muốn biến nó thành linh mạch thì sửa một dòng
Lua.

`w3region.py` sinh lại toàn bộ `Blk*` mỗi lần chạy và **giữ nguyên mọi vùng khác**
— nên vùng tự vẽ (`MyHouseRegion`, `MyEmenyRegion`) không bị đụng.

## Phương án đã loại

**Đặt tên theo vai trò** — `PhoBanCoi1`, `LinhMach03`, `DauDai`. Đọc code sướng
hơn hẳn: `gg_rct_DauDai` nói ngay nó là gì.

Loại vì hai thứ đổi với **nhịp rất khác nhau**. Vị trí gần như không bao giờ đổi;
vai trò thì sẽ đổi nhiều lần trước khi chốt — bảng vai trò hiện tại mới là bản
nháp đầu tiên, chưa chơi thử. Buộc chúng vào một cái tên nghĩa là mỗi lần đổi ý
phải: sửa file nhị phân, mở lại World Editor để xác nhận, và sửa mọi tham chiếu
`gg_rct_<Tên>` đang có. Ba việc cho một quyết định lẽ ra chỉ là một dòng.

**Không tạo vùng, tính hết lúc chạy** (giữ nguyên như trước). Rẻ nhất, và code đã
tính được `blockBounds(col, row)` rồi. Loại vì nó không giải quyết việc cần giải:
người làm map phải **nhìn thấy và kéo được** các ô đó trong World Editor, nhất là
khi block sẽ có địa hình riêng.

**Đặt 25 vùng bằng tay trong World Editor.** Loại vì 25 lần kéo chuột phải khớp
chính xác với công thức `splitAxis` trong Lua — lệch một ô là lưới logic và lưới
nhìn thấy nói hai chuyện khác nhau, và đó là kiểu lệch không ai phát hiện cho tới
lúc một cơ chế nào đó chạy sai.

## Hệ quả

`API.blockRole(idx)` trả `"hoang"` cho block chưa khai báo, **không** trả `nil` —
gọi bên ngoài không phải kiểm `nil` trước mỗi lần dùng.

Lệnh `-vung` in bản đồ vai trò và ping minimap theo màu. Nó **luôn đăng ký**,
không theo `DEV_COMMANDS`: chưa hệ nào gắn vào block, nên đó là cách duy nhất
nhìn thấy bảng có đúng như định không.
