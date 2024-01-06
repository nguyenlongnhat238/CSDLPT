USE QLTruongDH
GO

-- Cho CSDL Quản lý trường đại học (QLTruongDH) có 2 bảng như sau:
-- Lop(MaLop, TenLop, NganhDaoTao, #MaKhoa)
-- Khoa(MaKhoa, TenKhoa, CoSo)
-- Khóa chính: là MaKhoa và MaLop đã được gạch dưới
-- Khóa ngoại: Lop.MaKhoa là khóa ngoại tham khảo đến Khoa.MaKhoa
-- Câu 1: Hãy viết Stored procedure tên: TaoPM_Doc_Khoa để tạo và lấy dữ liệu cho 2 phân mảnh dọc từ
-- bảng Khoa, biết thiết kế của hai phân mảnh dọc là:
-- Khoa_Doc1(MaKhoa, TenKhoa)
-- Khoa_Doc2(MaKhoa, CoSo)

CREATE PROC TaoPM_Doc_Khoa
AS
BEGIN
    SELECT MaKhoa, TenKhoa INTO Khoa_Doc1 FROM Khoa
    SELECT MaKhoa, CoSo INTO Khoa_Doc2 FROM Khoa
    PRINT N'TẠO THÀNH CÔNG!!!!!'
END
GO

EXEC TaoPM_Doc_Khoa
GO

SELECT * FROM Khoa_Doc1
SELECT * FROM Khoa_Doc2

-- Câu 2: Hãy viết Stored procedure tên: XemKhoa_Doc có một tham số vào là @CoSo. Procedure này sẽ
-- lập danh sách 3 cột là MaKhoa, TenKhoa, CoSo từ 2 phân mảnh dọc của bảng Khoa.
-- Yêu cầu:
-- - Nếu @CoSo là NULL: lập danh sách tất cả các khoa
-- - Có @CoSo không hợp lệ: báo lỗi
-- - Không tìm thấy giá trị @CoSo: báo lỗi
-- Sinh viên phải tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất
-- cả các trường hợp.

CREATE PROC XemKhoa_Doc
    @CoSo nvarchar(50)
AS
BEGIN
    IF @CoSo IS NULL
    BEGIN
        print N'@CoSo không hợp lệ'
        RETURN;
    END

    IF @CoSo NOT IN (SELECT CoSo FROM Khoa_Doc2) AND @CoSo NOT IN (SELECT CoSo FROM Khoa_Doc2)
    BEGIN
        print N'Không tìm thấy giá trị @CoSo'
        RETURN;
    END

    SELECT a.MaKhoa, a.TenKhoa, b.CoSo
    FROM Khoa_Doc1 as a, Khoa_Doc2 as b
    WHERE a.MaKhoa = b.MaKhoa AND b.CoSo = @CoSo

END
GO

-- Lỗi @CoSo không hợp lệ
EXEC XemKhoa_Doc @CoSo = NULL
GO

-- Lỗi Không tìm thấy giá trị @CoSo
EXEC XemKhoa_Doc @CoSo = N'Đà Nẵng'
GO

-- Đúng
EXEC XemKhoa_Doc @CoSo = N'Sài Gòn'
GO
-- Đúng
EXEC XemKhoa_Doc @CoSo = N'Bình Dương'
GO

-- Câu 3: Tạo stored procedure tên ThemKhoa_Doc để thêm dữ liệu trong hai phân mảnh dọc của bảng
-- Khoa. Các tham số vào là @MaKhoa, @TenKhoa, và @CoSo
-- Yêu cầu: phải có thông báo chi tiết (print ra màn hình) việc đã thực hiện khi sửa dữ liệu thành công, hay
-- báo lỗi chi tiết và không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau:
-- - Có @MaKhoa là NULL, hay @TenKhoa là NULL, hay @CoSo là NULL
-- - Có @CoSo chứa giá trị khác “Sài Gòn” và “Bình Dương”
-- - Bị trùng mã khoa nên không thêm dữ liệu được
-- Sinh viên phải tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất
-- cả các trường hợp.

CREATE PROC ThemKhoa_Doc
    @MaKhoa nvarchar(50),
    @TenKhoa nvarchar(50),
    @CoSo nvarchar(50)
AS
BEGIN
    IF (
        @MaKhoa IS NULL
        OR @TenKhoa IS NULL
        OR @CoSo IS NULL
    )
    BEGIN
        PRINT N'Các dữ liệu không được để trống'
        RETURN;
    END

    IF (@CoSo NOT IN (N'Sài Gòn', N'Bình Dương'))
    BEGIN
        PRINT N'Chi nhánh phải là "Sài gòn" hoặc "Bình Dương"'
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Khoa_Doc1 WHERE MaKhoa = @MaKhoa)
    BEGIN
        PRINT N'Mã khoa đã tồn tại'
        RETURN;
    END

    INSERT INTO Khoa_Doc1 VALUES (@MaKhoa, @TenKhoa)
    INSERT INTO Khoa_Doc2 VALUES (@MaKhoa, @CoSo)
    PRINT N'Thêm thành công'
