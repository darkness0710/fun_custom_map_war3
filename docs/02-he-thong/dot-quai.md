# Hệ thống: Đợt quái

> **Trạng thái:** Đã cài — **chưa chơi thử**
> **Cập nhật:** 2026-09-16
> **Code:** [2_wave.lua](../../src/3_battle/2_wave.lua)
> **Khoá CFG:** `WAVE_*` `MOB_*` `ELITE_*` `BOSS_*` `SCALE_*` `LINHKHI_*`
> **Xem kèm:** [canh-gioi.md](../03-du-lieu/canh-gioi.md) ·
> [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) · [boss.md](boss.md)

> **Ghi chú khôi phục.** Bản trước của file này bị ghi đè nhầm và không lấy lại
> được. Bản này dựng lại từ những gì các tài liệu khác trích dẫn về nó —
> `canh-gioi.md`, `boss.md`, `duong-cong-suc-manh.md`, ADR 0009–0011 — nên **nhất
> quán với chúng**, nhưng có thể thiếu chi tiết so với bản gốc.

## Nó là gì

100 stage. Phe địch tu từ Phàm Nhân lên Sáng Thế Thần, mỗi cảnh giới 4 tầng rồi
một lần độ kiếp. Người chơi chặn ở từng tầng, và chặn hẳn ở mỗi lần độ kiếp.

## Luật

**L1. Một biến `stage` duy nhất, 1…100.**
Cảnh giới và tầng đều **suy ra** từ nó. Giữ hai biến song song là chúng sẽ lệch
nhau. Công thức ở [canh-gioi.md](../03-du-lieu/canh-gioi.md).

**L2. Một cảnh giới là 5 stage: 4 tầng + 1 boss.**
Số 5 là `TIERS_PER_REALM + 1`, không hard-code ở đâu cả. 20 cảnh giới × 5 =
**100 stage**.

**L3. Thành phần wave cố định: 50 lính + 1 tinh anh.**
Không đổi theo số người chơi, không đổi theo cảnh giới. Số lượng cố định thì mọi
thứ khác đoán được: hiệu năng, thời gian dọn, thu nhập.
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

**L4. Boss chiếm trọn stage, một mình.**
Không lính đi kèm. Xem [boss.md](boss.md).

**L5. Có trần số unit sống.**
Quá `WAVE_MAX_ALIVE` (300) con trên map thì **hoãn** wave mới thay vì chồng
thêm. Với luật "chỉ gọi khi đã sạch" ở dưới thì trần này gần như không chạm tới
— nó là lưới an toàn cho trường hợp quái kẹt không chết.

**L2b. Tầng có TÊN, không đánh số.**
`CFG.TIER_NAMES` — **Sơ Kì · Trung Kì · Hậu Kì · Viên Mãn**. "Trúc Cơ Sơ Kì" đọc
ra nghĩa ngay; "Trúc Cơ Tầng 3" thì phải nhớ tầng 3 trên tổng bao nhiêu. Bảng
thiếu phần tử thì `tierLabel()` lui về đánh số — đổi `TIERS_PER_REALM` mà quên
thêm tên thì vẫn chạy, chỉ là tên xấu.

**L6. Tầng đổi *tu chính*, không đổi chỉ số.**
Trong một cảnh giới, chỉ số chỉ nhích ×1.054 suốt 4 tầng — gần như không cảm
thấy. Thứ làm Hậu Kì khác Sơ Kì là **tu chính**, xem phần dưới.

## Nhịp — do người chơi bấm, KHÔNG có đồng hồ

**Không có `WAVE_TIME`, không có đồng hồ đếm ngược, không có đợt tự đến.** Mỗi
đợt bắt đầu khi người chơi bấm nút trên bảng `R` —
[ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md).

```
tầng 1..4      [GỌI ĐỢT n]          bấm là đợt sau ra
tầng 4 sạch  → [TRIỆU BOSS]
boss chết    → [SANG CẢNH GIỚI SAU]
```

