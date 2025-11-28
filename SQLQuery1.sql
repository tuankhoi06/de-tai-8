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
    IF EXISTS (SELECT * FROM inserted WHERE TrangThaiBenhNhan = 'Đã khỏi bệnh')
    BEGIN
        -- Thêm lịch khám mới khi bệnh nhân khỏi bệnh
        INSERT INTO LICHKHAM (MaBenhNhan, MaBacSi, MaPhong, NgayGioKham, TrangThai)
        VALUES 
        ((SELECT MaBenhNhan FROM inserted),  -- MaBenhNhan từ bảng inserted
         (SELECT MaBacSi FROM LICHKHAM WHERE MaBenhNhan = (SELECT MaBenhNhan FROM inserted)), -- Lấy MaBacSi từ LICHKHAM
         'MaPhong',  -- Bạn cần thay thế 'MaPhong' bằng giá trị thực tế
         DATEADD(MONTH, 6, SYSDATETIME()), 'Chưa khám');  -- Ngày tái khám
    END
END;


