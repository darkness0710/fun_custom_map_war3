# Đường cong sức mạnh

> ## Hết hiệu lực một phần — 2026-09-17
>
> Tài liệu này dựng trên **220 stage** và **thu nhập luỹ thừa ×967**. Cả hai đã
> đổi:
>
> | | Cũ | Nay |
> |---|---|---|
> | Tổng stage | 220 *(10 tầng + boss)* | **100** *(4 tầng + boss)* |
> | Thu nhập | `60 × 1.0319^(stage−1)`, cộng dồn 1,880,187 | **phẳng** — 1 Linh Khí/con, cả ván 4,000 |
> | EHP quái cả ván | `1.018^219 × 1.22^19` = **×2 176** | `1.018^99 × 1.22^19` = **×256** |
>
> Sức mạnh hero cả ván vẫn ×26 *(Tu Vi ×19.7 × kỹ năng ×1.33)*. Nên chênh lệch
> quái/hero tụt từ **×83** xuống **×10** — vẫn lệch, nhưng không còn là bất khả.
> Đây là lý do **chưa động vào `MOB_EHP_GROWTH`**: giữ nguyên hệ số thì chính
> việc rút stage đã kéo đường cong lại gần. Chỗ này phải đo khi chơi thử.
>
> Phần **hình dạng** đường cong bên dưới vẫn đúng; phần **con số tuyệt đối** thì
> không. Ngân sách đang chạy nằm ở [kinh-te.md](../02-he-thong/kinh-te.md).


> **Trạng thái:** Nháp — công thức đã chốt, **con số chờ chơi thử**
> **Cập nhật:** 2026-09-15
> **Khoá CFG:** `MOB_EHP_*` `MOB_DMG_*` `MOB_ARMOR_*` `SCALE_*` `BOSS_*`
> **Xem kèm:** [dot-quai.md](../02-he-thong/dot-quai.md) ·
> [canh-gioi.md](canh-gioi.md)

Trang này là **ngoại lệ của quy ước "số sống trong code"** — nó có số. Lý do:
đường cong là một hệ phương trình, và một hệ phương trình không đọc được nếu chỉ
thấy tên biến. Bảng tra bên dưới là **kết quả suy ra** từ công thức, không phải
tham số — sửa nó không đổi gì trong game. Tham số thật vẫn sống trong `CFG`; khi
đổi tham số thì sinh lại bảng bằng
`docs/03-du-lieu/curve.py` chứ đừng sửa tay.

## Hai chân của bài toán

Một đường cong địch chỉ đúng khi biết nó đối đầu với cái gì. Map này có một ràng
buộc bất thường làm chuyện đó khó hơn bình thường:

> **Hero không lên cấp.** `CFG.LOCK_HERO_XP = true` —
> [khoa-hero.md](../02-he-thong/khoa-hero.md).

Nghĩa là toàn bộ sức mạnh người chơi tăng lên trong 100 stage phải đến từ **thứ
chưa tồn tại**: trang bị, tu vi, nâng cấp. Nên trang này làm hai việc:

1. Định nghĩa đường cong **địch** — phần chốt được ngay.
2. Suy ra **hợp đồng** mà hệ tiến triển của người chơi phải thực hiện — phần
   chưa ai làm, và là rủi ro lớn nhất của cả thiết kế này.

## Công thức

Ba chỉ số, ba đường cong riêng. Chúng **cố ý dốc khác nhau**.

```
EHP  (s, r) = MOB_EHP_BASE   × MOB_EHP_GROWTH^(s-1)   × MOB_EHP_REALM_STEP^(r-1)
Dmg  (s, r) = MOB_DMG_BASE   × MOB_DMG_GROWTH^(s-1)   × MOB_DMG_REALM_STEP^(r-1)
Giáp (r)    = MOB_ARMOR_BASE + MOB_ARMOR_PER_REALM    × (r-1)
```

`s` là stage 1…220, `r` là cảnh giới 1…20. Cả hai suy ra từ một biến —
[canh-gioi.md](canh-gioi.md).

Giá trị đang đề xuất:

| | Base | Growth (mỗi stage) | Realm step (mỗi cảnh giới) | Tổng sau 100 stage |
|---|---|---|---|---|
| EHP | 20 | 1.018 | 1.22 | **×2 176** |
| Dmg | 6 | 1.016 | 1.12 | **×279** |
| Giáp | 0 | — | +1.0 | 0 → 19 |

