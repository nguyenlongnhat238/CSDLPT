--Cau 1 Viết 2 store procedure tên: TaoPM_Ngang_PB để tạo và lấy dữ liệu cho các phân mảnh
-- của bảng PhongBan; và Stored procedure TaoPM_Ngang_NhanVien để tạo và lấy dữ liệu cho các phân
-- mảnh của bảng NhanViên, biết:
-- • Bảng PhongBan được phân mảnh ngang chính dựa vào cột ChiNhanh. Biết cột ChiNhanh luôn
-- có dữ liệu (NOT NULL) và chỉ có một trong hai giá trị là “Sài gòn” và “Hà nội”.
-- • Bảng NhanVien được phân mảnh ngang dẫn xuất theo các phân mảnh của bảng PhongBan.
use QLNhanVien
Go
INSERT INTO
    PhongBan (MaPB, TenPB, ChiNhanh)
VALUES
    (N'P024', N 'Phòng Tuyệt vời HN', N'Hà nội')
GO
    CREATE PROC TaoPM_Ngang_PB AS BEGIN
SELECT
    * INTO PhongBanSG
FROM
    PhongBan
WHERE
    ChiNhanh = N'Sài gòn'
SELECT
    * INTO PhongBanHN
FROM
    PhongBan
WHERE
    ChiNhanh = N 'Hà Nội'
END
Go
    EXEC TaoPM_Ngang_PB
SELECT
    *
FROM
    PhongBanHN;

SELECT
    *
FROM
    PhongBanSG;

GO
    CREATE PROC TaoPM_Ngang_NhanVien AS BEGIN
SELECT
    * INTO NhanVienSG
FROM
    NhanVien
WHERE
    MaPB in (
        SELECT
            MaPB
        FROM
            PhongBanSG
    )
SELECT
    * INTO NhanVienHN
FROM
    NhanVien
WHERE
    MaPB in (
        SELECT
            MaPB
        FROM
            PhongBanHN
    )
END
Go
    EXEC TaoPM_Ngang_NhanVien
Go
SELECT
    *
FROM
    NhanVienHN
GO
SELECT
    *
FROM
    NhanVienSG
GO
    --2.  Tạo stored procedure tên ThemPB để thêm 1 hàng dữ liệu vào các phân mảnh ngang của bảng
    -- PhongBan. Các tham số vào là @MaPB, @TenPB, và @ChiNhanh.
    -- Yêu cầu: phải có báo thành công khi thêm dữ liệu thành công, hay báo lỗi chi tiết (print ra màn hình) và
    -- không thêm dữ liệu khi gặp các trường hợp ngoại lệ sau:
    -- - Có @MaPB là NULL, hay @TenPB là NULL, hay @ChiNhanh là NULL
    -- - @ChiNhanh chứa giá trị khác “Sài gòn” và “Hà nội”
    -- - @MaPB đã có (nếu thêm sẽ bị trùng @MaLop)
    -- Sinh viên phải tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất cả
    -- các trường hợp
    CREATE PROC ThemPB (
        @MaPB nvarchar(50),
        @TenPB nvarchar(50),
        @ChiNhanh nvarchar(50)
    ) AS BEGIN -- Check NULL
    IF (
        @MaPB IS NULL
        OR @TenPB IS NULL
        OR @ChiNhanh IS NULL
    ) BEGIN RAISERROR(N'Các dữ liệu không được để trống', 16, 1) RETURN;

END -- Check chi nhánh
IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội')) BEGIN RAISERROR(
    N'Chi nhánh phải là "Sài gòn" hoặc "Hà nội"',
    16,
    1
) RETURN;

END -- Check MaPB đã tồn tại ở PB SG chưa
IF EXISTS (
    SELECT
        1
    FROM
        PhongBanSG
    WHERE
        MaPB = @MaPB
) BEGIN RAISERROR(N'MaPB đã tồn tại', 16, 1) RETURN;

END -- Check MaPB đã tồn tại ở PB HN chưa
IF EXISTS (
    SELECT
        1
    FROM
        PhongBanHN
    WHERE
        MaPB = @MaPB
) BEGIN RAISERROR(N'MaPB đã tồn tại', 16, 1) RETURN;

END -- Nếu không có vấn đề, thêm dữ liệu
IF (@ChiNhanh = N'Sài gòn') BEGIN
INSERT INTO
    PhongBanSG (MaPB, TenPB, ChiNhanh)
