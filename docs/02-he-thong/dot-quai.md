# Hệ thống: Đợt quái

> **Trạng thái:** Đã cài — **chưa chơi thử**
> **Cập nhật:** 2026-09-16
> **Code:** [2_wave.lua](../../src/3_tran_dau/2_wave.lua)
> **Khoá CFG:** `WAVE_*` `MOB_*` `ELITE_*` `BOSS_*` `SCALE_*` `LINHKHI_*`
> **Xem kèm:** [canh-gioi.md](../03-du-lieu/canh-gioi.md) ·
> [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) · [boss.md](boss.md)

> **Ghi chú khôi phục.** Bản trước của file này bị ghi đè nhầm và không lấy lại
> được. Bản này dựng lại từ những gì các tài liệu khác trích dẫn về nó —
> `canh-gioi.md`, `boss.md`, `duong-cong-suc-manh.md`, ADR 0009–0011 — nên **nhất
> quán với chúng**, nhưng có thể thiếu chi tiết so với bản gốc.

## Nó là gì

100 stage. Phe địch tu từ Phàm Nhân lên Sáng Thế Thần, mỗi cảnh giới 4 tầng rồi
một lần độ kiếp. Người chơi chặn ở từng tầng, và chặn hẳn ở mỗi lần độ kiếp.

## Luật

**L1. Một biến `stage` duy nhất, 1…100.**
Cảnh giới và tầng đều **suy ra** từ nó. Giữ hai biến song song là chúng sẽ lệch
nhau. Công thức ở [canh-gioi.md](../03-du-lieu/canh-gioi.md).

**L2. Một cảnh giới là 5 stage: 4 tầng + 1 boss.**
Số 11 là `TIERS_PER_REALM + 1`, không hard-code ở đâu cả.

**L3. Thành phần wave cố định: 50 lính + 1 tinh anh.**
Không đổi theo số người chơi, không đổi theo cảnh giới. Số lượng cố định thì mọi
thứ khác đoán được: hiệu năng, thời gian dọn, thu nhập.
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

**L4. Boss chiếm trọn stage, một mình.**
Không lính đi kèm. Xem [boss.md](boss.md).

**L5. Có trần số unit sống.**
Đồng hồ wave chạy bất kể wave trước đã dọn chưa — đó là áp lực chính. Nhưng nếu
trên map đã quá `WAVE_MAX_ALIVE` con thì **hoãn** wave mới thay vì chồng thêm.

Đỉnh điểm dự kiến ~300 unit. Warcraft III chịu được, nhưng không có trần thì một
lần vỡ trận sẽ kéo theo dây chuyền và không bao giờ gỡ lại được.

**L2b. Tầng có TÊN, không đánh số.**
`CFG.TIER_NAMES` — **Sơ Kì · Trung Kì · Hậu Kì · Viên Mãn**. "Trúc Cơ Sơ Kì" đọc
ra nghĩa ngay; "Trúc Cơ Tầng 3" thì phải nhớ tầng 3 trên tổng bao nhiêu. Bảng
thiếu phần tử thì `tierLabel()` lui về đánh số — đổi `TIERS_PER_REALM` mà quên
thêm tên thì vẫn chạy, chỉ là tên xấu.

**L6. Tầng đổi *tu chính*, không đổi chỉ số.**
Trong một cảnh giới, chỉ số chỉ nhích ×1.054 suốt 4 tầng — gần như không cảm
thấy. Thứ làm Hậu Kì khác Sơ Kì là **tu chính**, xem phần dưới.

## Nhịp

**Một cảnh giới = 4 tầng có đồng hồ, rồi hai lần dừng hẳn** —
[ADR 0018](../05-quyet-dinh/0018-nghi-giua-hai-canh-gioi.md):

```
tầng 1…10          đồng hồ chạy          ← áp lực, đợt chồng được
tầng 10 dọn sạch → DỪNG đồng hồ          ← nghỉ
     -next       → BOSS
boss chết        → DỪNG đồng hồ          ← nghỉ, tiêu Tinh Thạch vừa rơi
     -next       → cảnh giới sau, tầng 1
```

`WAVE_TIME` theo cõi, không theo stage:

