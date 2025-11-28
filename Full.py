import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime, timedelta
import pyodbc
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

# ==================== KẾT NỐI SQL ====================
connection_string = 'Driver={SQL Server};Server=LAPTOP-JINK9QGU;Database=Quanlybenhvien;UID=huy;PWD=123;'

def get_conn():
    return pyodbc.connect(connection_string)

def execute_query(query, params=None, fetch=False):
    conn = get_conn()
    cursor = conn.cursor()
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        if fetch:
            result = cursor.fetchall()
            conn.commit()
            return result
        else:
            conn.commit()
    except Exception as e:
        messagebox.showerror("Lỗi cơ sở dữ liệu", str(e))
    finally:
        cursor.close()
        conn.close()

def rows_to_list(rows):
    return [tuple(row) for row in rows]

# ==================== TỰ ĐỘNG SINH MÃ ====================
def get_next_id(table, column):
    try:
        result = execute_query(f"SELECT MAX({column}) FROM {table}", fetch=True)
        max_id = result[0][0]
        return (max_id or 0) + 1
    except:
        return 1

# ==================== ỨNG DỤNG CHÍNH ====================
class HospitalApp:
    def __init__(self, root):
        self.root = root
        self.root.title("HỆ THỐNG QUẢN LÝ BỆNH VIỆN")
        self.root.geometry("1400x800")
        self.root.state('zoomed')

        self.create_menu()
        self.container = tk.Frame(self.root)
        self.container.pack(fill="both", expand=True, padx=10, pady=10)

        self.frames = {}
        for F in ( Dashboard, BenhNhanForm, BacSiForm, PhongKhamForm,
                  LichKhamForm, TraCuuForm, BaoCaoForm):
            page_name = F.__name__
            frame = F(parent=self.container, controller=self)
            self.frames[page_name] = frame
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame("Dashboard")

    def show_frame(self, page_name):
        frame = self.frames[page_name]
        frame.tkraise()
        if hasattr(frame, 'refresh'):
            frame.refresh()

    def create_menu(self):
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Menu", menu=menu)
        menu.add_command(label="Dashboard", command=lambda: self.show_frame("Dashboard"))
        menu.add_command(label="Quản lý Bệnh nhân", command=lambda: self.show_frame("BenhNhanForm"))
        menu.add_command(label="Quản lý Bác sĩ", command=lambda: self.show_frame("BacSiForm"))
        menu.add_command(label="Quản lý Phòng khám", command=lambda: self.show_frame("PhongKhamForm"))
        menu.add_command(label="Đặt lịch khám", command=lambda: self.show_frame("LichKhamForm"))
        menu.add_command(label="Tra cứu lịch", command=lambda: self.show_frame("TraCuuForm"))
        menu.add_command(label="Báo cáo", command=lambda: self.show_frame("BaoCaoForm"))
        menu.add_separator()
        menu.add_command(label="Thoát", command=self.root.quit)

