# 03. Trúc Cơ Thạch Linh — *Foundation Stonesoul*

> **Cảnh giới 3 — Trúc Cơ** *(Foundation)* · stage **15** · unit `Ucrl` *(Crypt Lord)*

Phản đòn dạy rằng đánh mạnh không phải lúc nào cũng đúng — hero giòn phải biết lúc lùi.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Chấn Địa** `slam` | Mỗi **9s** gây `2.5×` một đòn thường lên mọi hero trong bán kính **420**. | Tản ra. Đòn này không nhắm ai — đứng chụm là cả đội cùng ăn. |
| **Phản Đòn** `reflect` | Phản lại **15%** sát thương nhận vào, thẳng vào người đánh. | Hero giòn phải cẩn thận: đánh càng mạnh càng tự thương. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 3 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
