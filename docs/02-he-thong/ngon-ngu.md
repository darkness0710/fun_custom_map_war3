# Hệ thống: Hai thứ tiếng

> **Trạng thái:** Đã cài, chưa phủ hết
> **Cập nhật:** 2026-09-16
> **Code:** [6_lang.lua](../../src/1_nen/6_lang.lua)
> **Khoá CFG:** `LANG`

Một bộ nguồn, xuất ra được bản tiếng Anh và bản tiếng Việt.

```
python build.py --lang en     # mặc định
python build.py --lang vi
python build.py --lang en --map test2en.w3x
```

`--lang` **không sửa `1_config.lua` trên đĩa** — nó chèn một dòng
`CFG.LANG = "en"` vào cuối khối đã sinh. Nhờ vậy build hai bản khác tiếng không
làm bẩn cây làm việc, và `git diff` không nhảy lên sau mỗi lần build.

## Hai cách, dùng cho hai thứ khác nhau

**`API.t("key")` — chữ cố định của giao diện.** Nằm trong bảng `T` ở
[6_lang.lua](../../src/1_nen/6_lang.lua), một chỗ duy nhất. Nhận thêm tham số
như `string.format`:

```lua
API.t("skill_up", tenKyNang, 5, 10)   -- "Earthshatter reached level 5/10."
```

**`API.pick(tbl)` — tên nằm trong bảng dữ liệu.** Cảnh giới, kỹ năng, hero:

```lua
{ ten = "Pham Nhan", en = "Mortal", coi = 1 }
API.pick(CFG.REALMS[1])      -- "Mortal" hoặc "Pham Nhan"
```

Tên **không tách khỏi bảng dữ liệu** vì nó đi liền với số liệu của chính mục đó.
Tách ra là hai bảng phải giữ đồng bộ bằng tay, và sớm muộn sẽ lệch.

## Thiếu câu thì trả về chính cái key

```lua
API.t("khong_co_cau_nay")   -->  "khong_co_cau_nay"
```

Không trả `nil`, không sập. Một cái khoá lồ lộ trên màn hình thì thấy ngay và
sửa sau lúc nào cũng được; `nil` thì nó nổ giữa trận, ở chỗ không ai ngờ.

`API.langCheck()` chạy lúc vào map, đối chiếu hai bảng và ghi vào file vết:

```
lang: en, hai bang khop nhau
lang: LECH BANG -- vi:skill_up en:panel_foo
```

## Tên quái: 460 tên từ 25 chuỗi

Trước đây quái tên là **"Footman"** — vô nghĩa trong một map tu tiên.

Tên quái ghép từ **tên cảnh giới + tầng + hậu tố theo loại**:

```
<cảnh giới>  <tầng>  -  <hậu tố>
```

| Mảnh | Khoá | en | vi |
|---|---|---|---|
| cảnh giới | `CFG.REALMS[r]` | Qi Refining | Luyen Khi |
| tầng 1–9 | `tier_word` | Tier 3 | Tang 3 |
| tầng 10 | `tier_full` | Perfection | Vien Man |
| lính thường | `mob_suffix` | Cultivator | Tan Tu |
| tinh anh | `elite_suffix` | Elite | Tinh Anh |
| boss | `boss_suffix` | Lord | Ma Ton |

```
Luyen Khi Tang 1 - Tan Tu       Qi Refining Tier 1 - Cultivator
Luyen Khi Tang 1 - Tinh Anh     Qi Refining Tier 1 - Elite
Luyen Khi Vien Man - Tan Tu     Qi Refining Perfection - Cultivator
Luyen Khi - Ma Ton              Qi Refining - Lord
```

20 cảnh giới × 5 stage × 2 loại + 20 boss = **460 tên, sinh ra từ 20 tên cảnh
giới + 5 chuỗi.**

### Vì sao tầng phải nằm trong tên

Không có tầng thì cả 5 stage của một cảnh giới ra **cùng một cái tên**. Mà quái
dồn lại qua nhiều wave — đo được: ở stage 6 vẫn còn 174 con sống — nên trên map
lúc nào cũng có vài thế hệ cùng lúc. Nhìn một con không biết nó thuộc đợt nào,
cũng không biết nó đang trả giá thưởng của stage nào
([`S.mobStage`](../../src/3_tran_dau/2_wave.lua) trả theo stage lúc **sinh**).

Boss không cần tầng: nó là lần độ kiếp **duy nhất** của cảnh giới đó.

### Dòng báo thành phần wave

Một wave có hai loại quái, nên dòng báo phải kể ra cả hai — bằng **đúng cái tên
đang nằm trên con quái**, để đối chiếu được cái nhìn thấy với cái vừa đọc:

```
[7/100] Luyen Khi Trung Ki
   50 x Luyen Khi Tang 1 - Tan Tu   +   1 x Luyen Khi Tang 1 - Tinh Anh
```

Khoá `wave_comp`. Stage boss thay bằng `boss_coming` và một dòng tên boss.

### Đổi tên lúc chạy, không qua Object Editor

`BlzSetUnitName` đổi tên **từng con** lúc sinh, nên không phải tạo unit type nào
trong Object Editor, và đổi tiếng cũng không đụng tới nó.

Thiếu native thì quái giữ tên gốc của **mẫu lính** làm nó — `Footman`, `Ghoul`,
`Abomination`, `Frost Wyrm` theo `CFG.MOB_UNIT`. Đó là lỗi im lặng đúng kiểu ADR
0012, nên [5_natives.lua](../../src/1_nen/5_natives.lua) đo `BlzSetUnitName` và
ghi vào file vết; `-nat` xem lại được trong game.

## Chưa phủ hết

Còn chữ tiếng Việt cứng trong code, chủ yếu là **thông báo dành cho người phát
triển**: dòng vết, báo cáo `-nat`, `-sync`, cảnh báo thiếu native. Cố ý để lại —
chúng dành cho người làm map, không phải người chơi.

Chưa dịch: tên hero (`Hart`/`Hvwd`/`Hkal` là tên riêng, giữ nguyên), vai hero
(`Warrior`/`Shooter`/`Mage` — vốn đã tiếng Anh), và `CFG.HOUSE_NAME`.

`CFG.TIER_VIEN_MAN` **đã bỏ** — tên tầng cuối là chữ hiển thị chứ không phải
tham số, nên nó chuyển sang khoá `tier_full` ở đây. Cùng lý do với
`CFG.PICK_TITLE` trước đó.

**Tooltip của kỹ năng trong command card: đã có bộ sinh, nhưng chỉ một thứ tiếng
mỗi lần.**

[w3skill.py](../../w3skill.py) ghi tên và tooltip 10 bậc vào `war3map.wts` theo
`CFG.LANG`, hoặc theo `--lang` nếu chỉ định.

> ⚠ **`build.py --lang vi` KHÔNG đổi được tooltip.** Nó chỉ chèn `CFG.LANG` vào
> Lua; `war3map.wts` là file riêng và chỉ giữ được một thứ tiếng.
>
> Muốn bản tiếng Việt đầy đủ thì phải chạy **cả hai**:
> ```
> python w3skill.py gen --lang vi
> python build.py --lang vi
> ```
> Hai bản map khác tiếng cần hai lần sinh — và vì `w3skill.py` ghi thẳng vào thư
> mục map, **không build song song hai tiếng cùng lúc được**.
