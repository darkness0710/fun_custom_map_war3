# Bảng nhân vật — phím R

> **Viền nút tự vẽ, không mượn backdrop có sẵn** *(2026-09-16)*. Hai lần hỏng
> trước khi ra cách này:
>
> 1. `ScoreScreenTabButtonTemplate` (template của `GLUEBUTTON`) **không vẽ gì**
>    — nút chỉ là chữ trôi giữa nền, không ai biết bấm vào đâu.
> 2. Đổi sang `EscMenuBackdrop`, template đang vẽ khung bảng. Đó là backdrop
>    **9 ô**: bốn góc và bốn cạnh của nó là *ảnh có kích thước riêng*, không co
>    lại theo frame. Đắp lên một nút cao `0.026` thì mỗi nút mở ra một cái
>    khung gỗ to bằng nửa màn hình — cả bảng biến thành cái cũi gỗ.
>
> Bài học: **một backdrop dùng cho khung không dùng lại được cho nút.** Giờ nút
> tự vẽ bằng hai ô màu đặc lồng nhau — ô ngoài là viền, ô trong thụt vào
> `CFG.PANEL_BTN_BORDER` là ruột. Ô màu đặc co lại được ở mọi kích thước.
>
> Và chỉ dùng hai số hiệu `TeamColor` **đã thấy vẽ ra màu** trên ảnh chụp: `04`
> vàng, `27` đen. Đoán sai số hiệu thì ra ô **xanh lá** — đúng lỗi mà
> `BTNRingViolet` đã dính.

> **Trạng thái:** Đã cài — **cả bốn thẻ có nội dung**
> **Cập nhật:** 2026-09-16
> **Code:** [1_panel.lua](../../src/4_giao_dien/1_panel.lua) (khung),
> [3_linhcan.lua](../../src/2_nguoi_choi/3_linhcan.lua),
> [4_skill.lua](../../src/2_nguoi_choi/4_skill.lua) (nội dung)
> **Khoá CFG:** `PANEL_X` `PANEL_Y` `PANEL_W` `PANEL_GRID` `PANEL_GRID_TEX`
> **Liên quan:** [ky-nang.md](ky-nang.md), [kinh-te.md](kinh-te.md)

> **Đã cài tới đâu.** Khung, bốn thẻ, phím **E** và lệnh lui `-c` đều chạy, và
> cả bốn thẻ có nội dung thật.
>
> **Hai kiểu thân bảng**, không phải một —
> [ADR 0016](../05-quyet-dinh/0016-bang-phim-e-hai-kieu-than.md). Thẻ khai báo
> *dữ liệu*, bảng lo *bố cục*; trước đây ngược lại, mỗi thẻ phải tự khai báo bề
> ngang từng cột.
>
> Chiều cao bảng **suy ra từ số mục của thẻ dài nhất**, không gõ tay — nên
> `CFG.PANEL_H` không tồn tại.

## Ý tưởng

Bấm **E** mở một bảng frame che giữa màn hình, có bốn thẻ:

```
┌──────────────────────────────────────────────┐
│  [Kỹ Năng] [Trang Bị] [Linh Căn] [Pháp Khí]  │
├──────────────────────────────────────────────┤
│                                              │
│              nội dung thẻ đang mở            │
│                                              │
├──────────────────────────────────────────────┤
│  Linh Khí: 12 400                    [Đóng]  │
└──────────────────────────────────────────────┘
```

Hạ tầng đã có sẵn: [3_skillframe.lua](../../src/4_giao_dien/3_skillframe.lua) và
[2_heroframe.lua](../../src/4_giao_dien/2_heroframe.lua) đã vẽ được panel, nút, icon, và đã
xử lý đồng bộ nhiều người. Bảng này dùng lại đúng khuôn đó.

## Bốn thẻ, bốn hệ nâng cấp

Mỗi thẻ là một nguồn sức mạnh trong ngân sách ×967 —
[kinh-te.md](kinh-te.md). Không thẻ nào là trang trí.

| Thẻ | Nhân | Mua bằng | Cấu trúc |
|---|---|---|---|
| **Linh Căn** | ×19.7 | **Linh Khí** | 20 bậc tu vi, ×1.17/bậc | `focus` |
| **Kỹ Năng** | ×2.4 | **Ngộ Tính** | 7 kỹ năng × 10 cấp, +10%/cấp | `list` |
| **Trang Bị** | ×8.3 | **Linh Khí** | 6 ô × 10 cấp, +4%/cấp | `list` |
| **Pháp Khí** | ×2.5 | **Tinh Thạch** | 5 món, mua một lần | `list` |

Ba đồng tiền, ba loại quái —
[ADR 0015](../05-quyet-dinh/0015-ba-dong-tien-ba-loai-quai.md). Linh Căn và Trang
Bị cố ý dùng chung ví; đó là lựa chọn chính mỗi wave.

