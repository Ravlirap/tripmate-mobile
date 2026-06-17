import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    // FIXED: ambil initial dengan aman — hindari crash jika name kosong
    String initial = '?';
    if (user != null && user.name.isNotEmpty) {
      initial = user.name[0].toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // --- Avatar ---
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                // FIXED: pakai variabel 'initial' yang sudah aman
                initial,
                style: GoogleFonts.poppins(
                    fontSize: 40,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // --- Nama ---
            Text(
              user?.name ?? '-',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // --- Email ---
            Text(
              user?.email ?? '-',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // --- Badge Role ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user?.role == 'organizer' ? 'Penyedia Trip' : 'Traveler',
                style: GoogleFonts.poppins(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),

            // --- Info Card (bonus: tampilkan info user) ---
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                        Icons.person_outline, 'Nama', user?.name ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow(
                        Icons.email_outlined, 'Email', user?.email ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.badge_outlined,
                      'Role',
                      user?.role == 'organizer' ? 'Penyedia Trip' : 'Traveler',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Tombol Keluar ---
            // FIXED: CustomButton sekarang terima VoidCallback? sehingga null aman
            CustomButton(
              text: auth.isLoading ? 'Memproses...' : 'Keluar',
              onPressed: auth.isLoading
                  ? null
                  : () => _showLogoutDialog(context, auth),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // FIXED: pisahkan dialog ke method agar kode lebih rapi
  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // tutup dialog dulu
              await auth.logout();
              // FIXED: tidak perlu navigasi manual —
              // Consumer di main.dart otomatis redirect ke SplashScreen
            },
            child: const Text('Keluar',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
