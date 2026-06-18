import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';

class CreateBookingScreen extends StatefulWidget {
  final Trip trip;
  const CreateBookingScreen({super.key, required this.trip});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _participantCount = 1;
  final _notesController = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    final user = ApiService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu')));
      return;
    }

    setState(() => _submitting = true);
    final booking = Booking(
      id: '', // akan diabaikan
      tripId: widget.trip.id,
      userId: user.id,
      participantCount: _participantCount,
      notes: _notesController.text.isEmpty ? '-' : _notesController.text,
      status: 'pending',
      bookingDate: DateTime.now(),
    );
    final success = await ApiService.addBooking(booking);
    setState(() => _submitting = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pemesanan berhasil dikirim!'),
            backgroundColor: AppColors.success),
      );
      Navigator.pop(context); // kembali ke detail
      Navigator.pop(context); // kembali ke home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal membuat pemesanan'),
            backgroundColor: AppColors.error),
      );
    }
  }

  String _formatPrice(int price) {
    return price
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  int get _totalPrice => widget.trip.price * _participantCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Pemesanan'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Trip Summary Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.trip.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.textGrey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trip.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              widget.trip.destination,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatPrice(widget.trip.price)} / orang',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Jumlah Peserta ---
            Text(
              'Jumlah Peserta',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Peserta',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Decrement
                  GestureDetector(
                    onTap: _participantCount > 1
                        ? () => setState(() => _participantCount--)
                        : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _participantCount > 1
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        size: 18,
                        color: _participantCount > 1
                            ? AppColors.primary
                            : AppColors.textGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_participantCount',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  // Increment
                  GestureDetector(
                    onTap: () => setState(() => _participantCount++),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Catatan ---
            Text(
              'Catatan Tambahan',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Contoh: minta pick up atau request khusus (opsional)',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.sticky_note_2_outlined),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // --- Total Price Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.secondary.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_participantCount × Rp ${_formatPrice(widget.trip.price)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Rp ${_formatPrice(_totalPrice)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Submit Button ---
            CustomButton(
              text: _submitting ? 'Memproses...' : 'Kirim Pemesanan',
              icon: _submitting ? null : Icons.send_rounded,
              onPressed: _submitting ? null : _submit,
              isOutlined: false,
            ),
          ],
        ),
      ),
    );
  }
}