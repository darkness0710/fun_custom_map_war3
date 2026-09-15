# Thiết kế hero & bộ kỹ năng

> **Trạng thái:** Nháp — chưa có ability nào trong Object Editor
> **Cập nhật:** 2026-09-15
> **Liên quan:** [chon-hero.md](chon-hero.md), [ky-nang.md](ky-nang.md)

## Ba vai, ba bài toán khác nhau

| Hero | ID | Vai | Bài toán người chơi phải giải |
|---|---|---|---|
| Hart | `H001` | Tanker | Quái đi tới đâu? Đứng chặn ở đâu để nó không chạm nhà? |
| Hvwd | `H002` | Carry | Giết con nào trước? Đứng đâu để bắn được mà không bị đánh? |
| Hkal | `H003` | Support | Cứu ai trước? Tiêu mana vào lúc nào? |

Ba vai chỉ có nghĩa khi **cả ba cùng cần nhau**. Nếu Tanker tự sống được, Support
thành thừa. Nếu Carry tự giết hết, Tanker thành thừa. Mỗi bộ dưới đây đều có ít nhất
một chỗ **cố ý để hở**, buộc phải nhờ vai khác lấp.

## Bảy ô, không hơn

Command card còn đúng **7 ô trống** sau các lệnh cơ bản. Nên mỗi hero có đúng 7 kỹ
năng — không phải con số tuỳ tiện, mà là giới hạn cứng của giao diện.

| | X=0 | X=1 | X=2 | X=3 |
|---|---|---|---|---|
| **Y=0** | Move | Stop | Hold | Attack |
| **Y=1** | Patrol | ô 1 | ô 2 | ô 3 |
| **Y=2** | ô 4 | ô 5 | ô 6 | ô 7 |

Kỹ năng bị động **vẫn chiếm một ô** trong Warcraft III. Đã tính vào 7.

## Bao nhiêu chủ động, bao nhiêu bị động

Không chia đều cho cả ba. **Tỉ lệ này tự nó đã nói lên vai** — vai nào nhiều nút là
vai phải phản ứng liên tục.

| Hero | Chủ động | Bị động | Vì sao |
|---|---|---|---|
| Hart | 4 | 3 | Vừa giữ vị trí vừa bấm nút; bị động lo phần bền bỉ liên tục |
| Hvwd | 4 | 3 | Đòn đánh thường làm phần lớn việc; bị động khuếch đại nó |
| Hkal | **5** | 2 | Support về bản chất là phản ứng theo đồng đội — nhiều nút nhất |

Quá nhiều chủ động thì thành bấm loạn, không ai kịp nhìn trận đánh. Quá nhiều bị động
thì chơi hết một đợt mà chẳng làm gì. 4–5 chủ động là khoảng dễ chịu khi một người
điều khiển một hero.

> **Bị động không có nghĩa là nhàm.** Hào quang biến thành lý do để đứng gần nhau —
> đó là một quyết định vị trí, và vị trí là thứ map này xoay quanh.

## Dựa trên kỹ năng nào có sẵn

Dưới đây là **tên** kỹ năng gốc để tìm trong Object Editor, không phải ID — ID tôi
không xác minh được, còn tên thì tìm thẳng trong danh sách.

Cách làm: chuột phải kỹ năng gốc → Copy → Paste sang tab Custom → sửa số, icon,
Button Position, tên.

---

## Hart — Tanker

Không giết được gì đáng kể. Giá trị nằm ở chỗ **quái đánh Hart thay vì đánh nhà**.

