# Nâng cấp kỹ năng: giá và sức mạnh mỗi bậc

> **Trạng thái:** Đường cong sức mạnh đã chốt — **giá trả bằng Gỗ**
> **Cập nhật:** 2026-09-17
> **Khoá CFG:** `SKILL_LUMBER_UP` `SKILL_LUMBER_UNLOCK` `LUMBER_START` `SKILL_DMG_STEP` `SKILL_CD_STEP` `SKILL_PASSIVE_STEP`

> **Phần GIÁ của trang này đã lỗi thời.** Kỹ năng không mua bằng Linh Khí nữa —
> nó mua bằng **Gỗ**, rơi từ tinh anh (2) và boss (5), và giá là **1 điểm mỗi
> lần** chứ không phải đường cong mũ.
> [ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md) ·
> [kinh-te.md](../02-he-thong/kinh-te.md)
>
> Phần **sức mạnh mỗi bậc** (`SKILL_DMG_STEP`, `SKILL_CD_STEP`,
> `SKILL_PASSIVE_STEP`, ngân sách ×2.4) thì **vẫn đúng nguyên** — nó không dính
> gì tới chuyện trả bằng đồng tiền nào.

10 bậc mỗi skill, 7 skill mỗi hero. Bậc 1 được phát sẵn khi chọn skill, nên mỗi
skill có **9 lần nâng** — cả hero là 63 lần, trải 100 stage.

## Ngân sách: ×2, và ×2 đó là TÍCH của mọi nút chỉnh

Từ [đường cong sức mạnh](duong-cong-suc-manh.md): cả hệ nâng cấp kỹ năng được
**×2** trong tổng ×967. Tu Vi ×40, trang bị ×12.

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

> **Cột `price` và `cong don` ở trên là bản cũ** (Linh Khí, `89 × 1.99^(bac-1)`).
> Giữ lại vì phần còn lại của bảng — `cd`, `he so`, `bi dong`, `tich` — vẫn là số
> đang chạy. Giá hiện tại **phẳng, 1 điểm Ngộ Tính mỗi lần**:
>
> ```
> CFG.SKILL_NGO_UNLOCK = 1    -- mo khoa mot ky nang
> CFG.SKILL_NGO_UP     = 1    -- nang mot bac
> ```
>
> Trọn một kỹ năng = **10 điểm** (1 mở khoá + 9 nâng). Bảy kỹ năng = **70** trên
> 300 điểm kiếm được cả ván; 230 điểm còn lại dành cho Pháp Khí.

## Vì sao bước giá từng là 1,99 — và vì sao nó không còn

Tu Vi có 20 bậc, kỹ năng có 10 — mỗi bậc kỹ năng trải **2 cảnh giới**. Nên
bước giá kỹ năng = bước giá Tu Vi bình phương: 1,412² = 1,99. Nhờ đó "nâng cả
7 skill một bậc" luôn xấp xỉ "một lần đột phá Tu Vi" cùng thời điểm.

**Tính chất đó đã mất**, và mất có chủ ý. Nó chỉ có nghĩa khi hai hệ tiêu **cùng
một đồng tiền** — so 89 Linh Khí với 439 Linh Khí thì được, so 2 Ngộ Tính với
439 Linh Khí thì không so được.

Đổi lại: Tu Vi và Kỹ Năng không còn tranh nhau một cái ví, nên mỗi hệ có một
câu trả lời riêng cho "cần gì để nâng".
[ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md)

Hệ quả là một câu so sánh người chơi đọc được:

| Nâng cả 7 skill một bậc | Đột phá Tu Vi cùng lúc | Tỉ lệ |
|---|---|---|
| 1→2: 623 | bậc 2→3: 620 | 1,01 |
| 5→6: 9 770 | bậc 10→11: 9 794 | 1,00 |
| 9→10: 153 219 | bậc 18→19: 154 758 | 0,99 |

Tỉ lệ nằm trong 0,99–1,01 **suốt 100 stage**. Lựa chọn luôn là: *một cảnh giới
tu vi, hay một vòng nâng cho cả bảy kỹ năng.* Không phải hai đường cong rời rạc.

## Nhịp

Nếu dồn toàn bộ Linh Khí vào kỹ năng (không đột phá lần nào):

| Bậc | Mua nổi từ stage |
|---|---|
| 2 | 10 |
| 5 | 57 |
| 8 | 120 |
| 10 | 163 |

Đó là **cận trên của tốc độ**. Thực tế còn phải chia với Tu Vi nên chậm hơn.
Tổng hai khoản = 56% thu nhập cả ván, còn dư 44% — chưa chặt, còn chỗ cho các
nguồn tiêu sau này.

