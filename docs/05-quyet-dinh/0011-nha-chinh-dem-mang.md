# 0011 — Nhà chính đếm mạng thay vì đếm máu

> **Trạng thái:** Nháp — **cần bạn chốt trước khi code hệ wave**
> **Ngày:** 2026-09-15

Đây là ADR duy nhất trong thư mục này chưa chốt. Nó mâu thuẫn với
[nha-chinh.md](../02-he-thong/nha-chinh.md) đang ở trạng thái `Đã cài`, nên phải
quyết trước khi viết [05_wave.lua](../../src/05_wave.lua) — quyết sau thì phải gỡ
code đã chạy được.

## Bối cảnh

Nhà chính hiện có `HOUSE_HP = 1000` và chết là thua (L4 trong
[nha-chinh.md](../02-he-thong/nha-chinh.md)). Cấu hình đó ra đời khi map chưa có
quái.

Giờ có 220 wave, và sát thương lính tăng ×279 từ stage 1 tới stage 220 — từ 6 lên
1 645 mỗi đòn ([duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md)).
Một cái nhà 1 000 máu:

| Stage | Dmg mỗi đòn | Số đòn nhà chịu được |
|---|---|---|
| 1 | 6 | 167 |
| 44 (Kim Đan viên mãn) | 16 | 62 |
| 110 (Độ Kiếp) | 92 | 11 |
| 165 (Đại La) | 396 | **2** |
| 220 (Sáng Thế Thần) | 1 645 | **dưới 1** |

Cái nhà ngừng tồn tại về mặt lối chơi ở khoảng cảnh giới 12. Nên máu nhà phải
tăng theo — và câu hỏi là tăng theo cái gì.

## Quyết định (đề xuất)

**Bỏ máu. Nhà đếm mạng.**

```
CFG.HOUSE_LIVES      = 20     -- Linh Khi con lai
CFG.LEAK_COST_MOB    = 1
CFG.LEAK_COST_ELITE  = 3
```

Quái chạm nhà thì **biến mất** và trừ mạng. Hết mạng là thua. Boss chạm nhà là
thua ngay, không tính cộng trừ.

Nhà không nhận sát thương, nên toàn bộ đường cong sát thương địch chỉ còn tác
dụng lên hero — nơi nó *nên* có tác dụng. Một chiều cân bằng biến mất khỏi bài
toán.

Thứ người chơi đọc cũng đổi từ một thanh máu trôi (không suy ra được gì) thành
một con số đếm ngược rõ ràng: `Linh Khi: 17/20`. Lọt 3 con là biết ngay đã lọt 3
con.

## Phương án đã loại

**Máu nhà tăng theo đường cong sát thương địch.**
`HOUSE_HP(s) = HOUSE_HP_BASE × (đường cong dmg)`. Giữ nguyên "số đòn nhà chịu
được" suốt ván, và giữ nguyên mọi thứ đã cài trong
[06_core.lua](../../src/06_core.lua).

Loại vì nó đúng nhưng vô hình. Người chơi thấy thanh máu nhà tụt 30 % ở wave 80
và không suy ra được điều gì — 30 % của một con số vừa đổi mà họ không biết. Và
nó buộc `HOUSE_HP` phải được đặt lại ở mỗi wave, mà `BlzSetUnitMaxHP` trên một
**hero** (`Hmkg`) là chỗ đã cắn một lần rồi: máu tính lại theo Sức mạnh, phải
`SuspendHeroXP` trước — xem phần "Nó là hero, không phải công trình" trong
[nha-chinh.md](../02-he-thong/nha-chinh.md).

**Nhà bất tử, thua khi lọt quá N con.** Gần như giống phương án chọn, nhưng quái
vẫn đứng đó đánh nhà mãi mãi. Chúng tích lại thành một đống ở chân nhà, ăn CPU,
chắn đường, và làm `WAVE_MAX_ALIVE` vô dụng. Cho quái biến mất khi chạm nhà là
phần quan trọng của quyết định này, không phải chi tiết phụ.

**Giữ nguyên 1 000 máu, cân bằng bằng cách không cho lọt con nào.** Nghĩa là một
lần lọt ở cảnh giới 15 là thua ngay lập tức. Map không còn khoảng đệm — mọi sai
lầm đều chí mạng, và người chơi không học được gì vì họ chết trước khi kịp hiểu.

## Hệ quả

**[nha-chinh.md](../02-he-thong/nha-chinh.md) phải sửa.** L4 (chết là thua) đổi
thành hết mạng là thua. `HOUSE_HP`, `HOUSE_INVULNERABLE`, `HOUSE_DEATH_ENDS_GAME`
mất nghĩa hoặc đổi nghĩa. Tài liệu đó đang là `Đã cài` — sửa code thì sửa nó cùng
lúc, đừng để lệch.

**`BlzSetUnitMaxHP` không còn cần cho nhà chính.** Bớt được một phụ thuộc vào
patch 1.31+. `SuspendHeroXP` thì vẫn giữ — nhà vẫn là hero và vẫn không được lên
cấp.

**Phải bắt được "quái chạm nhà".** Không có sự kiện sẵn. Hoặc một vùng quanh nhà
(`TriggerRegisterEnterRectSimple`), hoặc timer quét khoảng cách. Vùng rẻ hơn.
Xoá unit trong sự kiện vào-vùng là sửa trạng thái engine từ trong sự kiện của
engine — hoãn bằng `API.after(0.0, ...)`,
[ADR 0005](0005-hoan-thao-tac-quay-hang.md).

**`HOUSE_LIVES = 20` là con số chưa có căn cứ.** Nó nói "được phép lọt 20 lính
trong cả 220 wave", tức khoảng 0.09 con mỗi wave. Có thể quá chặt. Phải chơi thử
mới biết, và đây là số nên chỉnh sớm.

**Cân nhắc cho hồi mạng.** 220 wave mà chỉ có 20 mạng, không hồi, thì một đoạn
xui ở cảnh giới 5 sẽ giết ván game ở cảnh giới 18 — người chơi mang theo một lỗi
đã phạm từ hai tiếng trước. Hạ boss hồi 1 mạng là đủ để sửa chuyện đó, và nó cho
boss một phần thưởng mà [boss.md](../02-he-thong/boss.md) đang thiếu.