## Hai kiểu thân bảng

Bốn hệ không cùng hình dạng, nên bảng có hai kiểu thân chứ không một —
[ADR 0016](../05-quyet-dinh/0016-bang-phim-e-hai-kieu-than.md).

**`kind = "focus"`** — một thẻ lớn, **một** hành động. Dùng cho Linh Căn, vì
trong 20 bậc chỉ có đúng bậc kế tiếp là mua được.

```lua
info(pid) -> { tieuDe, phu, dong = {{nhan, truoc, sau}, ...},
               tienDo, ghiChu, nut, batNut }
action(pid)
```

**`kind = "list"`** — danh sách mục: icon, tên, mô tả, trạng thái, một nút rộng.
Dùng cho ba thẻ còn lại.

```lua
soMuc                         -- bang này cần mấy dòng
items(pid) -> { { icon, ten, mota, trangThai, nut, batNut }, ... }
itemAction(pid, i)
```

Thêm một hệ mới = trả về một danh sách mục. Không phải dựng thêm bảng, không phải
đo bề ngang cột.

## Nhưng đừng làm cả bốn cùng lúc

Thiết kế xong không có nghĩa là cài cùng lúc. Thứ tự đề xuất:

1. **Linh Căn** — một danh sách 20 bậc, một nút đột phá, một con số nhân. Đơn giản
   nhất về giao diện mà lại là ×20, tức **nguồn sức mạnh lớn nhất**. Làm trước thì
   đường cong địch có đối trọng ngay.
2. **Kỹ Năng** — đã có 21 kỹ năng thiết kế sẵn
   ([thiet-ke-hero.md](thiet-ke-hero.md)), chỉ cần nối vào `SetUnitAbilityLevel`.
3. **Trang Bị** — cần có món đồ thật trong Object Editor trước.
4. **Pháp Khí** — cần Tinh Thạch, cần boss, cần 5 hiệu ứng riêng. Làm cuối.

Một thẻ mở ra trống rỗng tệ hơn là chưa có thẻ đó. Chỉ thêm tab khi nội dung của
nó đã chạy được.

## Thẻ Linh Căn — **đã cài**

> Code: [3_linhcan.lua](../../src/2_nguoi_choi/3_linhcan.lua). Mở bằng `-lc`.
> Không vẽ được frame thì tự lùi về thông báo chữ, và `-lc up` đột phá
> thẳng không cần bảng.

```
Tu vi hiện tại:  Trúc Cơ  (bậc 3/20)
Sức mạnh:        ×1.37
                                        [ Đột phá · 2 464 ]
Bậc kế:          Kim Đan   ×1.60
```

Một nút. Mờ đi khi không đủ Linh Khí. Giá lấy từ bảng
[kinh-te.md](kinh-te.md): `439 × 1.412^(bậc-1)`.

**Nhân vào đâu?** Tăng chỉ số hero trực tiếp — `SetHeroStr/Agi/Int` cộng dồn theo
bậc. Không đụng tới cấp độ hero, nên `LOCK_HERO_XP` và mốc máu nhà chính không
phải sửa gì.

> **Không nhân thẳng chỉ số lên ×1.17.** Sát thương hero = *sát thương nền + chỉ
> số*, nên phần nền làm loãng nhân số: đẩy chỉ số ×19.7 chỉ cho **×10.4** sát
> thương — thiếu một nửa. Phải giải ngược để bù:
>
> ```
> chiSo(r) = (DMG_BASE + STAT_BASE) × STEP^(r-1) − DMG_BASE
> ```
>
> `CFG.LINHCAN_DMG_BASE` và `LINHCAN_STAT_BASE` phải khớp hero thật trong Object
> Editor thì nhân số mới đúng. Bảng `-lc` in ra nhân số thực để đối chiếu.

## Thẻ Kỹ Năng

```
[icon]  Dậm Đất            Cấp 4/10        [ Nâng · 472 ]
        Sát thương vùng quanh Hart
```

Bảy dòng. Nâng cấp gọi `SetUnitAbilityLevel(hero, abilId, capMoi)`.

> Điều này đổi một quyết định cũ: ability phải đặt `Stats - Levels = 10` trong
> Object Editor, không phải 1. **21 ability × 10 cấp = 210 dòng số liệu** — lý do
> rất mạnh để làm 3 kỹ năng trước rồi mới nhân rộng.

## Thẻ Trang Bị

Warcraft III **đã có sẵn 6 ô đồ** trên hero. Đừng vẽ lại cái đó — vẽ lại là tự
nhận phần nhặt, rơi, xếp chồng mà engine đã làm xong.

Thẻ này chỉ là **nơi mua và nâng cấp**; đồ đã mua nằm trong túi gốc.

## Thẻ Pháp Khí

