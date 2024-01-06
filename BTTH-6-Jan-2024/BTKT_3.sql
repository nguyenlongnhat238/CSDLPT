-- Câu 1: (2 điểm) Hãy viết 2 Stored procedure tên: TaoPhanManhNXB để tạo và lấy dữ liệu cho các
-- phân mảnh của bảng Nhà xuất bản; và TaoPhanManhSach để tạo và lấy dữ liệu cho các phân mảnh của
-- bảng Sách, biết:
-- • Bảng NhàXuấtBản được phân mảnh ngang chính dựa vào cột LoạiHình. Biết cột LoạiHình luôn có
-- dữ liệu (NOT NULL) và chỉ có đúng 2 giá trị là “Tư nhân” và “Nhà nước”.
-- • Bảng Sách được phân mảnh ngang dẫn xuất theo các phân mảnh của bảng NhàXuấtBản.

use QLSach
Go

CREATE PROC TaoPhanManhNXB
AS
BEGIN
    SELECT * INTO NhaXuatBan_TuNhan FROM NhaXuatBan WHERE LoaiHinh = N'Tư nhân'
    SELECT * INTO NhaXuatBan_NhaNuoc FROM NhaXuatBan WHERE LoaiHinh = N'Nhà nước'
END
GO

CREATE PROC TaoPhanManhSach
AS
BEGIN
    SELECT * INTO SachTuNhan FROM Sach WHERE MaNXB IN (SELECT MaNXB FROM NhaXuatBan_TuNhan)
    SELECT * INTO SachNhaNuoc FROM Sach WHERE MaNXB IN (SELECT MaNXB FROM NhaXuatBan_NhaNuoc)
END
GO

-- TEst
EXEC TaoPhanManhNXB
EXEC TaoPhanManhSach

SELECT * FROM NhaXuatBan_TuNhan
SELECT * FROM NhaXuatBan_NhaNuoc
SELECT * FROM SachTuNhan
SELECT * FROM SachNhaNuoc


-- Câu 2: (2 điểm) Tạo 2 stored procedure tên DSSachMuc1 và DSSachMuc2 để lập danh sách các quyển
-- sách của NXB biết tên NXB. Danh sách gồm 4 cột: MãSách, TựaSách, MãNXB, TênNXB, tham số vào là
-- @TênNXB.
-- Yêu cầu: phải có báo lỗi chi tiết (print ra màn hình) khi gặp các trường hợp ngoại lệ sau:
-- - @TênNXB chứa giá trị NULL
-- - @TênNXB chứa giá trị không tìm thấy trong CSDL
-- Sau đó dùng 2 stored procedure này để lập danh sách các quyển sách của NXB biết tên NXB là:
-- Giá trị của @TênNXB - Trường hợp
-- N'Tuổi hoa' - Lỗi: không tìm thấy tên NXB
-- N'Sự thật' - có tìm thấy tên NXB
-- N'Mỹ thuật' - có tìm thấy tên NXB

CREATE PROC DSSachMuc1
    @TenNXB NVARCHAR(50)
AS
BEGIN
    IF @TenNXB IS NULL
    BEGIN
        PRINT N'Lỗi: @TênNXB chứa giá trị NULL'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM NhaXuatBan WHERE TenNXB = @TenNXB)
    BEGIN
        PRINT N'Lỗi: @TênNXB chứa giá trị không tìm thấy trong CSDL'
        RETURN
    END

    SELECT Sach.MaSach, Sach.TuaSach, Sach.MaNXB, NhaXuatBan.TenNXB
    FROM Sach JOIN NhaXuatBan ON Sach.MaNXB = NhaXuatBan.MaNXB
    WHERE NhaXuatBan.TenNXB = @TenNXB
END
GO

CREATE PROC DSSachMuc2
    @TenNXB NVARCHAR(50)
AS
BEGIN
    IF @TenNXB IS NULL
    BEGIN
        PRINT N'Lỗi: @TênNXB chứa giá trị NULL'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM NhaXuatBan_TuNhan WHERE TenNXB = @TenNXB) AND NOT EXISTS (SELECT * FROM NhaXuatBan_NhaNuoc WHERE TenNXB = @TenNXB)
    BEGIN
        PRINT N'Lỗi: @TênNXB chứa giá trị không tìm thấy trong CSDL'
        RETURN
    END

    SELECT SachTuNhan.MaSach, SachTuNhan.TuaSach, SachTuNhan.MaNXB, NhaXuatBan_TuNhan.TenNXB
    FROM SachTuNhan JOIN NhaXuatBan_TuNhan ON SachTuNhan.MaNXB = NhaXuatBan_TuNhan.MaNXB
    WHERE NhaXuatBan_TuNhan.TenNXB = @TenNXB

    UNION

    SELECT SachNhaNuoc.MaSach, SachNhaNuoc.TuaSach, SachNhaNuoc.MaNXB, NhaXuatBan_NhaNuoc.TenNXB
    FROM SachNhaNuoc JOIN NhaXuatBan_NhaNuoc ON SachNhaNuoc.MaNXB = NhaXuatBan_NhaNuoc.MaNXB
    WHERE NhaXuatBan_NhaNuoc.TenNXB = @TenNXB
    
