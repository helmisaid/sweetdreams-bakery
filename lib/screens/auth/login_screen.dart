import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../auth/auth_state.dart';
import '../user/home_screen.dart';
import '../admin/admin_dashboard.dart';
import 'debug_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends AuthStateBase<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  final _authService = AuthService();

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showSnackBar('Silahkan masukkan email dan password', isError: true);
      return;
    }

    isLoading = true;

    try {
      debugPrint(
          'Attempting to sign in with email: ${_emailController.text.trim()}');

      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        debugPrint('Sign in successful, user ID: ${response.user!.id}');

        await Future.delayed(const Duration(milliseconds: 500));

        final role = await _authService.getUserRole();
        debugPrint('Retrieved user role: $role');

        if (mounted) {
          if (role == 'admin') {
            debugPrint('Navigating to Admin Dashboard');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          } else {
            debugPrint('Navigating to Home Screen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      }
    } catch (error) {
      debugPrint('Sign in error: $error');
      handleError(error);
    } finally {
      isLoading = false;
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showSnackBar('Silahkan masukkan email dan password', isError: true);
      return;
    }

    isLoading = true;

    try {
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      if (response.user != null && mounted) {
        if (response.session == null) {
          showSnackBar(
              'Registration successful! Please check your email for verification.');
        } else {
          showSnackBar('Daftar berhasil, silahkan login!');
        }

        setState(() {
          _isLoginMode = true;
        });
      }
    } catch (error) {
      handleError(error);
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1), // Light amber
              Color(0xFFFFE0B2), // Light orange
              Color(0xFFFFCCBC), // Light deep orange
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.brown.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // Menggunakan clipBehavior agar gradient tidak 'bocor' dari sudut
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.95),
                        ],
                      ),
                    ),
                    // --- BARU: Dibungkus dengan Form untuk validasi ---
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Header ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cake_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isLoginMode
                                ? 'Selamat Datang Kembali'
                                : 'Buat Akun',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLoginMode
                                ? 'Masuk dengan akun anda'
                                : 'Isi form untuk bergabung dengan kami',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                SizeTransition(
                                    sizeFactor: animation, child: child),
                            child: !_isLoginMode
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: TextFormField(
                                      controller: _displayNameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Nama Panggilan',
                                          border: OutlineInputBorder()),
                                      validator: (v) => !_isLoginMode &&
                                              v!.isEmpty
                                          ? 'Nama panggilan tidak boleh kosong'
                                          : null,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // --- Field Email ---
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                labelText: 'Alamat Email',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.isEmpty ? 'Email tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),

                          // --- Field Password (dengan show/hide) ---
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => v!.isEmpty
                                ? 'Password tidak boleh kosong'
                                : null,
                          ),

                          // --- Field Confirm Password (Kondisional) ---
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                SizeTransition(
                                    sizeFactor: animation, child: child),
                            child: !_isLoginMode
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscurePassword,
                                      decoration: const InputDecoration(
                                          labelText: 'Konfirmasi Password',
                                          border: OutlineInputBorder()),
                                      validator: (v) {
                                        if (!_isLoginMode && v!.isEmpty)
                                          return 'Mohon konfirmasi password';
                                        if (!_isLoginMode &&
                                            v != _passwordController.text)
                                          return 'Password tidak cocok';
                                        return null;
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 24),

                          // --- Tombol Aksi Utama ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : (_isLoginMode ? _signIn : _signUp),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5))
                                  : Text(_isLoginMode ? 'Masuk' : 'Daftar',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Tombol Ganti Mode ---
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => setState(
                                    () => _isLoginMode = !_isLoginMode),
                            child: Text(
                              _isLoginMode
                                  ? 'Belum punya akun? Daftar'
                                  : 'Sudah punya akun? Masuk',
                              style: TextStyle(
                                  color: Colors.brown.shade700,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
