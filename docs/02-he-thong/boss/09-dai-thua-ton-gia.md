# 09. Đại Thừa Tôn Giả — *Great Ascension Arhat*

> **Cảnh giới 9 — Đại Thừa** *(Great Ascension)* · stage **45** · unit `Ekee` *(Keeper of the Grove)*

Phản đòn khiến việc quét diện rộng để dọn thuộc hạ trở thành tự chuốc sát thương.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Triệu Hồi** `trieuhoi` | Mỗi **20s** gọi **4** thuộc hạ quanh mình. | Dọn thuộc hạ hay bỏ qua là lựa chọn: chúng cho tiền, nhưng cũng chặn đường. |
| **Phản Đòn** `phandon` | Phản lại **15%** sát thương nhận vào, thẳng vào người đánh. | Hero giòn phải cẩn thận: đánh càng mạnh càng tự thương. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 9 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
