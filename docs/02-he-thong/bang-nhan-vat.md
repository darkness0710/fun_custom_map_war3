# Bảng nhân vật — phím E

> **Trạng thái:** Nháp — chưa cài
> **Cập nhật:** 2026-09-15
> **Liên quan:** [ky-nang.md](ky-nang.md), [kinh-te.md](kinh-te.md)

## Ý tưởng

Bấm **E** mở một bảng frame che giữa màn hình, có bốn thẻ:

```
┌──────────────────────────────────────────────┐
│  [Kỹ Năng] [Trang Bị] [Linh Căn] [Pháp Khí]  │
├──────────────────────────────────────────────┤
│                                              │
│              nội dung thẻ đang mở            │
│                                              │
├──────────────────────────────────────────────┤
│  Linh Khí: 12 400                    [Đóng]  │
└──────────────────────────────────────────────┘
```

Hạ tầng đã có sẵn: [07b_skillframe.lua](../../src/07b_skillframe.lua) và
[07c_heroframe.lua](../../src/07c_heroframe.lua) đã vẽ được panel, nút, icon, và đã
xử lý đồng bộ nhiều người. Bảng này dùng lại đúng khuôn đó.

## Lời khuyên quan trọng nhất: đừng làm cả bốn thẻ

Bốn thẻ nghe thì đầy đủ, nhưng ba trong bốn cái **chưa có nội dung nào**:

| Thẻ | Nội dung đã thiết kế? | Nếu làm bây giờ |
|---|---|---|
| **Kỹ Năng** | Có — 21 kỹ năng, bảng giá xong | Dùng được ngay |
| Trang Bị | Không có món nào | Thẻ trống |
| Linh Căn | Chưa có khái niệm gì | Thẻ trống |
| Pháp Khí | Chưa có món nào | Thẻ trống |

**Một thẻ mở ra trống rỗng tệ hơn là không có thẻ đó.** Người chơi bấm vào, thấy
trống, và mất niềm tin vào phần còn lại của giao diện.

Đề xuất: **làm thẻ Kỹ Năng trước, một mình nó.** Không có thanh tab, chỉ một bảng.
Khi nào Trang Bị có 5–6 món thật thì mới thêm tab thứ hai — lúc đó thanh tab mới có
lý do tồn tại.

## Thẻ Kỹ Năng

Bảy dòng, mỗi dòng một kỹ năng:

```
[icon]  Dậm Đất            Cấp 4/10        [ Nâng · 720 ]
        Sát thương vùng quanh Hart
```

| Thành phần | Ghi chú |
|---|---|
| Icon | Lấy từ `CFG.HEROES[i].abilities`, cùng icon với command card |
| Tên + mô tả ngắn | Một dòng, không phải cả tooltip |
| Cấp hiện tại / tối đa | |
| Nút nâng + giá | Mờ đi khi không đủ Linh Khí hoặc đã max |

Giá lấy từ bảng trong [kinh-te.md](kinh-te.md): `45 × cấp²`.

**Nâng cấp làm gì về mặt code:** `SetUnitAbilityLevel(hero, abilId, capMoi)`. Ability
phải đặt `Stats - Levels = 10` trong Object Editor và điền số cho từng cấp — đây là
chỗ khác với thiết kế cũ (`Levels = 1`).

> Điểm này đổi một quyết định cũ. Trước đây đặt `Levels = 1` vì không có hệ nâng cấp.
> Giờ có rồi, nên **mọi ability phải làm 10 cấp**. Làm 21 ability × 10 cấp số liệu là
> một khối việc đáng kể — lý do nữa để chỉ làm 3 kỹ năng trước rồi hãy nhân rộng.

## Ba thẻ còn lại — phác thảo

Chưa làm, nhưng ghi lại để khỏi thiết kế chồng chéo sau này.

**Trang Bị.** Warcraft III **đã có sẵn 6 ô đồ** trên hero. Đừng vẽ lại cái đó. Thẻ này
chỉ nên là **nơi mua**, còn đồ đã mua thì nằm trong túi gốc. Vẽ lại túi đồ là tự làm
khổ mình: phải tự xử lý nhặt, rơi, xếp chồng, tất cả những thứ engine đã làm xong.

**Linh Căn.** Phù hợp nhất với dạng cây tài năng thụ động: chọn một nhánh lúc đầu ván,
mở dần các điểm bằng Linh Khí. Khác với Kỹ Năng ở chỗ nó là **vĩnh viễn và định hướng
cả build**, còn kỹ năng thì nâng dần đều. Đây là nguồn sức mạnh ~20× mà
[kinh-te.md](kinh-te.md) cần.

**Pháp Khí.** Ít món, mỗi món **đổi cách chơi** chứ không chỉ cộng chỉ số. Hợp với
đồng tiền riêng lấy từ boss (xem phần Tinh Thạch trong kinh-te.md) — mỗi cái là một
quyết định lớn, không phải mua dần.

## Ba điều kỹ thuật phải xử lý

**Phím E.** Warcraft III không có sự kiện "bấm phím" trong 1.31 theo cách đơn giản.
Hai đường:

| Cách | Được | Mất |
|---|---|---|
| `BlzTriggerRegisterPlayerKeyEvent` | Đúng ý "bấm E" | Là native Blz, **chưa xác minh trên 1.31.1** |
| Lệnh chat `-c` | Chắc chắn chạy | Phải gõ, kém tiện hơn nhiều |
| Một ability trên command card | Chắc chắn chạy, bấm một nút | Chiếm một trong 7 ô |

Đề xuất: **dò xem native phím có tồn tại không** (thêm vài dòng vào file vết là biết),
dùng nó nếu có, lùi về lệnh chat nếu không. Đừng đổi lấy một ô kỹ năng.

**Bảng mở ra thì game vẫn chạy.** Frame không dừng game. Người chơi mở bảng giữa lúc
quái đang đánh là hero đứng chịu đòn. Hai lựa chọn: chấp nhận (mở bảng là một rủi ro,
phải chọn lúc), hoặc chỉ cho mở giữa hai wave. Đề xuất chấp nhận — nó tạo thêm một
quyết định thật.

**Đồng bộ nhiều người.** Bấm nút frame chỉ nổ trên máy người bấm. Mọi thay đổi phải đi
qua `BlzSendSyncData` như hai bảng hiện có. Đây không phải chuyện làm sau — sai là
lệch máy và đá người chơi ra khỏi trận.

## Chưa quyết

- Bảng mở ra có tạm dừng gì không (tạm dừng hero? làm chậm quái?).
- Mỗi người mở bảng riêng của mình, hay xem được build của người khác.
- Có nút hoàn điểm không.