END
GO

-- Test
EXEC DSSachMuc1 N'Tuổi hoa'
EXEC DSSachMuc1 N'Sự thật'
EXEC DSSachMuc1 N'Mỹ thuật'

EXEC DSSachMuc2 N'Tuổi hoa'
EXEC DSSachMuc2 N'Sự thật'
EXEC DSSachMuc2 N'Mỹ thuật'

-- Câu 3: (2 điểm) Tạo 2 stored procedure tên ThemNXBMuc1 và ThemNXBMuc2 để thêm 1 hàng dữ liệu.
-- Các tham số vào là @MãNXB, @TênNXB, và @LoạiHình.
-- Yêu cầu: phải có báo thành công khi thêm dữ liệu thành công, hay báo lỗi chi tiết (print ra màn hình) và
-- không thêm dữ liệu khi gặp các trường hợp ngoại lệ sau:
-- - Có 1, 2 hay cả 3 tham số @MãNXB, @TênNXB, và @LoạiHình là NULL
-- - @LoạiHình chứa giá trị khác “Tư nhân” và “Nhà nước”
-- - @MãNXB đã có (nếu thêm sẽ bị trùng @MãNXB)
-- Sau đó dùng 2 stored procedure này để thêm các hàng dữ liệu là:
-- STT Giá trị các đối số Trường hợp
-- 1. (NULL,N'Tương lai',N'Tư nhân') Lỗi: không có giá trị mã NXB
-- 2. (N'NXB20',NULL, N'Tư nhân') Lỗi: không có giá trị tên NXB
-- 3. (N'NXB20',N'Tương lai',NULL) Lỗi: không có giá trị loại hình NXB
-- 4. (N'NXB10',N'Tương lai',N'Tư nhân') thêm được NXB
-- 5. (N'NXB11',N'Giáo dục',N'Nhà nước') thêm được NXB
-- 6. (N'NXB5',N'Thiếu niên',N'Nhà nước') Lỗi: bị trùng mã NXB
-- 7. (N'NXB6',N'Thanh niên',N'Nhà nước') Lỗi: bị trùng mã NXB

CREATE PROC ThemNXBMuc1
    @MaNXB NVARCHAR(10),
    @TenNXB NVARCHAR(50),
    @LoaiHinh NVARCHAR(50)
AS
BEGIN
    IF @MaNXB IS NULL OR @TenNXB IS NULL OR @LoaiHinh IS NULL
    BEGIN
        PRINT N'Lỗi: Có 1, 2 hay cả 3 tham số @MãNXB, @TênNXB, và @LoạiHình là NULL'
        RETURN
    END

    IF @LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước')
    BEGIN
        PRINT N'Lỗi: @LoạiHình chứa giá trị khác “Tư nhân” và “Nhà nước”'
        RETURN
    END

    IF EXISTS (SELECT * FROM NhaXuatBan WHERE MaNXB = @MaNXB)
    BEGIN
        PRINT N'Lỗi: @MãNXB đã có (nếu thêm sẽ bị trùng @MãNXB)'
        RETURN
    END

    INSERT INTO NhaXuatBan VALUES (@MaNXB, @TenNXB, @LoaiHinh)
    PRINT N'Thêm thành công'
END
GO

CREATE PROC ThemNXBMuc2
    @MaNXB NVARCHAR(10),
    @TenNXB NVARCHAR(50),
    @LoaiHinh NVARCHAR(50)