Ba nhãn, **một nút**. Từ 2026-09-18 cả 5 stage đều cho gọi, nên hai mốc sau
không còn là "đứng đồng hồ" — chúng chỉ là hai nhãn khác của cùng cái nút. Vẫn
giữ biến riêng (`S.waitNext`) vì ba trạng thái làm ba việc khác nhau, và mốc thứ
hai là chỗ **Lôi Kiếp** sẽ gắn vào.

### Chỉ gọi được khi đã dọn sạch

`CFG.WAVE_ONLY_WHEN_CLEAR = true`. Gọi sớm là **bỏ qua phần khó của đợt này mà
vẫn lấy tiền của đợt sau**; và hai đợt chồng lên nhau thì đợt sau lại kéo dài
đợt đang dở — một dây chuyền người chơi không ngắt được.

Đặt `false` thì nút bật mọi lúc — nhưng lúc đó
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md) (50 lính cố định)
mất nghĩa, vì người chơi tự chọn số quái trên map.

### Đếm lại số quái sống, không tin con số đang giữ

`CFG.WAVE_RECOUNT = 10.0` — cứ 10 giây đếm lại `S.mobs`.

**Lỗi thật đã xảy ra** ([ADR 0018](../05-quyet-dinh/0018-nghi-giua-hai-canh-gioi.md)):
`S.alive` kẹt trên 0 thì **mọi** lối thoát cùng chết — cả đường "dọn sạch" lẫn
lệnh gọi tay, vì cả hai đều hỏi cùng con số. Kẹt thì kẹt vĩnh viễn, không lỗi
nào báo.

Đếm qua `S.mobs` chứ **không** quét map theo chủ sở hữu: `S.mobs` chỉ được ghi
ở hai chỗ sinh quái của hệ wave, nên quái **đặt sẵn** ở các vùng đặt sau này
không bao giờ lọt vào. Đếm theo `GetOwningPlayer == S.enemy` thì vơ luôn chúng,
và `S.alive` không bao giờ về 0 — đúng cái bẫy phép đo này định chữa.

### Độ dài một ván

**Không tính trước được nữa, và đó là chủ đích.** Bản cũ của trang này tính ra
"134 phút" từ `WAVE_TIME` theo cõi rồi lo map quá dài. Khi nhịp do người chơi
bấm thì độ dài ván = tốc độ đội dọn quái, cộng đúng số giây họ chọn để đứng lại
tiêu tiền.

Đội chơi nhanh đi nhanh; đội muốn ngắm bảng thì đứng lâu — và không ai phải
ngồi nhìn đồng hồ đếm ngược trong một đợt đã dọn xong từ lâu.

## Tu chính

**Đã cài 2026-09-19** — [5_modifier.lua](../../src/3_battle/5_modifier.lua).

Mỗi stage **thường** bốc một tu chính: một sửa đổi lên cả đợt. Đây là thứ làm 4
tầng khác nhau, vì chỉ số thì gần như đứng yên (L6). **Stage boss không có** —
boss đã có `BOSS_MECH` riêng, chồng thêm một lớp nữa thì không ai đọc ra cái gì
đang giết mình.

| Tu chính | Màu quái | Trời | Quái đổi gì | Người chơi buộc phải đổi gì |
|---|---|---|---|---|
| **Hút Máu** | đỏ | giông bão + sét | Ability hút máu gốc của Warcraft | **Dồn từng con**, đừng rải — rải thì mỗi con tự lành |
| **Chắn Phép** | tím | **mái vòm phép** *(Dalaran Shield)* | Kỹ năng chỉ còn **50%** sát thương | **Đánh tay** |
| **Dày Da** | xanh thép | tuyết nặng | Đòn thường chỉ còn **50%** | **Xả chiêu** |
| **Nổ Tan** | cam | bão tuyết | Chết thì nổ, bán kính 300 | **Đừng đứng chụm** |
| **Trùng Linh** | vàng | **trời quang** *(không hiệu ứng)* | *(không có gì)* | Không phải đổi gì — thưởng **×2** |

> Một con quái **dày gấp rưỡi** thì người chơi vẫn bấm đúng ngần ấy nút. Một con
> quái **tự hồi máu** thì buộc phải đổi thứ tự bấm. Chỉ cái sau mới là lối chơi.

