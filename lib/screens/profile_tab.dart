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

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user?.name[0] ?? '?',
                style:
                    GoogleFonts.poppins(fontSize: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? '-',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '-',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user?.role == 'organizer' ? 'Penyedia Trip' : 'Traveler',
                style: GoogleFonts.poppins(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: auth.isLoading ? 'Memproses...' : 'Keluar',
              onPressed: auth.isLoading
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Keluar'),
                          content:
                              const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await auth.logout();
                                // Provider akan otomatis refresh, kembali ke SplashScreen
                              },
                              child: const Text('Keluar',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
