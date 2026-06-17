import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/trip.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

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
            content: Text(_isEdit ? 'Trip berhasil diperbarui!' : 'Trip berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan trip'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Trip' : 'Tambah Trip')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Judul Trip'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(labelText: 'Destinasi'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quotaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Kuota'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: _submitting ? 'Menyimpan...' : (_isEdit ? 'Update Trip' : 'Simpan Trip'),
                  onPressed: _submit,
                  isOutlined: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}