## Lỗi kinh tế đã sửa cùng lúc

Tiền thưởng trước đây **chỉ vào người kết liễu**. Nhưng giá Tu Vi và giá nâng
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
của nó tăng tuyến tính — nhưng **giáp bản thân hero cũng tăng**, vì Tu Vi cho
+770 mỗi chỉ số ở bậc 20, và Agility sinh giáp.

Đo với aura +15 (bậc 1) và +30 (bậc 10):

| | Giáp bản thân | Aura +15 | Aura +30 |
|---|---|---|---|
| Tu Vi bậc 1 | 8 | **+61% EHP** | **+122% EHP** |
| Tu Vi bậc 20 | ~115 | +11% EHP | +23% EHP |

Đóng góp của aura vẫn ×2 đúng ngân sách. Nhưng so với tổng EHP thì nó **teo từ
+122% xuống +23%** — cuối game aura gần như vô nghĩa. Đúng bài học
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md) quay lại ở
chỗ khác.

**Cách chữa:** aura cộng **phần trăm giáp của chính hero** thay vì cộng số cố
định, viết bằng Lua (`BlzSetUnitArmor`). Lúc đó nó tự bám theo Tu Vi. Cần
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
| `A003` | `AOae` Endurance Aura | bị động, aura tốc đánh + tốc chạy | **World Editor** | — *(đổi 2026-09-19)* |
| `A004` | `Aamk` Attribute Bonus | bị động, cộng cả ba chỉ số | **cộng thẳng** | ⚠ teo dần — xem dưới |
| `A005` | `ACce` Cleaving Attack *(lấy từ unit)* | bị động, đánh lan | phần trăm | % ×1,08 |
| `A006` | `AOre` Hồi Sinh | bị động, chết thì sống lại | **World Editor** | — *(đổi 2026-09-19)* |
| `A007` | `AHav` Avatar | chủ động, tăng chỉ số | hệ số | ×1,03 · hồi chiêu ×0,956 |

### Cộng thẳng thì chết, phần trăm thì sống

Đây là lằn ranh quan trọng nhất của cả bảng. Tu Vi cộng **+770 mỗi chỉ số** ở
bậc 20. Mọi kỹ năng cộng một lượng **cố định** vào thứ Tu Vi cũng cộng vào đều
bị nuốt.

`A004` cộng +20 (bậc 1) → +40 (bậc 10), tính theo % chỉ số hero:

| Tu Vi | Chỉ số hero | A004 bậc 1 | A004 bậc 10 |
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

## Mở khóa: tay không, nhưng cầm sẵn 1 điểm

**Chốt 2026-09-16:** `CFG.SKILL_START_COUNT = 0` và `CFG.LUMBER_START = 1`
*(khoá cũ tên `NGOTINH_START`, đã đổi; hạ từ `2` xuống `1` ngày 2026-09-19 —
hai Gỗ mở được **hai** kỹ năng ngay giây đầu, và thế là mất mất quyết định đầu
tiên của ván: "mở cái nào trước")*.
Hero vào map với command card trống, ví có đúng **một** Ngộ Tính — vừa đủ mở một
kỹ năng ngay giây đầu. Mở khoá 1 điểm, đôn một bậc 1 điểm, trọn bảy cái là
`7 × (1 + 9) = 70` điểm.

Ba bản đã thử, và cái nào hỏng thì hỏng ở đâu:

| Bản | Hỏng ở đâu |
|---|---|
| Giá leo theo số cái đã mở *(250 → 68 210 Linh Khí)* | Bắt người chơi tính một đường cong để trả lời một câu hỏi đáng ra rất đơn giản |
| Cả bảy phát sẵn | Giây đầu **không còn gì để chọn** — bảy ô đầy ngay là hết chuyện |
| Tay không, **0 điểm** | Giây đầu **không chọn được gì** — phải đánh đòn thường tới con tinh anh đầu tiên mới có cái để bấm |

Một điểm cầm sẵn lấp đúng khe giữa hai cái sau: có một quyết định, và chỉ một.

Cái phải chịu: "mở cái nào" và "đôn cái nào" vẫn tiêu chung một đồng tiền. Đó là
đánh đổi có ý thức — giá **phẳng** nên người chơi không phải tính, chỉ phải chọn.

Hệ số 1,32 của Chưởng tính cho hero **có** Chém Lan và đòn thường, nên thứ tự
mở khoá ảnh hưởng thật đến đợt đầu — xem bảng kỹ năng, hai cái đó xếp đầu.

