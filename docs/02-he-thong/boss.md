# Hệ thống: Boss cuối cảnh giới

> ## Mỗi boss một hào quang — 2026-09-19
>
> Năm aura **có sẵn của Warcraft**, không nhân bản. Chia đều `5 × 4 = 20`.
>
> | Hào quang | Boss mang | Làm gì |
> |---|---|---|
> | **Vampiric** | 1 · 4 · 8 · 20 | tự lành khi đánh trúng |
> | **Command** | 2 · 6 · 13 · 18 | gây thêm sát thương |
> | **Endurance** | 3 · 9 · 14 · 17 | đánh và chạy nhanh hơn |
> | **Unholy** | 5 · 10 · 11 · 15 | chạy nhanh + tự hồi máu |
> | **Trueshot** | 7 · 12 · 16 · 19 | đòn tầm xa mạnh hơn |
>
> **Vì sao dùng ability gốc thay vì nhân bản.** Cả năm đều là **phần trăm**, nên
> chúng tự bám theo sức boss và không bao giờ teo
> ([ADR 0024](../05-quyet-dinh/0024-cong-thi-leo-nhan-thi-phang.md)). Đây đúng là
> trường hợp hiếm mà *"để Warcraft giữ số"* là lựa chọn đúng — ngược hẳn với
> `CFG.SKILLS[H002]`, nơi mọi số phẳng đều phải kéo về Lua.
>
> Bậc hào quang leo theo cảnh giới: `1–7` bậc 1, `8–14` bậc 2, `15–20` bậc 3.
> Aura gốc có đúng 3 bậc và chúng là phần trăm, nên lên bậc là lên tỉ lệ — không
> phải tính gì thêm.

### Hai ràng buộc của Warcraft, không phải của map

> **Vampiric chỉ ăn với đòn cận chiến. Trueshot chỉ ăn với đòn tầm xa.**

Gán nhầm thì aura **vẫn gắn được, icon vẫn hiện, và không làm gì hết** — không
lỗi, không báo, boss chỉ yếu đi một cách khó hiểu.

Nên `vampiric` chỉ nằm trên bốn con đánh gần *(`Hmkg` `Obla` `Otch` `Npbm`)* và
`trueshot` chỉ trên bốn con đánh xa *(`Hamg` `Emoo` `Hblm` `Nfir`)*. Ba cái còn
lại ăn với cả hai nên rải tự do.

**Nhưng bảng đó không tự chứng minh được.** `applyAura()` đo lại bằng
`IsUnitType(u, UNIT_TYPE_RANGED_ATTACKER)` và ghi vết nếu lệch:

```
boss: r8 aura 'vampiric' can don CAN CHIEN ma con nay danh XA -- se khong an gi
```

Cũng **không cho `vampiric`** lên con đã có cơ chế `lifesteal` *(r5 · r11 · r15 ·
r17)* — hai lớp hút máu chồng nhau thì lớp thứ hai không đọc ra được.

### Ba chỗ dễ hỏng im lặng, cả ba đều ghi vết

| | Triệu chứng nếu không bắt |
|---|---|
| **Mã ability sai** | `UnitAddAbility` trả `false` — không ném lỗi, không báo gì |
| **Quên đặt bậc** | ability vào ở **bậc 0**, và bậc 0 không có tác dụng nào |
| **Sai loại đòn đánh** | aura tồn tại, icon hiện, không làm gì |

Mã ability **dò chứ không gõ** — `abils` là danh sách ứng cử viên, thử lần lượt
rồi ghi vết cái nào trúng. Chỉ `AUav` `AOae` `AEar` là **đã dùng thật** trong map
này *(hút máu của tu chính, `A003`, `A009`)*; hai mã còn lại chưa, nên chúng có
bản dự phòng.

### Báo ra chữ

```
[He Thong] Tien De Kim Than da giang the.
[He Thong] Hao quang: Than Xa   Don tam xa cua boss manh hon.
```

