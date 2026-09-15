# Nâng cấp kỹ năng: giá và sức mạnh mỗi bậc

> **Trạng thái:** Đã chốt đường cong, chưa gán số cho từng skill
> **Cập nhật:** 2026-09-15
> **Khoá CFG:** `SKILL_COST_BASE` `SKILL_COST_STEP` `SKILL_DMG_STEP` `SKILL_CD_STEP` `SKILL_PASSIVE_STEP`

10 bậc mỗi skill, 7 skill mỗi hero. Bậc 1 được phát sẵn khi chọn skill, nên mỗi
skill có **9 lần nâng** — cả hero là 63 lần, trải 220 stage.

## Ngân sách: ×2, và ×2 đó là TÍCH của mọi nút chỉnh

Từ [đường cong sức mạnh](duong-cong-suc-manh.md): cả hệ nâng cấp kỹ năng được
**×2** trong tổng ×967. Linh Căn ×40, trang bị ×12.

Sai lầm dễ mắc: cho sát thương ×2 **rồi** giảm hồi chiêu 60s→33s. Hồi chiêu ngắn
đi nghĩa là đánh được nhiều lần hơn — đó cũng là sức mạnh. Làm vậy là ×3,6, vượt
ngân sách gần gấp đôi.

Nên ×2 phải **chia** cho các nút:

| Loại skill | Hệ số | Hồi chiêu | Tích |
|---|---|---|---|
| Chủ động | ×1,33 | ×0,667 (tần suất ×1,5) | **×2,00** |
| Bị động / aura | ×2,00 | — | **×2,00** |

Bị động không có hồi chiêu nên ăn trọn ×2 vào con số của nó.

## Bảng tra

```
bac           gia     cong don    cd 60s    he so  bi dong     tich
1               -            0     60.0s     1.00     1.00     1.00
2              89           89     57.4s     1.03     1.08     1.08
3             177          266     54.8s     1.07     1.17     1.17
4             352          619     52.4s     1.10     1.26     1.26
5             701        1,320     50.1s     1.14     1.36     1.36
6           1,396        2,716     47.9s     1.17     1.47     1.47
7           2,778        5,493     45.8s     1.21     1.59     1.58
8           5,527       11,020     43.8s     1.25     1.71     1.71
9          10,999       22,020     41.9s     1.29     1.85     1.85
10         21,888       43,908     40.0s     1.33     2.00     1.99
```

Giá tính bằng Linh Khí, cho **một** skill. Cả 7 skill lên bậc 10: **307 356**
Linh Khí, tức 16% thu nhập cả ván.

## Vì sao bước giá là 1,99

Linh Căn có 20 bậc, kỹ năng có 10 — mỗi bậc kỹ năng trải **2 cảnh giới**. Nên
bước giá kỹ năng = bước giá Linh Căn bình phương: 1,412² = 1,99.

Hệ quả là một câu so sánh người chơi đọc được:

| Nâng cả 7 skill một bậc | Đột phá Linh Căn cùng lúc | Tỉ lệ |
|---|---|---|
| 1→2: 623 | bậc 2→3: 620 | 1,01 |
| 5→6: 9 770 | bậc 10→11: 9 794 | 1,00 |
| 9→10: 153 219 | bậc 18→19: 154 758 | 0,99 |

Tỉ lệ nằm trong 0,99–1,01 **suốt 220 stage**. Lựa chọn luôn là: *một cảnh giới
tu vi, hay một vòng nâng cho cả bảy kỹ năng.* Không phải hai đường cong rời rạc.

## Nhịp

Nếu dồn toàn bộ Linh Khí vào kỹ năng (không đột phá lần nào):

| Bậc | Mua nổi từ stage |
|---|---|
| 2 | 10 |
| 5 | 57 |
| 8 | 120 |
| 10 | 163 |

Đó là **cận trên của tốc độ**. Thực tế còn phải chia với Linh Căn nên chậm hơn.
Tổng hai khoản = 56% thu nhập cả ván, còn dư 44% — chưa chặt, còn chỗ cho các
nguồn tiêu sau này.

## Lỗi kinh tế đã sửa cùng lúc

Tiền thưởng trước đây **chỉ vào người kết liễu**. Nhưng giá Linh Căn và giá nâng
kỹ năng thì **từng người tự trả nguyên giá**, còn độ khó lại tăng theo số người
(EHP lính ×2,2 khi ba người).

| Số người | Thu nhập/người | Cần chi/người | Dư/thiếu |
|---|---|---|---|
| 1 | 1 880 187 | 1 055 196 | **+78%** |
| 2 | 940 094 | 1 055 196 | −11% |
| 3 | 626 729 | 1 055 196 | **−41%** |

