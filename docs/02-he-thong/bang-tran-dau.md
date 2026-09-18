# Bảng trận đấu — phím R

> **Trạng thái:** **Đã cài**
> **Cập nhật:** 2026-09-18
> **Khoá CFG:** `GAME_KEY` `GAME_X/Y` `OP_WAVE_CALL` `WAVE_ONLY_WHEN_CLEAR`
> `WAVE_RECOUNT` `WAVE_REST` `WAVE_MAX_ALIVE`
> **Mã:** [6_gameframe.lua](../../src/4_ui/6_gameframe.lua) *(giao diện)* ·
> [2_wave.lua](../../src/3_battle/2_wave.lua) *(luật)*

**Bảng thứ hai**, tách khỏi bảng nhân vật có chủ ý:

| Phím | Trả lời câu hỏi | Mở lúc nào |
|---|---|---|
| **ESC** | *Nhân vật tôi thế nào?* | giữa trận, vội |
| **R** | *Trận đấu đang thế nào?* | giữa hai đợt, thong thả |

Hai câu hỏi khác nhau, hai nhịp khác nhau. Gộp làm một bảng bảy thẻ là bắt người
chơi cuộn qua Trang Bị để tìm nút gọi đợt.

## Hai thẻ

```
┌─ R ─── I. Tổng Quan ──── II. Nhiệm Vụ Phụ ────────────┐
│                                                        │
│   Đợt 37 / 100                                         │
│   Kim Đan -- Tầng 2                                    │
│   Còn 3 đợt nữa tới boss Kim Đan                       │
│   Quái còn sống: 0                                     │
│                                                        │
│          ┌──────────────────────────┐                  │
│          │      ĐỢT TIẾP  (38)      │                  │
│          └──────────────────────────┘                  │
└────────────────────────────────────────────────────────┘
```

**II. Nhiệm Vụ Phụ** để trống có chủ ý — 25 block đang dành cho phần này
([ADR 0014](../05-quyet-dinh/0014-25-block-de-danh-cho-noi-dung-sau.md)). Thẻ
vẫn hiện, và nói rõ *"chưa có gì"* thay vì để trắng: một thẻ trắng khiến người
chơi tưởng giao diện hỏng.

## Một nút, bốn nhãn

Nút gọi đợt **không phải bốn nút**, vì ba cái sẽ luôn xám. Nhãn đổi theo trạng
thái, và trạng thái do `API.waveCallState()` trong `2_wave.lua` quyết định —
giao diện chỉ **vẽ lại** thứ hàm đó trả về, không tự suy ra gì.

| Trạng thái | Nhãn | Bấm được |
|---|---|---|
| chưa vào đợt nào | `GỌI ĐỢT 1` | ✓ |
| vừa dọn sạch | `ĐỢT TIẾP (n)` | ✓ |
| dọn sạch tầng cuối | `TRIỆU BOSS` | ✓ |
| vừa hạ boss | `SANG <cảnh giới>` | ✓ |
| còn quái trên map | `CÒN n QUÁI` | ✗ |
| xong 100 đợt | `ĐÃ QUA TRỌN 100 ĐỢT` | ✗ |

**Điều kiện kiểm ở hai nơi, và đó là cố ý.** Giao diện kiểm để vẽ nút xám; `waveNow()`
kiểm lại lúc nhận. Nút có thể bị bấm đúng lúc con cuối cùng chưa chết, và lệnh chat
thì không đi qua giao diện bao giờ.

## Ai được bấm

**Ai cũng được.** Ba người là đồng minh; bấm xong thì chat báo ai vừa gọi.

Không xây cơ chế "cả ba sẵn sàng": với ba người chơi chung thì áp lực xã hội xử lý
việc đó tốt hơn một cơ chế, mà mỗi cơ chế là một chỗ có thể treo.

Cú bấm chỉ **gửi ý định** qua `CFG.OP_WAVE_CALL`; việc gọi đợt thật chạy trên
**mọi** máy, từ hàm nhận của kênh đồng bộ.

---

## Đồng hồ đã bỏ, và vì sao

Trước đây có ba thứ cùng được gọi là "bộ đếm". Chỉ một trong ba thật sự cầm lái.

| | Đã làm gì | Số phận |
|---|---|---|
| Cửa sổ đếm ngược `S.waveDlg` | Hiện *"Đợt sau: 0:32"* | **Xoá** |
| `WAVE_FIRST_DELAY` | 15 giây trước đợt 1 | **Xoá** |
| `WAVE_AUTO_NEXT` + `WAVE_CLEAR_DELAY` | Dọn sạch xong **1.5 giây** là đợt mới ra | **Xoá** |

Cửa sổ đếm ngược **đã không quyết định gì từ lâu**. Với `WAVE_ONLY_WHEN_CLEAR`
bật, dọn sạch sớm thì `onMobDeath` kéo đợt sau vào trước; dọn chậm thì đồng hồ
**tự ẩn đi** rồi hoãn. Con số chạy trên màn hình chỉ tạo áp lực giả.

Thứ thật sự không cho người chơi thở là **1.5 giây** của `WAVE_AUTO_NEXT`: dọn
xong chưa kịp mở bảng mua đá đã có đợt mới trên đầu. Đó mới là cái bị bỏ.