Không báo thì hào quang là một hệ số **vô hình**: người chơi thua mà không biết
vì sao. Cùng lý lẽ với [tu chính](dot-quai.md#bốn-lớp-báo-và-chỉ-một-lớp-tra-cứu-được)
— một lớp có thật nhưng không đọc được thì không dùng để ra quyết định được.

> ## Phép đo bỏ sót các lớp nhân sát thương — vá 2026-09-19
>
> `measureParty()` chỉ lấy `(DMG_BASE + chỉ số)`, trong khi **đòn đánh thật** còn
> nhân thêm `%Kiếm` và Pháp Khí **Hoả Vũ** — `onDamaged()` áp cả hai.
>
> Hệ quả ngược đời: **càng mua Trang Bị thì boss càng dễ.** Ước lượng đứng yên
> trong khi sản lượng thật leo lên, nên máu boss hụt lại đúng bằng phần đó. Không
> ai thấy được, vì boss vẫn "có máu theo đội" — chỉ là sai hệ số.
>
> Đã vá: nhân `(1 + gearDmgPct + relicVal)` vào `hit`, đúng thứ tự `onDamaged()`
> dùng.
>
> **Và bị động cộng % mỗi đòn giờ tính riêng** khỏi `BOSS_SKILL_SHARE`.
> `BOSS_SKILL_SHARE` là ước lượng cho phần **chủ động** (bấm nút); Thiêu Thiên
> của Hvwd thì **đọc được** từ bậc kỹ năng, không phải đoán. Gộp vào một hằng số
> chung thì Hart và Hvwd phải dùng chung một con số mà sản lượng thật khác nhau.
>
> `CFG.BOSS_DPS_PASSIVE_FX = { "burn" }` — **không** có `cleave`: Chém Lan văng
> sang con *bên cạnh*, mà boss đứng một mình nên nó cộng `0`. Gộp vào là boss
> thành quá dày máu cho Hart.
>
> Đo được trước khi vá — Hvwd một mình, cảnh giới 20, **không Trang Bị**:
>
> ```
> boss: r16 Hblm -- 1 hero, dps 20456 -> mau 818244
> boss: r16 CHET sau 30.0s (thiet ke 40s) -- lech -25%
> ```
>
> Sản lượng thật gấp `40/30 = 1.33` lần ước lượng — khớp đúng phần Thiêu Thiên
> (`+30%` mỗi đòn) mà phép đo bỏ sót.

> ## Viết lại toàn bộ — 2026-09-17
>
> **Boss là hero, không bay, và không lấy chỉ số từ đường cong quái.**
>
> | | Cũ | Nay |
> |---|---|---|
> | Loại unit | `CFG.MOB_UNIT` — cõi 4 là Frost Wyrm, **biết bay**, không phải hero | 20 hero đi bộ, mỗi cảnh giới một con |
> | Chỉ số | `×80` EHP / `×3` sát thương trên đường cong quái | **Đo đội** lúc xuất hiện |
> | Kỹ năng | không có | 8 cơ chế, mỗi con 1–4 |
>
> **Lỗi đã đo, và nó không riêng gì boss:** Tu Vi cộng đều cả ba chỉ số, mà
> `1 Agi = 1/3 giáp`. Cuối ván hero có **8,070 giáp** → giảm **99.79%** sát
> thương. Boss đánh 2,036 chỉ còn **4 máu**. Mọi con quái trong map đều vậy.
>
> Nên boss tính theo **máu hiệu dụng** `máu / (1 − giảm)`, và đòn của nó luôn
> hạ một hero đứng yên trong 12 đòn dù giáp bao nhiêu.
>
> Hai mươi bản thiết kế: **[danh sách](boss/README.md)** — mỗi con một file.


> **Trạng thái:** Khung đã cài — **thân boss chưa có**
> **Cập nhật:** 2026-09-19
> **Code:** [3_boss.lua](../../src/3_battle/3_boss.lua) ·
> [2_wave.lua](../../src/3_battle/2_wave.lua)
> **Khoá CFG:** `BOSSES` `BOSS_MECH` `BOSS_SECONDS` `BOSS_HITS_TO_KILL` `BOSS_SCALE` `BOSS_DPS_FACTOR` `BOSS_SKILL_SHARE` `REWARD_BOSS_*`

> **Viết lại 2026-09-19.** Trang này từng tả hệ chỉ số cũ — boss mạnh gấp
> `BOSS_EHP` lần lính cùng stage — và một danh sách khoá `BOSS_CC_RESIST` /
> `BOSS_PHASES` / `BOSS_ENRAGE_TIME` "sẽ làm". **Không khoá nào trong số đó còn
> tồn tại.** Hệ hiện tại **đo sức mạnh thật của đội** rồi suy ngược ra chỉ số
> boss, và các cơ chế nằm trong `CFG.BOSS_MECH`.
>
> **Đã cài tới đâu.** Stage thứ **5** của mỗi cảnh giới (`5r`, tức 5 · 10 · …
> · 100) sinh đúng một con từ `CFG.BOSSES` — 20 dòng, mỗi cảnh giới một unit
> hero riêng, to hơn và đỏ hơn. Hạ xong rơi Linh Khí + Gỗ + 3 lượt Cơ Duyên,
> cả đội cùng nhận. Hạ boss stage 100 là thắng.
> **Xem kèm:** [dot-quai.md](dot-quai.md) ·
> [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md)

## Nó là gì

Hai mươi nút thắt. Phe địch tu tới **viên mãn** một cảnh giới rồi mới độ kiếp
sang cảnh giới sau — và người chơi phải chặn bằng được ở đúng khoảnh khắc đó.

Boss là chỗ duy nhất trong cả 100 stage mà nhịp game đổi hẳn: không còn 50 con
chạy vào, chỉ còn một thân. Mọi kỹ năng AoE trở nên vô dụng, mọi kỹ năng đơn mục
tiêu bỗng đáng giá. Đó là mục đích — nó ép người chơi xây một bộ kỹ năng không
chỉ biết dọn đám đông.

## Luật

**L1. Boss chiếm trọn stage thứ 5 của cảnh giới, một mình.**
`TIERS_PER_REALM = 4` tầng lính + 1 boss = 5 stage mỗi cảnh giới, nên boss nằm ở
stage `5r`. Không lính thường, không tinh anh. Người chơi vừa dọn xong tầng viên
mãn, màn hình lặng đi, rồi boss bước ra.

**L2. Chỉ số boss ĐO TỪ ĐỘI, không suy từ đường cong quái.**

```lua
dps, ehpAvg, n = measureParty()      -- hoả lực và máu hiệu dụng THẬT
máu boss   = dps    × BOSS_SECONDS      (40)
sát thương = ehpAvg ÷ BOSS_HITS_TO_KILL (12)
```

Nghĩa là **mọi trận boss dài đúng 40 giây hoả lực cả đội**, ở mọi cảnh giới và
với mọi cách chơi — người farm kỹ và người chơi ẩu đều gặp một trận 40 giây.

Đây là bài học phải trả giá mới có. Bản cũ suy chỉ số từ **cảnh giới**; đo lại
thì ở cảnh giới 16 chỉ số thật của hero là **30 105** mà phần đến từ cảnh giới
chỉ **511** — **1,7 %**. Trang bị và kỹ năng chiếm 98,3 %, gấp 59 lần. Một
con boss suy từ cảnh giới vì thế hoặc vô hại hoặc bất khả thi, tuỳ người chơi
farm nhiều hay ít.

**Không nhân thêm theo số người.** `dps` ở trên đã là tổng của cả đội rồi; nhân
hai lần là phạt người chơi vì rủ được bạn.

**L3. Sát thương boss là số THÔ, và giáp boss bị ép về 0.**
`ehpAvg` là **máu hiệu dụng** — đã chia cho phần giảm từ giáp. Nếu còn để boss
có giáp nữa thì giáp bị đếm hai lần. Cuối ván hero có 8 070 giáp (giảm 99,79 %),
nên đòn boss chạm tới chỉ còn 4 máu.
Vì vậy `BlzSetUnitArmor(u, 0.0)` — xem
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md).