> Bảy ô command card **đã đo** và vừa khít bảy kỹ năng — sơ đồ ở
> [thiet-ke-hero.md](../02-he-thong/thiet-ke-hero.md). Đo lại bằng `-nat card`.

## Luyện Thể: vì sao bỏ phần trăm

**Phần trăm của chỉ số không dùng được**, vì chỉ số đổi **×2,421** suốt ván.

Bản cũ `+12%` đo được: bậc Tu Vi 1 cộng **+2**, bậc 20 cộng **+5,810** *(79% một
lần đột phá)*. Không phải yếu — mà **lệch thời điểm**: vô hình đúng lúc phải bỏ
Gỗ ra mua, rồi mạnh lên miễn phí khi đã không cần.

Gốc rễ: nâng skill từ bậc 1 lên 10 chỉ đưa `12% → 24%`, tức **×2**, trong khi chỉ
số nền đổi ×2,421. Nên sức mạnh của skill do **Tu Vi** quyết định chứ không phải
do **bậc skill** — người chơi bỏ 10 Gỗ ra mà gần như không thấy gì.

```
bonus = chiso × SKILL_PASSIVE_STEP^(bậc skill−1) × CULT_STAT_STEP^(bậc Tu Vi−1)
      = 4 × 1.0801^(lv−1) × 1.30^(rank−1)
```

| Bậc Tu Vi | skill bậc 1 | skill bậc 10 | so với một lần đột phá |
|---|---|---|---|
| 1 | +4 | +8 | 16% |
| 5 | +11 | +23 | 16% |
| 10 | +42 | +85 | 16% |
| 20 | +585 | +1,170 | 16% |

Hai trục đều có nghĩa: **bậc skill** đổi ×2 *(trả Gỗ thì thấy được)*, **bậc Tu
Vi** giữ nó không bị bỏ lại. Tỉ lệ so với một lần đột phá **đứng yên 16%**.

Dùng **chính** `CULT_STAT_STEP` như hệ quay, nên đổi đường cong Tu Vi thì cả
ba hệ tự co theo.

> **Đá Sắt và Chém Lan không dính lỗi này.** Chúng là phần trăm của *sát thương*
> — đại lượng tự tỉ lệ theo chỉ số — nên chúng giữ nguyên `pct`. Chỉ Luyện Thể
> sai vì nó là phần trăm của **chỉ số**, mà chỉ số mới là thứ phình ×2,421.

## Số gốc cho 7 kỹ năng của Hart

Sát thương và hồi máu tính theo **hệ số × (17 + chỉ số cao nhất của hero)**.
Bị động tính theo **phần trăm**. Cả hai đều tự bám theo Tu Vi.

| Kỹ năng | Loại | Bậc 1 | Bậc 10 |
|---|---|---|---|
| Chưởng | chủ động | ×1,32 · hồi 8,0s | ×1,76 · hồi 5,3s |
| Hộ Thể | chủ động | ×2,20 · hồi 10,0s | ×2,93 · hồi 6,7s |
| Hiệu Lệnh | aura | 15% giáp | 30% giáp |
| Luyện Thể | bị động | +4 chỉ số *(phẳng, ×bậc Tu Vi)* | +8 |
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

Kiểm ngược ở cuối game (Tu Vi bậc 20, kỹ năng bậc 10, ×12 trang bị):
**51 595** so với **58 019 cần** — đạt 89%. Nằm trong sai số của ba giả định chưa
đo: tốc độ đánh 2,0s, Chưởng trúng 8 con, Chém Lan có 4 con đứng gần.

## Lỗ hổng đã vá: Tu Vi thiếu một nửa

Phát hiện khi đi gán số gốc. Bậc Tu Vi lúc đó nhân **1,17** mỗi bậc
*(khoá `CFG.CULT_STEP`, nay đã xoá — đường cong tính trong `cultPowerAt()`)*:

| | Nhân |
|---|---|
| Tài liệu ghi | 40 × 12 × 2 = **×960** |
| Config cài | 19,7 × 12 × 2 = **×474** |
| Hợp đồng cần | **×967** |

Cuối game người chơi chỉ mạnh bằng **49%** mức cần — thua chắc, mà không có gì
báo. Đã đổi thành **1,215** (×40,5 → tổng ×971).

Cùng lúc sửa hai số trước đây là phỏng đoán, giờ đọc được từ hero thật:
`CULT_DMG_BASE` 20 → **17** (sát thương trung bình của Hart),
`CULT_STAT_BASE` 20 → **10** (Str của Hart cấp 1).

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
