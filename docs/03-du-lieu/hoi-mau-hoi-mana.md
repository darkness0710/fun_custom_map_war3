# Hồi máu & hồi mana — số đo, không phải trí nhớ

> **Khoá CFG:** chưa có hệ nào dùng. Tài liệu này ghi lại **kết quả đo** để hệ
> sau khỏi phải suy lại từ đầu.
> **Đo bằng:** `-reg` và `-reg mana` trong game (2026-09-16, bản 1.31.1).

## Kết luận: hai trường, một công thức

```
hồi máu thật  = UNIT_RF_HIT_POINTS_REGENERATION_RATE + Str × 0.05
hồi mana thật = UNIT_RF_MANA_REGENERATION           + Int × 0.05
```

Số đo, đặt trường `= 7.0` cho cả hai:

| | chỉ số | dự đoán | **đo được** | lệch |
|---|---|---|---|---|
| máu | Str 10 | 7.50 | **7.50** | 0.000 |
| máu | Str 20 | 8.00 | **8.00** | 0.000 |
| mana | Int 5 | 7.25 | **7.25** | 0.000 |
| mana | Int 15 | 7.75 | **7.75** | 0.000 |

Khớp **không cần tham số tự do nào**. Hệ số suy từ hiệu số (nên mọi sai lệch cố
định đều tự triệt tiêu): `0.0500` cho cả hai.

Giá trị gốc của hero: máu `0.250`, mana `0.010`.

## Ba điều quan trọng, cả ba đều đã đo

**1. Trường chứa BASE, không phải tổng.** Phần chỉ số engine cộng ở ngoài. Ở lần
đo đầu, hero Str 13 mà trường vẫn đọc ra `0.250` chứ không phải `0.25 + 13×0.05
= 0.90`.

**2. Ghi vào trường KHÔNG bị xoá khi chỉ số đổi.** `SetHeroStr` / `SetHeroInt`
xong đọc lại vẫn `7.000`. Không cần gắn lại vào `EVENT_PLAYER_HERO_LEVEL`, không
cần né sang ability/buff.

> Phép loại suy với `UNIT_RF_DEFENSE` **không áp dụng được**. Armor thì Agility
> ghi thẳng vào chính trường đó nên đè tay bị mất; regen thì không. Hai trường
> trông giống nhau, engine đối xử khác nhau — chỉ đo mới biết.

**3. Cộng thêm thuần.** Vì phần chỉ số nằm ngoài trường, ghi
`trường = base + Σ bonus` cho ra đúng hành vi cộng: hero 5 hp/s, đeo dây +1 →
6 hp/s. Công thức game không bị đụng.

## Một luật bắt buộc: MỘT chỗ ghi duy nhất

Trường này là **giá trị tuyệt đối**, không phải "cộng dồn". Hai hệ cùng ghi vào
thì hệ sau xoá hệ trước — đúng cái bẫy mà `API.heroRecompute` trong
[7_effect.lua](../../src/2_player/7_effect.lua) đã dựng ra để tránh cho ba
chỉ số.

Nên khi làm dây chuyền / nhẫn: mọi nguồn bonus phải đi qua **một** hàm tính lại
`base + Σ bonus` rồi ghi **một lần**, giống hệt cách `heroRecompute` đang làm.

## Bẫy khi đo: bể đầy giữa chừng

Lần đo mana đầu tiên ra `2.50 mana/giây` với trường `7.0` — trông như engine xử
lý khác. Không phải:

```
mana tối đa 75, hạ xuống 50% = thiếu 37.5
trường 7.0  ->  đầy lại sau 5.4 giây
đo trong 15 giây  ->  chỉ tăng được 37.5, chia 15 = 2.50
```

Con số đó là trung bình **đúng**, nhưng nó trả lời một câu hỏi khác. Bể máu (425)
không bao giờ đầy kịp nên bên máu không lộ — **lỗi chỉ lộ ở bể nhỏ**.

`-reg` giờ hạ xuống 10% thay vì 50% và **tự báo đỏ khi chạm trần**, thay vì in
một con số trông hợp lý.
