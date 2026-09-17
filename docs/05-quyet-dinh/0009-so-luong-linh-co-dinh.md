# 0009 — Số lượng lính cố định, chỉ nhân chỉ số theo số người chơi

> **Số trong tài liệu này tính cho 220 stage** *(10 tầng + boss mỗi cảnh giới)*.
> Từ 2026-09-17 còn **100 stage** *(4 tầng + boss)*, và thu nhập đã thành phẳng.
> Lập luận giữ nguyên; con số thì tra [bang-can-bang.md](../03-du-lieu/bang-can-bang.md).


> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-15

## Bối cảnh

Map chơi 1–3 người. Wave phải nặng hơn khi đông người, nhẹ hơn khi chơi một
mình — nếu không thì solo là bất khả thi, hoặc ba người là dạo chơi.

Thiết kế wave đặt `WAVE_MOB_COUNT = 50` lính và 1 tinh anh mỗi đợt, chạy suốt
100 stage ([dot-quai.md](../02-he-thong/dot-quai.md)). Câu hỏi: 50 đó là tổng,
hay 50 mỗi người?

## Quyết định

**Số lượng cố định. Chỉ chỉ số nhân theo số người.**

```
EHP  ×= 1 + SCALE_EHP_PER_PLAYER  × (P - 1)     -- 0.60
Dmg  ×= 1 + SCALE_DMG_PER_PLAYER  × (P - 1)     -- 0.15
Số lượng, giáp:  không nhân
```

Ba người chơi vẫn gặp đúng 50 lính và 1 tinh anh — chúng dày hơn, không đông hơn.

`P` đếm lại ở đầu mỗi wave (`SCALE_RECOUNT_EACH_WAVE`), không khoá lúc vào map:
một người thoát giữa chừng thì hai người còn lại không bị kẹt ở mức khó của ba
người suốt 150 wave.

Hệ số 0.60 là **dưới tuyến tính** có chủ ý. Ba hero mạnh hơn ba lần một hero:
AoE chồng lên nhau, buff dùng chung, tập trung hạ mục tiêu, và một người đỡ đòn
cho hai người kia rảnh tay. Nhân đủ ×3 là phạt người chơi vì rủ được bạn.

Sát thương giữ 0.15 vì nó đã tự loãng: 50 con quái chia cho 3 hero thì mỗi hero
ăn một phần ba. Nhân thêm nữa là nhân hai lần.

## Phương án đã loại

**Nhân số lượng theo người chơi (50 × P).**

Ba người là 150 unit một wave. Wave chạy theo đồng hồ và chồng lên nhau
(L5 trong [dot-quai.md](../02-he-thong/dot-quai.md)), nên đỉnh điểm là ~300 unit
cùng tìm đường tới một điểm. Pathing của Warcraft III bắt đầu giật ở quãng đó, và
nó giật trên máy yếu nhất trong phòng, không phải máy của người test.

Còn một hỏng nữa ít rõ hơn: 150 con chen qua một chỗ qua sông thì chúng xếp hàng.
Wave không còn là một đợt tấn công, nó thành một dòng chảy đều — và mọi tính toán
"dọn wave trong bao lâu" sai hết, vì thời gian bị quyết định bởi độ rộng nút cổ
chai chứ không phải bởi DPS.

**Nhân số lượng nhưng giảm chỉ số cho bù.** Giữ được tổng EHP đúng, nhưng vẫn
gánh nguyên chi phí pathing, mà lại thêm cái dở: quái yếu đi từng con nên mọi kỹ
năng đơn mục tiêu mất giá trị khi đông người. Bộ kỹ năng tối ưu đổi theo số người
trong phòng — không ai muốn cân bằng chuyện đó.

**Khoá `P` lúc vào map.** Đơn giản hơn khi cài, nhưng một người rớt mạng ở wave
30 là hai người còn lại ôm độ khó của ba người trong 190 wave nữa. Với một ván
dài 2 giờ thì rớt mạng là chuyện sẽ xảy ra, không phải có thể xảy ra.

## Hệ quả

**`WAVE_MOB_COUNT` là hằng số về tải, không phải nút cân bằng.** Muốn wave nặng
hơn thì sửa `MOB_EHP_BASE`. Sửa số lượng là đổi chi phí CPU và đổi cả cách wave
đi qua địa hình — hai thứ chẳng liên quan gì tới độ khó.

**Chơi một mình là cấu hình chuẩn.** Đường cong gốc trong
[duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) được viết cho
`P = 1`; 2 và 3 người là suy ra. Nên test cân bằng phải làm solo trước — test 3
người rồi suy ngược lại là sai thứ tự.

**Phải có `WAVE_MAX_ALIVE`.** Số lượng cố định vẫn chồng được nếu wave trước chưa
dọn xong. Trần tồn tại để chặn trường hợp xấu, và **chạm trần thường xuyên nghĩa
là đường cong quá nặng** — sửa đường cong, đừng nới trần.

**`SCALE_*` phải đọc lại `#S.pids` chứ không đọc `CFG.PLAYER_SLOTS`.**
`PLAYER_SLOTS` là slot đã bật trong World Editor; `S.pids` mới là người thật đang
chơi ([1_player.lua](../../src/2_nguoi_choi/1_player.lua)). Nhầm hai cái này thì chơi một
mình vẫn ăn độ khó ba người.
