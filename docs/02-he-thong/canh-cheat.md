# Hệ thống: Canh cheat có sẵn của Warcraft

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-19
> **Code:** [13_cheatguard.lua](../../src/2_player/13_cheatguard.lua)
> **Khoá CFG:** `CHEAT_WATCH` `CHEAT_TICK` `CHEAT_SLACK` `CHEAT_ACTION`

## Không chặn được ĐẦU VÀO — nhưng thu hồi được HẬU QUẢ

`greedisgood`, `whosyourdaddy`, `iseedeadpeople`… do **chính engine Warcraft**
xử lý. Chúng không đi qua trigger nào của map, và **không có native nào tắt
chúng**. Bất cứ ai hứa "chặn cheat bằng trigger" là nhầm.

Nhưng sổ cái giữ **con số đúng**, nên đặt lại thanh tài nguyên về con số đó là
**xoá sạch phần ăn cắp**. `greedisgood` vẫn "chạy" — chỉ là vô dụng sau nửa
giây.

```
CFG.CHEAT_TICK = 0.5
```

Nhịp này chính là **bề rộng cửa sổ** người chơi còn giữ được tiền ăn cắp. 2 giây
đủ để bấm mua một món; nửa giây thì không.

## Hai đường đo được

### 1. Sổ cái tiền — bắt `greedisgood` và họ hàng

**Vàng và Gỗ sống trên thanh tài nguyên của Warcraft**
(`PLAYER_STATE_RESOURCE_GOLD` / `_LUMBER`), và `greedisgood` bơm thẳng vào đó.

Nhưng map thì chỉ ghi qua `addGold` / `addLumber` — **hai chỗ duy nhất gọi
`SetPlayerState` trong cả cây nguồn**, đã quét để chắc. Nên:

```
mỗi lần map ghi  ->  ghi luôn con số đó vào sổ cái
mỗi 0.5 giây     ->  so thật với sổ cái
thật > sổ cái    ->  có kẻ thứ ba ghi vào
```

**Linh Khí và Đá không cần canh** — chúng sống trong `S.p[pid]`, cheat không với
tới. Đó là một lợi thế tình cờ của việc thanh tài nguyên chỉ có hai ô.

### 2. Bất tử — bắt `whosyourdaddy`

Map **không bao giờ** đặt hero bất tử. Đã quét cả cây: `SetUnitInvulnerable`
chỉ xuất hiện ở **pet** và **nhà chính**. Nên `BlzIsUnitInvulnerable(hero)` trả
`true` là cheat, không có cách hiểu khác.

## Không báo nhầm là yêu cầu số một

Lệnh `-debug` đẩy cả bốn đồng tiền lên 999 999. Nó **không** làm hệ này nổ, vì
nó gọi `API.addGold` — sổ cái tự khớp.

> ⚠ **Ràng buộc cho người sửa sau:** bất cứ đường cấp tiền **mới** nào cũng phải
> đi qua `addGold` / `addLumber`. Gọi thẳng `SetPlayerState` là tố oan người
> chơi, và tố oan thì tệ hơn bỏ lọt nhiều.

Ba chỗ khác cũng để tránh báo nhầm:

- **Mốc đầu là con số đang có, không phải `0`.** Warcraft phát vàng/gỗ khởi đầu
  theo `war3map.w3i` trước khi một dòng Lua nào chạy. Lấy `0` làm mốc là cả đội
  bị tố ngay giây đầu.
- **Chỉ bắt khi THỪA ra.** Thiếu đi thì nhận con số mới làm mốc — có thể là một
  đường trừ tiền chưa kịp ghi sổ, và tố oan vì *thiếu* tiền là kiểu sai tệ nhất.
- **Bắt xong nhận con số mới làm mốc**, để không đếm lại cùng một lệch mãi.

## Phản ứng

| `CHEAT_ACTION` | Làm gì |
|---|---|
| `"off"` | Đo nhưng im lặng, chỉ ghi file vết |
| `"announce"` | Báo cho cả bàn đồ, **không** đụng tới tiền |
| `"revert"` | Báo + **thu hồi** về đúng con số sổ cái *(mặc định)* |

**Thu hồi an toàn vì chỉ trừ phần thừa.** Thanh tài nguyên đang *thấp* hơn sổ
cái thì không đụng vào.

**Đây là chỗ thứ ba được gọi `SetPlayerState`**, ngoài `addGold`/`addLumber`.
Ngoại lệ này an toàn vì nó chỉ đặt về **đúng** con số sổ cái đang giữ — không
tạo ra một nguồn ghi mới, chỉ xoá một nguồn ghi lạ. Và **không** gọi `addGold`:
`addGold` cộng *thêm* rồi ghi lại sổ cái, tức lấy con số ăn cắp làm mốc.

Với `whosyourdaddy` thì gỡ bất tử bằng `SetUnitInvulnerable(hero, false)`. Phần
"một đòn giết ngay" của cheat đó **không gỡ được** — nhưng mất phần bất tử là
người chơi vẫn chết được, tức vẫn thua được.

**Không có lựa chọn "kết thúc ván".** Một phép đo có thể sai, và huỷ ván của ba
người vì một lần đo sai là cái giá quá đắt. Trong co-op, **cho người khác đọc
được** mới là phần có giá trị — báo riêng cho người vừa gõ là vô nghĩa, họ biết
họ vừa gõ gì.

Báo **một lần cho mỗi kiểu**, nhưng **thu hồi thì mọi lần**. Gõ `greedisgood`
mười lần thì mười lần bị lấy lại, mà chỉ một dòng chữ — báo mỗi nửa giây biến
phát hiện thành tiếng ồn, và tiếng ồn thì người ta tắt đi chứ không sửa.

## Cái KHÔNG bắt được

| Cheat | Vì sao bỏ |
|---|---|
| `thereisnospoon` *(vô hạn mana)* | Đo được về lý thuyết — so mana hiện tại với max qua nhiều lần cast — nhưng rất dễ báo nhầm với hồi mana từ trang bị. Không đáng đổi |
| `iseedeadpeople` *(mở map)* | Không có native nào đọc được tầm nhìn của người chơi |
| `allyourbasearebelongtous` | Engine tuyên bố thắng ngay; không còn gì để bảo vệ |
| `warpten` · `iocainepowder` · `pointbreak` | Không liên quan — map này không xây nhà, không có food |

## Cách kiểm

Dòng này trong `DarknessTrace.txt` lúc vào map:

```
cheat: canh so cai vang/go + bat tu, moi 0.5s, phan ung 'revert'
native [Canh cheat (13_cheatguard)] co 2/2
```

Nếu nhóm native báo **thiếu `BlzIsUnitInvulnerable`** thì đường bắt
`whosyourdaddy` tắt, sổ cái tiền vẫn chạy.

Lúc bắt được:

```
cheat: pid 0 -- gold   -- so cai 0, that 222 -- da thu hoi
cheat: pid 0 -- lumber -- so cai 0, that 222 -- da thu hoi
```

← [Kinh tế](kinh-te.md) · [Lệnh debug](../04-map/lenh-debug.md)
