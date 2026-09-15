# Thiết kế đợt quái

> **Trạng thái:** Nháp — chưa có dòng code nào (`05_wave.lua` còn rỗng)
> **Cập nhật:** 2026-09-15

## Ba con số cần sửa trước

Bạn nói 230 wave và 23 boss. Đếm lại danh sách cảnh giới bạn đưa:

```
20 cảnh giới  →  200 wave thường  +  20 boss  =  220 trận
```

Không phải 23. Nhưng con số đó chưa phải vấn đề. Hai con số dưới đây mới là.

### Một ván dài 2–4 tiếng

| Thời lượng mỗi wave | Cả ván |
|---|---|
| 30 giây | **2,2 giờ** |
| 45 giây | **3,0 giờ** |
| 60 giây | **3,8 giờ** |

Một map Warcraft III chơi chung thoải mái trong **30–60 phút**. Quá 90 phút là người
chơi rời trận giữa chừng, và map co-op mất một người là hỏng cả ván.

30 giây/wave đã là rất nhanh cho 51 con quái — mà vẫn 2,2 giờ.

### Sức mạnh phải tăng hàng nghìn lần

Qua 20 cảnh giới, nếu mỗi cảnh giới quái mạnh lên một hệ số cố định:

| Mỗi cảnh giới | Cuối game quái mạnh gấp |
|---|---|
| ×1,30 | 146 lần |
| ×1,45 | **1 164 lần** |
| ×1,60 | 7 555 lần |
| ×2,00 | 524 288 lần |

Sát thương người chơi **cũng phải tăng đúng chừng đó**, nếu không thì hoặc cảnh giới
sau vô nghĩa (quái quá yếu), hoặc bất khả thi (quái quá mạnh).

Tăng 1 000 lần sát thương qua 7 kỹ năng + trang bị + linh căn là làm được, nhưng phải
thiết kế ngay từ đầu chứ không vá sau. Đây là ràng buộc lớn nhất của cả map.

## Đề xuất: giữ 20 cảnh giới, cắt số tầng

Thang cảnh giới là thứ hay nhất trong ý tưởng của bạn — nó cho người chơi một cái
đích rõ ràng và một câu chuyện. **Giữ nguyên cả 20 cái.** Cắt phần khác.

| | Bạn đề xuất | Phương án A | Phương án B |
|---|---|---|---|
| Cảnh giới | 20 | 20 | 20 |
| Tầng mỗi cảnh giới | 10 | **3** | 5 |
| Wave thường | 200 | 60 | 100 |
| Boss | 20 | 20 | 20 |
| Tổng trận | 220 | **80** | 120 |
| Thời lượng @40s | 3 giờ | **~65 phút** | ~95 phút |
| Quái mạnh lên mỗi cảnh giới | ×1,45 | ×1,45 | ×1,45 |

**Khuyên chọn A.** 65 phút là độ dài một ván co-op tốt. Vẫn đi hết 20 cảnh giới, vẫn
đủ 20 lần đánh boss, chỉ là mỗi cảnh giới gọn hơn.

Chữ "viên mãn" vẫn dùng được: tầng 3 là viên mãn thay vì tầng 10.

> Nếu bạn vẫn muốn 10 tầng, cách duy nhất khả thi là **lưu tiến độ** — chơi nhiều
> phiên, mỗi phiên vài cảnh giới. Warcraft III làm được qua game cache hoặc mã `-save`.
> Nhưng đó là một hệ thống riêng, khá lớn, và nên làm **sau** khi map chơi được đã.

## Cấu trúc một wave

| | Số lượng | Sức mạnh |
|---|---|---|
| Lính thường | 50 | 1× |
| Tinh anh | 1 | 10× |
| **Tổng "đơn vị sức mạnh"** | | **60×** |

Boss ở wave riêng sau khi viên mãn, không có lính đi kèm — để trận boss là một khoảnh
khắc riêng chứ không lẫn vào đám đông.

**Boss nên mạnh bao nhiêu?** Đề xuất 60–80× lính thường cùng cảnh giới — tức bằng cả
một wave gộp lại. Đánh boss lâu bằng dọn một wave, nhưng chỉ một mục tiêu nên cảm
giác hoàn toàn khác.

