import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../widgets/booking_tile.dart';
import '../../models/booking.dart';

class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({super.key});

  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  List<Booking> bookings = [];
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
      setState(() {
        bookings = data;
        bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  // Fungsi untuk mengambil judul trip - karena tidak ada join, kita tampilkan ID
  String _getTripTitle(String tripId) {
    // Opsional: bisa panggil ApiService.getTripById, tapi akan banyak request.
    // Untuk saat ini tampilkan "Trip #id"
    return 'Trip #$tripId';
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
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Belum ada pemesanan', style: GoogleFonts.poppins(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: bookings.length,
                  itemBuilder: (ctx, i) {
                    final booking = bookings[i];
                    return BookingTile(
                      tripTitle: _getTripTitle(booking.tripId),
                      booking: booking,
                      showActions: false,
                      onStatusChanged: _loadBookings,
                    );
                  },
                ),
    );
  }
}