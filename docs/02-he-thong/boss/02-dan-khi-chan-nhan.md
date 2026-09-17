# 02. Đan Khí Chân Nhân — *Qi-Gathering Adept*

> **Cảnh giới 2 — Luyện Khí** *(Qi Refining)* · stage **10** · unit `Hpal` *(Paladin)*

Thêm khiên: lần đầu người chơi gặp một thanh máu **không** đi thẳng xuống. Bài học về dồn sát thương.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Chấn Địa** `chandia` | Mỗi **9s** gây `2.5×` một đòn thường lên mọi hero trong bán kính **420**. | Tản ra. Đòn này không nhắm ai — đứng chụm là cả đội cùng ăn. |
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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 2 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
