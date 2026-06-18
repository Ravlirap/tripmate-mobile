import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../widgets/booking_tile.dart';
import '../../models/booking.dart';
import '../../models/trip.dart';
import '../../theme/app_theme.dart';

class ManageBookingsTab extends StatefulWidget {
  const ManageBookingsTab({super.key});

  @override
  State<ManageBookingsTab> createState() => _ManageBookingsTabState();
}

class _ManageBookingsTabState extends State<ManageBookingsTab> {
  List<Booking> bookings = [];
  // FIXED: simpan map tripId -> tripTitle agar tidak fetch berulang
  Map<String, String> tripTitles = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = ApiService.currentUser;
    if (user != null) {
      setState(() => _loading = true);

      final data = await ApiService.getBookingsByOrganizer(user.id);
      data.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

      // FIXED: fetch judul trip untuk setiap booking secara paralel
      final Map<String, String> titles = {};
      final uniqueTripIds = data.map((b) => b.tripId).toSet();
      await Future.wait(uniqueTripIds.map((tripId) async {
        final Trip? trip = await ApiService.getTripById(tripId);
        titles[tripId] = trip?.title ?? 'Trip #$tripId';
      }));

      setState(() {
        bookings = data;
        tripTitles = titles;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  int get _pendingCount =>
      bookings.where((b) => b.status == 'pending').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // --- Header ---
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesanan Masuk',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Kelola pemesanan dari traveler',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.inbox_rounded,
                              color: AppColors.warning, size: 22),
                        ),
                      ],
                    ),
                    if (!_loading && _pendingCount > 0) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: AppColors.warning, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '$_pendingCount pesanan menunggu konfirmasimu',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // --- Content ---
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (bookings.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else ...[
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final booking = bookings[i];
                    // FIXED: gunakan judul asli dari map, fallback ke ID
                    final title =
                        tripTitles[booking.tripId] ?? 'Trip #${booking.tripId}';
                    return BookingTile(
                      tripTitle: title,
                      booking: booking,
                      showActions: true,
                      onStatusChanged: _loadBookings,
                    );
                  },
                  childCount: bookings.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 50, color: AppColors.secondary),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan dari traveler akan muncul di sini setelah mereka booking tripmu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
