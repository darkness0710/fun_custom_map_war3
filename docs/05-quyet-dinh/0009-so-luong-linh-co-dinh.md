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
EHP  ×= 1 + SCALE_EHP_PER_PLAYER  × (P - 1)     -- 1.00
Dmg  ×= 1 + SCALE_DMG_PER_PLAYER  × (P - 1)     -- 0.40
Số lượng, giáp:  không nhân
```

Ba người chơi vẫn gặp đúng 50 lính và 1 tinh anh — chúng dày hơn, không đông hơn.

`P` đếm lại ở đầu mỗi wave (`SCALE_RECOUNT_EACH_WAVE`), không khoá lúc vào map:
một người thoát giữa chừng thì hai người còn lại không bị kẹt ở mức khó của ba
người suốt 150 wave.

> ## Sửa hai hệ số — 2026-09-20
>
> Bản đầu đặt `0.60` / `0.15` với lý lẽ: *"hệ số dưới tuyến tính là có chủ ý —
> ba hero mạnh hơn ba lần một hero, nhân đủ ×3 là phạt người chơi vì rủ được
> bạn"*, và *"sát thương đã tự loãng, nhân thêm là nhân hai lần"*.
>
> **Đo lại thì lý lẽ đầu sai, và cái sai nằm ở chỗ quên mất
> [ADR 0013](0013-thuong-chia-deu-cho-moi-nguoi.md).**
>
> | Số người | Việc **mỗi người** | Sát thương **mỗi hero** | Thu nhập mỗi người |
> |---|---|---|---|
> | 1 | 100% | 100% | `X` |
> | 3 | **73%** | **43%** | **`X`** |
>
> Thưởng trả **đủ cho từng người**. Nên với `1.00`:
>
> ```
> ba người → 3 phần việc, mỗi người làm 1
>          → 3 phần thưởng, mỗi người nhận 1
> ```
>
> Bằng solo cả hai vế — **trung tính**, không phải phạt. Còn `0.60` thì ba người
> làm `2.2` phần việc mà nhận `3` phần thưởng: một khoản giảm giá 27% không ai
> trả.
>
> **Và co-op vẫn hơn** — chỉ là hơn bằng những thứ không nằm trong phép nhân
> này: sát thương loãng ra *(mỗi hero vẫn chịu 60%, không phải 100%)*, ba bộ kỹ
> năng khác nhau, có người gồng khi mình nằm chờ 30 giây, và Chấn Địa của boss
> vốn thiết kế để **chia vai**
> ([ADR 0023](0023-chan-dia-khong-noi-cast-tanker-o-lai-chiu.md)) — một mình thì
> không chia được.
>
> Sát thương lên `0.40` chứ **không** `1.0`: nó chia theo **khoảng cách**, không
> chia đều. Một hero đứng chắn cho hai người kia sẽ ăn trọn `3×` — tức `1.0` phạt
> đúng cái lối chơi mà Chấn Địa đang khuyến khích.

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
chơi ([1_player.lua](../../src/2_player/1_player.lua)). Nhầm hai cái này thì chơi một
mình vẫn ăn độ khó ba người.
