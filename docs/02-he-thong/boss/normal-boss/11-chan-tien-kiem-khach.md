# 11. Chân Tiên Kiếm Khách — *True Immortal Swordsman*

> **Cảnh giới 11 — Chân Tiên** *(True Immortal)* · stage **55** · unit `Edem` *(Demon Hunter)*

Lao tới người xa nhất rồi hút máu từ chính đòn đó — người đứng xa vừa bị nhắm vừa nuôi nó.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Hào quang** `unholy` | Unholy Aura — boss **chạy nhanh và tự hồi máu** — khó kéo, khó bỏ chạy. | Luôn bật, không hồi chiêu, không tắt được. Là **phần trăm** nên tự bám theo sức boss, không bao giờ teo. |
| **Lao Kích** `charge` | Mỗi **11s** dịch chuyển tới hero **XA NHẤT** và gây `3×` một đòn. | Không có chỗ nấp. Ai đứng xa nhất là mục tiêu, kể cả người đang hồi máu. |
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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 11 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../../boss.md)
