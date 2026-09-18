# 15. Đại La Thiên Ma — *Great Luo Demon*

> **Cảnh giới 15 — Đại La** *(Great Luo)* · stage **75** · unit `Udea` *(Death Knight)*

Ba cơ chế đều thưởng cho việc trận kéo dài. Đây là con boss **phạt sự do dự** nặng nhất ván.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Hút Máu** `lifesteal` | Hồi lại **25%** sát thương nó gây ra. | Đánh gấp. Kéo dài trận là cho nó hồi, và nó hồi theo số người nó chạm được. |
| **Phát Cuồng** `enrage` | Dưới **30%** máu, sát thương `×1.6` vĩnh viễn. | Để dành kỹ năng và lọ cho 30% cuối. Nửa đầu dễ, nửa cuối mới là trận. |
| **Xé Giáp** `shred` | Mỗi đòn trúng cộng dồn **+2%** sát thương nhận vào **của riêng hero đó**. | Thay phiên nhau chịu đòn. Một người tank cả trận là người đó vỡ trước. |

## Chỉ số

Boss **không** lấy chỉ số từ đường cong quái. Nó **đo đội** ngay lúc xuất hiện:

```
máu = Σ (17 + chỉ số cao nhất của mỗi hero) × BOSS_SECONDS (40s)
đòn = (máu hiệu dụng trung bình) / BOSS_HITS_TO_KILL (12 đòn)
      máu hiệu dụng = máu / (1 − giảm sát thương từ giáp)
```

Nên nó **luôn** cần ~40 giây hoả lực cả đội để hạ, và **luôn** hạ một hero
đứng yên trong 12 đòn — bất kể đội mạnh yếu thế nào.

Chia cho `(1 − giảm)` là phần quan trọng: cuối ván hero có 8,070 giáp,
giảm **99.79%** sát thương. Một con số tuyệt đối sẽ chỉ còn 4 máu khi chạm tới.

Boss là **hero** và **không bay** — `startBoss()` kiểm cả hai lúc vào map,
báo đỏ ngay nếu sai, không đợi tới cảnh giới 15 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