### Vì sao có hai số thay vì một

Một hệ số tăng trưởng duy nhất cho ra đường mũ trơn tru, và trơn tru là dở: 220
bước bằng nhau thì không bước nào là cột mốc. Tách làm hai cho phép chỉnh **nhịp**
độc lập với **tổng**:

| | Nhân | Người chơi thấy gì |
|---|---|---|
| Tầng 1 → tầng 10 trong cùng cảnh giới | ×1.174 | Nhích nhẹ. Cái đổi thật là **tu chính**, không phải chỉ số |
| Bước qua cảnh giới mới | ×1.264 | Một nấc rõ ràng, ngay sau khi vừa hạ boss |
| Trọn một cảnh giới | ×1.485 | "Cảnh giới sau mạnh gấp rưỡi" |

Chủ ý là **bước qua cảnh giới (×1.264) phải lớn hơn cả mười tầng cộng lại
(×1.174)**. Đó là thứ làm "viên mãn rồi vượt cấp" có nghĩa. Muốn cột mốc đậm hơn
nữa thì tăng `REALM_STEP` và giảm `GROWTH` — giữ tích của chúng không đổi để tổng
2 176 đứng yên.

### Vì sao sát thương dốc thoải hơn máu

EHP ×2 176 nhưng sát thương chỉ ×279. Nếu hai đường cùng dốc thì giai đoạn cuối
mọi thứ chết trong một đòn theo cả hai chiều — hero chạm là chết, mà chọn sai kỹ
năng cũng chết. Trò chơi biến thành xúc xắc.

Cho sát thương dốc thoải hơn nghĩa là **số đòn hero chịu được giữ nguyên** trong
khi **số đòn hero cần đánh giảm dần**. Cuối game nhanh hơn và nguy hiểm hơn,
nhưng vẫn còn chỗ để sửa sai. Tỉ lệ 2 176 / 279 ≈ 7.8 lần trôi trong suốt 220
stage — trôi chậm, có chủ ý.

## Giáp không nằm trong đường cong

Công thức giáp của Warcraft III:

```
giảm sát thương = (0.06 × giáp) / (1 + 0.06 × giáp)
EHP             = máu × (1 + 0.06 × giáp)
```

Giáp **là** máu, viết cách khác. Cộng giáp mà vẫn giữ nguyên máu là lén nhân
đường cong lên lần thứ hai. Với giáp 19 ở cảnh giới 20, đó là nhân lén ×2.14.

Nên luật là: **đường cong sinh ra EHP; máu thật suy ngược ra từ giáp.**

```
máu thật = EHP / (1 + 0.06 × giáp)
```

Giáp tồn tại để có **đối kháng** — để kỹ năng giảm giáp, sát thương phép bỏ qua
giáp, đòn chí mạng có chỗ dùng. Nó không tồn tại để làm quái cứng hơn.
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md)

## Nhân theo số người chơi

```
EHP  ×= 1 + SCALE_EHP_PER_PLAYER      × (P - 1)      -- 0.60
Dmg  ×= 1 + SCALE_DMG_PER_PLAYER      × (P - 1)      -- 0.15
EHP boss ×= 1 + SCALE_BOSS_EHP_PER_PLAYER × (P - 1)  -- 0.75
Giáp, số lượng:  không nhân
```

`P` là số người chơi **thật sự đang chơi** (`#S.pids`), tính lại ở đầu mỗi wave
(`SCALE_RECOUNT_EACH_WAVE`).

Bốn lựa chọn ở đây, mỗi cái đều có lý do:

**Máu nhân dưới tuyến tính (0.60 chứ không phải 1.0).** Ba hero không mạnh gấp
ba một hero — họ mạnh hơn thế: AoE chồng lên nhau, buff dùng chung, tập trung hạ
mục tiêu, và một người đỡ đòn cho hai người kia đánh. Nhân đủ ×3 là phạt người
chơi vì rủ được bạn.

| P | Nhân EHP | Tổng DPS đội cần (stage 100) | Mỗi hero |
|---|---|---|---|
| 1 | ×1.0 | 58 019 | 58 019 |
| 2 | ×1.6 | 92 830 | 46 415 |
| 3 | ×2.2 | 127 641 | 42 547 |

