# Lệnh debug & chế độ phát triển

> **Cập nhật:** 2026-09-15
> **Code:** [1_config.lua](../../src/1_nen/1_config.lua) · [1_events.lua](../../src/5_khoi_dong/1_events.lua)

Sổ tra cho lúc chạy thử. Mọi lệnh gõ thẳng vào ô chat trong game.

## Bốn công tắc, độc lập với nhau

Tất cả nằm ở đầu [1_config.lua](../../src/1_nen/1_config.lua). Đổi xong phải chạy
`python build.py` rồi mới Ctrl+F9.

| Khoá | Mặc định | Bật thì được gì |
|---|---|---|
| `CFG.DEV_COMMANDS` | `true` | Mở nhóm lệnh dev bên dưới |
| `CFG.TRACE` | `true` | Ghi vết khởi động ra file |
| `CFG.DEBUG` | `false` | In sơ đồ lưới, ping 25 block, báo cáo chi tiết lúc vào map |
| `CFG.REVEAL_MAP` | `true` | Mở toàn bộ sương mù |

**Bốn cái này không kéo theo nhau.** Tắt `DEBUG` vẫn gõ lệnh dev được, vẫn có file
vết. Đây là bài học từ một lần hỏng thật: trước đây lệnh `-sp` gắn vào `CFG.DEBUG`,
nên tắt báo cáo chi tiết là lệnh biến mất luôn mà không báo gì.

### Trước khi phát hành

```lua
CFG.DEV_COMMANDS = false
CFG.TRACE        = false
CFG.DEBUG        = false
CFG.REVEAL_MAP   = false
```

Quên `REVEAL_MAP` là cả bản đồ sáng trưng, mất hết sương mù — dễ sót nhất vì nó
không gây lỗi gì.

## Lệnh luôn dùng được

Không phụ thuộc công tắc nào. Đây là lối chơi, không phải debug.

| Lệnh | Làm gì |
|---|---|
| `E` | Mở bảng nhân vật (4 thẻ) |
| `-c` | Như phím E — đường lui nếu phím không gán được |
| `-lc` | Mở thẳng thẻ Linh Căn |
| `-lc up` | Đột phá một bậc, không cần mở bảng |
| `-sync` | Đường đồng bộ nào đang chạy, native nào có, ping có về không |

> **Lệnh chat luôn đúng trong nhiều người chơi.** `EVENT_PLAYER_CHAT_STRING` nổ
> trên mọi máy cùng lúc, nên `-lc up` đổi trạng thái game thẳng, không qua kênh
> đồng bộ. Đó là đường lui thật sự nếu các nút bấm không ăn.

> Phím **E** cần `BlzTriggerRegisterPlayerKeyEvent` và `OSKEY_E`. Hai cái này
> **chưa xác minh trên 1.31.1**. Kiểm bằng file vết: thấy `panel: da gan phim E`
> là chạy, thấy `panel: KHONG co Blz...` thì dùng `-c`.

## Lệnh dev

Cần `CFG.DEV_COMMANDS = true`.

| Lệnh | Làm gì | Ví dụ |
|---|---|---|
| `-wave <số>` | Nhảy thẳng tới stage 1–220 | `-wave 110` → boss Độ Kiếp |
| `-lk <số>` | Thêm Linh Khí (vàng) | `-lk 200000` |
| `-tt <số>` | Thêm Tinh Thạch (gỗ) | `-tt 500` |
| `-lc <số>` | Nhảy tới bậc Linh Căn 1–20 | `-lc 15` → Đại La |
| `-sp` | Phát 1 điểm kỹ năng, hoặc mở bảng chọn kỹ năng tuỳ `CFG.SKILL_MODE` | |
| `-next` | Gọi đợt kế tiếp — **chỉ khi đã dọn sạch** quái trên map | |
| `-spawn` | Tạo thẳng một `H001` bằng `CreateUnit`, cạnh hero | để so với unit đặt sẵn |
| `-nat` | Bản Warcraft này có native nào | |

**`-wave` là lệnh quan trọng nhất.** Không có nó thì muốn xem stage 180 phải chơi
hai tiếng. Mọi thứ về cân bằng đều kiểm bằng lệnh này.

### Ba bài kiểm hay dùng

```
-wave 1     rồi   -wave 110   rồi   -wave 220
```
Xem đường cong chỉ số có đúng không. Đối chiếu với bảng tra trong
[duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md).