END
GO

-- Lỗi Các dữ liệu không được để trống
EXEC ThemKhoa_Doc @MaKhoa = NULL, @TenKhoa = NULL, @CoSo = NULL
GO

-- Lỗi Chi nhánh phải là "Sài gòn" hoặc "Bình Dương"
EXEC ThemKhoa_Doc @MaKhoa = N'K1', @TenKhoa = N'Khoa 1', @CoSo = N'Đà Nẵng'
GO

-- Lỗi Mã khoa đã tồn tại
EXEC ThemKhoa_Doc @MaKhoa = N'CNSH', @TenKhoa = N'Khoa 1', @CoSo = N'Sài Gòn'
GO

-- Đúng
EXEC ThemKhoa_Doc @MaKhoa = N'K2', @TenKhoa = N'Khoa 2', @CoSo = N'Bình Dương'
GO


-- Câu 4: Hãy viết 2 Stored procedure tên: TaoPM_Ngang_Khoa để tạo và lấy dữ liệu cho các phân mảnh
-- của bảng Khoa; và Stored procedure TaoPM_Ngang_Lop để tạo và lấy dữ liệu cho các phân mảnh của
-- bảng Lop, biết:
-- • Bảng Khoa được phân mảnh ngang chính dựa vào cột CoSo (cơ sở). Biết cột CoSo luôn có dữ
-- liệu (NOT NULL) và chỉ có một trong hai giá trị là “Sài Gòn” và “Bình Dương”.
-- • Bảng Lop được phân mảnh ngang dẫn xuất theo các phân mảnh của bảng Khoa

CREATE PROC TaoPM_Ngang_Khoa
AS
BEGIN
    SELECT * INTO Khoa_SG FROM Khoa WHERE CoSo = N'Sài Gòn'
    SELECT * INTO Khoa_BD FROM Khoa WHERE CoSo = N'Bình Dương'
    PRINT N'Tạo thành công'
END
GO

CREATE PROC TaoPM_Ngang_Lop
AS
BEGIN
    SELECT * INTO Lop_SG FROM Lop WHERE MaKhoa IN (SELECT MaKhoa FROM Khoa_SG)
    SELECT * INTO Lop_BD FROM Lop WHERE MaKhoa IN (SELECT MaKhoa FROM Khoa_BD)
    PRINT N'Tạo thành công'
END
GO

EXEC TaoPM_Ngang_Khoa
EXEC TaoPM_Ngang_Lop

SELECT * FROM Khoa_SG
SELECT * FROM Khoa_BD
SELECT * FROM Lop_SG
SELECT * FROM Lop_BD

-- Câu 5: Tạo stored procedure tên XemKhoa_Ngang có một tham số vào là @CoSo. Procedure này sẽ lập
-- danh sách 3 cột là MaKhoa, TenKhoa, CoSo từ 2 phân mảnh ngang chính của bảng Khoa.
-- Yêu cầu:
-- - Nếu @CoSo là NULL: lập danh sách tất cả các khoa
-- - Có @CoSo không hợp lệ: báo lỗi
-- - Không tìm thấy giá trị @CoSo: báo lỗi
-- Sinh viên phải tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất
-- cả các trường hợp.

CREATE PROC XemKhoa_Ngang
    @CoSo nvarchar(50)
AS
BEGIN
    IF @CoSo IS NULL
    BEGIN
        print N'@CoSo không hợp lệ'
        RETURN;
    END

    IF @CoSo NOT IN (SELECT CoSo FROM Khoa_SG) AND @CoSo NOT IN (SELECT CoSo FROM Khoa_BD)
    BEGIN
        print N'Không tìm thấy giá trị @CoSo'
        RETURN;
    END

    SELECT * FROM Khoa_SG WHERE CoSo = @CoSo
    UNION
    SELECT * FROM Khoa_BD WHERE CoSo = @CoSo
END

-- Lỗi @CoSo không hợp lệ
EXEC XemKhoa_Ngang @CoSo = NULL
GO

-- Lỗi Không tìm thấy giá trị @CoSo
EXEC XemKhoa_Ngang @CoSo = N'Đà Nẵng'
GO

-- Đúng
EXEC XemKhoa_Ngang @CoSo = N'Sài Gòn'
GO
-- Đúng
EXEC XemKhoa_Ngang @CoSo = N'Bình Dương'
GO

