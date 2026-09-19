# Sửa & clone ability bằng script

> **Trạng thái:** Bộ đọc/ghi đã chạy, bộ sinh chưa viết
> **Cập nhật:** 2026-09-15
> **Công cụ:** [w3obj.py](../../w3obj.py)

Mọi con số trong tài liệu này **đọc ra từ file thật**, không chép từ đâu. Chỗ nào
chưa đo được thì ghi rõ là chưa đo.

## Hai bộ ghi

**[w3obj.py](../../w3obj.py) — tầng định dạng, không biết gì về game:**

```
python w3obj.py levels test2.w3x/war3map.w3a 10   # alev = 10 cho MOI ability
python w3obj.py set    test2.w3x/war3map.w3a A001 alev 10
```

**[w3skill.py](../../w3skill.py) — tầng dự án, sinh vỏ kỹ năng từ `CFG.SKILLS`:**

```
python w3skill.py show          # xem truoc, khong ghi
python w3skill.py gen           # ten + vi tri o + tooltip 10 bac
python w3skill.py gen --lang vi
```

Nó ghi **hai** file: `war3map.wts` (chuỗi) và `war3map.w3a` (tham chiếu
`TRIGSTR_`). Chuỗi sinh ra chiếm id từ **1000** trở lên nên không đụng chuỗi của
World Editor bên dưới; chạy lại bao nhiêu lần cũng ra một kết quả.

> **Chữ không nằm trong `.w3a`.** World Editor ghi chuỗi vào `war3map.wts` rồi để
> lại `TRIGSTR_nnn` trong object data. Đo được từ `A006` — object duy nhất từng có
> vỏ đầy đủ. `w3skill.py` làm y hệt thay vì nhét chữ thẳng vào.

Thêm `--dry` để chỉ in ra. Bản cũ chép vào `build/war3map.w3a.goc`.

**Cách tự kiểm đã dùng:** đặt lại `alev = 10` cho `A004` — giá trị nó *đã có* —
rồi so file với bản World Editor ghi ra. **Khớp từng byte.** Chỉ sau đó mới cho
nó sửa sáu ability còn lại.

> **Chỉ ghi được trường đã đo kiểu.** `FIELD_TYPE` trong
> [w3obj.py](../../w3obj.py) liệt kê 18 trường; trường không có trong đó thì
> **từ chối ghi** chứ không đoán kiểu. Đoán sai kiểu một trường bốn ký tự là file
> hỏng âm thầm — World Editor có thể nuốt mất object mà không báo gì.

## Tại sao không gõ tay

