-- Bài tập thực hành 6 
--- Tạo cơ sở dữ liệu
use master
go
    CREATE DATABASE QLDA
GO
    USE QLDA
GO
    -- 2. Tạo cơ sở dữ liệu
    -- Tạo bảng người quản lý
    CREATE TABLE NgườiQuảnLý (
        MãNQL INT PRIMARY KEY,
        Họ NVARCHAR(50),
        Tên NVARCHAR(50),
        TênPhòng NVARCHAR(50)
    );

INSERT INTO
    NgườiQuảnLý (MãNQL, Họ, Tên, TênPhòng)
values
    (1, N 'Nguyen', N'A', N'P1')
INSERT INTO
    NgườiQuảnLý (MãNQL, Họ, Tên, TênPhòng)
values
    (2, N 'Nguyen', N'B', N'P1')
INSERT INTO
    NgườiQuảnLý (MãNQL, Họ, Tên, TênPhòng)
values
    (3, N 'Nguyen', N'C', N'P1')
INSERT INTO
    NgườiQuảnLý (MãNQL, Họ, Tên, TênPhòng)
values
    (4, N 'Nguyen', N'D', N'P2')
INSERT INTO
    NgườiQuảnLý (MãNQL, Họ, Tên, TênPhòng)
values
    (5, N 'Nguyen', N'E', N'P2') -- Tạo bảng Dự Án
    CREATE TABLE DựÁn (
        MãDA INT PRIMARY KEY,
        TênDA NVARCHAR(100),
        MãNQL INT,
        FOREIGN KEY (MãNQL) REFERENCES NgườiQuảnLý(MãNQL)
    );

INSERT INTO
    DựÁn (MãDA, MãNQL, TênDA)
values
    (1, 1, N'Du An A')
INSERT INTO
    DựÁn (MãDA, MãNQL, TênDA)
values
    (2, 2, N'Du An B')
INSERT INTO
    DựÁn (MãDA, MãNQL, TênDA)
values
    (3, 3, N'Du An C')
INSERT INTO
    DựÁn (MãDA, MãNQL, TênDA)
values
    (4, 4, N'Du An D')
INSERT INTO
    DựÁn (MãDA, MãNQL, TênDA)
values
    (5, 5, N'Du An E')
INSERT INTO
    DựÁn (MãDA, MãNQL, TênDA)
values
    (6, 5, N'Du An F') -- Tạo bảng Bộ Phận
    CREATE TABLE BộPhận (
        MãBP INT PRIMARY KEY,
        TênBP NVARCHAR(100),
        MãNQL INT,
        FOREIGN KEY (MãNQL) REFERENCES NgườiQuảnLý(MãNQL)
    );

INSERT INTO
    BộPhận (MãBP, MãNQL, TênBP)
values
    (1, 1, N'Bo PHan A')
INSERT INTO
    BộPhận (MãBP, MãNQL, TênBP)
values
    (2, 2, N'Bo PHan B')
INSERT INTO
    BộPhận (MãBP, MãNQL, TênBP)
values
    (3, 3, N'Bo PHan C')
INSERT INTO
    BộPhận (MãBP, MãNQL, TênBP)
values
    (4, 4, N'Bo PHan D')
INSERT INTO
    BộPhận (MãBP, MãNQL, TênBP)
values
    (5, 5, N'Bo PHan E') -- Tạo bảng Nhân Viên
    CREATE TABLE NhânViên (
        MãNV INT PRIMARY KEY,
        Họ NVARCHAR(50),
        Tên NVARCHAR(50),
        MãBP INT,
        FOREIGN KEY (MãBP) REFERENCES BộPhận(MãBP)
    );

INSERT INTO
    NhânViên (MãNV, MãBP, Họ, Tên)
values
    (1, 1, N'Pham Van', N'A')
INSERT INTO
    NhânViên (MãNV, MãBP, Họ, Tên)
values
    (2, 2, N'Pham Van', N'B')
INSERT INTO
    NhânViên (MãNV, MãBP, Họ, Tên)
