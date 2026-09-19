# Hệ thống: Khoá hero — kinh nghiệm & kỹ năng

> **Trạng thái:** Đã cài
> **Cập nhật:** 2026-09-14
> **Code:** [1_player.lua](../../src/2_player/1_player.lua)
> **Khoá CFG:** `LOCK_HERO_XP` `STRIP_SKILL_POINTS` `HERO_REMOVE_ABILITIES` `HERO_XP_SWEEP`

## Nó là gì

Mọi hero trên bản đồ bị khoá hai thứ, không riêng phe nào — nhà chính, hero người
chơi, và cả hero của phe địch sau này:

| Khoá | Bằng gì |
|---|---|
| Không lên cấp | `SuspendHeroXP(u, true)` |
| Không nâng kỹ năng | Rút sạch điểm kỹ năng |

`SuspendHeroXP` chặn việc **nhận** kinh nghiệm, nên hero đứng yên ở cấp nó được
tạo ra. Gọi nhiều lần lên cùng một unit là vô hại.

## Xoá kỹ năng gốc: code không làm được

Đã đo, không phải phỏng đoán. Hai hướng runtime đều thất bại:

**Rút điểm kỹ năng** chạy được (`rut 1 diem (ok)`) nhưng **nút + vẫn còn**. Nút đó
không phụ thuộc số điểm.

**`UnitRemoveAbility`** trả về `false` cho cả 12 ID kỹ năng gốc, trên cả hai hero.
Vì kỹ năng **chưa học** không phải ability gắn trên unit — chúng nằm trong
`Techtree - Hero Abilities` của *loại* unit.

Và 1.31.1 không có `BlzGetUnitAbilityByIndex` để liệt kê lấy ID thật.

> **Cách duy nhất:** Object Editor → Units → từng hero →
> `Techtree - Hero Abilities` → xoá sạch. Hero không còn gì để học thì nút **+**
> biến mất.
>
> Chi tiết và số liệu đo:
> [ADR 0008](../05-quyet-dinh/0008-ky-nang-hero-phai-sua-o-object-editor.md).

Hai khoá trong code vẫn giữ, nhưng đúng vai trò của chúng:
`STRIP_SKILL_POINTS` chặn việc học thật, `HERO_REMOVE_ABILITIES` (mặc định rỗng)
gỡ được ability unit **thật sự đang có**.

## Thêm kỹ năng tự tạo — hai đường, chọn một

| Muốn gì | Làm sao | Cấu hình |
|---|---|---|
| **Luôn có sẵn**, không lên cấp | Để trống `Techtree - Hero Abilities`, gọi `UnitAddAbility(u, id('A000'))` ngay sau `CreateUnit` trong [2_heropick.lua](../../src/2_player/2_heropick.lua) | Giữ nguyên hiện tại |
| **Học bằng điểm** như hero thường | Đặt ability tự tạo vào `Techtree - Hero Abilities` | `STRIP_SKILL_POINTS = false`, `LOCK_HERO_XP = false` |

Đường thứ nhất hợp với hướng hiện tại của map — không hero nào lên cấp. Ability
thêm bằng `UnitAddAbility` **không tốn điểm kỹ năng** nên không đụng gì tới phần
khoá.

## Hai tầng

**Khoá lúc tạo.** Mọi chỗ code này tự tạo hero đều gọi `API.lockHero(u)` ngay
sau `CreateUnit`.

**Quét định kỳ.** Cứ `CFG.HERO_XP_SWEEP` giây quét mọi unit trong vùng chơi được
và khoá con nào là hero.

Tầng thứ hai cần thiết vì hero có thể xuất hiện ở chỗ code này không gọi tới:
unit đặt sẵn trong World Editor, hero triệu hồi, hero của đợt quái sau này. Khoá
lúc tạo chỉ bắt được những gì ta tự tạo.

## Luật

**L1. Khoá chặn nhận kinh nghiệm, không hạ cấp.**
Hero tạo ra ở cấp mấy thì đứng ở cấp đó. Muốn đổi cấp thì phải `SetHeroLevel`
riêng, khoá này không làm.

**L2. Quét lại là vô hại.**
`SuspendHeroXP` và việc rút điểm đều gọi lặp được, nên bộ quét chạy bao nhiêu lần
cũng không sao.

**L2b. Không có native đọc số điểm kỹ năng.**
Nên phải trừ dần từng điểm tới khi `UnitModifySkillPoints` báo không trừ được
nữa. Vòng lặp chặn cứng ở 20 lần để không bao giờ treo, bất kể native trả về gì.

**L3. Nhà chính khoá TRƯỚC khi đặt máu.**
Xem [nha-chinh.md](nha-chinh.md) — máu hero suy ra từ Sức mạnh, lên cấp là tính
lại, phá mất mốc `HOUSE_HP`. Vì thứ tự quan trọng nên nhà chính vẫn giữ lời gọi
riêng (`CFG.HOUSE_SUSPEND_XP`) chứ không dựa vào bộ quét.

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `LOCK_HERO_XP` | Không lên cấp | |
| `STRIP_SKILL_POINTS` | Rút sạch điểm kỹ năng | Làm nút **+** biến mất |
| `HERO_REMOVE_ABILITIES` | Gỡ ability unit **đang thật sự có** | Rỗng. **Không** gỡ được kỹ năng chưa học |
| `HERO_XP_SWEEP` | Giây giữa hai lần quét | `0` = chỉ khoá lúc tạo, không quét |

## Ràng buộc kỹ thuật

**Bộ quét duyệt toàn bộ unit trong vùng chơi được** mỗi lần chạy. Hiện map có
vài unit nên không đáng kể. Khi có đợt quái đông, cân nhắc nâng `HERO_XP_SWEEP`
lên hoặc bỏ hẳn bộ quét và khoá ngay tại chỗ sinh quái — lúc đó
đã kiểm soát được mọi nguồn tạo hero rồi.

**Dùng `FirstOfGroup` + `GroupRemoveUnit`** để duyệt, không dùng `ForGroup` —
tránh gọi hàm lồng nhau trong lúc nhóm đang bị duyệt.

## Cách kiểm

Bật `CFG.TRACE`, vào map, đọc dòng `lockHero: quet dau tien khoa N hero`. Ngay
sau khi khởi động, `N` phải bằng số hero đang có trên map (ít nhất là 1 — nhà chính).

Trong game cần thấy:

1. Giết vài unit cạnh hero: thanh kinh nghiệm không nhúc nhích.
2. Nút dấu **+** — chỉ mất sau khi xoá `Techtree - Hero Abilities` trong Object
   Editor. Code không làm được, xem phần trên.

> **Đã xong 2026-09-15.** Cả ba hero có `uhab = ""` trong `war3map.w3u` — đọc
> thẳng từ file, không phải nhìn màn hình. Nút **+** đã hết. Đừng liệt việc này
> vào danh sách phải làm nữa.

## Chưa làm

- Không có cách mở khoá cho riêng một hero lúc chạy. Muốn thì gọi
  `SuspendHeroXP(u, false)` trực tiếp, nhưng bộ quét sẽ khoá lại ở lần chạy sau.
- Chưa quyết hero nên đứng ở cấp mấy. Hiện là cấp 1, cấp mặc định khi tạo.
- Chưa có kỹ năng tự tạo nào. Command card hiện chỉ còn lệnh cơ bản.