```
-lk 2000000  rồi  -lc 20
```
Hero ở đỉnh tu vi. Xem chỉ số có lên +749 mỗi loại không, và sát thương có ×19.7
không.

```
-wave 11    (boss Phàm Nhân)
```
Stage boss đầu tiên. Kiểm boss ra một mình, không có lính đi kèm.

## File vết

`CFG.TRACE = true` ghi ra:

```
Documents\Warcraft III\CustomMapData\DarknessTrace.txt
```

File **bị ghi đè mỗi lần chạy**, và ghi lại toàn bộ danh sách ở mỗi bước — nên sau
khi game sập, **dòng cuối cùng là bước cuối đã chạy xong**.

> **Xoá file này trước khi test** nếu muốn chắc chắn dữ liệu là của lần chạy vừa
> rồi. Đã có một lần đọc nhầm vết của hôm trước rồi kết luận sai.

Những dòng đáng để mắt:

| Dòng | Nghĩa |
|---|---|
| `chunk: da nap` | Code đã vào map. Không có dòng nào cả = map không chứa code |
| `BOOTSTRAP HOAN TAT` | Khởi động sạch |
| `panel: da gan phim E` | Phím E dùng được |
| `fct: san sang` | Chữ bay chạy |
| `fct: THIEU su kien sat thuong` | 1.31.1 không có event đó, chữ bay tự tắt |
| `sync: mode=...` | Đường đồng bộ nào đang chạy — xem phần dưới |
| `sync: tu kiem [...] ve=... mat=...` | Ping ai về, ai mất |
| `native [...] co N/M` | Ban này thiếu native nào. Thiếu là hệ dùng nó tự tắt |
| `stage N (...) P=k song=m` | Mỗi wave: stage, số người, số quái đang sống |

## Đồng bộ nhiều người chơi — phép đo phải làm một lần

Nút bấm trong bảng chỉ nổ trên máy người bấm. Cả dự án đi qua một kênh duy nhất
([3_sync.lua](../../src/1_nen/3_sync.lua), [ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md)).
Vào map xong, mở file vết tìm hai dòng này:

```
sync: mode=blz blzSend=true blzReg=true regCu=false cache=true
sync: tu kiem [blz] ve=0 mat=khong ai
```

| `mode=` | Nghĩa |
|---|---|
| `blz` | Dùng `BlzSendSyncData`. Tốt nhất — là sự kiện, không phải quét |
| `cache` | Bản này không có blz, lùi về game cache + timer |
| `local` | **Không có kênh nào. Chỉ chơi một mình được.** |

`ve=` phải liệt kê **mọi** player đang chơi. Thiếu ai là kênh đó không thật sự
chạy: đổi `CFG.SYNC_MODE` trong [1_config.lua](../../src/1_nen/1_config.lua) sang
đường còn lại (`"blz"` ↔ `"cache"`), build lại, đo lại.

> Dòng `blzReg=` là `BlzTriggerRegisterPlayerSyncEvent`, `regCu=` là cùng tên
> nhưng **thiếu tiền tố `Blz`**. Trước đây code chỉ dò tên thiếu tiền tố, nên
> kết luận nhầm là bản 1.31.1 không có đồng bộ và cả ba bảng âm thầm lùi về chế
> độ một người chơi. Giờ dò cả hai.

### Lệnh khớp **tiền tố**, nên chúng ăn lẫn nhau

`TriggerRegisterPlayerChatEvent(..., "-sp", false)` — tham số cuối `false`
nghĩa là khớp tiền tố. Nên gõ **`-spawn`** cũng kích hoạt **`-sp`**.

Đã cắn: gõ `-spawn` thì hiện bảng chọn kỹ năng, không hiểu tại sao.

> Lệnh nào không nhận tham số thì **kiểm lại chuỗi đầy đủ** trong hàm xử lý:
> ```lua
> if raw:match("^%s*%-sp%s*$") == nil then return end
> ```
> Đặt `true` (khớp chính xác) thì không va nhau, nhưng lệch một dấu cách là
> **im lặng hoàn toàn** — cũng đã cắn hai lần với `-nat` và `-next`.

## Khi game sập hoặc im lặng

Theo thứ tự này, đừng đoán:

1. **`Documents\Warcraft III\Logs\War3Log.txt`** — lỗi biên dịch Lua nằm ở đây.
   Hộp thoại trống trong game *không phải* là "không có thông tin".
