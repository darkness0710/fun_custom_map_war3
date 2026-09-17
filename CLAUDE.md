# DarknessCustomMap

Map thủ trận Warcraft III (patch **1.31.1**), chủ đề tu tiên. Code Lua trong
`src/`, `build.py` nối lại thành `war3map.lua` rồi đóng gói thành `.w3x`.

---

## Quy ước đặt tên — **tiếng Anh**

**Mọi định danh trong code phải là tiếng Anh.** Không viết tiếng Việt không dấu.

| | Phải là | Không được |
|---|---|---|
| Tên hàm | `drawCard`, `addGold`, `heroRecompute` | `rutThe`, `themVang`, `capNhatHero` |
| Tên biến | `remaining`, `bossDamage`, `tierName` | `conLai`, `satThuongBoss`, `tenTang` |
| Khoá bảng / field | `d.rolls`, `b.shield` | `d.luotQuay`, `b.khien` |
| Khoá `CFG` | `CFG.BOSS_SECONDS` | `CFG.BOSS_GIAY` |
| Tên thư mục | `src/core/`, `src/player/` | `src/1_nen/`, `src/2_nguoi_choi/` |
| Tên file Lua | `linhcan.lua` → `cultivation.lua` | `3_linhcan.lua` |
| Tên file Python/docs | tiếng Anh | |

### Ngoại lệ duy nhất: chữ hiển thị cho người chơi

Mọi chuỗi người chơi **nhìn thấy** đi qua i18n trong
[`src/1_nen/6_lang.lua`](src/1_nen/6_lang.lua) — hai bảng `T.en` và `T.vi`:

```lua
API.msg(pid, API.t("boss_enraged"))        -- ĐÚNG
API.msg(pid, "Boss phat cuong!")           -- SAI: chuỗi cứng
```

**Khoá i18n cũng là tiếng Anh** (`boss_enraged`, không phải `boss_cuong`); chỉ
*giá trị* trong `T.vi` mới là tiếng Việt.

Tên dữ liệu trong bảng (cảnh giới, kỹ năng, boss…) dùng cặp `ten` / `en` và đọc
qua `API.pick(tbl)` — đó không phải định danh, đó là dữ liệu.

### Chú thích thì viết tiếng Việt

Chú thích trong code viết **tiếng Việt không dấu** (giữ như hiện tại — file
`war3map.lua` đi qua nhiều công cụ nhị phân, dấu tiếng Việt từng gây lỗi mã hoá).
Docs trong `docs/` viết tiếng Việt **có dấu** bình thường.

### Mã nguồn hiện tại **chưa** theo quy ước này

Đo được: **5/5 thư mục**, **26/26 file Lua**, và khoảng **412** hàm/`API.*` đang
dùng tiếng Việt không dấu (`rutThe`, `themLuot`, `chanDia`, `linhCanStatBonus`,
`src/2_nguoi_choi/3_linhcan.lua`…).

Quy ước áp dụng cho **code mới**. Đổi tên toàn bộ là một lần sửa lớn chạm gần như
mọi file — làm khi được yêu cầu rõ, và làm **một lần một** (đổi tên thuần, không
kèm thay đổi hành vi) để `git diff` còn đọc được.

---

## Build

```bash
python build.py --lang en          # nối src/ -> test2.w3x/war3map.lua
python build.py --lang en --pack   # + đóng gói .w3x, chép sang Maps/
python build.py --lang vi          # bản tiếng Việt
```

`build.py` chặn ghi file nếu Lua sai cú pháp. Nó cũng đóng **dấu thời gian** vào
mỗi bản build và in ra dòng đầu khi vào map — dùng nó để biết mình có đang chạy
bản mới hay không.

**World Editor đang mở thì đóng rồi mở lại trước khi Ctrl+F9.** WE giữ bản map
trong bộ nhớ nó; Ctrl+F9 sẽ đóng gói bản **cũ** và không báo lỗi gì.

`--pack` báo `Permission denied` nghĩa là game đang giữ file — đóng game rồi chạy
lại. `war3map.lua` trong folder vẫn đã được cập nhật.

## Kiểm tra

```bash
python w3obj.py checkall test2.w3x   # đọc lại file nhị phân, so từng byte
python w3skill.py gen --lang en      # sinh tên/tooltip/phím tắt vào war3map.w3a
```

---

## Hai luật đã phải trả giá để học

**1. Gọi hàm của file khác phải qua `API`.** `build.py` gộp mọi file vào một khối
`do...end`; local của file trước **không** nhìn thấy được ở file sau theo chiều
ngược lại. Bắt local lúc *định nghĩa*, `API` tra lúc *gọi*.

**2. Đo, đừng đoán.** Tên hằng số, đường dẫn texture, mã item, hằng số gameplay —
mỗi lần đoán trong dự án này đều đoán sai. Công cụ đo có sẵn:

```
-nat <chữ>    liệt kê hằng số toàn cục chứa <chữ>
-nat spell    hằng số theo ability gốc của từng kỹ năng
-nat stat     1 điểm chỉ số đổi ra bao nhiêu máu/mana/giáp
-reg          đo hồi máu thật; -reg mana cho mana
```

Kết quả đầy đủ vào `Documents/Warcraft III/CustomMapData/DarknessTrace.txt`
(**bị ghi đè mỗi phiên game** — đọc trước khi khởi động lại).

Gõ sai tên hằng số thì Lua trả `nil` và hàm **im lặng không làm gì**. Code mới
phải `API.trace` khi hằng số vắng mặt, không nuốt lỗi.
