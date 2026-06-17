import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/trip_card.dart';
import '../../models/trip.dart';
import '../../theme/app_theme.dart';
import 'add_edit_trip.dart';

class ManageTripsTab extends StatefulWidget {
  const ManageTripsTab({super.key});

  @override
  State<ManageTripsTab> createState() => _ManageTripsTabState();
}

class _ManageTripsTabState extends State<ManageTripsTab> {
  List<Trip> trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final user = ApiService.currentUser;
    if (user != null) {
      setState(() => _loading = true);
      final data = await ApiService.getTripsByOrganizer(user.id);
      setState(() {
        trips = data;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteTrip(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Trip?'),
        content: const Text('Trip yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiService.deleteTrip(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Trip dihapus'), backgroundColor: Colors.green),
        );
        _loadTrips();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal menghapus trip'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Trip Saya'), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddEditTripScreen(onSaved: _loadTrips)),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hiking, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Belum ada trip',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('Tekan tombol + untuk menambah',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: trips.length,
                  itemBuilder: (ctx, i) {
                    final trip = trips[i];
                    return TripCard(
                      trip: trip,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTripScreen(
                              trip: trip,
                              onSaved: _loadTrips,
                            ),
                          ),
                        );
                      },
                      showDelete: true,
                      onDelete: () => _deleteTrip(trip.id),
                    );
                  },
                ),
    );
  }
}
