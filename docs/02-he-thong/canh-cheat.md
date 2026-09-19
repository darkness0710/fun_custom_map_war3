# Hệ thống: Canh cheat có sẵn của Warcraft

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-19
> **Code:** [13_cheatguard.lua](../../src/2_player/13_cheatguard.lua)
> **Khoá CFG:** `CHEAT_WATCH` `CHEAT_TICK` `CHEAT_SLACK` `CHEAT_ACTION`

## Nói thẳng trước: KHÔNG chặn được

`greedisgood`, `whosyourdaddy`, `iseedeadpeople`… do **chính engine Warcraft**
xử lý. Chúng không đi qua trigger nào của map, và **không có native nào tắt
chúng**. Bất cứ ai hứa "chặn cheat bằng trigger" là nhầm.

Cái làm được là **đo hậu quả**. Hệ này không bắt lúc gõ — nó bắt dấu vết để lại.

## Hai đường đo được

### 1. Sổ cái tiền — bắt `greedisgood` và họ hàng

**Vàng và Gỗ sống trên thanh tài nguyên của Warcraft**
(`PLAYER_STATE_RESOURCE_GOLD` / `_LUMBER`), và `greedisgood` bơm thẳng vào đó.

Nhưng map thì chỉ ghi qua `addGold` / `addLumber` — **hai chỗ duy nhất gọi
`SetPlayerState` trong cả cây nguồn**, đã quét để chắc. Nên:

```
mỗi lần map ghi  ->  ghi luôn con số đó vào sổ cái
mỗi 2 giây       ->  so thật với sổ cái
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

## Phản ứng: chỉ báo ra

| `CHEAT_ACTION` | Làm gì |
|---|---|
| `"off"` | Đo nhưng im lặng, chỉ ghi file vết |
| `"announce"` | Báo cho **cả bàn đồ** *(mặc định)* |

**Không có lựa chọn "kết thúc ván".** Một phép đo có thể sai, và huỷ ván của ba
người vì một lần đo sai là cái giá quá đắt. Trong co-op, **cho người khác đọc
được** mới là phần có giá trị — báo riêng cho người vừa gõ là vô nghĩa, họ biết
họ vừa gõ gì.

Báo **một lần cho mỗi kiểu**, không báo mỗi nhịp: gõ `greedisgood` rồi để yên
thì lệch tồn tại mãi mãi, và báo mỗi 2 giây biến phát hiện thành tiếng ồn — mà
tiếng ồn thì người ta tắt đi chứ không sửa.

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
cheat: canh so cai vang/go + bat tu, moi 2.0s, phan ung 'announce'
native [Canh cheat (13_cheatguard)] co 2/2
```

Nếu nhóm native báo **thiếu `BlzIsUnitInvulnerable`** thì đường bắt
`whosyourdaddy` tắt, sổ cái tiền vẫn chạy.

Lúc bắt được:

```
cheat: pid 0 -- gold -- so cai 1250, that 501250
```

← [Kinh tế](kinh-te.md) · [Lệnh debug](../04-map/lenh-debug.md)
