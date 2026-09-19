# Các bước thực hiện

> **Cập nhật:** 2026-09-20

Làm từng bước một. Mỗi bước phải **chạy được và kiểm được** trước khi sang bước
sau — không dựng ba tầng rồi mới bật game lên xem.

---

# 📌 Còn treo — đọc cái này trước

> **Chốt ngày 2026-09-20.** Danh sách sống: làm xong thì **xoá dòng**, đừng để
> lại. Một dòng "chưa làm" còn nằm sau khi đã làm xong thì lần sau không ai tin
> cả danh sách nữa.

## 1. Một ván đo — đáng giá hơn mọi thứ bên dưới

Rất nhiều con số trong map là **con số đầu**, chưa ai đo trong một ván thật.
Công cụ đo đã dựng xong và đang chạy tốt; thiếu đúng dữ liệu.

**Chơi solo tới stage 10, rồi đọc:**

| Ở đâu | Dòng | Nói lên gì |
|---|---|---|
| Bảng tổng kết | `Thoi gian` · `ha N quai` | Một wave mất bao lâu thật |
| File vết | `boss: rN CHET sau Xs (thiet ke 40s)` | Lệch bao nhiêu sau khi vá `measureParty` |

**Wave 1 đang lê thê:** `7 200` EHP ÷ `32` sát thương = **225 đòn**, ~2.5–3 phút.
Núm duy nhất nên vặn là `MOB_EHP_BASE` — nhưng **đo trước**. Vặn theo cảm giác
sau ba phút chơi thì dễ vặn quá tay.

## 2. Tám chỗ chưa chứng minh — một ván là trả lời hết

File vết **bị ghi đè mỗi phiên** — đọc trước khi khởi động lại.

| Chỗ | Dòng cần tìm | Nếu sai thì sao |
|---|---|---|
| 20 mã `MOB_UNIT` | `wave: do 20 mau linh -- N ma sai, N con bay` | Lùi về `hfoo`, wave vẫn chạy |
| `whwd` Healing Ward | `shop: ... ma sai` | Không mua được |
| Cọc hồi `2%/giây` | *(nhìn bằng mắt)* | Đặt ở cảnh giới 1, rồi `-lc 10` đặt lại. **Số không đổi = tài liệu sai** |
| Icon thẻ Gỗ | `fortune: icon lumber = ...` | Ra cái áo giáp, không hợp nghĩa |
| Autocast Thiêu Thiên | `order: pid N phat lenh 852xxx` | Bấm `E` hai lần, ghi số vào `CFG.BURN_ORDER` |
| Hào quang boss | `aura '...' can don CAN CHIEN ma con nay danh XA` | Aura im lặng không làm gì |
| `A016` Brilliance | `skill: khong co hang so ...HAB1` | Tooltip lùi về "bậc N" |
| `A009` Trueshot `Ear1` | như trên, `...EAR1` | như trên |

## 3. Hai chỗ cần World Editor

**`A010` Hồi Xuân — hồi máu gốc vẫn chạy chồng lên Lua.** Không có hằng số
`ABILITY_RLF_*` nào cho `ACr2` *(đã đo, không phải chưa tìm)*. Cách tắt:

> Mở `A010` → đặt `Data - Hit Points Gained` **một giá trị bất kỳ** → Lưu → đóng
> WE → `python w3obj.py dump` sẽ in ra **mã trường 4 ký tự** → đưa vào
> `SKILL_ZERO_BASE` qua `ConvertAbilityRealLevelField`.

**`A012` Nguyệt Nhận — mất hoạt ảnh glaive bay vòng.** Đang tính bằng Lua. Muốn
lấy lại hoạt ảnh thì đặt `ua1w = mbounce` cho `H002`/`H003` — **nhưng phải bỏ
`fx = "bounce"`**, để cả hai là sát thương nhân đôi.

## 4. Chưa làm