AS
BEGIN
    IF @MaNXB IS NULL OR @TenNXB IS NULL OR @LoaiHinh IS NULL
    BEGIN
        PRINT N'Lỗi: Có 1, 2 hay cả 3 tham số @MãNXB, @TênNXB, và @LoạiHình là NULL'
        RETURN
    END

    IF @LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước')
    BEGIN
        PRINT N'Lỗi: @LoạiHình chứa giá trị khác “Tư nhân” và “Nhà nước”'
        RETURN
    END

    IF EXISTS (SELECT * FROM NhaXuatBan_TuNhan WHERE MaNXB = @MaNXB)
    BEGIN
        PRINT N'Lỗi: @MãNXB đã có (nếu thêm sẽ bị trùng @MãNXB)'
        RETURN
    END

    IF EXISTS (SELECT * FROM NhaXuatBan_NhaNuoc WHERE MaNXB = @MaNXB)
    BEGIN
        PRINT N'Lỗi: @MãNXB đã có (nếu thêm sẽ bị trùng @MãNXB)'
        RETURN
    END

    IF @LoaiHinh = N'Tư nhân'
    BEGIN
        INSERT INTO NhaXuatBan_TuNhan VALUES (@MaNXB, @TenNXB, @LoaiHinh)
    END
    ELSE
    BEGIN
        INSERT INTO NhaXuatBan_NhaNuoc VALUES (@MaNXB, @TenNXB, @LoaiHinh)
    END
    PRINT N'Thêm thành công'
END
GO

-- Test
EXEC ThemNXBMuc1 NULL, N'Tương lai', N'Tư nhân'
EXEC ThemNXBMuc1 N'NXB20', NULL, N'Tư nhân'
EXEC ThemNXBMuc1 N'NXB20', N'Tương lai', NULL
EXEC ThemNXBMuc1 N'NXB10', N'Tương lai', N'Tư nhân'
EXEC ThemNXBMuc1 N'NXB11', N'Giáo dục', N'Nhà nước'
EXEC ThemNXBMuc1 N'NXB5', N'Thiếu niên', N'Nhà nước'
EXEC ThemNXBMuc1 N'NXB6', N'Thanh niên', N'Nhà nước'

EXEC ThemNXBMuc2 NULL, N'Tương lai', N'Tư nhân'
EXEC ThemNXBMuc2 N'NXB20', NULL, N'Tư nhân'
EXEC ThemNXBMuc2 N'NXB20', N'Tương lai', NULL
EXEC ThemNXBMuc2 N'NXB10', N'Tương lai', N'Tư nhân'
EXEC ThemNXBMuc2 N'NXB11', N'Giáo dục', N'Nhà nước'
EXEC ThemNXBMuc2 N'NXB5', N'Thiếu niên', N'Nhà nước'
EXEC ThemNXBMuc2 N'NXB6', N'Thanh niên', N'Nhà nước'

SELECT * FROM NhaXuatBan_TuNhan
SELECT * FROM NhaXuatBan_NhaNuoc

SELECT * FROM NhaXuatBan

-- Câu 4: (2 điểm) Tạo 2 stored procedure tên SuaNXBMuc1 và SuaNXBMuc2 để sửa (update) 2 cột
-- TênNXB và LoạiHình (không sửa cột MãNXB). Các tham số vào là @MãNXB, @TênNXB, và
-- @LoạiHình, trong đó @MãNXB để xác định hàng dữ liệu cần sửa.
-- Yêu cầu: phải có báo chi tiết việc đã thực hiện khi sửa dữ liệu thành công, hay báo lỗi chi tiết (print ra màn
-- hình) và không sửa dữ liệu khi gặp các trường hợp ngoại lệ sau:
-- - Có @ MãNXB là NULL
-- - Không tìm thấy @ MãNXB để sửa dữ liệu
-- - Có @ LoạiHình là NULL hay chứa giá trị khác “Tư nhân” và “Nhà nước”- Chú ý: nếu sửa mức 2 mà có dời dữ liệu nhà xuất bản sang phân mảnh khác thì cũng phải dời sách
-- của nhà xuất bản đó sang phân mảnh khác tương ứng. Khi dời dữ liệu thì phải thông báo dời như
-- thế nào trong thông báo sửa dữ liệu thành công.
-- Sau đó dùng 2 stored procedure này để sửa các hàng dữ liệu:
-- STT Giá trị các đối số Trường hợp
-- 1. (NULL,N'Sáng tạo mới',N'Tư nhân') Lỗi: không có giá trị mã NXB
-- 2. (N'NXB123',N'Kỹ thuật',N'Tư nhân') Lỗi: không tìm thấy mã NXB
-- 3. (N'NXB1',N'Kỹ thuật',NULL) Lỗi: không có loại hình NXB
-- 4. (N'NXB1',N'Kỹ thuật',N'Nhập khẩu') Lỗi: không đúng loại hình NXB
-- 5. (N'NXB1',N'Sáng tạo mới',N'Tư nhân') Sửa không đổi loại hình
-- 6. (N'NXB3',N'Thành công',N'Nhà nước') Sửa có đổi loại hình
-- 7. (N'NXB6',N'Đất Việt',N'Tư nhân') Sửa có đổi loại hình

