# 0005 — Hoãn mọi thao tác quầy hàng sang tick sau

> **Trạng thái:** Đã chốt — luật vẫn hiệu lực, dù Tavern đã bị bỏ
>
> Tavern được thay bằng popup chọn hero
> ([chon-hero.md](../02-he-thong/chon-hero.md)), nên đoạn code cụ thể trong ADR
> này không còn. **Luật thì vẫn nguyên giá trị** cho mọi sự kiện engine khác:
> trong sự kiện chỉ đọc và quyết định, mọi thay đổi hoãn sang tick sau.

> **Ngày:** 2026-09-14

## Bối cảnh

Mua hero từ Tavern làm Warcraft III sập ngay lập tức:

```
<Exception.Summary:>
ACCESS_VIOLATION
<BlizzardError.AffectsVersions>War III 1.31.1
```

Crash dump không có symbol nên stack chỉ toàn địa chỉ thô, không chỉ ra được hàm
nào. Nhưng thời điểm thì rõ: sập đúng lúc giao dịch mua hoàn tất.

Code lúc đó gọi thẳng trong `EVENT_PLAYER_UNIT_SELL`:

```lua
if CFG.HERO_UNIQUE then RemoveUnitFromStock(S.tavern, uid) end
```

và ở nhánh huỷ mua:

```lua
RemoveUnit(sold)
AddUnitToStock(S.tavern, uid, 1, 1)
```

Cả hai đều là **sửa thứ engine đang dùng dở**. Lúc sự kiện bán đang chạy,
Warcraft III vẫn đang duyệt danh sách hàng của chính cửa hàng đó, và vẫn đang
giữ tham chiếu tới unit nó vừa tạo. Gỡ một phần tử khỏi mảng đang duyệt, hoặc
xoá unit engine còn cầm — đó là công thức của access violation.

## Quyết định

**Trong một sự kiện của engine, chỉ đọc và quyết định. Mọi thay đổi hoãn sang
tick sau** bằng timer 0 giây.

```lua
-- doc va quyet dinh: dong bo
local deny = ...
if deny == nil then d.heroCount = d.heroCount + 1 end

-- thay doi: hoan lai
API.after(0.0, function()
  RemoveUnitFromStock(S.tavern, uid)
end)
```

Timer 0 giây nổ ở tick kế tiếp, khi engine đã đóng giao dịch xong.

Thay đổi trạng thái Lua thuần (`d.heroCount`) vẫn làm đồng bộ được — chúng không
đụng gì tới engine, và làm ngay thì tránh được kẽ hở nếu có hai giao dịch sát
nhau.

## Áp dụng cho những gì

Luật này áp cho **mọi** sự kiện của engine, không riêng gì mua bán:

| Không được gọi đồng bộ trong sự kiện | Ví dụ |
|---|---|
| Sửa quầy hàng | `AddUnitToStock`, `RemoveUnitFromStock` |
| Xoá unit mà sự kiện đang nói tới | `RemoveUnit(GetSoldUnit())`, `RemoveUnit(GetTriggerUnit())` |
| Huỷ trigger từ trong chính nó | `DestroyTrigger(GetTriggeringTrigger())` |

Đọc thì luôn an toàn: `GetSoldUnit`, `GetUnitTypeId`, `GetOwningPlayer`,
`GetUnitName`.

## Phương án đã loại

**Bỏ `HERO_UNIQUE` để khỏi phải đụng quầy hàng.** Né được crash nhưng vứt luôn
một yêu cầu thật của map. Không chấp nhận.

**Dùng `TriggerSleepAction`.** Cũng hoãn được, nhưng nó làm chậm cả trigger,
không đồng bộ giữa các máy trong multiplayer, và độ trễ không kiểm soát được.
Timer chuẩn xác hơn và rẻ hơn.

## Hệ quả

**Người chơi thấy hero còn trên quầy thêm một khung hình** sau khi mua. Không ai
nhận ra được.

**Nhánh huỷ mua có một khung hình hero tồn tại thật** trước khi bị xoá. Cũng
không thấy được, nhưng nghĩa là mọi trigger khác bắt sự kiện tạo unit sẽ **thấy**
con hero đó. Hiện chưa có trigger nào như vậy; khi có thì phải nhớ chuyện này.

**Biến bắt vào closure phải chụp trước.** `GetSoldUnit()` và họ hàng chỉ có giá
trị trong lúc sự kiện chạy; tới tick sau là rỗng. Nên tên hero, tên người chơi,
id unit đều phải đọc ra biến cục bộ **trước** khi vào `API.after`.

## Nếu vẫn sập

Đặt `CFG.HERO_UNIQUE = false` rồi thử lại. Hết sập nghĩa là thủ phạm đúng là thao
tác quầy hàng; còn sập thì phải tìm chỗ khác.
