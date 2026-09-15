# Thiết kế hero & bộ kỹ năng

> **Trạng thái:** Nháp — chưa có ability nào trong Object Editor
> **Cập nhật:** 2026-09-15
> **Liên quan:** [chon-hero.md](chon-hero.md), [ky-nang.md](ky-nang.md)

## Ba vai, ba bài toán khác nhau

| Hero | ID | Vai | Bài toán người chơi phải giải |
|---|---|---|---|
| Hart | `H001` | Tanker | Quái đi tới đâu? Ta đứng chặn ở đâu để nó không chạm nhà? |
| Hvwd | `H002` | Carry | Giết con nào trước? Đứng đâu để bắn được mà không bị đánh? |
| Hkal | `H003` | Support | Cứu ai trước? Tiêu mana vào lúc nào? |

Ba vai này chỉ có nghĩa khi **cả ba cùng cần nhau**. Nếu Tanker tự sống được, Support
thành thừa. Nếu Carry tự giết hết, Tanker thành thừa. Mỗi bộ kỹ năng dưới đây đều
có ít nhất một chỗ cố ý để hở, buộc phải nhờ vai khác lấp.

## Bảy ô, không hơn

Command card còn đúng **7 ô trống** sau các lệnh cơ bản. Nên mỗi hero có đúng 7 kỹ
năng — không phải con số tuỳ tiện, mà là giới hạn cứng của giao diện.

| | X=0 | X=1 | X=2 | X=3 |
|---|---|---|---|---|
| **Y=0** | Move | Stop | Hold | Attack |
| **Y=1** | Patrol | ô 1 | ô 2 | ô 3 |
| **Y=2** | ô 4 | ô 5 | ô 6 | **ô 7 — Hồi sinh** |

Kỹ năng bị động (passive) **vẫn chiếm một ô** trong Warcraft III. Đã tính vào 7.

Ô 7 dành riêng cho Hồi sinh ở cả ba hero, cùng một vị trí — để người chơi đổi hero
vẫn tìm thấy nó ở chỗ cũ.

---

## Hart — Tanker

Không giết được gì đáng kể. Giá trị nằm ở chỗ **quái đánh Hart thay vì đánh nhà**.

| Ô | Kỹ năng | Loại | Làm gì |
|---|---|---|---|
| 1 | **Khiêu Khích** | Chủ động, vùng | Ép mọi quái trong bán kính đổi mục tiêu sang Hart, vài giây |
| 2 | **Da Sắt** | Bị động | Giảm % sát thương nhận vào |
| 3 | **Tường Chắn** | Chủ động, bản thân | Giảm mạnh sát thương trong thời gian ngắn, hồi chiêu dài |
| 4 | **Dậm Đất** | Chủ động, vùng | Sát thương nhẹ + làm chậm quanh Hart |
| 5 | **Hiệu Lệnh** | Bị động, hào quang | Đồng đội quanh Hart nhận ít sát thương hơn |
| 6 | **Tử Thủ** | Chủ động | Máu dưới ngưỡng thì hồi một cục lớn, hồi chiêu rất dài |
| 7 | **Hồi Sinh** | Chủ động | Xem phần chung bên dưới |

**Chỗ để hở:** Hart gần như không có sát thương. Một mình Hart thì quái không bao giờ
chết — nó chỉ đứng chịu đòn tới khi hết Tử Thủ.

**Cặp đôi đáng chú ý:** Khiêu Khích kéo quái vào một chỗ, rồi Carry dội sát thương vùng
lên đúng đống đó. Đây là khoảnh khắc "phối hợp" của map — nên làm bán kính Khiêu Khích
khớp với bán kính chiêu vùng của Carry.

---

## Hvwd — Carry

Nguồn sát thương chính. Yếu khi bị chạm vào.

| Ô | Kỹ năng | Loại | Làm gì |
|---|---|---|---|
| 1 | **Mũi Xuyên** | Chủ động, đường thẳng | Sát thương mọi mục tiêu trên một đường |
| 2 | **Liên Xạ** | Chủ động, bản thân | Tăng mạnh tốc đánh trong thời gian ngắn |
| 3 | **Dấu Thợ Săn** | Chủ động, mục tiêu | Mục tiêu nhận thêm % sát thương từ mọi nguồn |
| 4 | **Đa Tiễn** | Bị động | Mỗi đòn đánh chạm thêm vài mục tiêu gần đó |
| 5 | **Tụ Khí** | Bị động | Tỉ lệ ra đòn chí mạng |
| 6 | **Mưa Tên** | Chủ động, vùng lớn | Sát thương vùng lớn, hồi chiêu dài — đòn dọn đợt |
| 7 | **Hồi Sinh** | Chủ động | Xem phần chung bên dưới |

**Chỗ để hở:** máu thấp, không có kỹ năng thoát thân nào. Quái chạm được là chết.
Đứng sai chỗ thì cả bộ kỹ năng vô nghĩa.

**Dấu Thợ Săn** cố ý là buff cho *mọi nguồn sát thương*, không riêng Hvwd — để Carry
có lý do nhắm vào con mà cả đội đang đánh, thay vì tự bắn một mình.

---

## Hkal — Support

Không tự giải quyết được gì, nhưng làm hai người kia mạnh gấp bội.