Rủ bạn vào chơi là cả ba cùng nghèo đi. Đã đổi thành **trả đủ cho mọi người**
— quái thường, tinh anh, boss, cả hai loại tiền, qua một hàm `rewardAll` duy
nhất. Kinh tế mỗi người giống hệt solo:
[ADR 0013](../05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md).

## Cái bẫy: giáp không chịu quy tắc ×2

Warcraft tính EHP từ giáp theo `1 + 0,06 × giáp`. Cộng thêm giáp thì đóng góp
của nó tăng tuyến tính — nhưng **giáp bản thân hero cũng tăng**, vì Linh Căn cho
+770 mỗi chỉ số ở bậc 20, và Agility sinh giáp.

Đo với aura +15 (bậc 1) và +30 (bậc 10):

| | Giáp bản thân | Aura +15 | Aura +30 |
|---|---|---|---|
| Linh Căn bậc 1 | 8 | **+61% EHP** | **+122% EHP** |
| Linh Căn bậc 20 | ~115 | +11% EHP | +23% EHP |

Đóng góp của aura vẫn ×2 đúng ngân sách. Nhưng so với tổng EHP thì nó **teo từ
+122% xuống +23%** — cuối game aura gần như vô nghĩa. Đúng bài học
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md) quay lại ở
chỗ khác.

**Cách chữa:** aura cộng **phần trăm giáp của chính hero** thay vì cộng số cố
định, viết bằng Lua (`BlzSetUnitArmor`). Lúc đó nó tự bám theo Linh Căn. Cần
kiểm `BlzSetUnitArmor` có trên bản này không — gõ `-nat` trong game.

> Đây là ví dụ rõ nhất cho việc **khi nào nên fake skill bằng Lua**: không phải
> để làm lại thứ Warcraft đã có, mà để làm thứ nó không làm được — một con số
> bám theo chỉ số khác.

## Gán nút chỉnh cho 7 skill của Hart

Đọc từ `war3map.w3a`:

| ID | Gốc | Là gì | Loại số | Nút chính mỗi bậc |
|---|---|---|---|---|
| `A001` | `AOsh` Shockwave | **Chưởng** — chủ động, sát thương | hệ số | ×1,03 · hồi chiêu ×0,956 |
| `A002` | `AHhb` Holy Light | chủ động, hồi máu | hệ số | ×1,03 · hồi chiêu ×0,956 |
| `A003` | `AHad` Devotion Aura | bị động, aura giáp | **cộng thẳng** | ⚠ teo dần — xem dưới |
| `A004` | `Aamk` Attribute Bonus | bị động, cộng cả ba chỉ số | **cộng thẳng** | ⚠ teo dần — xem dưới |
| `A005` | `ACce` Cleaving Attack *(lấy từ unit)* | bị động, đánh lan | phần trăm | % ×1,08 |
| `A006` | `Aamk` Attribute Bonus *(làm vật mang)* | bị động, giảm % sát thương | phần trăm | % ×1,08 |
| `A007` | `AHav` Avatar | chủ động, tăng chỉ số | hệ số | ×1,03 · hồi chiêu ×0,956 |

### Cộng thẳng thì chết, phần trăm thì sống

Đây là lằn ranh quan trọng nhất của cả bảng. Linh Căn cộng **+770 mỗi chỉ số** ở
bậc 20. Mọi kỹ năng cộng một lượng **cố định** vào thứ Linh Căn cũng cộng vào đều
bị nuốt.

`A004` cộng +20 (bậc 1) → +40 (bậc 10), tính theo % chỉ số hero:

| Linh Căn | Chỉ số hero | A004 bậc 1 | A004 bậc 10 |
|---|---|---|---|
| bậc 1 | 40 | +50% | **+100%** |
| bậc 10 | 164 | +12% | +24% |
| bậc 20 | 790 | +3% | **+5%** |

Kỹ năng vẫn ×2 đúng ngân sách. Nhưng giá trị thực của nó **rơi từ +100% xuống
+5%** — cuối game gần như vô nghĩa. `A003` (aura giáp) y hệt.

`A005` đánh lan và `A006` giảm % sát thương thì **không dính**, vì chúng là phần
trăm — tự bám theo sát thương và giáp của chính hero.

**Luật:** kỹ năng bị động phải cộng **phần trăm của chính hero**, không cộng số
cố định. `A003` và `A004` phải viết bằng Lua để làm điều đó — đã đo, bản này
có đủ native (xem dưới).

