import 'package:flutter/material.dart';
import '../../models/user.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.hiking_outlined), label: 'Trip Saya'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan Masuk'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
