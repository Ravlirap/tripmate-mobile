import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_theme.dart';

class AddEditTripScreen extends StatefulWidget {
  final Trip? trip;
  final VoidCallback onSaved;
  const AddEditTripScreen({super.key, this.trip, required this.onSaved});

  @override
  State<AddEditTripScreen> createState() => _AddEditTripScreenState();
}

class _AddEditTripScreenState extends State<AddEditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _quotaController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  bool _isEdit = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.trip != null;
    if (widget.trip != null) {
      _titleController.text = widget.trip!.title;
      _destinationController.text = widget.trip!.destination;
      _dateController.text = widget.trip!.date;
      _quotaController.text = widget.trip!.quota.toString();
      _priceController.text = widget.trip!.price.toString();
      _descController.text = widget.trip!.description;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitting = true);
      final user = ApiService.currentUser!;
      final trip = Trip(
        id: _isEdit ? widget.trip!.id : '', // id akan di-generate oleh backend
        organizerId: user.id,
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        date: _dateController.text.trim(),
        quota: int.parse(_quotaController.text.trim()),
        price: int.parse(_priceController.text.trim()),
        description: _descController.text.trim(),
        imageUrl: _isEdit
            ? widget.trip!.imageUrl
            : 'https://picsum.photos/seed/${DateTime.now()}/400/200',
      );

      bool success;
      if (_isEdit) {
        success = await ApiService.updateTrip(trip);
      } else {
        success = await ApiService.addTrip(trip);
      }
      setState(() => _submitting = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEdit ? 'Trip berhasil diperbarui!' : 'Trip berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal menyimpan trip'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Trip' : 'Tambah Trip'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section: Info Dasar ---
              _buildSectionHeader(Icons.info_outline_rounded, 'Informasi Dasar'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Trip',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destinasi',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // --- Section: Jadwal & Kuota ---
              _buildSectionHeader(Icons.event_rounded, 'Jadwal & Kuota'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Keberangkatan',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _quotaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kuota Peserta',
                  prefixIcon: Icon(Icons.people_alt_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // --- Section: Harga ---
              _buildSectionHeader(Icons.payments_rounded, 'Harga'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga per Orang (Rp)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // --- Section: Deskripsi ---
              _buildSectionHeader(Icons.description_rounded, 'Deskripsi Trip'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi lengkap trip',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 36),

              // --- Submit ---
              CustomButton(
                text: _submitting
                    ? 'Menyimpan...'
                    : (_isEdit ? 'Perbarui Trip' : 'Simpan Trip'),
                icon: _submitting
                    ? null
                    : (_isEdit ? Icons.save_rounded : Icons.add_rounded),
                onPressed: _submitting ? null : _submit,
                isOutlined: false,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}