# Đặc tả — DarknessCustomMap

Thư mục này định nghĩa **map phải làm gì**. `src/` định nghĩa **map làm điều đó
bằng cách nào**. Khi hai bên mâu thuẫn, đó là bug — hoặc ở code, hoặc ở tài liệu.

Bắt đầu đọc từ [00-tong-quan.md](00-tong-quan.md), rồi
[01-buoc-thuc-hien.md](01-buoc-thuc-hien.md) để biết đang ở bước nào.

## Ba quy ước, chỉ ba thôi

**1. Con số sống trong code, không sống ở đây.**
Toàn bộ số cấu hình nằm trong `CFG` tại [01_config.lua](../src/01_config.lua).
Tài liệu nhắc tới chúng bằng **tên khoá** (`CFG.RIVER_TILES`), không bao giờ chép
giá trị. Lý do: giá trị đổi mỗi lần cân bằng lại; nếu chép vào đây thì sau ba lần
sửa tài liệu sẽ nói dối, mà tài liệu nói dối còn tệ hơn không có tài liệu.

Tài liệu giữ thứ code không nói được: *tại sao* khoá đó tồn tại, nó phải tuân
luật gì, đổi nó thì cái gì gãy.

Ngoại lệ: số đo **đã kiểm chứng** của map (kích thước, toạ độ lưới) được ghi kèm
cách đo ra chúng, vì đó là kết quả quan sát chứ không phải tham số điều chỉnh.

**2. Mỗi tài liệu có trạng thái ở ngay đầu file.**

| Trạng thái | Nghĩa |
|---|---|
| `Nháp` | Đang nghĩ, chưa chốt, đừng code theo |
| `Đã chốt` | Luật đã định, chưa cài vào code |
| `Đã cài` | Code khớp với tài liệu — ghi rõ file nào cài |
| `Chưa quyết` | Đang chặn việc khác, cần quyết sớm |

**3. Quyết định kiến trúc thì ghi lại, không tranh luận lại.**
Mỗi lần chọn một hướng và bỏ một hướng khác, viết một file trong
[05-quyet-dinh/](05-quyet-dinh/), theo [mẫu](mau/quyet-dinh.md). Ghi cả phương án
đã loại và lý do loại — nửa năm sau chính bạn sẽ hỏi "sao hồi đó không làm cách
kia".

## Bố cục

```
docs/
  00-tong-quan.md        Map là gì, cấu hình đã chốt, câu hỏi còn treo
  01-buoc-thuc-hien.md   Đang ở bước nào, bước sau là gì
  02-he-thong/
     nha-chinh.md        Nhà chính + vùng địch
     chon-hero.md        Popup chọn hero
     thiet-ke-hero.md    Ba vai và 21 kỹ năng
     khoa-hero.md        Không lên cấp, không nâng kỹ năng
     ky-nang.md          Kỹ năng cố định & hệ nâng cấp bằng nút +
     kinh-te.md          Hai đồng tiền, ngân sách ×967, bảng giá bốn hệ
     bang-nhan-vat.md    Bảng phím E: Kỹ Năng / Trang Bị / Linh Căn / Pháp Khí
     dot-quai.md         220 đợt quái: cấu trúc, thành phần, nhịp, tu chính
     boss.md             20 boss cuối cảnh giới
  03-du-lieu/
     bang-can-bang.md    Khoá CFG -> ý nghĩa -> ràng buộc
     canh-gioi.md        Bảng 20 cảnh giới, chỉ số hoá stage 1..220
     duong-cong-suc-manh.md  Công thức chỉ số địch + hợp đồng người chơi
     curve.py            Sinh lại bảng tra trong file trên
  04-map/
     kich-thuoc.md       Số đo thật, đọc từ war3map.w3e
     luoi-25-o.md        Lưới 5x5 và các dòng sông
     toa-do-ve-song.md   Bảng tra khi cầm cọ trong World Editor
     lenh-debug.md       Lệnh debug và bốn công tắc chế độ phát triển
  05-quyet-dinh/         Nhật ký quyết định, đánh số tăng dần
     0001-src-nam-ngoai-map.md
     0002-goi-cheo-qua-bang-api.md
     0003-duong-dan-dung-chuoi-tho.md
     0004-song-ve-tay.md
     0005-hoan-thao-tac-quay-hang.md
     0006-fourcc-tra-hai-gia-tri.md
     0007-khong-dung-getunitgoldcost.md
     0008-ky-nang-hero-phai-sua-o-object-editor.md
     0009-so-luong-linh-co-dinh.md
     0010-giap-khong-nam-trong-duong-cong.md
     0011-nha-chinh-dem-mang.md        <- CHUA CHOT
     0012-mot-kenh-dong-bo-duy-nhat.md
  mau/                   Mẫu để copy khi viết tài liệu mới
     he-thong.md
     quyet-dinh.md
```

Mỗi hệ thống lối chơi một file trong `02-he-thong/`, theo [mẫu](mau/he-thong.md).

## Hai cái bẫy đã cắn, đừng để cắn lại

**Không gọi `FourCC` trần** — nó trả về *hai* giá trị và nở ra ở vị trí cuối của
bảng. Dùng `id()` trong [01_config.lua](../src/01_config.lua).
[ADR 0006](05-quyet-dinh/0006-fourcc-tra-hai-gia-tri.md)

**Không gọi `GetUnitGoldCost` / `GetUnitWoodCost`** — sập ngay cả với id hợp lệ.
`build.py` chặn cứng. [ADR 0007](05-quyet-dinh/0007-khong-dung-getunitgoldcost.md)

**Không sửa trạng thái engine bên trong sự kiện của engine** — quầy hàng, xoá
unit của sự kiện, huỷ trigger từ trong chính nó. Hoãn bằng `API.after(0.0, ...)`.
[ADR 0005](05-quyet-dinh/0005-hoan-thao-tac-quay-hang.md)

Gặp lỗi im lặng hoặc sập: bật `CFG.TRACE`, chạy, rồi đọc
`Documents\Warcraft III\CustomMapData\DarknessTrace.txt`. Dòng cuối là bước
cuối đã chạy xong. Đừng đoán.

## Thêm một hệ thống mới

1. Copy [mau/he-thong.md](mau/he-thong.md) vào `02-he-thong/<ten>.md`.
2. Viết luật trước, chưa cần biết code ra sao.
3. Đặt tên khoá CFG sẽ cần, thêm vào
   [03-du-lieu/bang-can-bang.md](03-du-lieu/bang-can-bang.md).
4. Cài vào `src/`, rồi quay lại đổi trạng thái thành `Đã cài` và điền tên file.

## Thư mục này có bị đóng gói vào map không

Không. World Editor chỉ đóng gói thứ nằm **trong** `test2.w3x/`. `docs/`, `src/`
và `build.py` đều nằm ngoài, nên chúng không phình map và không lộ ra bản `.w3x`
khi phát hành. Lý do đầy đủ ở
[ADR 0001](05-quyet-dinh/0001-src-nam-ngoai-map.md).
