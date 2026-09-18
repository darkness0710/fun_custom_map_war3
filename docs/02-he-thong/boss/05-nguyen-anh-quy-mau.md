# 05. Nguyên Anh Quỷ Mẫu — *Nascent Soul Matron*

> **Cảnh giới 5 — Nguyên Anh** *(Nascent Soul)* · stage **25** · unit `Udre` *(Dreadlord)*

Hút máu cộng thuộc hạ: càng đông càng khoẻ. Con boss đầu tiên **thắng bằng dọn dẹp** chứ không phải đánh thẳng.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Hút Máu** `lifesteal` | Hồi lại **25%** sát thương nó gây ra. | Đánh gấp. Kéo dài trận là cho nó hồi, và nó hồi theo số người nó chạm được. |
| **Triệu Hồi** `summon` | Mỗi **20s** gọi **4** thuộc hạ quanh mình. | Dọn thuộc hạ hay bỏ qua là lựa chọn: chúng cho tiền, nhưng cũng chặn đường. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 5 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
