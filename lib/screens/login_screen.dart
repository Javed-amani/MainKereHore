import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../utils/theme_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isLoginMode = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        await _authService.signIn(email, password);
      } else {
        await _authService.signUp(email, password);
        if (mounted) {
           _showDialog(
             title: 'Registrasi Berhasil',
             content: 'Silakan cek email Anda untuk verifikasi akun.',
           );
           setState(() => _isLoginMode = true);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        // --- CUSTOM ERROR MESSAGE (Biar gak bahasa Inggris default) ---
        String message = e.message;
        if (message.contains('Invalid login credentials')) {
          message = 'Email atau password salah.';
        } else if (message.contains('Email not confirmed')) {
          message = 'Email belum diverifikasi. Cek inbox anda.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan sistem'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final emailResetController = TextEditingController();
    
    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text('Reset Password', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Masukkan email akun Anda:', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800])),
              const SizedBox(height: 10),
              TextField(
                controller: emailResetController,
                decoration: const InputDecoration(hintText: 'Email'),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, emailResetController.text.trim()),
              child: const Text('Kirim Link'),
            ),
          ],
        );
      }
    );

    if (email == null || email.isEmpty) return;

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        _showDialog(
          title: 'Email Terkirim',
          content: 'Silakan cek email Anda ($email) untuk link reset password.',
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim email. Pastikan email terdaftar.'), backgroundColor: Colors.red));
    }
  }

  void _showDialog({required String title, required String content}) {
      showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            content: Text(content, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800])),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              ),
            ],
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.money, size: 80, color: isDark ? Colors.white : Colors.black),
                const SizedBox(height: 16),
                Text('Main Kere Hore', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(_isLoginMode ? 'Daftar Game Kere Hore!' : 'Gabung sekarang!', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700])),
                const SizedBox(height: 40),
                
                // --- KARTU INPUT ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: Colors.white24) : Border.all(color: Colors.black12),
                    boxShadow: [
                       BoxShadow(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(controller: _emailController, decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: 'Email')),
                      const SizedBox(height: 16),
                      TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'Password')),
                      
                      const SizedBox(height: 12),

                      // --- [FIX] BAGIAN TOMBOL LUPA PASSWORD ---
                      // Saya gunakan Row + Spacer agar pasti nempel ke kanan
                      if (_isLoginMode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _handleResetPassword,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                child: Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Colors.blue, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else 
                        const SizedBox(height: 24), // Spasi jika mode register
                      
                      const SizedBox(height: 10),

                      // --- TOMBOL UTAMA ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                            ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white) 
                            : Text(_isLoginMode ? 'LOGIN' : 'REGISTER', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(_isLoginMode ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Login', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}