| | Ghi chú |
|---|---|
| **Sự kiện thương nhân** | Ý của chủ dự án. Đứng cạnh nhà 60 giây sau khi dọn wave, bán giảm giá. Dùng lại nguyên `CFG.SHOP` + hệ số + đồng hồ. **Rẻ nhất, lấp lỗ thật**: vàng hiện chỉ có một chỗ tiêu, và shop là menu tĩnh không bao giờ tạo ra khoảnh khắc |
| **Lôi Kiếp** | Đã thiết kế, đã có chỗ cắm — mốc thứ hai của `WAVE_REST` |
| **6 mẫu lính mỗi cõi** | `MOB_UNIT` giờ là 20 unit gốc WC3, đổi mỗi cảnh giới. Muốn mẫu tự vẽ thì đây là chỗ |
| **25 block** | Hoãn có chủ ý ([ADR 0014](05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md)). Đừng động tới cho tới khi trên xong |
| **Màn kết nâng cao** | Bản đơn giản đã xong. Ba hướng nếu muốn hơn: camera bay qua nhà, xếp hạng ba người, ghi kỷ lục ra `CustomMapData` |

## 5. Đã quyết — đừng mở lại

| | Quyết định |
|---|---|
| **Lọ hồi máu phẳng** | `250` máu không scale; cảnh giới 20 chỉ hồi `1%`. **Để yên** — lọ rẻ `5` / cọc đắt `50` là đường tiến hoá hợp lý. Mô tả đã ghi rõ con số nên nó không nói dối |
| **Xổ số chẵn/lẻ** | Bỏ. Cơ Duyên đã là hệ cờ bạc; cược vàng giữa người chơi tạo ra người tụt lại vì **xui**, không phải vì chơi dở |
| **`A012` trên Hkal** | Chưa hợp lý, chấp nhận tạm. Đổi là thay một dòng |
| **Hvwd/Hkal `locked`** | Đã mở hết. Cơ chế `locked` giữ lại cho hero thứ tư |

---

## ✅ Bước 1 — Nền: kích thước, người chơi, lưới

**Xong.**

| Việc | Ở đâu |
|---|---|
| Đo map size thật từ `war3map.w3e` | [04-map/kich-thuoc.md](04-map/kich-thuoc.md) |
| 3 người chơi + 1 phe địch, quan hệ đồng minh | [1_player.lua](../src/2_player/1_player.lua) |
| Lưới 5×5 tự chia theo vùng chơi được | [4_geometry.lua](../src/1_core/4_geometry.lua) |

**Cách kiểm:** `python build.py`, vào map. Với `CFG.DEBUG = true` sẽ thấy bảng số
lưới in ra chat (đối chiếu với [04-map/luoi-25-o.md](04-map/luoi-25-o.md)) và 25
chấm vàng ping đúng tâm 25 block.

---

## ✅ Bước 2b — Nhà chính & vùng địch

**Xong.** Vùng `MyHouseRegion` và `MyEmenyRegion` đã có trong map.

Chi tiết: [02-he-thong/nha-chinh.md](02-he-thong/nha-chinh.md).

**Cách kiểm:** đọc khối `=== Vung & nha chinh ===` lúc vào map (cần `CFG.DEBUG`).
Nó in danh sách vùng WE nhìn thấy, toạ độ nhà, nhà rơi vào block nào, máu đặt
được chưa.

Vùng `MyTarvenRegion` không còn dùng tới; xoá trong World Editor lúc nào cũng được.

---

## ✅ Bước 5 — Đợt quái

**Đã cài — chưa chơi thử.** [2_wave.lua](../src/3_battle/2_wave.lua).

Làm xong, theo đúng thứ tự đã định:

1. ✅ Bộ đếm `stage` + đồng hồ wave, kèm lệnh dev `-wave <stage>`.
2. ✅ Sinh `WAVE_MOB_COUNT` lính, đi tới nhà, phát lại lệnh mỗi `WAVE_TICK` giây.
3. ✅ Áp đường cong chỉ số — EHP, giáp, sát thương, nhân theo số người.
4. ✅ Tinh anh và boss (chỉ số + tên + thưởng).
5. ✅ Tên quái theo cảnh giới + tầng, dòng báo thành phần đợt.
6. ✅ Kinh tế **phẳng**: `REWARD_*`, ba đồng tiền Linh Khí · Vàng · Gỗ.
7. ✅ Máu nhà tính lại mỗi đợt theo `HOUSE_HP_HITS`.

Hai câu hỏi từng chặn bước này **đã quyết**:

- Nhà chính đếm máu hay đếm mạng → **đếm máu**, [ADR 0011](05-quyet-dinh/0011-nha-chinh-dem-mang.md)
  bị lật.
- Sức mạnh người chơi tăng bằng gì → Tu Vi + Kỹ Năng + Cơ Duyên đã cài; Trang
  Bị và Pháp Khí đang khoá (xem Bước 7).

