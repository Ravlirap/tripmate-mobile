import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import 'manage_trips_tab.dart';
import 'manage_bookings_tab.dart';
import '../profile_tab.dart';

class OrganizerHome extends StatefulWidget {
  final User user;
  final VoidCallback logoutCallback;
  const OrganizerHome(
      {super.key, required this.user, required this.logoutCallback});

  @override
  State<OrganizerHome> createState() => _OrganizerHomeState();
}

class _OrganizerHomeState extends State<OrganizerHome> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    ManageTripsTab(),
    ManageBookingsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.hiking_outlined),
              selectedIcon: Icon(Icons.hiking_rounded),
              label: 'Trip Saya',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pesanan Masuk',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
