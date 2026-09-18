# 0018 — Đồng hồ dừng hẳn ở hai mốc mỗi cảnh giới

> ⛔ **Số trong tài liệu này tính theo `WAVE_TIME`, khoá đã xoá ngày 2026-09-18.**
> Nhịp cả ván giờ do người chơi gọi, nên **thời lượng ván không tính trước được
> nữa** — chỉ đo sau trận chơi thử. Lập luận giữ nguyên; con số là lịch sử.
> [ADR 0026](0026-nhip-van-do-nguoi-choi-goi.md)

> **Số trong tài liệu này tính cho 220 stage** *(10 tầng + boss mỗi cảnh giới)*.
> Từ 2026-09-17 còn **100 stage** *(4 tầng + boss)*, và thu nhập đã thành phẳng.
> Lập luận giữ nguyên; con số thì tra [bang-can-bang.md](../03-du-lieu/bang-can-bang.md).


> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-16

## Bối cảnh

Hai vấn đề lộ ra cùng lúc khi đo quãng đường quái đi.

**Một: nhánh "dọn sạch → vào đợt sau" không bao giờ chạy được ở cõi 1.**

Cửa quái cách nhà 5 361 đơn vị. Footman đi 270/giây → **19.9 giây**. `WAVE_TIME`
cõi 1 là **20.0 giây**.

```
t = 0.0s   đợt N sinh ở cửa
t = 19.9s  đợt N tới nhà
t = 20.0s  đợt N+1 sinh
```

Người chơi có **0.1 giây** để giết 50 con. Nghĩa là `S.alive` không bao giờ về 0,
nên `WAVE_AUTO_NEXT` và lệnh `-next` — cả hai đều đòi `alive == 0` — **chết hẳn
suốt 55 đợt đầu**. Cơ chế có trong code nhưng không với tới được.

Ràng buộc chưa ai viết ra:

```
WAVE_TIME[cõi]  >  quãng đường/tốc độ  +  thời gian giết hết một đợt
```

Cõi 3 cũng vi phạm (cần ≥38s, đang đặt 36).

**Hai: 100 đợt là một dòng chảy phẳng, không có nhịp.** Không có mở, không có
kết, không có chỗ thở. Và vì frame **không dừng game**, mở bảng phím R để mua sắm
nghĩa là đứng chịu đòn — nên việc tiêu tiền không có chỗ của nó trong cả ván.

## Quyết định

**Đồng hồ chạy suốt 10 tầng, rồi dừng hẳn ở hai mốc.** `CFG.WAVE_REST`

```
tầng 1…10          đồng hồ chạy          ← áp lực, đợt chồng được
tầng 10 dọn sạch → DỪNG đồng hồ          ← nghỉ
     -next       → BOSS
boss chết        → DỪNG đồng hồ          ← nghỉ, tiêu Tinh Thạch vừa rơi
     -next       → cảnh giới sau, tầng 1
```

Kèm hai thay đổi phụ:

**`WAVE_TIME` = `{32, 28, 40, 45}`** — cõi 1 từ 20→32, cõi 3 từ 36→40, để vế phải
của ràng buộc trên có chỗ.

> Cõi 1 (32s) giờ **dài hơn** cõi 2 (28s) dù dễ hơn. Không phải nhầm:
> `WAVE_TIME` không thuần là độ khó, nó bị **chặn dưới bởi tốc độ mẫu lính**.
> Footman (270) chậm hơn Ghoul (350) nên cõi 1 cần nhiều giây hơn. Đổi
> `CFG.MOB_UNIT` là phải tính lại bảng này.

**Boss không bao giờ sinh đè lên quái đang sống.** Nếu hết giờ mà tầng 10 chưa
dọn xong thì hoãn, không sinh boss. Giữ đúng L4 của
[dot-quai.md](../02-he-thong/dot-quai.md) — "boss chiếm trọn stage, một mình".

## Phương án đã loại

**Bỏ hẳn đồng hồ — mọi đợt đều chờ dọn sạch + 15 giây (hoặc `-next`).** Đơn giản
nhất, dễ hiểu nhất, và không bao giờ bị hai đợt chồng nhau.

Loại vì `WAVE_TIME` đang là **mỏ neo của hợp đồng DPS ×967**: cả đường cong sức
mạnh suy ra từ "wave phải hạ kịp giờ"
([duong-cong-suc-manh.md](../03-du-lieu/duong-cong-suc-manh.md)). Bỏ áp lực thời
gian thì không còn lý do nào phải xây DPS — người chơi cứ đánh chậm là xong — và
hợp đồng phải neo lại vào "nhà chịu được mấy đòn", tức viết lại toàn bộ bảng tra.
Đổi lấy một thứ nhỏ hơn nhiều so với cái phải trả.

**Dừng một lần thay vì hai (chỉ sau boss).** Gọn hơn — 20 lần gõ `-next` thay vì
40. Loại vì nó bỏ mất cái hay nhất: boss được **người chơi gọi khi sẵn sàng**,
thay vì lẫn vào dòng đợt quái như một stage nữa.

**Dời cửa quái xa hơn.** Từng đề xuất, và **sai**: xa hơn là đi lâu hơn, càng ít
thời gian đánh. Muốn có chỗ thở thì phải gần hơn, hoặc tăng `WAVE_TIME`.

## Cái phải trả: dài thêm 16 phút

| | |
|---|---|
| Cũ — 100 stage × `WAVE_TIME` | **118 phút** |
| Mới — 200 đợt thường | 121 phút |
| Mới — 20 boss (~40s, không đồng hồ) | 13 phút |
| Mới — 40 cửa sổ nghỉ | 0 nếu gõ `-next` ngay |
| **Tổng** | **134 phút** (+16) |

Gần hết phần tăng đến từ `WAVE_TIME` cõi 1 (+10 phút).

**Và điều đó làm rủi ro lớn nhất của thiết kế nặng thêm.**
[dot-quai.md](../02-he-thong/dot-quai.md) đã gọi thời lượng là "con số đáng lo
nhất": map co-op quá 90 phút là người chơi rời trận, mà mất một người là hỏng cả
ván.

Lập luận bênh vực — và nó là lập luận thật, không phải bào chữa: **134 phút chia
thành 20 khối 6–8 phút, mỗi khối có mở–thân–kết, đọc rất khác 118 phút một mạch
không cho thở.** Nhưng nếu chơi thử vẫn thấy dài thì chỗ cắt là
`TIERS_PER_REALM` 10 → 5, không phải bỏ nhịp nghỉ.

## Hệ quả

`S.waitNext` = `nil` | `"boss"` | `"realm"` — đồng hồ đang chạy, hay đang chờ
`-next` để làm gì.

Lúc nghỉ, **đồng hồ đếm bị ẩn** chứ không để hiện số 0:00 đứng yên — đúng lỗi mà
`WAVE_WAIT_FIRST` đã phải xử lý một lần.

`-next` giờ là thứ **duy nhất** đi tiếp được ở hai mốc đó, nên nó càng phải không
theo `CFG.DEV_COMMANDS` — tắt đi là ván đứng vĩnh viễn.
