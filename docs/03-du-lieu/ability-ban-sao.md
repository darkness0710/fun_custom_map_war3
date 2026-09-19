# Ability bản sao: tắt hiệu ứng gốc, hay mượn nó làm vật mang

> **Khoá CFG:** `SKILL_ZERO_BASE` `SKILL_ZERO_BASE_INT` `SKILL_CARRY_BASE`
> **Đo bằng:** `-nat spell`, `-nat ilf` trong game (1.31.1)

## Vấn đề gốc

Bảy kỹ năng của Hart đều là **bản sao** của ability có sẵn, và một bản sao
**giữ nguyên hiệu ứng của ability gốc**. Chưởng là bản sao của Shockwave nên
*nó* tự gây 110 sát thương, rồi `fxLine` cộng thêm 39.6 nữa — bảng ghi 39.6 mà
màn hình hiện **111**.

Tệ hơn con số lệch: số gốc là **hằng số**. Nó đứng yên ở 110 suốt ván trong khi
đường cong của dự án lên ×26. Đầu ván kỹ năng mạnh gấp ba lần bảng ghi, cuối ván
phần gốc thành vụn.

## Hai cách xử lý, chọn theo từng kỹ năng

### Cách A — TẮT hiệu ứng gốc (`SKILL_ZERO_BASE`)

Dùng khi **Lua đã tự làm thay**. Ghi `0` vào trường của ability ở **mọi bậc**,
trong `applyLevel()`.

| Kỹ năng | Trường | Lua thay bằng |
|---|---|---|
| A001 Chưởng | `ABILITY_RLF_DAMAGE_OSH1`, `MAXIMUM_DAMAGE_OSH2` | `fxLine` |
| A002 Hộ Thể | `ABILITY_RLF_AMOUNT_HEALED_DAMAGED_HHB1` | `fxHeal` |
| A007 Bất Hoại | `ABILITY_RLF_DAMAGE_BONUS_HAV3`, `MAGIC_DAMAGE_REDUCTION_HAV4` | *(không dùng)* |
| A004 | `ABILITY_ILF_STRENGTH_BONUS_ISTR`, `AGILITY_BONUS`, `INTELLIGENCE_BONUS` | `fx = "stat"` |
| ~~A006~~ | — | **đã rút khỏi bảng** — xem dưới |

Số nguyên phải gọi `BlzSetAbilityIntegerLevelField`, không phải bản Real.

### Cách B — MƯỢN trường gốc làm **vật mang** (`SKILL_CARRY_BASE`)

Dùng khi **Warcraft làm tốt hơn ta**. Thay vì tắt rồi tự cộng, **ghi thẳng số
cân bằng của mình vào trường** rồi để engine cộng.

| Kỹ năng | Trường | Nguồn số |
|---|---|---|
| ~~A003 Hiệu Lệnh~~ | — | **đã rút khỏi bảng** — xem dưới |
| A007 Bất Hoại | `ABILITY_RLF_DEFENSE_BONUS_HAV1` | `FX_BUFF_ARMOR` theo bậc |

## Vì sao giáp phải dùng cách B — và nó sửa một lỗi khác

Warcraft **không có native "cộng thêm giáp"**: `BlzSetUnitArmor` đặt **giáp
tổng**. Nên để Hiệu Lệnh cộng +3 giáp, `heroRecompute` buộc phải sở hữu cả công
thức:

```lua
BlzSetUnitArmor(h, n.giap + auraGiap() + buffGiap(pid))
```

`n.giap` là `BlzGetUnitArmor()` **chụp lúc tạo hero** — tức giáp tổng hồi Agi
còn bằng 5. Từ đó trở đi mỗi lần tính lại đều đóng băng phần Agi vào con số đó:

> **Agi 511, giáp vẫn bằng 2.** Str 516, đòn thường vẫn 12-22.

Đây không phải Warcraft tính sai — **ta đè lên nó**. Và hai kỹ năng cần cộng
giáp *chính là* hai ability vốn cộng giáp. Ghi số vào trường của chúng thì
Warcraft tự cộng, và cả hai dòng ghi đè **xoá được hẳn**:

```lua
-- heroRecompute() không còn ghi BlzSetUnitArmor hay BlzSetUnitBaseDamage
```

Chỉ số chạy lại bình thường như mọi map Warcraft khác.

**Không phải ta cần tính thêm, mà là ta cần thôi sở hữu.** Sửa xong là *bớt*
code: `auraGiap()`, `buffGiap()`, `fxBuff()` và cờ `buffLv` đều xoá.

Sát thương không cần vật mang: Trang Bị đang khoá nên `gearMult` luôn `1.0`,
tức dòng cũ ghi lại đúng con số nó vừa đọc. **Mở Trang Bị lại thì phải chọn vật
mang cho nó, đừng ghi đè ở `heroRecompute`.**

## Ba thứ còn chạy, biết trước chứ không phải bug

| | |
|---|---|
| **Cleave % của Chém Lan** | `ACce` không có hằng số nào ở cả `RLF` lẫn `ILF`. Native cleave vẫn cộng chồng lên `fxCleave`. Đường còn lại: sửa thẳng `war3map.w3a`, mã trường phải tra trong World Editor |
| **Máu tối đa của Bất Hoại** (`HAV2`) | Bản 1.31.1 không phơi ra hằng số |
| **Bán kính aura** | Aura của Warcraft **có bán kính**; bản Lua cũ thì không — nó cộng cho cả đội dù đứng đâu. Ba người trong map này gần như luôn đứng chung chỗ nên khác biệt nhỏ, nhưng cần nhìn lại nếu đội hình tách xa |

Thời lượng Bất Hoại giờ là thời lượng gốc của Avatar, **không phải**
`CFG.FX_BUFF_TIME`. Muốn đổi thì đặt `adur`/`ahdu` trong `war3map.w3a`.

## Cách tìm tên hằng số

Tên hằng **mỗi bản mỗi khác** — bản 1.31.1 có đủ các hàm `Blz*AbilityField`
nhưng **thiếu** `ABILITY_RLF_DAMAGE_HCA1`. Gõ sai tên thì Lua trả `nil` và
`BlzSetAbilityRealLevelField` **im lặng không làm gì**.

```
-nat spell      tra hằng số theo ability gốc của từng kỹ năng
-nat ilf        mọi hằng số nguyên
-nat rlf        mọi hằng số thực
```

Kết quả đầy đủ nằm trong `DarknessTrace.txt`, chia 6 tên mỗi dòng vì `Preload()`
tự cắt chuỗi dài (đo được: cắt ở 278 ký tự, mất 407/414 tên).

> `applyLevel()` **ghi vết** khi một hằng số không tồn tại thay vì bỏ qua —
> `skill: KHONG co hang so X -- hieu ung goc VAN CHAY`.