### Giảm % sát thương: trần cứng

`A006` giảm % sát thương thì **không được để bậc 10 chạm 50%**. Giảm 50% là EHP
×2; hai nguồn giảm % nhân nhau rất nhanh thành bất tử. Đề xuất bậc 1 = 5%, bậc 10
= 10% — đúng ×2, và trần 10% thì cộng với mọi thứ khác vẫn an toàn.

## Đã đo: bản 1.31.1 có đủ native cần thiết

Gõ `-nat` trong game:

```
Su kien sat thuong          : 7/7
Sua so lieu ability luc CHAY: 8/9   thieu ABILITY_RLF_DAMAGE_HCA1
Ky nang tu viet             : 5/5
Chi so hero                 : 5/5
```

| Nhóm | Mở ra cái gì |
|---|---|
| Sát thương 7/7 | Có `EVENT_PLAYER_UNIT_DAMAGING` + `BlzSetEventDamage` → chặn được sát thương **trước khi nó vào máu**. Né đòn và giảm % làm đúng được |
| Chỉ số hero 5/5 | Có `BlzSetUnitArmor` → aura cộng **% giáp** chạy được, chữa được `A003` |
| Ability lúc chạy 8/9 | Có `BlzSetAbilityRealLevelField` → **sửa số liệu ability từ Lua lúc chạy** |

Nhóm thứ ba đổi cả kế hoạch sinh file: nếu số liệu đặt được lúc chạy thì
`war3map.w3a` chỉ cần chứa **vỏ** (tên, icon, ô nút, `Levels`), còn 210 dòng số
nằm trong bảng Lua — chỉnh cân bằng không cần build lại file nhị phân nào.

> Thiếu `ABILITY_RLF_DAMAGE_HCA1` chỉ là **một hằng số tên trường**, không phải
> hàm. Các hàm đều có. Phải dò xem bản này dùng tên hằng nào — và còn **chưa
> đo** liệu sửa xong có ăn ngay hay phải `IncUnitAbilityLevel` để làm mới.

## Mở khóa: hero **không** có sẵn cả bảy

Bắt đầu với **2** kỹ năng đầu tiên; năm cái còn lại mua bằng Linh Khí.

Hai lý do, lý do thứ hai mới là cái nặng:

1. Cả bảy ngay từ stage 1 thì không còn gì để mong. Bảy ô trong command card
   đầy ngay giây đầu là hết chuyện.
2. **Phép tính hệ số 1,32 cho Chưởng chỉ đếm ba nguồn**: đánh thường, Chém
   Lan, Chưởng. Cho cả bảy ngay từ đầu là hero mạnh hơn hợp đồng stage 1
   rất nhiều — đầu ván thành dễ không.

Giá suy từ đường cong thu nhập: mở được kỹ năng thứ *k* vào khoảng stage này
nếu dành 22% thu nhập cộng dồn cho việc mở khóa:

| Lần mở thứ | Mở được khoảng stage | Giá |
|---|---|---|
| 3 | 15 | 250 |
| 4 | 40 | 790 |
| 5 | 75 | 2 910 |
| 6 | 120 | 13 560 |
| 7 | 170 | 68 210 |

Tổng mở khóa **85 720**. Cộng với nâng cấp (307 356) và Linh Căn (747 839) là
**61% thu nhập cả ván** — trước là 56%, vẫn còn chỗ cho các nguồn tiêu sau này.

**Giá theo số cái đã mở, không theo cái nào.** Mở cái thứ ba là 250 dù đó là kỹ
năng nào — người chơi thích mở cái nào trước thì mở. Ép thứ tự là lấy mất một
lựa chọn mà chẳng được gì.

Hai kỹ năng phát sẵn là **Chém Lan** và **Chưởng**: một nguồn dọn quái đông, một
nguồn đánh theo đường — đủ hai việc để sống qua những cảnh giới đầu.

`CFG.SKILL_START_COUNT = 7` là quay về kiểu cũ, có sẵn cả bảy.

> Dòng bị khóa trong bảng **không hiện số liệu** — chỉ tên, chữ "chưa mở" và
> giá. Hiện luôn cả số thì lộ hết, chẳng còn gì để mong.

## Số gốc cho 7 kỹ năng của Hart

Sát thương và hồi máu tính theo **hệ số × (17 + chỉ số cao nhất của hero)**.
Bị động tính theo **phần trăm**. Cả hai đều tự bám theo Linh Căn.

