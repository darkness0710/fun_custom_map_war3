# Các bước thực hiện

> **Cập nhật:** 2026-09-17

Làm từng bước một. Mỗi bước phải **chạy được và kiểm được** trước khi sang bước
sau — không dựng ba tầng rồi mới bật game lên xem.

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
- **Cơ Duyên có ngắt nhịp không.** Khung mở **ngay** khi tinh anh chết, giữa
  lúc còn quái — vui hay phiền thì phải nhìn mới biết.
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

## ⏸ Bước 7b — Kỹ năng cho Hvwd và Hkal

**Hart xong.** Bảy kỹ năng đủ vỏ lẫn ruột: 10 bậc, hiệu ứng thật, và từ 2026-09-16
có tên riêng, vị trí ô, tooltip 10 bậc — sinh bằng
[w3skill.py](../w3skill.py) từ `CFG.SKILLS`, nên tooltip không thể nói khác bảng
phím R.

**Hvwd và Hkal vẫn trống, và từ 2026-09-19 đã khoá.** `locked = true` nên chúng
không ra bảng chọn nữa — trước đó chọn được nhưng **không có kỹ năng nào**.
Thiết kế cũ đã xoá để làm lại — [thiet-ke-hero.md](02-he-thong/thiet-ke-hero.md).
Mở lại chỉ là bỏ cờ đó đi.

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

## ⬜ Bước 8 — Tu chính

4 tầng của một cảnh giới hiện **giống hệt nhau** — chỉ số chỉ nhích ×1.054 suốt
4 tầng. Bảng tu chính ở
[02-he-thong/dot-quai.md](02-he-thong/dot-quai.md#tu-chính) còn là phác thảo,
chưa có số và chưa có khoá `CFG` nào.

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