### 50% là con số đo được, không phải chọn cho đẹp

`CFG.BOSS_SKILL_SHARE = 1.0` — kỹ năng đóng góp ~100% so với đòn thường, tức sát
thương chia đôi hai kênh. Chặn 50% một kênh ≈ **−25% tổng DPS**: đủ đau để phải
đổi cách đánh, chưa đủ để bế tắc.

Và hai cái ngược nhau (Chắn Phép ↔ Dày Da) đặt cạnh nhau tạo nhịp thật.

### Bốn ràng buộc kỹ thuật

**1. Bốc là một ràng buộc đồng bộ.** `GetRandomInt` phải chạy trên **mọi máy
cùng thứ tự**, nếu không hai bản game lệch nhau. `pick()` gọi từ `spawnStage()`
— đường đã đồng bộ. Tuyệt đối không bốc trong callback của frame
([ADR 0012](../05-quyet-dinh/0012-mot-kenh-dong-bo-duy-nhat.md)).

**2. Không dùng giáp để giảm sát thương.**
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md): đường cong
sinh ra **EHP**, máu thật suy ngược ra *từ giáp*. Sờ vào giáp là lặng lẽ đổi cả
đường cong độ khó. Hai tu chính "giảm 50%" vì thế nhân ở **sự kiện sát thương**,
dùng đúng cách phân biệt phép/đòn mà Áo Choàng đã dùng:

```lua
spell = (BlzGetEventDamageType() ~= DAMAGE_TYPE_NORMAL)
```

Mọi kỹ năng hero đánh ra `DAMAGE_TYPE_MAGIC`; đòn thường là `NORMAL`. Native đó
**có mặt** ở 1.31.1 — file vết ghi `native [Su kien sat thuong] co 7/7`.

**3. Mã ability thì ĐO, không gõ.** `UnitAddAbility` trả `false` khi mã sai và
hàm **im lặng không làm gì**. `probeAbility()` thử lần lượt `AUav` → `ANvc` →
`Avam` trên con quái **đầu tiên** của đợt, giữ mã nào nhận, rồi dùng cho 49 con
còn lại. Không mã nào nhận thì ghi vết và lùi về đường sự kiện sát thương.

**4. Sát thương vụ nổ tính theo sát thương của chính con đó**
(`BlzGetUnitBaseDamage × 4`), không phải một con số phẳng — số phẳng sẽ thành vô
nghĩa ở cảnh giới 15. Và **chỉ đánh hero**: nổ lan sang chính đồng quái của nó
thì tu chính này thành một món quà cho người chơi.

### Bốn lớp báo, và chỉ một lớp TRA CỨU được

| Lớp | Luôn ở đó? | Vấn đề |
|---|---|---|
| **Dòng chữ** lúc vào đợt | không | nói một lần rồi trôi mất |
| **Màu quái** | có | phải **nhớ** màu nào nghĩa gì |
| **Trời** | có | sương mù rất mờ, không chắc là vừa đổi hay chưa |
| **Dòng trong khung `R`** | **có** | — |

**Dòng thứ tư thêm 2026-09-19**, và nó vá đúng lỗ mà ba lớp kia để lại: *tu
chính kéo dài cả đợt, còn dòng chữ thì trôi sau vài giây*. Người chơi vào giữa
đợt, hoặc vừa đọc một dòng khác đè lên, thì **không còn chỗ nào hỏi**.

Hàng cuối của thẻ Tổng Quan (`ROWS = 5`) hiện **tên tu chính + kiểu trời + mô
tả nó làm gì** — `API.modifierLabel()`. `announce()` và `clear()` đều gọi
`API.gameFrameRefresh()`, nếu không thì sang đợt boss dòng đó vẫn giữ tên tu
chính **cũ** — sai mà nhìn rất thật.

### Trời đổi theo tu chính *(2026-09-19)*

Lớp báo thứ **ba**, cạnh dòng chữ (trôi mất) và màu quái (phải nhìn vào quái).
**Trời thì thấy mà không cần nhìn đâu cả.**