values
    (3, 3, N'Pham Van', N'C')
INSERT INTO
    NhânViên (MãNV, MãBP, Họ, Tên)
values
    (4, 4, N'Pham Van', N'D')
INSERT INTO
    NhânViên (MãNV, MãBP, Họ, Tên)
values
    (5, 5, N'Pham Van', N'E') -- Tạo bảng Phân Công
    CREATE TABLE PhânCông (
        MãNV INT,
        MãDA INT,
        PRIMARY KEY (MãNV, MãDA),
        FOREIGN KEY (MãNV) REFERENCES NhânViên(MãNV),
        FOREIGN KEY (MãDA) REFERENCES DựÁn(MãDA)
    );

INSERT INTO
    PhânCông (MãNV, MãDA)
values
    (1, 1)
INSERT INTO
    PhânCông (MãNV, MãDA)
values
    (2, 2)
INSERT INTO
    PhânCông (MãNV, MãDA)
values
    (3, 3)
INSERT INTO
    PhânCông (MãNV, MãDA)
values
    (4, 4)
INSERT INTO
    PhânCông (MãNV, MãDA)
values
    (5, 5) -- 3. TẠO các phân mảnh dựa trên thông tin câu 1 
    --  Phân mảnh bảng NgườiQuảnLý dựa vào trường TênPhòng
SELECT
    * INTO QuanLyP1
FROM
    NgườiQuảnLý
WHERE
    TênPhòng = 'P1';

SELECT
    * INTO QuanLyP2
FROM
    NgườiQuảnLý
WHERE
    TênPhòng = 'P2';

-- Phân mảnh bảng BộPhận dựa vào MãNQL
SELECT
    * INTO BoPhan_NQL_1
FROM
    BộPhận
WHERE
    MãNQL IN (
        SELECT
            MãNQL
        FROM
            QuanLyP1
    );

SELECT
    * INTO BoPhan_NQL_2
FROM
    BộPhận
WHERE
    MãNQL IN (
        SELECT
            MãNQL
        FROM
            QuanLyP2
    );

-- Phân mảnh bảng DựÁn dựa vào MãNQL
SELECT
    * INTO DuAn_NQL_1
FROM
    DựÁn
WHERE
    MãNQL IN (
        SELECT
            MãNQL
        FROM
            QuanLyP1
    );

SELECT
    * INTO DuAn_NQL_2
FROM
    DựÁn
WHERE
    MãNQL IN (
        SELECT
            MãNQL
        FROM
            QuanLyP2
    );

-- Phân mảnh bảng NhânViên dựa vào MãBP
SELECT
    * INTO NhanVien_BP_1
FROM
    NhânViên
WHERE
    MãBP IN (
        SELECT
            MãBP
        FROM
            BoPhan_NQL_1
    );

SELECT
    * INTO NhanVien_BP_2
FROM
    NhânViên
WHERE
    MãBP IN (
        SELECT
            MãBP
        FROM
            BoPhan_NQL_2
    );

-- Phân mảnh bảng PhânCông dựa vào MãNV
SELECT
    * INTO PhanCong_NV_1
FROM
    PhânCông
WHERE
    MãNV IN (
        SELECT
            MãNV
        FROM
            NhanVien_BP_1
    );

SELECT
    * INTO PhanCong_NV_2
FROM
    PhânCông
WHERE
    MãNV IN (
        SELECT
            MãNV
        FROM
            NhanVien_BP_2
    );

--- 4. Lập danh sách tên những dự án chưa có nhân viên tham gia
-- MUC1
CREATE PROC DuAn0NVMUC1 AS BEGIN
SELECT
    *
FROM
    DựÁn
WHERE
    MãDA not in (
        SELECT
            DISTINCT MãDA
        FROM
            PhânCông
    )
END
GO
    exec DuAn0NVMUC1 -- MỨC 2
    CREATE PROC DuAn0NVMUC2 AS BEGIN
SELECT
    *
FROM
    DuAn_NQL_1
