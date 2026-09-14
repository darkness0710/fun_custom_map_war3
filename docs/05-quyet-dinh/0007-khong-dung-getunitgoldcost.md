# 0007 — Không dùng `GetUnitGoldCost` / `GetUnitWoodCost`

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-14

## Bối cảnh

Sau khi sửa lỗi `FourCC` trả hai giá trị ([ADR 0006](0006-fourcc-tra-hai-gia-tri.md)),
map **vẫn sập** `ACCESS_VIOLATION` ở đúng chỗ cũ. Vết khởi động:

```
tavern: #HEROES=3 #REMOVE=8      ← bảng đã đúng, lỗi FourCC hết thật
tavern: CreateUnit slot 15
tavern: grantBuyingPower         ← dòng cuối
```

Tức là id truyền vào đã hợp lệ — `FourCC('Emoo')` = `0x456D6F6F`, qua được
`validId` — mà vẫn sập. Nên vấn đề **không phải dữ liệu, mà là chính hai native**.

Trong `grantBuyingPower`, sau khi loại id rác, chỉ còn đúng hai lời gọi đáng ngờ:

```lua
GetUnitGoldCost(uid)
GetUnitWoodCost(uid)
```

Phần còn lại là `GetPlayerState` / `SetPlayerState` / `Player()` — những native
dùng ở khắp nơi trong map này và chưa bao giờ gây chuyện.

## Quyết định

**Không gọi hai native đó.** `build.py` chặn cứng, không chỉ cảnh báo:

```
[cam] GetUnitGoldCost o dong N -- ACCESS_VIOLATION ngay ca voi unit id hop le
[loi] khong ghi file.
```

## Không biết giá vẫn hoàn tiền chính xác được

Hoá ra chưa bao giờ cần biết giá. Cái cần là **đưa số tiền trở về nguyên trạng**:

1. Lúc khởi động, đặt vàng/gỗ của mỗi người bằng một con số cố định — "ví tiền" —
   và ghi nhớ nó.
2. Sau khi mua, **đặt lại** đúng con số đó.

Trừ bao nhiêu cũng trở về nguyên trạng, mà không hỏi câu nào. Giải pháp còn đơn
giản hơn cái cũ, và ít phụ thuộc engine hơn.

## Phương án đã loại

**Hardcode giá vào CFG.** Chạy được, nhưng sai ngay khi đổi hero, và sai âm thầm:
hoàn thừa thì người chơi được tiền chùa, hoàn thiếu thì mất tiền không rõ lý do.

**Đọc giá từ Object Editor lúc build.** Về lý thì làm được — giá nằm trong
`war3map.w3u`. Nhưng phải viết bộ đọc định dạng nhị phân cho một thứ mà cách đặt
lại ví tiền đã giải quyết xong.

## Hệ quả

**Người chơi thấy 1 000 vàng và 500 gỗ** trong khi map chưa có nền kinh tế. Đây
là cái giá của "miễn phí giả". Muốn 0 vàng thật thì phải nhân bản ba hero trong
Object Editor với `Gold Cost` = 0, rồi đặt `TAVERN_FREE = false` và ví tiền = 0.

**Ví phải đủ mua con đắt nhất.** Hero tavern thường 425 vàng 100 gỗ; `1000/500`
là dư dả. Thêm hero đắt hơn thì phải nâng ví.

## Ba lần đoán, một lần đọc

Ghi lại để lần sau khỏi lặp. Ba chẩn đoán đầu đều sai vì suy từ triệu chứng:

1. *"Sập lúc mua hero"* — từ một ảnh chụp màn hình. Log cho thấy game chỉ sống
   7 giây, không đủ đi tới Tavern.
2. *"Sai tên trường Blz API"* — có lý, nhưng không phải. Vẫn đáng sửa.
3. *"`FourCC` trả hai giá trị"* — **đúng**, nhưng chỉ là một trong hai lỗi.

Cả ba chỉ thu hẹp được sau khi có **vết ghi ra file**. Thứ chấm dứt việc đoán là
`CFG.TRACE`, không phải suy luận giỏi hơn.

Giữ `CFG.TRACE` lại. Gặp lỗi im lặng hay sập thì bật lên **trước**, đừng đoán.
