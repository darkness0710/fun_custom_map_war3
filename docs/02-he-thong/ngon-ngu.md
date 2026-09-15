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

## Tên quái: 60 tên từ 23 chuỗi

Trước đây quái tên là **"Footman"** — vô nghĩa trong một map tu tiên.

Tên quái ghép từ tên cảnh giới cộng hậu tố theo loại:

| Loại | Hậu tố en | Hậu tố vi |
|---|---|---|
| lính thường | Cultivator | Tan Tu |
| tinh anh | Elite | Tinh Anh |
| boss | Lord | Ma Ton |

```
Mortal Cultivator · Golden Core Elite · Great Luo Lord
Pham Nhan Tan Tu  · Kim Dan Tinh Anh  · Dai La Ma Ton
```

20 cảnh giới × 3 loại = **60 tên, sinh ra từ 20 + 3 chuỗi.**

Đổi tên bằng `BlzSetUnitName` lúc sinh quái, nên **không phải tạo unit type nào
trong Object Editor**, và đổi tiếng cũng không phải đụng tới nó. Thiếu native
thì bỏ qua, quái giữ tên gốc — không sập.

## Chưa phủ hết

Còn chữ tiếng Việt cứng trong code, chủ yếu là **thông báo dành cho người phát
triển**: dòng vết, báo cáo `-nat`, `-sync`, cảnh báo thiếu native. Cố ý để lại —
chúng dành cho người làm map, không phải người chơi.

Chưa dịch: tên hero (`Hart`/`Hvwd`/`Hkal` là tên riêng, giữ nguyên), vai hero
(`Warrior`/`Shooter`/`Mage` — vốn đã tiếng Anh).

**Tooltip của kỹ năng trong command card chưa dịch** vì nó nằm trong
`war3map.w3a`, không nằm trong Lua. Bộ sinh sẽ ghi nó ra theo `CFG.LANG` — xem
[sửa & clone ability](../06-object-editor/sua-va-clone-ability.md).