Đi từ 1 lên 3 người, gánh nặng mỗi đầu người giảm 27 %. Solo vẫn thắng được,
đông vẫn dễ hơn — đúng thứ tự mong muốn cho map hợp tác.

**Sát thương gần như không nhân (0.15).** Sát thương đã tự loãng theo số người:
50 con quái chia cho 3 hero thì mỗi hero ăn 1/3. Nhân thêm lần nữa là nhân hai
lần. Giữ 0.15 để đông người không thành *dễ hơn* về mặt sống sót.

**Giáp không nhân.** Giáp là EHP (xem trên). Nhân nó là nhân EHP lần thứ hai.

**Số lượng không nhân.** 50 × 3 người = 150 unit một wave, chồng 2 wave là 300.
Pathing của Warcraft III sụp trước khi cân bằng kịp sai.
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

**Tính lại mỗi wave** để một người thoát giữa chừng không khoá cứng ván của hai
người còn lại ở mức khó của ba người.

## Tinh anh và boss

| | EHP | Dmg | Giáp | Ghi chú |
|---|---|---|---|---|
| Lính chuẩn (`Tốt`) | ×1 | ×1 | +0 | Định nghĩa đường cong |
| Tinh anh | ×10 | ×2.5 | +4 | 1 con mỗi wave, 2 con ở tầng viên mãn |
| Boss | ×80 | ×3 | +8 | Xem [boss.md](../02-he-thong/boss.md) |

Một wave thường nặng tổng cộng:

```
50 × EHP  +  1 × 10 × EHP  =  60 × EHP
```

Con số **60** là đơn vị đo của cả thiết kế này. Mọi tính toán thời gian bên dưới
đều bắt đầu từ nó.

Boss ×80 thì thời gian hạ boss tự động bằng `80/60 = 1.33` lần thời gian hạ một
wave, ở **mọi** giai đoạn — vì cả hai cùng trôi theo một đường cong. Đó là lý do
chọn 80: nó không phải số đẹp, nó là số giữ cho mọi trận boss dài như nhau.

## Bảng tra theo cảnh giới

Suy ra từ công thức, giá trị cho **1 người chơi**. Nhân theo bảng ở trên cho 2–3
người.

| # | Cảnh giới | Stage | EHP tầng 1 | EHP viên mãn | Máu thật | Giáp | Dmg | EHP tinh anh | EHP boss | Dmg boss | DPS đội cần |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Phàm Nhân | 1–11 | 20 | 23 | 23 | 0 | 7 | 235 | 1 912 | 21 | 70 |
| 2 | Luyện Khí | 12–22 | 30 | 35 | 33 | 1 | 9 | 349 | 2 839 | 28 | 105 |
| 3 | Trúc Cơ | 23–33 | 44 | 52 | 46 | 2 | 12 | 518 | 4 215 | 38 | 155 |
| 4 | Kim Đan | 34–44 | 65 | 77 | 65 | 3 | 16 | 768 | 6 257 | 50 | 230 |
| 5 | Nguyên Anh | 45–55 | 97 | 114 | 92 | 4 | 22 | 1 141 | 9 288 | 67 | 244 |
| 6 | Hóa Thần | 56–66 | 144 | 169 | 130 | 5 | 29 | 1 693 | 13 789 | 89 | 363 |
| 7 | Luyện Hư | 67–77 | 214 | 251 | 185 | 6 | 39 | 2 513 | 20 470 | 119 | 539 |
| 8 | Hợp Thể | 78–88 | 318 | 373 | 263 | 7 | 52 | 3 731 | 30 388 | 158 | 800 |
| 9 | Đại Thừa | 89–99 | 472 | 554 | 374 | 8 | 69 | 5 539 | 45 111 | 211 | 1 187 |
| 10 | Độ Kiếp | 100–110 | 700 | 822 | 534 | 9 | 92 | 8 223 | 66 968 | 282 | 1 762 |
| 11 | Chân Tiên | 111–121 | 1 040 | 1 221 | 763 | 10 | 123 | 12 207 | 99 415 | 376 | 2 035 |
| 12 | Thiên Tiên | 122–132 | 1 543 | 1 812 | 1 092 | 11 | 164 | 18 122 | 147 583 | 501 | 3 020 |
| 13 | Kim Tiên | 133–143 | 2 291 | 2 690 | 1 564 | 12 | 219 | 26 902 | 219 090 | 668 | 4 484 |
| 14 | Thái Ất | 144–154 | 3 401 | 3 994 | 2 244 | 13 | 292 | 39 937 | 325 243 | 891 | 6 656 |
| 15 | Đại La | 155–165 | 5 049 | 5 929 | 3 222 | 14 | 390 | 59 286 | 482 829 | 1 188 | 9 881 |
| 16 | Tiên Đế | 166–176 | 7 496 | 8 801 | 4 632 | 15 | 520 | 88 012 | 716 768 | 1 585 | 14 669 |
| 17 | Thánh Nhân | 177–187 | 11 127 | 13 066 | 6 666 | 16 | 693 | 130 655 | 1 064 055 | 2 113 | 17 421 |
| 18 | Đạo Tổ | 188–198 | 16 519 | 19 396 | 9 602 | 17 | 925 | 193 960 | 1 579 608 | 2 819 | 25 861 |
| 19 | Hỗn Độn Thần | 199–209 | 24 523 | 28 794 | 13 843 | 18 | 1 233 | 287 937 | 2 344 956 | 3 759 | 38 392 |
| 20 | Sáng Thế Thần | 210–100 | 36 404 | 42 745 | 19 974 | 19 | 1 645 | 427 447 | 3 481 129 | 5 013 | 56 993 |

