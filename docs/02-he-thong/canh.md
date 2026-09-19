# Hệ thống: Cánh — huy hiệu cảnh giới

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-19
> **Code:** [9_wing.lua](../../src/4_ui/9_wing.lua)
> **Khoá CFG:** `WINGS` `WING_ATTACH` `WING_SCALE` `OP_WING`
> **Model:** [models/wings/note.txt](../../models/wings/note.txt)

## Nó là gì

Sáu bộ cánh đeo trên lưng hero, mở dần theo **cảnh giới**. Không có chỉ số,
không đụng cân bằng — nó chỉ để **người khác nhìn thấy** anh đã đi tới đâu.

Trước đó cảnh giới chỉ đọc được trong bảng `ESC`. Trên chiến trường không có gì
cho biết ai đang ở đâu.

| Cánh | Cảnh giới | Stage | Vì sao mốc đó |
|---|---|---|---|
| **Lôi Đình** *(Storm)* | **2** · Luyện Khí | 6 | Ngay sau khi hạ **boss đầu tiên** |
| **U Minh** *(Darkness)* | **4** · Kim Đan | 16 | Vẫn trong cõi Phàm — miếng thứ hai đến nhanh |
| **Thiên Đạo** *(Divine)* | **6** · Hoá Thần | 26 | Vào cõi **Yêu** |
| **Băng Nguyệt** *(Blizzard)* | **11** · Chân Tiên | 51 | Vào cõi **Tiên** |
| **Thánh Quang** *(Holy)* | **16** · Tiên Đế | 76 | Vào cõi **Thần** |
| **Thái Dương** *(Sun)* | **20** · Sáng Thế Thần | 96 | Đỉnh |

## Hình dạng: hai cái nhanh, rồi mỗi cõi một cái, rồi đỉnh

```
cõi Phàm   ██ ██                    2 cánh
cõi Yêu        ████                 1
cõi Tiên            █████           1
cõi Thần                 █████ █    1 + đỉnh
```

**Cánh đầu ở stage 6, không phải 26.** Bản thiết kế đầu rải *đều* từ cảnh giới 6
— một phần tư map không có gì. Đường cong phần thưởng phải **dồn về đầu**: cái
đầu tiên đến nhanh để dạy người chơi rằng hệ này tồn tại, rồi khoảng cách giãn
dần (10 → 10 → 25 → 25 → 20 stage).

Và nó rơi **ngay sau boss đầu tiên** — người chơi vừa thắng một trận thì cánh nở
ra. Hai sự kiện cộng hưởng thay vì hai sự kiện rời.

**Ba mốc giữa trùng ranh giới bốn cõi** (6 · 11 · 16) là cố ý: đó là lúc
`MOB_UNIT` đổi, quái **nhìn khác hẳn**. Chương mới đã có dấu hiệu thị giác sẵn,
gắn cánh vào đó làm nó nặng thêm.

## Thứ tự cánh: độ chói thắng chủ đề

```
Lôi Đình → U Minh → Thiên Đạo → Băng Nguyệt → Thánh Quang → Thái Dương
 khói xám   đen+đỏ    trắng-lam    trắng-xanh     vàng kim      lửa cam
```

**U Minh đứng thứ hai dù nhìn hoành tráng nhất** (sải rộng nhất). Lý do: nền map
tối, cánh đen đọc rất yếu ở tầm zoom `2000`. Nó ấn tượng lúc đứng ngắm, nhưng
giữa trận thì nhạt hơn Thánh Quang và Thái Dương nhiều. **Cảm giác "cánh mình
xịn dần" phải thắng sự hợp chủ đề.**

## Đổi được cánh đã mở

Ô **Cánh** ở hàng 5 thẻ Trang Bị, nút `ĐỔI` xoay vòng qua các bộ đã mở.

Chưa tự chọn thì luôn đeo bộ **cao nhất**. Tự chọn rồi thì `check()` **tôn trọng
lựa chọn đó** — trừ khi bộ đang đeo không còn hợp lệ.

Đánh đổi đã biết: cánh **mất tính chỉ báo cảnh giới** — U Minh có thể là người
cảnh giới 4 hoặc người cảnh giới 20 thích màu tối. Chấp nhận, vì cảnh giới đã
đọc được ở bảng `R`, còn *"chọn bộ mình thích"* mới là thứ giữ người chơi.

## Bốn điều kỹ thuật phải làm đúng

### 1. Phải gắn trên MỌI máy

Đây là khác biệt với camera. `SetCameraField` chỉ đổi máy đang chạy nên gọi cục
bộ là đúng; `AddSpecialEffectTarget` tạo ra một **effect thật**. Gọi trên một máy
thì chỉ máy đó thấy cánh — mà **cả giá trị của cánh nằm ở chỗ người khác nhìn
thấy**.

`wear()` vì thế đi từ đường đã đồng bộ: đột phá, hoặc `syncOn(OP_WING)` của nút
đổi. Không bao giờ từ callback frame ([ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md)).

### 2. Đổi hero là rò rỉ

Effect bám vào unit. Hero bị xoá mà không `DestroyEffect` thì handle treo lại.
`clear()` phải gọi ở **chỗ đổi hero**, không chỉ ở chỗ đeo bộ mới.

### 3. Phải QUÉT LẠI, không chỉ bắt sự kiện

Người chơi nhảy cảnh giới bằng `-lc 15`, hoặc đột phá nhiều bậc trong một lần.
`check()` **quét cả bảng** mỗi lần gọi thay vì so với bậc vừa qua. Nó cũng chạy
sau khi pick hero: hero mới thì chưa có cánh trên người dù cảnh giới đã cao.

`d.wingTop` nhớ mốc cao nhất **đã báo**, để đột phá ba bậc một lần không ra ba
dòng chữ liên tiếp.

### 4. Điểm gắn là thuộc tính của MODEL

Gói Ethereal phải gắn `origin`; gói khác gắn `chest` thì cánh **vọt lên trên
đầu**. Từng bộ khai riêng trường `attach`, `CFG.WING_ATTACH` chỉ là đường lui.

Chi tiết và lịch sử đo: [models/wings/note.txt](../../models/wings/note.txt).

## Báo cho cả bàn đồ

```
[He Thong] WorldEdit dot pha -- Thien Dao hien the.
```

Báo riêng cho người vừa đột phá là vô nghĩa — họ đang nhìn thẳng vào nó. Giá trị
nằm ở chỗ **người khác đọc được**.

Animation `Birth` của model chạy một lần lúc gắn, nên khoảnh khắc đột phá tự có
hiệu ứng nở cánh — không phải viết gì.

## Chưa làm

- **Chưa đo trận thật.** Sáu mốc là con số đầu.
- **Hvwd và Hkal** đang khoá nên chưa biết cánh nằm đúng lưng chúng không —
  điểm gắn là thuộc tính của từng model, `origin` đúng với Hart chưa chắc đúng
  với hero khác. Mở khoá hero thì phải đo lại bằng `-wing N <điểm>`.

← [Tu Vi](../03-du-lieu/canh-gioi.md) · [Trang Bị](trang-bi-kiem.md)
