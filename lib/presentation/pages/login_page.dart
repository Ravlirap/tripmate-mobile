import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_ppb_app/core/theme/app_theme.dart';
import 'package:tubes_ppb_app/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedRole = 'traveler';
  bool _useDemoMode = false;

  void _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();

    if (_useDemoMode) {
      _handleDemoSync();
      return;
    }

    final success = await authProvider.loginWithGoogle(selectedRole: _selectedRole);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${authProvider.user?.name}!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && authProvider.errorMessage != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Detail Konfigurasi'),
          content: Text(
            'Google Sign-In gagal: ${authProvider.errorMessage}\n\n'
            'Pastikan google-services.json sudah terpasang dan SHA-1 ditambahkan ke Firebase Console.\n\n'
            'Ingin masuk menggunakan mode Demo untuk pengujian?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _useDemoMode = true);
                _handleDemoSync();
              },
              child: const Text('Masuk Mode Demo'),
            ),
          ],
        ),
      );
    }
  }

  void _handleDemoSync() async {
    final authProvider = context.read<AuthProvider>();
    final isAgent = _selectedRole == 'agent';
    authProvider.setLoading(true);
    authProvider.clearError();
    try {
      final demoResult = await authProvider.authService.firebaseSync(
        firebaseUid: isAgent ? 'demo_agent_firebase_uid_999' : 'demo_traveler_firebase_uid_111',
        name: isAgent ? 'Demo Travel Agent' : 'Demo Traveler',
        email: isAgent ? 'agent.demo@tripmate.com' : 'traveler.demo@tripmate.com',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        phone: '08123456789',
        role: _selectedRole,
      );

      authProvider.setUser(demoResult['user']);
      final token = demoResult['token'] as String;
      await authProvider.secureStorage.write(key: 'sanctum_token', value: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil masuk via Demo Sync sebagai $_selectedRole!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koneksi backend gagal: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      authProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabung TripMate'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.explore_rounded, size: 72, color: AppTheme.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Selamat Datang di TripMate',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Temukan atau kelola open trip impianmu dengan mudah dan aman.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Role Selector
                Text(
                  'PILIH PERAN ANDA',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRoleCard('traveler', Icons.backpack_rounded, 'Traveler', 'Cari & pesan open trip'),
                    const SizedBox(width: 16),
                    _buildRoleCard('agent', Icons.storefront_rounded, 'Travel Agent', 'Kelola & jual open trip'),
                  ],
                ),
                const SizedBox(height: 48),

                // Error Message
                if (authProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Google Button / Loading
                if (authProvider.isLoading)
                  const CircularProgressIndicator(color: AppTheme.primary)
                else
                  ElevatedButton(
                    onPressed: _handleGoogleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          _useDemoMode ? 'Simulasi Sync Google' : 'Masuk dengan Google',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => setState(() => _useDemoMode = !_useDemoMode),
                  child: Text(
                    _useDemoMode ? 'Kembali ke Google login asli' : 'Aktifkan mode Demo (bypass OAuth)',
                    style: TextStyle(
                      fontSize: 11,
                      color: _useDemoMode ? AppTheme.primary : AppTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.divider,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: isSelected ? AppTheme.primary : AppTheme.textLight),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
