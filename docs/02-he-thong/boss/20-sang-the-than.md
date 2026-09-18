# 20. Sáng Thế Thần — *World Creator*

> **Cảnh giới 20 — Sáng Thế Thần** *(World Creator)* · stage **100** · unit `Npbm` *(Pandaren Brewmaster)*

Con cuối. Bốn cơ chế — mọi bài đã học trong 19 trận trước, cùng lúc. Hạ được nó là **thắng ván**.

## Cơ chế

| Cơ chế | Làm gì | Đánh thế nào |
|---|---|---|
| **Chấn Địa** `slam` | Mỗi **9s**: boss **đứng yên 2s**, một vòng tròn bán kính **600** hiện ra tại chỗ nó đang đứng, rồi nổ — `10×` một đòn thường lên mọi hero còn trong vòng. | **Chia vai, không phải cùng chạy.** Tanker **ở lại** ăn đòn — máu hiệu dụng nó trên trung bình nên đòn này ăn vào nó nhẹ hơn. Carry và Support **phải chạy**: dưới trung bình thì đòn này có thể quá 100% máu. Tâm nổ chốt lúc bắt đầu niệm nên chạy là thoát thật. Đổi lại boss bị khoá 2s — cửa sổ để đánh trả. Không nhân hệ số phát cuồng. [ADR 0023](../../05-quyet-dinh/0023-chan-dia-khong-noi-cast-tanker-o-lai-chiu.md) |
| **Lao Kích** `charge` | Mỗi **11s** dịch chuyển tới hero **XA NHẤT** và gây `3×` một đòn. | Không có chỗ nấp. Ai đứng xa nhất là mục tiêu, kể cả người đang hồi máu. |
| **Xé Giáp** `shred` | Mỗi đòn trúng cộng dồn **+2%** sát thương nhận vào **của riêng hero đó**. | Thay phiên nhau chịu đòn. Một người tank cả trận là người đó vỡ trước. |
| **Phát Cuồng** `enrage` | Dưới **30%** máu, sát thương `×1.6` vĩnh viễn. | Để dành kỹ năng và lọ cho 30% cuối. Nửa đầu dễ, nửa cuối mới là trận. |

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
báo đỏ ngay nếu sai, không đợi tới cảnh giới 20 mới phát hiện.

← [Danh sách 20 boss](README.md) · [Thiết kế chung](../boss.md)