Cột **DPS đội cần** = `60 × EHP viên mãn / WAVE_TIME`. Đây là con số phải nhìn:
nó là hợp đồng, không phải kết quả.

Ba chỗ cột đó **chững lại** (cảnh giới 5, 11, 17 — chỉ tăng ~6–19 % thay vì ~48 %)
không phải lỗi: đó là lúc `WAVE_TIME` nhảy lên bậc mới, wave dài ra nên DPS cần
tăng chậm hẳn. Đúng chỗ để thở sau một quãng leo dốc, và nó rơi đúng vào đầu mỗi
cõi mới.

## Ngân sách thời lượng

`WAVE_TIME` theo cõi. Một cảnh giới tốn `10 × T` (wave thường) `+ 2 × T`
(stage boss, `WAVE_BOSS_TIME_MULT` = 2) = `12 × T`.

> `WAVE_BOSS_TIME_MULT` **chưa tồn tại trong `CFG`**: hiện stage boss dùng đúng
> `WAVE_TIME` như wave thường. Ngân sách dưới đây tính theo thiết kế, nên nó
> **hơi dài hơn** thời lượng thật đang chạy.

| Cõi | Cảnh giới | `WAVE_TIME` | 50 đợt thường |
|---|---|---|---|
| Phàm | 1–5 | 32 s *(trước: 20)* | 27 phút |
| Yêu | 6–10 | 28 s | 23 phút |
| Tiên | 11–15 | 40 s *(trước: 36)* | 33 phút |
| Thần | 16–20 | 45 s | 38 phút |
| | | 20 boss (~40 s, **không đồng hồ**) | 13 phút |
| | | | **134 phút** |

> **134 phút là vấn đề lớn nhất của thiết kế này, không phải đường cong.**
>
> Một ván Warcraft III custom thường 40–90 phút. Hơn 2 giờ nghĩa là gần như không
> ai chơi hết — họ bỏ ở khoảng cảnh giới 12, và 8 cảnh giới đẹp nhất chưa ai thấy
> bao giờ.
>
> **Và con số này vừa tăng 16 phút** (từ 118) khi sửa `WAVE_TIME` cõi 1 và 3.
> Bắt buộc phải sửa — không sửa thì cơ chế gọi sớm không dùng được, xem
> [ADR 0018](../05-quyet-dinh/0018-nghi-giua-hai-canh-gioi.md).

Bốn cách xử lý, không loại trừ nhau:

**1. Gọi sớm (`WAVE_AUTO_NEXT` + lệnh `-next`, đã cài).** Dọn sạch là vào đợt sau
ngay, không chờ hết đồng hồ. Giữ nguyên 100 stage và thưởng cho người chơi giỏi.
Nên làm dù chọn thêm cách nào.