| Cõi | Cảnh giới | Giây/wave | Quãng đường | Vì sao |
|---|---|---|---|---|
| Phàm | 1–5 | **32** | Footman đi 19.9s | Chậm nhất, nên cần nhiều giây nhất |
| Yêu | 6–10 | 28 | Ghoul đi 15.3s | |
| Tiên | 11–15 | **40** | Abomination đi 28.2s | |
| Thần | 16–20 | 45 | Frost Wyrm đi 26.8s | Wave nặng, cần thời gian hồi chiêu |

> **Ràng buộc, không phải số chỉnh tự do:**
> ```
> WAVE_TIME[cõi] > quãng đường/tốc độ + thời gian giết hết một đợt
> ```
> Thiếu vế phải thì map **không bao giờ sạch**, nên `S.alive` không bao giờ về 0,
> nên cả `WAVE_AUTO_NEXT` lẫn `-next` đều chết. Cõi 1 từng đặt 20s trong khi
> quãng đường đã ăn 19.9s — nhánh gọi sớm nằm đó suốt 55 đợt mà không dùng được.
>
> Vì thế cõi 1 (32s) **dài hơn** cõi 2 (28s) dù dễ hơn: `WAVE_TIME` bị chặn dưới
> bởi **tốc độ mẫu lính**, không thuần là độ khó. Đổi `CFG.MOB_UNIT` là phải tính
> lại bảng này.

Tổng: **134 phút** — 121 phút đợt thường + 13 phút boss. Cửa sổ nghỉ do người
chơi điều khiển, gõ `-next` ngay là mất 0 giây.

> **Đây là con số đáng lo nhất của cả thiết kế, và nó vừa nặng thêm 16 phút.**
> Map co-op quá 90 phút là người chơi rời trận, mà mất một người là hỏng cả ván.
>
> Phần tăng đến từ việc sửa `WAVE_TIME` cõi 1 (20→32, +10 phút) — bắt buộc, vì
> không sửa thì cơ chế gọi sớm không dùng được.
>
> Lập luận bênh vực: **134 phút chia thành 20 khối 6–8 phút, mỗi khối có
> mở–thân–kết, đọc rất khác 118 phút một mạch không cho thở.** Nếu chơi thử vẫn
> thấy dài thì chỗ cắt là `TIERS_PER_REALM` 10 → 5, không phải bỏ nhịp nghỉ.
>
> **Đã chọn: gọi wave sớm.** Cài bằng hai cơ chế:
>
> - `WAVE_AUTO_NEXT` — con cuối cùng của wave chết là vào wave sau ngay, sau
>   `WAVE_CLEAR_DELAY` giây để kịp đọc chữ.
> - `-next` — gọi tay. **Chỉ gọi được khi đã dọn sạch**; nếu không thì đó là bỏ
>   qua phần khó của wave này mà vẫn lấy tiền của wave sau.
>
> Đồng hồ **vẫn chạy song song**. Hai cơ chế không thay thế nhau: dọn sạch sớm
> thì vào sớm, dọn không kịp thì quái dồn lại đúng như trước. Áp lực giữ nguyên,
> chỉ mất phần ngồi nhìn đồng hồ.
>
> **Không có thưởng thêm cho việc gọi sớm.** Thu nhập bám đường cong ×967
> ([kinh-te.md](kinh-te.md)); cộng thêm là lệch khỏi chính đường cong đó.
>
> **Lưu tiến độ** vẫn để ngỏ, làm sau nếu 134 phút vẫn quá dài.

## Tu chính

Mỗi tầng trong cảnh giới gắn một **tu chính** — một sửa đổi nhỏ lên cả wave. Đây
là thứ làm 4 tầng khác nhau, vì chỉ số thì gần như đứng yên (L6).

| Tầng | Tu chính | Ảnh hưởng lối chơi |
|---|---|---|
| 1 | *(không)* | Mốc chuẩn của cảnh giới |
| 2 | Nhanh chân | Tốc chạy +25% — ít thời gian phản ứng hơn |
| 3 | Dày da | Giáp +50% — ép dùng sát thương phép |
| 4 | Chia đàn | Ra từ 2 cửa thay vì 1 — không đứng một chỗ chặn được |
| 5 | Hồi phục | Tự hồi máu — ép dồn sát thương, không rỉ rả |
| 6 | Nổ tan | Chết thì gây sát thương vùng — phạt việc đứng chụm |
| 7 | Chắn phép | Kháng phép cao — ép đánh tay |
| 8 | Bầy đàn | Tinh anh thành 3 con, mỗi con 1/3 sức | 
| 9 | Vội vã | `WAVE_TIME` giảm 30% riêng tầng này |
| 10 | **Viên mãn** | Gộp tu chính của tầng 3 và 5 |