**Không cần region.** Cả 5 kiểu thời tiết gắn vào **cùng một rect**
(`bj_mapInitialPlayableArea` — đã dùng ở ba chỗ khác trong map), rồi bật/tắt
từng cái. `AddWeatherEffect` cho phép nhiều hiệu ứng trên một rect; chỉ một cái
được **bật** tại một lúc.

**Tạo một lần lúc vào map**, không tạo lại mỗi stage: mỗi `AddWeatherEffect` là
một handle mới, mà handle Warcraft thì không tự dọn — một ván 100 stage sẽ rò rỉ
100 cái.

**Tắt trước rồi bật sau**, nếu không có một khung hình hai kiểu trời chồng nhau
— mưa với bão cát cùng lúc nhìn ra lỗi vẽ.

**Stage boss tắt hẳn trời** (`modifierClear()`): boss đã có bảng cơ chế riêng,
thêm một kiểu trời nữa là người chơi không biết trời đang nói về cái gì.

#### Mã thời tiết thì ĐO, không gõ

`CFG.MODIFIERS[i].weather` là một **danh sách ứng viên**, không phải một mã:

```lua
weather = { 'RLhr', 'RAhr', 'RLlr' },   -- giông bão Lordaeron
```

`AddWeatherEffect` trả `nil` khi mã sai rồi **im lặng**. `makeWeather()` thử lần
lượt, giữ cái nào dựng được, và ghi vết **cả hai trường hợp**:

```
modifier: thoi tiet lifesteal = 'RLhr'
modifier: KHONG ma thoi tiet nao dung duoc cho resist_phys (WNcw WOcw WHwd)
```

### ⚠ `AddWeatherEffect` trả về handle KHÔNG chứng minh mã đúng

**Lỗi đã ship.** `makeWeather()` thử lần lượt, giữ mã nào "dựng được", rồi ghi
vết `modifier: thoi tiet resist_phys = 'WNcw'`. Trông như bằng chứng. **Không
phải** — `AddWeatherEffect` nhận cả mã rác và vẫn trả về handle bình thường.
Dòng vết đó chỉ nghĩa là *"gọi hàm không lỗi"*.

Khác hẳn ability: `UnitAddAbility` trả `false` khi mã sai, nên phép dò `AUav`
**có** giá trị chứng minh.

**Không có cách nào kiểm mã thời tiết bằng code.** Phép đo duy nhất là **con
mắt** — lệnh `-sky N`.

### Đo xong 2026-09-19: chỉ 4 trong 22 mã hiện ra

Thử trên **1.31.1, tileset `L` (Lordaeron Summer)**:

| Mã | Kiểu trời | |
|---|---|---|
| `RLhr` | Lordaeron mưa rào + sét | ✅ |
| `SNbs` | Northrend bão tuyết | ✅ |
| `SNhs` | Northrend tuyết nặng | ✅ |
| `MEds` | Dalaran Shield — mái vòm tím | ✅ |

**Không hiện gì:** cả **8 kiểu sương mù** (xanh/lục/đỏ/trắng × nặng/nhẹ), mọi
kiểu mưa và tuyết **nhẹ**, `RAhr`/`RAlr` (Ashenvale), và cả 6 ứng viên gió / bão
cát.

Chưa rõ vì sao — có thể phụ thuộc tileset, có thể asset không có trong bản này.
Không đoán tiếp: `CFG.SKY_PROBE` giữ nguyên cả 22 mã làm **tư liệu**, và `-sky`
vẫn dùng để đo lại trên bản Warcraft khác.

### Bốn mã cho năm tu chính — nên một cái đi tay không

Cho **Trùng Linh**, và đó là chủ đích: đợt nghỉ + hái tiền thì **trời quang** là
dấu hiệu đúng nhất. **Vắng mặt cũng là một tin.**

Cặp dễ nhầm nhất là hai kiểu tuyết (Dày Da ↔ Nổ Tan), nên màu quái phải kéo
chúng ra xa hết cỡ: **xanh thép** ↔ **cam**. Nâu với cam thì vẫn gần nhau.

Mái vòm Dalaran rơi vào Chắn Phép là may: trong bốn mã còn dùng được thì nó vừa
**hợp chủ đề nhất** (một cái khiên phép phủ cả vùng) vừa **khác hẳn** ba cái kia
— không thể nhầm với mưa hay tuyết.