[ADR 0026](../05-quyet-dinh/0026-nhip-van-do-nguoi-choi-goi.md) ghi lại quyết
định và cái giá của nó.

## Đo lại số quái — lưới đỡ bắt buộc

**Lỗi thật đã xảy ra** ([ADR 0018](../05-quyet-dinh/0018-nghi-giua-hai-canh-gioi.md)):
`S.alive` kẹt trên 0 thì **mọi** lối thoát cùng chết — cả đường "dọn sạch" lẫn
lệnh gọi tay, vì cả hai hỏi cùng con số đó. Kẹt là kẹt vĩnh viễn, không lỗi nào báo.

Nên cứ `CFG.WAVE_RECOUNT` giây lại **đo lại** thay vì tin con số đang giữ:

```
mỗi 10 giây:
    duyệt S.mobs
        còn sống  -> đếm
        đã mất    -> xoá khỏi bảng
    lệch  -> ghi vết, sửa S.alive
    vừa về 0 -> chạy nốt phần "đã dọn sạch"
```

**Ba điều bắt buộc trong phép đo này:**

**1. Đếm qua `S.mobs`, KHÔNG quét map theo chủ sở hữu.** `S.mobs` chỉ được ghi ở
đường sinh quái của hệ wave, nên quái **đặt sẵn** ở các vùng đất sau này không bao
giờ lọt vào. Đếm theo `GetOwningPlayer == S.enemy` thì vơ luôn chúng, `S.alive`
không bao giờ về 0 — **đúng cái bẫy phép đo này định chữa**.

> **Ràng buộc kéo theo:** mọi unit địch mà hệ wave chịu trách nhiệm dọn **phải đi
> qua `spawnStage`**. Gọi `CreateUnit` thẳng cho phe địch là tạo một con quái vô
> hình với bộ đếm — dọn sạch sẽ không bao giờ xảy ra, và không có lỗi nào báo.
>
> Thuộc hạ boss đã tuân luật này: `summonAdds()` gọi qua `API.waveSpawnAt` thay
> vì `CreateUnit`, và chú thích tại chỗ nói rõ lý do.

**2. Phải chạy nốt phần "đã dọn sạch".** Nếu con cuối cùng biến mất mà không sinh
sự kiện chết, `onMobDeath` không chạy cho nó. Hai mốc nghỉ nằm trong đó, nên cả ván
sẽ **bỏ qua boss trong im lặng** — nút hiện `ĐỢT TIẾP` thay vì `TRIỆU BOSS`. Vì
thế phần đó đã tách thành `onWaveCleared()`, gọi được từ cả hai đường.

**3. Vòng lặp đó không được làm gì khác ngoài đếm.** Thứ tự duyệt `pairs()` có thể
khác nhau giữa các máy. Đếm thì không phụ thuộc thứ tự nên an toàn — thêm một
`GetRandomInt` hay một hành động vào trong đó là lệch đồng bộ ngay.

## ESC: ba tầng, loại trừ nhau

**Hai bảng không bao giờ mở cùng lúc.** Mở bảng này là đóng bảng kia. Chồng lên
nhau thì ESC phải đoán đóng cái nào, mà câu hỏi đó không có đáp án đúng.

```
Bấm ESC:
  Cơ Duyên mở?  -> không làm gì      (phải chọn thẻ mới đi tiếp)
  Bảng R mở?    -> đóng, dừng
  Bảng ESC mở?  -> đóng, dừng
  không gì mở   -> mở bảng ESC
```

Hỏi bảng R **trước**. Đảo lại thì mở R rồi bấm ESC sẽ đi vào nhánh *"bảng này đang
đóng → mở nó ra"*, và bảng R nằm lì.

**`bindEsc()` trong [1_panel.lua](../../src/4_ui/1_panel.lua) là chủ sở hữu ESC
duy nhất.** File bảng R **không** tự đăng ký ESC: hai bộ đăng ký trên cùng một
trigger là một cú bấm nổ hai lần — đó là lý do `CFG.PANEL_ESC_LOCK` tồn tại.

## Hai bẫy giao diện đã trả giá rồi

**Trả tiêu điểm bàn phím sau mỗi cú bấm.** `GLUEBUTTON` giữ tiêu điểm và nuốt hết
phím, nên bấm nút gọi đợt xong thì **ESC chết**. Tắt rồi bật lại frame là cách trả
ở bản 1.31. Lỗi này thuộc loại "lúc được lúc không", khó lần nhất.

**`GetLocalPlayer` chỉ dùng cho hiện/ẩn.** Mọi thay đổi trạng thái đi qua kênh
đồng bộ. Một nhánh `GetLocalPlayer` có gọi `GetRandomInt` là từ giây đó mọi số
ngẫu nhiên của cả ván đều lệch.

## `-next` vẫn còn, làm đường lui

Không xoá. `framesAvailable()` có thể trả `false` khi bản game thiếu native frame,
và lúc đó **không còn cách nào khởi động ván** — bảng nhân vật đã phải in *"Không
vẽ được bảng — dùng lệnh chat"* vì đúng lý do đó.

Nó không phải lệnh cheat: vẫn đòi dọn sạch quái mới gọi được, y như nút.