| Ô | Kỹ năng | Loại | Làm gì |
|---|---|---|---|
| 1 | **Trị Liệu** | Chủ động, mục tiêu | Hồi máu một đồng đội |
| 2 | **Băng Vực** | Chủ động, vùng | Làm chậm mạnh quái trong vùng |
| 3 | **Khiên Pháp** | Chủ động, mục tiêu | Lá chắn hấp thụ một lượng sát thương |
| 4 | **Thần Tốc** | Chủ động, mục tiêu | Tăng tốc chạy và tốc đánh cho đồng đội |
| 5 | **Kích Pháp** | Chủ động, mục tiêu | Sát thương phép đơn mục tiêu |
| 6 | **Thánh Địa** | Chủ động, vùng | Vùng đứng yên: đồng đội bên trong hồi máu và chịu ít sát thương |
| 7 | **Hồi Sinh** | Chủ động | Xem phần chung bên dưới |

**Chỗ để hở:** sát thương gần như không có, mana là tài nguyên khan hiếm. Dùng hết
mana sớm là nửa sau của đợt quái không còn gì để cứu ai.

> **Mana phải là ràng buộc thật.** Nếu Hkal đủ mana để bấm mọi thứ mọi lúc thì vai
> Support biến thành bấm nút vô nghĩa. Chi phí mana nên đủ cao để mỗi đợt chỉ dùng
> được 3–4 lần kỹ năng lớn.

---

## Hồi Sinh — chung cho cả ba

Ô 7, cùng vị trí ở cả ba hero.

**Cách hoạt động đề xuất:** không nhắm mục tiêu. Bấm là hồi sinh **mọi hero đồng đội
đang chết** ngay tại chỗ người bấm, với một phần máu.

Lý do không nhắm mục tiêu: hero chết trong Warcraft III **không còn là mục tiêu hợp
lệ** — không click vào được. Làm kỹ năng nhắm vào xác hay vào vị trí chết đều phải
dựng thêm cơ chế đánh dấu. Không nhắm gì cả thì tránh được toàn bộ chuyện đó.

| Thông số | Đề xuất | Lý do |
|---|---|---|
| Hồi chiêu | Rất dài (vài phút) | Chết phải có sức nặng, không thì hồi sinh thành chuyện thường |
| Mana | Cao | Hkal bấm được thường xuyên hơn, đúng vai Support |
| Máu hồi sinh | 30–50% | Sống lại giữa đám quái vẫn nguy hiểm |
| Kênh (channel) | Cân nhắc | Kênh thì phải chọn thời điểm; bấm phát ăn ngay thì không |

**Cần code.** Object Editor không có ability "hồi sinh đồng đội" sẵn dùng được. Cách
làm: tạo một ability chủ động không mục tiêu (nhân bản từ một chiêu tức thời bất kỳ),
rồi bắt `EVENT_PLAYER_UNIT_SPELL_EFFECT` và gọi `ReviveHero(hero, x, y, true)` cho mọi
hero đồng đội đang chết.

Đây là phần duy nhất trong cả 21 kỹ năng **bắt buộc** phải có code. 20 cái còn lại
đều dựng được bằng Object Editor thuần.

---

## Lời khuyên về thứ tự làm

**Đừng làm cả 21 kỹ năng rồi mới test.** Đó là 21 lần có thể sai ID, sai Button
Position, sai loại ability — và phát hiện tất cả cùng lúc thì không biết cái nào hỏng
vì cái gì.

Thứ tự đề xuất:

1. **Một kỹ năng, một hero.** Làm Dậm Đất của Hart. Gắn vào `CFG.HEROES[1].abilities`,
   vào map, bấm thử. Xác nhận cả chuỗi chạy: tạo trong Object Editor → gắn bằng code
   → hiện đúng ô → bấm có tác dụng.
2. **Hồi Sinh.** Đây là cái khó nhất vì cần code. Làm sớm để nếu hướng sai thì còn
   kịp đổi.
3. **Nốt phần còn lại của Hart**, rồi Hvwd, rồi Hkal.

Bước 1 tốn khoảng 15 phút và loại bỏ mọi rủi ro quy trình. 20 cái sau chỉ còn là việc
lặp lại.

## Mỗi ability cần đặt gì trong Object Editor

| Trường | Giá trị | Vì sao |
|---|---|---|
| Loại ability | **Thường**, không phải hero ability | Hero ability cần điểm kỹ năng, mà map này khoá cấp độ |
| `Art - Button Position (X)(Y)` | Theo bảng 7 ô ở trên | Không đặt thì tất cả chồng lên nhau ở ô mặc định |
| `Stats - Levels` | 1 | Không có hệ nâng cấp từng cấp |
| `Art - Icon - Normal` | Icon riêng | Bảy icon giống nhau thì người chơi không phân biệt được |
| `Stats - Hotkey` | Phím riêng từng ô | |

Xong thì chép ID vào `CFG.HEROES[i].abilities` — code gắn tự động lúc tạo hero, và
báo đỏ ngay trong game nếu ID sai.

## Chưa quyết

- **Có cho chọn không, hay cả 7 luôn có sẵn?** Hiện thiết kế là cả 7 đều có. Muốn
  người chơi chọn build thì mỗi ô cần 2 ứng viên → 14 ability mỗi hero, gấp đôi khối
  lượng. Đề xuất: làm 7 cái cố định trước, chơi thử, rồi mới thêm nhánh vào 2–3 ô
  đáng chọn nhất.
- Con số cụ thể (sát thương, hồi chiêu, mana, bán kính) — chưa đặt cái nào. Cần có
  đợt quái rồi mới cân được.
- Hồi Sinh có nên kênh hay không.
