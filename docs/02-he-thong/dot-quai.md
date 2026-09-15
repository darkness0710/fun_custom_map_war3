# Hệ thống: Đợt quái

> **Trạng thái:** Đã chốt — chưa cài (`05_wave.lua` còn rỗng)
> **Cập nhật:** 2026-09-15
> **Khoá CFG:** `WAVE_*` `MOB_*` `ELITE_*` `SCALE_*`
> **Xem kèm:** [canh-gioi.md](../03-du-lieu/canh-gioi.md) ·
> [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) · [boss.md](boss.md)

> **Ghi chú khôi phục.** Bản trước của file này bị ghi đè nhầm và không lấy lại
> được. Bản này dựng lại từ những gì các tài liệu khác trích dẫn về nó —
> `canh-gioi.md`, `boss.md`, `duong-cong-suc-manh.md`, ADR 0009–0011 — nên **nhất
> quán với chúng**, nhưng có thể thiếu chi tiết so với bản gốc.

## Nó là gì

220 stage. Phe địch tu từ Phàm Nhân lên Sáng Thế Thần, mỗi cảnh giới 10 tầng rồi
một lần độ kiếp. Người chơi chặn ở từng tầng, và chặn hẳn ở mỗi lần độ kiếp.

## Luật

**L1. Một biến `stage` duy nhất, 1…220.**
Cảnh giới và tầng đều **suy ra** từ nó. Giữ hai biến song song là chúng sẽ lệch
nhau. Công thức ở [canh-gioi.md](../03-du-lieu/canh-gioi.md).

**L2. Một cảnh giới là 11 stage: 10 tầng + 1 boss.**
Số 11 là `TIERS_PER_REALM + 1`, không hard-code ở đâu cả.

**L3. Thành phần wave cố định: 50 lính + 1 tinh anh.**
Không đổi theo số người chơi, không đổi theo cảnh giới. Số lượng cố định thì mọi
thứ khác đoán được: hiệu năng, thời gian dọn, thu nhập.
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

**L4. Boss chiếm trọn stage, một mình.**
Không lính đi kèm. Xem [boss.md](boss.md).

**L5. Có trần số unit sống.**
Đồng hồ wave chạy bất kể wave trước đã dọn chưa — đó là áp lực chính. Nhưng nếu
trên map đã quá `WAVE_MAX_ALIVE` con thì **hoãn** wave mới thay vì chồng thêm.

Đỉnh điểm dự kiến ~300 unit. Warcraft III chịu được, nhưng không có trần thì một
lần vỡ trận sẽ kéo theo dây chuyền và không bao giờ gỡ lại được.

**L6. Tầng đổi *tu chính*, không đổi chỉ số.**
Trong một cảnh giới, chỉ số chỉ nhích ×1.174 suốt 10 tầng — gần như không cảm
thấy. Thứ làm tầng 7 khác tầng 2 là **tu chính**, xem phần dưới.

## Nhịp

`WAVE_TIME` theo cõi, không theo stage:

| Cõi | Cảnh giới | Giây/wave | Vì sao |
|---|---|---|---|
| Phàm | 1–5 | 20 | Wave ngắn, học cách chơi |
| Yêu | 6–10 | 28 | |
| Tiên | 11–15 | 36 | |
| Thần | 16–20 | 45 | Wave nặng, cần thời gian hồi chiêu |

Tổng: **129 phút**. Gọi wave sớm cắt được 25% → **97 phút**.

> **Đây là con số đáng lo nhất của cả thiết kế.** Map co-op quá 90 phút là người
> chơi rời trận, mà mất một người là hỏng cả ván. Hai cách gỡ, chưa chọn:
>
> - **Gọi wave sớm** (đã tính trong 97 phút): dọn sạch thì bấm gọi wave kế, nhận
>   thêm Linh Khí. Biến thời lượng thành thứ người chơi tự điều khiển.
> - **Lưu tiến độ**: chơi nhiều phiên. Hệ thống riêng, khá lớn, làm sau.
>
> Nếu không làm gì thì phải cắt `TIERS_PER_REALM` xuống 5 — nhưng đó là đổi một
> quyết định đã chốt, và mọi bảng tra phải sinh lại.

## Tu chính

Mỗi tầng trong cảnh giới gắn một **tu chính** — một sửa đổi nhỏ lên cả wave. Đây
là thứ làm 10 tầng khác nhau, vì chỉ số thì gần như đứng yên (L6).

| Tầng | Tu chính | Ảnh hưởng lối chơi |
|---|---|---|
| 1 | *(không)* | Mốc chuẩn của cảnh giới |
| 2 | Nhanh chân | Tốc chạy +25% — ít thời gian phản ứng hơn |
| 3 | Dày da | Giáp +50% — ép dùng sát thương phép |
| 4 | Chia đàn | Ra từ 2 cửa thay vì 1 — không đứng một chỗ chặn được |
| 5 | Hồi phục | Tự hồi máu — ép dồn sát thương, không rỉ rả |
| 6 | Nổ tan | Chết thì gây sát thương vùng — phạt việc đứng chụm |
| 7 | Chắn phép | Kháng phép cao — ép đánh tay |
| 8 | Bầy đàn | Tinh anh thành 3 con, mỗi con 1/3 sức | 
| 9 | Vội vã | `WAVE_TIME` giảm 30% riêng tầng này |
| 10 | **Viên mãn** | Gộp tu chính của tầng 3 và 5 |