2. **`CustomMapData\DarknessTrace.txt`** — chết ở bước nào.
3. **`Documents\Warcraft III\Errors\<thời gian>\Crash.txt`** — dump khi sập.

`FramedefErrors.log` thì **bỏ qua** — mấy dòng `ConsoleUI.fdf` và
`PlayerSlotPopupMenu` là tiếng ồn nền của Warcraft III, có ở mọi lần khởi động kể
cả khi map chưa có dòng frame nào.

## Hai giới hạn của engine đã cắn một lần

**200 biến local mỗi hàm.** Cả bản build là một hàm. `build.py` bọc mỗi file trong
khối `do...end` riêng để lách, và **chặn ghi file** nếu phát hiện file này gọi
thẳng local của file kia. Triệu chứng nếu tái phát:
`too many local variables (limit is 200)` trong `War3Log.txt`.

**~100 text tag cùng lúc.** Xem phần chữ bay ở cuối.

**`build.py` chặn ghi file nếu file nào ngoài `3_sync.lua` gọi thẳng native
đồng bộ.** Cả `BlzSendSyncData` lẫn `StoreInteger`/`SyncStoredInteger`. Mọi chỗ
khác đi qua `API.syncSend` / `API.syncOn`.

## Bẫy quy trình

**World Editor ghi đè `war3map.lua` mỗi lần Save.** Thứ tự bắt buộc:

```
sửa địa hình trong WE  →  Save
sửa code trong src/
python build.py                  ←  LUÔN là bước cuối
Ctrl+F9
```

Vào map mà im lìm, không thấy dòng vàng `[build x.y.z] code da chay.` — gần như
chắc chắn là quên build. Đã dính nhiều lần.

**World Editor cũng giữ bản map trong bộ nhớ nó.** Nếu WE mở map suốt buổi mà
script sửa file trên đĩa, Ctrl+F9 đóng gói **bản cũ trong bộ nhớ** — vào game
không thấy gì đổi, không lỗi nào báo, file vết không được ghi mới.

Đã cắn hai lần. Lần thứ hai mất cả buổi đi tìm lỗi trong code trong khi code
hoàn toàn đúng. Nên `build.py` giờ **dò xem World Editor có đang chạy không** và
báo to nếu có:

```
[!] WORLD EDITOR DANG MO -- DONG MAP ROI MO LAI TRUOC KHI Ctrl+F9.
```

> **Dấu hiệu nhận ra:** file vết không đổi giờ sau khi chạy game. So
> `DarknessTrace.txt` với giờ bạn vừa vào map — cũ hơn là code không chạy dòng nào.

### Cách kiểm dứt điểm

World Editor đóng gói bản test ra `%TEMP%\WorldEditTestMap.w3x`. Mở file đó ra
xem có code của mình trong đó không:

```
grep -ac "TUTIEN BUILD" "$TEMP/WorldEditTestMap.w3x"
```

Đã đo một lần: file WE đóng gói **1,27 MB** trong khi thư mục map trên đĩa
**3,78 MB** (có model 1,5 MB). Không chứa cả code lẫn model — bằng chứng dứt
điểm rằng Ctrl+F9 đóng gói bản trong bộ nhớ.

### Đường vòng: chạy thẳng, không qua World Editor

```
python build.py --run
python build.py --run --wc3 "D:\Warcraft III_64\Warcraft III.exe"
```

Warcraft đọc **thư mục map trên đĩa**, nên không có khâu bộ nhớ của World
Editor ở giữa. Đây là cách test khi chỉ sửa code — chỉ cần World Editor khi sửa
địa hình hoặc Object Editor.

## Tắt riêng chữ bay

Chữ bay có công tắc riêng, không theo `CFG.DEBUG`:

```lua
CFG.FCT_ENABLED   = true    -- tắt hết chữ bay
CFG.FCT_SHOW_GOLD = true    -- chỉ tắt chữ Linh Khí
CFG.FCT_MAX_TAGS  = 12      -- giảm nếu thấy rối mắt
```

> Đừng nâng `FCT_MAX_TAGS` quá cao. Warcraft III chỉ cho ~100 text tag cùng lúc;
> tràn trần thì **không còn chữ nào hiện nữa**, kể cả chữ quan trọng. Với 12 chữ
> mỗi 0.4 giây thì đỉnh điểm khoảng 52 — còn cách trần.
