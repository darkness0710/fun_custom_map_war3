# Hệ thống: <TÊN>

> **Trạng thái:** Nháp
> **Cập nhật:** YYYY-MM-DD
> **Code:** [xx_ten.lua](../../src/xx_ten.lua)
> **Khoá CFG:** `TIEN_TO_*`

## Nó là gì

Hai, ba câu. Hệ thống này tồn tại để làm gì, và người chơi cảm thấy gì khi chạm
vào nó. Nếu viết không nổi đoạn này thì hệ thống chưa chín — đừng code vội.

## Luật

Đánh số L1, L2… để chỗ khác trích dẫn được.

**L1. <Một câu mệnh lệnh.>**
Vì sao luật này tồn tại. Bỏ nó đi thì cái gì hỏng.

**L2. <Luật tiếp theo.>**
Nếu có khoảng giá trị hợp lệ thì ghi khoảng, đừng ghi con số — con số sống
trong `CFG`.

## Số liệu

Nhắc bằng **tên khoá**, không chép giá trị:

| Khoá | Ý nghĩa | Ràng buộc |
|---|---|---|
| `CFG.ABC` | | |

Đồng thời thêm dòng tương ứng vào
[03-du-lieu/bang-can-bang.md](../03-du-lieu/bang-can-bang.md).

## Ràng buộc kỹ thuật

Thứ đọc code không thấy nhưng sai là gãy:

- Native chỉ có từ patch nào.
- Thứ tự khởi tạo bắt buộc.
- Cái gì bị ghi đè lúc chạy.
- Chỗ nào là nguồn sự thật duy nhất, không được tính lại ở nơi khác.

## Chưa làm

Liệt kê thẳng. Danh sách này trung thực thì mới có ích — đừng giấu chỗ còn dở.

- …