CREATE PROC SuaNXBMuc1
    @MaNXB NVARCHAR(10),
    @TenNXB NVARCHAR(50),
    @LoaiHinh NVARCHAR(50)
AS
BEGIN
    IF @MaNXB IS NULL
    BEGIN
        PRINT N'Lỗi: Có @ MãNXB là NULL'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM NhaXuatBan WHERE MaNXB = @MaNXB)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy @ MãNXB để sửa dữ liệu'
        RETURN
    END

    IF @LoaiHinh IS NULL OR @LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước')
    BEGIN
        PRINT N'Lỗi: Có @ LoạiHình là NULL hay chứa giá trị khác “Tư nhân” và “Nhà nước”'
        RETURN
    END

    DECLARE @OldLoaiHinh NVARCHAR(50)
    SELECT @OldLoaiHinh = LoaiHinh FROM NhaXuatBan WHERE MaNXB = @MaNXB

    IF @OldLoaiHinh != @LoaiHinh
        print M'Sửa có đổi loại hình'
    ELSE
        print M'Sửa không đổi loại hình'

    UPDATE NhaXuatBan SET TenNXB = @TenNXB, LoaiHinh = @LoaiHinh WHERE MaNXB = @MaNXB
    PRINT N'Sửa thành công'
END
GO

CREATE PROC SuaNXBMuc2
    @MaNXB NVARCHAR(10),
    @TenNXB NVARCHAR(50),
    @LoaiHinh NVARCHAR(50)
AS
BEGIN
    IF @MaNXB IS NULL
    BEGIN
        PRINT N'Lỗi: Có @ MãNXB là NULL'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM NhaXuatBan_TuNhan WHERE MaNXB = @MaNXB) AND NOT EXISTS (SELECT * FROM NhaXuatBan_NhaNuoc WHERE MaNXB = @MaNXB)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy @ MãNXB để sửa dữ liệu'
        RETURN
    END

    IF @LoaiHinh IS NULL OR @LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước')
    BEGIN
        PRINT N'Lỗi: Có @ LoạiHình là NULL hay chứa giá trị khác “Tư nhân” và “Nhà nước”'
        RETURN
    END

    # khai báo biến
    DECLARE @OldLoaiHinh NVARCHAR(50)

    SELECT @OldLoaiHinh = LoaiHinh FROM NhaXuatBan_TuNhan WHERE MaNXB = @MaNXB

    IF @OldLoaiHinh IS NULL
    BEGIN
        SELECT @OldLoaiHinh = LoaiHinh FROM NhaXuatBan_NhaNuoc WHERE MaNXB = @MaNXB
    END
    print N'Loại hình cũ: ' + @OldLoaiHinh
    print N'Loại hình mới: ' + @LoaiHinh
    IF @OldLoaiHinh != @LoaiHinh
    BEGIN
        print N'Loại hình cũ khác loại hình mới'
        PRINT N'Sửa có đổi loại hình'
        IF @OldLoaiHinh = N'Tư nhân'
        BEGIN
            INSERT INTO NhaXuatBan_NhaNuoc VALUES (@MaNXB, @TenNXB, @LoaiHinh)
            DELETE FROM NhaXuatBan_TuNhan WHERE MaNXB = @MaNXB
            print N'Dời dữ liệu từ phân mảnh Tư nhân của NXB sang phân mảnh Nhà nước'

            INSERT INTO SachNhaNuoc SELECT * FROM SachTuNhan WHERE MaNXB = @MaNXB
            DELETE FROM SachTuNhan WHERE MaNXB = @MaNXB
            print N'Dời dữ liệu từ phân mảnh Tư nhân của Sách sang phân mảnh Nhà nước'
        END
        ELSE
        BEGIN
            INSERT INTO NhaXuatBan_TuNhan VALUES (@MaNXB, @TenNXB, @LoaiHinh)
            DELETE FROM NhaXuatBan_NhaNuoc WHERE MaNXB = @MaNXB
            print N'Dời dữ liệu từ phân mảnh Nhà nước của NXB sang phân mảnh Tư nhân'

            INSERT INTO SachTuNhan SELECT * FROM SachNhaNuoc WHERE MaNXB = @MaNXB
            DELETE FROM SachNhaNuoc WHERE MaNXB = @MaNXB
            print N'Dời dữ liệu từ phân mảnh Nhà nước của Sách sang phân mảnh Tư nhân'
        END
    END
    ELSE
    BEGIN
        print N'Loại hình cũ giống loại hình mới'
        PRINT N'Sửa không đổi loại hình'
    END

    UPDATE NhaXuatBan_TuNhan SET TenNXB = @TenNXB, LoaiHinh = @LoaiHinh WHERE MaNXB = @MaNXB
    UPDATE NhaXuatBan_NhaNuoc SET TenNXB = @TenNXB, LoaiHinh = @LoaiHinh WHERE MaNXB = @MaNXB

    PRINT N'Sửa thành công'
