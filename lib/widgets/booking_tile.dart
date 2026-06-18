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
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.successLight;
      case 'cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Row ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tripTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dipesan: ${booking.bookingDate.toLocal().toString().split(' ')[0]}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(booking.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(booking.status),
                          color: _getStatusColor(booking.status),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(booking.status),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _getStatusColor(booking.status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 14),

              // --- Info Row ---
              Row(
                children: [
                  _buildDetailItem(
                    Icons.people_alt_rounded,
                    '${booking.participantCount} peserta',
                  ),
                  const SizedBox(width: 20),
                  if (booking.notes.isNotEmpty && booking.notes != '-')
                    Expanded(
                      child: _buildDetailItem(
                        Icons.sticky_note_2_outlined,
                        booking.notes,
                        flexible: true,
                      ),
                    ),
                ],
              ),

              // --- Action Buttons ---
              if (showActions && booking.status == 'pending') ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        label: 'Konfirmasi',
                        icon: Icons.check_rounded,
                        color: AppColors.success,
                        onPressed: () async {
                          final success = await ApiService.updateBookingStatus(
                              booking.id, 'confirmed');
                          if (success) {
                            onStatusChanged();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan dikonfirmasi'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal mengkonfirmasi'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        label: 'Tolak',
                        icon: Icons.close_rounded,
                        color: AppColors.error,
                        isOutlined: true,
                        onPressed: () async {
                          final success = await ApiService.updateBookingStatus(
                              booking.id, 'cancelled');
                          if (success) {
                            onStatusChanged();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan dibatalkan'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal membatalkan'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, {bool flexible = false}) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        flexible
            ? Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
    );
    return content;
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
        textStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