Tu chính **chọn từ một bảng chung**, không phải mỗi cảnh giới viết riêng 10 cái.
Nên thêm một tu chính mới là cả 20 cảnh giới cùng có.

> Vì sao tu chính quan trọng hơn chỉ số: một con quái dày gấp rưỡi thì người chơi
> vẫn bấm đúng ngần ấy nút. Một con quái *tự hồi máu* thì buộc phải đổi thứ tự
> bấm. Chỉ cái sau mới là lối chơi.

## Chỉ số

Đường cong ở [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md). Tóm
tắt phần đợt quái cần biết:

| | Khoá | Nhân so với lính thường cùng stage |
|---|---|---|
| Lính | — | ×1 |
| Tinh anh | `ELITE_EHP` `ELITE_DMG` | EHP ×10, sát thương ×2.5 |
| Boss | `BOSS_EHP` `BOSS_DMG` | EHP ×80, sát thương ×3 |

Một wave = `50 + 10 = 60` đơn vị EHP. Boss = 80 — nhỉnh hơn cả wave gộp lại, nên
trận boss dài hơn một wave một chút, nhưng cảm giác hoàn toàn khác vì chỉ có một
mục tiêu.

**Giáp không nằm trong đường cong.** Đường cong sinh ra EHP; máu thật suy ngược ra
từ giáp. Đổi giáp **không** đổi độ khó.
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md)

## Theo số người chơi

**Số lượng cố định, chỉ chỉ số nhân.**
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

| Khoá | Tác dụng | Ràng buộc |
|---|---|---|
| `SCALE_EHP_PER_PLAYER` | EHP lính nhân thêm mỗi người | Phải **< 1.0**. Bằng 1.0 là phạt người chơi vì rủ bạn |
| `SCALE_DMG_PER_PLAYER` | Sát thương nhân thêm | Giữ **nhỏ**. Ba người có gấp ba sát thương, nhưng mỗi người vẫn chỉ có **một** thân — quái đánh đau gấp ba thì ba người chết nhanh như một |
| `SCALE_BOSS_EHP_PER_PLAYER` | Riêng boss | Cao hơn lính: boss một thân, đông người dồn hạ hiệu quả hơn hẳn |
| `SCALE_RECOUNT_EACH_WAVE` | Tính lại `P` mỗi wave | `true` — người thoát giữa chừng không khoá cứng ván của người ở lại |

## Đường đi

**Đang chạy phương án A.** Lưới 25 block và 8 dòng sông
([luoi-25-o.md](../04-map/luoi-25-o.md)) vẫn chưa gắn gì vào đợt quái.

| | Cách | Được | Mất |
|---|---|---|---|
| **A** ✔ | Quái ra ở `MyEmenyRegion`, đi thẳng tới nhà | Đơn giản nhất, đã chạy | Lưới 25 block thành trang trí |
| B | Quái đi theo hành lang giữa các block, sông chặn hai bên | Lưới có ý nghĩa, vị trí đứng quan trọng | Phải vẽ địa hình xong trước |
| C | Nhiều cửa, mỗi cảnh giới đổi cửa | Người chơi phải đọc bản đồ | Chia nhỏ lực lượng 3 người, dễ hỏng |

Nâng lên B khi địa hình xong. Đổi từ A sang B chỉ là đổi điểm sinh và điểm đến,
không đụng đường cong chỉ số.

Điểm sinh xê dịch trong bán kính `SPAWN_JITTER` để 50 con không chồng lên nhau
một chỗ. Cứ `WAVE_TICK` giây phát lại lệnh đi cho mọi con còn sống — quái bị đánh
lạc hướng không tự quay về nhà.

## Tên quái

Mỗi con mang tên **cảnh giới + tầng + loại**, đặt bằng `BlzSetUnitName` lúc sinh.
Dòng báo đợt kể ra cả hai loại, bằng đúng cái tên đang nằm trên con quái:

```
[7/100] Luyen Khi Trung Ki
   50 x Luyen Khi Tang 1 - Tan Tu   +   1 x Luyen Khi Tang 1 - Tinh Anh
```

