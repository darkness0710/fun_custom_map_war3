# 0023 — Chấn Địa không nới thời gian niệm: tanker ở lại chịu đòn là có chủ ý

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-18
> **Liên quan:** [boss.md](../02-he-thong/boss.md) · `CFG.BOSS_MECH.slam`

## Bối cảnh

Chấn Địa bản mới niệm **2s** rồi nổ trong bán kính **600**, tâm chốt tại chỗ boss
đứng lúc bắt đầu niệm.

Làm phép tính thoát: hero đứng ngay tâm phải vượt đúng 600 đơn vị trong 2 giây,
tức cần tốc độ **≥ 300**. Hero Warcraft mặc định chạy 270–320. Nghĩa là hero cận
chiến đang dí sát boss **có thể không kịp ra**.

Nhìn như một lỗi cân bằng. Hai cách sửa hiển nhiên: nới `cast` lên 2.5s, hoặc hạ
`radius` xuống 500.

## Quyết định

**Không sửa. Giữ `cast = 2.0`, `radius = 600`.**

Cận chiến không ra kịp **không phải lỗi — đó là cái giá của vị trí đứng**. Hart
là *Warrior — Tanker*; vai của nó là ở lại ăn đòn, không phải chạy giỏi. Đổi số
cho ai cũng thoát được thì Chấn Địa thành một đòn không ai ăn, tức là không tồn
tại.

Hệ quả rơi ra đúng ba vai đã thiết kế sẵn:

| Vai | Làm gì khi thấy vòng tròn |
|---|---|
| **Hart** — Tanker | **Ở lại.** Ăn trọn, rồi chờ hồi máu. Đây là lúc nó làm đúng việc của nó |
| **Hvwd** — Carry, *"rất mỏng"* | **Chạy.** Nó đứng xa sẵn rồi, thường chỉ cần bước vài bước |
| **Hkal** — Mage/Support | **Chạy, rồi hồi máu cho Hart.** Đòn này là lý do tổ đội cần nó |

Nói cách khác: Chấn Địa không hỏi "ai né giỏi", nó hỏi **"đội có chia vai không"**.

## Vì sao tanker ở lại mà sống được

`b.dmg` tính trên **máu hiệu dụng trung bình cả đội**:

```
dmg      = ehpAvg / BOSS_HITS_TO_KILL       -- 12
slam     = dmg × 10                          = 0.833 × ehpAvg
mất bao nhiêu phần máu của hero i            = 0.833 × ehpAvg / EHP_i
```

Vì mẫu số là `EHP` **của chính hero đó**, cùng một đòn tự động:

- ăn **nhẹ hơn** vào hero có EHP trên trung bình (Hart),
- ăn **nặng hơn**, có thể quá 100%, vào hero dưới trung bình (Hvwd).

Đó chính là thứ làm "tanker ở lại, thằng mỏng chạy" thành **luật của số liệu**
chứ không phải lời khuyên trong docs.

## Nhưng "nhẹ hơn" là bao nhiêu thì phải đo

Chưa ai đo EHP thật của ba hero, nên không biết Hart mất 50% hay 95%. Đoán ở đây
là vô nghĩa — [đo, đừng đoán](../../CLAUDE.md).

Lúc boss xuất hiện, map ghi vào `DarknessTrace.txt` **một dòng cho mỗi hero**:

```
boss: slam pid 0 Hart -- mat 58% mau (o lai duoc) | chay 540/600 (KHONG kip)
boss: slam pid 1 Hvwd -- mat 141% mau (CHET NGAY) | chay 600/600 (thoat kip)
```

Đọc hai cột đó rồi mới chỉnh, và chỉnh thì chỉnh một số trong `CFG.BOSS_MECH.slam`:

| Đọc được | Nghĩa là | Sửa |
|---|---|---|
| Hart `(CHET NGAY)` | Tanker không tank nổi — vai của nó bị phá | Hạ `factor` |
| Hart mất < 40% | Ở lại không đau, đòn thành vô hại | Tăng `factor` |
| Hvwd `(KHONG kip)` | Thằng mỏng cũng không thoát được → hết đường chơi | Nới `cast` |

Ngưỡng muốn nhắm: **Hart ở lại được, Hvwd bắt buộc phải chạy.**

## Hệ quả

- Chưa có hồi máu thì Chấn Địa **rất** đau: Hart ăn hai phát liên tiếp (cách nhau
  9s) là chết. Đó là áp lực buộc Hkal phải có mặt — và cũng là một lý do nữa để
  làm hồi sinh hero (xem phần *Chưa làm* của [boss.md](../02-he-thong/boss.md)).
- Chấn Địa **không** nhân hệ số phát cuồng. `10 × 1.6 = 133%` là chết chắc ngay
  từ máu đầy, mà một đòn chết chắc thì báo trước cũng vô nghĩa — và nó sẽ giết
  luôn cả tanker, tức xoá sạch quyết định ở trên.
- Solo một mình cầm Hvwd hoặc Hkal thì Chấn Địa gần như là án tử. Chấp nhận:
  map này thiết kế cho tổ đội, và ba hero đã ghi rõ điểm yếu ngay trên thẻ chọn.
