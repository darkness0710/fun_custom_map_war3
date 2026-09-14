# Toạ độ vẽ sông

> **Trạng thái:** Đã chốt — dùng để vẽ tay trong World Editor
> **Cập nhật:** 2026-09-14
> **Sinh từ:** `CFG.RIVER_TILES = 8`, vùng chơi được 212 × 212 ô

Bảng này là **bản tra khi cầm cọ**. Toạ độ thế giới hiện ở thanh trạng thái dưới
cùng của World Editor khi rê chuột.

> **Không cần vẽ chính xác.** Lưới trong Lua là tầng logic, con sông là tầng hình
> ảnh — chúng không buộc phải trùng nhau. `API.blockAt()` vẫn trả đúng block dù
> sông uốn cong hay lệch vài ô. Bảng này cho bạn **tim đường** rộng 1024 đơn vị
> để vẽ trong đó, không phải khuôn để tô theo. Xem
> [ADR 0004](../05-quyet-dinh/0004-song-ve-tay.md).

## Bố cục

```
        song1      song2      song3      song4
          |          |          |          |
   #21 ---+--- #22 --+-- #23 ---+--- #24 --+--- #25     Y = 11008
   ------------------------------------------------ song4 ngang
   #16 ---+--- #17 --+-- #18 ---+--- #19 --+--- #20     Y =  5376
   ------------------------------------------------ song3 ngang
   #11 ---+--- #12 --+-- #13 ---+--- #14 --+--- #15     Y =  -256   <- tâm map
   ------------------------------------------------ song2 ngang
   # 6 ---+--- # 7 --+-- # 8 ---+--- # 9 --+--- #10     Y = -5888
   ------------------------------------------------ song1 ngang
   # 1 ---+--- # 2 --+-- # 3 ---+--- # 4 --+--- # 5     Y = -11520

 X = -11264    -5632       0        5632      11264
```

Block đánh số từ **góc dưới–trái**, chạy sang phải rồi lên trên. Cùng chiều trục
toạ độ WC3, khỏi phải lật dấu.

## Kích thước

| | Ô | Đơn vị |
|---|---|---|
| Mỗi block | 36 × 36 | 4 608 |
| Lòng sông | 8 | 1 024 |
| Lề | 0 | 0 |

`5 × 36 + 4 × 8 = 212` — khít vùng chơi được, không dư ô nào. Đây là lý do chọn
8 chứ không phải 10: mọi mép đều rơi đúng ranh giới ô, đếm ô trong WE là ra.

## Bốn sông dọc — vẽ theo trục Y

| Sông | X từ | đến | Ô trong WE |
|---|---|---|---|
| 1 | −8 960 | −7 936 | 42 … 50 |
| 2 | −3 328 | −2 304 | 86 … 94 |
| 3 | 2 304 | 3 328 | 130 … 138 |
| 4 | 7 936 | 8 960 | 174 … 182 |

## Bốn sông ngang — vẽ theo trục X

| Sông | Y từ | đến | Ô trong WE |
|---|---|---|---|
| 1 | −9 216 | −8 192 | 40 … 48 |
| 2 | −3 584 | −2 560 | 84 … 92 |
| 3 | 2 048 | 3 072 | 128 … 136 |
| 4 | 7 680 | 8 704 | 172 … 180 |

> Sông ngang lệch sông dọc **256 đơn vị (2 ô)**. Không phải lỗi — vùng chơi được
> của map không đối xứng qua gốc toạ độ: Y chạy −13 824 … +13 312, tâm ở −256 chứ
> không phải 0. Xem [kich-thuoc.md](kich-thuoc.md).

Cột "ô trong WE" tính từ **góc map kể cả viền** (224 ô), không phải từ mép vùng
chơi được — vì đó là thứ bạn đếm được trên lưới của World Editor.

## Tâm 25 block

Dùng khi cần đặt gì đó vào giữa một block.

| | col 1 | col 2 | col 3 | col 4 | col 5 |
|---|---|---|---|---|---|
| **Y = 11 008** | #21 | #22 | #23 | #24 | #25 |
| **Y = 5 376** | #16 | #17 | #18 | #19 | #20 |
| **Y = −256** | #11 | #12 | **#13** | #14 | #15 |
| **Y = −5 888** | #6 | #7 | #8 | #9 | #10 |
| **Y = −11 520** | #1 | #2 | #3 | #4 | #5 |
| **X** | −11 264 | −5 632 | 0 | 5 632 | 11 264 |

**#13 là block giữa**, tâm `(0, −256)` — đúng tâm vùng chơi được.

## Vẽ theo thứ tự nào

1. **Một ngã tư trước.** Chỗ sông dọc 2 giao sông ngang 2, quanh `(−2 816, −3 072)`.
   Chừng 10 phút.
2. **Vào game đi bộ quanh đó.** Hai câu cần trả lời: sông rộng 1 024 đơn vị là
   cản trở thật hay chỉ là vạch kẻ? Block 4 608 đơn vị đi hết mất bao lâu?
3. **Trả lời xong mới vẽ nốt 7 con còn lại.**

Vẽ cả 8 con trước khi biết cảm giác là vẽ mù — sửa lại thì mất cả buổi.

## Sau khi vẽ

Chạy `python build.py`, vào map với `CFG.DEBUG = true`. 25 chấm ping trên minimap
phải rơi vào giữa 25 khoảng đất, không chấm nào nằm dưới nước. Lệch thì sửa —
mà sửa **một trong hai bên đều được**: hoặc vẽ lại sông, hoặc đổi `CFG.RIVER_TILES`
rồi build lại. Tầng logic không thiêng hơn tầng hình ảnh.
