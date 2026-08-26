# [Addition to the study guides]

## CARD (COUNT) and $\gamma$ (GROUP BY) in Relational Algebra


## Finding a Good F


## Apply FDs to Find Keys


## Tableau Algorithm for Lossless Join

Thuật toán Tableau là một công cụ ma trận trực quan dùng để chứng minh bằng toán học xem một phép phân rã là Lossless hay Lossy. Thay vì phải đoán, chúng ta lập bảng để chạy thuật toán.

**Bước 1: Khởi tạo ma trận**
  * Cột của ma trận đại diện cho các thuộc tính của bảng gốc ($A_1, A_2, \dots, A_n$).
  * Dòng của ma trận đại diện cho các bảng nhỏ sau khi tách ($R_1, R_2, \dots, R_m$).

**Bước 2: Điền giá trị ban đầu**
  * Xét từng dòng $R_i$: Nếu bảng nhỏ này có chứa thuộc tính $A_j$, bạn điền ký hiệu $a_j$ (đại diện cho dữ liệu có thật và được bảo toàn).
  * Nếu bảng nhỏ này không chứa thuộc tính $A_j$, bạn điền ký hiệu $b_{ij}$ (đại diện cho dữ liệu bị khuyết).

**Bước 3: Áp dụng các Phụ thuộc hàm**
  * Thuật toán yêu cầu bạn dò từng phụ thuộc hàm (FD) $X \rightarrow Y$.
  * Nếu có hai hoặc nhiều dòng giống hệt nhau ở các cột thuộc tập $X$ (cùng mang ký hiệu chữ $a$), thì bạn bắt buộc phải ép các dòng đó giống hệt nhau ở cột $Y$.
  * Quy tắc ép: Nếu một dòng mang chữ $a$ và một dòng mang chữ $b$ ở cột $Y$, bạn ưu tiên biến chữ $b$ thành chữ $a$.

**Bước 4: Kết luận**
  * Bạn lặp lại Bước 3 liên tục cho đến khi ma trận không thể thay đổi được nữa.
  * **Trường hợp Lossless:** Sau khi biến đổi, bạn tìm thấy có **ít nhất một dòng chứa toàn ký hiệu chữ $a$** ($a_1, a_2, \dots, a_n$). Điều này chứng tỏ toàn bộ cấu trúc dữ liệu ban đầu có thể được khôi phục nguyên vẹn thông qua dòng liên kết đó. Nhìn vào slide 73, dòng `R3` đã biến thành toàn chữ $a$.
  * **Trường hợp Not Lossless:** Sau khi áp dụng các FD, không có bất kỳ sự thay đổi biến $b$ thành biến $a$ nào diễn ra (The matrix is not changed). Do đó, không có dòng nào đạt được trạng thái toàn chữ $a$. Điều này chứng minh thuật toán thất bại và việc join lại chắc chắn sẽ sinh ra spurious tuples.