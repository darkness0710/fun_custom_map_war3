# Thiết kế hero & bộ kỹ năng

> **Trạng thái:** Nháp — chưa có ability nào trong Object Editor
> **Cập nhật:** 2026-09-15
> **Liên quan:** [chon-hero.md](chon-hero.md), [ky-nang.md](ky-nang.md), [kinh-te.md](kinh-te.md)

## Một chỗ cần làm rõ

Bạn viết "mỗi hero tối đa 3 skills thôi", rồi ngay sau đó hỏi về skill 4-5-6-7. Tôi
hiểu là: **ba kỹ năng đầu do bạn chốt, bốn cái sau tôi đề xuất** — tổng vẫn 7, vừa
đúng 7 ô trống của command card.

Nếu ý bạn thật sự là mỗi hero chỉ có 3 kỹ năng thì nói, tôi cắt lại — nhưng lúc đó
nên nâng số cấp mỗi kỹ năng lên để vẫn còn thứ để tiêu Linh Khí.

## Ba vai

| Hero | ID | Vai | Bài toán người chơi phải giải |
|---|---|---|---|
| Hart | `H001` | Tanker | Quái đi tới đâu? Đứng chặn ở đâu để nó không chạm nhà? |
| Hvwd | `H002` | Carry | Giết con nào trước? Đứng đâu để bắn được mà không bị đánh? |
| Hkal | `H003` | Support | Cứu ai trước? Tiêu mana vào lúc nào? |

Ba vai chỉ có nghĩa khi **cả ba cùng cần nhau**. Mỗi bộ dưới đây đều có một chỗ **cố ý
để hở**, buộc phải nhờ vai khác lấp.

## Bố cục 7 ô

| | X=0 | X=1 | X=2 | X=3 |
|---|---|---|---|---|
| **Y=0** | Move | Stop | Hold | Attack |
| **Y=1** | Patrol | **KN 1** | **KN 2** | **KN 3** |
| **Y=2** | **KN 4** | **KN 5** | **KN 6** | **KN 7** |

Ba kỹ năng bạn chốt nằm ở hàng giữa — chỗ dễ với tay nhất. Kỹ năng bị động **vẫn chiếm
một ô**, đã tính vào 7.

## Tỉ lệ chủ động / bị động

| Hero | Chủ động | Bị động | Vì sao |
|---|---|---|---|
| Hart | 4 | 3 | Vừa giữ vị trí vừa bấm nút; bị động lo phần bền bỉ liên tục |
| Hvwd | 4 | 3 | Đòn đánh thường làm phần lớn việc; bị động khuếch đại nó |
| Hkal | **5** | 2 | Support phản ứng theo đồng đội — nhiều nút nhất |

---

## Hart — Tanker

| Ô | Kỹ năng | Loại | Dựa trên | Ghi chú |
|---|---|---|---|---|
| 1 | **Dậm Đất** | Chủ động, vùng | **War Stomp** *(Tauren Chieftain)* | Sát thương vùng + choáng quanh Hart |
| 2 | **Hộ Thể** | Chủ động, hồi máu | **Holy Light** *(Paladin)* | Tự hồi hoặc hồi cho đồng đội — Holy Light tự nhắm mình được |
| 3 | **Bất Hoại** | Chủ động | **Avatar** *(Mountain King)* | Giáp, máu, kháng phép trong thời gian ngắn |
| 4 | **Khiêu Khích** | Chủ động | **Taunt** *(Mountain Giant)* | Ép quái đổi mục tiêu sang Hart. **Kỹ năng định nghĩa cả vai này** |
| 5 | **Da Sắt** | Bị động | **Hardened Skin** *(Mountain Giant)* | Trừ thẳng một lượng sát thương mỗi đòn — rất mạnh trước 50 con quái yếu |
| 6 | **Hiệu Lệnh** | Bị động, **aura** | **Devotion Aura** *(Paladin)* | Cộng giáp cho đồng đội đứng gần |
| 7 | **Phản Đòn** | Bị động, **aura** | **Thorns Aura** *(Keeper of the Grove)* | Dội ngược sát thương. Càng đông quái đánh Hart càng lợi |

