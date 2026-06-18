import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../widgets/trip_card.dart';
import '../../models/trip.dart';
import '../../theme/app_theme.dart';
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
    final user = ApiService.currentUser;
    final firstName = user?.name.split(' ').first ?? 'Traveler';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // --- Custom SliverAppBar ---
            SliverToBoxAdapter(
              child: _buildHeader(context, firstName),
            ),

            // --- Search Bar ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: GestureDetector(
                  onTap: () {
                    showSearch(
                        context: context,
                        delegate: TripSearchDelegate(trips));
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Cari destinasi atau trip...',
                          style: GoogleFonts.poppins(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Section Label ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'Open Trip Tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    if (!_loading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${trips.length} trip',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- Content ---
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (trips.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => TripCard(
                    trip: trips[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripDetailScreen(trip: trips[i]),
                        ),
                      ).then((_) => _loadTrips());
                    },
                  ),
                  childCount: trips.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $firstName 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mau petualangan ke mana hari ini?',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.explore_rounded,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
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
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore_outlined,
                  size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Trip Tersedia',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pantau terus, organizer sedang menyiapkan open trip terbaru untukmu!',
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

class TripSearchDelegate extends SearchDelegate {
  final List<Trip> allTrips;
  TripSearchDelegate(this.allTrips);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textGrey,
          fontSize: 14,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    final results = allTrips
        .where((t) =>
            t.destination.toLowerCase().contains(query.toLowerCase()) ||
            t.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results.isEmpty
        ? _buildSearchEmpty()
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: results.length,
            itemBuilder: (ctx, i) => TripCard(trip: results[i], onTap: () {}),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allTrips
        .where((t) =>
            t.destination.toLowerCase().contains(query.toLowerCase()) ||
            t.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return suggestions.isEmpty && query.isNotEmpty
        ? _buildSearchEmpty()
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (ctx, i) => ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary, size: 18),
              ),
              title: Text(
                suggestions[i].destination,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                suggestions[i].title,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              onTap: () {
                query = suggestions[i].destination;
                showResults(context);
              },
            ),
          );
  }

  Widget _buildSearchEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 60, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil untuk "$query"',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}