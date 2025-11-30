Main Kere Hore

Main Kere Hore adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna menemukan penawaran diskon game terbaik dari berbagai platform distribusi digital resmi seperti Steam, Epic Games, dan GOG. Informasi diperbarui secara waktu nyata sehingga pengguna bisa memantau perubahan harga dengan cepat.

Aplikasi ini menyediakan fitur penyaringan data yang lengkap serta sinkronisasi wishlist, sehingga pengguna dapat mengikuti penurunan harga dan penawaran game gratis dengan lebih efisien.

Fitur Utama

Pencarian Penawaran (Discover Deals)
Pengguna dapat menjelajahi ribuan penawaran game yang tersedia melalui API CheapShark.

Filter Lanjutan
Tersedia penyaringan berdasarkan judul, genre seperti aksi, RPG, atau strategi, serta persentase diskon yang diinginkan.

Mode Game Gratis
Fitur khusus yang menampilkan daftar game yang sedang digratiskan.

Sinkronisasi Wishlist
Pengguna dapat menyimpan game favorit ke dalam basis data Supabase. Data ini akan tersinkronisasi otomatis di semua perangkat.

Tema Tampilan
Aplikasi mendukung Dark Mode yang dioptimalkan untuk layar AMOLED dan Light Mode untuk penggunaan di berbagai kondisi.

Fleksibilitas Tampilan
Pengguna dapat memilih antara List View untuk informasi yang lebih lengkap atau Grid View untuk tampilan yang lebih ringkas.

Autentikasi Pengguna
Proses daftar dan masuk menggunakan verifikasi email melalui Supabase Auth agar tetap aman.

Teknologi yang Digunakan

Frontend: Flutter (Dart)

Backend dan Basis Data: Supabase (PostgreSQL dan Auth)

Integrasi API:

CheapShark API (data diskon)

Steam Store API (validasi genre)

Manajemen State: setState dan ValueNotifier

Konektivitas: http package
