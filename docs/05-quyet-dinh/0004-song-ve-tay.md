# 0004 — Sông vẽ tay, Lua chỉ giữ tầng logic

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

Map chia 25 block ngăn cách bởi sông. Warcraft III không cho tạo nước lúc chạy —
nước là thuộc tính từng ô, nướng sẵn trong `war3map.w3e`. `SetTerrainType` chỉ
đổi hình nền mặt đất, `TerrainDeform*` chỉ bóp méo hình học; không cái nào sinh
ra mặt nước. Nên con sông phải tồn tại từ trước khi game chạy.

Ba đường: vẽ tay trong World Editor, sinh `war3map.w3e` bằng Python, hoặc giả
lập bằng texture và vật cản.

## Quyết định

**Vẽ tay.** Và tách đôi trách nhiệm:

| Tầng | Là gì | Ai giữ |
|---|---|---|
| **Logic** | Block nằm đâu, điểm này thuộc block nào | `S.grid` trong [4_geometry.lua](../../src/1_core/4_geometry.lua) |
| **Hình ảnh** | Nước, bờ, cầu, cây cối | Địa hình vẽ tay trong World Editor |

Hai tầng **không buộc phải trùng nhau từng ô**. Lòng sông rộng 1 024 đơn vị là
tim đường để vẽ trong đó, không phải khuôn để tô theo. `API.blockAt()` vẫn trả
đúng block dù sông uốn cong hay lệch vài ô.

`CFG.RIVER_TILES = 8` được chọn vì nó chia hết vùng chơi được:
`5 × 36 + 4 × 8 = 212`, lề bằng 0, mọi mép rơi đúng ranh giới ô.

## Phương án đã loại

**Sinh `war3map.w3e` bằng Python.** Về kỹ thuật thì làm được — định dạng có tài
liệu, khoảng 2–4 tiếng viết. Loại vì hai lý do.

Thứ nhất, nó chỉ đẻ ra được sông thẳng, rộng đều, cắt vuông góc. Lưới đều tăm
tắp đọc ra như bảng tính chứ không như map. Thứ làm map có hồn lại đúng là thứ
generator không sinh nổi: khúc phình thành hồ, chỗ thắt đủ hẹp để bắc cầu, bờ
nông lội qua được ở một điểm duy nhất, block bị sông ăn lẹm thành hình thang.

Thứ hai, rủi ro không cân xứng: sai một byte trong header hay cờ ô là World
Editor không mở được map, mà đổi lại chỉ được thứ xấu hơn vẽ tay.

**Giả lập bằng texture + vật cản lúc chạy.** Không cần đụng địa hình, nhưng
không có mặt nước — chỉ là vệt màu trên đất phẳng. Nhìn ra ngay là giả.

## Hệ quả

**Lối chơi không chờ địa hình.** Vì chức năng (biết đang ở block nào, chặn ranh
giới) nằm ở tầng logic, map chạy được đầy đủ trước khi có một giọt nước nào. Vẽ
là việc làm sau, khi bố cục đã đông cứng.

**Đổi `RIVER_TILES` là phải vẽ lại.** Nên chốt con số trước khi cầm cọ. Bảng tra
toạ độ ở [04-map/toa-do-ve-song.md](../04-map/toa-do-ve-song.md) sinh theo giá
trị hiện tại; đổi số thì sinh lại bảng.

**Lệch nhau thì sửa bên nào cũng được.** Vẽ xong thấy 25 ping không khớp đất, có
thể vẽ lại sông *hoặc* đổi `CFG.RIVER_TILES` rồi build lại. Tầng logic không
thiêng hơn tầng hình ảnh.
