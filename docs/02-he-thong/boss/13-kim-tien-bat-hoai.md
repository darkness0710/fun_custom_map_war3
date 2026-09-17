# 13. Kim Tiên Bất Hoại — *Golden Immortal Adamant*

> **Cảnh giới 13 — Kim Tiên** *(Golden Immortal)* · stage **65** · unit `Hpal` *(Paladin)*

Con boss **phòng thủ thuần**. Không đuổi, không gọi quân, chỉ đứng đó và bắt đội chứng minh sát thương của mình.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Phản Đòn** `phandon` | Phản lại **15%** sát thương nhận vào, thẳng vào người đánh. | Hero giòn phải cẩn thận: đánh càng mạnh càng tự thương. |
| **Hộ Thể** `khien` | Mỗi **15s** tạo khiên hấp thụ bằng **12%** máu tối đa. | Dồn sát thương phá khiên trước khi lớp sau kịp lên, nếu không trận kéo vô hạn. |

## Chỉ số

Boss **không** lấy chỉ số từ đường cong quái. Nó **đo đội** ngay lúc xuất hiện:

```
máu = Σ (17 + chỉ số cao nhất của mỗi hero) × BOSS_GIAY (40s)
đòn = (máu hiệu dụng trung bình) / BOSS_SO_DON (12 đòn)
      máu hiệu dụng = máu / (1 − giảm sát thương từ giáp)
```

Nên nó **luôn** cần ~40 giây hoả lực cả đội để hạ, và **luôn** hạ một hero
đứng yên trong 12 đòn — bất kể đội mạnh yếu thế nào.

Chia cho `(1 − giảm)` là phần quan trọng: cuối ván hero có 8,070 giáp,
giảm **99.79%** sát thương. Một con số tuyệt đối sẽ chỉ còn 4 máu khi chạm tới.

Boss là **hero** và **không bay** — `startBoss()` kiểm cả hai lúc vào map,
báo đỏ ngay nếu sai, không đợi tới cảnh giới 13 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
