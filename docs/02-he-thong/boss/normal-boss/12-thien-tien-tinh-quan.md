# 12. Thiên Tiên Tinh Quân — *Heavenly Star Marshal*

> **Cảnh giới 12 — Thiên Tiên** *(Heavenly Immortal)* · stage **60** · unit `Emoo` *(Priestess of the Moon)*

Khiên kéo dài trận, xé giáp phạt việc kéo dài. Hai cơ chế cố tình chống nhau — đó là cái bẫy.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Hộ Thể** `shield` | Mỗi **15s** tạo khiên hấp thụ bằng **12%** máu tối đa. | Dồn sát thương phá khiên trước khi lớp sau kịp lên, nếu không trận kéo vô hạn. |
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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 12 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../../boss.md)