-- Câu 6: Tạo stored procedure tên SuaKhoa_Ngang để sửa dữ liệu (update) của các phân mảnh ngang của
-- bảng Khoa tại 2 cột TenKhoa và CoSo (không sửa cột MaKhoa). Các tham số vào là @MaKhoa,
-- @TenKhoa, và @CoSo, trong đó @MaKhoa để xác định hàng dữ liệu cần sửa.
-- Yêu cầu: phải có báo chi tiết (print ra màn hình) việc đã thực hiện khi sửa dữ liệu thành công, hay báo lỗi
-- chi tiết và không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau:
-- - Có @MaKhoa là NULL, hay @TenKhoa là NULL, hay @CoSo là NULL
-- - Không tìm thấy @MaKhoa để sửa dữ liệu
-- - @CoSo chứa giá trị khác “Sài Gòn” và “Bình Dương”

CREATE PROC SuaKhoa_Ngang
    @MaKhoa nvarchar(50),
    @TenKhoa nvarchar(50),
    @CoSo nvarchar(50)
AS
BEGIN
    IF (
        @MaKhoa IS NULL
        OR @TenKhoa IS NULL
        OR @CoSo IS NULL
    )
    BEGIN
        PRINT N'Các dữ liệu không được để trống'
        RETURN;
    END

    IF (@CoSo NOT IN (N'Sài Gòn', N'Bình Dương'))
    BEGIN
        PRINT N'Chi nhánh phải là "Sài gòn" hoặc "Bình Dương"'
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Khoa_SG WHERE MaKhoa = @MaKhoa)
    AND NOT EXISTS (SELECT 1 FROM Khoa_BD WHERE MaKhoa = @MaKhoa)
    BEGIN
        PRINT N'Không tìm thấy @MaKhoa để sửa dữ liệu'
        RETURN;
    END

    DECLARE @CoSoCu nvarchar(50)
    SELECT @CoSoCu = CoSo FROM Khoa_SG WHERE MaKhoa = @MaKhoa
    IF @CoSoCu IS NULL
    BEGIN
        SELECT @CoSoCu = CoSo FROM Khoa_BD WHERE MaKhoa = @MaKhoa
    END

    IF @CoSoCu != @CoSo
    BEGIN
        PRINT N'Sửa @CoSo có chuyển chi nhánh'
        IF @CoSoCu = N'Sài Gòn'
        BEGIN
            INSERT INTO Khoa_BD VALUES (@MaKhoa, @TenKhoa, @CoSo) 
            DELETE FROM Khoa_SG WHERE MaKhoa = @MaKhoa
            PRINT N'Đã chuyển cơ sở của khoa sang Bình Dương'
            
            INSERT INTO Lop_BD SELECT * FROM Lop_SG WHERE MaKhoa = @MaKhoa
            DELETE FROM Lop_SG WHERE MaKhoa = @MaKhoa
            PRINT N'Đã chuyển lớp của khoa sang Bình Dương'
        END
        ELSE
        BEGIN
            INSERT INTO Khoa_SG VALUES (@MaKhoa, @TenKhoa, @CoSo) 
            DELETE FROM Khoa_BD WHERE MaKhoa = @MaKhoa
            PRINT N'Đã chuyển cơ sở của khoa sang Sài Gòn'

            INSERT INTO Lop_SG SELECT * FROM Lop_BD WHERE MaKhoa = @MaKhoa
            DELETE FROM Lop_BD WHERE MaKhoa = @MaKhoa
            PRINT N'Đã chuyển lớp của khoa sang Sài Gòn'
        END
    END
    ELSE
    BEGIN
        PRINT N'Sửa @CoSo không chuyển chi nhánh'
    END
    UPDATE Khoa_SG SET TenKhoa = @TenKhoa, CoSo = @CoSo WHERE MaKhoa = @MaKhoa
    UPDATE Khoa_BD SET TenKhoa = @TenKhoa, CoSo = @CoSo WHERE MaKhoa = @MaKhoa
    PRINT N'Sửa thành công'
END
GO

-- Lỗi Các dữ liệu không được để trống
EXEC SuaKhoa_Ngang @MaKhoa = NULL, @TenKhoa = NULL, @CoSo = NULL
GO
-- Lỗi Chi nhánh phải là "Sài gòn" hoặc "Bình Dương"
EXEC SuaKhoa_Ngang @MaKhoa = N'K1', @TenKhoa = N'Khoa 1', @CoSo = N'Đà Nẵng'
GO
-- Lỗi Không tìm thấy @MaKhoa để sửa dữ liệu
EXEC SuaKhoa_Ngang @MaKhoa = N'K3', @TenKhoa = N'Khoa 1', @CoSo = N'Sài Gòn'
GO
-- Sửa @CoSo không chuyển chi nhánh
EXEC SuaKhoa_Ngang @MaKhoa = N'CNSH', @TenKhoa = N'Khoa 1', @CoSo = N'Bình Dương'
GO
SELECT * FROM Khoa_SG
SELECT * FROM Khoa_BD
-- Sửa @CoSo có chuyển chi nhánh
EXEC SuaKhoa_Ngang @MaKhoa = N'CNSH', @TenKhoa = N'Khoa 1', @CoSo = N'Sài Gòn'
GO
SELECT * FROM Khoa_SG
SELECT * FROM Khoa_BD