WHERE
    MãDA not in (
        SELECT
            DISTINCT MãDA
        FROM
            PhanCong_NV_1
    )
UNION
SELECT
    *
FROM
    DuAn_NQL_2
WHERE
    MãDA not in (
        SELECT
            DISTINCT MãDA
        FROM
            PhanCong_NV_2
    )
END
GO
    exec DuAn0NVMUC2 -- 5. Hiển thị Họ và Tên người quản lý dự án biết mã dự án
    -- MỨC 1
    CREATE PROC NguoiQuanLyDuAnMuc1 (@maDA int) AS BEGIN
SELECT
    REPLACE(CONCAT(Họ + ' ', Tên + ' '), '  ', ' ') as Name
FROM
    NgườiQuảnLý
Where
    MãNQL = (
        SELECT
            MãNQL
        FROM
            DựÁn
        WHERE
            MãDA = @maDA
    )
END
GO
    EXEC NguoiQuanLyDuAnMuc1 1 -- Mức 2:
    CREATE PROC NguoiQuanLyMuc2 (@maDA int) AS BEGIN
SELECT
    REPLACE(CONCAT(Họ + ' ', Tên + ' '), '  ', ' ') as Name
FROM
    QuanLyP1
Where
    MãNQL = (
        SELECT
            MãNQL
        FROM
            DuAn_NQL_1
        WHERE
            MãDA = @maDA
    )
UNION
SELECT
    REPLACE(CONCAT(Họ + ' ', Tên + ' '), '  ', ' ') as Name
FROM
    QuanLyP2
Where
    MãNQL = (
        SELECT
            MãNQL
        FROM
            DuAn_NQL_2
        WHERE
            MãDA = @maDA
    )
END
GO
    EXEC NguoiQuanLyMuc2 1 -- 6. Danh sách nhân viên tham gia dự án 
    -- Mức 1
    CREATE PROC DanhSachNhanVienDAMuc1 AS BEGIN
SELECT
    d.TênDA,
    COUNT(E.MãNV)
FROM
    NhânViên as e,
    DựÁn as d,
    PhânCông as p
Where
    e.MãNV = p.MãNV
    and d.MãDA = p.MãDA
GROUP BY
    d.TênDA
END
GO
    EXEC DanhSachNhanVienDAMuc1 -- Mức 2:
    CREATE PROC DanhSachNhanVienDAMuc2 AS BEGIN
SELECT
    d.TênDA,
    COUNT(E.MãNV)
FROM
    NhanVien_BP_1 as e,
    DuAn_NQL_1 as d,
    PhanCong_NV_1 as p
Where
    e.MãNV = p.MãNV
    and d.MãDA = p.MãDA
GROUP BY
    d.TênDA
UNION
SELECT
    d.TênDA,
    COUNT(E.MãNV)
FROM
    NhanVien_BP_2 as e,
    DuAn_NQL_2 as d,
    PhanCong_NV_2 as p
Where
    e.MãNV = p.MãNV
    and d.MãDA = p.MãDA
GROUP BY
    d.TênDA
END
Go
    EXEC DanhSachNhanVienDAMuc2 -- 7. Thêm dữ liệu vào bảng người quản lý 100, Trần Văn, Hùng, P1 và 200,Lê Thị, Hồng, P2
    -- Mức 1:
    CREATE PROC ThemNguoiQLMuc1 (
        @ma int,
        @ho nvarchar(50),
        @ten nvarchar(50),
        @phong nvarchar(50)
    ) AS BEGIN
INSERT INTO
    NgườiQuảnLý (MãNQL, Họ, Tên, TênPhòng)
values
    (@ma, @ho, @ten, @phong)
END
Go
    EXEC ThemNguoiQLMuc1 100,
    N'Trần Văn',
    N'Hùng',
    N'P1' EXEC ThemNguoiQLMuc1 200,
    N'Lê Thị',
    N'Hồng',
    N'P2'
SELECT
    *
