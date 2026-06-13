import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_ppb_app/core/constants/app_constants.dart';
import 'package:tubes_ppb_app/core/theme/app_theme.dart';
import 'package:tubes_ppb_app/data/models/trip_model.dart';
import 'package:tubes_ppb_app/providers/trip_provider.dart';
import 'package:tubes_ppb_app/providers/auth_provider.dart';
import 'package:tubes_ppb_app/presentation/pages/trip_detail_page.dart';
import 'package:tubes_ppb_app/presentation/pages/login_page.dart';
import 'package:tubes_ppb_app/presentation/pages/booking_history_page.dart';
import 'package:tubes_ppb_app/presentation/pages/agent_trip_list_page.dart';
import 'package:tubes_ppb_app/presentation/widgets/section_header.dart';
import 'package:tubes_ppb_app/presentation/widgets/trip_card.dart';

/// Home page displaying a list of available open trips.
/// Features: greeting header, category filter chips, and scrollable trip cards.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _categories = ['Semua', 'Gunung', 'Pantai', 'Pulau', 'Budaya'];
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().fetchTrips();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns filtered trips based on the selected category.
  List<Trip> _getFilteredTrips(List<Trip> allTrips) {
    if (_selectedCategoryIndex == 0) return allTrips;
    final category = _categories[_selectedCategoryIndex];
    return allTrips.where((trip) => trip.category == category).toList();
  }

  void _navigateToDetail(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
    );
  }

  Future<void> _handleRefresh() async {
    await context.read<TripProvider>().fetchTrips(search: _searchController.text);
  }

  void _triggerSearch(String query) {
    context.read<TripProvider>().fetchTrips(search: query);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: _buildAppBar(authProvider),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primary,
        child: Consumer<TripProvider>(
          builder: (context, tripProvider, child) {
            final filteredTrips = _getFilteredTrips(tripProvider.trips);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Greeting Section ──
                SliverToBoxAdapter(child: _buildGreetingSection(authProvider)),

                // ── Search Bar ──
                SliverToBoxAdapter(child: _buildSearchBar()),

                // ── Category Chips ──
                SliverToBoxAdapter(child: _buildCategoryChips()),

                // ── Section Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SectionHeader(
                      title: AppConstants.popularTrips,
                      actionText: tripProvider.trips.isNotEmpty ? AppConstants.seeAll : null,
                    ),
                  ),
                ),

                // ── Core States: Loading, Error, Empty, or List ──
                if (tripProvider.isLoading && tripProvider.trips.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else if (tripProvider.errorMessage != null && tripProvider.trips.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text(
                              tripProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _handleRefresh,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (filteredTrips.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 60, color: AppTheme.textLight),
                            SizedBox(height: 12),
                            Text(
                              'Tidak ada open trip yang sesuai.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trip = filteredTrips[index];
                        return TripCard(
                          trip: trip,
                          onTap: () => _navigateToDetail(trip),
                        );
                      },
                      childCount: filteredTrips.length,
                    ),
                  ),

                // ── Bottom Spacing ──
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Custom AppBar with auth status triggers.
  PreferredSizeWidget _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Text(AppConstants.appName),
        ],
      ),
      actions: [
        if (authProvider.isAuthenticated) ...[
          // Agent Dashboard Link (if agent)
          if (authProvider.user!.isAgent)
            IconButton(
              tooltip: 'Kelola Trip',
              icon: const Icon(Icons.dashboard_customize_rounded, color: AppTheme.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgentTripListPage()),
                );
              },
            ),
          // Booking History Link (if traveler)
          if (authProvider.user!.isTraveler)
            IconButton(
              tooltip: 'Riwayat Booking',
              icon: const Icon(Icons.receipt_long_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
                );
              },
            ),
          // Profile/Logout Action
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar Aplikasi'),
                  content: const Text('Apakah Anda yakin ingin keluar dari TripMate?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await authProvider.logout();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil keluar.')),
                  );
                }
              }
            },
          ),
        ] else
          IconButton(
            tooltip: 'Masuk',
            icon: const Icon(Icons.login_rounded, color: AppTheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Greeting text dynamically reflecting auth user profile.
  Widget _buildGreetingSection(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final String greeting = authProvider.isAuthenticated
        ? 'Hai, ${authProvider.user!.name}! 👋'
        : AppConstants.greetingText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.isAuthenticated && authProvider.user!.isAgent
                ? 'Kelola trip dan layani traveler terbaik!'
                : AppConstants.tagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive search bar filtering trips from the API.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _triggerSearch,
          decoration: InputDecoration(
            hintText: 'Cari destinasi impianmu...',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLight,
                ),
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 22),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.textLight, size: 18),
              onPressed: () {
                _searchController.clear();
                _triggerSearch('');
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  /// Horizontal scrolling category filter chips.
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return ChoiceChip(
            label: Text(
              _categories[index],
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedCategoryIndex = index);
            },
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
