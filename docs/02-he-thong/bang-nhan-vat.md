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

## Bốn thẻ, bốn hệ nâng cấp

Mỗi thẻ là một nguồn sức mạnh trong ngân sách ×967 —
[kinh-te.md](kinh-te.md). Không thẻ nào là trang trí.

| Thẻ | Nhân | Mua bằng | Cấu trúc |
|---|---|---|---|
| **Kỹ Năng** | ×2.4 | Linh Khí | 7 kỹ năng × 10 cấp, +10%/cấp |
| **Trang Bị** | ×8 | Linh Khí | 6 ô × 10 cấp, +4%/cấp |
| **Linh Căn** | ×20 | Linh Khí | 20 bậc tu vi, ×1.17/bậc |
| **Pháp Khí** | ×2.5 | **Tinh Thạch** | 5 món, mỗi món ×1.2 |

## Nhưng đừng làm cả bốn cùng lúc

Thiết kế xong không có nghĩa là cài cùng lúc. Thứ tự đề xuất:

1. **Linh Căn** — một danh sách 20 bậc, một nút đột phá, một con số nhân. Đơn giản
   nhất về giao diện mà lại là ×20, tức **nguồn sức mạnh lớn nhất**. Làm trước thì
   đường cong địch có đối trọng ngay.
2. **Kỹ Năng** — đã có 21 kỹ năng thiết kế sẵn
   ([thiet-ke-hero.md](thiet-ke-hero.md)), chỉ cần nối vào `SetUnitAbilityLevel`.
3. **Trang Bị** — cần có món đồ thật trong Object Editor trước.
4. **Pháp Khí** — cần Tinh Thạch, cần boss, cần 5 hiệu ứng riêng. Làm cuối.

Một thẻ mở ra trống rỗng tệ hơn là chưa có thẻ đó. Chỉ thêm tab khi nội dung của
nó đã chạy được.

## Thẻ Linh Căn — **đã cài**

> Code: [07d_linhcan.lua](../../src/07d_linhcan.lua). Mở bằng `-lc`.
> Không vẽ được frame thì tự lùi về thông báo chữ, và `-lc up` đột phá
> thẳng không cần bảng.

```
Tu vi hiện tại:  Trúc Cơ  (bậc 3/20)
Sức mạnh:        ×1.37
                                        [ Đột phá · 2 464 ]
Bậc kế:          Kim Đan   ×1.60
```

Một nút. Mờ đi khi không đủ Linh Khí. Giá lấy từ bảng
[kinh-te.md](kinh-te.md): `439 × 1.412^(bậc-1)`.

**Nhân vào đâu?** Tăng chỉ số hero trực tiếp — `SetHeroStr/Agi/Int` cộng dồn theo
bậc. Không đụng tới cấp độ hero, nên `LOCK_HERO_XP` và mốc máu nhà chính không
phải sửa gì.

> **Không nhân thẳng chỉ số lên ×1.17.** Sát thương hero = *sát thương nền + chỉ
> số*, nên phần nền làm loãng nhân số: đẩy chỉ số ×19.7 chỉ cho **×10.4** sát
> thương — thiếu một nửa. Phải giải ngược để bù:
>
> ```
> chiSo(r) = (DMG_BASE + STAT_BASE) × STEP^(r-1) − DMG_BASE
> ```
>
> `CFG.LINHCAN_DMG_BASE` và `LINHCAN_STAT_BASE` phải khớp hero thật trong Object
> Editor thì nhân số mới đúng. Bảng `-lc` in ra nhân số thực để đối chiếu.

## Thẻ Kỹ Năng

```
[icon]  Dậm Đất            Cấp 4/10        [ Nâng · 472 ]
        Sát thương vùng quanh Hart
```

Bảy dòng. Nâng cấp gọi `SetUnitAbilityLevel(hero, abilId, capMoi)`.

> Điều này đổi một quyết định cũ: ability phải đặt `Stats - Levels = 10` trong
> Object Editor, không phải 1. **21 ability × 10 cấp = 210 dòng số liệu** — lý do
> rất mạnh để làm 3 kỹ năng trước rồi mới nhân rộng.

## Thẻ Trang Bị

Warcraft III **đã có sẵn 6 ô đồ** trên hero. Đừng vẽ lại cái đó — vẽ lại là tự
nhận phần nhặt, rơi, xếp chồng mà engine đã làm xong.

Thẻ này chỉ là **nơi mua và nâng cấp**; đồ đã mua nằm trong túi gốc.

## Thẻ Pháp Khí

Năm món, mỗi món **đổi cách chơi** chứ không cộng chỉ số — ba hệ kia đã lo chỉ số
rồi. Mua bằng Tinh Thạch, chỉ rơi từ boss.

Thua một boss là mất một Pháp Khí. Đó là trọng lượng thật của việc thua.

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