FROM
    NgườiQuảnLý -- Mức 2:
    CREATE PROC ThemNguoiQLMuc2 (
        @ma int,
        @ho nvarchar(50),
        @ten nvarchar(50),
        @phong nvarchar(50)
    ) AS BEGIN if (@phong = N'P1')
INSERT INTO
    QuanLyP1(MãNQL, Họ, Tên, TênPhòng)
values
    (@ma, @ho, @ten, @phong) if (@phong = N'P2')
INSERT INTO
    QuanLyP2 (MãNQL, Họ, Tên, TênPhòng)
values
    (@ma, @ho, @ten, @phong)
END
Go
    EXEC ThemNguoiQLMuc2 100,
    N'Trần Văn',
    N'Hùng',
    N'P1' EXEC ThemNguoiQLMuc2 200,
    N'Lê Thị',
    N'Hồng',
    N'P2'
SELECT
    *
FROM
    QuanLyP1
SELECT
    *
FROm
    QuanLyP2 -- 8. Sửa dữ liệu ở bảng người quản lý biết mã NQL
    -- Mức 1:
    CREATE PROC SuaNguoiQLMuc1 (
        @ma int,
        @ho nvarchar(50),
        @ten nvarchar(50),
        @phong nvarchar(50)
    ) AS BEGIN
UPDATE
    NgườiQuảnLý
SET
    Họ = @ho,
    Tên = @ten,
    TênPhòng = @phong
Where
    MãNQL = @ma
END
GO
    EXEC SuaNguoiQLMuc1 100,
    N'Hồ Thanh',
    N'Tùng',
    N'P2' EXEC SuaNguoiQLMuc1 200,
    N'Trần Thị',
    N'Điệp',
    N'P1'
SELECT
    *
FROM
    NgườiQuảnLý -- MỨc 2:
    CREATE PROC SuaNguoiQLMuc2 (
        @ma int,
        @ho nvarchar(50),
        @ten nvarchar(50),
        @phong nvarchar(50)
    ) AS BEGIN
UPDATE
    QuanLyP1
SET
    Họ = @ho,
    Tên = @ten,
    TênPhòng = @phong
Where
    MãNQL = @ma if (@ @ROWCOUNT = 1) Begin if (@phong = N'P2') BEGIN
INSERT INTO
    QuanLyP2
SELECT
    *
FROM
    QuanLyP1
Where
    MãNQL = @ma
DELETE FROM
    QuanLyP1
Where
    MãNQL = @ma
END RETURN
END
UPDATE
    QuanLyP2
SET
    Họ = @ho,
    Tên = @ten,
    TênPhòng = @phong
Where
    MãNQL = @ma if (@ @ROWCOUNT = 1) if (@phong = N'P1') BEGIN
INSERT INTO
    QuanLyP1
SELECT
    *
FROM
    QuanLyP2
Where
    MãNQL = @ma
DELETE FROM
    QuanLyP2
Where
    MãNQL = @ma
END
END
GO
    EXEC SuaNguoiQLMuc2 100,
    N'Hồ Thanh',
    N'Tùng',
    N'P2' EXEC SuaNguoiQLMuc2 200,
    N'Trần Thị',
    N'Điệp',
    N'P1'
SELECT
    *
FROM
    QuanLyP1
SELECT
    *
FROM
    QuanLyP2 -- 9. XÓa dữ liệu bảng người quản lý
    -- Mức 1
    CREATE PROC XoaNguoiQLMuc1 (@ma int) AS BEGIN
DELETE FROM
    NgườiQuảnLý
WHERE
    MãNQL = @ma
END
GO
    EXEC XoaNguoiQLMuc1 100 EXEC XoaNguoiQLMuc1 200
SELECT
    *
FROm
    NgườiQuảnLý -- Mức 2:
    CREATE PROC XoaNguoiQLMuc2 (@ma int) AS BEGIN
DELETE FROM
    QuanLyP1
WHERE
    MãNQL = @ma
DELETE FROM
    QuanLyP2
WHERE
    MãNQL = @ma
END
GO
    EXEC XoaNguoiQLMuc2 100 EXEC XoaNguoiQLMuc2 200