import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../widgets/booking_tile.dart';
import '../../models/booking.dart';
import '../../models/trip.dart';

class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({super.key});

  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
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

      final data = await ApiService.getBookingsByUser(user.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Belum ada pemesanan',
                          style: GoogleFonts.poppins(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: bookings.length,
                  itemBuilder: (ctx, i) {
                    final booking = bookings[i];
                    // FIXED: gunakan judul asli dari map, fallback ke ID
                    final title =
                        tripTitles[booking.tripId] ?? 'Trip #${booking.tripId}';
                    return BookingTile(
                      tripTitle: title,
                      booking: booking,
                      showActions: false,
                      onStatusChanged: _loadBookings,
                    );
                  },
                ),
    );
  }
}
