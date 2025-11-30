Main Kere Hore 

Main Kere Hore merupakan aplikasi perangkat bergerak berbasis Flutter yang dikembangkan untuk memfasilitasi pengguna dalam menemukan penawaran diskon permainan video terbaik dari berbagai platform distribusi digital resmi (seperti Steam, Epic Games, GOG, dan lainnya) secara waktu nyata (real-time).

Aplikasi ini dilengkapi dengan fitur penyaringan data yang komprehensif dan sinkronisasi daftar keinginan (wishlist), sehingga pengguna dapat memantau penurunan harga maupun penawaran permainan gratis dengan lebih efisien.

Fitur Utama

Pencarian Penawaran (Discover Deals)
Memungkinkan pengguna menelusuri ribuan penawaran permainan video yang bersumber dari API CheapShark.

Filter Lanjutan
Menyediakan opsi penyaringan berdasarkan judul, genre (seperti Aksi, RPG, Strategi), serta persentase diskon yang diinginkan.

Mode Permainan Gratis
Fitur khusus untuk menampilkan daftar permainan yang sedang didiskon 100% (gratis) pada saat itu.

Sinkronisasi Daftar Keinginan (Wishlist)
Pengguna dapat menyimpan permainan favorit ke dalam basis data Supabase. Data ini tersinkronisasi secara otomatis antar perangkat.

Tema Tampilan
Mendukung Mode Gelap (Dark Mode) yang dioptimalkan untuk layar AMOLED (True Black) serta Mode Terang (Light Mode) demi kenyamanan visual pengguna.

Fleksibilitas Tata Letak
Pengguna dapat mengubah tampilan antarmuka antara Tampilan Daftar (List View) untuk informasi mendetail atau Tampilan Grid (Grid View) untuk tampilan yang lebih ringkas.

Autentikasi Pengguna
Sistem pendaftaran dan masuk yang aman menggunakan verifikasi surel melalui Supabase Auth.

Teknologi yang Digunakan

Frontend: Flutter (Dart)

Backend & Basis Data: Supabase (PostgreSQL + Auth)

Integrasi API:

CheapShark API (Penyedia Data Diskon)

Steam Store API (Validasi Genre Permainan)

Manajemen State: Native setState & ValueNotifier

Konektivitas: Paket http
