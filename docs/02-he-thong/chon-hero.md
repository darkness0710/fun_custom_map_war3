# Hệ thống: Chọn hero bằng popup

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-14
> **Code:** [07_heropick.lua](../../src/07_heropick.lua)
> **Khoá CFG:** `HEROES` `PICK_*` `HERO_*`

## Nó là gì

Vào map vài giây thì mỗi người chơi nhận một popup liệt kê hero còn trống. Bấm
một nút là hero hiện ra cạnh nhà chính. Mỗi người một con, không ai lấy trùng.

| Nhãn trên nút | ID | Vai |
|---|---|---|
| Hart - Warrior | `H001` | Cận chiến |
| Hvwd - Shooter | `H002` | Đánh xa |
| Hkal - Mage | `H003` | Phép |

Đây là **unit tự tạo trong Object Editor**, không còn là hero gốc. Nghĩa là mọi
thứ về chúng — chỉ số, kỹ năng, giá, requirement — đều sửa được ở Object Editor,
không phải chống đỡ bằng code.

`name` chỉ là chữ hiện trên nút popup, tự đặt, không cần trùng tên unit trong
Object Editor.

## Vì sao bỏ Tavern

Đây là quyết định đáng ghi lại, vì nó xoá một lúc **năm** chỗ vá.

Bán hero qua cửa hàng thì phải đi qua toàn bộ hệ thống techtree của Warcraft III,
và ba hero lúc đó là hero **chủng tộc** gốc — Blizzard không thiết kế để bán. Hệ quả là
năm thứ phải chống đỡ:

| Vấn đề | Chỗ vá cũ |
|---|---|
| Đòi Altar of Kings / Elders | `SetPlayerTechResearched` giả lập đã có altar |
| Chờ cả phút mới có hàng | Bơm lại stock mỗi giây |
| Tốn 425 vàng 100 gỗ | Phát ví tiền rồi đặt lại |
| Tốn 5 lương thực, food cap 0 | Phát trần lương thực |
| Tavern bán sẵn 7 hero trung lập | Danh sách ID gỡ — **đã sai một lần** |

`CreateUnit` **bỏ qua toàn bộ techtree**: không requirement, không giá, không
lương thực, không quầy hàng, không đồng hồ hồi hàng. Cả năm chỗ vá biến mất mà
không cần đụng Object Editor.

Popup còn tốt hơn về mặt chơi: người chơi không phải đi bộ ngang bản đồ tới
Tavern, và không thể bỏ lỡ bước chọn hero.

## Luật

**L1. Popup hiện sau `CFG.PICK_DELAY` giây, không hiện ngay.**
Hiện đúng lúc map vừa nạp thì bị màn hình chuyển cảnh nuốt mất.

**L2. Danh sách dựng lại mỗi lần thay đổi.**
Người khác vừa lấy một con thì con đó phải biến khỏi popup của mọi người còn lại.
`DialogClear` huỷ các nút cũ, nên bảng ánh xạ nút → hero **phải dựng lại từ đầu**
— giữ lại bảng cũ là trỏ vào nút đã chết.

**L3. Người bấm trước thắng.**
Sự kiện popup được xử lý tuần tự nên không có tranh chấp thật. Người bấm sau vào
con đã bị lấy thì nhận thông báo và popup hiện lại với danh sách mới.

**L4. Hero sinh quanh nhà chính, mỗi người một hướng.**
Chia đều `360°` theo số người chơi để không chồng lên nhau. Toạ độ bị kéo về
trong vùng chơi được.

**L5. Hết hero thì đóng popup và báo.**
Nhiều người hơn số hero thì người sau cùng không có gì để chọn — hiện chưa xử lý
gì thêm ngoài một dòng thông báo.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `HEROES` | Danh sách `{ id, name }` | Không được rỗng. `name` là chữ hiện trên nút, tự đặt |
| `PICK_TITLE` | Tiêu đề popup | |
| `PICK_DELAY` | Giây trước khi hiện popup | Quá nhỏ thì bị màn hình chuyển cảnh nuốt |
| `HERO_MAX_PER_PLAYER` | Mỗi người tối đa | `0` = không giới hạn |
| `HERO_UNIQUE` | Không ai lấy trùng | |
| `HERO_SPAWN_OFFSET` | Hero sinh cách nhà chính bao xa | |

## Ràng buộc kỹ thuật

**Mỗi người chơi một dialog riêng.** Warcraft III hiện dialog theo từng người
(`DialogDisplay(player, ...)`), nhưng nội dung thì thuộc về dialog — nên muốn
mỗi người thấy một danh sách khác nhau thì phải có dialog riêng.

**`CreateUnit` không kiểm tra gì cả** — không techtree, không tài nguyên, không
lương thực. Đó chính là lý do chọn nó.

**Popup không dừng game.** Người chơi vẫn điều khiển được trong lúc chọn. Hiện
chưa có gì để điều khiển nên chưa thành vấn đề.

## Cách kiểm

Vào map, đợi 2 giây. Cần thấy:

1. Popup với đúng **3 nút**, không có hero lạ.
2. Bấm một nút → hero hiện cạnh nhà chính, camera nhảy tới, unit được chọn sẵn.
3. Không bị trừ vàng, không đòi Altar, không phải chờ hồi hàng.
4. Nhiều người: người thứ hai chỉ còn thấy **2 nút**.

## Chưa làm

- Mất hero thì không chọn lại được — `heroCount` không giảm.
- Không có hình minh hoạ hero trên nút; Warcraft III chỉ cho chữ.
- Không có hạn giờ chọn. Ai không bấm thì không có hero, ván vẫn chạy.
- Nhiều người hơn số hero: chỉ báo một dòng, chưa xử lý gì thêm.
