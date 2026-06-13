import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tubes_ppb_app/core/theme/app_theme.dart';
import 'package:tubes_ppb_app/providers/trip_provider.dart';
import 'package:tubes_ppb_app/presentation/pages/agent_trip_form_page.dart';

class AgentTripListPage extends StatefulWidget {
  const AgentTripListPage({super.key});

  @override
  State<AgentTripListPage> createState() => _AgentTripListPageState();
}

class _AgentTripListPageState extends State<AgentTripListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchAgentTrips();
    });
  }

  void _navigateForm({String? tripId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentTripFormPage(tripId: tripId),
      ),
    ).then((updated) {
      if (updated == true) {
        context.read<TripProvider>().fetchAgentTrips();
      }
    });
  }

  void _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Trip'),
        content: const Text('Apakah Anda yakin ingin menghapus open trip ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<TripProvider>().deleteTrip(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Trip berhasil dihapus.' : 'Gagal menghapus trip.'),
            backgroundColor: success ? AppTheme.success : Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Open Trip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<TripProvider>().fetchAgentTrips(),
          )
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.agentTrips.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (provider.errorMessage != null && provider.agentTrips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchAgentTrips(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.agentTrips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.beach_access_outlined, size: 60, color: AppTheme.textLight),
                    const SizedBox(height: 12),
                    const Text(
                      'Anda belum membuat open trip.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Trip Pertama'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.agentTrips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trip = provider.agentTrips[index];
              final isPublished = trip.status == 'published';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          trip.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.divider,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.textLight),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Status chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isPublished
                                        ? AppTheme.success.withValues(alpha: 0.1)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    trip.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isPublished ? AppTheme.success : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Sisa Kuota: ${trip.remainingQuota}/${trip.maxQuota}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              trip.destination,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currencyFormat.format(trip.price),
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(trip.departureDate),
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                            onPressed: () => _navigateForm(tripId: trip.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => _handleDelete(trip.id),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateForm(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat Trip'),
      ),
    );
  }
}