| Ô | Kỹ năng | Loại | Dựa trên | Ghi chú |
|---|---|---|---|---|
| 1 | **Khiêu Khích** | Chủ động | **Taunt** *(Mountain Giant)* | Ép quái quanh đó đổi mục tiêu sang Hart. Kỹ năng quan trọng nhất của vai này |
| 2 | **Dậm Đất** | Chủ động | **War Stomp** *(Tauren Chieftain)* | Sát thương vùng + choáng. Giữ chân đám vừa bị kéo vào |
| 3 | **Tường Chắn** | Chủ động | **Avatar** *(Mountain King)* | Giáp, máu, kháng phép trong thời gian ngắn. Hồi chiêu dài |
| 4 | **Tử Thủ** | Chủ động | **Holy Light** *(Paladin)* | Tự hồi một cục lớn — Holy Light tự nhắm mình được |
| 5 | **Da Sắt** | Bị động | **Hardened Skin** *(Mountain Giant)* | Trừ thẳng một lượng sát thương mỗi đòn — rất mạnh trước nhiều quái yếu |
| 6 | **Hiệu Lệnh** | Bị động, aura | **Devotion Aura** *(Paladin)* | Cộng giáp cho đồng đội đứng gần |
| 7 | **Phản Đòn** | Bị động, aura | **Thorns Aura** *(Keeper of the Grove)* | Dội ngược sát thương. Càng nhiều quái đánh Hart càng lợi |

**Chỗ để hở:** Hart gần như không có sát thương. Một mình thì quái không bao giờ chết.

**Cặp đôi đáng chú ý:** Khiêu Khích kéo quái vào một đống, rồi Mưa Tên của Hvwd dội
lên đúng đống đó. Nên làm bán kính hai kỹ năng khớp nhau — đây là khoảnh khắc phối
hợp của map.

---

## Hvwd — Carry

Nguồn sát thương chính. Yếu khi bị chạm vào.

| Ô | Kỹ năng | Loại | Dựa trên | Ghi chú |
|---|---|---|---|---|
| 1 | **Mũi Xuyên** | Chủ động | **Shockwave** *(Tauren Chieftain)* | Sát thương cả một đường thẳng. Thưởng cho việc đứng đúng góc |
| 2 | **Liên Xạ** | Chủ động | **Berserk** *(Troll Headhunter)* | Tăng tốc đánh nhưng nhận thêm sát thương. Đúng chất Carry: lời to, rủi ro to |
| 3 | **Dấu Thợ Săn** | Chủ động | **Faerie Fire** *(Druid of the Talon)* | Giảm giáp mục tiêu. Có lợi cho **cả đội**, nên Carry có lý do nhắm con cả đội đang đánh |
| 4 | **Mưa Tên** | Chủ động | **Starfall** *(Priestess of the Moon)* | Đòn dọn đợt, hồi chiêu dài |
| 5 | **Đa Tiễn** | Bị động | **Cleaving Attack** *(Tauren)* | Mỗi đòn văng sang mục tiêu gần |
| 6 | **Tụ Khí** | Bị động | **Critical Strike** *(Blademaster)* | Chí mạng |
| 7 | **Tẩm Độc** | Bị động | **Envenomed Spears** *(Shadow Hunter)* | Độc gây sát thương theo thời gian |

**Chỗ để hở:** máu thấp, **không có kỹ năng thoát thân nào**. Quái chạm được là chết.
Đứng sai chỗ thì cả bộ kỹ năng vô nghĩa.

---

## Hkal — Support

Không tự giải quyết được gì, nhưng làm hai người kia mạnh gấp bội.

| Ô | Kỹ năng | Loại | Dựa trên | Ghi chú |
|---|---|---|---|---|
| 1 | **Trị Liệu** | Chủ động | **Holy Light** *(Paladin)* | Hồi máu đồng đội |
| 2 | **Băng Vực** | Chủ động | **Frost Nova** *(Lich)* | Sát thương vùng + làm chậm |
| 3 | **Khiên Pháp** | Chủ động | **Inner Fire** *(Troll Priest)* | Cộng giáp và sát thương cho đồng đội |
| 4 | **Thần Tốc** | Chủ động | **Bloodlust** *(Orc Shaman)* | Tăng tốc đánh và tốc chạy cho đồng đội |
| 5 | **Kích Pháp** | Chủ động | **Storm Bolt** *(Mountain King)* | Sát thương đơn mục tiêu + choáng |
| 6 | **Bền Bỉ** | Bị động, aura | **Endurance Aura** *(Shadow Hunter)* | Tốc chạy và tốc đánh cho cả đội |
| 7 | **Chỉ Huy** | Bị động, aura | **Command Aura** *(Blademaster)* | Cộng sát thương cho cả đội |

