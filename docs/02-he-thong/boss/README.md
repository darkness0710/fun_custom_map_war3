# Boss — mục lục

Hai loại, khác nhau ở **ba** điểm cơ bản chứ không chỉ ở chỉ số.

| | [20 boss thường](normal-boss/README.md) | [4 Thánh Thú](special-boss/README.md) |
|---|---|---|
| Khi nào có mặt | sinh ra khi tới cảnh giới | **đứng sẵn từ lúc vào map** |
| Ai tới ai | nó đi tới nhà chính | **người chơi dịch chuyển tới nó** |
| Chỉ số lấy từ đâu | **đo đội** ngay lúc xuất hiện | suy từ **cảnh giới cửa** |
| Hạ xong được gì | qua cảnh giới | **thu phục thành pet** |

Cả hai dùng chung **một bộ tám cơ chế** (`CFG.BOSS_MECH`) và chung mã ở
[`3_boss.lua`](../../../src/3_battle/3_boss.lua). Không có cơ chế nào riêng cho
Thánh Thú — thêm cơ chế thứ chín chỉ để phục vụ bốn con là thêm một đường chưa
ai đi.

- [Thiết kế chung](../boss.md) — vì sao boss đo đội thay vì nằm trên đường cong
- [20 boss thường](normal-boss/README.md) — mỗi cảnh giới một con
- [4 Thánh Thú](special-boss/README.md) — phó bản ở mốc Tu Vi 5 / 10 / 15 / 20