**L4. Mối đe doạ nằm ở CƠ CHẾ, không ở đòn thường.**
Mỗi con boss khai một danh sách `mech` trong `CFG.BOSSES`, lấy từ `CFG.BOSS_MECH`:

| Cơ chế | Làm gì | Số |
|---|---|---|
| `slam` | Chấn địa: vẽ vòng, chờ rồi nổ | `cd 9s` · `cast 2s` · `radius 600` · `factor 10` |
| `charge` | Lao tới hero **xa nhất** | `cd 11s` · `factor 3` |
| `summon` | Triệu thuộc hạ | `cd 20s` · `count 4` |
| `shield` | Khiên = 12 % máu tối đa | `cd 15s` · `ratio 0.12` |
| `lifesteal` | Hút lại % sát thương gây ra | `ratio 0.25` |
| `reflect` | Phản % sát thương nhận | `ratio 0.15` |
| `shred` | Mỗi đòn trừ 2 % giáp **hiện có** | `perHit 0.02` |
| `enrage` | Dưới 30 % máu thì ×1.60 sát thương | `at 0.30` · `dmg 1.60` |

Cho boss đánh thường nặng là thiết kế lười: người chơi không có gì để đọc, không
có gì để né, chỉ có so sánh hai con số máu. Sát thương phải đến từ thứ **báo
trước được** — `slam` có vòng và có 2 giây chuẩn bị, đúng vì lý do đó.