### 50 con một wave có nặng máy không

51 con **cùng sống một lúc** thì Warcraft III chịu được thoải mái. Vấn đề chỉ đến khi
wave chồng nhau: wave sau ra khi wave trước chưa dọn xong.

Hai cách xử lý, chọn một:

| | Cách làm | Được | Mất |
|---|---|---|---|
| **Chờ dọn sạch** | Wave sau chỉ ra khi wave trước hết | Không bao giờ chồng, không lo máy | Người chơi rùa được, ván dài không kiểm soát |
| **Đồng hồ cứng** | Cứ N giây một wave | Áp lực thật, thời lượng đoán được | Chồng wave, có thể vỡ trận dây chuyền |

**Khuyên: đồng hồ cứng, kèm trần số quái.** Nếu trên map đã có quá `MAX_ALIVE` con thì
hoãn wave mới. Vừa giữ được áp lực vừa chặn được cảnh 300 con cùng lúc.

## Công thức sức mạnh quái

Gọi `r` = số cảnh giới (1…20), `t` = tầng (1…3), `p` = số người chơi.

```
mau  = MAU_GOC  × 1.45^(r-1) × (1 + 0.25×(t-1)) × (1 + 0.6×(p-1))
dame = DAME_GOC × 1.45^(r-1) × (1 + 0.25×(t-1)) × (1 + 0.15×(p-1))
giap = GIAP_GOC + 0.5×(r-1)
```

Ba điểm đáng giải thích:

**Máu tăng theo số người, sát thương thì gần như không.** Ba người có gấp ba sát
thương nên quái phải dày hơn. Nhưng mỗi người vẫn chỉ có **một** thân — quái đánh đau
gấp ba thì ba người chết nhanh như một người. Đây là sai lầm kinh điển của map co-op.

**Giáp tăng tuyến tính, không nhân.** Giáp trong Warcraft III đã là giảm % rồi; nhân
nó lên nữa thì tới cảnh giới 10 là miễn nhiễm sát thương.

**Tầng chỉ tăng 25%, cảnh giới tăng 45%.** Trong một cảnh giới người chơi thấy khó dần
nhưng vẫn xoay xở được; lên cảnh giới mới là một bậc thang thật sự.

## Nút thắt: đánh boss trước khi lên cảnh giới

Boss là **cửa kiểm tra**, không phải phần thưởng. Nó trả lời câu "người chơi đã đủ
mạnh để đi tiếp chưa".

Nên boss phải kiểm tra thứ mà lính thường không kiểm tra được:

| Boss ở cảnh giới | Kiểm tra điều gì |
|---|---|
| Đầu (1–5) | Có biết dùng kỹ năng không |
| Giữa (6–13) | Ba vai có phối hợp không — ví dụ boss đánh mạnh một mục tiêu, buộc Tanker phải kéo và Support phải cứu |
| Cuối (14–20) | Có tiêu Linh Khí đúng chỗ không |

**Thua boss thì sao?** Chưa quyết. Ba lựa chọn: đánh lại, đánh lại với quái yếu hơn,
hoặc thua luôn cả ván. Ván 65 phút mà thua ở boss 18 rồi mất trắng là rất cay — đề
xuất cho đánh lại, nhưng mất một phần Linh Khí.

## Phần thưởng mỗi wave

Xem [kinh-te.md](kinh-te.md). Tóm tắt: Linh Khí rơi ra tỉ lệ với cảnh giới, nên thu
nhập tự động theo kịp lạm phát sức mạnh mà không cần bảng riêng cho từng wave.

## Chưa quyết

- **Chọn phương án A hay B** — quyết định này chặn mọi con số khác.
- Quái đi đường nào tới nhà chính? Hiện lưới 25 block và sông chưa gắn vào đợt quái.
- Thua boss thì mất gì.
- Có loại quái đặc biệt không (bay, tàng hình, hồi máu) hay chỉ khác nhau về chỉ số.
- 20 cảnh giới cần bao nhiêu **loại** quái khác nhau về hình dáng. Dùng lại một mẫu
  suốt 20 cảnh giới thì đến cảnh giới 10 người chơi hết thấy tiến triển.