> Cơ chế này **từng nằm đó mà không dùng được**: `WAVE_TIME` cõi 1 là 20s trong
> khi quái đi bộ đã hết 19.9s, nên map không bao giờ sạch và `S.alive` không bao
> giờ về 0. Sửa `WAVE_TIME` mới là thứ bật nó lên — và cũng chính là thứ làm ván
> dài thêm. Phần cắt và phần thêm không bù nhau.

**2. Giảm còn 5 tầng mỗi cảnh giới.** 20 × 6 = 120 stage → **70 phút**. Giữ đủ 20
cảnh giới và 20 boss, mất một nửa số tầng. Nếu buộc phải cắt, cắt ở đây — vì 10
tầng trong một cảnh giới chỉ chênh nhau 17 % chỉ số, 5 tầng không mất gì nhiều.

**3. Cho lưu tiến độ.** Sinh mã chơi tiếp (`-save` / `-load`). Chấp nhận 2 giờ,
chia làm hai buổi. Nhiều việc, nhưng là cách duy nhất giữ trọn 100 stage.

**4. Chế độ ngắn.** Lệnh lúc bắt đầu ván, chọn chơi 20 cảnh giới × 5 tầng hay
× 10 tầng. Một cờ trong `CFG`, và hai chế độ dùng chung một đường cong nếu công
thức tính theo *tỉ lệ hoàn thành* thay vì theo stage tuyệt đối.

Đề xuất: **làm 1 ngay, thiết kế cho 4 từ đầu, để 3 lại sau.**

## Hợp đồng sức mạnh người chơi

Đây là phần chưa ai làm, và nếu không làm thì mọi con số ở trên vô nghĩa.

Từ bảng tra, để wave luôn hạ kịp giờ:

| | Stage 1 | Stage 100 | Phải tăng |
|---|---|---|---|
| DPS mỗi hero | ~60 | ~58 000 | **×967** |
| EHP mỗi hero | ~600 | ~167 000 | **×279** |

EHP hero bám đúng đường cong sát thương địch (×279) để "hero chịu được bao nhiêu
đòn" là hằng số suốt ván. Chọn hằng số đó quanh **10 đòn của lính thường**.

**Hero không lên cấp**, nên cả ×967 phải đến từ chỗ khác. Ngân sách đề xuất:

| Nguồn | Nhân | Ghi chú |
|---|---|---|
| Tu vi — cảnh giới của **người chơi** | ×40 | 20 bậc, mỗi bậc ×1.215. Lên bậc khi phe địch lên cảnh giới |
| Trang bị | ×12 | Mua bằng thứ tinh anh và boss rơi ra |
| Nâng cấp kỹ năng | ×2 | Hệ nút `+` hiện có — [ky-nang.md](../02-he-thong/ky-nang.md) |
| | **×960** | ≈ ×967 ✔ |

**Tu vi là mảnh còn thiếu, và nó hợp chủ đề đến mức đáng ngờ.** Phe địch tu tiên
qua 20 cảnh giới; người chơi cũng vậy, trên cùng một thang. Nó cho đúng thứ mà
`LOCK_HERO_XP` lấy đi (một đường tiến triển thấy được), mà không phải bật lại
kinh nghiệm hero — nên mốc máu của nhà chính và mọi thứ đã cài quanh
`SuspendHeroXP` không phải đụng tới.

