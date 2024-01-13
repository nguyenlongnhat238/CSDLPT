-- Lop(MaLop, TenLop, NganhDaoTao, #MaKhoa)
-- Khoa(MaKhoa, TenKhoa, CoSo)
-- Khóa chính: là MaKhoa và MaLop đã được gạch dưới
-- Khóa ngoại: Lop.MaKhoa là khóa ngoại tham khảo đến Khoa.MaKhoa
-- Câu 1: Hãy viết Stored procedure tên: TaoPM_Doc_Khoa để tạo và lấy dữ liệu cho 2 phân mảnh dọc từ
-- bảng Khoa, biết thiết kế của hai phân mảnh dọc là:
-- Khoa_Doc1(MaKhoa, TenKhoa)
-- Khoa_Doc2(MaKhoa, CoSo)
CREATE PROC TaoPM_Doc_Khoa AS BEGIN
SELECT
    MaKhoa,
    TenKhoa INTO Khoa_Doc1
From
    Khoa
SELECT
    MaKhoa,
    CoSo INTO Khoa_Doc2
From
    Khoa
END
GO
    EXEC TaoPM_Doc_Khoa
GO
SELECT
    *
FROM
    Khoa_Doc1
SELECT
    *
FROM
    Khoa_Doc2 -- Câu 2: Hãy viết Stored procedure tên: XemKhoa_Doc có một tham số vào là @CoSo. Procedure này sẽ
    -- lập danh sách 3 cột là MaKhoa, TenKhoa, CoSo từ 2 phân mảnh dọc của bảng Khoa.
    -- Yêu cầu:
    -- - Nếu @CoSo là NULL: lập danh sách tất cả các khoa
    -- - Có @CoSo không hợp lệ: báo lỗi
    -- - Không tìm thấy giá trị @CoSo: báo lỗi
    -- Sinh viên phải tự tạo đủ các trường hợp để kiểm thử, chứng minh kết quả lập trình là đúng trong tất
    -- cả các trường hợp.
    CREATE PROC XemKhoa_Doc @CoSo nvarchar(50) AS BEGIN IF @CoSo IS NULL
SELECT
    *
FROM
    Khoa_Doc1
UNION
SELECT
    *
FROM
    Khoa_Doc2
    ELSE IF @CoSo NOT IN (
        SELECT
            CoSo
        FROM
            Khoa_Doc2
    ) RAISERROR('CoSo khong hop le', 16, 1)
    ELSE
SELECT
    *
FROM
    Khoa_Doc1
WHERE
    MaKhoa IN (
        SELECT
            MaKhoa
        FROM
            Khoa_Doc2
        WHERE
            CoSo = @CoSo
    )
UNION
SELECT
    *
FROM
    Khoa_Doc2
WHERE
    CoSo = @CoSo
END
GO
    EXEC XemKhoa_Doc 'CS1'
GO
    EXEC XemKhoa_Doc 'CS2'
GO
    -------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------
    USE [master] RESTORE DATABASE [QLTruongDH]
FROM
    DISK = N'D:\QLTruongDH_DeThi.bak' WITH FILE = 1,
    MOVE N'QL_TruongDH' TO N'C:\Program Files\Microsoft SQL
Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\QL_TruongDH.mdf',
    MOVE N'QL_TruongDH_log' TO N'C:\Program Files\Microsoft SQL
Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\QL_TruongDH_log.ldf',
    NOUNLOAD,
    STATS = 5
GO
    use QLTruongDH
go
    --cau 1
    create proc TaoPM_Doc_Khoa as begin
select
    MaKhoa,
    TenKhoa into Khoa_Doc1
from
    Khoa
select
    MaKhoa,
    CoSo into Khoa_Doc2
from
    Khoa
end
go
    exec TaoPM_Doc_Khoa
go
    --cau2
    create proc XemKhoa_Doc(@CoSo nvarchar(50)) as begin begin try if(@CoSo is null) begin
select
    a.MaKhoa,
    TenKhoa,
    CoSo
from
    Khoa_Doc1 a
    join Khoa_Doc2 b on a.MaKhoa = b.MaKhoa return
end if(
    not exists(
        select
            CoSo
        from
            Khoa_Doc2
        where
            CoSo = @CoSo
    )
) raiserror(N'Co So khong hop le', 16, 1)
select
    a.MaKhoa,
    TenKhoa,
    CoSo
from
    Khoa_Doc1 a
    join Khoa_Doc2 b on a.MaKhoa = b.MaKhoa
where
    CoSo = @CoSo
end try begin catch DECLARE @ErrorMessage NVARCHAR(4000);

DECLARE @ErrorSeverity INT;

DECLARE @ErrorState INT;

SELECT
    @ErrorMessage = ERROR_MESSAGE(),
    @ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE();

-- Use RAISERROR inside the CATCH block to return error
-- information about the original error that caused
-- execution to jump to the CATCH block.
RAISERROR (
    @ErrorMessage,
    -- Message text.
    @ErrorSeverity,
    -- Severity.
    @ErrorState -- State.
);

end catch
end
go
    exec XemKhoa_Doc null
go
    exec XemKhoa_Doc N'@@#@#'
go
    exec XemKhoa_Doc N'Bình Dương'
go
    exec XemKhoa_Doc N'Sài Gòn'
go
    drop proc XemKhoa_Doc
go
--cau3
    create proc ThemKhoa_Doc (
        @MaKhoa nvarchar(10),
        @TenKhoa nvarchar(50),
        @CoSo nvarchar(50)
    ) as begin begin try if(
        @MaKhoa is null
        and @TenKhoa is null
        and @CoSo is null
    ) raiserror(N'Mã Khoa null, Tên Khoa null, Cơ Sở null', 16, 1) if(@MaKhoa is null) raiserror(N'Mã Khoa null', 16, 1) if(@TenKhoa is null) raiserror(N'Tên Khoa null', 16, 1) if(@CoSo is null) raiserror(N'Cơ Sở null', 16, 1) if(
        @CoSo != N'Bình Dương'
        and @CoSo != N'Sài Gòn'
    ) raiserror(N'Cơ Sở khác Bình Dương và Sài Gòn', 16, 1) if(
        exists(
            select
                MaKhoa
            from
                Khoa_Doc1
            where
                MaKhoa = @MaKhoa
        )
    ) raiserror(N'Trùng Mã Khoa không thêm được', 16, 1)
insert into
    Khoa_Doc1
values
(@MaKhoa, @TenKhoa)
insert into
    Khoa_Doc2
values
(@MaKhoa, @CoSo) print N'Thêm thành công'
end try begin catch declare @t nvarchar(4000) declare @s int declare @st int
select
    @t = ERROR_MESSAGE(),
    @s = ERROR_SEVERITY(),
    @st = ERROR_STATE() raiserror(@t, @s, @st)
end catch endgo exec ThemKhoa_Doc null,
'saa',
'saas'
go
    exec ThemKhoa_Doc 'saa',
    null,
    'saas'
go
    exec ThemKhoa_Doc 'saa',
    'saas',
    null
go
    exec ThemKhoa_Doc null,
    null,
    null
go
    exec ThemKhoa_Doc N 'NNH',
    N 'Ngoại ngữ học',
    N'Cần Thơ'
go
    exec ThemKhoa_Doc N'QTKD',
    N 'Ngoại ngữ học',
    N'Sài Gòn'
go
    exec ThemKhoa_Doc N 'NNH',
    N 'Ngoại ngữ học',
    N'Sài Gòn'
go
    --cau 4
    create proc TaoPM_Ngang_Khoa as begin
select
    * into Khoa_Ngang1
from
    Khoa
where
    CoSo = N'Bình Dương'
select
    * into Khoa_Ngang2
from
    Khoa
where
    CoSo = N'Sài Gòn'
end
go
    exec TaoPM_Ngang_Khoa
go
    create proc TaoPM_Ngang_Lop as begin
select
    * into Lop_Ngang1
from
    Lop
where
    MaKhoa in (
        select
            MaKhoa
        from
            Khoa_Ngang1
    )
select
    * into Lop_Ngang2
from
    Lop
where
    MaKhoa in (
        select
            MaKhoa
        from
            Khoa_Ngang2
    )
end
go
    exec TaoPM_Ngang_Lop
go
    --cau5
    create proc XemKhoa_Ngang(@CoSo nvarchar(50)) as begin begin try if(@CoSo is null) raiserror(N'Cơ sở null', 16, 1) if(
        not exists(
            select
                CoSo
            from
                Khoa_Ngang1
            where
                CoSo = @CoSo
        )
        and not exists(
            select
                CoSo
            from
                Khoa_Ngang2
            where
                CoSo = @CoSo
        )
    ) raiserror(N'Không tìm thấy cơ sở', 16, 1) if(@CoSo = N'Bình Dương')
select
    *
from
    Khoa_Ngang1
    else
select
    *
from
    Khoa_Ngang2
end try begin catch declare @t nvarchar(4000) declare @s int declare @st intselect @t = ERROR_MESSAGE(),
@s = ERROR_SEVERITY(),
@st = ERROR_STATE() raiserror(@t, @s, @st)
end catch
end
go
    exec XemKhoa_Ngang null
go
    exec XemKhoa_Ngang N'Cần Thơ'
go
    exec XemKhoa_Ngang N'Bình Dương'
go
    exec XemKhoa_Ngang N'Sài Gòn'
go
    --cau6
    create proc SuaKhoa_Ngang(
        @MaKhoa nvarchar(10),
        @TenKhoa nvarchar(50),
        @CoSo nvarchar(50)
    ) as begin begin try if(
        @MaKhoa is null
        and @TenKhoa is null
        and @CoSo is null
    ) raiserror(N'Mã Khoa null, Tên Khoa null, Cơ Sở null', 16, 1) if(@MaKhoa is null) raiserror(N'Mã Khoa null', 16, 1) if(@TenKhoa is null) raiserror(N'Tên Khoa null', 16, 1) if(@CoSo is null) raiserror(N'Cơ Sở null', 16, 1) if(
        not exists(
            select
                MaKhoa
            from
                Khoa_Ngang1
            where
                MaKhoa = @MaKhoa
        )
        and not exists(
            select
                MaKhoa
            from
                Khoa_Ngang2
            where
                MaKhoa = @MaKhoa
        )
    ) raiserror(N'Không tìm thấy Mã Khoa', 16, 1) if(
        @CoSo != N'Bình Dương'
        and @CoSo != N'Sài Gòn'
    ) raiserror(N'Cơ Sở khác Bình Dương và Sài Gòn', 16, 1) if(
        exists(
            select
                MaKhoa
            from
                Khoa_Ngang1
            where
                MaKhoa = @MaKhoa
        )
    ) begin if(@CoSo = N'Bình Dương') begin
update
    Khoa_Ngang1
set
    TenKhoa = @TenKhoa
where
    MaKhoa = @MaKhoa print N'đã sửa tên khoa thành công' return
end
else begin
update
    Khoa_Ngang1
set
    TenKhoa = @TenKhoa,
    CoSo = @CoSo
where
    MaKhoa = @MaKhoa print N'Đã sửa tên khoa và cơ sở thành công'
insert into
    Khoa_Ngang2
select
    *
from
    Khoa_Ngang1
where
    MaKhoa = @MaKhoa print N'Đã thêm khoa muốn sửa vào khoa 2'
insert into
    Lop_Ngang2
select
    *
from
    Lop_Ngang1
where
    MaKhoa = @MaKhoa print N'Đã thêm các lớp của khoa đó vào lớp 2'
delete from
    Khoa_Ngang1
where
    MaKhoa = @MaKhoa print N'Đã xóa khoa được sửa ở khoa 1'
delete from
    Lop_Ngang1
where
    MaKhoa = @MaKhoa print N'Đã xóa các lớp của khoa ở lớp 1' return endend if(
        exists(
            select
                MaKhoa
            from
                Khoa_Ngang2
            where
                MaKhoa = @MaKhoa
        )
    ) begin if(@CoSo = N'Sài Gòn') begin
update
    Khoa_Ngang2
set
    TenKhoa = @TenKhoa
where
    MaKhoa = @MaKhoa print N'đã sửa tên khoa thành công' return
end
else begin
update
    Khoa_Ngang2
set
    TenKhoa = @TenKhoa,
    CoSo = @CoSo
where
    MaKhoa = @MaKhoa print N'Đã sửa tên khoa và cơ sở thành công'
insert into
    Khoa_Ngang1
select
    *
from
    Khoa_Ngang2
where
    MaKhoa = @MaKhoa print N'Đã thêm khoa muốn sửa vào khoa 1'
insert into
    Lop_Ngang1
select
    *
from
    Lop_Ngang2
where
    MaKhoa = @MaKhoa print N'Đã thêm các lớp của khoa đó vào lớp 1'
delete from
    Khoa_Ngang2
where
    MaKhoa = @MaKhoa print N'Đã xóa khoa được sửa ở khoa 2'
delete from
    Lop_Ngang2
where
    MaKhoa = @MaKhoa print N'Đã xóa các lớp của khoa ở lớp 2' return
end
end
end try begin catch declare @t nvarchar(4000) declare @s int declare @st int
select
    @t = ERROR_MESSAGE(),
    @s = ERROR_SEVERITY(),
    @st = ERROR_STATE() raiserror(@t, @s, @st)
end catch
end
go
    exec SuaKhoa_Ngang null,
    null,
    null
go
    exec SuaKhoa_Ngang null,
    'sad',
    'asdas'
go
    exec SuaKhoa_Ngang 'null',
    null,
    'null'
go
    exec SuaKhoa_Ngang 'null',
    'null',
    null
go
    exec SuaKhoa_Ngang N 'NNH',
    N 'Ngôn ngữ học',
    N'Cần Thơ'
go
    exec SuaKhoa_Ngang N 'CNSH',
    N 'Ngôn ngữ học',
    N'Bình Dương'
go
    exec SuaKhoa_Ngang N 'CNSH',
    N 'Ngôn ngữ học2',
    N'Sài Gòn'
go
    exec SuaKhoa_Ngang N 'CNSH',
    N 'Ngôn ngữ học',
    N'Bình Dương'
go