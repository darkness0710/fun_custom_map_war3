# 0024 — Món cộng điểm thì leo theo Tu Vi, món cộng % thì để phẳng

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-18

## Bối cảnh

Trang Bị chạy khung từ 2026-09-17 nhưng `gearMult` / `gearStat` trả về `1.0` và
`0` — người chơi đốt đá leo 100 bậc và nhận về **đúng không gì cả**.

Lúc ngồi điền chỗ trống đó thì lộ ra một câu hỏi không né được: các món giờ chia
làm hai loại rất khác nhau về bản chất.

- **Cộng điểm** (Mũ → Int, Áo → Str, Giày → Agi, Dây Chuyền → cả ba): cộng một
  số vào chỉ số hero.
- **Nhân phần trăm** (Kiếm → %sát thương gây ra, Khiên → %đòn đánh nhận vào,
  Áo Choàng → %phép nhận vào): nhân vào một con số khác.

Cho cả hai cùng một đường cong là sai, và sai theo hai hướng ngược nhau.

Đây đúng là cái bẫy [ADR 0010](0010-giap-khong-nam-trong-duong-cong.md) đã phải
viết ra cho quái — *"giáp là máu, viết bằng đơn vị khác"* — lặp lại một tầng trên.

## Quyết định

**Bốn món cộng điểm LEO theo `CULT_STAT_STEP`. Ba món cộng % để PHẲNG.**

```lua
-- cong diem: nhan theo canh gioi, y het duong cong Tu Vi
value(T, L) = GEAR_STAT_BASE * ( 5*(STEP^(T-1) - 1)/(STEP-1) + L*STEP^(T-1) )

-- nhan %: tuyen tinh theo SO BAC da di, khong dinh gi toi canh gioi
pct(T, L)   = MAX * ((T-1)*5 + L) / 100
```

Lý do một câu: **món cộng % đã tự leo sẵn.** Giá trị của `+20% sát thương` tỉ lệ
với toàn bộ sức mạnh còn lại, mà phần đó đã leo ×146 theo Tu Vi. Cho nó leo thêm
một lần nữa là ×146 **bình phương**.

Ngược lại, `+100 Str` ở cảnh giới 20 đáng đúng bằng `+100 Str` ở cảnh giới 1,
trong khi quái đã ×146 — không nhân tay thì nửa sau ván nó thành hạt bụi.

Dùng **chính** `CFG.CULT_STAT_STEP`, không gõ `1.30`: đổi đường cong Tu Vi thì
trang bị tự đi theo, giống cách thẻ chỉ số của Cơ Duyên đã làm.

### Ngân sách

`GEAR_STAT_BASE = 1.5` chọn để một món đi trọn 100 bậc đáng **4 726 điểm** =
**19.5%** Tu Vi cả ván (24 198). `GEAR_DMG_MAX = 0.20` và
`GEAR_MITIG_MAX = 0.25` đặt để ba món "nhân" ngang ngân sách đó.

## Phương án đã loại

**Khiên cộng điểm giáp.** Đây là phương án hiển nhiên và là thứ đầu tiên thử.
Bỏ vì đo ra: `EHP = máu × (1 + 0.06 × giáp)`, nên để ngang ngân sách một món
khác, Khiên chỉ được cộng **2.8 điểm giáp cả ván** — tức `0.03` mỗi bậc. Một con
số không hiển thị nổi cho người chơi, và 100 bậc mà mỗi bậc cộng 0.03 thì cái
thang mất nghĩa. Giáp mạnh đến mức **không chia được thành 100 bậc**.

Đổi sang `%` chống chịu thì cùng ngân sách đó trả về một con số đọc được, và bỏ
luôn được việc phải mượn trường của một ability làm vật mang.

**Dùng `gearMult` nhân thẳng vào `BlzSetUnitBaseDamage`.** Bỏ hẳn, `API.gearMult`
đã xoá. `heroRecompute` đã phải gỡ `BlzSetUnitArmor` và `BlzSetUnitBaseDamage`
một lần rồi vì chúng đóng băng phần chỉ số — giáp đứng ở 2 trong khi Agi lên 511.
Món Kiếm cộng `%` nên nhân được ngay trong `onDamaged` và `skillDamage`, **không
cần vật mang nào cả**.

**Cho cả các món cùng một đường cong lũy thừa.** Đơn giản hơn để viết, và là thứ
gần như chắc chắn sẽ có người đề xuất lại. Nó làm Kiếm và Khiên chạy mất: đến
cảnh giới 20, `+20%` đã leo sẵn ×146 mà còn nhân thêm ×146 nữa.

**Chỉ dùng ba chỉ số Str/Agi/Int, bỏ hẳn nhóm %.** An toàn nhất, không cần
`onDamaged`. Bỏ vì khi đó các món chỉ còn **ba** vai thật — Kiếm và Áo Giáp sẽ là
cùng một thứ, vì Str cho cả sát thương lẫn máu. Tám món mà ba vai thì bảy ô kia
chỉ là trang trí.

## Hệ quả

- **Thêm một món là phải quyết nó thuộc loại nào.** Không có mặc định. Một món
  `role` mới phải vào đúng một trong hai nhánh của `statOf` / `pctOf`.
- **Hai con số `GEAR_MITIG_MAX` dựa trên giả định chưa đo.** `0.25` giả định quái
  đánh 60% vật lý / 40% phép. Chưa đếm lần nào. Đây là hai số đầu tiên phải xem
  lại sau trận chơi thử đầu — bật `CFG.TRACE`, cộng dồn theo
  `BlzGetEventDamageType` rồi chia.
- **Thiếu `BlzGetEventDamageType` thì Áo Choàng không ăn gì.** Bản 1.31.1 có native
  này trong bảng thăm dò nhưng chưa xác nhận. Code ghi vết **một lần** rồi coi
  mọi đòn là vật lý, chứ không im lặng — nếu không thì "Áo Choàng vô dụng" sẽ bị chẩn
  nhầm thành lỗi cân bằng.
- **Khiên và Áo Choàng nhân với nhau, không cộng.** Cộng thì hai nguồn đủ mạnh sẽ chạm
  100% và hero bất tử. Vẫn có `GEAR_MITIG_CAP` chặn cứng thêm một lần nữa.
- **Bảng cân bằng trong `docs/` phải tính lại mỗi khi đổi một trong bốn khoá**
  `GEAR_STAT_BASE` `GEAR_DMG_MAX` `GEAR_MITIG_MAX` `CULT_STAT_STEP`. Con số trong
  tài liệu là **dẫn xuất**, không phải nguồn.
