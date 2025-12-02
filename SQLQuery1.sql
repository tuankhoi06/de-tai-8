USE [Quanlybenhvien]
GO
/****** Object:  Table [dbo].[BENHNHAN]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BENHNHAN](
	[MaBenhNhan] [int] NOT NULL,
	[HoTen] [nvarchar](255) NULL,
	[NgaySinh] [date] NULL,
	[GioiTinh] [char](1) NULL,
	[DiaChi] [nvarchar](255) NULL,
	[SoDienThoai] [varchar](15) NULL,
	[TrangThaiBenhNhan] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaBenhNhan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BACSI]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BACSI](
	[MaBacSi] [int] NOT NULL,
	[HoTen] [nvarchar](255) NULL,
	[NgaySinh] [date] NULL,
	[GioiTinh] [char](1) NULL,
	[DiaChi] [nvarchar](255) NULL,
	[ChuyenKhoa] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaBacSi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PHONGKHAM]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PHONGKHAM](
	[MaPhong] [int] NOT NULL,
	[TenPhong] [nvarchar](255) NULL,
	[ChuyenKhoa] [nvarchar](100) NULL,
	[TinhTrang] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaPhong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LICHKHAM]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LICHKHAM](
	[MaLichKham] [int] NOT NULL,
	[MaBenhNhan] [int] NULL,
	[MaBacSi] [int] NULL,
	[MaPhong] [int] NULL,
	[NgayGioKham] [datetime] NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayCapNhat] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaLichKham] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_chitietlichkham]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW v_chitietdoituonglichkham AS
SELECT 
   l.MaLichKham,
    b.HoTen AS TenBenhNhan,
    bs.HoTen AS TenBacSi,
    pk.TenPhong AS TenPhongKham,
    l.NgayGioKham,
    l.TrangThai AS TrangThaiKham
FROM 
   LICHKHAM l
   JOIN 
   BENHNHAN b ON l.MaBenhNhan = b.MaBenhNhan
JOIN 
   BACSI bs ON l.MaBacSi = bs.MaBacSi
JOIN 
   PHONGKHAM pk ON l.MaPhong = pk.MaPhong;
GO
/****** Object:  View     Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW V_ChiTietDoiTuongBacsi AS
SELECT 
   bs.MaBacSi,
    bs.HoTen,
    bs.NgaySinh,
    bs.GioiTinh,
    bs.DiaChi,
    bs.ChuyenKhoa
FROM 
   BACSI bs;
GO

/****** Object:  View     Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW V_ThongTinPhongKham AS
SELECT 
   pk.MaPhong,
    pk.TenPhong,
    pk.ChuyenKhoa,
    pk.TinhTrang
FROM 
   PHONGKHAM pk;
GO
/****** Object:  View     Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW TrangThaiBenhNhan AS
SELECT 
   b.MaBenhNhan,
    b.HoTen,
    b.NgaySinh,
    b.GioiTinh,
    b.TrangThaiBenhNhan
FROM 
   BENHNHAN b;
GO
ALTER TABLE [dbo].[LICHKHAM]  WITH CHECK ADD FOREIGN KEY([MaBacSi])
REFERENCES [dbo].[BACSI] ([MaBacSi])
GO
ALTER TABLE [dbo].[LICHKHAM]  WITH CHECK ADD FOREIGN KEY([MaBenhNhan])
REFERENCES [dbo].[BENHNHAN] ([MaBenhNhan])
GO
ALTER TABLE [dbo].[LICHKHAM]  WITH CHECK ADD FOREIGN KEY([MaPhong])
REFERENCES [dbo].[PHONGKHAM] ([MaPhong])
GO
	
/****** Object:  StoredProcedure     Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE prc_TimKiemLichKham (@MaBenhNhan INT)
AS
BEGIN

	
	-- Lệnh SELECT truy vấn chi tiết lịch khám
	SELECT
    	l.MaLichKham,
    	b.HoTen AS TenBenhNhan,
    	bs.HoTen AS TenBacSi,
    	pk.TenPhong AS TenPhongKham,
    	l.NgayGioKham,
    	l.TrangThai
	FROM
    	LICHKHAM l
	JOIN
    	BENHNHAN b ON l.MaBenhNhan = b.MaBenhNhan
	JOIN
    	BACSI bs ON l.MaBacSi = bs.MaBacSi
	JOIN
    	PHONGKHAM pk ON l.MaPhong = pk.MaPhong
	WHERE
    	l.MaBenhNhan = @MaBenhNhan; -- Lọc theo Mã Bệnh nhân được truyền vào
END;
GO

-- ***** Object:  StoredProcedure
	CREATE OR ALTER PROCEDURE prc_Top5BacSiTieuBieu
AS
BEGIN
    SELECT TOP 5 
        bs.HoTen,
        bs.ChuyenKhoa,
        COUNT(lk.MaLichKham) AS SoLuongCaKham
    FROM 
        BACSI bs
    JOIN 
        LICHKHAM lk ON bs.MaBacSi = lk.MaBacSi
    WHERE 
        lk.TrangThai = N'Đã khám' -- Chỉ tính những ca đã hoàn thành
    GROUP BY 
        bs.HoTen, bs.ChuyenKhoa
    ORDER BY 
        SoLuongCaKham DESC;
END;
GO

	
/*triger one */
CREATE TRIGGER trg_ngay_capnhat_ngaykham
 ON LICHKHAM
 AFTER INSERT
 AS
 BEGIN
 	UPDATE LICHKHAM
 	SET NgayGioKham = SYSDATETIME()
 	WHERE MaLichKham = (SELECT MaLichKham FROM inserted);
 END;