**Chỗ để hở:** gần như không có sát thương đơn mục tiêu. Một mình Hart thì boss không
bao giờ chết.

**Da Sắt là kỹ năng ăn khớp nhất với cấu trúc wave.** Mỗi wave có 50 con yếu — trừ
thẳng sát thương mỗi đòn có giá trị gấp bội so với giảm theo %.

---

## Hvwd — Carry

| Ô | Kỹ năng | Loại | Dựa trên | Ghi chú |
|---|---|---|---|---|
| 1 | **Mũi Xuyên** | Chủ động, vùng | **Shockwave** *(Tauren Chieftain)* | Sát thương cả một đường thẳng. Thưởng cho việc đứng đúng góc |
| 2 | **Hút Máu** | Chủ động, hồi máu | **Holy Light** *(Paladin)* | Xem ghi chú "dame heal" bên dưới |
| 3 | **Cuồng Xạ** | Chủ động | **Berserk** *(Troll Headhunter)* | Tăng tốc đánh nhưng **nhận thêm sát thương**. Lời to, rủi ro to |
| 4 | **Dấu Thợ Săn** | Chủ động | **Faerie Fire** *(Druid of the Talon)* | Giảm giáp mục tiêu. Có lợi cho **cả đội** |
| 5 | **Đa Tiễn** | Bị động | **Cleaving Attack** *(Tauren)* | Mỗi đòn văng sang mục tiêu gần — hợp với wave 50 con |
| 6 | **Tụ Khí** | Bị động | **Critical Strike** *(Blademaster)* | Chí mạng. Nguồn sát thương đơn mục tiêu chính khi đánh boss |
| 7 | **Thần Xạ** | Bị động, **aura** | **Trueshot Aura** *(Priestess of the Moon)* | Cộng sát thương cho đồng đội đánh xa |

**Chỗ để hở:** máu thấp, **không có kỹ năng thoát thân nào**. Quái chạm được là chết.

**Cuồng Xạ + Khiêu Khích là cặp đôi của map.** Hvwd bật Cuồng Xạ thì mong manh hơn
hẳn — đúng lúc đó Hart phải kéo hết quái về mình. Hai người chơi phải nói chuyện với
nhau.

---

## Hkal — Support

| Ô | Kỹ năng | Loại | Dựa trên | Ghi chú |
|---|---|---|---|---|
| 1 | **Băng Vực** | Chủ động, vùng | **Frost Nova** *(Lich)* | Sát thương vùng + làm chậm |
| 2 | **Trị Liệu** | Chủ động, hồi máu | **Holy Light** *(Paladin)* | Hồi máu đồng đội |
| 3 | **Hộ Pháp Thuẫn** | Chủ động | **Mana Shield** *(Naga Sea Witch)* | Chuyển sát thương sang mana |
| 4 | **Thần Tốc** | Chủ động | **Bloodlust** *(Orc Shaman)* | Tăng tốc đánh và tốc chạy cho đồng đội |
| 5 | **Khiên Pháp** | Chủ động | **Inner Fire** *(Troll Priest)* | Cộng giáp và sát thương cho đồng đội |
| 6 | **Bền Bỉ** | Bị động, **aura** | **Endurance Aura** *(Shadow Hunter)* | Tốc chạy và tốc đánh cho cả đội |
| 7 | **Tinh Thông** | Bị động, **aura** | **Brilliance Aura** *(Archmage)* | Hồi mana cho cả đội |

**Chỗ để hở:** sát thương gần như không có, và mana là thứ luôn thiếu.

