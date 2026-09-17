# 08. Hợp Thể Cuồng Ma — *Body-Integration Fiend*

> **Cảnh giới 8 — Hợp Thể** *(Body Integration)* · stage **40** · unit `Otch` *(Tauren Chieftain)*

Đơn giản và nặng. Không mẹo, chỉ là một cuộc đua: hạ nó trước khi nó vào 30%.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Chấn Địa** `chandia` | Mỗi **9s** gây `2.5×` một đòn thường lên mọi hero trong bán kính **420**. | Tản ra. Đòn này không nhắm ai — đứng chụm là cả đội cùng ăn. |
| **Phát Cuồng** `cuong` | Dưới **30%** máu, sát thương `×1.6` vĩnh viễn. | Để dành kỹ năng và lọ cho 30% cuối. Nửa đầu dễ, nửa cuối mới là trận. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 8 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