Năm món, mỗi món **đổi cách chơi** chứ không cộng chỉ số — ba hệ kia đã lo chỉ số
rồi. Mua bằng Tinh Thạch, chỉ rơi từ boss.

Thua một boss là mất một Pháp Khí. Đó là trọng lượng thật của việc thua.

## Ba điều kỹ thuật phải xử lý

**Phím E.** Warcraft III không có sự kiện "bấm phím" trong 1.31 theo cách đơn giản.
Hai đường:

| Cách | Được | Mất |
|---|---|---|
| `BlzTriggerRegisterPlayerKeyEvent` | Đúng ý "bấm E" | Là native Blz, **chưa xác minh trên 1.31.1** |
| Lệnh chat `-c` | Chắc chắn chạy | Phải gõ, kém tiện hơn nhiều |
| Một ability trên command card | Chắc chắn chạy, bấm một nút | Chiếm một trong 7 ô |

Đề xuất: **dò xem native phím có tồn tại không** (thêm vài dòng vào file vết là biết),
dùng nó nếu có, lùi về lệnh chat nếu không. Đừng đổi lấy một ô kỹ năng.

**Bảng mở ra thì game vẫn chạy.** Frame không dừng game. Người chơi mở bảng giữa lúc
quái đang đánh là hero đứng chịu đòn. Hai lựa chọn: chấp nhận (mở bảng là một rủi ro,
phải chọn lúc), hoặc chỉ cho mở giữa hai wave. Đề xuất chấp nhận — nó tạo thêm một
quyết định thật.

**Đồng bộ nhiều người.** Bấm nút frame chỉ nổ trên máy người bấm. Mọi thay đổi phải đi
qua `BlzSendSyncData` như hai bảng hiện có. Đây không phải chuyện làm sau — sai là
lệch máy và đá người chơi ra khỏi trận.

## Chưa quyết

- Bảng mở ra có tạm dừng gì không (tạm dừng hero? làm chậm quái?).
- Mỗi người mở bảng riêng của mình, hay xem được build của người khác.
- Có nút hoàn điểm không.

## Hình học: hai số ràng buộc nhau

**`PANEL_ROW` phải lớn hơn `PANEL_BTN_H`.** Trước đây dòng cao `0,021` còn nút
`0,024`, nên nút của hai dòng kề nhau **chồng lên nhau 0,003** — bấm dòng này ăn
vào dòng kia. Đó chính là lỗi "click bị trượt". Giờ `0,048` và `0,026`.

**Chiều cao bảng suy ra từ số mục của thẻ dài nhất**, không gõ tay:

```lua
-- tinh luc startPanel(), tu truong soMuc cua tung the
MAX_ITEMS = max(tab.soMuc)
panelH()  = PAD + TAB_H + GAP + HEAD_H + GAP + MAX_ITEMS*ROW + GAP + FOOT + PAD
```

Thêm một hệ 9 mục thì bảng tự rộng ra. Trước đây `ROWS` tăng từ 8 lên 10 mà
`CFG.PANEL_H` đứng yên, hai dòng cuối tràn ra ngoài khung.

## Kích thước: bảng không nhỏ, nội dung mới nhỏ

Đo ở 1080p, bản trước:

| | Cũ | Mới |
|---|---|---|
| Khung | 828 × 709 px | 1008 × 907 px |
| Một dòng | 43 px | 86 px |
| Icon | **32 px** | 65 px |
| Nút | **50 × 36 px** | 189 × 47 px |
| Cỡ chữ | một cỡ cho mọi dòng | ba cấp |
| Nền | `TeamColor27` — ô màu **đặc 1×1 px** | template FDF có viền |

Khung cũ chiếm 66% chiều cao màn hình mà chứa icon 32 px và nút 50 px. Vấn đề
không phải "bảng bé" — là **mật độ sai**.

## Mỗi mục: icon, hai dòng chữ, một nút rộng

| | |
|---|---|
| Icon | Lấy thẳng từ ability bằng `BlzGetAbilityIcon`, **không gõ đường dẫn** — gõ sai một chữ là hiện ô xanh lá mà không biết sai ở đâu |
| Nút | Rộng `PANEL_BTN_W`, chứa **chữ *và* giá** (`NANG   178`). Một dấu `+` không nói được nó tốn bao nhiêu |
| Nút thiếu tiền | **Mờ đi, không ẩn.** Ẩn là giấu mất giá, mà giá chính là thứ cần để biết phải để dành bao nhiêu |
| Vạch kẻ | Kẻ xen kẽ, và **chỉ kẻ dòng có nội dung**. Tắt bằng `CFG.PANEL_GRID` |
| Chữ | Mọi frame chữ **đặt kích thước và canh lề**. Không đặt thì Warcraft căn giữa quanh điểm neo và chữ dài tràn sang cột bên |
