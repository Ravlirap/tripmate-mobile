import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FIXED: pisahkan logic login agar lebih bersih dan aman
  Future<void> _handleLogin(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await auth.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // FIXED: cek mounted sebelum navigasi (hindari crash setelah widget dispose)
    if (!mounted) return;

    if (success) {
      // Kembali ke root (main.dart Consumer akan otomatis arahkan ke home)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleGoogleLogin(AuthProvider auth) async {
    final success = await auth.signInWithGoogle();

    // FIXED: cek mounted sebelum aksi UI
    if (!mounted) return;

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login Google gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: gunakan Consumer agar tidak rebuild seluruh tree
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Masuk')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Selamat Datang Kembali!',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk melanjutkan petualanganmu.',
                    style: GoogleFonts.poppins(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 32),

                  // --- Email Field ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Password Field ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      // FIXED: tambah toggle show/hide password
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                  ),

                  // --- Error Message ---
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        auth.errorMessage!,
                        style: GoogleFonts.poppins(
                            color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // --- Tombol Masuk ---
                  // FIXED: onPressed null-safe — CustomButton sekarang terima VoidCallback?
                  CustomButton(
                    text: auth.isLoading ? 'Memproses...' : 'Masuk',
                    onPressed: auth.isLoading ? null : () => _handleLogin(auth),
                    isOutlined: false,
                  ),
                  const SizedBox(height: 16),

                  // --- Divider ---
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('atau',
                            style:
                                GoogleFonts.poppins(color: Colors.grey[600])),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Tombol Google ---
                  _buildGoogleButton(auth),
                  const SizedBox(height: 16),

                  // --- Link ke Register ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun?', style: GoogleFonts.poppins()),
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                );
                              },
                        child: const Text('Daftar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        // FIXED: onPressed null ketika loading
        onPressed: auth.isLoading ? null : () => _handleGoogleLogin(auth),
        icon: auth.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                // FIXED: ganti Image.network (rawan gagal) dengan Icon + warna Google
                child: const Icon(
                  Icons.g_mobiledata,
                  color: Color(0xFF4285F4),
                  size: 22,
                ),
              ),
        label: Text(
          auth.isLoading ? 'Memproses...' : 'Masuk dengan Google',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.grey, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