Trước khi code hệ wave, phải trả lời: **tu vi lên bằng gì.** Tự động theo cảnh
giới địch, hay người chơi phải gom tài nguyên để đột phá? Chọn tự động thì nó chỉ
là một con số trang trí; chọn gom tài nguyên thì nó là lối chơi, nhưng phải có
kinh tế trước.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `MOB_EHP_BASE` | EHP lính chuẩn ở stage 1 | Chỉnh nó là dời cả đường cong lên/xuống, giữ nguyên hình dạng. Đây là nút chỉnh độ khó tổng thể |
| `MOB_EHP_GROWTH` | Nhân mỗi stage | Rất nhạy: mũ 219. Đổi từ 1.018 sang 1.020 là tổng nhảy từ ×2 176 lên ×3 351 |
| `MOB_EHP_REALM_STEP` | Nhân thêm mỗi cảnh giới | Mũ 19. Giữ `GROWTH^11 × REALM_STEP` cố định thì tổng không đổi, chỉ đổi **nhịp** |
| `MOB_DMG_BASE` `MOB_DMG_GROWTH` `MOB_DMG_REALM_STEP` | Như trên, cho sát thương | Phải dốc thoải hơn EHP. Bằng nhau là cuối game thành xúc xắc |
| `MOB_ARMOR_BASE` `MOB_ARMOR_PER_REALM` | Giáp theo cảnh giới | Tuyến tính, không mũ. Đổi nó **không** đổi độ khó — máu thật tự chia lại. [ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md) |
| `SCALE_EHP_PER_PLAYER` | Nhân EHP mỗi người thêm | Phải < 1.0. Bằng 1.0 là phạt người chơi vì rủ bạn |
| `SCALE_DMG_PER_PLAYER` | Nhân sát thương mỗi người thêm | Giữ nhỏ — sát thương đã tự loãng theo số mục tiêu |
| `SCALE_BOSS_EHP_PER_PLAYER` | Riêng cho boss | Cao hơn lính: boss là một thân, đông người tập trung hạ hiệu quả hơn nhiều |
| `SCALE_RECOUNT_EACH_WAVE` | Tính lại `P` mỗi wave | `true` — người thoát giữa chừng không khoá cứng ván của người ở lại |
| `WAVE_TIME` | Giây mỗi wave, theo cõi | Xem ngân sách thời lượng. Đây là nút chỉnh **thời lượng ván**, và nó cũng chỉnh DPS cần — hai thứ dính nhau |

## Hợp đồng đã thực hiện tới đâu

**Ngân sách đã chuyển từ ba nguồn sang bốn** —
[ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md). Bảng ×40/×12/×2 ở
trên là **bản cũ**; bản đang chạy là:

| Nguồn | Nhân | Mua bằng | Trạng thái |
|---|---|---|---|
| Tu Vi | ×19.7 | Linh Khí | **Đã cài** — [3_linhcan.lua](../../src/2_nguoi_choi/3_linhcan.lua), `LINHCAN_STEP = 1.17` |
| Trang Bị | ×8.3 | Linh Khí | **Đã cài** — [5_trangbi.lua](../../src/2_nguoi_choi/5_trangbi.lua), 6 ô × 10 cấp |
| Kỹ Năng | ×2.4 | **Ngộ Tính** | **Đã cài** — [4_skill.lua](../../src/2_nguoi_choi/4_skill.lua), nhưng số liệu chưa có hiệu lực (`SKILL_DATA_LIVE = false`) |
| Pháp Khí | ×2.5 | **Tinh Thạch** | **Đã cài** — [6_phapkhi.lua](../../src/2_nguoi_choi/6_phapkhi.lua), 5 món |
| | **×392 / ×967** | | ⚠ thiếu ×2.5 vì Pháp Khí rỗng |

**Hai bản không trộn được.** Tu Vi ×40.5 của bản cũ nhân với Trang Bị ×8 của
bản mới cho ×1 942 — gấp đôi hợp đồng.

## Chưa làm

- **Chưa chơi thử một giây nào.** Mọi con số ở đây là suy luận. Ba chỗ dễ sai
  nhất: DPS thật của hero cấp 1 ở stage 1 (đoán 60), thời gian quái đi bộ tới nhà,
  và `MOB_EHP_BASE`.
- **Số liệu kỹ năng chưa có hiệu lực.** `CFG.SKILL_DATA_LIVE = false` — hệ bậc
  và giá chạy đúng, nhưng sát thương thật vẫn là số gốc của Warcraft, nên ×2.4
  kia chưa thu được đồng nào.
- **Pháp Khí trả ×2.5 bằng đường vòng.** Năm món không món nào cộng thẳng sát
  thương; chúng cộng vào kinh tế và sức chịu của nhà chính. Chưa đo được đường
  vòng đó có bằng ×2.5 thật không.
- `curve.py` để sinh lại bảng tra. Hiện bảng này chép tay từ một lần chạy.

Đường cong phần thưởng thì **đã cài** và bám ×967, không bám ×2 176:
`LINHKHI_GROWTH = 1.0319 = 967^(1/219)` — xem [kinh-te.md](../02-he-thong/kinh-te.md).