21 skill × 10 level. Riêng tooltip đã là 210 đoạn chữ, và **mỗi lần chỉnh cân
bằng phải viết lại cả 210** — vì skill có hiệu ứng viết bằng Lua không dùng được
cú pháp tự thay số của Warcraft (xem [Bẫy `<AHav,DataA1>`](#bẫy-ahavdataa1)).

Sinh bằng script thì số liệu và tooltip ra từ **cùng một bảng**, nên không bao
giờ lệch nhau. Đó là cái được lớn hơn chuyện đỡ mỏi tay.

## Các file

| File | Chứa gì | Có trường `level` |
|---|---|---|
| `war3map.w3a` | ability | **có** |
| `war3map.w3u` | unit | không |
| `war3map.w3t` | item | không |
| `war3map.w3b` | doodad | không |
| `war3map.w3d` | destructable | **có** |
| `war3map.w3q` | upgrade | **có** |

Đó là khác biệt **duy nhất** giữa hai họ. `w3obj.py` tự nhận theo đuôi file.

## Định dạng (phiên bản 2 — bản 1.31.1 dùng)

```
int   phiên bản                       = 2
int   số object GỐC bị sửa            -- bảng 1
  mỗi object:
    char[4]  id gốc
    char[4]  id mới                   -- 0 ở bảng 1
    int      số trường sửa
      mỗi trường:
        char[4]  mã trường
        int      kiểu   0=int 1=real 2=unreal 3=string
        int      level          \  CHỈ w3a, w3d, w3q
        int      con trỏ dữ liệu /
        <giá trị theo kiểu>           -- string kết thúc bằng byte 0
        char[4]  dấu hết trường       -- World Editor luôn ghi 00 00 00 00
int   số object TỰ TẠO                -- bảng 2
  ... giống hệt
```

### Hai bảng, hai việc khác nhau

**Bảng 1 — sửa ability gốc.** Đè lên ability có sẵn của Warcraft, **cả map**.
Mọi unit dùng nó đều đổi, kể cả quái và unit trung lập, và mọi bản sao *dựa
trên* nó cũng thừa hưởng.

Không hợp cho skill hero. Rất hợp cho quái: sửa một lần là 50 con đổi theo, khỏi
tạo 24 unit type.

**Bảng 2 — bản sao.** `id gốc` + `id mới`. Đây là chỗ 21 skill sẽ nằm.

### Con trỏ dữ liệu = cột Data

Đo trên Avatar:

| Mã | Con trỏ |
|---|---|
| `Hav1` | 1 |
| `Hav2` | 2 |
| `Hav3` | 3 |
| `Hav4` | 4 |
| mọi trường khác | 0 |

Tức nó là số thứ tự cột Data A/B/C/D. Đặt sai là World Editor đọc nhầm cột.

### Thứ tự level KHÔNG được sắp

Đọc từ `A004` trong map:

```
thu tu level cua Iagi: [1, 2, 5, 3, 4, 6, 7, 8, 9, 10]
```

World Editor ghi ra theo thứ tự nội bộ của nó, không theo level. **Bộ đọc không
được giả định thứ tự**, và bộ ghi phải giữ nguyên thứ tự đọc vào nếu muốn dựng
lại đúng từng byte.

## Mã trường đã đo được

Tất cả lấy từ `test2.w3x/war3map.w3a` do World Editor ghi ra.

### Dùng chung mọi ability

| Mã | Ô trong World Editor | Kiểu | Theo level |
|---|---|---|---|
| `alev` | Stats - Levels | int | không |
| `arac` | Stats - Race | string | không |
| `aher` | Stats - Hero Ability | int (0/1) | không |
| `acdn` | Stats - Cooldown | unreal | **có** |
| `adur` | Stats - Duration - Normal | unreal | **có** |
| `ahdu` | Stats - Duration - Hero | unreal | **có** |
| `aart` | Art - Icon - Normal | string | không |
| `arar` | Art - Icon - Research | string | không |
| `abpx` `abpy` | Art - Button Position - Normal | int | không |
| `arpx` `arpy` | Art - Button Position - Research | int | không |
| `aubx` `auby` | Art - Button Position - Turn Off | int | không |
| `anam` | Text - Name | string | không |
| `aret` | Text - Tooltip - Learn | string | không |
| `arut` | Text - Tooltip - Learn - Extended | string | không |
| `aub1` | Text - Tooltip - Normal - Extended | string | **có** |

**`aub1` theo level** — đó là ô tooltip mà người chơi đọc khi rê chuột, và là ô
duy nhất trong nhóm Text cần viết riêng cho từng level.

> **Chưa đo được:** `Text - Tooltip - Normal` (dòng ngắn). Gõ vào ô đó rồi save
> thì nó sẽ hiện ra, đọc một lần là biết.
>
> Chưa đo: mana, tầm thi triển, bán kính, loại mục tiêu hợp lệ. Cùng cách lấy.

### Ability ẩn: đặt Button Position ra ngoài lưới

Command card là lưới **4 × 3** — X từ 0–3, Y từ 0–2. Button Position chỉ là toạ
độ trong lưới đó, nên đặt **ngoài** phạm vi thì nút vẫn tồn tại và ability vẫn
chạy, nhưng **vẽ ở chỗ không có ô nào** — tức không hiện.

```
abpx = 0
abpy = -11        <- ngoai luoi, nut khong hien
```

**Dùng khi nào.** Một ability chỉ để mang hiệu ứng, không cần người chơi bấm hay
nhìn: bonus của trang bị, cờ trạng thái, vật mang cho code Lua. Hero chỉ có
**7 ô trống** và bảy kỹ năng đã chiếm hết — mọi ability thêm sau **bắt buộc**
phải ẩn, nếu không nó đè lên một kỹ năng và cái đó **bấm không được**.

**Vì sao chọn cách này thay vì `BlzUnitHideAbility`:**

| | |
|---|---|
| `BlzUnitHideAbility` | Là **native** — chưa xác minh bản 1.31.1 có, và phải gọi lúc chạy cho từng hero |
| Button Position `(0, −11)` | Là **dữ liệu** — nằm sẵn trong `.w3a`, không phụ thuộc phiên bản, không cần một dòng Lua nào |

Đúng nguyên tắc của dự án: để dữ liệu lo thay vì viết code lo.

**Bộ ghi xử lý được số âm.** `abpx`/`abpy` là int32 **có dấu**; `w3obj.py` ghi
bằng `struct "<i"` nên `-11` ra `f5 ff ff ff` và đọc lại đúng — đã kiểm bằng một
vòng ghi–đọc.

> **Chưa nhìn tận mắt trong game.** Đây là cách quen thuộc trong cộng đồng WC3 và
> khớp với cơ chế lưới mà `w3skill.py` đang dùng để đặt 7 nút của Hart, nhưng
> chưa ai trong dự án này bật game lên xác nhận. Kiểm một lần khi làm ô trang bị
> đầu tiên.

### Theo từng ability gốc

| Gốc | Là gì | Mã Data |
|---|---|---|
| `AHav` | Avatar | `Hav1` `Hav2` `Hav3` `Hav4` |
| `Aamk` | Attribute Bonus | `Istr` `Iagi` `Iint` |
| `AOsh` | Shockwave | chưa đo — **và không cần nữa**, xem dưới |
| `AHhb` | Holy Light | chưa đo |
| `AHad` | Devotion Aura | chưa đo |
| `ACce` | Cleaving Attack (**lấy từ unit**, không phải hero) | chưa đo |

> **Bốn dòng "chưa đo" ở trên không còn chặn việc gì.**
> [7_effect.lua](../../src/2_player/7_effect.lua) không sửa trường sát
> thương của ability — nó bắt `EVENT_PLAYER_UNIT_SPELL_EFFECT` rồi **tự gọi**
> `UnitDamageTarget`. Sát thương gốc của Warcraft vẫn còn, nhưng ở bậc 10 với
> Tu Vi bậc 20 thì nó là sai số làm tròn.
>
> Đo được mã trường vẫn có ích (đổi tooltip trong game, đỡ một sự kiện), nhưng
> nó không còn là đường duy nhất.

Mã Data **mỗi ability gốc một khác**, và đoán sai thì World Editor nuốt lặng,
không báo gì. Chỉ có một cách biết: đọc từ file do nó ghi ra.

## Cách moi mã trường ra

World Editor **chỉ ghi vào file những trường khác với ability gốc**. Bản sao vừa
tạo xong thì giống hệt gốc, nên file chỉ có đúng một dòng `arac`.

Hai cách ép nó ghi ra:

**1. Đặt `Stats - Levels` = 10.** Ép ghi ra mọi trường **theo level**, kèm mã.
Đây là cách lấy mã Data. Đo được: `A001` (Avatar) sau khi đặt Levels=10 có 79
trường, giá trị giống hệt nhau cả 10 mức — tức World Editor tự điền, không ai gõ.

**2. Gõ đại một chữ vào ô muốn biết mã.** Dùng cho trường không theo level
(tên, tooltip, icon). Gõ `x` cũng được.

## Bẫy `<AHav,DataA1>`

Đọc từ `war3map.wts` của chính map này, tooltip của một bản sao Avatar:

```
...gives the Mountain King <AHav,DataA1> bonus armor,
   <AHav,DataB1> bonus hit points...
```

`<AHav,DataA1>` là cú pháp Warcraft tự thay bằng số thật lúc chạy. Nhưng nó trỏ
**`AHav` — ability gốc**, không phải bản sao. Bản sao thừa hưởng nguyên chuỗi đó,
nên sửa DataA của bản sao thì tooltip vẫn hiện số của Avatar.

Cắn mọi map clone ability bằng tay, và im lặng.

**Với skill có hiệu ứng viết bằng Lua thì cú pháp này chết hẳn** — số nằm trong
bảng Lua, ô Data bằng 0, tooltip sẽ hiện "gây 0 sát thương". Phải viết thẳng số
vào từng dòng `aub1`, mỗi level một dòng.

## Chữ nằm ở đâu

World Editor không ghi chữ vào `.w3a`. Nó ghi một con trỏ:

```
anam = 'TRIGSTR_016'
```

rồi để chữ thật trong `war3map.wts`:

```
STRING 16
// Abilities: A006 (Defend Percent), Name (Name)
{
Defend Percent
}
```

**Nhưng ghi chữ thẳng vào `.w3a` cũng chạy** — đã thử: sinh `A003` với `anam` =
`Hộ Thể` viết thẳng, UTF-8, World Editor mở lên hiện đúng. Gọn hơn vì khỏi phải
sinh thêm `war3map.wts`.

`w3obj.py` đọc/ghi chuỗi bằng UTF-8 với `surrogateescape`, nên chữ tiếng Việt
vào ra đúng mà byte lạ cũng không mất.

## Quy trình an toàn

```
python w3obj.py checkall test2.w3x        # đọc rồi dựng lại, so từng byte
cp test2.w3x/war3map.w3a build/objbak/    # sao lưu TRƯỚC khi ghi
<chạy bộ sinh>
python w3obj.py check test2.w3x/war3map.w3a
```

**Lệnh `check` là cái quan trọng nhất.** Nó đọc file do World Editor ghi ra rồi
dựng lại từ đầu và so từng byte. Lệch một byte là hiểu sai định dạng — dừng lại,
đừng sinh gì cả.

File sai định dạng thì World Editor có thể không mở được map, hoặc **lặng lẽ
nuốt mất object** — kiểu hỏng tệ nhất vì không báo gì.

> Hỏng thì chép `build/objbak/war3map.w3a.goc` đè lại là xong.

### Ai sở hữu cái gì

Cùng một bài học với `src/` và `war3map.lua`, chỉ khác file:

| | Ai sở hữu |
|---|---|
| Tạo ability, chọn gốc, đặt `Levels` | **World Editor** |
| Số liệu từng level, tooltip, tên, ô nút | **bộ sinh** |

Sửa số trong World Editor là lần sinh sau đè mất. Thứ tự bắt buộc: sửa trong WE
→ Save → chạy bộ sinh → **không Save trong WE nữa**.

> World Editor có giữ nguyên thứ script ghi ra sau một lần Save hay không —
> **chưa đo được**. Đã hai lần định đo thì file bị thay trước đó. Cứ sao lưu.

## Tình trạng trong map

```
A001  AOsh  Shockwave          1 trường   <- chưa đặt Levels
A002  AHhb  Holy Light         1 trường   <- chưa đặt Levels
A003  AHad  Devotion Aura      1 trường   <- chưa đặt Levels
A004  Aamk  Attribute Bonus   32 trường   Levels=10 ✓
A005  ACce  Cleaving Attack    2 trường   Hero Ability = có, <- chưa đặt Levels
A006  Aamk  Attribute Bonus   16 trường   đủ tên + tooltip + icon
A007  AHav  Avatar             1 trường   <- chưa đặt Levels

Mới **1 / 7** đặt `Levels = 10`. Sáu cái còn lại chưa nhả mã Data nào.
```

`A004` và `A006` đều dựa trên **Attribute Bonus** (`Aamk`), nhưng dùng vào hai
việc khác nhau:

- `A004` **Luyện Thể** dùng đúng công dụng của nó — cộng cả ba chỉ số.
- `A006` **Da Sắt** mượn nó làm **vật mang**: hiệu ứng thật (giảm % sát thương)
  viết bằng Lua, vì Attribute Bonus không giảm sát thương được.

Attribute Bonus hợp làm vật mang hơn Critical Strike đặt 0%: nó không có tỉ lệ
nào để lỡ kích hoạt. Nhưng phải **đặt cả ba chỉ số = 0** — để khác 0 thì nó
cộng chỉ số thật, chồng lên hiệu ứng Lua mà không ai để ý.

## Còn thiếu

- `Text - Tooltip - Normal` chưa biết mã.
- Mã Data của 19 ability gốc còn lại — lấy bằng cách đặt `Levels = 10`.

### Ability lấy từ unit, gắn lên hero

`ACce` Cleaving Attack lấy từ một unit chứ không phải từ hero. Chạy được,
nhưng ba chỗ phải kiểm vì ability unit không được thiết kế để nằm trên hero:

1. **`Stats - Hero Ability` phải bật** — đã bật (`aher = 1` trong file).
2. **`Stats - Levels`** — ability unit thường chỉ có 1 bậc. Không đặt lên 10 thì
   `SetUnitAbilityLevel(hero, 'A005', 7)` không lên được, và **không báo lỗi**.
3. **Icon và ô nút** — ability unit hay không có `Art - Button Position`, nên
   nó có thể đè lên một ô khác trong command card.
- Bộ sinh chưa viết. Cần bảng số liệu 21 skill trước.
- Chưa đo World Editor có giữ nguyên file script ghi ra sau khi Save không.

## Trường chỉ khai ở bậc 1 là một quả mìn hẹn giờ

> **Lỗi đã ship — 2026-09-20.** `A010` *Hồi Xuân* khai `atar` *(danh sách mục
> tiêu)*, `adur`, `aran`, `amcs`, `acdn` ở **đúng bậc 1**. Bậc 1 nhắm được bản
> thân và đồng đội; **bậc 2 trở lên rơi về ability gốc và không nhắm được ai
> cả**.
>
> Nghĩa là người chơi bỏ Gỗ ra **nâng một bậc** thì kỹ năng **hỏng đi** — và
> không có lỗi nào báo.

Object Editor lưu trường theo **từng bậc**. Gõ một giá trị khi ability mới có 1
bậc, rồi sau đó nâng `Stats - Levels` lên 10, thì bậc 2–10 **không có giá trị
nào** — và Warcraft lặng lẽ đọc dữ liệu của ability **gốc** cho những bậc đó.

Đây là anh em sinh đôi của cái bẫy `alev`: cái kia là *số* bậc, cái này là *nội
dung* của những bậc vừa mở ra.

```bash
python w3obj.py fill test2.w3x/war3map.w3a --dry   # xem trước
python w3obj.py fill test2.w3x/war3map.w3a
```

Nhân bản giá trị bậc 1 ra mọi bậc, cho **mọi** trường chỉ khai bậc 1. Chạy lại
nhiều lần vô hại — trường nào đã đủ bậc thì nó bỏ qua.

**Thứ tự đúng sau khi clone một ability mới:**

```bash
python w3obj.py levels test2.w3x/war3map.w3a 10   # mở đủ 10 bậc
python w3skill.py gen --lang vi                   # tên · tooltip · ô · phím
python w3obj.py fill   test2.w3x/war3map.w3a      # trám nội dung bậc 2-10
python w3obj.py checkall test2.w3x                # đọc lại, so từng byte
```

Đo lại bằng chính `dump`: trường nào chỉ có một dòng `level=1` trong khi
`alev = 10` là một quả mìn chưa nổ.