Tầng nằm trong tên vì quái **dồn lại qua nhiều wave** — đo được: ở stage 6 vẫn
còn 174 con sống. Không có tầng thì cả 5 stage của một cảnh giới trùng tên nhau,
nhìn vào không phân biệt được thế hệ nào với thế hệ nào, mà chúng trả giá thưởng
khác nhau (`S.mobStage` trả theo stage lúc **sinh**). Bảng chuỗi đầy đủ:
[ngon-ngu.md](ngon-ngu.md).

`CFG.MOB_UNIT` hiện là **placeholder**: bốn unit gốc của Warcraft — Footman,
Ghoul, Abomination, Frost Wyrm — một mẫu cho mỗi cõi. Bản thiết kế cần 4 cõi ×
6 mẫu = 24 unit type. **Tên đã đúng; hình dáng thì chưa.**

## Thua

Nhà chính **nhận sát thương bình thường, chết là thua**. Không đếm mạng, không
lọt-trừ-mạng — [ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md) **đã bị lật**.

Máu nhà không cố định được: sát thương địch tăng ×279 qua 100 stage, nên 1 000
máu ở stage 100 chết trong dưới một giây. Thay vào đó máu tính lại **mỗi wave**:

```
máu tối đa = HOUSE_HP_HITS × sát thương một con lính ở stage đó
```

Tỉ lệ sống sót giữ nguyên suốt ván, và cả map chỉ còn **một** con số chỉnh độ
khoan dung. Mỗi wave nhà hồi thêm `HOUSE_REGEN_PER_WAVE` phần máu tối đa — giữ
nguyên tỉ lệ máu đang có rồi cộng thêm, chứ không đặt lại đầy (đặt lại đầy thì
lọt bao nhiêu cũng không sao).

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `WAVE_MOB_COUNT` | Lính mỗi wave | `50`, cố định |
| `WAVE_ELITE_COUNT` | Tinh anh mỗi wave | `1` |
| `WAVE_TIME` | Giây/wave theo cõi | Nút chỉnh **thời lượng ván**, và nó cũng chỉnh DPS cần — hai thứ dính nhau |
| `WAVE_FIRST_DELAY` | Giây trước đợt đầu | Chỉ dùng khi `WAVE_WAIT_FIRST` tắt |
| `WAVE_WAIT_FIRST` | Đợt 1 chờ gọi `-next` | `true` — để kịp nhìn map, mở bảng, nâng kỹ năng trước khi vào trận |
| `WAVE_AUTO_NEXT` `WAVE_CLEAR_DELAY` | Dọn sạch thì vào đợt sau ngay | Đồng hồ **vẫn chạy song song**; hai cơ chế không thay thế nhau |
| `WAVE_MAX_ALIVE` | Trần unit sống, quá thì hoãn wave | ~300. Hoãn việc **sinh**, không hoãn đồng hồ. Chạm thường xuyên = đường cong sai |
| `WAVE_TICK` | Giây giữa hai lần ra lệnh lại cho quái | Quái bị đánh lạc hướng phải quay về nhà |
| `SPAWN_JITTER` | Bán kính xê dịch điểm sinh | Đủ rộng để 50 con không chồng một chỗ |
| `MOB_UNIT` | Mẫu lính mỗi cõi, tra theo `REALMS[r].coi` | **Placeholder** — 4 unit gốc WC3. Thiết kế cần 24 |
| `TIERS_PER_REALM` | `10` | Đổi là đổi tổng stage; mọi thứ suy ra từ nó |

## Chưa làm

- **Chưa chơi thử một giây nào.** Ba chỗ dễ sai nhất: DPS thật của hero ở
  stage 1, thời gian quái đi bộ tới nhà, và `MOB_EHP_BASE`.
- **Tu chính chưa cài.** Bảng ở trên còn là phác thảo: chưa có số, chưa có khoá
  `MODIFIERS` nào trong `CFG`. Hiện 4 tầng của một cảnh giới **chỉ khác nhau ở
  chỉ số** — mà chỉ số chỉ nhích ×1.054 suốt 4 tầng, nên trên thực tế chúng
  giống hệt nhau. Theo chính L6 thì đây là khoảng trống lớn nhất còn lại của hệ
  này: tầng đáng ra phải đổi *cách chơi*, hiện chỉ đổi *cái tên*.
- **6 mẫu lính chưa có** — `MOB_UNIT` mới là 4 unit gốc WC3 làm placeholder.
- **Boss chưa có gì riêng**: cùng mẫu lính, chỉ to hơn và đỏ hơn — xem
  [boss.md](boss.md).
- Đường đi phương án B, khi địa hình xong.
