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
CREATE VIEW [dbo].[v_chitietlichkham] AS
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
/****** Object:  View [dbo].[v_chitietbacsi]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_chitietbacsi] AS
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
/****** Object:  View [dbo].[v_phongkham]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_phongkham] AS
SELECT 
   pk.MaPhong,
    pk.TenPhong,
    pk.ChuyenKhoa,
    pk.TinhTrang
FROM 
   PHONGKHAM pk;
GO
/****** Object:  View [dbo].[v_benhnhan_status]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_benhnhan_status] AS
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
/****** Object:  StoredProcedure [dbo].[prc_TimKiemLichKham]    Script Date: 11/7/2025 10:10:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[prc_TimKiemLichKham] (@MaBenhNhan INT)
AS
BEGIN
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
       l.MaBenhNhan = @MaBenhNhan;
END;
GO

SELECT * FROM v_chitietlichkham;

/*triger one */
CREATE TRIGGER trg_UpdateTrangThaiBenhNhan
ON BENHNHAN
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE TrangThaiBenhNhan = 'Đã khỏi bệnh')
    BEGIN
        -- Cập nhật trạng thái bệnh nhân khi thay đổi sang "Đã khỏi bệnh"
        UPDATE BENHNHAN
        SET TrangThaiBenhNhan = 'Đã khỏi bệnh'
        WHERE MaBenhNhan IN (SELECT MaBenhNhan FROM inserted);
    END
END;
/*triger two*/ 
CREATE TRIGGER trg_UpdatePhongKhamStatus
ON LICHKHAM
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Cập nhật trạng thái phòng khám khi có bệnh nhân
        UPDATE PHONGKHAM
        SET TinhTrang = 'Đã có bệnh nhân'
        WHERE MaPhong IN (SELECT MaPhong FROM inserted);
    END
END;
/*triger three*/
CREATE TRIGGER trg_UpdatePhongKhamStatusAfterPayment
ON LICHKHAM
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE TrangThai = 'Đã thanh toán')
    BEGIN
        -- Cập nhật lại trạng thái phòng sau khi thanh toán
        UPDATE PHONGKHAM
        SET TinhTrang = 'Còn trống'
        WHERE MaPhong IN (SELECT MaPhong FROM inserted);
    END
END;
/* */
CREATE TRIGGER trg_UpdateLichKhamInfo
ON LICHKHAM
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Cập nhật lại các thông tin lịch khám nếu có sự thay đổi
        UPDATE LICHKHAM
        SET NgayGioKham = (SELECT NgayGioKham FROM inserted)
        WHERE MaLichKham IN (SELECT MaLichKham FROM inserted);
    END
END;
 
