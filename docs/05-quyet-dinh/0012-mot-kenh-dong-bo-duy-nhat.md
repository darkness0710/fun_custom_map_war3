# 0012 — Một kênh đồng bộ duy nhất cho cả dự án

> **Trạng thái:** Đã chốt — đo trong game 2026-09-15, chạy đường `blz`
> **Ngày:** 2026-09-15
> **Code:** [3_sync.lua](../../src/1_nen/3_sync.lua)

## Kết quả đo (một người, 1.31.1)

```
Duong dang chay: blz   (CFG.SYNC_MODE = auto)
BlzSendSyncData ................... true
BlzGetTriggerSyncData ............. true
BlzTriggerRegisterPlayerSyncEvent   true      <- CÓ
TriggerRegisterPlayerSyncEvent .... false     <- tên code cũ dò
Game cache (Store/Sync/Flush) ..... true
Ping player 0: da ve
```

**1.31.1 có đủ native đồng bộ.** Thiếu ba chữ cái `Blz` trong một cái tên là
toàn bộ nguyên nhân. Ping về được, tức là gửi → sự kiện → nhận chạy thật.

Còn một phép đo nữa **chưa làm**: vòng này qua mạng thật với hai người trở lên.
Ở một người, gói tin không rời máy.

Đường `cache` và cái bẫy của nó bên dưới **không dùng tới**, nhưng giữ nguyên
làm đường lui — bật bằng `CFG.SYNC_MODE = "cache"`.

## Bối cảnh

Sự kiện bấm frame (`BlzTriggerRegisterFrameEvent`) **chỉ nổ trên máy người
bấm**. Warcraft III chạy lockstep: mọi máy mô phỏng cùng một ván cờ, cùng một
nhịp. Đổi trạng thái game ngay trong sự kiện đó thì máy ấy đi trước hai máy kia
— và lệch nhịp là bị đá ra khỏi trận, không phải lỗi hiển thị.

Ba giao diện frame ([bảng kỹ năng](../../src/4_giao_dien/3_skillframe.lua),
[thẻ chọn hero](../../src/4_giao_dien/2_heroframe.lua),
[Linh Căn](../../src/2_nguoi_choi/3_linhcan.lua)) mỗi file tự dò native, tự quyết định có đồng bộ hay không, tự lùi về chế độ chạy thẳng
khi thiếu. **Ba câu trả lời khác nhau cho cùng một câu hỏi.**

Và cả ba đều trả lời sai, vì cùng một lý do: cả ba dò
`TriggerRegisterPlayerSyncEvent`. Tên native của bản 1.31 là
**`BlzTriggerRegisterPlayerSyncEvent`** — có tiền tố `Blz`. Thiếu ba chữ cái,
nên `syncAvailable()` trả về `false`, và cả ba giao diện **âm thầm lùi về chế
độ một người chơi** đúng như thiết kế dự phòng. Không có lỗi nào nổ. File vết
chỉ ghi `THIEU dong bo`, mà tôi đọc thành "bản 1.31.1 không có native này".

Chưa xác minh được tên đúng khi ngồi ngoài game — máy này không có `common.j`.
Nên code dò **cả hai tên**, và ghi riêng từng cái vào file vết.

## Quyết định

Một file `3_sync.lua` giữ toàn bộ việc đồng bộ. Mọi module khác chỉ biết hai
hàm:

```lua
API.syncSend(pid, op, arg)   -- bấm: gửi đi, KHÔNG đổi gì
API.syncOn(op, f)            -- nhận: f(pid, arg) chạy trên MỌI máy
```

`build.py` **chặn ghi file** nếu bất kỳ file nào khác gọi thẳng native đồng bộ
(`check_sync_owner`). Lỗi vừa rồi tồn tại được là nhờ mỗi file có bản sao riêng
của cùng một logic; giờ chỉ còn một bản.

### Ba đường gửi

`CFG.SYNC_MODE` chọn đường; `"auto"` ưu tiên từ trên xuống.

| | Cần gì | Cơ chế | Đánh đổi |
|---|---|---|---|
| `blz` | 1.31+ | `BlzSendSyncData` + sự kiện | Là sự kiện, không có khe thời gian mơ hồ |
| `cache` | mọi bản | `StoreInteger` + `SyncStoredInteger`, quét bằng timer | Chắc chắn tồn tại, nhưng xem bẫy dưới |
| `local` | — | chạy thẳng | **Chỉ chơi một mình** |

