import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
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
        const SnackBar(content: Text('Pemesanan berhasil dikirim!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // kembali ke detail
      Navigator.pop(context); // kembali ke home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat pemesanan'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pemesanan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.trip.destination, style: GoogleFonts.poppins(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Jumlah Peserta', style: GoogleFonts.poppins(fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _participantCount > 1 ? () => setState(() => _participantCount--) : null,
                ),
                Text('$_participantCount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _participantCount++),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Contoh: minta pick up atau request khusus',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _submitting ? 'Memproses...' : 'Kirim Pemesanan',
              onPressed: _submit,
              isOutlined: false,
            ),
          ],
        ),
      ),
    );
  }
}