END
GO

-- Test
EXEC SuaNXBMuc1 NULL, N'Sáng tạo mới', N'Tư nhân'
EXEC SuaNXBMuc1 N'NXB123', N'Kỹ thuật', N'Tư nhân'
EXEC SuaNXBMuc1 N'NXB1', N'Kỹ thuật', NULL
EXEC SuaNXBMuc1 N'NXB1', N'Kỹ thuật', N'Nhập khẩu'
EXEC SuaNXBMuc1 N'NXB1', N'Sáng tạo mới', N'Tư nhân'
EXEC SuaNXBMuc1 N'NXB3', N'Thành công', N'Nhà nước'
EXEC SuaNXBMuc1 N'NXB6', N'Đất Việt', N'Tư nhân'

EXEC SuaNXBMuc2 NULL, N'Sáng tạo mới', N'Tư nhân'
EXEC SuaNXBMuc2 N'NXB123', N'Kỹ thuật', N'Tư nhân'
EXEC SuaNXBMuc2 N'NXB1', N'Kỹ thuật', NULL
EXEC SuaNXBMuc2 N'NXB1', N'Kỹ thuật', N'Nhập khẩu'
EXEC SuaNXBMuc2 N'NXB1', N'Sáng tạo mới', N'Tư nhân'
EXEC SuaNXBMuc2 N'NXB3', N'Thành công', N'Nhà nước'
EXEC SuaNXBMuc2 N'NXB6', N'Đất Việt', N'Tư nhân'

SELECT * FROM NhaXuatBan_TuNhan
SELECT * FROM NhaXuatBan_NhaNuoc

SELECT * FROM SachTuNhan
SELECT * FROM SachNhaNuoc

SELECT * FROM NhaXuatBan

-- Câu 5: (2 điểm) Tạo 2 stored procedure tên XoaSachMuc1 và XoaSachMuc2 để xóa 1 hàng dữ liệu sách
-- biết mã sách. Tham số vào là @MãSách để xác định hàng dữ liệu cần xóa.
-- Yêu cầu: phải có báo việc đã thực hiện khi xóa dữ liệu thành công, hay báo lỗi (print ra màn hình) và không
-- xóa dữ liệu khi gặp các trường hợp ngoại lệ sau:
-- - Có @MãSách là NULL
-- - Không tìm thấy @MãSách để xóa dữ liệu
-- Sau đó dùng 2 stored procedure này để xóa các hàng dữ liệu có mã sách là:
-- STT Giá trị đối số @MãSách Trường hợp
-- 1. NULL Lỗi: không có giá trị mã sách
-- 2. N'S123' Lỗi: không tìm thấy sách để xóa
-- 3. N'S004' Xóa được sách
-- 4. N'S005' Xóa được sách

CREATE PROC XoaSachMuc1
    @MaSach NVARCHAR(10)
AS
BEGIN
    IF @MaSach IS NULL
    BEGIN
        PRINT N'Lỗi: Có @MãSách là NULL'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Sach WHERE MaSach = @MaSach)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy @MãSách để xóa dữ liệu'
        RETURN
    END

    DELETE FROM Sach WHERE MaSach = @MaSach
    PRINT N'Xóa thành công'
END
GO

CREATE PROC XoaSachMuc2
    @MaSach NVARCHAR(10)
AS
BEGIN
    IF @MaSach IS NULL
    BEGIN
        PRINT N'Lỗi: Có @MãSách là NULL'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM SachTuNhan WHERE MaSach = @MaSach) AND NOT EXISTS (SELECT * FROM SachNhaNuoc WHERE MaSach = @MaSach)
    BEGIN
        PRINT N'Lỗi: Không tìm thấy @MãSách để xóa dữ liệu'
        RETURN
    END

    DELETE FROM SachTuNhan WHERE MaSach = @MaSach
    DELETE FROM SachNhaNuoc WHERE MaSach = @MaSach
    PRINT N'Xóa thành công'
END
GO

-- Test
EXEC XoaSachMuc1 NULL
EXEC XoaSachMuc1 N'S123'
EXEC XoaSachMuc1 N'S004'
EXEC XoaSachMuc1 N'S005'

EXEC XoaSachMuc2 NULL
EXEC XoaSachMuc2 N'S123'
EXEC XoaSachMuc2 N'S004'
EXEC XoaSachMuc2 N'S005'