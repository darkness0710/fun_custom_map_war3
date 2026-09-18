# 0010 — Đường cong sinh ra EHP, giáp chỉ là cách chia lại

> **Số trong tài liệu này tính cho 220 stage** *(10 tầng + boss mỗi cảnh giới)*.
> Từ 2026-09-17 còn **100 stage** *(4 tầng + boss)*, và thu nhập đã thành phẳng.
> Lập luận giữ nguyên; con số thì tra [bang-can-bang.md](../03-du-lieu/bang-can-bang.md).


> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-15

## Bối cảnh

Quái cần ba chỉ số tăng theo 100 stage: máu, giáp, sát thương. Cách làm hiển
nhiên là cho mỗi chỉ số một đường cong riêng — máu nhân mỗi wave, giáp cộng mỗi
cảnh giới.

Cách hiển nhiên đó sai, vì công thức giáp của Warcraft III:

```
giảm sát thương = (0.06 × giáp) / (1 + 0.06 × giáp)
```

Lật lại thành lượng sát thương thật sự phải bỏ ra để giết:

```
EHP = máu × (1 + 0.06 × giáp)
```

**Giáp là máu, viết bằng đơn vị khác.** Giáp 19 ở cảnh giới 20 nhân EHP lên
×2.14 — một lần nhân ×2.14 nằm ngoài mọi bảng tính, không ai thấy, và nó xuất
hiện đúng lúc game đã khó nhất.

## Quyết định

**Đường cong sinh ra EHP. Máu thật suy ngược ra từ giáp.**

```lua
local ehp   = MOB_EHP_BASE * MOB_EHP_GROWTH^(s-1) * MOB_EHP_REALM_STEP^(r-1)
local armor = MOB_ARMOR_BASE + MOB_ARMOR_PER_REALM * (r - 1)
local hp    = ehp / (1 + 0.06 * armor)     -- <= cái này mới đem đặt lên unit
```

Áp cho **mọi** nguồn giáp, không chỉ giáp nền: `ELITE_ARMOR_BONUS`,
`BOSS_ARMOR_BONUS`, và tu chính `Kim Thân` (+8 giáp). Cộng giáp ở đâu thì chia
máu ở đó.

> Ba nguồn giáp phụ đó **chưa tồn tại trong `CFG`** — hiện chỉ có giáp nền
> `MOB_ARMOR_BASE + MOB_ARMOR_PER_REALM × (r−1)`, và `hpFromEhp()` trong
> [2_wave.lua](../../src/3_battle/2_wave.lua) đã chia máu theo đúng luật này.
> Luật viết sẵn cho lúc thêm chúng vào.

Hệ quả trực tiếp: **đổi `MOB_ARMOR_PER_REALM` không đổi độ khó.** Nó chỉ đổi tỉ
lệ giữa "máu" và "giáp" trong cùng một lượng EHP. Đó chính là điều mong muốn — nó
biến giáp từ một nút cân bằng mập mờ thành một nút thiết kế rõ ràng.

Giáp vẫn tồn tại, và tồn tại vì một lý do: **đối kháng.** Có giáp thì kỹ năng
giảm giáp có chỗ dùng, sát thương phép bỏ qua giáp có ý nghĩa, đòn chí mạng và
sát thương cộng thẳng có giá trị khác nhau. Không có giáp thì mọi kỹ năng phòng
thủ và mọi kỹ năng xuyên giáp thành rác.

## Phương án đã loại

**Hai đường cong độc lập cho máu và giáp.** Là cách hiển nhiên, và là cách sai.
EHP thật thành tích của hai đường, mà chỉ một đường được viết ra. Khi wave 150
hoá ra khó gấp đôi dự tính, không có cách nào biết là do đường máu hay đường giáp
— cả hai đều "trông đúng" khi đọc riêng.

**Giáp bằng 0 cho mọi quái.** Giải quyết triệt để bài toán, nhưng giết luôn cả
một nhánh thiết kế kỹ năng. Giảm giáp, xuyên giáp, sát thương phép đối lại sát
thương vật lý — không cái nào còn nghĩa lý. Với map có hệ chọn kỹ năng làm trung
tâm ([ky-nang.md](../02-he-thong/ky-nang.md)) thì đó là mất mát lớn hơn cái được.

**Giáp âm cho quái yếu.** Warcraft III xử lý giáp âm bằng một công thức khác
(`2 - 0.94^|giáp|`), nên nó không phải phần mở rộng liên tục của công thức dương.
Một hàm hai nhánh là một hàm sẽ bị dùng sai. Giữ giáp ≥ 0.

## Hệ quả

**Không được đặt giáp trong Object Editor.** Mọi giá trị giáp phải do code đặt
lúc chạy, cùng chỗ với máu. Một con số giáp nằm sẵn trong Object Editor là một
lần nhân EHP mà công thức không biết tới — đúng thứ ADR này tồn tại để chặn. Đặt
giáp gốc của cả 24 unit type về 0.

**Tu chính cộng giáp phải chia lại máu.** `Kim Than` (+8 giáp) không được phép là
"cộng 8 giáp rồi thôi" — bật nó là phải tính lại `hp = ehp / (1 + 0.06 × armor)`
với giáp mới. Cùng luật với tu chính `Phan Than`: hai con con cộng lại 50 % EHP
nên con mẹ phải rút còn 50 %.

**Cột "Máu thật" trong bảng tra là số sẽ hiện trên thanh máu.** Ở cảnh giới 20,
EHP 42 745 nhưng thanh máu hiện 19 974 — hai con số khác nhau, và đó là bình
thường. Ai đọc bảng mà không đọc ADR này sẽ tưởng bảng sai.

**Bảng attack type / armor type của Warcraft III là lần nhân thứ ba, và nó nằm
ngoài tầm với của ADR này.** Bảng đó nhân 0.5–2.0 tuỳ cặp, *sau* mọi tính toán ở
đây. Nên: một armor type cho lính, một attack type cho hero. Dùng năm loại thì
đường cong sai tới bốn lần mà không ai truy ra được.
