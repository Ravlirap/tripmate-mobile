import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/trip_card.dart';
import '../../models/trip.dart';
import 'trip_detail.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Trip> trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    final data = await ApiService.getAllTrips();
    setState(() {
      trips = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Open Trip'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: TripSearchDelegate(trips));
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? const Center(child: Text('Belum ada trip tersedia'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: trips.length,
                  itemBuilder: (ctx, i) => TripCard(
                    trip: trips[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trips[i])),
                      ).then((_) => _loadTrips());
                    },
                  ),
                ),
    );
  }
}

class TripSearchDelegate extends SearchDelegate {
  final List<Trip> allTrips;
  TripSearchDelegate(this.allTrips);

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    final results = allTrips.where((t) => t.destination.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (ctx, i) => TripCard(trip: results[i], onTap: () {}),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allTrips.where((t) => t.destination.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(suggestions[i].destination),
        onTap: () {
          query = suggestions[i].destination;
          showResults(context);
        },
      ),
    );
  }
}