# ==================== DASHBOARD ====================
class Dashboard(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.configure(bg="#f0f4f8")

        try:
            from PIL import Image, ImageTk
            logo_img = Image.open("cmc_logo.png")
            logo_img = logo_img.resize((280, 180), Image.Resampling.LANCZOS)
            self.logo = ImageTk.PhotoImage(logo_img)
            tk.Label(self, image=self.logo, bg="#f0f4f8").pack(pady=(30, 10))
        except:
            tk.Label(self, text="CMC UNIVERSITY", font=("Helvetica", 32, "bold"), fg="#007acc", bg="#f0f4f8").pack(pady=(30, 5))
            tk.Label(self, text="Aspire to Inspire the Digital World", font=("Helvetica", 14), fg="#555", bg="#f0f4f8").pack(pady=(0, 20))

        # === 4 Ô SỐ LIỆU – CĂN GIỮA TOÀN MÀN HÌNH ===
        stats_container = tk.Frame(self, bg="#f0f4f8")
        stats_container.pack(expand=True, fill="both")  # QUAN TRỌNG: fill="both"

        self.stats_frame = tk.Frame(stats_container, bg="#f0f4f8")
        self.stats_frame.pack(expand=True)  # expand=True → chiếm hết chiều ngang

        self.labels = []
        stats_info = [
            ("Số bệnh nhân hiện tại", "dodgerblue"),
            ("Số bác sĩ", "green"),
            ("Số phòng khám", "orange"),
            ("Lịch khám hôm nay", "red")
        ]

        for text, color in stats_info:
            frame = tk.Frame(self.stats_frame, bg="white", relief="solid", bd=2, padx=45, pady=35)
            frame.pack(side="left", padx=50)  # padx lớn hơn để cân đối
            tk.Label(frame, text=text, font=("Helvetica", 14), bg="white", fg="#333").pack()
            num_label = tk.Label(frame, text="0", font=("Helvetica", 52, "bold"), bg="white", fg=color)
            num_label.pack()
            self.labels.append(num_label)

        # === MENU DƯỚI CÙNG – CĂN GIỮA ===
        menu_frame = tk.Frame(self, bg="#f0f4f8")
        menu_frame.pack(side="bottom", pady=40, fill="x")  # fill="x" để full chiều ngang

        inner_menu = tk.Frame(menu_frame, bg="#f0f4f8")
        inner_menu.pack(expand=True)

        menu_buttons = [
            ("Quản lý Bệnh nhân", "BenhNhanForm"),
            ("Quản lý Bác sĩ", "BacSiForm"),
            ("Quản lý Phòng khám", "PhongKhamForm"),
            ("Đặt lịch khám", "LichKhamForm"),
            ("Tra cứu lịch", "TraCuuForm"),
            ("Báo cáo", "BaoCaoForm")
        ]

        for text, page in menu_buttons:
            btn = tk.Button(inner_menu, text=text, font=("Helvetica", 12, "bold"),
                           bg="#007acc", fg="white", width=18, height=2,
                           relief="flat", bd=0, highlightthickness=0,
                           command=lambda p=page: controller.show_frame(p))
            btn.pack(side="left", padx=20)


            def hover_enter(e, b=btn): b.config(bg="#005a99")
            def hover_leave(e, b=btn): b.config(bg="#007acc")
            btn.bind("<Enter>", hover_enter)
            btn.bind("<Leave>", hover_leave)

    def refresh(self):
        so_bn = len(rows_to_list(execute_query("SELECT * FROM BenhNhan", fetch=True)))
        so_bs = len(rows_to_list(execute_query("SELECT * FROM BacSi", fetch=True)))
        so_phong = len(rows_to_list(execute_query("SELECT * FROM PhongKham", fetch=True)))
        so_lich_today = len(rows_to_list(execute_query("SELECT * FROM LichKham WHERE CAST(NgayGioKham AS DATE) = CAST(GETDATE() AS DATE)", fetch=True)))

        values = [so_bn, so_bs, so_phong, so_lich_today]
        for label, val in zip(self.labels, values):
            label.config(text=str(val))

# ==================== QUẢN LÝ BỆNH NHÂN ====================
class BenhNhanForm(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        tk.Label(self, text="QUẢN LÝ BỆNH NHÂN", font=("Helvetica", 20, "bold")).pack(pady=10)
        btns = tk.Frame(self); btns.pack(pady=10)
        tk.Button(btns, text="Thêm", command=self.them, bg="lightgreen").pack(side="left", padx=5)
        tk.Button(btns, text="Sửa", command=self.sua, bg="lightblue").pack(side="left", padx=5)
        tk.Button(btns, text="Xóa", command=self.xoa, bg="salmon").pack(side="left", padx=5)

        cols = ("MaBenhNhan", "HoTen", "NgaySinh", "GioiTinh", "SoDienThoai", "TrangThaiBenhNhan")
        self.tree = ttk.Treeview(self, columns=cols, show="headings")
        for col, text in zip(cols, ["Mã BN", "Họ tên", "Ngày sinh", "Giới tính", "SĐT", "Trạng thái"]):
            self.tree.heading(col, text=text); self.tree.column(col, width=150, anchor="center")
        self.tree.pack(fill="both", expand=True, padx=10, pady=10)
        self.tree.bind("<Double-1>", lambda e: self.sua())

    def refresh(self):
        for i in self.tree.get_children(): self.tree.delete(i)
        data = rows_to_list(execute_query("SELECT MaBenhNhan, HoTen, NgaySinh, GioiTinh, SoDienThoai, TrangThaiBenhNhan FROM BenhNhan ORDER BY MaBenhNhan", fetch=True))
        for row in data: self.tree.insert("", "end", values=row)

    def them(self): self.open_dialog("Thêm bệnh nhân", True)
    def sua(self):
        sel = self.tree.selection()
        if not sel: return messagebox.showwarning("Chọn", "Chọn bệnh nhân!")
        values = self.tree.item(sel[0], "values")
        self.open_dialog("Sửa bệnh nhân", False, values)

    def xoa(self):
        sel = self.tree.selection()
        if not sel: return
        if messagebox.askyesno("Xác nhận", "Xóa bệnh nhân này?"):
            ma = self.tree.item(sel[0], "values")[0]
            execute_query("DELETE FROM BenhNhan WHERE MaBenhNhan=?", (ma,))
            self.refresh()

    def open_dialog(self, title, is_add, data=None):
        dialog = tk.Toplevel(self); dialog.title(title); dialog.geometry("420x520"); dialog.grab_set()
        labels = ["Họ tên", "Ngày sinh (YYYY-MM-DD)", "Giới tính (M/F)", "Địa chỉ", "SĐT", "Trạng thái"]
        entries = []
        for i, label in enumerate(labels):
            tk.Label(dialog, text=label + ":").grid(row=i, column=0, sticky="w", padx=20, pady=12)
            e = tk.Entry(dialog, width=35); e.grid(row=i, column=1, padx=20, pady=12)
            if not is_add and data: e.insert(0, data[i+1] if i < 5 else data[i])
            entries.append(e)

        def save():
            vals = [e.get().strip() for e in entries]
            if not all(vals): return messagebox.showerror("Lỗi", "Điền đầy đủ!")
            if is_add:
                ma = get_next_id("BenhNhan", "MaBenhNhan")
                execute_query("INSERT INTO BenhNhan VALUES (?, ?, ?, ?, ?, ?, ?)", (ma, *vals))
                messagebox.showinfo("Thành công", f"Thêm thành công! Mã BN: {ma}")
            else:
                ma = data[0]
                execute_query("UPDATE BenhNhan SET HoTen=?, NgaySinh=?, GioiTinh=?, DiaChi=?, SoDienThoai=?, TrangThaiBenhNhan=? WHERE MaBenhNhan=?", (*vals, ma))
            self.refresh(); dialog.destroy()

        tk.Button(dialog, text="Lưu", command=save, bg="lightgreen", font=12, width=15).grid(row=6, column=0, columnspan=2, pady=25)

# ==================== QUẢN LÝ BÁC SĨ====================
class BacSiForm(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        tk.Label(self, text="QUẢN LÝ BÁC SĨ", font=("Helvetica", 20, "bold")).pack(pady=10)
        btns = tk.Frame(self); btns.pack(pady=10)
        tk.Button(btns, text="Thêm", command=self.them, bg="lightgreen").pack(side="left", padx=5)
        tk.Button(btns, text="Sửa", command=self.sua, bg="lightblue").pack(side="left", padx=5)
        tk.Button(btns, text="Xóa", command=self.xoa, bg="salmon").pack(side="left", padx=5)

        # BỎ CỘT SĐT
        cols = ("MaBacSi", "HoTen", "ChuyenKhoa")
        self.tree = ttk.Treeview(self, columns=cols, show="headings")
        self.tree.heading("MaBacSi", text="Mã BS")
        self.tree.heading("HoTen", text="Họ tên")
        self.tree.heading("ChuyenKhoa", text="Chuyên khoa")
        for col in cols:
            self.tree.column(col, width=200, anchor="center")
        self.tree.pack(fill="both", expand=True, padx=10, pady=10)
        self.tree.bind("<Double-1>", lambda e: self.sua())

    def refresh(self):
        for i in self.tree.get_children():
            self.tree.delete(i)
        data = rows_to_list(execute_query("SELECT MaBacSi, HoTen, ChuyenKhoa FROM BacSi ORDER BY MaBacSi", fetch=True))
        for row in data:
            self.tree.insert("", "end", values=row)

    def them(self):
        self.open_dialog("Thêm bác sĩ", True)

    def sua(self):
        sel = self.tree.selection()
        if not sel:
            return messagebox.showwarning("Chọn", "Vui lòng chọn bác sĩ!")
        values = self.tree.item(sel[0], "values")
        self.open_dialog("Sửa bác sĩ", False, values)

    def xoa(self):
        sel = self.tree.selection()
        if sel and messagebox.askyesno("Xóa", "Xóa bác sĩ này?"):
            ma = self.tree.item(sel[0], "values")[0]
            execute_query("DELETE FROM BacSi WHERE MaBacSi=?", (ma,))
            self.refresh()

    def open_dialog(self, title, is_add, data=None):
        dialog = tk.Toplevel(self)
        dialog.title(title)
        dialog.geometry("400x250")
        dialog.grab_set()

        # CHỈ CÒN 2 TRƯỜNG: HỌ TÊN + CHUYÊN KHOA
        labels = ["Họ tên", "Chuyên khoa"]
        entries = []
        for i, label in enumerate(labels):
            tk.Label(dialog, text=label + ":").grid(row=i, column=0, padx=20, pady=20, sticky="w")
            e = tk.Entry(dialog, width=30)
            e.grid(row=i, column=1, padx=20, pady=20)
            if not is_add and data:
                e.insert(0, data[i+1])
            entries.append(e)

        def save():
            vals = [e.get().strip() for e in entries]
            if not all(vals):
                return messagebox.showerror("Lỗi", "Vui lòng điền đầy đủ!")

            if is_add:
                ma = get_next_id("BacSi", "MaBacSi")
                # CHỈ TRUYỀN 3 GIÁ TRỊ: MaBacSi, HoTen, ChuyenKhoa
                execute_query("INSERT INTO BacSi (MaBacSi, HoTen, ChuyenKhoa) VALUES (?, ?, ?)",
                              (ma, vals[0], vals[1]))
                messagebox.showinfo("Thành công", f"Thêm bác sĩ thành công! Mã BS: {ma}")
            else:
                ma = data[0]
                execute_query("UPDATE BacSi SET HoTen=?, ChuyenKhoa=? WHERE MaBacSi=?",
                              (vals[0], vals[1], ma))

            self.refresh()
            dialog.destroy()

        tk.Button(dialog, text="Lưu", command=save, bg="lightgreen", font=("Helvetica", 11, "bold"), width=12).grid(row=2, column=0, columnspan=2, pady=20)
# ==================== QUẢN LÝ PHÒNG KHÁM (ĐÃ SỬA) ====================
class PhongKhamForm(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        tk.Label(self, text="QUẢN LÝ PHÒNG KHÁM", font=("Helvetica", 20, "bold")).pack(pady=10)
        btns = tk.Frame(self); btns.pack(pady=10)
        tk.Button(btns, text="Thêm phòng", command=self.them, bg="lightgreen").pack(side="left", padx=5)
        tk.Button(btns, text="Sửa phòng", command=self.sua, bg="lightblue").pack(side="left", padx=5)
        tk.Button(btns, text="Xóa phòng", command=self.xoa, bg="salmon").pack(side="left", padx=5)

        cols = ("MaPhong", "TenPhong", "ChuyenKhoa", "TinhTrang")
        self.tree = ttk.Treeview(self, columns=cols, show="headings")
        for col, text in zip(cols, ["Mã phòng", "Tên phòng", "Chuyên khoa", "Tình trạng"]):
            self.tree.heading(col, text=text); self.tree.column(col, width=180, anchor="center")
        self.tree.pack(fill="both", expand=True, padx=10)

    def refresh(self):
        for i in self.tree.get_children(): self.tree.delete(i)
        data = rows_to_list(execute_query("SELECT MaPhong, TenPhong, ChuyenKhoa, TinhTrang FROM PhongKham ORDER BY MaPhong", fetch=True))
        for row in data: self.tree.insert("", "end", values=row)

    def them(self): self.open_dialog("Thêm phòng", True)
    def sua(self):
        sel = self.tree.selection()
        if not sel: return messagebox.showwarning("Chọn", "Chọn phòng!")
        values = self.tree.item(sel[0], "values")
        self.open_dialog("Sửa phòng", False, values)

    def xoa(self):
        sel = self.tree.selection()
        if sel and messagebox.askyesno("Xóa", "Xóa phòng?"):
            ma = self.tree.item(sel[0], "values")[0]
            execute_query("DELETE FROM PhongKham WHERE MaPhong=?", (ma,))
            self.refresh()

    def open_dialog(self, title, is_add, data=None):
        dialog = tk.Toplevel(self); dialog.title(title); dialog.geometry("400x300"); dialog.grab_set()
        labels = ["Tên phòng", "Chuyên khoa", "Tình trạng"]
        entries = []
        for i, label in enumerate(labels):
            tk.Label(dialog, text=label + ":").grid(row=i, column=0, padx=20, pady=15, sticky="w")
            e = tk.Entry(dialog, width=30); e.grid(row=i, column=1, padx=20, pady=15)
            if not is_add and data: e.insert(0, data[i+1])
            entries.append(e)

        def save():
            vals = [e.get().strip() for e in entries]
            if not all(vals): return messagebox.showerror("Lỗi", "Điền đầy đủ!")
            if is_add:
                ma = get_next_id("PhongKham", "MaPhong")
                execute_query("INSERT INTO PhongKham VALUES (?, ?, ?, ?)", (ma, *vals))
                messagebox.showinfo("Thành công", f"Thêm phòng thành công! Mã phòng: {ma}")
            else:
                ma = data[0]
                execute_query("UPDATE PhongKham SET TenPhong=?, ChuyenKhoa=?, TinhTrang=? WHERE MaPhong=?", (*vals, ma))
            self.refresh(); dialog.destroy()

        tk.Button(dialog, text="Lưu", command=save, bg="lightgreen", font=12, width=12).grid(row=3, column=0, columnspan=2, pady=20)

# ==================== ĐẶT LỊCH KHÁM (ĐÃ SỬA MALICHKHAM) ====================
class LichKhamForm(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        tk.Label(self, text="ĐẶT LỊCH KHÁM", font=("Helvetica", 20, "bold")).pack(pady=20)
        form = tk.Frame(self); form.pack(pady=10)
        tk.Label(form, text="Bệnh nhân:").grid(row=0, column=0, sticky="w")
        self.cb_bn = ttk.Combobox(form, width=50); self.cb_bn.grid(row=0, column=1, padx=10)
        tk.Label(form, text="Bác sĩ:").grid(row=1, column=0, sticky="w")
        self.cb_bs = ttk.Combobox(form, width=50); self.cb_bs.grid(row=1, column=1, padx=10)
        tk.Label(form, text="Phòng:").grid(row=2, column=0, sticky="w")
        self.cb_phong = ttk.Combobox(form, width=50); self.cb_phong.grid(row=2, column=1, padx=10)
        tk.Label(form, text="Ngày giờ (YYYY-MM-DD HH:MM):").grid(row=3, column=0, sticky="w")
        self.entry_time = tk.Entry(form, width=53); self.entry_time.grid(row=3, column=1, padx=10)
        self.entry_time.insert(0, (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d 08:00"))

        tk.Button(form, text="ĐẶT LỊCH", command=self.dat_lich, bg="gold", font=("Helvetica", 12, "bold"), width=20).grid(row=4, column=0, columnspan=2, pady=20)

        cols = ("MaLichKham", "BenhNhan", "BacSi", "Phong", "ThoiGian", "TrangThai")
        self.tree = ttk.Treeview(self, columns=cols, show="headings")
        for col, text in zip(cols, ["Mã lịch", "Bệnh nhân", "Bác sĩ", "Phòng", "Thời gian", "Trạng thái"]):
            self.tree.heading(col, text=text); self.tree.column(col, width=180)
        self.tree.pack(fill="both", expand=True, padx=10)

    def refresh(self):
        self.load_combobox()
        for i in self.tree.get_children(): self.tree.delete(i)
        data = rows_to_list(execute_query("""
            SELECT lk.MaLichKham, bn.HoTen, bs.HoTen, pk.TenPhong, CONVERT(varchar, lk.NgayGioKham, 120), lk.TrangThai
            FROM LichKham lk
            JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
            JOIN BacSi bs ON lk.MaBacSi = bs.MaBacSi
            JOIN PhongKham pk ON lk.MaPhong = pk.MaPhong
            ORDER BY lk.NgayGioKham DESC
        """, fetch=True))
        for row in data: self.tree.insert("", "end", values=row)

    def load_combobox(self):
        bn = rows_to_list(execute_query("SELECT MaBenhNhan, HoTen FROM BenhNhan", fetch=True))
        self.cb_bn['values'] = [f"{id} - {name}" for id, name in bn]
        bs = rows_to_list(execute_query("SELECT MaBacSi, HoTen FROM BacSi", fetch=True))
        self.cb_bs['values'] = [f"{id} - {name}" for id, name in bs]
        pk = rows_to_list(execute_query("SELECT MaPhong, TenPhong FROM PhongKham", fetch=True))
        self.cb_phong['values'] = [f"{id} - {name}" for id, name in pk]

    def dat_lich(self):
        try:
            ma_bn = int(self.cb_bn.get().split(" - ")[0])
            ma_bs = int(self.cb_bs.get().split(" - ")[0])
            ma_phong = int(self.cb_phong.get().split(" - ")[0])
            thoigian = self.entry_time.get()
            ma_lich = get_next_id("LichKham", "MaLichKham")
            execute_query("""
                INSERT INTO LichKham (MaLichKham, MaBenhNhan, MaBacSi, MaPhong, NgayGioKham, TrangThai)
                VALUES (?, ?, ?, ?, ?, N'Chưa khám')
            """, (ma_lich, ma_bn, ma_bs, ma_phong, thoigian))
            messagebox.showinfo("Thành công", f"Đặt lịch thành công! Mã lịch: {ma_lich}")
            self.refresh()
        except Exception as e:
            messagebox.showerror("Lỗi", "Vui lòng chọn đầy đủ thông tin!")

# ==================== TRA CỨU & BÁO CÁO (giữ nguyên) ====================
class TraCuuForm(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        tk.Label(self, text="TRA CỨU LỊCH KHÁM", font=("Helvetica", 20, "bold")).pack(pady=20)
        search = tk.Frame(self); search.pack(pady=10)
        tk.Label(search, text="Ngày (YYYY-MM-DD):").pack(side="left")
        self.entry_date = tk.Entry(search); self.entry_date.pack(side="left", padx=5)
        self.entry_date.insert(0, datetime.now().strftime("%Y-%m-%d"))
        tk.Button(search, text="Tìm", command=self.tim_kiem).pack(side="left", padx=10)

        cols = ("BN", "BS", "Phong", "ThoiGian", "TrangThai")
        self.tree = ttk.Treeview(self, columns=cols, show="headings")
        for col, text in zip(cols, ["Bệnh nhân", "Bác sĩ", "Phòng", "Thời gian", "Trạng thái"]):
            self.tree.heading(col, text=text); self.tree.column(col, width=200)
        self.tree.pack(fill="both", expand=True, padx=10)

    def tim_kiem(self):
        date = self.entry_date.get()
        for i in self.tree.get_children(): self.tree.delete(i)
        data = rows_to_list(execute_query("""
            SELECT bn.HoTen, bs.HoTen, pk.TenPhong, CONVERT(varchar, lk.NgayGioKham, 120), lk.TrangThai
            FROM LichKham lk
            JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
            JOIN BacSi bs ON lk.MaBacSi = bs.MaBacSi
            JOIN PhongKham pk ON lk.MaPhong = pk.MaPhong
            WHERE CAST(lk.NgayGioKham AS DATE) = ?
        """, (date,), fetch=True))
        for row in data: self.tree.insert("", "end", values=row)

class BaoCaoForm(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        tk.Label(self, text="BÁO CÁO & THỐNG KÊ", font=("Helvetica", 20, "bold")).pack(pady=30)
        btn = tk.Frame(self); btn.pack(pady=20)
        tk.Button(btn, text="Biểu đồ theo tháng", command=self.bieu_do_thang, bg="cyan", font=12).pack(side="left", padx=20)
        tk.Button(btn, text="Top 5 bác sĩ", command=self.top_bacsi, bg="lightpink", font=12).pack(side="left", padx=20)
        self.chart_frame = tk.Frame(self); self.chart_frame.pack(fill="both", expand=True)

    def bieu_do_thang(self):
        data = rows_to_list(execute_query("SELECT MONTH(NgayGioKham), COUNT(*) FROM LichKham WHERE YEAR(NgayGioKham)=YEAR(GETDATE()) GROUP BY MONTH(NgayGioKham) ORDER BY 1", fetch=True))
        if not data: return messagebox.showinfo("Thông báo", "Chưa có dữ liệu")
        thang, sl = zip(*data)
        for w in self.chart_frame.winfo_children(): w.destroy()
        fig, ax = plt.subplots(figsize=(8,5))
        ax.bar(thang, sl, color='skyblue')
        ax.set_title("Số lượt khám theo tháng"); ax.set_xlabel("Tháng"); ax.set_ylabel("Số lượt")
        canvas = FigureCanvasTkAgg(fig, self.chart_frame); canvas.draw(); canvas.get_tk_widget().pack(fill="both", expand=True)

    def top_bacsi(self):
        # Gọi Stored Procedure thay vì câu Select thường
        query = "{CALL prc_Top5BacSiTieuBieu}"

        # Nếu pyodbc không hỗ trợ CALL trực tiếp tuỳ driver, dùng EXEC:
        # query = "EXEC prc_Top5BacSiTieuBieu"

        try:
            data = rows_to_list(execute_query(query, fetch=True))

            if data:
                # Format hiển thị: Nguyễn Văn A (Khoa Nhi): 15 ca
                msg_list = [f"{i + 1}. {row[0]} ({row[1]}): {row[2]} ca" for i, row in enumerate(data)]
                msg = "\n".join(msg_list)
                messagebox.showinfo("Top 5 Bác sĩ tiêu biểu (Đã khám)", msg)
            else:
                messagebox.showinfo("Thông báo", "Chưa có dữ liệu bác sĩ nào hoàn thành ca khám.")

        except Exception as e:
            # Fallback nếu chưa tạo Procedure thì chạy câu lệnh thường
            data = rows_to_list(execute_query("""
                                              SELECT TOP 5 bs.HoTen, bs.ChuyenKhoa, COUNT(*)
                                              FROM LichKham lk
                                                       JOIN BacSi bs ON lk.MaBacSi = bs.MaBacSi
                                              WHERE lk.TrangThai = N'Đã khám'
                                              GROUP BY bs.HoTen, bs.ChuyenKhoa
                                              ORDER BY COUNT(*) DESC
                                              """, fetch=True))

            if data:
                msg_list = [f"{i + 1}. {row[0]} ({row[1]}): {row[2]} ca" for i, row in enumerate(data)]
                msg = "\n".join(msg_list)
                messagebox.showinfo("Top 5 Bác sĩ (Fallback)", msg)
            else:
                messagebox.showinfo("Thông báo", "Chưa có dữ liệu.")


# ==================== CHẠY CHƯƠNG TRÌNH ====================
if __name__ == "__main__":
    root = tk.Tk()
    app = HospitalApp(root)
    root.mainloop()
