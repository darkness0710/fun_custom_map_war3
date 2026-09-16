# Hệ thống: Boss cuối cảnh giới

> **Trạng thái:** Khung đã cài — **thân boss chưa có**
> **Cập nhật:** 2026-09-16
> **Code:** [2_wave.lua](../../src/3_tran_dau/2_wave.lua)
> **Khoá CFG:** `BOSS_EHP` `BOSS_DMG` `BOSS_SCALE` `TINHTHACH_BOSS_*`

> **Đã cài tới đâu.** Stage `11 × r` sinh đúng một con, chỉ số theo `BOSS_EHP` /
> `BOSS_DMG`, to hơn và đỏ hơn, tên `"<cảnh giới> - Ma Ton"`, hạ xong rơi Tinh
> Thạch và cả đội cùng nhận. Hạ boss stage 220 là thắng.
>
> **Chưa có gì của L4–L6**: kháng khống chế, đổi giai đoạn, phát điên. Cũng chưa
> có 20 unit type riêng — boss hiện dùng chung mẫu lính của cõi đó, phóng to
> `BOSS_SCALE` lần. Những khoá `BOSS_CC_RESIST`, `BOSS_PHASES`, `BOSS_ENRAGE_*`,
> `BOSS_ARMOR_BONUS`, `BOSSES` nhắc dưới đây **chưa tồn tại trong `CFG`**.
> **Xem kèm:** [dot-quai.md](dot-quai.md) ·
> [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md)

## Nó là gì

Hai mươi nút thắt. Phe địch tu tới **viên mãn** một cảnh giới rồi mới độ kiếp
sang cảnh giới sau — và người chơi phải chặn bằng được ở đúng khoảnh khắc đó.

Boss là chỗ duy nhất trong cả 220 stage mà nhịp game đổi hẳn: không còn 50 con
chạy vào, chỉ còn một thân. Mọi kỹ năng AoE trở nên vô dụng, mọi kỹ năng đơn mục
tiêu bỗng đáng giá. Đó là mục đích — nó ép người chơi xây một bộ kỹ năng không
chỉ biết dọn đám đông.

## Luật

**L1. Boss chiếm trọn stage `11 × r`, một mình.**
Không lính thường, không tinh anh. Người chơi vừa dọn xong tầng viên mãn, màn
hình lặng đi, rồi boss bước ra.

**L2. Boss mạnh gấp `BOSS_EHP` lần lính của chính stage đó.**
`BOSS_EHP` = 80, so với 60 của cả một wave. Nghĩa là trận boss dài bằng
`80/60 ≈ 1.33` lần thời gian dọn một wave — ở **mọi** cảnh giới, vì boss và lính
trôi trên cùng một đường cong.

Đó là lý do chọn 80 chứ không phải 100: 80 là số giữ cho mọi trận boss dài như
nhau từ Phàm Nhân tới Sáng Thế Thần, không phải số cho đẹp.

**L3. Đòn đánh thường của boss phải nhẹ. Mối đe doạ nằm ở kỹ năng.**
`BOSS_DMG` = 3, không phải 10. Ở cảnh giới 20 con số đó là ~5 000 mỗi đòn,
đúng 3 đòn là hero phải lùi.

Cho boss đánh thường nặng là thiết kế lười: người chơi không có gì để đọc, không
có gì để né, chỉ có so sánh hai con số máu. Sát thương phải đến từ thứ **báo
trước được** — một kỹ năng có animation, có vùng, có thời gian chuẩn bị.

**L4. Boss kháng khống chế, không miễn nhiễm.**
`BOSS_CC_RESIST` = 0.6 — mọi hiệu ứng khống chế chỉ còn 40 % thời gian.

Miễn nhiễm hoàn toàn thì mọi kỹ năng khống chế thành rác trong 20 trận boss, và
người chơi học được rằng đừng bao giờ chọn chúng. Kháng một phần giữ chúng có
ích mà không cho phép xích boss chết đứng.

**L5. Boss đổi giai đoạn ở các mốc `BOSS_PHASES`.**
Mặc định 70 % và 40 % máu. Mỗi mốc: triệu thuộc hạ, và mở thêm một kỹ năng.