Tu chính **chọn từ một bảng chung**, không phải mỗi cảnh giới viết riêng 10 cái.
Nên thêm một tu chính mới là cả 20 cảnh giới cùng có.

> Vì sao tu chính quan trọng hơn chỉ số: một con quái dày gấp rưỡi thì người chơi
> vẫn bấm đúng ngần ấy nút. Một con quái *tự hồi máu* thì buộc phải đổi thứ tự
> bấm. Chỉ cái sau mới là lối chơi.

## Chỉ số

Đường cong ở [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md). Tóm
tắt phần đợt quái cần biết:

| | Nhân so với lính thường cùng stage |
|---|---|
| Lính | ×1 |
| Tinh anh | EHP ×10, sát thương ×2.5 |
| Boss | EHP ×80, sát thương ×3 |

Một wave = `50 + 10 = 60` đơn vị EHP. Boss = 80 — nhỉnh hơn cả wave gộp lại, nên
trận boss dài hơn một wave một chút, nhưng cảm giác hoàn toàn khác vì chỉ có một
mục tiêu.

**Giáp không nằm trong đường cong.** Đường cong sinh ra EHP; máu thật suy ngược ra
từ giáp. Đổi giáp **không** đổi độ khó.
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md)

## Theo số người chơi

**Số lượng cố định, chỉ chỉ số nhân.**
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

| Khoá | Tác dụng | Ràng buộc |
|---|---|---|
| `SCALE_EHP_PER_PLAYER` | EHP lính nhân thêm mỗi người | Phải **< 1.0**. Bằng 1.0 là phạt người chơi vì rủ bạn |
| `SCALE_DMG_PER_PLAYER` | Sát thương nhân thêm | Giữ **nhỏ**. Ba người có gấp ba sát thương, nhưng mỗi người vẫn chỉ có **một** thân — quái đánh đau gấp ba thì ba người chết nhanh như một |
| `SCALE_BOSS_EHP_PER_PLAYER` | Riêng boss | Cao hơn lính: boss một thân, đông người dồn hạ hiệu quả hơn hẳn |
| `SCALE_RECOUNT_EACH_WAVE` | Tính lại `P` mỗi wave | `true` — người thoát giữa chừng không khoá cứng ván của người ở lại |

## Đường đi

**Chưa quyết.** Lưới 25 block và 8 dòng sông
([luoi-25-o.md](../04-map/luoi-25-o.md)) hiện chưa gắn gì vào đợt quái. Ba hướng:

| | Cách | Được | Mất |
|---|---|---|---|
| A | Quái ra ở `MyEmenyRegion`, đi thẳng tới nhà | Đơn giản nhất, làm được ngay | Lưới 25 block thành trang trí |
| B | Quái đi theo hành lang giữa các block, sông chặn hai bên | Lưới có ý nghĩa, vị trí đứng quan trọng | Phải vẽ địa hình xong trước |
| C | Nhiều cửa, mỗi cảnh giới đổi cửa | Người chơi phải đọc bản đồ | Chia nhỏ lực lượng 3 người, dễ hỏng |

Đề xuất **A trước** để hệ wave chạy được, rồi nâng lên B khi địa hình xong. Đổi
từ A sang B chỉ là đổi điểm sinh và điểm đến, không đụng đường cong chỉ số.

## Thua

Nhà chính **đếm mạng, không đếm máu**.
[ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md)

Mỗi con quái chạm được vào nhà thì trừ một mạng và biến mất. Hết mạng là thua.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `WAVE_MOB_COUNT` | Lính mỗi wave | `50`, cố định |
| `WAVE_ELITE_COUNT` | Tinh anh mỗi wave | `1` |
| `WAVE_TIME` | Giây/wave theo cõi | Nút chỉnh **thời lượng ván**, và nó cũng chỉnh DPS cần — hai thứ dính nhau |
| `WAVE_MAX_ALIVE` | Trần unit sống, quá thì hoãn wave | ~300 |
| `WAVE_REORDER_TICK` | Giây giữa hai lần ra lệnh lại cho quái | Quái bị đánh lạc hướng phải quay về nhà |
| `TIERS_PER_REALM` | `10` | Đổi là đổi tổng stage; mọi thứ suy ra từ nó |

## Chưa làm

- **Chốt cách gỡ thời lượng** — gọi wave sớm hay lưu tiến độ. Chặn việc cài.
- Đường đi của quái (A/B/C ở trên).
- Bảng tu chính mới ở mức phác thảo, chưa có số.
- Chưa chơi thử một giây nào. Ba chỗ dễ sai nhất: DPS thật của hero ở stage 1,
  thời gian quái đi bộ tới nhà, và `MOB_EHP_BASE`.
