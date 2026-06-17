import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BookingTile extends StatelessWidget {
  final String tripTitle;
  final Booking booking;
  final bool showActions;
  final VoidCallback onStatusChanged;

  const BookingTile({
    super.key,
    required this.tripTitle,
    required this.booking,
    required this.showActions,
    required this.onStatusChanged,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Menunggu Konfirmasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tripTitle,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(booking.status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Jumlah: ${booking.participantCount} peserta',
                style: GoogleFonts.poppins(color: Colors.grey[600])),
            Text('Catatan: ${booking.notes}',
                style: GoogleFonts.poppins(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              'Dipesan: ${booking.bookingDate.toLocal().toString().split(' ')[0]}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
            if (showActions && booking.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await ApiService.updateBookingStatus(
                            booking.id, 'confirmed');
                        if (success) {
                          onStatusChanged();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pesanan dikonfirmasi'),
                                backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Gagal mengkonfirmasi'),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Konfirmasi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await ApiService.updateBookingStatus(
                            booking.id, 'cancelled');
                        if (success) {
                          onStatusChanged();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pesanan dibatalkan'),
                                backgroundColor: Colors.red),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Gagal membatalkan'),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