Thuộc hạ là chỗ duy nhất boss có quái thường — và có mặt đúng để AoE lại có việc
làm giữa một trận đơn mục tiêu.

**L6. Boss phát điên nếu kéo quá dài.**
Không hạ trong `BOSS_ENRAGE_TIME` giây thì cứ mỗi `BOSS_ENRAGE_STEP` giây boss
cộng thêm `BOSS_ENRAGE_DMG` (100 %) sát thương, cộng dồn.

Không có luật này thì một đội thiếu DPS nhưng thừa hồi máu sẽ đứng đó nửa tiếng,
và ván game treo mà không ai thua. Phát điên biến "thiếu DPS" thành "thua trong
hai phút" — thua rõ ràng tốt hơn treo vô hạn.

**L7. Boss chạm nhà chính là thua ngay.**
Không trừ mạng — không có cơ chế mạng nào cả
([ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md) đã bị lật). Boss đánh
nhà bằng sát thương thường, mà `BOSS_DMG` = 3 lần lính thì nhà cạn máu trong
khoảng `HOUSE_HP_HITS / 3` đòn. Trên thực tế là hết.

**L8. Hạ boss stage 220 là thắng.**
Điều kiện thắng duy nhất của map.

## Hai mươi con boss

Mỗi cảnh giới một con, **cần unit type riêng trong Object Editor** — khác lính,
boss không tái dùng model được. 20 unit type.

Tên chưa đặt. Ràng buộc khi đặt: tên hiện trong game phải **không dấu**, cùng lý
do với tên cảnh giới ([canh-gioi.md](../03-du-lieu/canh-gioi.md)).

Kỹ năng leo thang theo cõi — mỗi cõi thêm một tầng phức tạp, để người chơi học
dần chứ không bị ném vào một trận boss ba cơ chế ngay từ Phàm Nhân:

| Cõi | Boss | Số kỹ năng | Kiểu cơ chế |
|---|---|---|---|
| Phàm (1–5) | 5 | 1 | Một chiêu đơn giản, báo trước rõ. Dạy người chơi khái niệm "né" |
| Yêu (6–10) | 5 | 2 | Thêm triệu hồi hoặc vùng gây hại đứng yên |
| Tiên (11–15) | 5 | 2 + thụ động | Thêm một thụ động phải xử lý (hồi máu, phản đòn, giáp cộng dồn) |
| Thần (16–20) | 5 | 3 + thụ động | Cơ chế chồng nhau, giai đoạn 3 đổi hẳn cách đánh |

**Đừng thiết kế cả 20 con trước khi chơi thử con thứ nhất.** Làm boss cảnh giới
1, đánh thử, rồi mới làm tiếp. Hai mươi bản thiết kế viết một lượt trên giấy thì
19 con sẽ phải viết lại sau trận thử đầu tiên.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
**Đã có trong `CFG`:**

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `BOSS_EHP` | Gấp mấy lần lính cùng stage | 80. Đổi nó là đổi **thời lượng mọi trận boss cùng lúc** — tỉ lệ với `60` của một wave |
| `BOSS_DMG` | Gấp mấy lần lính cùng stage | Giữ thấp (3). Xem L3 |
| `BOSS_SCALE` | Cỡ model | Thuần hình ảnh, nhưng là thứ báo "đây là boss" trước cả thanh máu |
| `SCALE_BOSS_EHP_PER_PLAYER` | Nhân máu theo số người | Cao hơn lính — [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) |
| `TINHTHACH_BOSS_BASE` `TINHTHACH_BOSS_STEP` | Tinh Thạch rơi ra ở cảnh giới `r` | `BASE + STEP × (r−1)`. Nguồn Tinh Thạch **duy nhất** của cả ván — [kinh-te.md](kinh-te.md) |