VALUES
    (@MaPB, @TenPB, @ChiNhanh)
END
ELSE IF (@ChiNhanh = N'Hà nội') BEGIN
INSERT INTO
    PhongBanHN (MaPB, TenPB, ChiNhanh)
VALUES
    (@MaPB, @TenPB, @ChiNhanh)
END PRINT N'Thêm dữ liệu thành công'
END EXEC ThemPB N'P024',
N'Phòng Tuyệt vời',
N'Sài gòn';

GO
    EXEC ThemPB N'P025',
    N'Phòng Tuyệt vời',
    N'Hà nội';

GO
SELECT
    *
FROM
    PhongBan -- Câu 3: Tạo stored procedure tên SuaPB để sửa dữ liệu của các phân mảnh ngang của bảng PhongBan
    -- (update) tại 2 cột TenPB và ChiNhanh (không sửa cột MaPB). Các tham số vào là @MaPB, @TenPB, và
    -- @ChiNhanh, trong đó @MaPB để xác định hàng dữ liệu cần sửa.
    -- Yêu cầu: phải có báo chi tiết việc đã thực hiện khi sửa dữ liệu thành công, hay báo lỗi chi tiết (print ra màn
    -- hình) và không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau:
    -- - Có @MaPB là NULL, hay @TenPB là NULL, hay @ChiNhanh là NULL
    -- - Không tìm thấy @MaPB để sửa dữ liệu
    -- - @ChiNhanh chứa giá trị khác “Sài gòn” và “Hà nội”
    -- Sinh viên tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất cả các
    -- trường hợp.
    -- Chú ý: nếu sửa phòng ban mà có dời dữ liệu lớp sang phân mảnh khác thì cũng phải dời nhân viên của
    -- phòng ban đó sang phân mảnh khác tương ứng. Khi dời dữ liệu thì phải thông báo dời như thế nào trong
    -- thông báo sửa dữ liệu thành công
    CREATE PROC SuaPB (
        @MaPB nvarchar(50),
        @TenPB nvarchar(50),
        @ChiNhanh nvarchar(50)
    ) AS BEGIN -- CHECK NULL
    IF (
        @MaPB IS NULL
        OR @TenPB IS NULL
        OR @ChiNhanh IS NULL
    ) BEGIN PRINT N'Các dữ liệu không được để trống' RETURN;

END -- CHECK ChiNhanh
IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội')) BEGIN PRINT N'Chi nhánh phải là "Sài gòn" hoặc "Hà nội"' RETURN;

END -- CHECK @MaPB exits
IF NOT EXISTS (
    SELECT
        *
    FROM
        PhongBanSG
    WHERE
        MaPB = @MaPB
)
AND NOT EXISTS (
    SELECT
        *
    FROM
        PhongBanHN
    WHERE
        MaPB = @MaPB
) BEGIN PRINT N'Không tìm thấy MaPB để sửa dữ liệu' RETURN;

END DECLARE @OldChiNhanh nvarchar(50)
SELECT
    @OldChiNhanh = ChiNhanh
FROM
    PhongBanSG
WHERE
    MaPB = @MaPB IF (@OldChiNhanh IS NULL)
SELECT
    @OldChiNhanh = ChiNhanh
FROM
    PhongBanHN
WHERE
    MaPB = @MaPB -- Nếu chi nhánh cũ khác chi nhánh mới thì dời records đi
    IF @OldChiNhanh != @ChiNhanh BEGIN IF @OldChiNhanh = N'Sài gòn'
INSERT INTO
    PhongBanHN
SELECT
    *
FROM
    PhongBanSG
WHERE
    MaPB = @MaPB
    ELSE
INSERT INTO
    PhongBanSG
SELECT
    *
FROM
    PhongBanHN
WHERE
    MaPB = @MaPB PRINT N'Dữ liệu phòng ban đã được dời sang phân mảnh khác'
END -- Sửa dữ liệu trong phân mảnh cần sửa
IF @ChiNhanh = N'Sài gòn'
UPDATE
    PhongBanSG
SET
    TenPB = @TenPB,
    ChiNhanh = @ChiNhanh
WHERE
    MaPB = @MaPB
    ELSE
UPDATE
    PhongBanHN
SET
    TenPB = @TenPB,
    ChiNhanh = @ChiNhanh
WHERE
    MaPB = @MaPB PRINT N'Sửa dữ liệu thành công'
END DROP PROC SuaPB EXEC SuaPB N'P024',
N 'Phòng Tuyệt vời HN',
N'Hà nội';

