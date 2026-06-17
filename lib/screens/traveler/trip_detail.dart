import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import 'create_booking.dart';

class TripDetailScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                trip.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              trip.title,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Text(trip.destination, style: GoogleFonts.poppins(color: Colors.grey[600])),
                const Spacer(),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Text(trip.date, style: GoogleFonts.poppins(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga', style: GoogleFonts.poppins(color: Colors.grey[600])),
                      Text(
                        'Rp ${trip.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Kuota Tersisa', style: GoogleFonts.poppins(color: Colors.grey[600])),
                      Text('${trip.quota} peserta', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(trip.description, style: GoogleFonts.poppins(color: Colors.grey[700])),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Pesan Sekarang',
              onPressed: () {
                if (ApiService.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silakan login terlebih dahulu')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateBookingScreen(trip: trip),
                  ),
                );
              },
              isOutlined: false,
            ),
          ],
        ),
      ),
    );
  }
}