/*triger two*/ 
CREATE TRIGGER trg_UpdatePhongKhamStatus
 ON LICHKHAM
 AFTER INSERT
 AS
 BEGIN
 	IF EXISTS (SELECT * FROM inserted)
 	BEGIN
     	UPDATE PHONGKHAM
     	SET TinhTrang = 'Đã có bệnh nhân'
     	WHERE MaPhong IN (SELECT MaPhong FROM inserted);
 	END
 END;

/*triger three*/
CREATE TRIGGER trg_UpdatePhongKhamStatus_Delete
 ON LICHKHAM
 AFTER DELETE
 AS
 BEGIN
 	IF EXISTS (SELECT * FROM deleted)
 	BEGIN
     	UPDATE PHONGKHAM
     	SET TinhTrang = 'Còn trống'
     	WHERE MaPhong IN (SELECT MaPhong FROM deleted);
 	END
 END;

/* */
CREATE TRIGGER trg_CreateTaoLichTaiKham
ON BENHNHAN
AFTER UPDATE
AS
BEGIN
    
    IF EXISTS (SELECT * FROM inserted WHERE TrangThaiBenhNhan = N'Đã khỏi bệnh')
    BEGIN
        DECLARE @MaBenhNhan INT;
        DECLARE @MaBacSi INT;
        
        SELECT @MaBenhNhan = MaBenhNhan FROM inserted;

        -- Lấy Bác sĩ từ lần khám GẦN NHẤT của bệnh nhân này
        SELECT TOP 1 @MaBacSi = MaBacSi 
        FROM LICHKHAM 
        WHERE MaBenhNhan = @MaBenhNhan 
        ORDER BY NgayGioKham DESC;

        -- Nếu tìm thấy bác sĩ cũ thì mới tạo lịch tái khám
        IF @MaBacSi IS NOT NULL
        BEGIN
            INSERT INTO LICHKHAM (MaBenhNhan, MaBacSi, MaPhong, NgayGioKham, TrangThai)
            VALUES 
            (
                @MaBenhNhan, 
                @MaBacSi, 
                1, 
                DATEADD(MONTH, 6, GETDATE()), 
                N'Chưa khám' 
            ); 
        END
    END
END;
GO


-- Thực nghiệm 8 câu 
-- Câu 1:
1. Danh sách bệnh nhân theo từng bác sĩ
	
SELECT bs.HoTen AS BacSi, bn.HoTen AS BenhNhan
FROM BacSi bs
JOIN LichKham lk ON bs.MaBacSi = lk.MaBacSi
JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
ORDER BY bs.HoTen, bn.HoTen;

-- Câu 2:
2. Danh sách lịch khám bệnh của bác sĩ theo ngày
	
SELECT bs.HoTen AS BacSi, bn.HoTen AS BenhNhan, lk.NgayGioKham, lk.TrangThai
FROM LichKham lk
JOIN BacSi bs ON lk.MaBacSi = bs.MaBacSi
JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
WHERE CAST(lk.NgayGioKham AS DATE) = '2025-11-10'
ORDER BY lk.NgayGioKham;

-- Câu 3: 
3. Thống kê số lượng bệnh nhân khám bệnh theo ngày/tháng
	
SELECT CAST(NgayGioKham AS DATE) AS Ngay, COUNT(DISTINCT MaBenhNhan) AS SoLuongBenhNhan
FROM LichKham
GROUP BY CAST(NgayGioKham AS DATE)
ORDER BY Ngay DESC;

-- Câu 4:

4. Tìm kiếm bệnh nhân đã khám bệnh trong tháng/năm
	
SELECT bn.HoTen, lk.NgayGioKham, lk.TrangThai
FROM LichKham lk
JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
WHERE MONTH(lk.NgayGioKham) = 11 AND YEAR(lk.NgayGioKham) = 2025
AND lk.TrangThai = N'Đã khám';

-- Câu 5:
5. Báo cáo danh sách bệnh nhân điều trị nội trú.
	
SELECT bn.HoTen, bn.TrangThaiBenhNhan
FROM BenhNhan bn
WHERE bn.TrangThaiBenhNhan = N'Đang điều trị';

-- Câu 6:
6. Quản lý lịch trực của bác sĩ theo chuyên khoa
	
SELECT 
    bs.HoTen AS TenBacSi,
    lk.NgayGioKham,      
    pk.TenPhong AS TenPhongKham
FROM 
    BACSI bs
JOIN 
    LICHKHAM lk ON bs.MaBacSi = lk.MaBacSi 
JOIN
    PHONGKHAM pk ON lk.MaPhong = pk.MaPhong 
WHERE 
    bs.ChuyenKhoa = N'Nhĩ khoa' 
ORDER BY 
    lk.NgayGioKham; 

-- Câu 7:
7. Tính tổng số lần khám bệnh của từng bác sĩ.
	
SELECT bs.HoTen, COUNT(lk.MaLichKham) AS SoLuongKham
FROM LichKham lk
JOIN BacSi bs ON lk.MaBacSi = bs.MaBacSi
GROUP BY bs.HoTen
ORDER BY SoLuongKham DESC;

-- Câu 8:
8. Danh sách bác sĩ có nhiều bệnh nhân nhất

SELECT TOP 1 WITH TIES 
    bs.HoTen, 
    COUNT(lk.MaLichKham) AS SoLuongBenhNhan
FROM 
    BACSI bs
JOIN 
    LICHKHAM lk ON bs.MaBacSi = lk.MaBacSi
GROUP BY 
    bs.MaBacSi, bs.HoTen 
ORDER BY 
    SoLuongBenhNhan DESC;







