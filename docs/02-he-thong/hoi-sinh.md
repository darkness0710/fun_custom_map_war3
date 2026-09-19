# Hệ thống: Hồi sinh hero

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-19
> **Code:** [14_revive.lua](../../src/2_player/14_revive.lua)
> **Khoá CFG:** `HERO_REVIVE_SECONDS` `HERO_SPAWN_OFFSET`

## Trước file này, chết là hết ván

`onAnyDeath()` chỉ xử lý **nhà chính** và **quái** — không một dòng nào cho hero.
Quét cả cây nguồn: đường sống lại duy nhất là **Ankh 500 vàng**, hoặc bị động
**Hồi Sinh** của `A006`.

Nghĩa là chết ở wave 30 mà không có Ankh thì **ngồi xem 70 wave còn lại**. Trong
map co-op ba người, đó là cho một người nghỉ chơi giữa chừng mà vẫn phải ngồi đó.

**Và nó còn âm thầm làm hỏng cân bằng boss.** `measureParty()` bỏ qua hero chết,
nên boss **nhỏ lại** theo:

> Đội hai người thắng dễ hơn đội ba người có một xác.

Không ai nhìn ra được, vì boss vẫn "có máu theo đội" — chỉ là đội bị đếm thiếu.

## 30 giây, ở nhà chính

| | |
|---|---|
| **Bao lâu** | `HERO_REVIVE_SECONDS = 30` — `0` là tắt hẳn |
| **Ở đâu** | quanh **nhà chính**, toả theo slot để ba người không chồng lên nhau |
| **Máu/mana** | đẩy về **đầy** |

**30 giây** chọn theo nhịp wave: một wave thường kéo 40–60 giây, nên chết là mất
gần trọn một wave — đủ để thấy xót, chưa đủ để bỏ game.

**Ở nhà chính chứ không ở chỗ vừa chết.** Chỗ vừa chết là chỗ vừa thua: sống lại
ngay giữa bầy quái là chết lần hai trong ba giây. Đoạn đường quay lại **chính là
phần giá phải trả** — và nó tự co giãn theo việc người chơi đang đánh xa nhà đến
đâu.

**Đẩy máu/mana về đầy** vì `ReviveHero` của Warcraft trả hero về một phần máu, mà
sống lại với một vạch máu thì 30 giây kia thành vô nghĩa.

## Báo cho cả bàn đồ

```
[Player] da nga xuong -- 30 giay nua tro lai.
[Player] da dung day tro lai.
```

Báo riêng người vừa chết là vô nghĩa — họ đang nhìn màn hình xám. Giá trị nằm ở
chỗ **hai người kia biết đội vừa mất một phần ba hoả lực trong 30 giây** và lùi
về giữ nhà.

## Bốn điều kỹ thuật

### 1. Không cần đồng bộ

Sự kiện chết của Warcraft bắn trên **mọi máy** với cùng một unit, nên mỗi máy tự
chạy cùng một nhánh và ra cùng kết quả. Khác hẳn callback frame
([ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md)) — cái đó chỉ bắn
trên máy bấm.

### 2. Không đẩy sang `onMobDeath`

`onHeroDeath()` trả `true` khi đã nhận xử lý, và `onAnyDeath()` dừng ở đó.
`onMobDeath()` **cộng tiền thưởng cho kẻ giết** — để hero rơi vào đó là phe địch
được thưởng vì giết người chơi.

### 3. Nhận hero bằng `d.hero == u`, không bằng chủ sở hữu

Pet và tháp canh cũng thuộc về người chơi. Kiểm chủ sở hữu thì một cái tháp sập
cũng hẹn giờ hồi sinh.

### 4. Một cờ hẹn duy nhất

`d.reviving`. Không có nó thì *chết → Ankh cứu → chết lại* sẽ xếp **hai** cái hẹn,
và cái thứ nhất sẽ "hồi sinh" một hero đang sống.

`revive()` cũng kiểm lại `API.alive(u)` **lúc đến giờ**: Ankh hoặc `A006` có thể
đã lo trước, và lúc đó không được đụng vào.

## Chưa làm

- **Chưa đo trận thật.** `30` là con số đầu, chọn theo nhịp wave trên giấy.
- Không có đồng hồ đếm ngược trên màn hình — chỉ một dòng chữ lúc ngã và một dòng
  lúc dậy.
- Cả đội chết cùng lúc lúc đang đánh boss thì chưa có gì đặc biệt: boss đứng đó,
  ba người lần lượt về nhà rồi chạy lại.

← [Chọn hero](chon-hero.md) · [Boss](boss.md)
