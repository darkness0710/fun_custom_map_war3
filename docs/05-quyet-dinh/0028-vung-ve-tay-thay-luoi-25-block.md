# 0028 — Vùng vẽ tay thay lưới 25 block sinh tự động

> **Trạng thái:** Đã chốt
> **Ngày:** 2026-09-19
> **Thay thế phần "lưới `Blk01`…`Blk25`" của** [0017](0017-ten-vung-la-vi-tri-vai-tro-o-cfg.md)

## Bối cảnh

[ADR 0017](0017-ten-vung-la-vi-tri-vai-tro-o-cfg.md) chốt rằng 25 block sẽ thành
vùng thật với tên mã hoá **vị trí** (`Blk01`…`Blk25`), sinh bằng `w3region.py gen`.

Quyết định đó **chưa bao giờ được thi hành**: `war3map.w3r` tới hôm nay vẫn chỉ
có bốn vùng vẽ tay. Và khi phó bản Tứ Thánh Thú cần chỗ đặt, cách làm thực tế đã
khác — vẽ thẳng trong World Editor, vì phó bản cần **địa hình riêng** chứ không
phải một ô vuông đều đặn cắt từ lưới.

Một ô `Blk` là hình vuông 4608 × 4608 khớp công thức `splitAxis`. Phòng boss thì
muốn hẹp, dài, có lối vào — hình dạng do người thiết kế quyết, không do phép chia.

## Quyết định

**Bỏ phần lưới sinh tự động. Vùng vẽ tay trong World Editor.**

Giữ nguyên **nguyên tắc cốt lõi của 0017**, vì nó vẫn đúng:

> Vai trò sống trong `CFG`, không nằm trong tên vùng.

`CFG.SIDE_QUESTS[i]` cầm tên vùng; đổi phó bản sang chỗ khác là sửa một dòng Lua,
không phải sửa file nhị phân rồi truy lại mọi tham chiếu `gg_rct_<Tên>`.

`w3region.py gen` **không xoá đi** — nó vẫn dùng được nếu sau này cần lưới đều.
Nó giữ nguyên mọi vùng tự vẽ, nên hai cách sống chung được.

## Hệ quả: tên vùng giờ là việc của người vẽ

Lưới sinh tự động có một ưu điểm đã mất: tên `Blk22` **nói lên vị trí**. Tên mặc
định của World Editor (`Region 004`, `Region 004 Copy`) không nói lên gì cả —
không vị trí, không vai trò.

Nên đổi tên ngay trong World Editor **trước khi** gắn vào `CFG`: đổi sau nghĩa là
sửa `war3map.w3r`, mở lại WE để xác nhận, và sửa mọi chỗ tham chiếu. Đúng ba việc
mà 0017 đã cảnh báo.

`CFG` nhận **danh sách ứng viên** chứ không phải một tên, nên trong lúc chuyển
tiếp có thể để cả tên cũ lẫn tên mới và map chạy được với bản nào cũng được.

## Phương án đã loại

**Ép phó bản vào ô `Blk` cho đúng 0017.** Loại vì nó bắt địa hình phục vụ một
phép chia — đúng cái sai mà 0017 đã loại ở chiều ngược lại (ép lưới phục vụ hệ
đợt quái).

**Sinh `Blk01`…`Blk25` rồi vẽ đè lên.** Loại vì 25 vùng không ai dùng chỉ làm
danh sách vùng trong World Editor rối thêm, mà rối thì chọn nhầm.
