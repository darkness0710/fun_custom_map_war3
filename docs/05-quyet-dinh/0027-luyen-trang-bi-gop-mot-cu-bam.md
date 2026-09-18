# 0027 — Luyện trang bị gộp vào một cú bấm

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-19
> **Nối tiếp** [0021](0021-trang-bi-la-mot-mon-tien-hoa.md) — thang 100 bậc giữ nguyên, chỉ đổi cách bấm

## Bối cảnh

`GEAR_ODDS = {1.00, 0.75, 0.50, 0.25, 0.15}` cho kỳ vọng
`1 + 1/0.75 + 1/0.50 + 1/0.25 + 1/0.15 = 15` lần thử để đi trọn **một** cảnh
giới của **một** món. Đếm ra cả ván:

```
20 canh gioi x 8 mon x 15 lan   = 2.400 lan bam
+ Tien Giai 19 lan x 8 mon      =   152 lan bam
                                  ------------
                                  2.552 lan bam
```

Thực tế không tới đó, vì đá mới là thứ chặn: Cơ Duyên thể 1 cho ~420 viên cả
ván, giá 1 viên một lần thử. Nhưng **420 lần bấm** thì vẫn là 420 lần bấm, và
người chơi báo mỏi tay trước khi báo thiếu đá.

## Quyết định

**Một cú bấm `LUYEN` = luyện liên tiếp tới Hoàn Hảo, hoặc tới khi hết đá.**

Nhãn nút ghi giá kỳ vọng: `LUYEN Hoan Hao  ~15`. Kết quả về **một** dòng tổng
kết — `Luyen 12 lan, ton 12 da -- gio la Pham Nhan Kiem - Hoan Hao.` — thay cho
12 dòng "luyện thất bại".

420 lần bấm còn **~34**.

## Ô tích — và vì sao bản đầu của nó bị bỏ

Bản gộp-luôn ship trước, không có ô tích. Câu hỏi đến ngay sau đó: **thế muốn
nâng lẻ thì sao?**

Đề xuất đầu tiên là một ô tick "all in": bật thì mỗi cú bấm tiêu tới khi hết đá.
Bỏ bản đó vì **nó là chế độ ẩn** — bật ở Kiếm, quên, lát sau bấm Nhẫn → bay cả
kho đá, không undo. Không phải lỗi hiếm; là lỗi *chắc chắn xảy ra* với một cái
tick sống lâu hơn sự chú ý của người chơi.

Bản được chốt sửa đúng chỗ đó: **ô tích đổi luôn nhãn của cả tám nút.**

| Ô tích | Nhãn tám nút | Một cú bấm |
|---|---|---|
| `[X] LUYEN GOP` | `LUYEN Hoan Hao  ~15` | quay tới Hoàn Hảo / hết đá |
| `[ ] LUYEN LE` | `LUYEN  1` | đúng một lần quay |

Chế độ không còn ẩn: nó **viết ra trên tám chỗ cùng lúc**, chứ không nằm trong
một cái tick bé tí. Nhìn bảng là biết cú bấm tiếp theo làm gì — mà đó mới là
điều kiện thật, chứ không phải "có tick hay không có tick".

Mặc định **bật**. Người chơi báo mỏi tay trước khi báo thiếu đá, nên gộp là
trạng thái thường; tick là để *tắt*.

### Ô tích không đồng bộ, và không được phép đồng bộ

Nó chỉ đổi hai thứ, cả hai đều cục bộ:

1. chữ trên nút ở máy này;
2. `tabItemAction` gửi `OP_GEAR_UP` hay `OP_GEAR_UP_ONE`.

Click frame **chỉ nổ ở máy người bấm**, nên `tabItemAction` vốn đã cục bộ. Bên
*nhận* op mới là chỗ đổi trạng thái thật, và nó kiểm lại đủ điều kiện. Một máy
gõ trạng thái tick cũng không làm gì được hơn ngoài việc tự luyện lẻ.

