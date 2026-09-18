# 17. Thánh Nhân Vô Ngã — *Selfless Saint*

> **Cảnh giới 17 — Thánh Nhân** *(Saint)* · stage **85** · unit `Oshd` *(Shadow Hunter)*

Mọi đòn đánh đều quay lại chống người chơi: phản một phần, và nuôi nó phần còn lại.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Phản Đòn** `reflect` | Phản lại **15%** sát thương nhận vào, thẳng vào người đánh. | Hero giòn phải cẩn thận: đánh càng mạnh càng tự thương. |
| **Hút Máu** `lifesteal` | Hồi lại **25%** sát thương nó gây ra. | Đánh gấp. Kéo dài trận là cho nó hồi, và nó hồi theo số người nó chạm được. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 17 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