| Kỹ năng | Loại | Bậc 1 | Bậc 10 |
|---|---|---|---|
| Chưởng | chủ động | ×1,32 · hồi 8,0s | ×1,76 · hồi 5,3s |
| Hộ Thể | chủ động | ×2,20 · hồi 10,0s | ×2,93 · hồi 6,7s |
| Hiệu Lệnh | aura | 15% giáp | 30% giáp |
| Luyện Thể | bị động | 12% chỉ số | 24% chỉ số |
| Chém Lan | bị động | 20% văng | 40% văng |
| Da Sắt | bị động | 5% giảm | 10% giảm |
| Bất Hoại | chủ động | hồi 60s | hồi 40s |

### Hệ số 1,32 của Chưởng đến từ đâu

Stage 1 cần **60 EHP/giây** (50 lính × 20 EHP + 1 tinh anh × 200, chia cho 20
giây). Hart cấp 1: sát thương 12–22 (tb 17), Str 10.

```
danh thuong + chem lan : 24,3 EHP/giay
Dam Dat phai bu        : 35,7 EHP/giay
he so = 35,7 x 8,0 / (8 con x 27) = 1,32
```

Kiểm ngược ở cuối game (Linh Căn bậc 20, kỹ năng bậc 10, ×12 trang bị):
**51 595** so với **58 019 cần** — đạt 89%. Nằm trong sai số của ba giả định chưa
đo: tốc độ đánh 2,0s, Chưởng trúng 8 con, Chém Lan có 4 con đứng gần.

## Lỗ hổng đã vá: Linh Căn thiếu một nửa

Phát hiện khi đi gán số gốc. `CFG.LINHCAN_STEP` đang là **1,17**:

| | Nhân |
|---|---|
| Tài liệu ghi | 40 × 12 × 2 = **×960** |
| Config cài | 19,7 × 12 × 2 = **×474** |
| Hợp đồng cần | **×967** |

Cuối game người chơi chỉ mạnh bằng **49%** mức cần — thua chắc, mà không có gì
báo. Đã đổi thành **1,215** (×40,5 → tổng ×971).

Cùng lúc sửa hai số trước đây là phỏng đoán, giờ đọc được từ hero thật:
`LINHCAN_DMG_BASE` 20 → **17** (sát thương trung bình của Hart),
`LINHCAN_STAT_BASE` 20 → **10** (Str của Hart cấp 1).

## Hai lỗi đã gặp khi chơi thử

**Nâng lên bậc 10, trả đủ tiền, mà trong game chỉ lên bậc 3.**
Object Editor mới là người quyết định một ability có bao nhiêu bậc — ability
hero mặc định **3 bậc**, ability unit thường **1 bậc**. Gọi
`SetUnitAbilityLevel(u, aid, 10)` lên một ability 3 bậc thì nó **kẹp xuống 3 và
không báo lỗi gì**.

**Aura giáp max chỉ được 3 giáp.** Cùng gốc: ở bậc 3, và con số vẫn là mặc
định của Devotion Aura chứ không phải 15%/30% trong bảng này — chưa có gì
ghi số thiết kế vào ability, và "% giáp của chính hero" cần Lua viết riêng.

### Đã sửa — và phần lỗi là của code

Lỗi thật không phải "Object Editor thiếu bậc" — đó là công việc còn dở. Lỗi
là **code lấy tiền rồi báo bậc sai** mà không ai biết.

| | Trước | Sau |
|---|---|---|
| Trần bậc | đoán là 10 | **đo thật** bằng `SetUnitAbilityLevel` rồi đọc lại |
| Nâng quá trần | trừ tiền, báo 10/10 | **không trừ tiền**, báo đúng ability nào thiếu |
| Bảng hiển thị | `bậc 3/10` | `bậc 3/3 (OE thiếu bậc)` đỏ |
| Lúc chọn hero | im lặng | liệt kê ngay ability nào thiếu bậc |
| Số liệu | hiện như thật | ghi rõ **"THIẾT KẾ, chưa có hiệu lực"** |

Dòng cuối là `CFG.SKILL_DATA_LIVE`, bật khi bộ sinh đã ghi số vào `war3map.w3a`
và các skill bị động đã viết bằng Lua. **Bảng hiện số đẹp nhưng sai thì tệ hơn
là không hiện.**

## Chưa làm

- Chưa có con số gốc cho từng skill ở bậc 1 (sát thương bao nhiêu, hồi bao nhiêu).
  Phải suy từ DPS hero ở stage 1 — mà [con số đó vẫn là phỏng đoán](duong-cong-suc-manh.md).
- Hvwd và Hkal chưa gán nút chỉnh.
- Chưa đo `BlzSetUnitArmor` có trên 1.31.1 không.