Vì thế nó **không** nằm trong `S.p`: một trường trong trạng thái đã đồng bộ mà
chỉ đúng ở một máy là cái bẫy cho người đọc sau.

Nó ngồi ở khe **nút** của ô Pet (`GEAR_TOGGLE_SLOT = {2,4}`) — Pet là ô duy nhất
không có nút nên chỗ đó đang trống, và cột giữa thì nằm giữa cả tám nút. Một cái
điều khiển tất cả thì phải ngồi giữa chúng, không nép ra rìa. Lưới vẫn 4 hàng,
khung bảng không cao thêm một chút nào.

## Vì sao gộp mà không mất gì

**Bấm lẻ không phải một quyết định.** Thất bại không phạt gì ngoài viên đá
(không tụt cấp, không vỡ món) và tỉ lệ thì cố định — nên nhìn một lần thất bại
**không cho người chơi thông tin nào để đổi ý**. 15 lần bấm chỉ là 15 lần bấm.

Chỗ duy nhất bấm lẻ hơn được là dừng đúng lúc còn 10 viên để Tiến Giải món khác.
Nhưng vòng gộp cũng dừng khi hết đá, và giá kỳ vọng ghi sẵn trên nút — nên đó là
một lựa chọn có đủ thông tin, không phải một cái bẫy.

## Vì sao dừng ở Hoàn Hảo

Vì đó là ranh giới **có sẵn** trong thiết kế, không phải một trần bịa ra: qua nó
phải Tiến Giải, một cửa 10 đá gác bởi Tu Vi ([ADR 0021](0021-trang-bi-la-mot-mon-tien-hoa.md)).
Tức là dừng đúng chỗ người chơi **buộc phải quyết định lại**.

Nó cũng làm rủi ro có trần. Mô phỏng 200.000 lần bấm từ Sơ Cấp:

| | Tốn |
|---|---|
| trung vị | 13 viên |
| 90% số lần | ≤ 24 viên |
| 99% số lần | ≤ 39 viên |
| tệ nhất đo được | 84 viên |

99% số lần bấm ăn ≤ 9% ngân sách cả ván. Trần là **cái cảnh giới**, không phải
cái kho đá — đó là khác biệt giữa phương án này và "all in".

## Hệ quả

- `refine(pid, i, once)` thành vòng lặp; `once` thoát sau một vòng. Bấm lẻ giữ
  nguyên câu báo cũ (`gear_failed` / `gear_became`) — đổi sang dòng tổng kết thì
  "Luyện 1 lần, tốn 1 đá" **không nói được rằng nó thất bại**. `GetRandomInt` vẫn nằm trong hàm chạy trên **mọi
  máy** từ kênh đồng bộ, và cả số đá lẫn cấp đều là trạng thái đã đồng bộ — nên
  vòng quay đúng bấy nhiêu lần, đúng thứ tự, ở mọi máy.
- `heroRecompute` + `panelRefresh` gọi **một** lần ở cuối, không mỗi vòng.
- Nháy ô: `fail` nếu không lên cấp nào, `big` nếu chạm Hoàn Hảo, `ok` nếu có lên
  mà chưa tới. Báo cả đội chỉ khi chạm Hoàn Hảo — trước đây báo ở hai cấp cuối,
  gộp rồi thì thành hai dòng liền nhau cho cùng một cú bấm.
- Có `GUARD = 1000` vòng. Đá hữu hạn nên vòng tự hết, nhưng một `GEAR_ODDS` gõ
  sai (`0` hoặc `nil`) sẽ biến nó thành cái bơm hút sạch kho đá mà không báo gì.
  Chặn cứng, và `API.trace` khi chạm — không nuốt.
- Nhãn nút phải gói trong **22 ký tự**: ở lưới, `note` chỉ hiện khi *không* có
  nút ([`1_panel.lua:387`](../../src/4_ui/1_panel.lua#L387)), nên chữ giải thích
  bị chính cái nút che. `LUYEN Hoan Hao  ~15` = 19 ký tự, vừa.