**Chỗ để hở:** sát thương gần như không có, và **mana là tài nguyên khan hiếm**.

> Tôi cố ý **không** cho Hkal hào quang hồi mana. Nếu đủ mana bấm mọi thứ mọi lúc thì
> vai Support biến thành bấm nút vô nghĩa — quyết định "tiêu mana vào lúc nào" chính
> là phần chơi của vai này. Chi phí nên đủ cao để mỗi đợt chỉ dùng được 3–4 kỹ năng lớn.

---

## Hai điều kỹ thuật phải biết

**Ability nhân bản từ hero ra ở cấp 0.** Storm Bolt, Holy Light, Starfall, Avatar,
Critical Strike, Devotion Aura, Thorns Aura — tất cả đều là *hero ability*. Gắn bằng
`UnitAddAbility` thì chúng ở cấp 0: nút hiện nhưng bấm không được.

Code đã tự gọi `SetUnitAbilityLevel(u, id, 1)` ngay sau khi gắn, ở cả
[07_heropick.lua](../../src/07_heropick.lua) lẫn bộ chọn kỹ năng. Không phải lo —
nhưng nếu tự viết chỗ gắn ability mới thì nhớ.

**Hai aura cùng loại không cộng dồn.** Warcraft III chỉ lấy cái mạnh hơn. Devotion
Aura của Hart và Command Aura của Hkal khác loại nên cộng bình thường, nhưng đừng cho
hai hero cùng một loại aura.

## Mỗi ability cần đặt gì trong Object Editor

| Trường | Giá trị | Vì sao |
|---|---|---|
| `Art - Button Position (X)(Y)` | Theo bảng 7 ô ở trên | Không đặt thì tất cả chồng lên nhau ở ô mặc định |
| `Stats - Levels` | 1 | Không có hệ nâng cấp từng cấp |
| `Art - Icon - Normal` | Icon riêng | Bảy icon giống nhau thì người chơi không phân biệt được |
| `Stats - Hotkey` | Phím riêng từng ô | |
| `Stats - Mana Cost` | Có cân nhắc | Nhất là Hkal — xem ghi chú mana ở trên |

Xong thì chép ID vào `CFG.HEROES[i].abilities` — code gắn tự động lúc tạo hero, và
báo đỏ ngay trong game kèm ID nếu gõ sai.

## Lời khuyên về thứ tự làm

**Đừng làm cả 21 rồi mới test.** Đó là 21 lần có thể sai ID, sai Button Position, sai
loại ability — phát hiện cùng lúc thì không biết cái nào hỏng vì cái gì.

1. **Một kỹ năng chủ động** — Dậm Đất của Hart (nhân bản War Stomp). Gắn vào
   `CFG.HEROES[1].abilities`, vào map bấm thử.
2. **Một kỹ năng bị động** — Da Sắt. Kiểm loại bị động có hiện đúng ô không.
3. **Một aura** — Hiệu Lệnh. Aura hành xử khác hai loại trên.

Ba bước đó tốn chừng nửa giờ và loại sạch rủi ro quy trình. 18 cái còn lại chỉ là lặp lại.

## Chưa quyết

- **Có cho chọn build không?** Hiện cả 7 đều có sẵn. Muốn chọn thì mỗi ô cần 2 ứng
  viên → 14 ability mỗi hero, gấp đôi khối lượng. Đề xuất: làm 7 cái cố định trước,
  chơi thử, rồi thêm nhánh vào 2–3 ô đáng chọn nhất. Giao diện thẻ chọn đã dựng sẵn.
- Con số cụ thể (sát thương, hồi chiêu, mana, bán kính) — chưa đặt cái nào. Cần có đợt
  quái rồi mới cân được.
- **Hồi sinh đồng đội** đã bỏ khỏi bộ kỹ năng. Nếu sau này muốn, nó nên là cơ chế
  riêng của map (nhà chính hồi sinh, hoặc mốc thời gian) chứ không chiếm một trong 7 ô.