**L5. Phát cuồng kích theo NGƯỠNG MÁU, không theo đồng hồ.**
`BOSS_MECH.enrage = { at = 0.30, dmg = 1.60 }` — xuống dưới 30 % máu thì sát
thương ×1.60, một lần, không cộng dồn.

Theo đồng hồ thì đội chơi đúng mà chẳng may kéo dài vẫn bị phạt. Theo ngưỡng
máu thì nó là **giai đoạn hai của trận**, ai cũng gặp, và gặp đúng lúc trận sắp
kết thúc — chỗ mà một cú sai còn sửa được.

**L6. `charge` chỉ nhắm hero ĐANG Ở TRONG TRẬN.**
Lao tới một người đang đứng ở nhà chính là con boss bay nửa bản đồ và trận tự
giải tán. Bán kính giới hạn bằng dây xích của chính nó.

**L7. Boss chạm nhà chính là thua ngay.**
Không trừ mạng — không có cơ chế mạng nào cả
([ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md) đã bị lật). Sát thương
boss tính theo máu hiệu dụng của **hero**, mà nhà chính thì dai hơn hero nhiều,
nên nhà không đổ trong một đòn — nhưng cũng không cầm được lâu.

**L8. Hạ boss stage 100 là thắng.**
Điều kiện thắng duy nhất của map.

## Hai mươi con boss

Mỗi cảnh giới một con, **cần unit type riêng trong Object Editor** — khác lính,
boss không tái dùng model được. 20 unit type.

Tên chưa đặt. Ràng buộc khi đặt: tên hiện trong game phải **không dấu**, cùng lý
do với tên cảnh giới ([canh-gioi.md](../03-du-lieu/canh-gioi.md)).

Kỹ năng leo thang theo cõi — mỗi cõi thêm một tầng phức tạp, để người chơi học
dần chứ không bị ném vào một trận boss ba cơ chế ngay từ Phàm Nhân:

| Cõi | Boss | Số kỹ năng | Kiểu cơ chế |
|---|---|---|---|
| Phàm (1–5) | 5 | 1 | Một chiêu đơn giản, báo trước rõ. Dạy người chơi khái niệm "né" |
| Yêu (6–10) | 5 | 2 | Thêm triệu hồi hoặc vùng gây hại đứng yên |
| Tiên (11–15) | 5 | 2 + thụ động | Thêm một thụ động phải xử lý (hồi máu, phản đòn, giáp cộng dồn) |
| Thần (16–20) | 5 | 3 + thụ động | Cơ chế chồng nhau, giai đoạn 3 đổi hẳn cách đánh |

**Đừng thiết kế cả 20 con trước khi chơi thử con thứ nhất.** Làm boss cảnh giới
1, đánh thử, rồi mới làm tiếp. Hai mươi bản thiết kế viết một lượt trên giấy thì
19 con sẽ phải viết lại sau trận thử đầu tiên.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `BOSS_SECONDS` | Trận boss dài mấy giây hoả lực cả đội | `40`. **Đây là nút chỉnh độ dài mọi trận boss cùng lúc** |
| `BOSS_HITS_TO_KILL` | Boss hạ một hero đứng yên trong mấy đòn | `12`. Nhỏ hơn = boss đánh đau hơn |
| `BOSS_DPS_FACTOR` | Hệ số hiệu chỉnh phép đo hoả lực | `1.0`. Chỉnh khi trận thật lệch hẳn so với 40 giây |
| `BOSS_SKILL_SHARE` | Kỹ năng đóng góp thêm bao nhiêu vào hoả lực ước tính | `1.0` = kỹ năng cộng thêm 100 % so với đòn thường |
| `BOSS_ATTACKS_FALLBACK` | Đòn/giây khi không đọc được hồi chiêu thật | `1.0`. Có `API.trace` khi phải lùi về số này |
| `BOSS_SCALE` | Cỡ model | `2.2`. Thuần hình ảnh, nhưng là thứ báo "đây là boss" trước cả thanh máu |
| `BOSS_MECH` | Bảng số của 8 cơ chế | Xem L4 |
| `BOSSES` | Bảng 20 dòng `{ r, vi, en, unit, mech }` | Đúng 20 dòng, khớp thứ tự `REALMS`. Id phải qua `id()` — [ADR 0006](../05-quyet-dinh/0006-fourcc-tra-hai-gia-tri.md) |
| `REWARD_BOSS_QI` `REWARD_BOSS_LUMBER` | Boss rơi ra | `100` + `5`, **phẳng** — không theo cảnh giới — [kinh-te.md](kinh-te.md) |
| `FORTUNE_BOSS` | Số lượt Cơ Duyên boss cho | `3` *(tinh anh cho `1`)* — [quay-thuong.md](quay-thuong.md) |

