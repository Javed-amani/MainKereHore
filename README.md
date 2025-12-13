# Main Kere Hore

**Main Kere Hore** merupakan aplikasi mobile berbasis **Flutter** yang membantu pengguna menemukan penawaran diskon game terbaik dari platform resmi seperti **Steam**, **Epic Games**, dan **GOG**. Informasi diperbarui secara **real time** untuk memudahkan pemantauan perubahan harga.

Aplikasi ini menyediakan **fitur filter lengkap** dan **sinkronisasi wishlist**, sehingga pengguna bisa mengikuti penurunan harga serta penawaran game gratis dengan lebih efisien.

---

## Fitur Utama

### **Pencarian Penawaran (Discover Deals)**
Menelusuri penawaran game melalui **API CheapShark**.

### **Filter Lanjutan**
Penyaringan berdasarkan:
- Judul
- Genre (Action, RPG, Strategy, dll.)
- Persentase diskon

### **Mode Game Gratis**
Menampilkan daftar game yang sedang digratiskan.

### **Sinkronisasi Wishlist**
Menyimpan game favorit ke **Supabase**, dengan sinkronisasi otomatis ke semua perangkat.

### **Tema Tampilan**
- Dark Mode (optimal untuk AMOLED)
- Light Mode

### **Fleksibilitas Tampilan**
- **List View** untuk detail lengkap
- **Grid View** untuk tampilan lebih ringkas

### **Autentikasi Pengguna**
Login dan daftar menggunakan verifikasi email melalui **Supabase Auth**.

---

## Teknologi yang Digunakan

- **Frontend:** Flutter (Dart)
- **Backend & Database:** Supabase (PostgreSQL, Auth)
- **Integrasi API:**
  - CheapShark API (diskon)
  - Steam Store API (validasi genre)
- **Manajemen State:** `setState`, `ValueNotifier`
- **Konektivitas:** `http` package

---

## Tampilan Aplikasi

Berikut beberapa tampilan utama dari aplikasi **Main Kere Hore**:

### Login
![Login](lib/images/login.png)

### Register
![Register](lib/images/register.png)

### Pencarian Game
![Search](lib/images/search.png)

### Wishlist
![Wishlist](lib/images/wishlist.png)

### List View
![List View](lib/images/listview.png)

### Grid View
![Grid View](lib/images/gridview.png)