**Chưa làm trong bước này:** tu chính (`MODIFIERS`), 24 mẫu lính, thân boss.
Xem [02-he-thong/dot-quai.md](02-he-thong/dot-quai.md#chưa-làm).

---

## 🔨 Bước 6 — Chơi thử, rồi cân bằng

**Đây là việc tiếp theo, và không có gì thay thế được nó.**

Mọi con số trong [03-du-lieu/](03-du-lieu/) là suy luận — **chưa ai chơi thử một
giây nào**. Ba chỗ dễ sai nhất, theo thứ tự:

1. **DPS thật của hero ở stage 1.** Cả đường cong dựng trên phỏng đoán ~60.
2. **Thời gian quái đi bộ từ vùng địch tới nhà.** Đã đo — xem
   [phan-vung.md](02-he-thong/phan-vung.md). Không còn ràng buộc `WAVE_TIME`
   *(đồng hồ đã bỏ)*, nhưng nó vẫn là sàn thời gian của một đợt.
3. **`MOB_EHP_BASE`** — nút chỉnh độ khó tổng thể.

Cách đo: dùng `-wave N` nhảy tới stage 1, 25, 50, 75, 100, bấm giờ xem hạ một
đợt mất bao lâu. Ba mốc đó phải **gần bằng nhau** — đường cong quái và đường
cong sức mạnh người chơi đi song song thì thời gian dọn một đợt mới đứng yên.
Lệch là **công thức sai — đừng chỉnh số để che**.

Hai thứ từng chặn bước này **đã xong**: cả bảy ability đã có `Stats - Levels =
10`, và `CFG.SKILL_DATA_LIVE` đã bật — sát thương ăn theo chỉ số thật qua
[7_effect.lua](../src/2_player/7_effect.lua).

Những thứ mới cài, chưa ai nhìn thấy chạy:

- **Ba đồng tiền có thật sự tách nhau không** — hay người chơi vẫn chỉ nhìn một
  thanh vàng. [ADR 0015](05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md)
- **Quái bám đúng đường cong Tu Vi chưa.** Đây là thứ đáng đo nhất: nếu đúng thì
  "mấy phát một con" phải **không đổi** từ stage 1 tới 100. Dùng `-wave N` nhảy
  tới 1, 25, 50, 75, 100 rồi đếm.
  [ADR 0020](05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md)
- **Cơ Duyên có còn ngắt nhịp không.** Từ 2026-09-20 khung mở lúc **dọn sạch
  đợt** chứ không lúc tinh anh chết, và gom cả wave vào một lần. Phải nhìn mới
  biết gom như thế có thành một đống quá dài hay không.
- **Ba máy có rút cùng bộ ba thẻ không.** Thẻ sinh trong sự kiện quái chết nên
  *phải* đồng bộ; lệch một lần là lệch cả ván. Chơi thử **hai máy** mới đo được.
- **`-nat oskey`** — hàng số trên có bắt phím không, và có đụng lệnh gọi nhóm
  quân của Warcraft đến mức khó chịu không.

---

## ✅ Bước 7 — Trang Bị & Pháp Khí

[5_gear.lua](../src/2_player/5_gear.lua) ·
[6_relic.lua](../src/2_player/6_relic.lua) — **cả hai đã mở.**
`GEAR_LOCKED` đã xoá hẳn; `RELIC_LOCKED = false` từ 2026-09-19 khi
`CFG.RELIC` có bốn món — [phap-khi.md](02-he-thong/phap-khi.md).

Phần dưới giữ lại vì lý do khoá lúc đó vẫn đáng đọc: **mở khoá không
đơn giản là đặt `false`**, phải có nội dung trước.

**Vì sao khoá, và vì sao mở lại không đơn giản là đặt `false`:**

| | Vướng cái gì |
|---|---|
| **Trang Bị** | Giá `147 × 1.134ⁿ` suy từ thu nhập **mũ** cũ. Với 10 000 Linh Khí cả ván thì trọn 60 lần nâng tốn **974 606** — mua được 18/60. Mà Tu Vi đã ăn 9 500/10 000, nên thực tế chỉ còn 500 → **2 lần nâng cả ván** |
| **Pháp Khí** | Chưa có nội dung. Ngân sách dành sẵn **190 Gỗ** (260 kiếm được − 70 kỹ năng tiêu) |

**Và câu hỏi đã đổi.** Trước: "có đủ ×8 và ×2.5 cho hợp đồng ×967 không". Giờ:
**"cho vượt lên bao nhiêu là vừa"** — vì Tu Vi một mình đã bám đúng quái
([ADR 0020](05-quyet-dinh/0020-duong-cong-quai-bam-theo-tu-vi.md)).

> ⚠ **Đá Huyền Thiết đang dồn vô ích.** Cơ Duyên rơi 10 đá mỗi lượt, cả ván
> **1 400**, mà ô tiêu duy nhất là Trang Bị. Càng để lâu càng giống Tinh Thạch —
> một con số chỉ tăng chứ không bao giờ dùng được. **Mở Trang Bị là việc gấp
> nhất trong bước này.**

Hai quyết định kèm theo:

- **Ba đồng tiền, mỗi đồng một loại quái** —
  [ADR 0015](05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md)
- **Bảng phím R có hai kiểu thân** —
  [ADR 0016](05-quyet-dinh/0016-bang-phim-e-hai-kieu-than.md)

---

## ✅ Bước 7c — Shop, Cơ Duyên, dùng đồ

**Đã cài 2026-09-17 — chưa chơi thử.**

| Hệ | Mã | Làm gì |
|---|---|---|
| **Shop** (thẻ V) | [8_shop.lua](../src/2_player/8_shop.lua) | Hệ duy nhất tiêu **Vàng**, duy nhất bán đồ tiêu hao. Gộp lọ cùng loại vào một ô nên không đầy túi sau sáu lần mua |
| **Cơ Duyên** | [10_fortune.lua](../src/2_player/10_fortune.lua) · [5_fortuneframe.lua](../src/4_ui/5_fortuneframe.lua) | Khung ba cột riêng, mở ngay khi tinh anh/boss chết. Chọn 1 trong 3: đá · chỉ số · vàng |
| **Dùng đồ** | [9_useitem.lua](../src/2_player/9_useitem.lua) | Hàng số trên cạnh Esc, **thêm** vào numpad chứ không thay |

Chi tiết: [quay-thuong.md](02-he-thong/quay-thuong.md) ·
[kinh-te.md](02-he-thong/kinh-te.md).

---

## ⏸ Bước 7b — Kỹ năng cho Hkal

**Hart và Hvwd xong.** Mỗi con bảy kỹ năng đủ vỏ lẫn ruột: 10 bậc, hiệu ứng
thật, tên riêng, vị trí ô, tooltip 10 bậc — sinh bằng
[w3skill.py](../w3skill.py) từ `CFG.SKILLS`, nên tooltip không thể nói khác bảng
phím R.

> **Hvwd mở khoá 2026-09-19.** Bảy kỹ năng, và `A004`/`A006` dùng chung ability
> với Hart. Chi tiết và lý do phân nhóm *"ai giữ con số"*:
> [ky-nang.md](02-he-thong/ky-nang.md#bảy-kỹ-năng-của-hvwd-xạ-thủ).
>
> **Đã chạy xong** `w3obj.py levels … 10` và `w3skill.py gen` — `A008`–`A012`
> giờ có `alev = 10`, tên riêng, tooltip 10 bậc, vị trí ô và phím tắt
> (`A008` Q · `A010` W · `A011` E). `w3obj.py checkall` khớp từng byte.

**Hkal vẫn trống và vẫn khoá.** `locked = true` nên nó không ra bảng chọn —
trước đó chọn được nhưng **không có kỹ năng nào**. Thiết kế cũ đã xoá để làm lại
— [thiet-ke-hero.md](02-he-thong/thiet-ke-hero.md). Mở lại chỉ là bỏ cờ đó đi
sau khi `CFG.SKILLS[id('H003')]` có nội dung.

**Chặn bởi một câu hỏi không phải cân bằng:** bộ mặt của map. Icon và hiệu ứng đều
lấy từ kho có sẵn của Warcraft, nên mỗi kỹ năng trông giống ability gốc mà nó nhân
bản. Chủ dự án dừng để nghĩ.

**Việc phải làm trước khi mở lại:**

- ✅ **`API.heroRecompute`** — đã xong. Mọi chỉ số hero giờ đi qua một cửa duy
  nhất, nên thêm hero mới không sinh ra lỗi giẫm chân như Bất Hoại × Hiệu Lệnh.
- Vào game **nhìn command card của Hart một lần** — xác nhận 7 nút đúng ô, đúng
  tên, tooltip đúng số.
- Gõ `-nat` xem `EVENT_PLAYER_UNIT_DAMAGING` có không — nó quyết định làm được
  kiểu kỹ năng nào (chặn sát thương trước khi vào máu).

---

## ✅ Bước 8 — Tu chính

**Xong 2026-09-19.** 5 tu chính trong `CFG.MODIFIERS`, bốc ngẫu nhiên mỗi stage
thường, kèm **thời tiết** và một **dòng tra cứu** ở khung `R`. Chi tiết:
[dot-quai.md](02-he-thong/dot-quai.md#tu-chính).

---

## ⬜ Bước 2 — Vẽ sông trong World Editor

**Vẫn chưa vẽ.** Quyết định và lý do: [ADR 0004](05-quyet-dinh/0004-song-ve-tay.md).
Bảng toạ độ: [04-map/toa-do-ve-song.md](04-map/toa-do-ve-song.md).

Thứ tự:

1. **Một ngã tư trước**, quanh `(−2 816, −3 072)`. Chừng 10 phút.
2. **Vào game đi bộ quanh đó.** Sông 1 024 đơn vị là cản trở thật hay chỉ là vạch
   kẻ? Block 4 608 đơn vị đi hết mất bao lâu?
3. **Trả lời xong mới vẽ nốt 7 con còn lại.**

Vẽ cả 8 con trước khi biết cảm giác là vẽ mù.

> Bước này không chặn Bước 6 nữa (quái đi thẳng tới nhà, phương án A), nhưng
> đường đi có sông sẽ dài hơn hẳn, nên bảng quãng đường ở
> [phan-vung.md](02-he-thong/phan-vung.md) phải đo lại.

---

## ⬜ Bước 3 — Chặn đường và chỗ qua sông

Sông có nước rồi thì chưa chắc đã chặn được đường — WC3 cho đi qua nước nông. Cần
chốt: sông chặn hoàn toàn, hay lội qua được nhưng chậm? Và nếu chặn thì qua sông
bằng gì — cầu, cổng, hay phải phá.

---

## 🧊 Bước 4 — Phó bản, thí luyện, linh mạch, đấu đài (bản đồ xong, lối chơi để dành)

**Bản đồ đã chốt:** [phan-vung.md](02-he-thong/phan-vung.md).
**Lối chơi vẫn hoãn có chủ ý:** [ADR 0014](05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md).

Đã làm:

- ✅ 25 vùng thật `Blk01..Blk25` trong World Editor — [w3region.py](../w3region.py)
- ✅ Bảng vai trò `CFG.BLOCKS`, bốn loại vùng đã duyệt
- ✅ Lệnh `-vung` xem bản đồ và ping minimap theo màu
- ✅ [ADR 0017](05-quyet-dinh/0017-ten-vung-la-vi-tri-vai-tro-o-cfg.md) — tên vùng là vị trí, vai trò ở CFG

Chưa làm: **toàn bộ lối chơi**. Bốn loại vùng mới có tên và vị trí, không loại
nào có một dòng code. Khi bắt tay vào, làm **một loại** trước rồi chơi thử — đừng
làm cả bốn rồi mới bật game lên xem.

> Ba loại vùng tuỳ chọn là **vòi thứ hai** của ba đồng tiền, và hai trong ba hiện
> chỉ dư 6–9%. Hụt một boss ở cảnh giới 7 là vĩnh viễn thiếu một Pháp Khí — Phó
> Bản là cách gỡ duy nhất.

---

## Quy trình mỗi lần test

```
sửa địa hình trong World Editor  →  Save
sửa code trong src/
python build.py                  ←  luôn là bước cuối
```

Rồi **`python build.py --run`** — đóng gói và chạy thẳng, không qua World Editor.
Hai cái bẫy biến mất ở đó: Ctrl+F9 đóng gói bản trong *bộ nhớ* World Editor chứ
không phải bản trên đĩa, và mỗi lần Save nó sinh lại `war3map.lua` xoá sạch code
vừa chèn.

Nếu vào map mà không thấy dòng `[build x.y.z] code da chay.`, gần như chắc chắn
là quên chạy build. Xem thêm [04-map/dong-goi-map.md](04-map/dong-goi-map.md).