### Hai lệnh dev

| Lệnh | Làm gì |
|---|---|
| `-mod N` | Ép **tu chính** N, bật luôn trời của nó. `-mod` không số = liệt kê |
| `-sky N` | Bật **một mã thời tiết** bất kỳ trong `CFG.SKY_PROBE` để nhìn. `-sky off` = tắt |

`-sky` tắt luôn trời của tu chính trước khi bật cái mới — hai kiểu trời chồng
nhau thì không biết mình đang nhìn cái nào.

### Báo cho người chơi — ba kênh

Chat trôi sau vài giây, mà tu chính kéo dài cả đợt. Nên có ba:

```
[He Thong] [47/100] Hoa Than Trung Ki
[He Thong] Tu chinh: Hut Mau  |  troi: giong bao
           Quai tu lanh khi danh trung. Don tung con, dung rai.
```

**Gọi tên kiểu trời ra**, không để người chơi tự đoán. Một số kiểu (sương mù) rất
mờ nhạt — không nói thì người chơi không biết trời có vừa đổi hay không, mà một
dấu hiệu không chắc chắn thì không dùng được.

…cộng **màu quái** (`SetUnitVertexColor`) và **kiểu trời**. Ba lớp cho cùng một
tin, vì mỗi lớp hỏng theo một kiểu: chữ thì trôi, màu thì phải nhìn vào quái,
trời thì không nói được *phải làm gì*.

Câu chữ nói **quái làm gì** *và* **mình phải làm gì**. Nói mỗi tên thì người chơi
phải tự đoán — và một tu chính người chơi không biết thì không phải cơ chế, nó
là **độ khó vô hình**, thứ chỉ gây ức chế.

### Bốc ngẫu nhiên, nhưng không trùng cái vừa rồi

Chốt 2026-09-19. Bảng chỉ có 5 cái nên xác suất trùng liên tiếp là 1/5 — đủ cao
để gặp thường xuyên, và hai stage liên tiếp giống nhau thì người chơi tưởng hệ
hỏng. `pick()` bốc lại cho tới khi khác `S.waveModCode` trước đó.

> **Còn lặp ở tầm cảnh giới.** 5 tu chính trải trên 80 stage nghĩa là người chơi
> gặp đúng 5 thứ này ~16 lần mỗi thứ. Nó chữa *"bốn tầng giống hệt nhau"*, chưa
> chữa *"hai mươi cảnh giới giống nhau"*. Cách rẻ để đỡ là **thêm tu chính vào
> bảng** — thêm một dòng `CFG.MODIFIERS` là cả 20 cảnh giới cùng có.

### Thưởng ×2 — nhân cả bốn thứ

Chốt 2026-09-19: **Linh Khí, Vàng, Gỗ và lượt Cơ Duyên đều ×2**, không chừa thứ
nào. Kỳ vọng cả ván (~16 stage trúng tu chính này):

| | Trước | Sau |
|---|---|---|
| Gỗ *(Ngộ Tính)* | 260 | **~292** |
| Lượt Cơ Duyên | 169 | **~185** |
| Vàng từ quái | 4 000 | **~4 800** |

Gỗ là đồng tiền hiếm nhất map, nhưng nó **sẽ có thêm chỗ tiêu** *(Pháp Khí)* nên
hào phóng được. Khi thiết kế Pháp Khí thì lấy **292** làm ngân sách, không phải
260.

## Chỉ số

Đường cong ở [duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md). Tóm
tắt phần đợt quái cần biết:

| | Khoá | Chỉ số lấy từ đâu |
|---|---|---|
| Lính | `MOB_EHP_*` `MOB_DMG_*` | Đường cong theo cảnh giới — ×1 |
| Tinh anh | `ELITE_EHP` `ELITE_DMG` | Nhân lên từ lính cùng stage: EHP ×10, sát thương ×2.5 |
| Boss | `BOSS_SECONDS` `BOSS_HITS_TO_KILL` | **Không** nhân từ lính. Đo sức mạnh thật của đội — xem [boss.md](boss.md) |

