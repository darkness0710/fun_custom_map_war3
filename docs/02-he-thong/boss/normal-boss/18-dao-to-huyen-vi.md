# 18. Đạo Tổ Huyền Vi — *Dao Ancestor*

> **Cảnh giới 18 — Đạo Tổ** *(Dao Ancestor)* · stage **90** · unit `Nbrn` *(Dark Ranger)*

Xé giáp cộng dồn trong khi thuộc hạ giữ chân. Càng lâu càng giòn, và nó không cho phép rút.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Xé Giáp** `shred` | Mỗi đòn trúng cộng dồn **+2%** sát thương nhận vào **của riêng hero đó**. | Thay phiên nhau chịu đòn. Một người tank cả trận là người đó vỡ trước. |
| **Triệu Hồi** `summon` | Mỗi **20s** gọi **4** thuộc hạ quanh mình. | Dọn thuộc hạ hay bỏ qua là lựa chọn: chúng cho tiền, nhưng cũng chặn đường. |
| **Lao Kích** `charge` | Mỗi **11s** dịch chuyển tới hero **XA NHẤT** và gây `3×` một đòn. | Không có chỗ nấp. Ai đứng xa nhất là mục tiêu, kể cả người đang hồi máu. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 18 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../../boss.md)
