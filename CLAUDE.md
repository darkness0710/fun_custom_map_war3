# DarknessCustomMap

Map thủ trận Warcraft III (patch **1.31.1**), chủ đề tu tiên. Code Lua trong
`src/`, `build.py` nối lại thành `war3map.lua` rồi đóng gói thành `.w3x`.

---

## Quy ước đặt tên — **tiếng Anh**

**Mọi định danh trong code phải là tiếng Anh.** Không viết tiếng Việt không dấu.

| | Phải là | Không được |
|---|---|---|
| Tên hàm | `drawCards`, `addGold`, `heroRecompute` | `rutThe`, `themVang`, `capNhatHero` |
| Tên biến | `remaining`, `bossDamage`, `tierName` | `conLai`, `satThuongBoss`, `tenTang` |
| Khoá bảng / field | `d.rolls`, `b.shield` | `d.luotQuay`, `b.khien` |
| Khoá `CFG` | `CFG.BOSS_SECONDS` | `CFG.BOSS_GIAY` |
| Khoá i18n | `boss_enraged`, `gear_up` | `boss_cuong`, `tb_len` |
| Tên thư mục | `src/2_player/` | `src/2_nguoi_choi/` |
| Tên file Lua | `3_cultivation.lua` | `3_linhcan.lua` |
| Tên file Python/docs | tiếng Anh | |

Số ở đầu tên thư mục và file Lua là **thứ tự nạp** của `build.py`, không phải
tiếng Việt — giữ nguyên.

### Ngoại lệ duy nhất: chữ hiển thị cho người chơi

Mọi chuỗi người chơi **nhìn thấy** đi qua i18n trong
[`src/1_core/6_i18n.lua`](src/1_core/6_i18n.lua) — hai bảng `T.en` và `T.vi`:

```lua
API.msg(pid, API.t("boss_enraged"))        -- ĐÚNG
API.msg(pid, "Boss phat cuong!")           -- SAI: chuỗi cứng
```

**Nhưng không phải chữ nào cũng của người chơi.** Ba kênh riêng cho chẩn đoán,
và chúng **cố ý không dịch** — nội dung là tên khoá `CFG`, tên native, tên file:

```lua
API.warn(pid, "Kiem tra CFG.HOUSE_UNIT.")   -- người LÀM MAP đọc, đỏ
API.info(nil, "Nha chinh : " .. x)          -- thân báo cáo, không màu
API.trace("boss: r16 mau 1204880")          -- file vết
```

Dịch chúng chỉ tốn hai bảng chuỗi cho một độc giả duy nhất là chính mình.

**Dấu hiệu phân kênh là `API.t()`, không phải màu.** Đợt chuyển 150 chỗ lần đầu
lấy màu đỏ làm dấu hiệu chẩn đoán — sai, vì đỏ cũng dùng cho lỗi *của người
chơi* (*"không đủ gỗ"*). 26 câu bị đẩy nhầm sang kênh chẩn đoán, và **không ai
thấy được**: build vẫn chạy, chữ vẫn hiện đúng, chỉ phân loại sai. Bắt được nhờ
quét `API.warn(` nào còn chứa `API.t(`.

Chi tiết: [docs/02-he-thong/ngon-ngu.md](docs/02-he-thong/ngon-ngu.md).

**Khoá i18n cũng là tiếng Anh** (`boss_enraged`, không phải `boss_cuong`); chỉ
*giá trị* trong `T.vi` mới là tiếng Việt.

Tên dữ liệu trong bảng (cảnh giới, kỹ năng, boss…) dùng cặp `vi` / `en` và đọc
qua `API.pick(tbl)`; mô tả dài thì `desc_vi` / `desc_en`. Đó không phải định
danh, đó là dữ liệu — nhưng *khoá* vẫn là mã ngôn ngữ, không phải `ten`/`mota`.

### Chú thích thì viết tiếng Việt

Chú thích trong code viết **tiếng Việt không dấu** (giữ như hiện tại — file
`war3map.lua` đi qua nhiều công cụ nhị phân, dấu tiếng Việt từng gây lỗi mã hoá).
Docs trong `docs/` viết tiếng Việt **có dấu** bình thường.

### Mã nguồn đã đổi xong (2026-09-18)

Cả 5 thư mục, 26/26 file Lua, toàn bộ hàm/biến/field/khoá `CFG`/khoá i18n đều
đã sang tiếng Anh. Kiểm lại bằng cách quét định danh *ngoài chú thích và chuỗi*
— hiện còn **0** chỗ.

Bài học của lần đổi đó, đáng nhớ cho lần sau:

- **Che chú thích và chuỗi trước khi đổi tên.** Lần đầu làm ẩu, `"Phong thu"`
  thành `"Phong tries"` — hỏng thật chứ không phải phiền nhỏ. Cách đúng: thay
  chú thích/chuỗi bằng placeholder, đổi định danh, rồi trả lại; chuỗi nào cần
  đổi (khoá i18n, tên cơ chế) thì một lượt riêng, khớp **trọn** chuỗi.
- **Đổi tên theo từng file thì dễ đứt liên kết giữa file.** File A ghi
  `out.dong`, file B đọc `d.row` — Lua trả `nil`, không báo gì. Sau khi đổi
  phải quét: field nào *đọc* mà không ai *ghi*.
- **Đổi định danh mà quên chuỗi tương ứng.** `API.t("quay_the_" .. kind)` trong
  khi khoá đã thành `fortune_card_*`; `ICON.chiso` thành `ICON.statVal` trong
  khi `kind` vẫn là `"chiso"`; `CFG.BOSS_MECH` còn khoá `chandia` trong khi
  `3_boss.lua` tra bằng `"slam"`. Cả ba đều im lặng cho tới lúc chạy.
- Đổi tên thì làm **một lần một** (đổi tên thuần, không kèm thay đổi hành vi)
  để `git diff` còn đọc được.

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