> **Mana Shield và Brilliance Aura kéo nhau.** Mana Shield biến mana thành máu, nên
> mana vừa là tài nguyên thi triển vừa là thanh máu thứ hai. Brilliance Aura nới ra
> một phần — nhưng giữ chi phí kỹ năng **cao**, nếu không thì Hkal vừa bất tử vừa bấm
> mọi thứ mọi lúc, và vai Support mất hết quyết định.
>
> Tinh Thông cũng giúp Hart thi triển Hộ Thể thường xuyên hơn — đó là lý do nó tồn tại
> ở vai Support chứ không phải để nuôi chính Hkal.

---

## "Skill 2 phải là dame heal"

Chỗ này tôi chưa chắc hiểu đúng ý bạn, nên nêu hai cách hiểu:

| Cách hiểu | Làm thế nào | Công sức |
|---|---|---|
| **Hồi máu đơn thuần** | Nhân bản **Holy Light**, đổi số | Object Editor thuần |
| **Vừa gây sát thương vừa hồi** | Phải có code: bắt `EVENT_PLAYER_UNIT_SPELL_EFFECT`, gây sát thương vùng rồi hồi cho người thi triển một phần | Cần trigger riêng |

Bảng trên đang viết theo cách hiểu thứ nhất vì nó dựng được ngay. Nếu bạn muốn cách
thứ hai — hút máu thật — nói tôi biết, đó là kỹ năng đầu tiên cần code và tôi làm luôn.

Riêng với Hvwd, cách thứ hai hợp vai hơn nhiều: Carry hút máu từ sát thương mình gây ra
là một vòng lặp tự thưởng.

---

## Điều đã thay đổi so với bản trước

**Mọi ability giờ phải có 10 cấp**, không phải 1 cấp nữa.

[bang-nhan-vat.md](bang-nhan-vat.md) có bảng nâng kỹ năng bằng Linh Khí, tức
`Stats - Levels = 10` và phải điền số liệu cho từng cấp trong Object Editor.

Đây là khối việc lớn hơn hẳn: **21 ability × 10 cấp = 210 dòng số liệu**. Lý do rất
mạnh để làm 3 kỹ năng trước rồi mới nhân rộng.

Sức mạnh mỗi cấp: **+12% cộng dồn nhân**, cấp 10 ≈ 2,77× cấp 1. Con số này lấy từ
ngân sách trong [kinh-te.md](kinh-te.md), không phải chọn bừa.

## Mỗi ability cần đặt gì trong Object Editor

| Trường | Giá trị | Vì sao |
|---|---|---|
| `Art - Button Position (X)(Y)` | Theo bảng 7 ô ở trên | Không đặt thì tất cả chồng lên nhau |
| `Stats - Levels` | **10** | Có hệ nâng cấp bằng Linh Khí |
| Số liệu từng cấp | +12% mỗi cấp | Xem kinh-te.md |
| `Art - Icon - Normal` | Icon riêng | Bảy icon giống nhau thì không phân biệt được |
| `Stats - Hotkey` | Phím riêng từng ô | |
| `Stats - Mana Cost` | Có cân nhắc | Nhất là Hkal |

## Hai điều kỹ thuật phải biết

**Ability nhân bản từ hero ra ở cấp 0.** Gắn bằng `UnitAddAbility` thì nút hiện nhưng
bấm không được. Code đã tự gọi `SetUnitAbilityLevel(u, id, 1)` ngay sau khi gắn.

**Hai aura cùng loại không cộng dồn** — Warcraft III chỉ lấy cái mạnh hơn. Ba hero
trên dùng năm loại aura khác nhau nên không đụng nhau.

## Thứ tự làm

1. **Một kỹ năng chủ động** — Dậm Đất của Hart. Chỉ làm **1 cấp** trước, chỉ để kiểm
   cả chuỗi: Object Editor → code gắn → hiện đúng ô → bấm có tác dụng.
2. **Một bị động** — Da Sắt.
3. **Một aura** — Hiệu Lệnh.
4. Ba loại chạy đúng rồi mới **thêm 10 cấp** cho một cái, kiểm bảng nâng cấp.
5. Xong bước 4 thì 20 ability còn lại chỉ là lặp lại.

Đừng dựng 21 ability × 10 cấp rồi mới bật game lên xem.
