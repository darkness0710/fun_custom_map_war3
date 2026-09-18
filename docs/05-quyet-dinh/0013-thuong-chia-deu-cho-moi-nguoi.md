# 0013 — Mọi phần thưởng chia đều cho mọi người

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-15
> **Code:** [2_wave.lua](../../src/3_battle/2_wave.lua) — `rewardAll`

## Bối cảnh

Linh Khí trước đây **chỉ vào người kết liễu**. Tinh Thạch từ boss thì đã chia đều
sẵn — hai đường khác nhau cho cùng một việc.

Nhưng giá thì **từng người tự trả nguyên giá**: đột phá Tu Vi là của riêng
người đó, nâng kỹ năng cũng vậy. Còn độ khó lại tăng theo số người
(`SCALE_EHP_PER_PLAYER = 0.60` → EHP lính ×2,2 khi ba người).

Đo ra:

| Số người | Thu nhập/người | Cần chi/người | Dư/thiếu |
|---|---|---|---|
| 1 | 1 880 187 | 1 055 196 | **+78%** |
| 2 | 940 094 | 1 055 196 | −11% |
| 3 | 626 729 | 1 055 196 | **−41%** |

**Rủ bạn vào chơi là cả ba cùng nghèo đi**, mà quái lại dày hơn gấp đôi. Với một
map thủ thành chơi cùng bạn bè thì đó là hỏng từ gốc.

Chưa kể nó đẻ ra tranh giành đòn kết liễu — thứ không ai muốn trong map co-op.

## Quyết định

Mọi phần thưởng đi qua **một hàm duy nhất**, `rewardAll(stage, kind)`:

- Quái thường, tinh anh, boss — cả ba
- Linh Khí và Tinh Thạch — cả hai
- Chia đều cho **mọi người chơi đang hoạt động**, không phụ thuộc ai kết liễu

Kinh tế của mỗi người khi đó giống hệt chơi một mình. Đúng ý định: **độ khó tăng
theo số người, túi tiền thì không.**

Một hàm chứ không phải hai vòng lặp riêng như trước — thêm một loại thưởng nữa
thì không thể quên một chỗ.

## Không có công tắc

Đã bỏ hẳn `CFG.LINHKHI_SHARE_ALL`. Một công tắc mà bật sang `false` là nền kinh
tế vỡ ở ba người chơi thì không phải lựa chọn cấu hình, nó là cái bẫy chờ người
sau bước vào.

## Trả theo stage lúc SINH, không phải lúc chết

Sửa cùng lúc, cùng một lý do là "phần thưởng phải đúng":

Quái dồn lại qua nhiều wave — đo trong game: stage 6 mà còn **174 con sống**.
Trả theo `S.stage` hiện tại nghĩa là một con sinh ra ở stage 3, chết ở stage 8,
được trả giá của stage 8. Tức **tự thưởng thêm cho việc giết chậm**, và càng dồn
nhiều thì lạm phát càng nặng.

Giờ mỗi con ghi lại stage lúc sinh (`S.mobStage[u]`) và trả đúng giá đó.

## Kiểm

Tổng tiền một stage trả ra phải khớp đúng đường cong thu nhập:

```
stage 1    50 linh + 1 tinh anh   tra        60.00 / duong cong        60.00  lech 0.0000%
stage 11   1 boss                 tra        82.13 / duong cong        82.13  lech 0.0000%
stage 110  1 boss                 tra      1839.29 / duong cong      1839.29  lech 0.0000%
stage 219  50 linh + 1 tinh anh   tra     56383.34 / duong cong     56383.34  lech -0.0000%
```

Lính ăn 60% chia cho 50 con, tinh anh ăn 40%, boss ăn trọn cả wave. Ba loại cộng
lại đúng bằng `waveIncome(stage)`, không dư không thiếu.

## Hệ quả

- Đòn kết liễu không còn giá trị kinh tế. Không ai phải tranh.
- Người vào muộn hoặc chết nhiều vẫn theo kịp về tu vi — cân bằng chỉ còn phụ
  thuộc kỹ năng chơi, không phụ thuộc ai nhặt được xác.
- Tổng Linh Khí bơm vào game tăng theo số người. Cố ý: chi phí cũng nhân theo số
  người vì mỗi người có bảng nâng cấp riêng.