### Khuôn tin: một số nguyên

```
packed = op * 10^7  +  seq * 10^5  +  arg
         op  1..200      seq 0..99     arg 0..99999
```

Một số duy nhất, nên tin đến **nguyên vẹn hoặc không đến** — không có cảnh
`op` tới trước `arg` một nhịp.

`seq` chỉ để phân biệt hai tin **giống hệt nhau** gửi liên tiếp (bấm "Đột phá"
hai lần). Đường cache so giá trị cũ với mới để biết có tin mới; không có `seq`
thì tin thứ hai bị nuốt.

`arg` chỉ 5 chữ số, nên **không gửi được id kiểu FourCC** (`H001` là hơn 1,2
tỉ). Gửi **số thứ tự** trong bảng tĩnh (`CFG.HEROES`, danh sách `choices`) rồi
tra ngược ra id ở đầu bên kia.

### Lệnh chat không đi qua đây

`EVENT_PLAYER_CHAT_STRING` **vốn đã nổ trên mọi máy cùng lúc**. Nên `-lc up`
gọi thẳng `breakthrough()`. Đó cũng là lý do lệnh chat vẫn chạy đúng kể cả khi
không còn đường đồng bộ nào — và là đường lui thật sự nếu cả hai đường trên
hỏng.

## Bẫy của đường cache, và một giả định chưa đo được

`StoreInteger` ghi **thẳng vào cache của máy người gửi**. Nếu để nguyên, bộ quét
của chính máy đó thấy tin ở nhịp kế tiếp (0,1 giây), trong khi hai máy kia phải
đợi gói tin qua mạng. Người gửi làm trước một nhịp → **lệch trận**. Đúng cái
đang muốn tránh.

Nên sau khi gọi `SyncStoredInteger`, code **xoá ngay bản cục bộ**
(`FlushStoredInteger`). Máy người gửi khi đó cũng phải đợi gói tin quay về như
mọi người.

Việc này dựa trên một giả định **chưa đo được trên 1.31.1**:
`SyncStoredInteger` đóng gói giá trị ngay lúc gọi, nên xoá sau không huỷ được
nó.

**Chọn kiểu hỏng.** Nếu giả định sai, tin không bao giờ về — nút chết, **không
lệch trận**. Hỏng kiểu đó thấy ngay khi test; lệch trận thì không, nó nổ ở ván
thứ mười với ba người đang chơi.

## Tự kiểm

Mỗi người gửi một tin `PING` lúc vào map. Sau 3 giây, file vết ghi ping nào về,
ping nào mất. Ping của chính mình về được nghĩa là vòng store → sync → flush →
nhận **chạy thật**. Trong game gõ `-sync` để xem.

Tự kiểm **không tự đổi đường** khi thất bại. Hai máy kết luận khác nhau thì mỗi
máy chạy một kiểu — đúng cái muốn tránh ngay từ đầu. Nó báo ra, rồi người sửa
`CFG.SYNC_MODE` và build lại.

## Phương án đã loại

**Bắt tay (mọi máy báo đã nhận, đủ chữ ký mới thi hành).** Giải được đúng cái
bẫy trên mà không cần giả định gì. Nhưng chữ ký của chính máy mình cũng ghi cục
bộ, nên lại vướng đúng vấn đề cũ ở một tầng sâu hơn — trừ khi cũng xoá bản cục
bộ, tức là vẫn phải tin vào cùng một giả định. Phức tạp hơn nhiều mà không chắc
hơn.

**Đưa mọi hành động về lệnh chat.** Đúng chắc chắn, không cần đo gì. Nhưng
người chơi phải gõ `-lc up` thay vì bấm nút, và ba bảng frame vừa dựng xong
thành đồ trang trí.

**Chấp nhận một người chơi.** Không hợp — bạn bè sẽ vào cùng.

## Hệ quả

- Ba file giao diện mất hẳn phần dò native và phần lùi chế độ. Ngắn hơn, và
  không thể lệch nhau.
- Thêm một `op` mới là thêm một hằng trong [1_config.lua](../../src/1_nen/1_config.lua)
  và một `API.syncOn`.
- `arg` trần 99999 là ràng buộc thật: cái gì cần gửi thì phải đánh số được
  trong một bảng tĩnh.
- Còn **một phép đo phải làm trong game**: xem dòng `sync:` trong file vết.
  Xem [lệnh debug](../04-map/lenh-debug.md).