**Đã xoá 2026-09-19** vì không file nào đọc: `BOSS_ENRAGE_AT`, `BOSS_ENRAGE_DMG`,
`BOSS_SKILL_CD`, `BOSS_SKILL_RADIUS`, `BOSS_SKILL_FACTOR`, `BOSS_LIFESTEAL` —
tất cả đã chuyển vào `CFG.BOSS_MECH`. Chúng nằm lại một mình sau đợt chuyển, và
**trang này đọc chúng rồi tả cơ chế sai theo** suốt từ đó.

**Chưa bao giờ tồn tại**, dù bản cũ của trang này nhắc tới như thể sắp làm:
`BOSS_CC_RESIST` *(kháng khống chế)*, `BOSS_PHASES` *(đổi giai đoạn theo mốc
máu)*, `BOSS_ARMOR_BONUS`. Nếu muốn làm thì xem mục **Chưa làm**.

## Ràng buộc kỹ thuật

**Thanh máu boss phải tự vẽ.** Warcraft III không có thanh máu boss sẵn. Hoặc
`BlzCreateFrame` như [3_skillframe.lua](../../src/4_ui/3_skillframe.lua) đã làm,
hoặc dùng multiboard, hoặc chấp nhận chỉ có thanh máu nhỏ trên đầu unit. Cái thứ
ba là chấp nhận được ở bản đầu — đừng chặn hệ boss vì cái thanh máu.

**Kháng khống chế không có native.** `BOSS_CC_RESIST` phải tự cài: bắt
`EVENT_PLAYER_UNIT_SPELL_EFFECT`, và nếu mục tiêu là boss thì rút ngắn thời gian
hiệu ứng. Với kỹ năng gốc của Warcraft III thì không rút được — phải nhân đôi
ability trong Object Editor và đặt thời gian riêng cho bản dùng lên boss, hoặc
gỡ buff sớm bằng `UnitRemoveAbility`. Việc này lâu hơn vẻ ngoài của nó.

**Đổi giai đoạn phải hoãn.** Mốc máu bắt bằng sự kiện damage; triệu hồi và thêm
ability ngay trong đó là sửa trạng thái engine từ trong sự kiện của engine. Hoãn
bằng `API.after(0.0, ...)`.
[ADR 0005](../05-quyet-dinh/0005-hoan-thao-tac-quay-hang.md)

**Mốc giai đoạn phải có cờ đã-chạy.** Sự kiện damage bắn nhiều lần quanh ngưỡng
70 %; không đánh dấu thì boss triệu thuộc hạ mỗi khung hình.

**Boss là unit thường, không nên là hero.** Hero thì dính `LOCK_HERO_XP`, dính
tính lại máu theo chỉ số, dính hồi sinh — đúng ba thứ đã phải xử lý cho nhà chính
([nha-chinh.md](nha-chinh.md)). Nếu vẫn muốn boss là hero (để có thanh máu và ô
chân dung riêng) thì phải làm lại y hệt những xử lý đó.

## Chưa làm

- **Kỹ năng riêng cho từng con.** 20 unit hero thì đã có; tám cơ chế dùng
  chung ở `BOSS_MECH` cũng đã có. Cái thiếu là kỹ năng *chỉ một con mới có*.
- **L4 kháng khống chế, L5 đổi giai đoạn** — chưa có dòng nào. (L6 phát cuồng
  thì xong rồi: `BOSS_MECH.enrage`.)
- Thanh máu boss, và một thanh **niệm** cho Chấn Địa — hiện chỉ có vòng tròn
  và một dòng chữ.
- Chuyện gì xảy ra nếu cả đội chết lúc đang đánh boss. Hiện chưa có hồi sinh
  hero.
- Màn kết sau khi hạ boss stage 100. Hiện chỉ có một dòng `win_final` rồi
  `CustomVictoryBJ`.

Phần thưởng thì **đã có**: `REWARD_BOSS_QI` (100 Linh Khí) + `REWARD_BOSS_LUMBER`
(5 Gỗ), **phẳng**, chia đều cho cả đội
([ADR 0013](../05-quyet-dinh/0013-thuong-chia-deu-cho-moi-nguoi.md)).