Một wave = `50 + 10 = 60` đơn vị EHP lính.

**Boss thì không nằm trên thang đó.** Máu boss = `hoả lực đo được của đội × 40
giây`, nên trận boss dài đúng 40 giây ở mọi cảnh giới bất kể người chơi mạnh
yếu. Bản cũ của trang này ghi "EHP ×80" — đó là hệ cũ, đã bỏ cùng hai khoá
`BOSS_EHP` / `BOSS_DMG`.

**Giáp không nằm trong đường cong.** Đường cong sinh ra EHP; máu thật suy ngược ra
từ giáp. Đổi giáp **không** đổi độ khó.
[ADR 0010](../05-quyet-dinh/0010-giap-khong-nam-trong-duong-cong.md)

## Theo số người chơi

**Số lượng cố định, chỉ chỉ số nhân.**
[ADR 0009](../05-quyet-dinh/0009-so-luong-linh-co-dinh.md)

| Khoá | Tác dụng | Ràng buộc |
|---|---|---|
| `SCALE_EHP_PER_PLAYER` | EHP lính nhân thêm mỗi người | Phải **< 1.0**. Bằng 1.0 là phạt người chơi vì rủ bạn |
| `SCALE_DMG_PER_PLAYER` | Sát thương nhân thêm | Giữ **nhỏ**. Ba người có gấp ba sát thương, nhưng mỗi người vẫn chỉ có **một** thân — quái đánh đau gấp ba thì ba người chết nhanh như một |
| `SCALE_RECOUNT_EACH_WAVE` | Tính lại `P` mỗi wave | `true` — người thoát giữa chừng không khoá cứng ván của người ở lại |

**Boss không dùng bảng này.** Khoá `SCALE_BOSS_EHP_PER_PLAYER` đã bỏ: hoả lực
đo được (`measureParty`) đã là **tổng của cả đội** rồi, nhân thêm lần nữa là
phạt người chơi vì rủ được bạn.

## Đường đi

**Đang chạy phương án A.** Lưới 25 block và 8 dòng sông
([luoi-25-o.md](../04-map/luoi-25-o.md)) vẫn chưa gắn gì vào đợt quái.

| | Cách | Được | Mất |
|---|---|---|---|
| **A** ✔ | Quái ra ở `MyEmenyRegion`, đi thẳng tới nhà | Đơn giản nhất, đã chạy | Lưới 25 block thành trang trí |
| B | Quái đi theo hành lang giữa các block, sông chặn hai bên | Lưới có ý nghĩa, vị trí đứng quan trọng | Phải vẽ địa hình xong trước |
| C | Nhiều cửa, mỗi cảnh giới đổi cửa | Người chơi phải đọc bản đồ | Chia nhỏ lực lượng 3 người, dễ hỏng |

Nâng lên B khi địa hình xong. Đổi từ A sang B chỉ là đổi điểm sinh và điểm đến,
không đụng đường cong chỉ số.

Điểm sinh xê dịch trong bán kính `SPAWN_JITTER` để 50 con không chồng lên nhau
một chỗ. Cứ `WAVE_TICK` giây phát lại lệnh đi cho mọi con còn sống — quái bị đánh
lạc hướng không tự quay về nhà.

## Tên quái

Mỗi con mang tên **cảnh giới + tầng + loại**, đặt bằng `BlzSetUnitName` lúc sinh.
Dòng báo đợt kể ra cả hai loại, bằng đúng cái tên đang nằm trên con quái:

```
[7/100] Luyen Khi Trung Ki
   50 x Luyen Khi Tang 1 - Tan Tu   +   1 x Luyen Khi Tang 1 - Tinh Anh
```

Tầng nằm trong tên vì quái **dồn lại qua nhiều wave** — đo được: ở stage 6 vẫn
còn 174 con sống. Không có tầng thì cả 5 stage của một cảnh giới trùng tên nhau,
nhìn vào không phân biệt được thế hệ nào với thế hệ nào, mà chúng trả giá thưởng
khác nhau (`S.mobStage` trả theo stage lúc **sinh**). Bảng chuỗi đầy đủ:
[ngon-ngu.md](ngon-ngu.md).