GO
    EXEC SuaPB N'P025',
    N'Phòng Tuyệt vời SG',
    N'Sài gòn';

GO
    EXEC SuaPB N'P025',
    N'Phòng Tuyệt vời SG 1',
    N'Sài gòn';

GO
SELECT
    *
FROM
    PhongBanSG
GO
SELECT
    *
FROM
    PhongBanHN
GO
    -- Câu 4: Hãy viết Stored procedure tên: TaoPM_Doc_PB để tạo và lấy dữ liệu cho 2 phân mảnh dọc từ
    -- bảng PhongBan, biết hai phân mảnh dọc là:
    -- PhongBan_Doc1(MaPB, TenPB)PhongBan_Doc2(MaPB, ChiNhanh)
    CREATE PROC TaoPM_Doc_PB AS BEGIN
SELECT
    MaPB,
    TenPB INTO PhongBan_Doc1
FROM
    PhongBan
SELECT
    MaPB,
    ChiNhanh INTO PhongBan_Doc2
FROM
    PhongBan PRINT N 'TẠO THÀNH CÔNG!!!!!'
END
GO
    EXEC TaoPM_Doc_PB
GO
SELECT
    *
FROM
    PhongBan_Doc1
SELECT
    *
FROM
    PhongBan_Doc2 -- Câu 5: Hãy viết Stored procedure tên: XemPB_Doc để lập danh sách tất cả phòng ban từ 2 phân mảnh
    -- dọc của bảng PhongBan, danh sách lớp gồm 3 cột: MaPB, TenPB, ChiNhanh.
    CREATE PROC XemPB_Doc AS BEGIN
SELECT
    a.MaPB,
    a.TenPB,
    b.ChiNhanh
FROM
    PhongBan_Doc1 as a,
    PhongBan_Doc2 as b
WHERE
    a.MaPB = b.MaPB
END
GO
    EXEC XemPB_Doc
GO
    -- Câu 6: Tạo stored procedure tên SuaPB_Doc để sửa các phân mảnh dọc của bảng PhongBan (update)
    -- tại 2 cột TenPB và ChiNhanh (không sửa cột MaPB). Các tham số vào là @MaPB, @TenPB, và
    -- @ChiNhanh, trong đó @MaPB để xác định hàng dữ liệu cần sửa.
    -- Yêu cầu: phải có báo chi tiết việc đã thực hiện khi sửa dữ liệu thành công, hay báo lỗi chi tiết (print ra màn
    -- hình) và không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau:
    -- - Có @MaPB là NULL, hay @TenPB là NULL, hay @ChiNhanh là NULL
    -- - Không tìm thấy @ MaPB để sửa dữ liệu
    -- - Có @ChiNhanh chứa giá trị khác “Sài gòn” và “Hà nội”
    -- Sinh viên phải tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất cả
    -- các trường hợp.
    CREATE PROC SuaPB_Doc @MaPB nvarchar(50),
    @TenPB nvarchar(50),
    @ChiNhanh nvarchar(50) AS BEGIN -- check NULL
    IF (
        @MaPB IS NULL
        OR @TenPB IS NULL
        OR @ChiNhanh IS NULL
    ) BEGIN PRINT N'Các dữ liệu không được để trống' RETURN;

END -- check ChiNhanh
IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội')) BEGIN PRINT N'Chi nhánh phải là "Sài gòn" hoặc "Hà nội"' RETURN;

END -- check @MaPB exists
IF NOT EXISTS (
    SELECT
        1
    FROM
        PhongBan_Doc1
    WHERE
        MaPB = @MaPB
)
OR NOT EXISTS (
    SELECT
        1
    FROM
        PhongBan_Doc2
    WHERE
        MaPB = @MaPB
) BEGIN PRINT N'Không tìm thấy MaPB để sửa dữ liệu' RETURN;

END -- Sửa PhongBan_Doc1
UPDATE
    PhongBan_Doc1
SET
    TenPB = @TenPB
WHERE
    MaPB = @MaPB -- Sửa PhongBan_Doc2
UPDATE
    PhongBan_Doc2
SET
    ChiNhanh = @ChiNhanh
WHERE
    MaPB = @MaPB PRINT N'Sửa dữ liệu thành công'
END EXEC SuaPB_Doc N'P024',
N 'Phòng Tuyệt vời HN',
N'Hà nội';

GO
    EXEC XemPB_Doc