**Chưa tồn tại — thiết kế cho L4–L6:**

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `BOSS_ARMOR_BONUS` | Giáp cộng thêm | Giáp là EHP trá hình — máu thật phải chia lại. [ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md) |
| `BOSS_CC_RESIST` | Giảm bao nhiêu phần thời gian khống chế | `0.0`–`1.0`. `1.0` là miễn nhiễm — **đừng** |
| `BOSS_ENRAGE_TIME` | Giây trước khi phát điên | Phải lớn hơn hẳn thời gian hạ boss dự kiến (~1.33 × `WAVE_TIME`), nếu không đội chơi đúng cũng bị phạt |
| `BOSS_ENRAGE_STEP` `BOSS_ENRAGE_DMG` | Cứ mấy giây thì cộng bao nhiêu | |
| `BOSS_PHASES` | Mốc % máu đổi giai đoạn | Giảm dần, ví dụ `{0.70, 0.40}` |
| `BOSSES` | Bảng 20 dòng `{ id, ten, en, abilities }` | Đúng 20 dòng, khớp thứ tự `REALMS`. Id phải qua `id()` — [ADR 0006](../05-quyet-dinh/0006-fourcc-tra-hai-gia-tri.md) |

## Ràng buộc kỹ thuật

**Thanh máu boss phải tự vẽ.** Warcraft III không có thanh máu boss sẵn. Hoặc
`BlzCreateFrame` như [3_skillframe.lua](../../src/4_giao_dien/3_skillframe.lua) đã làm,
hoặc dùng multiboard, hoặc chấp nhận chỉ có thanh máu nhỏ trên đầu unit. Cái thứ
ba là chấp nhận được ở bản đầu — đừng chặn hệ boss vì cái thanh máu.

**Kháng khống chế không có native.** `BOSS_CC_RESIST` phải tự cài: bắt
`EVENT_PLAYER_UNIT_SPELL_EFFECT`, và nếu mục tiêu là boss thì rút ngắn thời gian
hiệu ứng. Với kỹ năng gốc của Warcraft III thì không rút được — phải nhân đôi
ability trong Object Editor và đặt thời gian riêng cho bản dùng lên boss, hoặc
gỡ buff sớm bằng `UnitRemoveAbility`. Việc này lâu hơn vẻ ngoài của nó.

**Đổi giai đoạn phải hoãn.** Mốc máu bắt bằng sự kiện damage; triệu hồi và thêm
ability ngay trong đó là sửa trạng thái engine từ trong sự kiện của engine. Hoãn
bằng `API.after(0.0, ...)`.
[ADR 0005](../05-quyet-dinh/0005-hoan-thao-tac-quay-hang.md)

**Mốc giai đoạn phải có cờ đã-chạy.** Sự kiện damage bắn nhiều lần quanh ngưỡng
70 %; không đánh dấu thì boss triệu thuộc hạ mỗi khung hình.

**Boss là unit thường, không nên là hero.** Hero thì dính `LOCK_HERO_XP`, dính
tính lại máu theo chỉ số, dính hồi sinh — đúng ba thứ đã phải xử lý cho nhà chính
([nha-chinh.md](nha-chinh.md)). Nếu vẫn muốn boss là hero (để có thanh máu và ô
chân dung riêng) thì phải làm lại y hệt những xử lý đó.

## Chưa làm

- **20 unit type và toàn bộ kỹ năng boss.** Hiện boss dùng chung mẫu lính của
  cõi, phóng to và tô đỏ. Tên thì đã đúng (`"<cảnh giới> - Ma Ton"`).
- **L4 kháng khống chế, L5 đổi giai đoạn, L6 phát điên** — chưa có dòng nào.
  Riêng L6 đáng làm sớm: không có nó thì một đội thiếu DPS treo ván vô hạn.
- Thanh máu boss.
- Chuyện gì xảy ra nếu cả đội chết lúc đang đánh boss. Hiện chưa có hồi sinh
  hero.
- Màn kết sau khi hạ boss stage 220. Hiện chỉ có một dòng `win_final` rồi
  `CustomVictoryBJ`.

Phần thưởng thì **đã có**: `TINHTHACH_BOSS_BASE + STEP × (r−1)`, chia đều cho cả
đội ([ADR 0013](../05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md)).