`CFG.MOB_UNIT` hiện là **placeholder**: bốn unit gốc của Warcraft — Footman,
Ghoul, Abomination, Frost Wyrm — một mẫu cho mỗi cõi. Bản thiết kế cần 4 cõi ×
6 mẫu = 24 unit type. **Tên đã đúng; hình dáng thì chưa.**

## Thua

Nhà chính **nhận sát thương bình thường, chết là thua**. Không đếm mạng, không
lọt-trừ-mạng — [ADR 0011](../05-quyet-dinh/0011-nha-chinh-dem-mang.md) **đã bị lật**.

Máu nhà không cố định được: sát thương địch tăng ×279 qua 100 stage, nên 1 000
máu ở stage 100 chết trong dưới một giây. Thay vào đó máu tính lại **mỗi wave**:

```
máu tối đa = HOUSE_HP_HITS × sát thương một con lính ở stage đó
```

Tỉ lệ sống sót giữ nguyên suốt ván, và cả map chỉ còn **một** con số chỉnh độ
khoan dung. Mỗi wave nhà hồi thêm `HOUSE_REGEN_PER_WAVE` phần máu tối đa — giữ
nguyên tỉ lệ máu đang có rồi cộng thêm, chứ không đặt lại đầy (đặt lại đầy thì
lọt bao nhiêu cũng không sao).

## Số liệu

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `WAVE_MOB_COUNT` | Lính mỗi wave | `50`, cố định |
| `WAVE_ELITE_COUNT` | Tinh anh mỗi wave | `1` |
| `WAVE_RECOUNT` | Giây giữa hai lần đo lại số quái sống | `10`. Lưới đỡ bắt buộc — [ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md) |
| `WAVE_MAX_ALIVE` | Trần unit sống | ~300. Chặn **nút gọi đợt**. Chạm thường xuyên = đường cong sai |

> ⛔ **Bốn khoá đồng hồ đã xoá** — `WAVE_TIME` `WAVE_FIRST_DELAY`
> `WAVE_WAIT_FIRST` `WAVE_AUTO_NEXT` `WAVE_CLEAR_DELAY`. Mọi đợt giờ đều chờ
> người chơi gọi. Xem [bang-tran-dau.md](bang-tran-dau.md).
| `WAVE_TICK` | Giây giữa hai lần ra lệnh lại cho quái | Quái bị đánh lạc hướng phải quay về nhà |
| `SPAWN_JITTER` | Bán kính xê dịch điểm sinh | Đủ rộng để 50 con không chồng một chỗ |
| `MOB_UNIT` | Mẫu lính mỗi cõi, tra theo `REALMS[r].coi` | **Placeholder** — 4 unit gốc WC3. Thiết kế cần 24 |
| `TIERS_PER_REALM` | `4` | Đổi là đổi tổng stage; mọi thứ suy ra từ nó. 4 tầng + 1 boss = 5 stage/cảnh giới, ×20 = **100 stage** |

## Chưa làm

- **Chưa chơi thử một giây nào.** Ba chỗ dễ sai nhất: DPS thật của hero ở
  stage 1, thời gian quái đi bộ tới nhà, và `MOB_EHP_BASE`.
- **Tu chính chưa cài.** Bảng ở trên còn là phác thảo: chưa có số, chưa có khoá
  `MODIFIERS` nào trong `CFG`. Hiện 4 tầng của một cảnh giới **chỉ khác nhau ở
  chỉ số** — mà chỉ số chỉ nhích ×1.054 suốt 4 tầng, nên trên thực tế chúng
  giống hệt nhau. Theo chính L6 thì đây là khoảng trống lớn nhất còn lại của hệ
  này: tầng đáng ra phải đổi *cách chơi*, hiện chỉ đổi *cái tên*.
- **6 mẫu lính chưa có** — `MOB_UNIT` mới là 4 unit gốc WC3 làm placeholder.
- **Boss chưa có gì riêng**: cùng mẫu lính, chỉ to hơn và đỏ hơn — xem
  [boss.md](boss.md).
- Đường đi phương án B, khi địa hình xong.
