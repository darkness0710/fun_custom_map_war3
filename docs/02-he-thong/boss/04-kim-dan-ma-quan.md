# 04. Kim Đan Ma Quân — *Golden Core Warlord*

> **Cảnh giới 4 — Kim Đan** *(Golden Core)* · stage **20** · unit `Obla` *(Blademaster)*

Con đầu tiên **đuổi theo** người chơi. Kết hợp phát cuồng: nửa cuối trận nó vừa bám vừa đau.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Lao Kích** `lao` | Mỗi **11s** dịch chuyển tới hero **XA NHẤT** và gây `3×` một đòn. | Không có chỗ nấp. Ai đứng xa nhất là mục tiêu, kể cả người đang hồi máu. |
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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 4 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
