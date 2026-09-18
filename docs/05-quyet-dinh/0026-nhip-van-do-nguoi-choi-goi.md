# 0026 — Nhịp cả ván do người chơi gọi, không do đồng hồ

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-18
> **Thay thế phần "đồng hồ" của** [0018](0018-nghi-giua-hai-canh-gioi.md)

## Bối cảnh

Người chơi dọn sạch một đợt, và **1.5 giây** sau đợt mới ra
(`WAVE_AUTO_NEXT` + `WAVE_CLEAR_DELAY`). Không đủ để mở bảng mua đá, nâng kỹ
năng, hay dùng lượt Cơ Duyên.

Mà [ADR 0018](0018-nghi-giua-hai-canh-gioi.md) đã ghi lý do việc đó nghiêm trọng:
**frame không dừng game**. Mở bảng giữa đợt nghĩa là đứng chịu đòn. Nên "tiêu
tiền" không có chỗ của nó trong cả ván, dù bốn hệ nâng cấp đều tiêu tiền.

Cùng lúc, ba thứ khác nhau đang bị gọi chung là "bộ đếm", và chỉ một trong ba
thật sự cầm lái:

| | Làm gì |
|---|---|
| `S.waveDlg` | Cửa sổ đếm ngược *"Đợt sau: 0:32"* |
| `WAVE_FIRST_DELAY` | 15 giây trước đợt 1 — **đã chết sẵn** vì `WAVE_WAIT_FIRST` |
| `WAVE_AUTO_NEXT` | Dọn sạch xong 1.5 giây là đợt mới ra |

Đọc `onWaveTimer()` thì thấy cửa sổ đếm ngược **không quyết định gì**: với
`WAVE_ONLY_WHEN_CLEAR` bật, dọn sạch sớm thì `onMobDeath` kéo đợt sau vào trước;
dọn chậm thì đồng hồ **tự ẩn đi** rồi hoãn vô hạn. Con số chạy trên màn hình chỉ
tạo áp lực giả.

## Quyết định

**Không đồng hồ nào kéo đợt mới vào. Nhịp cả ván do nút `GỌI ĐỢT` trên bảng
trận đấu (phím R) quyết định, và chỉ nó.**

Xoá `S.waveDlg`, `WAVE_TIME`, `WAVE_FIRST_DELAY`, `WAVE_AUTO_NEXT`,
`WAVE_CLEAR_DELAY`, `WAVE_WAIT_FIRST`.

Giữ `WAVE_ONLY_WHEN_CLEAR` — nó thành điều kiện bật/tắt của nút.

Thêm `WAVE_RECOUNT`: cứ 10 giây **đo lại** số quái sống thay vì tin con số đang
giữ. Đây là điều kiện bắt buộc của quyết định trên — xem phần Hệ quả.

## Phương án đã loại

**Giữ đồng hồ làm trần, nút chỉ để "gọi sớm".** Đây là khuôn mẫu chuẩn của thể
loại (Legion TD, Bloons): đồng hồ rộng rãi, gọi sớm được thưởng. Loại vì nó giữ
lại đúng thứ gây khó chịu — người chơi vẫn bị một con số hối — và vì phần thưởng
gọi sớm là một hệ kinh tế nữa phải cân, trong khi bốn hệ hiện có còn chưa chơi thử.

Có thể quay lại phương án này nếu đo thấy ván lê thê.

**Xoá luôn cả lệnh `-next`.** Đề xuất ban đầu. Loại vì `framesAvailable()` có thể
trả `false` — bản game thiếu native frame thì không vẽ được bảng nào, và lúc đó
không còn cách nào khởi động ván. Bảng nhân vật đã phải in *"Không vẽ được bảng —
dùng lệnh chat"* vì đúng lý do đó.

**Đếm lại bằng cách quét map theo chủ sở hữu** (`GetOwningPlayer == S.enemy`).
Loại vì nó hỏng ngay ngày thêm vùng đất có **quái đặt sẵn** — chúng cũng thuộc
phe địch, nên `S.alive` không bao giờ về 0. Đúng cái bẫy phép đo này định chữa.
Đếm qua `S.mobs` thì miễn nhiễm, vì bảng đó chỉ được ghi ở đường sinh của hệ wave.

## Hệ quả

**1. Mất khả năng ước lượng thời lượng ván.** Con số *"134 phút"* trong
[duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md) tính bằng
`100 stage × WAVE_TIME`. Không còn `WAVE_TIME` thì thời lượng do người chơi quyết
— không tính trước được nữa, chỉ **đo** sau trận chơi thử. Mọi ngân sách thời gian
trong `docs/` trở thành lịch sử.

**2. Không còn sức ép tốc độ.** Quái bám đường cong Tu Vi nên độ khó tự cân bằng,
nhưng nó không nói gì về **tốc độ** — giờ một đội đánh chậm vẫn thắng, chỉ lâu hơn.
Nếu sau này cần sức ép trở lại, nó phải đến từ nội dung (Lôi Kiếp, nhiệm vụ có
hạn giờ) chứ đừng gắn lại đồng hồ.

**3. Ràng buộc khó chịu nhất của ADR 0018 biến mất.**

```
WAVE_TIME[cõi]  >  quãng đường/tốc độ  +  thời gian giết hết một đợt
```

Ràng buộc này đã làm sai `WAVE_TIME` **hai lần** (cõi 1 và cõi 3) và khoá cứng
mọi lần đổi `CFG.MOB_UNIT` — đổi loại lính là phải tính lại cả bảng. Giờ không còn.

**4. Bắt buộc phải có phép đo lại.** Trước đây ba đường cùng tồn tại (dọn sạch tự
động · lệnh `-next` · đồng hồ). Quyết định này bỏ hai. Đường còn lại hỏi `S.alive`,
mà ADR 0018 đã ghi lại lần con số đó kẹt và làm chết mọi lối thoát. Nên phép đo
lại **không phải tính năng phụ, nó là điều kiện để quyết định này an toàn**.

**5. Thêm một ràng buộc vĩnh viễn cho mọi code sau này.** Mọi unit địch mà hệ
wave chịu trách nhiệm dọn **phải đi qua `spawnStage`**. Gọi `CreateUnit` thẳng
cho phe địch là tạo một con quái vô hình với bộ đếm — và nó hỏng im lặng.

**6. Hai mốc nghỉ của ADR 0018 vẫn còn, nhưng đổi vai.** Chúng không còn là "dừng
đồng hồ" (không còn đồng hồ để dừng) — chúng là **hai nhãn khác** của cùng một
nút: `TRIỆU BOSS` và `SANG <cảnh giới>`. Mốc thứ hai là chỗ Lôi Kiếp sẽ gắn vào.
