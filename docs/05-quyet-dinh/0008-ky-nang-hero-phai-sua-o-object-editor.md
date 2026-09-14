# 0008 — Kỹ năng gốc của hero chỉ xoá được trong Object Editor

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-15

## Bối cảnh

Cần ba hero không có kỹ năng gốc nào và không có nút **+**, để trống chỗ cho kỹ
năng tự tạo. Đã thử hai hướng runtime, cả hai đều thất bại — nhưng thất bại theo
hai kiểu khác nhau, và phân biệt được chúng mới ra kết luận.

**Hướng 1: rút sạch điểm kỹ năng.** Chạy được thật:

```
skillpoint Priestess of the Moon: rut 1 diem (ok)
```

Nhưng nút **+ vẫn còn**. Nên nút đó **không phụ thuộc số điểm kỹ năng** — hết
điểm chỉ khiến bấm vào không học được.

**Hướng 2: gỡ ability bằng `UnitRemoveAbility`.** Thử 12 ID kỹ năng gốc của ba
hero:

```
remove Priestess of the Moon: KHONG id nao trung (12 id da thu)
remove Nha Chinh:             KHONG id nao trung (12 id da thu)
```

`UnitRemoveAbility` trả về `false` cho **toàn bộ** 12 ID, trên **cả hai** hero.

Nếu chỉ là ID đoán sai thì khó mà sai cả 12 — `AEst` (Scout) và `AEsf` (Starfall)
là ID khá chắc chắn. Kết luận: **kỹ năng hero chưa học không phải ability gắn
trên unit.** Chúng là danh sách học thuộc *loại* unit, ở trường
`Techtree - Hero Abilities`, và native này không với tới được.

Cũng không liệt kê được để lấy ID thật: 1.31.1 **không có**
`BlzGetUnitAbilityByIndex`.

## Quyết định

**Xoá kỹ năng gốc bằng Object Editor**, không bằng code.

Object Editor → Units → từng hero → `Techtree - Hero Abilities` → xoá sạch.

Hero không còn gì để học thì nút **+** biến mất, và command card trống sẵn cho
kỹ năng tự tạo.

## Phương án đã loại

**Rút điểm kỹ năng** — chạy được nhưng không giấu được nút. Vẫn giữ trong code
(`CFG.STRIP_SKILL_POINTS`) vì nó chặn việc học thật, chỉ là không đủ một mình.

**`UnitRemoveAbility`** — không tác dụng với kỹ năng chưa học, như đo được ở
trên. Giữ cơ chế (`CFG.HERO_REMOVE_ABILITIES`, mặc định rỗng) vì nó vẫn gỡ được
ability unit **thật sự đang có**.

**`SetPlayerAbilityAvailable`** — chưa thử. Kể cả có tác dụng thì vẫn cần ID
đúng, mà không có cách nào lấy ID trên 1.31.1 ngoài tra tay trong Object Editor.
Đã ở trong Object Editor rồi thì xoá thẳng trường kia nhanh hơn.

## Hệ quả

**Kỹ năng tự tạo có hai đường, chọn một:**

| Muốn gì | Làm sao | Cấu hình |
|---|---|---|
| Học bằng điểm kỹ năng như hero thường | Đặt ability tự tạo vào `Techtree - Hero Abilities` | `STRIP_SKILL_POINTS = false`, `LOCK_HERO_XP = false` |
| Luôn có sẵn, không lên cấp | Để trống trường đó, gọi `UnitAddAbility` lúc tạo hero | Giữ nguyên như hiện tại |

Đường thứ hai hợp với hướng hiện tại của map — không hero nào lên cấp.

**Sau khi sửa Object Editor phải Save, và Save là World Editor ghi đè
`war3map.lua`** — luôn chạy `python build.py` trước khi test.

## Bài học lặp lại

Lần thứ ba trong dự án này: tôi suy đoán về cách engine hoạt động rồi tư vấn chắc
chắn, thay vì đo trước. Ở đây là câu "rút điểm kỹ năng là đủ, không cần gỡ từng
ability" — sai, và người dùng mất hai lượt thử mới lòi ra.

Cái phá được thế bế tắc vẫn là ghi vết ra file, và lần này là mẹo đọc **giá trị
trả về** của `UnitRemoveAbility` để phân biệt "ID sai" với "native không áp dụng
được". Không có nó thì vẫn đang đoán ID.
